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

NA = 6.02214076e23  # Avogadro's number (particles per mole)

# Try importing basiCO and SciPy; raise informative errors if unavailable
try:
    import basico # type: ignore
except ImportError as e:
    basico = None  # fallback; will raise at runtime if called

try:
    from scipy.optimize import minimize
except ImportError:
    minimize = None  # type: ignore

try:
    # Used only for confidence intervals; the script still works if scipy.stats is unavailable.
    from scipy.stats import t as _student_t
except Exception:
    _student_t = None  # type: ignore

# Try importing SciPy's approx_derivative for numerical Jacobian estimation.  If unavailable,
# we will fall back to our own finite difference routine.
try:
    # SciPy exposes a private numdiff module used by optimize.  We attempt to import
    # approx_derivative from there.  If this import fails (e.g. SciPy not installed),
    # ``_approx_derivative`` will be ``None`` and a fallback implementation will be used.
    from scipy.optimize._numdiff import approx_derivative as _approx_derivative  # type: ignore
except Exception:
    _approx_derivative = None  # type: ignore



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
    return (0.01 * magnitude if value > 0 else 1.1 * value,
            100 * magnitude if value > 0 else -0.1 * value)


def split_species_compartment(name: str, default_compartment: str, valid_compartments: List[str]) -> Tuple[str, Optional[str]]:
    """Split a species name into base name and optional compartment.

    Expected formats:
      - "A" -> ("A", "cell")
      - "A{cell}" -> ("A", "cell")
      - "A{compartment_name}" -> ("A", "compartment_name")

    If braces are malformed, return the original name as base and None for
    the compartment.
    """
    if not isinstance(name, str):
        return (str(name), default_compartment)
    # prefer last '{' in case base contains braces
    i = name.rfind('{')
    j = name.rfind('}')
    if 0 <= i < j:
        base = name[:i]
        comp = name[i+1:j]

        if comp not in valid_compartments:
            logger.fatal(f"Compartment '{comp}' not in valid compartments: {valid_compartments}")
            quit()

        return base, comp
    
    return name, default_compartment  # default compartment


def get_species_concentration(model, compartment = None) -> Dict[str, float]:
    """Retrieve species concentrations from a basiCO model."""
    species_df = basico.get_species(model=model).reset_index()
    conc = {}
    for _, srow in species_df.iterrows():
        name = srow['name']
        comp = srow['compartment']
        if compartment != None and comp != compartment:
            continue
        conc[name] = float(srow['concentration'])

    return conc


def make_species_name(base: str, compartment: Optional[str]) -> str:
    return f"{base}{{{compartment}}}" if compartment else base


def get_parameter_name(name, type: str) -> str:
    if not isinstance(name, str):
        new_names = []
        for n in name:
            new_name = get_parameter_name(n, type)
            new_names.append(new_name)

        return new_names

    if '_' in name: # May contain specification "type_name"
        start = name.split('_')[0]
        if start in ['ode', 'dH', 'N']:
            basename = name[name.index('_'):]
            return type + basename
    
    return type + "_" + name


def sanitize_for_param(name: str) -> str:
    return ''.join(ch if ch.isalnum() else '_' for ch in name)


def _extract_param_value(info):
    if isinstance(info, dict) and 'value' in info:
        return info['value']
    return info


def _parse_param_value(raw, pname: str) -> Tuple[Optional[float], Optional[str]]:
    if isinstance(raw, str):
        raw_str = raw.strip()
        if raw_str == "":
            raise ValueError(f"Parameter '{pname}' has an empty string value.")
        try:
            return float(raw_str), None
        except ValueError:
            return None, raw_str
    try:
        return float(raw), None
    except (TypeError, ValueError):
        raise ValueError(f"Parameter '{pname}' has an invalid value: {raw!r}")


def resolve_parameter_values(parameters: Dict[str, object], overrides: Optional[Dict[str, float]] = None) -> Dict[str, float]:
    base_values: Dict[str, float] = {}
    aliases: Dict[str, str] = {}
    for pname, info in parameters.items():
        raw = _extract_param_value(info)
        value, alias = _parse_param_value(raw, pname)
        if alias is not None:
            aliases[pname] = alias
        else:
            base_values[pname] = float(value)

    if overrides:
        for key, value in overrides.items():
            if key in aliases:
                logger.warning(f"Ignoring override for aliased parameter '{key}'.")
                continue
            base_values[key] = float(value)

    resolved: Dict[str, float] = {}
    resolving = set()

    def _resolve(name: str) -> float:
        if name in resolved:
            return resolved[name]
        if name in resolving:
            raise ValueError(f"Circular parameter alias detected at '{name}'.")
        resolving.add(name)
        if name in aliases:
            target = aliases[name]
            if target == name:
                raise ValueError(f"Parameter '{name}' cannot alias itself.")
            if target in aliases or target in base_values:
                value = _resolve(target)
            elif overrides and target in overrides:
                value = float(overrides[target])
            else:
                raise ValueError(f"Alias target '{target}' for parameter '{name}' not found.")
        else:
            if name in base_values:
                value = base_values[name]
            elif overrides and name in overrides:
                value = float(overrides[name])
            else:
                raise ValueError(f"Parameter '{name}' has no value.")
        resolved[name] = float(value)
        resolving.remove(name)
        return resolved[name]

    for pname in list(base_values.keys()) + list(aliases.keys()):
        _resolve(pname)

    return resolved


def _default_log_flag(pname: str, exp_names: List[str]) -> bool:
    if not pname.startswith(("Kd", "Keq")):
        return False
    if not exp_names:
        return True
    return not any(f"_{exp_name}" in pname for exp_name in exp_names)


def _param_uses_log_scale(pname: str, info_dict: Dict[str, object], exp_names: List[str]) -> bool:
    if isinstance(info_dict, dict) and 'log' in info_dict:
        return bool(info_dict['log'])
    return _default_log_flag(pname, exp_names)


def _vector_to_param_dict(x: np.ndarray, fit_names: List[str], log_flags: Dict[str, bool]) -> Dict[str, float]:
    out: Dict[str, float] = {}
    for name, val in zip(fit_names, x):
        if log_flags.get(name, False):
            out[name] = float(np.exp(val))
        else:
            out[name] = float(val)
    return out


def _transform_error_info_to_param_scale(error_info: Optional[Dict[str, object]], fit_names: List[str], log_flags: Dict[str, bool]) -> Optional[Dict[str, object]]:
    if error_info is None:
        return None
    if not any(log_flags.get(n, False) for n in fit_names):
        return error_info
    cov = np.asarray(error_info.get('cov', None), dtype=float)
    if cov.size == 0:
        return error_info
    x_opt = np.asarray(error_info.get('x_opt', None), dtype=float)
    if x_opt.size != len(fit_names):
        return error_info

    scale = np.ones(len(fit_names), dtype=float)
    for i, n in enumerate(fit_names):
        if log_flags.get(n, False):
            scale[i] = float(np.exp(x_opt[i]))

    cov_scaled = cov * scale[:, None] * scale[None, :]
    se_scaled = np.sqrt(np.diag(cov_scaled))
    with np.errstate(divide='ignore', invalid='ignore'):
        denom = np.outer(se_scaled, se_scaled)
        corr_scaled = np.divide(cov_scaled, denom, out=np.full_like(cov_scaled, np.nan), where=denom != 0)

    updated = dict(error_info)
    updated['cov'] = cov_scaled
    updated['se'] = se_scaled
    updated['corr'] = corr_scaled
    updated['se_by_name'] = {n: float(se_scaled[i]) for i, n in enumerate(fit_names)}
    updated['x_opt'] = np.asarray([
        float(np.exp(x_opt[i])) if log_flags.get(n, False) else float(x_opt[i])
        for i, n in enumerate(fit_names)
    ], dtype=float)
    if 'ci95_by_name' in updated:
        del updated['ci95_by_name']
    return updated


def check_and_repair_config(config):
    # Function to check if all fields of the config are valid
    logger.info("Checking config file...")
    if 'experiments' not in config:
        logger.fatal("Config does not contain experiments. Quitting")
        quit()
    if 'fitting' not in config:
        config['fitting'] = {}
        config['fitting']['max_iterations'] = 1000
        config['fitting']['estimate_errors'] = True
        logger.warning("Config file did not contain fitting routine information. Adding default values.")
        quit()

    required_elements = ['name','model_path','data_path','experiment_info']
    required_model_elements = ['cell_compartment_name', 'syringe_compartment_name', 'cell_volume', 'cell_species_initial_conc', 'syringe_species_initial_conc']
    
    for exp in config['experiments']:
        logger.info(f' -Checking {exp["name"]}...')
        for key in required_elements:
            if key not in exp:
                logger.fatal(f' -Experiment {exp["name"]} missing {key}. Quitting.')
                quit()
        for key in required_model_elements:
            if key not in exp['experiment_info']:
                logger.fatal(f' -Configuration file "experiment_info" missing key {key}. Quitting.')
                quit()
        if 'parameters' not in exp or len(exp['parameters']) == 0:
            logger.warning(f'Experiment {exp["name"]} does not contain any parameters. It is recommended to have individual N and Offset values.')

    logger.info("Config file check complete.")
    return config


def build_config(model_paths: List[Path], data_paths: Optional[List[Path]], output_path: Path) -> None:
    """Generate a YAML configuration file from one or more COPASI models.

    For each model, loads it with basiCO and extracts global parameters (with default bounds)
    and species information. The output YAML will have a top-level 'experiments' list.
    Each experiment entry contains:
      - name, model path, data path (if provided)
      - experiment_info (compartment names, cell volume, injection delay, initial species concentrations)
      - parameters (initial parameter values and bounds, including per-experiment N_* and Offset_* parameters)
    """
    if basico is None:
        raise RuntimeError("The 'basiCO' package is not available. Please install it to use this function.")

    config_out = {'fitting' : 
        {
        'max_iterations':   1000,
        'estimate_errors': True,
        }   
    }

    experiments_list: List[Dict] = []
    
    for idx, model_path in enumerate(model_paths):
        logger.info(f"Loading experiment with COPASI model from {Path(model_path).stem}")
        model = basico.load_model(str(model_path))
        data_path = None
        if data_paths is not None:
            if idx < len(data_paths): data_path = data_paths[idx]
            else: data_path = data_paths[-1]
        
        original_name = "exp"

        # Ensure unique experiment name
        exp_name = f"{original_name}_1"
        count = 2
        while any(exp.get('name') == exp_name for exp in experiments_list):
            exp_name = f"{original_name}_{count}"
            count += 1
        
        logger.info(f'  Using experiment name: {exp_name}')
        
        exp_dict: Dict[str, any] = {}
        exp_dict['name'] = exp_name
        exp_dict['model_path'] = str(model_path)
        exp_dict['data_path'] = str(data_path) if data_path is not None else ""
        
        # Build experiment_info and parameters
        exp_info: Dict[str, any] = {}

        logger.info("  Identifying compartments...")
        comps_df = basico.get_compartments(model=model).reset_index()
        cell_compartment_name = 'cell'
        syringe_compartment_name = 'syringe'
        cell_volume = None
        for _, crow in comps_df.iterrows():
            cname = str(crow['name'])
            size = float(crow['initial_size']) if not pd.isna(crow['initial_size']) else None
            unit = crow['unit']
            logger.info(f"    Found compartment '{cname}' with volume {size} {unit}")
            low_name = cname.lower()
            if 'cell' in low_name:
                cell_compartment_name = cname
                cell_volume = size
                logger.info(f"     -Assigned as cell compartment")
            elif 'syr' in low_name:
                syringe_compartment_name = cname
                logger.info(f"     -Assigned as syringe compartment")
        exp_info['cell_compartment_name'] = cell_compartment_name
        exp_info['syringe_compartment_name'] = syringe_compartment_name
        exp_info['cell_volume'] = float(cell_volume) if cell_volume is not None else 1.0
        exp_info['fallback_inj_delay'] = float(150)
        
        logger.info("  Identifying species...")
        species_df = basico.get_species(model=model).reset_index()
        species_initial_concs_cell: Dict[str, float] = {}
        species_initial_concs_syringe: Dict[str, float] = {}
        parameters: Dict[str, Dict] = {}
        for _, srow in species_df.iterrows():
            sname_raw = str(srow.get('display_name'))
            base_name, comp_from_name = split_species_compartment(sname_raw, cell_compartment_name,
                                                                   [cell_compartment_name, syringe_compartment_name])
            compartment_col = srow.get('compartment', None)
            compartment = comp_from_name if comp_from_name else compartment_col
            ival = srow.get('initial_concentration', None)
            if ival is None or pd.isna(ival) or float(ival) == 0.0:
                continue
            is_cell = (str(compartment).lower() == str(cell_compartment_name).lower()) or \
                      (compartment is None and cell_compartment_name == '')
            
            logger.info(f'    Found {base_name} in {compartment} with concentration: {ival:.2f}')
            if is_cell:
                species_initial_concs_cell[base_name] = float(ival) 
                pname = f"N_{sanitize_for_param(base_name)}_{exp_name}"
                if pname not in parameters:
                    parameters[pname] = 1.0
                    logger.info("     -Adding associated N-value")
            else:
                species_initial_concs_syringe[sname_raw] = float(ival)
        
        exp_info['cell_species_initial_conc'] = species_initial_concs_cell if species_initial_concs_cell else {}
        exp_info['syringe_species_initial_conc'] = species_initial_concs_syringe if species_initial_concs_syringe else {}
        
        # Global parameters (model values)
        logger.info("  Identifying parameters...")
        params_df = basico.get_parameters(model=model).reset_index()
        for _, row in params_df.iterrows():

            # Check if parameter is value
            if row['type'] != 'fixed': continue 

            name = str(row['name'])
                
            # If parameter appears in any previous experiment skip (we already have it)
            if any(name in exp.get('parameters', {}) for exp in experiments_list): 
                logger.info(f'    Parameter "{name}" already present in previous experiment. Will be fitted globally.')
                continue    

            unit = row['unit']
            val = row['initial_value'] if not pd.isna(row['initial_value']) else row.get('value', np.nan)
            val = float(val) if not pd.isna(val) else 0.0
            parameters[name] = val

            logger.info(f'    Found {name} = {val}')
        
        # Reaction enthalpy parameters for cell reactions
        logger.info("  Identifying reactions...")
        reactions_df = basico.get_reactions(model=model).reset_index()
        for _, rrow in reactions_df.iterrows():
            rname = str(rrow['name'])
            mapping = rrow.get('mapping', {})
            subs = mapping.get('substrate', [])
            if isinstance(subs, str):
                subs = [subs]
            if any(syringe_compartment_name in sub for sub in subs): continue
            logger.info(f'    Found "{rname}" in cell: {rrow["scheme"]}')
            dh_param = f"dH_{rname}"
            if not any(dh_param in exp.get('parameters') for exp in experiments_list):
                parameters[dh_param] = -20000.0
                logger.info(f'    Adding enthalpy "{dh_param}" for reaction')
        
        # Add dilution heat offset parameter for this experiment
        offset_name = f"Offset_{exp_name}"
        parameters[offset_name] = -2000
        exp_dict['experiment_info'] = exp_info
        exp_dict['parameters'] = parameters
        experiments_list.append(exp_dict)
    
    config_out['experiments'] = experiments_list
    with open(output_path, 'w') as f:
        yaml.dump(config_out, f, sort_keys=False)
    
    logger.info(f"Configuration written to {output_path}")


def parse_data(data_path: Path, inj_delay: float = 150.0) -> Tuple[List[float], List[float], List[float], List[bool], List[float]]:
    """
    Parse the csvexperimental data csv file to extract injection volumes, delays, heats,
    inclusion flags and the molar ratio values.
    """
    logger.info(f"    Parsing data file: {data_path}...")
    df = pd.read_csv(data_path, comment="#")
    include_col = None
    volumes_col = None
    delays_col = None
    molar_ratio_col = None
    heat_cols: List[str] = []
    for col in df.columns:
        lcol = col.lower()
        if include_col is None and 'include' in lcol: include_col = col
        if volumes_col is None and any(key in lcol for key in ['v_inj', 'volume', 'vol']): volumes_col = col
        if delays_col is None and 'delay' in lcol: delays_col = col
        if molar_ratio_col is None and any(key in lcol for key in ['ratio', 'x']): molar_ratio_col = col
        if any(key in lcol for key in ['heat', 'enthalpy', 'q', 'peak']): heat_cols.append(col)

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
        delays = [inj_delay] * len(volumes)

    # Determine which injections to include
    if include_col is not None: include = pd.to_numeric(df[include_col], errors='coerce').fillna(0).astype(int).tolist()
    else: include = [1] * len(volumes)

    # Compute experimental heats by averaging replicate columns if present
    heats: List[float] = []
    if heat_cols:
        # convert heat columns to numeric, coerce errors to NaN
        heat_df = df[heat_cols].apply(pd.to_numeric, errors='coerce')
        heats = heat_df.mean(axis=1).astype(float).tolist()
    else:
        logger.fatal(f'No heat data found in {Path(data_path).stem}. Quitting.')
        quit()

    # Print summary of data file parsing
    _volumes = []
    for v in volumes:
        _v = f'{v:.2E}'
        if len(_volumes) == 0 or _v != _volumes[-1]:
            _volumes.append(_v)
    logger.info(f"      Injection volumes from column: '{volumes_col}': {_volumes}")
    if delays_col is not None: logger.info(f"      Injection delays from column: '{delays_col}': {delays}")
    else: logger.info(f"      No injection delay column found; using uniform delay of {inj_delay} seconds")
    if molar_ratio_col is not None: logger.info(f"      Molar ratios from column: '{molar_ratio_col}'")
    if include_col is not None: logger.info(f"      Inclusion flags from column: '{include_col}': {include}")
    
    logger.info(f"      Heat measurements from columns: {heat_cols}")

    logger.info(f"    Looking for metadata in file...")
    metadata = {}
    with open(data_path) as f:
        for line in f.readlines():
            if '# EXPINFO' in line:
                key = line.split(' ')[2]
                value = float(line.split(' ')[-1])
                metadata[key] = value
                logger.info(f'      Found {key} = {value}')

    logger.info("    File reading completed")
    return { 'volumes': volumes, 'delays': delays, 'heats': heats, 'include': include, 'molar_ratio': x, 'metadata': metadata }


def setup_odes(model, parameters):
    # Set up ODEs for each reaction in the cell in order to quantify flux and derive released heat
    logger.debug(f"Setting up ODEs for tracking of reaction flux")
    reactions_df = basico.get_reactions(model=model).reset_index()
    # Collect all dH_ keys
    enthalpies = [key[3:] for key in parameters.keys() if 'dH_' in key]

    logger.debug(f'  Tracked reactions: {enthalpies}')

    for _, row in reactions_df.iterrows():
        rname = row['name']
        if rname in enthalpies:
            ode_name = "ode_" + rname
            expression = f'({rname}).ParticleFlux'
            basico.add_parameter(model=model, name=ode_name, status='ode', expression=expression, initial_value=0)
            logger.debug(f'  -Adding ODE {ode_name}: {expression}')

def get_odes(model):
    odes = basico.get_parameters(model=model).reset_index()
    odes = odes[odes['name'].astype(str).str.contains('ode_')]

    return odes

def compute_heat_from_ode(odes,params) -> float:
    q = 0.0
    for _, orow in odes.iterrows():
        ode_name = str(orow['name'])
        dH_name = get_parameter_name(ode_name, 'dH')
        ode_value = float(orow['value'])  # particles
        ode_moles = ode_value / NA        # moles
        dH_value = float(params[dH_name]) # J/mol
        q += ode_moles * dH_value         # joules

    return q * 1000000

def simulate(
        model_path: Path,
        config: Dict,
        volumes: List[float],
        delays: List[float],
        param_values: Optional[Dict[str, float]]
    ) -> Tuple[List[float], List[float]]:

        model = basico.load_model(str(model_path))
        exp_name = config['name']
        model_info_cfg = config['experiment_info']

        logger.debug("Collecting parameters from config...")
        params = resolve_parameter_values(config.get('parameters', {}), param_values)
        setup_odes(model, params)

        cell = basico.get_compartments(model_info_cfg['cell_compartment_name'])
        cell["initial_volume"] = float(model_info_cfg['cell_volume'])

        logger.debug(f'Setting Cell ({model_info_cfg["cell_compartment_name"]}) volume = {float(model_info_cfg["cell_volume"])}')

        # Adjusted total cell start concentration
        M_cell = 0.0
        # Apply initial concentration overrides from MODEL_INFO if present
        cell_species_initial_conc_cfg = model_info_cfg.get('cell_species_initial_conc', {}) or {}
        syringe_species_initial_conc_cfg = model_info_cfg.get('syringe_species_initial_conc', {}) or {}
        for sname, sval in cell_species_initial_conc_cfg.items():
            n_value = params["N_" + sname + "_" + exp_name]
            M_cell += sval
            logger.debug(f"Setting cell initial concentration of species '{sname}' to {float(sval)} x {n_value} in model.")
            basico.set_species(model=model, name=sname, compartment=model_info_cfg.get('cell_compartment_name', 'cell'), initial_concentration=float(sval)*float(n_value))
        for sname, sval in syringe_species_initial_conc_cfg.items():
            logger.debug(f"Setting syringe initial concentration of species '{sname}' to {float(sval)} in model.")
            basico.set_species(model=model, name=sname, compartment=model_info_cfg.get('syringe_compartment_name', 'syringe'), initial_concentration=float(sval))

        # apply numeric parameters to model
        logger.debug("Applying parameters to model...")
        global_params_df = basico.get_parameters(model=model).reset_index()
        for pname, pval in params.items():
            if pname not in global_params_df['name'].values: continue # Do not set parameters not in model
            logger.debug(f" -Setting parameter '{pname}' to {pval} in model.")
            basico.set_parameters(model=model, name=pname, initial_value=float(pval), value=float(pval))

        # cell volume
        cell_volume = float(model_info_cfg['cell_volume'])
        logger.debug(f"Using cell volume: {cell_volume}")

        # build enthalpy mapping from parameters named dH_*
        logger.debug("Building enthalpy mapping from config -> reaction products...")
        enthalpy_map: Dict[str, float] = {}
        
        cell_compartment_name = model_info_cfg['cell_compartment_name']
        syringe_compartment_name = model_info_cfg['syringe_compartment_name']

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
                base, comp_in_name = split_species_compartment(prod_str, cell_compartment_name, [cell_compartment_name, syringe_compartment_name])
                effective_comp = comp_in_name if comp_in_name else cell_compartment_name
                key_with_comp = make_species_name(base, effective_comp)

                enthalpy_map[key_with_comp] = enthalpy_map.get(key_with_comp, 0.0) + dh_value
                enthalpy_map[base] = enthalpy_map.get(base, 0.0) + dh_value

                logger.debug(f"  Mapped dH '{dh_param}' ({dh_value}) -> product '{prod_str}' as '{key_with_comp}' and '{base}'")

        # run steady state equilibration
        logger.debug("Running steady state equilibration...")
        basico.run_steadystate(model=model)

        if logger.level == logging.DEBUG:
            # Print species concentrations after equilibration
            species_df = basico.get_species(model=model).reset_index()
            logger.debug("Species concentrations after equilibration:")
            for _, srow in species_df.iterrows():
                sname = srow.get('display_name')
                sconc = srow.get('concentration', 0.0)
                logger.debug(f"  {sname}: {sconc}")

        # Read post STEADY STATE equilibration syringe species concentrations from model
        # This for easier reference later during the injection simulations
        syringe_initials_cfg = get_species_concentration(model, compartment=syringe_compartment_name)
        total_syringe_conc = sum(syringe_initials_cfg.values())

        ################################
        ### Run titration simulation ###
        ################################

        logger.debug("Running titration simulation...")

        molar_ratio: List[float] = []
        M_inj = 0.0

        logger.debug(f"  Total cell species concentration: {get_species_concentration(model, cell_compartment_name)}")
        logger.debug(f"  Total syringe species concentration: {total_syringe_conc}")

        q_pre = 0.0

        heats: List[float] = []
        offset = float(params.get('Offset_' + exp_name, 0.0))
        i = 0
        for v_inj, d_inj in zip(volumes, delays):
            logger.debug(f" -Simulating injection #{i} of volume {v_inj:.1E} at delay {d_inj}...")
            i += 1
            # get pre-injection concentrations (only consider species in the cell compartment)
            conc_pre = get_species_concentration(model, compartment=cell_compartment_name)

            # PERFORM INJECTION
            # compute post-mix concentrations by simple dilution + syringe input
            for name, sconc in conc_pre.items():
                # try to find a syringe species with same base name
                conc_inj = 0.0
                # priority: explicit syringe species initial concs from config
                is_injected = False
                if name in syringe_initials_cfg:
                    conc_inj = float(syringe_initials_cfg[name])
                    is_injected = True

                # mixing with dilution adjustment
                new_val = (sconc * cell_volume + conc_inj * v_inj) / (cell_volume + v_inj)
                
                basico.set_species(model=model, name=make_species_name(name, cell_compartment_name if is_injected else None), initial_concentration=new_val)
 
            # Simulate for duration of injection delay
            basico.run_time_course(model=model, duration=d_inj, update_model=True)

            # Get ODE fluxes
            odes_post = get_odes(model)

            # Calculate 
            q_post = compute_heat_from_ode(odes_post, params)

            # compute heat released
            inj_mass = v_inj * total_syringe_conc
            delta_h = q_post - q_pre
            delta_h /= inj_mass
            delta_h += offset
            heats.append(delta_h)

            # Calculate molar ratio of injected protein species versus cell species
            M_inj  = (M_inj * cell_volume + inj_mass) / (cell_volume + v_inj)     
            M_cell = (M_cell * cell_volume) / (cell_volume + v_inj)
            x = M_inj / M_cell
            molar_ratio.append(x)

            q_pre = q_post

        if logger.level == logging.DEBUG:
            # Print injection heats
            logger.debug("Injection heats:")
            for idx, heat in enumerate(heats):
                logger.debug(f"  Injection #{idx}:\t{molar_ratio[idx]:.7g}\t{heat:.4g} J")

        return heats, molar_ratio


def _objective(param_dict: Dict, config: Dict, data: Dict, model_path: Path) -> float:
    #heats_sim, _ = simulate(model_path=model_path, config=config, volumes=data['volumes'], delays=data['delays'], param_values=param_dict)
    #diff = np.array(heats_sim) - np.array(data['heats'])
    #diff = diff * data['include']

    residuals = get_residuals(param_dict, config, data, model_path)

    rmsd = float(np.sqrt(np.mean(residuals**2)))
    return rmsd

def get_residuals(param_dict: Dict, config: Dict, data: Dict, model_path: Path) -> np.ndarray:
    heats_sim, _ = simulate(
        model_path=model_path,
        config=config,
        volumes=data['volumes'],
        delays=data['delays'],
        param_values=param_dict,
    )
    r = np.asarray(heats_sim, dtype=float) - np.asarray(data['heats'], dtype=float)
    include = np.asarray(data['include'], dtype=bool)
    return r[include]

def cov_from_jacobian_svd(J: np.ndarray, sse: float, dof: int, rcond: float = 1e-12):
    """
    Gauss-Newton covariance estimate using SVD truncation:
      Cov ≈ sigma2 * (J^T J)^-1
    where (J^T J)^-1 is built from SVD of J with small singular values truncated.

    Returns:
      cov, se, corr, diagnostics dict
    """
    m, n = J.shape
    dof = max(1, int(dof))
    sigma2 = float(sse) / float(dof)

    # SVD of J
    U, S, Vt = np.linalg.svd(J, full_matrices=False)
    s0 = S[0] if S.size else 0.0

    # keep singular values above threshold
    if s0 == 0.0:
        keep = np.zeros_like(S, dtype=bool)
    else:
        keep = S > (rcond * s0)

    eff_rank = int(np.sum(keep))

    inv_s2 = np.zeros_like(S, dtype=float)
    inv_s2[keep] = 1.0 / (S[keep] ** 2)

    # (J^T J)^-1 ≈ V diag(inv_s2) V^T
    # V is Vt.T
    V = Vt.T
    JTJ_inv = (V * inv_s2) @ V.T

    cov = sigma2 * JTJ_inv

    diag = np.diag(cov)
    se = np.sqrt(np.clip(diag, 0.0, np.inf))

    # correlation
    outer = np.outer(se, se)
    with np.errstate(divide="ignore", invalid="ignore"):
        corr = cov / outer
    corr[~np.isfinite(corr)] = np.nan

    # diagnostics
    cond = np.inf
    if eff_rank >= 2:
        cond = float(S[keep][0] / S[keep][-1]) if S[keep][-1] != 0 else np.inf

    diag_info = {
        "sigma2": sigma2,
        "rcond": float(rcond),
        "singular_values": S,
        "effective_rank": eff_rank,
        "condition_number_kept": cond,
    }

    logger.info("SVD info:")
    for key,value in diag_info.items():
        logger.info(f'  {key} = {value}')

    return cov, se, corr, diag_info


# ====================================================================================
# New Gauss–Newton error estimation utilities
#
# The following functions implement a robust parameter uncertainty estimation based on
# the Gauss–Newton approximation of the covariance matrix.  They leverage SciPy's
# numerical differentiation machinery when available to compute the Jacobian of the
# residual vector at the optimum.  When SciPy is not available, a finite
# difference fallback is provided.

def _residuals_concat(
    x_fit: np.ndarray,
    fit_names: List[str],
    fix_dict: Dict[str, float],
    experiments_config: List[Dict],
    exp_data: List[Dict],
    log_flags: Dict[str, bool],
) -> np.ndarray:
    """Concatenate residuals across all experiments for a given parameter vector."""
    # Convert the vector of fitted parameters into a dictionary of actual
    # parameter values, applying the exponential for log-scaled parameters.
    param_dict = _vector_to_param_dict(x_fit, fit_names, log_flags)
    # Merge with fixed parameter values
    param_dict.update(fix_dict)

    residuals_all: List[np.ndarray] = []
    for exp_idx, exp in enumerate(experiments_config):
        # Retrieve the model path and experimental data for this experiment
        model_path = exp['model_path']
        data = exp_data[exp_idx]
        # Compute residuals (simulated minus experimental) for included points
        r = get_residuals(param_dict, exp, data, model_path)
        residuals_all.append(r)

    if not residuals_all:
        # No experiments provided; return an empty array to avoid errors.
        return np.asarray([], dtype=float)
    # Concatenate along the first dimension to get a single vector of residuals.
    return np.concatenate(residuals_all)


def _compute_jacobian(
    residuals_func,
    x0: np.ndarray,
    bounds: Optional[List[Tuple[float, float]]] = None,
) -> Tuple[np.ndarray, np.ndarray]:
    """Compute the Jacobian of a residual function using numerical differentiation."""
    x0 = np.asarray(x0, dtype=float)
    # Build a small caching wrapper around the residuals function.  SciPy's
    # approx_derivative will call the function multiple times at nearby points;
    # memoising these evaluations avoids redundant and expensive simulations.
    cache: Dict[Tuple[float, ...], np.ndarray] = {}

    def f_cached(x: np.ndarray) -> np.ndarray:
        # Use a tuple of floats as the cache key; convert to float to avoid
        # comparisons of numpy scalars which can be slow.
        key = tuple(float(v) for v in x)
        if key in cache:
            return cache[key]
        val = np.asarray(residuals_func(x), dtype=float)
        cache[key] = val
        return val

    # Evaluate residuals at x0 to obtain the base value and ensure caching.
    r0 = f_cached(x0)

    # Use the two-point rule for efficiency.  The default relative
    # stepping scheme inside SciPy picks a step size based on the
    # machine precision and the scale of each variable.  We also pass
    # the precomputed residual value via f0 to avoid an extra function
    # call.
    J = _approx_derivative(
        f_cached,
        x0,
        method='3-point',
        f0=r0,
    )

    return J, r0


def fit_model(config_path: Path, output_dir: Path) -> None:
    # Load configuration
    with open(config_path, 'r') as f:
        config = yaml.safe_load(f)
        config = check_and_repair_config(config)

    print()
    logger.info(f'Starting fitting routine...')

    experiments_config = config['experiments']
    exp_names = [str(exp.get('name', '')) for exp in experiments_config]
    num_exps = len(experiments_config)

    ##############################
    ### Load experimental data ###
    ##############################

    exp_data: List[Tuple[List[float], List[float], List[float], List[int], List[float]]] = []
    logger.info(f'Loading {num_exps} experiments...')
    for exp in experiments_config:
        # Parse data to obtain injection volumes, times, and experimental heats
        # Use the default 150s injection delay when no explicit delay column exists
        data_file = exp.get('data_path', "")
        default_delay = float(exp.get('fallbak_inj_delay', 150))
        logger.info(f'  Experiment {exp["name"]}')
        logger.info(f'    Model: {exp["model_path"]}')
        logger.info(f'    Data:  {data_file}')
        logger.info(f'    Default delay: {default_delay}')
        if not data_file or not Path(data_file).exists():
            raise RuntimeError(f"Data file not specified or not found for experiment '{exp.get('name')}'.")
        data = parse_data(Path(data_file), default_delay)

        metadata = data.get('metadata') or {}
        if metadata:
            exp_info = exp.get('experiment_info', {})
            cell_species_initial_conc = exp_info.get('cell_species_initial_conc', {}) or {}
            syringe_species_initial_conc = exp_info.get('syringe_species_initial_conc', {}) or {}
            for key, value in metadata.items():
                key_upper = str(key).strip().upper()
                if key_upper == 'CELLCONC':
                    for sname in cell_species_initial_conc.keys(): cell_species_initial_conc[sname] = float(value)
                elif key_upper == 'SYRINGECONC':
                    for sname in syringe_species_initial_conc.keys(): syringe_species_initial_conc[sname] = float(value)
                elif key_upper == 'CELLVOLUME':
                    exp_info['cell_volume'] = float(value)

            exp_info['cell_species_initial_conc'] = cell_species_initial_conc
            exp_info['syringe_species_initial_conc'] = syringe_species_initial_conc
            exp['experiment_info'] = exp_info

        exp_data.append(data)
    
    ###################################################
    ### Construct parameter vector for fitting      ###
    ### Identify parameters to fit and their bounds ###
    ###################################################
    logger.info(f'Setting up parameter vector...')
    fit_names: List[str] = []
    fit_bounds: List[Tuple[float, float]] = []
    param_init: Dict[str, float] = {}
    fix_dict: Dict[str, float] = {}
    log_flags: Dict[str, bool] = {}
    alias_params: set = set()
    all_param_names = set()
    for exp in experiments_config:
        all_param_names.update(exp.get('parameters', {}).keys())

    for exp in experiments_config:
        for pname, info in exp.get('parameters', {}).items():
            if pname in fit_names or pname in fix_dict or pname in alias_params:
                continue

            raw = _extract_param_value(info)
            value, alias = _parse_param_value(raw, pname)
            if alias is not None:
                if alias not in all_param_names:
                    raise ValueError(f"Parameter '{pname}' aliases '{alias}', which is not defined in config.")
                alias_params.add(pname)
                logger.info(f'  Linking parameter {pname} -> {alias}')
                continue

            info_dict = info if isinstance(info, dict) else {'value': value}
            if isinstance(info, dict) and 'fit' in info and not info['fit']:
                fix_dict[pname] = float(value)
                continue

            fit_names.append(pname)
            log_flag = _param_uses_log_scale(pname, info_dict, exp_names)
            log_flags[pname] = log_flag
            pmin = info_dict.get('min', -np.inf)
            pmax = info_dict.get('max', np.inf)
            if log_flag:
                if float(value) <= 0:
                    raise ValueError(f"Log-scaled parameter '{pname}' requires a positive initial value, got {value}.")
                if np.isfinite(pmin) and float(pmin) <= 0:
                    raise ValueError(f"Log-scaled parameter '{pname}' requires a positive minimum bound, got {pmin}.")
                if np.isfinite(pmax) and float(pmax) <= 0:
                    raise ValueError(f"Log-scaled parameter '{pname}' requires a positive maximum bound, got {pmax}.")
                pmin_log = float(np.log(pmin)) if np.isfinite(pmin) else -np.inf
                pmax_log = float(np.log(pmax)) if np.isfinite(pmax) else np.inf
                fit_bounds.append((pmin_log, pmax_log))
                param_init[pname] = float(np.log(value))
            else:
                fit_bounds.append((float(pmin), float(pmax)))
                param_init[pname] = float(value)
            logger.info(f'  Adding parameter {pname} = {value} | log={log_flag}')

    x0 = np.array([param_init[name] for name in fit_names], dtype=float)
    
    print() # Blank line for readability 
    
    ##################################
    ### Objective function wrapper ###
    ##################################
    iter = 0
    def obj_wrapper(x: np.ndarray) -> float:
        nonlocal iter

        rmsd = 0.0

        param_dict = _vector_to_param_dict(x, fit_names, log_flags)
        param_dict.update(fix_dict)

        if logger.level == logging.DEBUG:
            for key,val in param_dict.items():
                logger.debug(f'  {key} = {val:.2e}')

        for exp_idx, exp in enumerate(experiments_config):
            model_path = exp['model_path']
            data = exp_data[exp_idx]

            rmsd += _objective(param_dict, exp, data, model_path)
        
        iter += 1
        logger.info(f"Iteration {iter}: \tRMSD = {rmsd:.20g}")
        
        return rmsd

    ################################
    ### Run optimisation         ###
    ################################
    logger.info(f"Starting optimisation of {len(fit_names)} parameters across {num_exps} experiments...")

    result = minimize(
        obj_wrapper,
        x0,
        method='Nelder-Mead',
        bounds=fit_bounds,
        options={'maxiter': int(config['fitting']['max_iterations'])},
    )

    logger.info(f"Optimisation completed. Success={result.success}, message={result.message}")

    #################################
    ### Process and write results ###
    #################################

    # Collect fitted parameters in dictionary
    fitted_values = _vector_to_param_dict(np.asarray(result.x, dtype=float), fit_names, log_flags)
    fitted_values.update(fix_dict)
    for exp in experiments_config:
        for pname, info in exp.get('parameters', {}).items():
            if pname in alias_params:
                continue
            if pname in fitted_values:
                if isinstance(info, dict):
                    info['value'] = fitted_values[pname]
                    exp['parameters'][pname] = info
                else:
                    exp['parameters'][pname] = fitted_values[pname]

    logger.info("Result parameters:")
    for key,value in fitted_values.items():
        logger.info(f'  {key}\t = {value:.2e}')

    # Estimate parameter covariance using a Gauss-Newton approximation (Jacobian of residuals).
    # This does *not* re-run a full optimisation; it performs only a limited number
    # of extra objective evaluations near the optimum.
    error_info = None
    if config['fitting']['estimate_errors']:
        # Run uncertainty estimation only if the optimiser succeeded and at least one parameter was fitted.
        if result.success and len(fit_names) > 0:
            error_info = estimate_errors(
                result,
                fit_names,
                fix_dict,
                config,
                exp_data,
                log_flags,
                fit_bounds,
            )
            error_info = _transform_error_info_to_param_scale(error_info, fit_names, log_flags)
        else:
            error_info = None

    write_results(result, fit_names, fix_dict, config, exp_data, error_info, output_dir, log_flags)
    
def estimate_errors(
    result,
    fit_names: List[str],
    fix_dict: Dict[str, float],
    config: Dict,
    exp_data: List[Dict],
    log_flags: Dict[str, bool],
    fit_bounds: Optional[List[Tuple[float, float]]] = None,
) -> Optional[Dict[str, object]]:
    """Estimate parameter uncertainties via a Gauss-Newton + SVD pipeline."""
    experiments_config = config['experiments']
    error_info: Optional[Dict[str, object]] = None
    try:
        npar = len(fit_names)
        if npar > 0:
            # Define a residual function that concatenates residuals across all experiments.
            def _residuals(x: np.ndarray) -> np.ndarray:
                return _residuals_concat(x, fit_names, fix_dict, experiments_config, exp_data, log_flags)

            logger.info("Estimating parameter covariance (Gauss-Newton + SVD)...")

            # Compute Jacobian and residual vector at the optimum.
            x_opt = np.asarray(result.x, dtype=float)

            J, r0 = _compute_jacobian(
                _residuals,
                x_opt,
                bounds=fit_bounds,
            )

            # Number of observations and degrees of freedom
            nobs = int(r0.size)
            sse = float(np.dot(r0, r0))
            dof = int(max(1, nobs - npar))
            sigma2 = float(sse / dof)

            # Determine default truncation threshold for singular values.  Use
            # max(J.shape) * machine epsilon as suggested for numerical stability,
            # but do not go below 1e-12 to avoid overly tiny cut-offs on small
            # problems.
            if J.size == 0:
                # No residuals; skip covariance estimation
                raise ValueError("Jacobian is empty; cannot estimate covariance.")
            rcond_default = max(J.shape) * np.finfo(float).eps
            if rcond_default < 1e-12:
                rcond_default = 1e-12

            # Perform SVD-based covariance estimation.  Use the same function
            # previously defined in this module.  It returns covariance, standard
            # errors, correlation matrix and a diagnostics dictionary.
            cov, se, corr, svd_info = cov_from_jacobian_svd(
                J,
                sse=sse,
                dof=dof,
                rcond=rcond_default,
            )

            # Determine the multiplier for 95% confidence intervals using the
            # Student-t distribution when available; otherwise fall back to
            # approximately 1.96 (Z-score).
            if _student_t is not None:
                try:
                    ci_mult = float(_student_t.ppf(0.975, dof))
                except Exception:
                    ci_mult = 1.959963984540054
            else:
                ci_mult = 1.959963984540054

            # Assemble the output dictionary
            error_info = {
                'method': 'gauss-newton (jacobian) + svd',
                'cov': cov,
                'se': se,
                'corr': corr,
                'sse': sse,
                'sigma2': sigma2,
                'dof': dof,
                'ci_mult_95': ci_mult,
                'nobs': nobs,
                'npar': npar,
                'singular_values': svd_info.get('singular_values'),
                'effective_rank': svd_info.get('effective_rank'),
                'condition_number_kept': svd_info.get('condition_number_kept'),
            }

            # Attach names and point estimates for reporting
            error_info['fit_names'] = list(fit_names)
            error_info['x_opt'] = x_opt

            # Convenience dicts: standard errors by name and 95% confidence intervals
            se_arr = np.asarray(se, dtype=float)
            error_info['se_by_name'] = {n: float(se_arr[i]) for i, n in enumerate(fit_names)}
            ci_dict: Dict[str, Tuple[float, float]] = {}
            for i, n in enumerate(fit_names):
                val = float(x_opt[i])
                se_i = float(se_arr[i]) if i < se_arr.size else float('nan')
                lo = val - ci_mult * se_i
                hi = val + ci_mult * se_i
                ci_dict[n] = (lo, hi)
            error_info['ci95_by_name'] = ci_dict
    except Exception as e:
        # Catch any error during covariance estimation and log a warning.
        logger.warning(f"Parameter covariance estimation failed: {e}")

    return error_info

def write_results(result, fit_names, fix_dict, config, exp_data, error_info, output_dir, log_flags):
    import matplotlib
    matplotlib.use('Agg')  # use non-interactive backend
    import matplotlib.pyplot as plt
    experiments_config = config['experiments']
    fitted = _vector_to_param_dict(np.asarray(result.x, dtype=float), fit_names, log_flags)
    param_dict = dict(fitted)
    param_dict.update(fix_dict)

    # Prepare output directory
    output_dir.mkdir(parents=True, exist_ok=True)
    report_path = output_dir / 'results_report.txt'
    fit_config_path = output_dir / 'run_config.yaml'
    with open(fit_config_path, 'w') as cfgf:
        yaml.dump(config, cfgf, sort_keys=False)

    # Optional covariance/correlation outputs
    cov_path = output_dir / 'covariance_matrix.tsv'
    corr_path = output_dir / 'correlation_matrix.tsv'
    corr_plot_path = output_dir / 'correlation_matrix.png'

    with open(report_path, 'w') as rep:
        rep.write("Fitted parameters:\n")
        for name, val in fitted.items():
            rep.write(f"  {name}: {val}\n")

        rep.write("Fixed parameters:\n")
        for name, val in fix_dict.items():
            rep.write(f"  {name}: {val}\n")

        if error_info is not None and 'fit_names' in error_info and 'cov' in error_info and 'se' in error_info:
            fit_names = list(error_info['fit_names'])
            se = np.asarray(error_info['se'], dtype=float)
            ci95_by_name = error_info.get('ci95_by_name', {})
            rep.write(f"\nUncertainty estimates (local, {error_info['method']}):\n")
            rep.write(f"  nobs: {error_info.get('nobs')}\n")
            rep.write(f"  npar: {error_info.get('npar')}\n")
            rep.write(f"  dof: {error_info.get('dof')}\n")
            sse_val = error_info.get('sse')
            sigma2_val = error_info.get('sigma2')
            rep.write("  SSE (included points): " + (f"{float(sse_val):.6g}" if sse_val is not None else "NA") + "\n")
            rep.write("  sigma^2: " + (f"{float(sigma2_val):.6g}" if sigma2_val is not None else "NA") + "\n")
            # Report SVD diagnostics if available
            sv = error_info.get('singular_values')
            if sv is not None:
                rep.write("  singular values: " + ", ".join(f"{float(s):.6g}" for s in sv) + "\n")
            eff_rank = error_info.get('effective_rank')
            if eff_rank is not None:
                rep.write(f"  effective_rank: {eff_rank}\n")
            cond_num = error_info.get('condition_number_kept')
            if cond_num is not None:
                rep.write(f"  condition_number_kept: {cond_num}\n")
            rep.write("\nParameter\tValue\tStdErr\tCI95_low\tCI95_high\n")
            for i, n in enumerate(fit_names):
                v = float(param_dict[n])
                se_i = float(se[i]) if i < se.size else float('nan')
                if isinstance(ci95_by_name, dict) and n in ci95_by_name:
                    lo, hi = ci95_by_name[n]
                else:
                    mult = float(error_info.get('ci_mult_95', 1.959963984540054))
                    lo, hi = v - mult * se_i, v + mult * se_i
                rep.write(f"{n}\t{v:.10g}\t{se_i:.6g}\t{lo:.10g}\t{hi:.10g}\n")

            # Write covariance / correlation matrices to separate TSV files (easier to consume).
            cov = np.asarray(error_info['cov'], dtype=float)
            corr = np.asarray(error_info.get('corr', np.full_like(cov, np.nan)), dtype=float)

            def _write_matrix(path: Path, header: List[str], mat: np.ndarray) -> None:
                with open(path, 'w') as fh:
                    fh.write("\t" + "\t".join(header) + "\n")
                    for i, row_name in enumerate(header):
                        row = mat[i, :]
                        fh.write(row_name + "\t" + "\t".join(f"{x:.10g}" for x in row) + "\n")

            _write_matrix(cov_path, fit_names, cov)
            _write_matrix(corr_path, fit_names, corr)
            plot_correlation_matrix(corr, fit_names, corr_plot_path)

            rep.write("\nCovariance matrix written to: " + str(cov_path) + "\n")
            rep.write("Correlation matrix written to: " + str(corr_path) + "\n")
            rep.write("Correlation matrix plot written to: " + str(corr_plot_path) + "\n")

        rep.write("\nExperiment RMSDs:\n")

        for exp_idx, exp in enumerate(experiments_config):
            exp_name = exp['name']
            model_path = exp['model_path']
            plot_path = output_dir / f'results_plot_{exp_name}.pdf'
            data = exp_data[exp_idx]

            logger.info(f'Writing output for {exp_name}...')

            # Generate final simulation data with best-fit parameters
            heats_sim, ratios = simulate(
                model_path=model_path, 
                config=exp, 
                volumes=data['volumes'], 
                delays=data['delays'], 
                param_values=param_dict)
            
            # Get experiment RMSD
            rmsd = _objective(param_dict, exp, data, model_path)

            rep.write(f"  {exp_name}: {rmsd}\n")

            plt.figure()
            plt.plot(ratios, heats_sim, label='Simulated', marker="o")

            # Plot experimental heats using filled squares for included points and hollow squares for excluded points
            include = data['include']
            x = data['molar_ratio']
            heats_exp = data['heats']
            included_ratios = [r for r, inc in zip(x, include) if inc]
            included_heats = [h for h, inc in zip(heats_exp, include) if inc]
            excluded_ratios = [r for r, inc in zip(x, include) if not inc]
            excluded_heats = [h for h, inc in zip(heats_exp, include) if not inc]
            plt.plot(included_ratios, included_heats, linestyle='None', marker='s', markersize=8, label='Experimental', color='black')
            if excluded_ratios:
                plt.plot(excluded_ratios, excluded_heats, linestyle='None', marker='s', markersize=8, fillstyle='none', color='black')
            plt.xlabel('Molar ratio (titrant/macromolecule)')
            plt.ylabel('Heat per mole injected (J/mol)')
            plt.title('ITC Isotherm: simulation vs experiment')
            plt.legend()
            plt.savefig(plot_path, dpi=300)
            plt.close()

    logger.info(f"Report written to {report_path}")
    logger.info(f"Updated configuration written to {fit_config_path}")
    logger.info(f"Plot saved to {output_dir / 'results_plot.png'}")

def plot_correlation_matrix(corr: np.ndarray, names: List[str], output_path: Path) -> None:
    import matplotlib.pyplot as plt

    fig, ax = plt.subplots(figsize=(max(6, 0.35 * len(names)), max(5, 0.35 * len(names))))
    im = ax.imshow(corr, vmin=-1.0, vmax=1.0, cmap='coolwarm')
    ax.set_xticks(range(len(names)))
    ax.set_yticks(range(len(names)))
    ax.set_xticklabels(names, rotation=45, ha='right',  fontsize=8)
    ax.set_yticklabels(names, fontsize=8)
    for i in range(len(names)):
        for j in range(len(names)):
            text = ax.text(j,i,f'{corr[i,j]:.2f}', ha="center", va="center")

    ax.set_title('Parameter Correlation Matrix')
    fig.colorbar(im, ax=ax, fraction=0.046, pad=0.04, label='Correlation')
    fig.tight_layout()
    fig.savefig(output_path, dpi=300)
    plt.close(fig)

def main() -> None:
    logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

    parser = argparse.ArgumentParser(description="ITC simulation and fitting using COPASI models.")
    
    subparsers = parser.add_subparsers(dest='command', required=True)

    # Subparser for build_config
    parser_build = subparsers.add_parser('build_config', help='Generate a YAML configuration from one or more COPASI models')
    parser_build.add_argument('--model', type=Path, nargs='+', action='append', required=True, help='Path to a COPASI model (.cps). Can be used multiple times for multiple experiments.')
    parser_build.add_argument('--data', type=Path, nargs='+', action='append', required=False, help='Path to an experimental data CSV file corresponding to each model (optional, repeat for multiple models in order)')
    parser_build.add_argument('--output', type=Path, default=None, help='Path to write the generated YAML configuration (default: config_<model>.yaml)')

    # Subparser for fit
    parser_fit = subparsers.add_parser('fit', help='Fit model parameters to experimental data')
    parser_fit.add_argument('--config', type=Path, required=True, help='YAML configuration file produced by build_config')
    parser_fit.add_argument('--output', type=Path, required=False, default=None, help='Directory where results will be written (default: results_<config_name>)')

    parser.add_argument('--verbose', '-v', action='store_true', help='Enable verbose logging output')

    args = parser.parse_args()
    if args.verbose:
        logging.basicConfig(level=logging.DEBUG, format='%(levelname)s: %(message)s')
        logger.setLevel(logging.DEBUG)

    if args.command == 'build_config':
        models_list: List[Path] = args.model[0]
        data_list: List[Path] = args.data[0] if args.data is not None else None
        out = args.output if args.output is not None else Path(f"config_{models_list[0].stem}.yaml")
        build_config(models_list, data_list, out)
    elif args.command == 'fit':
        base_results = Path('results')
        if args.output is None:
            cfg_stem = Path(args.config).stem
            if cfg_stem.startswith('config_'):
                cfg_stem = cfg_stem[len('config_'):]
            subfolder = f"results_{cfg_stem}"
        else:
            # Use the provided output's name as the subfolder
            subfolder = Path(args.output).name
        out_dir = base_results / subfolder
        fit_model(args.config, out_dir)


if __name__ == '__main__':
    main()
