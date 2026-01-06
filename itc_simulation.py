"""
This script implements a command line tool to perform analysis of
isothermal titration calorimetry (ITC) experiments using COPASI models.  It
supports two main workflows:

1. GENERATE CONFIG FILE: Extract global parameters and other key
   information from a COPASI model and produce a YAML configuration file.  The
   resulting configuration lists parameters under ``FITTED`` and ``FIXED``
   sections, together with sensible default bounds.  Users should review 
   the generated YAML and move parameters between ``FITTED`` and ``FIXED`` 
   as desired before fitting.

2. PERFORM MODEL FITTING: Given a COPASI model, a configuration YAML, and a data
   file of integrated injection heats, run a series of steady-state
   simulations to mimic the injections, compute the theoretical heat released
   per injection and optimise the chosen parameters to fit the experimental
   data.  The script writes the fitted parameter values to a report and
   generates a plot comparing simulated vs experimental heats.

This implementation relies on the `basiCO` package to interface with
COPASI.  The current environment may not include COPASI or basiCO; the
script is designed to be run in an environment where these are installed.

Usage::

    python itc_simulation.py build_config \
        --model model.cps \

    # edit config.yaml as needed, then

    python itc_simulation.py fit \
        --model model.cps \
        --data example_data.csv \
        --config config.yaml \
        --output results

The fitting routine will create ``results_report.txt``, ``results_fit.yaml`` and
``results_plot.png`` in the specified output directory.
"""

import argparse
import logging
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Iterable, Optional

import numpy as np
import pandas as pd
import yaml

logger = logging.getLogger(__name__)

# Try importing basiCO and SciPy; raise informative errors if unavailable
try:
    import basico # type: ignore
except ImportError as e:
    basico = None  # fallback; will raise at runtime if called

try:
    from scipy.optimize import minimize
except ImportError:
    minimize = None  # type: ignore


def _default_bounds(value: float) -> Tuple[float, float]:
    """Return a default (min, max) bound around a parameter value.
    Returns
    -------
    tuple
        A (min, max) tuple representing default bounds.
    """
    if value == 0:
        return (-1.0, 1.0)
    # choose one order of magnitude around the absolute value
    magnitude = abs(value)
    return (0.1 * magnitude if value > 0 else 1.1 * value,
            10 * magnitude if value > 0 else -0.1 * value)


def split_species_compartment(name: str) -> Tuple[str, Optional[str]]:
    """Split a species name into base name and optional compartment.

    Expected formats:
      - "A" -> ("A", None)
      - "A{cell}" -> ("A", "cell")
      - "A{compartment_name}" -> ("A", "compartment_name")

    If braces are malformed, return the original name as base and None for
    the compartment.
    """
    if not isinstance(name, str):
        return (str(name), None)
    # prefer last '{' in case base contains braces
    try:
        i = name.rfind('{')
        j = name.rfind('}')
        if 0 <= i < j:
            base = name[:i]
            comp = name[i+1:j]
            return base, comp
    except Exception:
        pass
    return name, None


def make_species_name(base: str, compartment: Optional[str]) -> str:
    return f"{base}{{{compartment}}}" if compartment else base


def _sanitize_for_param(name: str) -> str:
    return ''.join(ch if ch.isalnum() else '_' for ch in name)


def build_config(model_path: Path, output_path: Path) -> None:
    """Generate a minimal YAML configuration template from a COPASI model.

    Loads the model with basiCO, extracts global parameters (placed under
    'FITTED' with default bounds) and an estimated cell volume (added to
    'FIXED').
    """
    if basico is None:
        raise RuntimeError("The 'basiCO' package is not available. Please install it to use this function.")

    logger.info(f"Loading COPASI model from {model_path}")
    model = basico.load_model(str(model_path))

    # Build configuration dictionary
    config: Dict[str, Dict] = {
        'FITTED': {},
        'FIXED': {},
        'MODEL_INFO': {
            'INJ_DELAY': 120.0,
        }
    }

    # Retrieve global parameters (model values)
    logger.info(f"Retrieving global parameters...")
    params_df = basico.get_parameters(model=model)
    params_df = params_df.reset_index()  # ensure 'name' is a column
    for _, row in params_df.iterrows():
        if row['type'] == 'assignment' or row['type'] == 'calculated': continue
        name = row['name']
        unit = row['unit']
        value = row['initial_value'] if not pd.isna(row['initial_value']) else row.get('value', np.nan)
        value = float(value) if not pd.isna(value) else 0.0
        min_bound, max_bound = _default_bounds(value)
        config['FITTED'][name] = {
            'value': value,
            'min': min_bound,
            'max': max_bound,
            'unit': unit
        }
        logger.info(f"  {name}: {value:.4g} {unit}")

    # Retrieve compartment information to guess cell volume
    logger.info(f"Retrieving compartments...")
    comps_df = basico.get_compartments(model=model)
    comps_df = comps_df.reset_index()
    # Try to identify a cell compartment by name; fall back to the first
    cell_volume = None
    cell_compartment_name = 'cell'
    syringe_compartment_name = 'syringe'
    for _, row in comps_df.iterrows():
        name = str(row['name']).lower()
        size = float(row['initial_size']) if not pd.isna(row['initial_size']) else None
        unit = row['unit']
        logger.info(f"  Found '{name}' with volume {size} {unit}")
        if 'cell' in name:
            logger.info(f"   -Saved as cell compartment")
            cell_volume = size
            cell_compartment_name = str(row['name'])
        elif 'syr' in name:
            logger.info(f"   -Saved as syringe compartment")
            syringe_compartment_name = str(row['name'])

    config['MODEL_INFO']['cell_compartment_name'] = cell_compartment_name
    config['MODEL_INFO']['syringe_compartment_name'] = syringe_compartment_name

    # Retrieve species to suggest starting concentrations for the user
    logger.info(f"Finding species...")
    species_df = basico.get_species(model=model)
    species_df = species_df.reset_index()
    species_initial_concs_cell: Dict[str, float] = {}
    species_initial_concs_syringe: Dict[str, float] = {}
    for _, srow in species_df.iterrows():
        sname_raw = str(srow.get('display_name'))
        # allow compartment encoded in the name (e.g. 'A{cell}') or in the compartment column
        base_name, comp_from_name = split_species_compartment(sname_raw)
        compartment_col = srow.get('compartment', None)
        compartment = comp_from_name if comp_from_name else compartment_col
        unit = srow.get('unit', '')
        ival = srow.get('initial_concentration', None)

        logger.info(f"  Found '{sname_raw}' (base='{base_name}') in '{compartment}' at {ival}")

        # If model concentration of species is zero or missing, skip suggestion
        if ival is None or pd.isna(ival) or float(ival) == 0.0:
            logger.info("   -Ignore (no initial concentration)")
            continue
        else: logger.info("   -Add to initial concentrations")

        # Adding stoichiometry parameter suggestions for cell species (use base name)
        cell_comp = config['MODEL_INFO'].get('cell_compartment_name', '')
        is_cell = (str(compartment).lower() == str(cell_comp).lower()) or (compartment is None and cell_comp == '')
        if is_cell:
            pname = f"N_{_sanitize_for_param(base_name)}"
            if pname not in config['FITTED']:
                v = 1.0
                pmin, pmax = _default_bounds(v)
                config['FITTED'][pname] = {'value': v, 'min': pmin, 'max': pmax, 'unit': ''}
                logger.info(f"   -Added fitted stoichiometry parameter suggestion: {pname} (default {v})")

        # store initial concentrations under cell/syringe buckets using the exact species name
        if is_cell: species_initial_concs_cell[sname_raw] = float(ival)
        else: species_initial_concs_syringe[sname_raw] = float(ival)

    # Add species initial concentrations to FIXED as suggestions
    if species_initial_concs_cell: config['FIXED']['cell_species_initial_conc'] = species_initial_concs_cell
    if species_initial_concs_syringe: config['FIXED']['syringe_species_initial_conc'] = species_initial_concs_syringe

    # Retrieve reactions and enthalpies
    logger.info(f"Getting reactions...")
    reactions_df = basico.get_reactions(model=model).reset_index()
    for _, row in reactions_df.iterrows():
        name = row['name']
        print(name)
        scheme = row['scheme']
        substrates = row['mapping']['substrate']
        if type(substrates) is str:
            substrates = [substrates]
        compartment = cell_compartment_name  # default
        if all([syringe_compartment_name in substrate for substrate in substrates]):
            print("Syringe interaction, can't fit this")
        for substrate in substrates:
            if syringe_compartment_name in substrate:
                compartment = syringe_compartment_name
                    
        logger.info(f"  Found reaction '{name}' in '{compartment}': {scheme}")

        if compartment == cell_compartment_name:
            global_params_name = f"dH_{name}"
            if global_params_name not in config['FITTED']:
                config['FITTED'][global_params_name] = {
                    'value': -30000.0,
                    'min': -100000.0,
                    'max': 100000.0,
                    'unit': 'J/mol'
                }
                logger.info(f"   -Adding enthalpy parameter '{global_params_name}'")
            else: logger.info(f"   -Enthalpy parameter '{global_params_name}' already exists; skipping addition")

    # Add dilution heat offset parameter
    logger.info(f"Adding dilution heat offset term...")
    config['FITTED']['Offset'] = {
        'value': -2000.0,
        'min': -10000.0,
        'max': 10000.0,
        'unit': 'J'
    }

    # Add the cell volume to the FIXED section; users may need to adjust units
    if cell_volume is not None:
        config['FIXED']['cell_volume'] = cell_volume

    # Write YAML file
    with open(output_path, 'w') as f:
        yaml.dump(config, f, sort_keys=False)
    logger.info(f"Configuration written to {output_path}")


def _parse_data(data_path: Path, inj_delay: float = 120.0) -> Tuple[List[float], List[float], List[float], List[bool], List[float]]:
    """
    Parse the experimental data file to extract injection volumes, times, heat column names,
    inclusion flags and the molar ratio values.

    The CSV is parsed heuristically: columns containing ``v_inj``, ``volume`` or ``vol`` are
    assumed to correspond to the injected volumes; columns containing ``time`` denote
    the injection times; columns containing ``ratio`` or ``x`` are assumed to provide
    the molar ratio values; and any columns with names containing ``heat``, ``enthalpy``,
    ``q`` or ``peak`` are treated as replicate heat measurements.  A column with
    ``include`` in its name, if present, is interpreted as a boolean flag (1 to include,
    0 to exclude) for each injection.

    If no time column is present, the injection times are generated assuming uniform
    spacing with a delay equal to ``inj_delay`` seconds between successive injections.

    Parameters
    ----------
    data_path : Path
        Path to the experimental CSV file.
    inj_delay : float, optional
        Time interval between injections (seconds) used when no time column exists in
        the data.  Default is 120.0 seconds.

    Returns
    -------
    tuple
        A tuple ``(volumes, times, heat_cols, include, x)`` where ``volumes`` and
        ``times`` are lists of floats specifying the volume and time of each injection,
        ``heat_cols`` is a list of column names corresponding to the heat measurements,
        ``include`` is a list of booleans indicating which injections to include in
        the fit, and ``x`` is a list of molar ratio values (if present, otherwise
        an empty list).
    """
    df = pd.read_csv(data_path)
    include_col = None
    volumes_col = None
    delays_col = None
    molar_ratio_col = None
    heat_cols: List[str] = []
    for col in df.columns:
        lcol = col.lower()
        if include_col is None and 'include' in lcol:
            include_col = col
        if volumes_col is None and any(key in lcol for key in ['v_inj', 'volume', 'vol']):
            volumes_col = col
        if delays_col is None and 'delay' in lcol:
            delays_col = col
        if molar_ratio_col is None and any(key in lcol for key in ['ratio', 'x']):
            molar_ratio_col = col
        if any(key in lcol for key in ['heat', 'enthalpy', 'q', 'peak']):
            heat_cols.append(col)

    if volumes_col is None:
        raise ValueError("Data file must contain a column indicating injection volumes (e.g. 'volume' or 'vol').")

    volumes = df[volumes_col].astype(float).tolist()
    # Collect molar ratios if available
    x: List[float] = []
    if molar_ratio_col is not None:
        x = df[molar_ratio_col].astype(float).tolist()

    # Determine injection times
    if delays_col is not None: delays = df[delays_col].astype(float).tolist()
    else:
        # Use regular spacing based on inj_delay
        delays = [float(i) * float(inj_delay) for i in range(len(volumes))]

    # Determine which injections to include
    if include_col is not None: include = pd.to_numeric(df[include_col], errors='coerce').fillna(0).astype(int).eq(1).tolist()
    else: include = [True] * len(volumes)

    # Compute experimental heats by averaging replicate columns if present
    heats: List[float] = []
    if heat_cols:
        # convert heat columns to numeric, coerce errors to NaN
        heat_df = df[heat_cols].apply(pd.to_numeric, errors='coerce')
        heats = heat_df.mean(axis=1).astype(float).tolist()
    else:
        # No heat columns found; return empty list to be handled downstream
        heats = []

    # Print summary of data file parsing
    logger.info(f"Parsed data file '{data_path}':")
    _volumes = []
    for v in volumes:
        _v = f'{v:.2E}'
        if len(_volumes) == 0 or _v != _volumes[-1]:
            _volumes.append(_v)
    logger.info(f"  Injection volumes from column: '{volumes_col}': {_volumes}")
    if delays_col is not None: logger.info(f"  Injection delays from column: '{delays_col}': {delays}")
    else: logger.info(f"  No injection delay column found; using uniform delay of {inj_delay} seconds")
    if molar_ratio_col is not None: logger.info(f"  Molar ratios from column: '{molar_ratio_col}'")
    if include_col is not None: logger.info(f"  Inclusion flags from column: '{include_col}': {include}")
    
    logger.info(f"  Heat measurements from columns: {heat_cols}")

    return volumes, delays, heats, include, x


def _compute_q(concentrations: Dict[str, float], enthalpy_map: Dict[str, float]) -> float:
    """Compute the heat content Q at a given state.

    Q is defined as the sum of the concentration of each bound complex times
    its enthalpy parameter.  Only species present in ``enthalpy_map`` are
    considered.

    Parameters
    ----------
    concentrations : dict
        Mapping from species name to its concentration.
    enthalpy_map : dict
        Mapping from species name to the enthalpy (J/mol) associated with
        binding that species.

    Returns
    -------
    float
        The calculated Q value (J per liter).  Units depend on concentrations
        being mol/L and enthalpy values being J/mol.
    """
    q = 0.0
    for species, enthalpy in enthalpy_map.items():
        conc = concentrations.get(species, 0.0)
        q += conc * enthalpy
    return q


def _simulate(
        model_path: Path,
        config: Dict,
        volumes: List[float],
        delays: List[float],
        param_values: Optional[Dict[str, float]] = None,
    ) -> Tuple[List[float], List[float]]:

        model = basico.load_model(str(model_path))

        # collect parameters (FITTED + numeric FIXED) and apply overrides
        params: Dict[str, float] = {}
        for pname, info in config.get('FITTED', {}).items():
            params[pname] = float(info.get('value', 0.0))
        
        for pname, info in config.get('FIXED', {}).items():
            # FIXED may be a mapping of names->values or nested dicts
            if pname in ["cell_species_initial_conc", "syringe_species_initial_conc"]:
                compartment = pname.split('_')[0]
                for sname, sval in info.items():
                    logger.debug(f"Setting {compartment} initial concentration of species '{sname}' to {sval} in model.")
                    try:
                        basico.set_species(model=model, name=f"{sname}{'{' + compartment + '}'}", compartment=compartment, initial_concentration=float(sval))
                    except Exception:
                        logger.fatal(f"Could not set species '{sname}' to {sval} in model.")
                        quit()
            else:
                if isinstance(info, dict) and 'value' in info: params[pname] = float(info['value'])
                else: params[pname] = float(info)

        if param_values:
            for k, v in param_values.items():
                params[k] = float(v)

        # apply numeric parameters to model
        for pname, pval in params.items():
            try:
                basico.set_parameters(model=model, name=pname, initial_value=float(pval))
            except Exception:
                logger.fatal(f"Could not set parameter '{pname}' to {pval} in model.")
                quit()

        # cell volume
        cell_volume = float(config.get('FIXED', {}).get('cell_volume', 1.0))

        # build enthalpy mapping from parameters named dH_*
        logger.debug("Building enthalpy mapping from config -> reaction products...")
        enthalpy_map: Dict[str, float] = {}
        model_info_cfg = config.get('MODEL_INFO', {}) or {}
        assumed_cell_comp = model_info_cfg.get('cell_compartment_name', 'cell')

        reactions_df = basico.get_reactions(model=model).reset_index()

        for _, rrow in reactions_df.iterrows():
            rname = rrow.get('name')
            dh_param = f"dH_{rname}"
            if dh_param not in params:
                continue
            dh_value = float(params[dh_param])

            mapping = rrow['mapping']
            products = mapping['product']
            if isinstance(products, str): products = [products]

            for prod in products:
                prod_str = str(prod)
                base, comp_in_name = split_species_compartment(prod_str)
                effective_comp = comp_in_name if comp_in_name else assumed_cell_comp
                key_with_comp = make_species_name(base, effective_comp)
                key_no_comp = base

                enthalpy_map[key_with_comp] = enthalpy_map.get(key_with_comp, 0.0) + dh_value
                enthalpy_map[key_no_comp] = enthalpy_map.get(key_no_comp, 0.0) + dh_value

                logger.debug(f"  Mapped dH '{dh_param}' ({dh_value}) -> product '{prod_str}' as '{key_with_comp}' and '{key_no_comp}'")

        # read model_info for compartment names
        model_info = config.get('MODEL_INFO', {})
        cell_compartment = model_info.get('cell_compartment_name', 'cell')
        syringe_compartment = model_info.get('syringe_compartment_name', 'syringe')

        # run steady state (best-effort)
        try:
            basico.run_steadystate(model=model)
        except Exception:
            logger.fatal("Could not reach steady state in model; proceeding with current state.")
            quit()

        if logger.level == logging.DEBUG:
            # Print species concentrations after equilibration
            species_df = basico.get_species(model=model).reset_index()
            logger.debug("Species concentrations after equilibration:")
            for _, srow in species_df.iterrows():
                sname = srow.get('display_name')
                sconc = srow.get('concentration', 0.0)
                logger.debug(f"  {sname}: {sconc}")

        # Read post equilibration syringe species concentrations from model
        syringe_initials_cfg: Dict[str, float] = {}
        try:
            species_df_all = basico.get_species(model=model).reset_index()
            for _, srow in species_df_all.iterrows():
                sname_raw = str(srow.get('display_name') or srow.get('name') or '')
                base_name, comp_from_name = split_species_compartment(sname_raw)
                effective_comp = comp_from_name if comp_from_name else srow.get('compartment', None)
                if str(effective_comp).lower() != str(syringe_compartment).lower():
                    continue
                conc = float(srow.get('concentration'))
                key = make_species_name(base_name, syringe_compartment)
                syringe_initials_cfg[key] = conc
        except Exception:
            logger.fatal("Could not read syringe species concentrations from model.")
            quit()

        # Run titration simulation
        heats: List[float] = []
        i = 0
        for v_inj, d_inj in zip(volumes, delays):
            logger.debug(f"Simulating injection #{i} of volume {v_inj} at delay {d_inj}...")
            i += 1
            # get pre-injection concentrations (only consider species in the cell compartment)
            species_df = basico.get_species(model=model)            
            conc_pre: Dict[str, float] = {}
            for _, srow in species_df.iterrows():
                sname = srow.get('display_name')
                base_name, comp_from_name = split_species_compartment(str(sname))
                effective_comp = comp_from_name if comp_from_name else srow.get('compartment', None)
                if str(effective_comp).lower() != str(cell_compartment).lower():
                    continue
                try:
                    sconc = float(srow.get('concentration', 0.0))
                except Exception:
                    sconc = 0.0
                conc_pre[sname] = sconc

            logger.debug(f"Pre-injection concentrations:  " + ", ".join(f"{k}={v:.2f}" for k, v in conc_pre.items()))

            # compute Q pre-injection
            q_pre = _compute_q(conc_pre, enthalpy_map)

            # compute post-mix concentrations by simple dilution + syringe input
            new_conc: Dict[str, float] = {}
            for sname, sconc in conc_pre.items():
                base_name, _ = split_species_compartment(str(sname))
                # try to find a syringe species with same base name
                inj_name = make_species_name(base_name, syringe_compartment)
                conc_inj = 0.0
                # priority: explicit syringe species initial concs from config
                if inj_name in syringe_initials_cfg:
                    conc_inj = float(syringe_initials_cfg[inj_name])
                else:
                    # try to read from model
                    try:
                        sres = basico.get_species(model=model, name=inj_name)
                        if sres is not None and len(sres) > 0:
                            conc_inj = float(sres.iloc[0].get('concentration', 0.0))
                    except Exception:
                        conc_inj = 0.0

                # mixing (conservative formula assuming constant cell volume)
                new_val = (sconc * cell_volume + conc_inj * float(v_inj)) / (cell_volume + float(v_inj))
                new_conc[sname] = new_val
                
                basico.set_species(model=model, name=sname, initial_concentration=new_val)
 
            logger.debug("Post-injection concentrations: " + ", ".join(f"{k}={v:.2f}" for k, v in new_conc.items()))

            # advance time to injection moment
            try:
                basico.run_time_course(model=model, duration=d_inj, update_model=True)
            except Exception:
                logger.fatal("Time-course advancement failed.")
                quit()

            # compute Q post-injection
            q_post = _compute_q(new_conc, enthalpy_map)

            # compute heat released
            dilution = (v_inj / cell_volume) * 0.5 * (q_pre + q_post)
            offset = params.get('Offset', 0.0)
            delta_h = q_post - q_pre + dilution
            heats.append(delta_h * cell_volume + float(offset))

            logger.debug(f"Injection heat: Q_pre={q_pre}, Q_post={q_post}, dH={delta_h}, dilution={dilution}, offset={offset}, heat={heats[-1]}")

        print(heats)
        quit()

        return heats, []


def _objective(
    param_vector: np.ndarray,
    param_names: List[str],
    config: Dict,
    volumes: List[float],
    delays: List[float],
    heats_exp: List[float],
    model_path: Path,
) -> float:
    """Objective function for optimisation.

    This wrapper computes the root mean square deviation (RMSD) between the
    simulated heats and the experimental heats for a given set of parameter
    values.

    Parameters
    ----------
    param_vector : ndarray
        Array of parameter values corresponding to ``param_names``.
    param_names : list of str
        Names of the parameters being optimised.
    config : dict
        Configuration dictionary used by :func:`_simulate`.

    Returns
    -------
    float
        The RMSD between simulated and experimental heats.
    """
    # Build parameter dictionary for simulation
    param_values = {name: value for name, value in zip(param_names, param_vector)}
    try:
        heats_sim, _ = _simulate(
            model_path=model_path,
            config=config,
            volumes=volumes,
            delays=delays,
            param_values=param_values,
        )
    except Exception as exc:
        logger.warning(f"Simulation failed for parameters {param_values}: {exc}")
        quit()
        return 1e20
    
    diff = np.array(heats_sim) - np.array(heats_exp)
    rmsd = float(np.sqrt(np.mean(diff**2)))
    return rmsd


def fit_model(model_path: Path, data_path: Path, config_path: Path, output_dir: Path) -> None:
    """Fit model parameters to experimental ITC data.

    This function reads a configuration file, extracts the list of fitted
    parameters and their bounds, parses the experimental data, and performs
    optimisation of the fitted parameters to minimise the RMS deviation
    between simulated and experimental heats.  It writes a report with the
    fitted values, generates a YAML file with updated parameter values,
    and produces a plot comparing simulation and experiment.

    Parameters
    ----------
    model_path : Path
        Path to the COPASI model (.cps).
    data_path : Path
        Path to the experimental CSV file.
    config_path : Path
        Path to the YAML configuration file.
    output_dir : Path
        Directory where output files (report, fit config, plot) should be
        written.  The directory will be created if it does not exist.
    """
    if basico is None:
        raise RuntimeError("The 'basiCO' package is not available. Please install it to use this function.")
    if minimize is None:
        raise RuntimeError("SciPy is required for optimisation but could not be imported. Please install scipy.")

    # Load configuration
    with open(config_path, 'r') as f:
        config = yaml.safe_load(f)
    # Parse data to obtain injection volumes, times, and experimental heats
    # Use the configured injection delay when no explicit time column exists
    default_inj_delay = config.get('MODEL_INFO', {}).get('INJ_DELAY', 120.0)
    volumes, delays, heats_exp, include, x = _parse_data(data_path, default_inj_delay)

    # Identify parameters to fit and their bounds
    fitted_params = config.get('FITTED', {})
    fit_names: List[str] = []
    fit_bounds: List[Tuple[float, float]] = []
    for pname, info in fitted_params.items():
        fit_names.append(pname)
        # Use specified bounds or default if missing
        pmin = info.get('min', None)
        pmax = info.get('max', None)
        if pmin is None or pmax is None:
            default_min, default_max = _default_bounds(float(info.get('value', 0.0)))
            pmin = default_min if pmin is None else pmin
            pmax = default_max if pmax is None else pmax
        fit_bounds.append((float(pmin), float(pmax)))
    
    # Initial guess vector
    x0 = np.array([float(fitted_params[name]['value']) for name in fit_names])

    logger.info(f"Starting optimisation of {len(fit_names)} parameters...")

    # Define objective wrapper capturing constant arguments
    def obj_wrapper(x: np.ndarray) -> float:
        return _objective(x, fit_names, config, volumes, delays, heats_exp, model_path)

    # Run optimisation using Nelder-Mead; other methods could be used depending on problem
    result = minimize(
        obj_wrapper,
        x0,
        method='Nelder-Mead',
        bounds=fit_bounds,
        options={'maxiter': 1000, 'disp': False},
    )

    logger.info(f"Optimisation completed. Success={result.success}, message={result.message}")
    # Update configuration with fitted values
    fitted_values = {name: float(val) for name, val in zip(fit_names, result.x)}
    for name, value in fitted_values.items():
        if name in config.get('FITTED', {}):
            config['FITTED'][name]['value'] = value

    # Generate final simulation with best-fit parameters
    heats_sim, ratios = _simulate(
        model_path=model_path,
        config=config,
        volumes=volumes,
        delays=delays,
        param_values=fitted_values,
    )
    # Prepare output directory
    output_dir.mkdir(parents=True, exist_ok=True)
    # Write report
    report_path = output_dir / 'results_report.txt'
    with open(report_path, 'w') as rep:
        rep.write("Fitted parameters:\n")
        for name, val in fitted_values.items():
            rep.write(f"  {name}: {val}\n")
        rep.write(f"\nObjective function value (RMSD): {result.fun}\n")
    # Write updated config
    fit_config_path = output_dir / 'results_fit.yaml'
    with open(fit_config_path, 'w') as cfgf:
        yaml.dump(config, cfgf, sort_keys=False)
    # Generate plot comparing experiment vs simulation
    try:
        import matplotlib
        matplotlib.use('Agg')  # use non-interactive backend
        import matplotlib.pyplot as plt
        plt.figure()
        plt.plot(ratios, heats_sim, label='Simulated', marker='o')
        # Align experimental data to same number of points if mismatch
        min_len = min(len(ratios), len(heats_exp))
        plt.plot(ratios[:min_len], heats_exp[:min_len], label='Experimental', marker='x')
        plt.xlabel('Molar ratio (titrant/macromolecule)')
        plt.ylabel('Heat per mole injected (J/mol)')
        plt.title('ITC Isotherm: simulation vs experiment')
        plt.legend()
        plot_path = output_dir / 'results_plot.png'
        plt.savefig(plot_path, dpi=300)
        plt.close()
    except Exception as exc:
        logger.warning(f"Could not generate plot: {exc}")

    logger.info(f"Report written to {report_path}")
    logger.info(f"Updated configuration written to {fit_config_path}")
    logger.info(f"Plot saved to {output_dir / 'results_plot.png'}")


def main() -> None:
    parser = argparse.ArgumentParser(description="ITC simulation and fitting using COPASI models.")
    subparsers = parser.add_subparsers(dest='command', required=True)

    # Subparser for build_config
    parser_build = subparsers.add_parser('build_config', help='Generate a YAML configuration from a COPASI model')
    parser_build.add_argument('--model', type=Path, required=True, help='Path to the COPASI model (.cps)')
    #parser_build.add_argument('--data', type=Path, default=None, help='Optional CSV file containing experimental data')
    parser_build.add_argument('--output', type=Path, default="config.yaml", help='Path to write the generated YAML configuration')

    # Subparser for fit
    parser_fit = subparsers.add_parser('fit', help='Fit model parameters to experimental data')
    parser_fit.add_argument('--model', type=Path, required=True, help='Path to the COPASI model (.cps)')
    parser_fit.add_argument('--data', type=Path, required=True, help='CSV file with experimental data')
    parser_fit.add_argument('--config', type=Path, required=True, help='YAML configuration file produced by build_config')
    parser_fit.add_argument('--output', type=Path, required=True, help='Directory where results will be written')

    args = parser.parse_args()
    logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
    logger.setLevel(logging.DEBUG)
    if args.command == 'build_config':
        build_config(args.model, args.output)
    elif args.command == 'fit':
        fit_model(args.model, args.data, args.config, args.output)


if __name__ == '__main__':
    main()