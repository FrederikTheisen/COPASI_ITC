<?xml version="1.0" encoding="UTF-8"?>
<!-- generated with COPASI 4.39 (Build 272) (http://www.copasi.org) at 2024-07-24T10:20:28Z -->
<?oxygen RNGSchema="http://www.copasi.org/static/schema/CopasiML.rng" type="xml"?>
<COPASI xmlns="http://www.copasi.org/static/schema" versionMajor="4" versionMinor="39" versionDevel="272" copasiSourcesModified="0">
  <ListOfFunctions>
    <Function key="Function_14" name="Mass action (reversible)" type="MassAction" reversible="true">
      <MiriamAnnotation>
<rdf:RDF xmlns:CopasiMT="http://www.copasi.org/RDF/MiriamTerms#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
   <rdf:Description rdf:about="#Function_14">
   <CopasiMT:is rdf:resource="urn:miriam:obo.sbo:SBO:0000042" />
   </rdf:Description>
   </rdf:RDF>
      </MiriamAnnotation>
      <Comment>
        <body xmlns="http://www.w3.org/1999/xhtml">
<b>Mass action rate law for reversible reactions</b>
<p>
Reaction scheme where the products are created from the reactants and the change of a product quantity is proportional to the product of reactant activities. The reaction scheme does include a reverse process that creates the reactants from the products.
</p>
</body>
      </Comment>
      <Expression>
        k1*PRODUCT&lt;substrate_i>-k2*PRODUCT&lt;product_j>
      </Expression>
      <ListOfParameterDescriptions>
        <ParameterDescription key="FunctionParameter_69" name="k1" order="0" role="constant"/>
        <ParameterDescription key="FunctionParameter_68" name="substrate" order="1" role="substrate"/>
        <ParameterDescription key="FunctionParameter_78" name="k2" order="2" role="constant"/>
        <ParameterDescription key="FunctionParameter_79" name="product" order="3" role="product"/>
      </ListOfParameterDescriptions>
    </Function>
  </ListOfFunctions>
  <Model key="Model_1" name="New Model" simulationType="time" timeUnit="s" volumeUnit="l" areaUnit="m²" lengthUnit="m" quantityUnit="µmol" type="deterministic" avogadroConstant="6.0221407599999999e+23">
    <MiriamAnnotation>
<rdf:RDF
   xmlns:dcterms="http://purl.org/dc/terms/"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:Description rdf:about="#Model_1">
    <dcterms:created>
      <rdf:Description>
        <dcterms:W3CDTF>2023-08-10T14:00:17Z</dcterms:W3CDTF>
      </rdf:Description>
    </dcterms:created>
  </rdf:Description>
</rdf:RDF>

    </MiriamAnnotation>
    <ListOfCompartments>
      <Compartment key="Compartment_0" name="cell" simulationType="fixed" dimensionality="3" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Compartment_0">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
      </Compartment>
      <Compartment key="Compartment_1" name="syringe" simulationType="fixed" dimensionality="3" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Compartment_1">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
      </Compartment>
    </ListOfCompartments>
    <ListOfMetabolites>
      <Metabolite key="Metabolite_0" name="14_3_3_PRLR_cis" simulationType="reactions" compartment="Compartment_0" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Metabolite_0">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
      </Metabolite>
      <Metabolite key="Metabolite_1" name="14_3_3" simulationType="reactions" compartment="Compartment_0" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Metabolite_1">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
      </Metabolite>
      <Metabolite key="Metabolite_2" name="PRLR_cis" simulationType="reactions" compartment="Compartment_0" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Metabolite_2">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
      </Metabolite>
      <Metabolite key="Metabolite_3" name="14_3_3_PRLR_trans" simulationType="reactions" compartment="Compartment_0" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Metabolite_3">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
      </Metabolite>
      <Metabolite key="Metabolite_4" name="PRLR_cis" simulationType="reactions" compartment="Compartment_1" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Metabolite_4">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
      </Metabolite>
      <Metabolite key="Metabolite_5" name="14_3_3" simulationType="fixed" compartment="Compartment_1" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Metabolite_5">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
      </Metabolite>
      <Metabolite key="Metabolite_6" name="PRLR_trans" simulationType="reactions" compartment="Compartment_0" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Metabolite_6">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
      </Metabolite>
      <Metabolite key="Metabolite_7" name="PRLR_trans" simulationType="reactions" compartment="Compartment_1" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Metabolite_7">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
      </Metabolite>
    </ListOfMetabolites>
    <ListOfModelValues>
      <ModelValue key="ModelValue_0" name="Kd_trans" simulationType="fixed" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#ModelValue_0">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <Unit>
          umol/l
        </Unit>
      </ModelValue>
      <ModelValue key="ModelValue_1" name="Kd_cis" simulationType="fixed" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#ModelValue_1">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <Unit>
          umol/l
        </Unit>
      </ModelValue>
      <ModelValue key="ModelValue_2" name="k_on_cis" simulationType="assignment" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#ModelValue_2">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <Expression>
          &lt;CN=Root,Model=New Model,Vector=Values[k_off_cis],Reference=InitialValue>/&lt;CN=Root,Model=New Model,Vector=Values[Kd_cis],Reference=InitialValue>
        </Expression>
        <Unit>
          l/(umol*s)
        </Unit>
      </ModelValue>
      <ModelValue key="ModelValue_3" name="k_off_cis" simulationType="fixed" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#ModelValue_3">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <Unit>
          1/s
        </Unit>
      </ModelValue>
      <ModelValue key="ModelValue_4" name="k_on_trans" simulationType="assignment" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#ModelValue_4">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <Expression>
          &lt;CN=Root,Model=New Model,Vector=Values[k_off_trans],Reference=InitialValue>/&lt;CN=Root,Model=New Model,Vector=Values[Kd_trans],Reference=InitialValue>
        </Expression>
        <Unit>
          l/(umol*s)
        </Unit>
      </ModelValue>
      <ModelValue key="ModelValue_5" name="k_off_trans" simulationType="fixed" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#ModelValue_5">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <Unit>
          1/s
        </Unit>
      </ModelValue>
      <ModelValue key="ModelValue_6" name="V_inj" simulationType="fixed" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#ModelValue_6">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <Unit>
          l
        </Unit>
      </ModelValue>
      <ModelValue key="ModelValue_7" name="T_offset" simulationType="fixed" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#ModelValue_7">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <Unit>
          s
        </Unit>
      </ModelValue>
      <ModelValue key="ModelValue_8" name="k_cis_trans" simulationType="fixed" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#ModelValue_8">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <Unit>
          1/s
        </Unit>
      </ModelValue>
      <ModelValue key="ModelValue_9" name="k_trans_cis" simulationType="assignment" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#ModelValue_9">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <Expression>
          &lt;CN=Root,Model=New Model,Vector=Values[K_cis_trans],Reference=InitialValue>*&lt;CN=Root,Model=New Model,Vector=Values[k_cis_trans],Reference=InitialValue>
        </Expression>
        <Unit>
          1/s
        </Unit>
      </ModelValue>
      <ModelValue key="ModelValue_10" name="N" simulationType="fixed" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#ModelValue_10">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
      </ModelValue>
      <ModelValue key="ModelValue_11" name="K_cis_trans" simulationType="fixed" addNoise="false">
      </ModelValue>
      <ModelValue key="ModelValue_12" name="K_re" simulationType="assignment" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#ModelValue_12">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <Expression>
          &lt;CN=Root,Model=New Model,Vector=Values[K_cis_trans],Reference=Value>*&lt;CN=Root,Model=New Model,Vector=Values[Kd_trans],Reference=Value>/&lt;CN=Root,Model=New Model,Vector=Values[Kd_cis],Reference=Value>
        </Expression>
      </ModelValue>
      <ModelValue key="ModelValue_13" name="k_re_cis_trans" simulationType="fixed" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#ModelValue_13">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
      </ModelValue>
      <ModelValue key="ModelValue_14" name="k_re_trans_cis" simulationType="assignment" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#ModelValue_14">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <Expression>
          &lt;CN=Root,Model=New Model,Vector=Values[k_re_cis_trans],Reference=Value>*&lt;CN=Root,Model=New Model,Vector=Values[K_re],Reference=Value>
        </Expression>
      </ModelValue>
      <ModelValue key="ModelValue_15" name="V_inj_actual" simulationType="fixed" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#ModelValue_15">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <Unit>
          l
        </Unit>
      </ModelValue>
    </ListOfModelValues>
    <ListOfReactions>
      <Reaction key="Reaction_0" name="cis_binding" reversible="true" fast="false" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Reaction_0">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <ListOfSubstrates>
          <Substrate metabolite="Metabolite_1" stoichiometry="1"/>
          <Substrate metabolite="Metabolite_2" stoichiometry="1"/>
        </ListOfSubstrates>
        <ListOfProducts>
          <Product metabolite="Metabolite_0" stoichiometry="1"/>
        </ListOfProducts>
        <ListOfConstants>
          <Constant key="Parameter_5506" name="k1" value="10"/>
          <Constant key="Parameter_5509" name="k2" value="2"/>
        </ListOfConstants>
        <KineticLaw function="Function_14" unitType="Default" scalingCompartment="CN=Root,Model=New Model,Vector=Compartments[cell]">
          <ListOfCallParameters>
            <CallParameter functionParameter="FunctionParameter_69">
              <SourceParameter reference="ModelValue_2"/>
            </CallParameter>
            <CallParameter functionParameter="FunctionParameter_68">
              <SourceParameter reference="Metabolite_1"/>
              <SourceParameter reference="Metabolite_2"/>
            </CallParameter>
            <CallParameter functionParameter="FunctionParameter_78">
              <SourceParameter reference="ModelValue_3"/>
            </CallParameter>
            <CallParameter functionParameter="FunctionParameter_79">
              <SourceParameter reference="Metabolite_0"/>
            </CallParameter>
          </ListOfCallParameters>
        </KineticLaw>
      </Reaction>
      <Reaction key="Reaction_1" name="trans_binding" reversible="true" fast="false" addNoise="false">
        <ListOfSubstrates>
          <Substrate metabolite="Metabolite_1" stoichiometry="1"/>
          <Substrate metabolite="Metabolite_6" stoichiometry="1"/>
        </ListOfSubstrates>
        <ListOfProducts>
          <Product metabolite="Metabolite_3" stoichiometry="1"/>
        </ListOfProducts>
        <ListOfConstants>
          <Constant key="Parameter_4675" name="k1" value="0.5"/>
          <Constant key="Parameter_4676" name="k2" value="2"/>
        </ListOfConstants>
        <KineticLaw function="Function_14" unitType="Default" scalingCompartment="CN=Root,Model=New Model,Vector=Compartments[cell]">
          <ListOfCallParameters>
            <CallParameter functionParameter="FunctionParameter_69">
              <SourceParameter reference="ModelValue_4"/>
            </CallParameter>
            <CallParameter functionParameter="FunctionParameter_68">
              <SourceParameter reference="Metabolite_1"/>
              <SourceParameter reference="Metabolite_6"/>
            </CallParameter>
            <CallParameter functionParameter="FunctionParameter_78">
              <SourceParameter reference="ModelValue_5"/>
            </CallParameter>
            <CallParameter functionParameter="FunctionParameter_79">
              <SourceParameter reference="Metabolite_3"/>
            </CallParameter>
          </ListOfCallParameters>
        </KineticLaw>
      </Reaction>
      <Reaction key="Reaction_2" name="iso_cell" reversible="true" fast="false" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Reaction_2">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <ListOfSubstrates>
          <Substrate metabolite="Metabolite_2" stoichiometry="1"/>
        </ListOfSubstrates>
        <ListOfProducts>
          <Product metabolite="Metabolite_6" stoichiometry="1"/>
        </ListOfProducts>
        <ListOfConstants>
          <Constant key="Parameter_4678" name="k1" value="0.004"/>
          <Constant key="Parameter_4674" name="k2" value="0.002448"/>
        </ListOfConstants>
        <KineticLaw function="Function_14" unitType="Default" scalingCompartment="CN=Root,Model=New Model,Vector=Compartments[cell]">
          <ListOfCallParameters>
            <CallParameter functionParameter="FunctionParameter_69">
              <SourceParameter reference="ModelValue_8"/>
            </CallParameter>
            <CallParameter functionParameter="FunctionParameter_68">
              <SourceParameter reference="Metabolite_2"/>
            </CallParameter>
            <CallParameter functionParameter="FunctionParameter_78">
              <SourceParameter reference="ModelValue_9"/>
            </CallParameter>
            <CallParameter functionParameter="FunctionParameter_79">
              <SourceParameter reference="Metabolite_6"/>
            </CallParameter>
          </ListOfCallParameters>
        </KineticLaw>
      </Reaction>
      <Reaction key="Reaction_3" name="iso_syringe" reversible="true" fast="false" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Reaction_3">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <ListOfSubstrates>
          <Substrate metabolite="Metabolite_4" stoichiometry="1"/>
        </ListOfSubstrates>
        <ListOfProducts>
          <Product metabolite="Metabolite_7" stoichiometry="1"/>
        </ListOfProducts>
        <ListOfConstants>
          <Constant key="Parameter_4679" name="k1" value="0.004"/>
          <Constant key="Parameter_4677" name="k2" value="0.002448"/>
        </ListOfConstants>
        <KineticLaw function="Function_14" unitType="Default" scalingCompartment="CN=Root,Model=New Model,Vector=Compartments[syringe]">
          <ListOfCallParameters>
            <CallParameter functionParameter="FunctionParameter_69">
              <SourceParameter reference="ModelValue_8"/>
            </CallParameter>
            <CallParameter functionParameter="FunctionParameter_68">
              <SourceParameter reference="Metabolite_4"/>
            </CallParameter>
            <CallParameter functionParameter="FunctionParameter_78">
              <SourceParameter reference="ModelValue_9"/>
            </CallParameter>
            <CallParameter functionParameter="FunctionParameter_79">
              <SourceParameter reference="Metabolite_7"/>
            </CallParameter>
          </ListOfCallParameters>
        </KineticLaw>
      </Reaction>
      <Reaction key="Reaction_4" name="iso_bound" reversible="true" fast="false" addNoise="false">
        <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Reaction_4">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <ListOfSubstrates>
          <Substrate metabolite="Metabolite_0" stoichiometry="1"/>
        </ListOfSubstrates>
        <ListOfProducts>
          <Product metabolite="Metabolite_3" stoichiometry="1"/>
        </ListOfProducts>
        <ListOfConstants>
          <Constant key="Parameter_6923" name="k1" value="0"/>
          <Constant key="Parameter_6924" name="k2" value="0"/>
        </ListOfConstants>
        <KineticLaw function="Function_14" unitType="Default" scalingCompartment="CN=Root,Model=New Model,Vector=Compartments[cell]">
          <ListOfCallParameters>
            <CallParameter functionParameter="FunctionParameter_69">
              <SourceParameter reference="Parameter_6923"/>
            </CallParameter>
            <CallParameter functionParameter="FunctionParameter_68">
              <SourceParameter reference="Metabolite_0"/>
            </CallParameter>
            <CallParameter functionParameter="FunctionParameter_78">
              <SourceParameter reference="Parameter_6924"/>
            </CallParameter>
            <CallParameter functionParameter="FunctionParameter_79">
              <SourceParameter reference="Metabolite_3"/>
            </CallParameter>
          </ListOfCallParameters>
        </KineticLaw>
      </Reaction>
    </ListOfReactions>
    <ListOfEvents>
      <Event key="Event_0" name="InjectPRLR" fireAtInitialTime="0" persistentTrigger="1">
        <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Event_0">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <TriggerExpression>
          &lt;CN=Root,Model=New Model,Reference=Time> == &lt;CN=Root,Model=New Model,Vector=Values[T_offset],Reference=Value> and true
        </TriggerExpression>
        <ListOfAssignments>
          <Assignment target="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[PRLR_cis]" targetKey="Metabolite_2">
            <Expression>
              (&lt;CN=Root,Model=New Model,Vector=Compartments[cell],Reference=Volume>*&lt;CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[PRLR_cis],Reference=Concentration>+&lt;CN=Root,Model=New Model,Vector=Compartments[syringe],Vector=Metabolites[PRLR_cis],Reference=Concentration>*&lt;CN=Root,Model=New Model,Vector=Values[V_inj_actual],Reference=Value>)/(&lt;CN=Root,Model=New Model,Vector=Compartments[cell],Reference=Volume>+&lt;CN=Root,Model=New Model,Vector=Values[V_inj_actual],Reference=Value>)
            </Expression>
          </Assignment>
          <Assignment target="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[PRLR_trans]" targetKey="Metabolite_6">
            <Expression>
              (&lt;CN=Root,Model=New Model,Vector=Compartments[cell],Reference=Volume>*&lt;CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[PRLR_trans],Reference=Concentration>+&lt;CN=Root,Model=New Model,Vector=Values[V_inj_actual],Reference=Value>*&lt;CN=Root,Model=New Model,Vector=Compartments[syringe],Vector=Metabolites[PRLR_trans],Reference=Concentration>)/(&lt;CN=Root,Model=New Model,Vector=Compartments[cell],Reference=Volume>+&lt;CN=Root,Model=New Model,Vector=Values[V_inj_actual],Reference=Value>)
            </Expression>
          </Assignment>
          <Assignment target="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[14_3_3_PRLR_cis]" targetKey="Metabolite_0">
            <Expression>
              &lt;CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[14_3_3_PRLR_cis],Reference=Concentration>*&lt;CN=Root,Model=New Model,Vector=Compartments[cell],Reference=InitialVolume>/(&lt;CN=Root,Model=New Model,Vector=Compartments[cell],Reference=InitialVolume>+&lt;CN=Root,Model=New Model,Vector=Values[V_inj_actual],Reference=Value>)
            </Expression>
          </Assignment>
          <Assignment target="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[14_3_3_PRLR_trans]" targetKey="Metabolite_3">
            <Expression>
              &lt;CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[14_3_3_PRLR_trans],Reference=Concentration>*&lt;CN=Root,Model=New Model,Vector=Compartments[cell],Reference=InitialVolume>/(&lt;CN=Root,Model=New Model,Vector=Compartments[cell],Reference=InitialVolume>+&lt;CN=Root,Model=New Model,Vector=Values[V_inj_actual],Reference=Value>)
            </Expression>
          </Assignment>
          <Assignment target="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[14_3_3]" targetKey="Metabolite_1">
            <Expression>
              &lt;CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[14_3_3],Reference=Concentration>*&lt;CN=Root,Model=New Model,Vector=Compartments[cell],Reference=InitialVolume>/(&lt;CN=Root,Model=New Model,Vector=Compartments[cell],Reference=InitialVolume>+&lt;CN=Root,Model=New Model,Vector=Values[V_inj_actual],Reference=Value>)
            </Expression>
          </Assignment>
          <Assignment target="CN=Root,Model=New Model,Vector=Values[T_offset]" targetKey="ModelValue_7">
            <Expression>
              &lt;CN=Root,Model=New Model,Vector=Values[T_offset],Reference=Value>+&lt;CN=Root,Model=New Model,Vector=Values[T_offset],Reference=InitialValue>
            </Expression>
          </Assignment>
          <Assignment target="CN=Root,Model=New Model,Vector=Values[V_inj_actual]" targetKey="ModelValue_15">
            <Expression>
              &lt;CN=Root,Model=New Model,Vector=Values[V_inj],Reference=InitialValue>
            </Expression>
          </Assignment>
        </ListOfAssignments>
      </Event>
      <Event key="Event_1" name="AdjustConc" fireAtInitialTime="1" persistentTrigger="0">
        <MiriamAnnotation>
<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Event_1">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <TriggerExpression>
          &lt;CN=Root,Model=New Model,Reference=Time> == 10
        </TriggerExpression>
        <ListOfAssignments>
          <Assignment target="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[14_3_3]" targetKey="Metabolite_1">
            <Expression>
              &lt;CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[14_3_3],Reference=InitialConcentration>*&lt;CN=Root,Model=New Model,Vector=Values[N],Reference=Value>
            </Expression>
          </Assignment>
        </ListOfAssignments>
      </Event>
    </ListOfEvents>
    <ListOfModelParameterSets activeSet="ModelParameterSet_1">
      <ModelParameterSet key="ModelParameterSet_1" name="Initial State">
        <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#ModelParameterSet_1">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <ModelParameterGroup cn="String=Initial Time" type="Group">
          <ModelParameter cn="CN=Root,Model=New Model" value="0" type="Model" simulationType="time"/>
        </ModelParameterGroup>
        <ModelParameterGroup cn="String=Initial Compartment Sizes" type="Group">
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[cell]" value="0.00020709999999999999" type="Compartment" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[syringe]" value="1" type="Compartment" simulationType="fixed"/>
        </ModelParameterGroup>
        <ModelParameterGroup cn="String=Initial Species Values" type="Group">
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[14_3_3_PRLR_cis]" value="0" type="Species" simulationType="reactions"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[14_3_3]" value="18084187595242000" type="Species" simulationType="reactions"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[PRLR_cis]" value="0" type="Species" simulationType="reactions"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[14_3_3_PRLR_trans]" value="0" type="Species" simulationType="reactions"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[syringe],Vector=Metabolites[PRLR_cis]" value="1.8263526946697223e+20" type="Species" simulationType="reactions"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[syringe],Vector=Metabolites[14_3_3]" value="0" type="Species" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[PRLR_trans]" value="0" type="Species" simulationType="reactions"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[syringe],Vector=Metabolites[PRLR_trans]" value="4.719714311450278e+20" type="Species" simulationType="reactions"/>
        </ModelParameterGroup>
        <ModelParameterGroup cn="String=Initial Global Quantities" type="Group">
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[Kd_trans]" value="4" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[Kd_cis]" value="0.20000000000000001" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_on_cis]" value="10" type="ModelValue" simulationType="assignment"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_off_cis]" value="2" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_on_trans]" value="0.5" type="ModelValue" simulationType="assignment"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_off_trans]" value="2" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[V_inj]" value="1.9999999999999999e-06" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[T_offset]" value="600" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_cis_trans]" value="0.0040000000000000001" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_trans_cis]" value="0.0015478502080000002" type="ModelValue" simulationType="assignment"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[N]" value="1" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[K_cis_trans]" value="0.38696255200000002" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[K_re]" value="7.7392510400000001" type="ModelValue" simulationType="assignment"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_re_cis_trans]" value="1" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_re_trans_cis]" value="7.7392510400000001" type="ModelValue" simulationType="assignment"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[V_inj_actual]" value="4.9999999999999998e-07" type="ModelValue" simulationType="fixed"/>
        </ModelParameterGroup>
        <ModelParameterGroup cn="String=Kinetic Parameters" type="Group">
          <ModelParameterGroup cn="CN=Root,Model=New Model,Vector=Reactions[cis_binding]" type="Reaction">
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[cis_binding],ParameterGroup=Parameters,Parameter=k1" value="10" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_on_cis],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[cis_binding],ParameterGroup=Parameters,Parameter=k2" value="2" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_off_cis],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
          </ModelParameterGroup>
          <ModelParameterGroup cn="CN=Root,Model=New Model,Vector=Reactions[trans_binding]" type="Reaction">
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[trans_binding],ParameterGroup=Parameters,Parameter=k1" value="0.5" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_on_trans],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[trans_binding],ParameterGroup=Parameters,Parameter=k2" value="2" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_off_trans],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
          </ModelParameterGroup>
          <ModelParameterGroup cn="CN=Root,Model=New Model,Vector=Reactions[iso_cell]" type="Reaction">
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[iso_cell],ParameterGroup=Parameters,Parameter=k1" value="0.0040000000000000001" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_cis_trans],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[iso_cell],ParameterGroup=Parameters,Parameter=k2" value="0.0015478502080000002" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_trans_cis],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
          </ModelParameterGroup>
          <ModelParameterGroup cn="CN=Root,Model=New Model,Vector=Reactions[iso_syringe]" type="Reaction">
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[iso_syringe],ParameterGroup=Parameters,Parameter=k1" value="0.0040000000000000001" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_cis_trans],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[iso_syringe],ParameterGroup=Parameters,Parameter=k2" value="0.0015478502080000002" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_trans_cis],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
          </ModelParameterGroup>
          <ModelParameterGroup cn="CN=Root,Model=New Model,Vector=Reactions[iso_bound]" type="Reaction">
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[iso_bound],ParameterGroup=Parameters,Parameter=k1" value="0" type="ReactionParameter" simulationType="fixed"/>
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[iso_bound],ParameterGroup=Parameters,Parameter=k2" value="0" type="ReactionParameter" simulationType="fixed"/>
          </ModelParameterGroup>
        </ModelParameterGroup>
      </ModelParameterSet>
      <ModelParameterSet key="ModelParameterSet_3" name="HighConcExp">
        <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#ModelParameterSet_3">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <ModelParameterGroup cn="String=Initial Time" type="Group">
          <ModelParameter cn="CN=Root,Model=New Model" value="0" type="Model" simulationType="time"/>
        </ModelParameterGroup>
        <ModelParameterGroup cn="String=Initial Compartment Sizes" type="Group">
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[cell]" value="0.00020709999999999999" type="Compartment" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[syringe]" value="1" type="Compartment" simulationType="fixed"/>
        </ModelParameterGroup>
        <ModelParameterGroup cn="String=Initial Species Values" type="Group">
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[14_3_3_PRLR_cis]" value="0" type="Species" simulationType="reactions"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[14_3_3]" value="22449336325128000" type="Species" simulationType="reactions"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[PRLR_cis]" value="0" type="Species" simulationType="reactions"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[14_3_3_PRLR_trans]" value="0" type="Species" simulationType="reactions"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[syringe],Vector=Metabolites[PRLR_cis]" value="4.0816986085943201e+20" type="Species" simulationType="reactions"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[syringe],Vector=Metabolites[14_3_3]" value="0" type="Species" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[PRLR_trans]" value="0" type="Species" simulationType="reactions"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[syringe],Vector=Metabolites[PRLR_trans]" value="6.6618125515272002e+20" type="Species" simulationType="reactions"/>
        </ModelParameterGroup>
        <ModelParameterGroup cn="String=Initial Global Quantities" type="Group">
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[Kd_trans]" value="4" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[Kd_cis]" value="0.20000000000000001" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_on_cis]" value="10" type="ModelValue" simulationType="assignment"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_off_cis]" value="2" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_on_trans]" value="0.5" type="ModelValue" simulationType="assignment"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_off_trans]" value="2" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[V_inj]" value="1.9999999999999999e-06" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[T_offset]" value="600" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_cis_trans]" value="0.0040000000000000001" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_trans_cis]" value="0.0024480000000000001" type="ModelValue" simulationType="assignment"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[N]" value="1" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[K_cis_trans]" value="0.61199999999999999" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[K_re]" value="12.239999999999998" type="ModelValue" simulationType="assignment"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_re_cis_trans]" value="1" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_re_trans_cis]" value="12.239999999999998" type="ModelValue" simulationType="assignment"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[V_inj_actual]" value="4.9999999999999998e-07" type="ModelValue" simulationType="fixed"/>
        </ModelParameterGroup>
        <ModelParameterGroup cn="String=Kinetic Parameters" type="Group">
          <ModelParameterGroup cn="CN=Root,Model=New Model,Vector=Reactions[cis_binding]" type="Reaction">
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[cis_binding],ParameterGroup=Parameters,Parameter=k1" value="10" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_on_cis],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[cis_binding],ParameterGroup=Parameters,Parameter=k2" value="2" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_off_cis],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
          </ModelParameterGroup>
          <ModelParameterGroup cn="CN=Root,Model=New Model,Vector=Reactions[trans_binding]" type="Reaction">
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[trans_binding],ParameterGroup=Parameters,Parameter=k1" value="0.5" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_on_trans],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[trans_binding],ParameterGroup=Parameters,Parameter=k2" value="2" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_off_trans],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
          </ModelParameterGroup>
          <ModelParameterGroup cn="CN=Root,Model=New Model,Vector=Reactions[iso_cell]" type="Reaction">
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[iso_cell],ParameterGroup=Parameters,Parameter=k1" value="0.0040000000000000001" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_cis_trans],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[iso_cell],ParameterGroup=Parameters,Parameter=k2" value="0.0024480000000000001" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_trans_cis],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
          </ModelParameterGroup>
          <ModelParameterGroup cn="CN=Root,Model=New Model,Vector=Reactions[iso_syringe]" type="Reaction">
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[iso_syringe],ParameterGroup=Parameters,Parameter=k1" value="0.0040000000000000001" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_cis_trans],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[iso_syringe],ParameterGroup=Parameters,Parameter=k2" value="0.0024480000000000001" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_trans_cis],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
          </ModelParameterGroup>
          <ModelParameterGroup cn="CN=Root,Model=New Model,Vector=Reactions[iso_bound]" type="Reaction">
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[iso_bound],ParameterGroup=Parameters,Parameter=k1" value="0" type="ReactionParameter" simulationType="fixed"/>
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[iso_bound],ParameterGroup=Parameters,Parameter=k2" value="0" type="ReactionParameter" simulationType="fixed"/>
          </ModelParameterGroup>
        </ModelParameterGroup>
      </ModelParameterSet>
      <ModelParameterSet key="ModelParameterSet_4" name="LowConcExp">
        <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#ModelParameterSet_4">
</rdf:Description>
</rdf:RDF>
        </MiriamAnnotation>
        <ModelParameterGroup cn="String=Initial Time" type="Group">
          <ModelParameter cn="CN=Root,Model=New Model" value="0" type="Model" simulationType="time"/>
        </ModelParameterGroup>
        <ModelParameterGroup cn="String=Initial Compartment Sizes" type="Group">
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[cell]" value="0.00020709999999999999" type="Compartment" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[syringe]" value="1" type="Compartment" simulationType="fixed"/>
        </ModelParameterGroup>
        <ModelParameterGroup cn="String=Initial Species Values" type="Group">
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[14_3_3_PRLR_cis]" value="0" type="Species" simulationType="reactions"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[14_3_3]" value="3554478251478600" type="Species" simulationType="reactions"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[PRLR_cis]" value="0" type="Species" simulationType="reactions"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[14_3_3_PRLR_trans]" value="0" type="Species" simulationType="reactions"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[syringe],Vector=Metabolites[PRLR_cis]" value="5.8827050393261539e+19" type="Species" simulationType="reactions"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[syringe],Vector=Metabolites[14_3_3]" value="0" type="Species" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[PRLR_trans]" value="0" type="Species" simulationType="reactions"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Compartments[syringe],Vector=Metabolites[PRLR_trans]" value="9.6122631361538458e+19" type="Species" simulationType="reactions"/>
        </ModelParameterGroup>
        <ModelParameterGroup cn="String=Initial Global Quantities" type="Group">
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[Kd_trans]" value="4" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[Kd_cis]" value="0.20000000000000001" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_on_cis]" value="10" type="ModelValue" simulationType="assignment"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_off_cis]" value="2" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_on_trans]" value="0.5" type="ModelValue" simulationType="assignment"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_off_trans]" value="2" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[V_inj]" value="2.0999999999999998e-06" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[T_offset]" value="600" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_cis_trans]" value="0.0040000000000000001" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_trans_cis]" value="0.0024480000000000001" type="ModelValue" simulationType="assignment"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[N]" value="1" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[K_cis_trans]" value="0.61199999999999999" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[K_re]" value="12.239999999999998" type="ModelValue" simulationType="assignment"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_re_cis_trans]" value="1" type="ModelValue" simulationType="fixed"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[k_re_trans_cis]" value="12.239999999999998" type="ModelValue" simulationType="assignment"/>
          <ModelParameter cn="CN=Root,Model=New Model,Vector=Values[V_inj_actual]" value="4.9999999999999998e-07" type="ModelValue" simulationType="fixed"/>
        </ModelParameterGroup>
        <ModelParameterGroup cn="String=Kinetic Parameters" type="Group">
          <ModelParameterGroup cn="CN=Root,Model=New Model,Vector=Reactions[cis_binding]" type="Reaction">
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[cis_binding],ParameterGroup=Parameters,Parameter=k1" value="10" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_on_cis],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[cis_binding],ParameterGroup=Parameters,Parameter=k2" value="2" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_off_cis],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
          </ModelParameterGroup>
          <ModelParameterGroup cn="CN=Root,Model=New Model,Vector=Reactions[trans_binding]" type="Reaction">
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[trans_binding],ParameterGroup=Parameters,Parameter=k1" value="0.5" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_on_trans],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[trans_binding],ParameterGroup=Parameters,Parameter=k2" value="2" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_off_trans],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
          </ModelParameterGroup>
          <ModelParameterGroup cn="CN=Root,Model=New Model,Vector=Reactions[iso_cell]" type="Reaction">
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[iso_cell],ParameterGroup=Parameters,Parameter=k1" value="0.0040000000000000001" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_cis_trans],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[iso_cell],ParameterGroup=Parameters,Parameter=k2" value="0.0024480000000000001" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_trans_cis],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
          </ModelParameterGroup>
          <ModelParameterGroup cn="CN=Root,Model=New Model,Vector=Reactions[iso_syringe]" type="Reaction">
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[iso_syringe],ParameterGroup=Parameters,Parameter=k1" value="0.0040000000000000001" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_cis_trans],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[iso_syringe],ParameterGroup=Parameters,Parameter=k2" value="0.0024480000000000001" type="ReactionParameter" simulationType="assignment">
              <InitialExpression>
                &lt;CN=Root,Model=New Model,Vector=Values[k_trans_cis],Reference=InitialValue>
              </InitialExpression>
            </ModelParameter>
          </ModelParameterGroup>
          <ModelParameterGroup cn="CN=Root,Model=New Model,Vector=Reactions[iso_bound]" type="Reaction">
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[iso_bound],ParameterGroup=Parameters,Parameter=k1" value="0" type="ReactionParameter" simulationType="fixed"/>
            <ModelParameter cn="CN=Root,Model=New Model,Vector=Reactions[iso_bound],ParameterGroup=Parameters,Parameter=k2" value="0" type="ReactionParameter" simulationType="fixed"/>
          </ModelParameterGroup>
        </ModelParameterGroup>
      </ModelParameterSet>
    </ListOfModelParameterSets>
    <StateTemplate>
      <StateTemplateVariable objectReference="Model_1"/>
      <StateTemplateVariable objectReference="Metabolite_0"/>
      <StateTemplateVariable objectReference="Metabolite_6"/>
      <StateTemplateVariable objectReference="Metabolite_2"/>
      <StateTemplateVariable objectReference="Metabolite_4"/>
      <StateTemplateVariable objectReference="Metabolite_3"/>
      <StateTemplateVariable objectReference="Metabolite_1"/>
      <StateTemplateVariable objectReference="Metabolite_7"/>
      <StateTemplateVariable objectReference="ModelValue_2"/>
      <StateTemplateVariable objectReference="ModelValue_4"/>
      <StateTemplateVariable objectReference="ModelValue_9"/>
      <StateTemplateVariable objectReference="ModelValue_12"/>
      <StateTemplateVariable objectReference="ModelValue_14"/>
      <StateTemplateVariable objectReference="Metabolite_5"/>
      <StateTemplateVariable objectReference="Compartment_0"/>
      <StateTemplateVariable objectReference="Compartment_1"/>
      <StateTemplateVariable objectReference="ModelValue_0"/>
      <StateTemplateVariable objectReference="ModelValue_1"/>
      <StateTemplateVariable objectReference="ModelValue_3"/>
      <StateTemplateVariable objectReference="ModelValue_5"/>
      <StateTemplateVariable objectReference="ModelValue_6"/>
      <StateTemplateVariable objectReference="ModelValue_7"/>
      <StateTemplateVariable objectReference="ModelValue_8"/>
      <StateTemplateVariable objectReference="ModelValue_10"/>
      <StateTemplateVariable objectReference="ModelValue_11"/>
      <StateTemplateVariable objectReference="ModelValue_13"/>
      <StateTemplateVariable objectReference="ModelValue_15"/>
    </StateTemplate>
    <InitialState type="initialState">
      0 0 0 0 1.8263526946697223e+20 0 18084187595242000 4.719714311450278e+20 10 0.5 0.0015478502080000002 7.7392510400000001 7.7392510400000001 0 0.00020709999999999999 1 4 0.20000000000000001 2 2 1.9999999999999999e-06 600 0.0040000000000000001 1 0.38696255200000002 1 4.9999999999999998e-07 
    </InitialState>
  </Model>
  <ListOfTasks>
    <Task key="Task_17" name="Steady-State" type="steadyState" scheduled="false" updateModel="false">
      <Report reference="Report_22" target="" append="1" confirmOverwrite="1"/>
      <Problem>
        <Parameter name="JacobianRequested" type="bool" value="1"/>
        <Parameter name="StabilityAnalysisRequested" type="bool" value="1"/>
      </Problem>
      <Method name="Enhanced Newton" type="EnhancedNewton">
        <Parameter name="Resolution" type="unsignedFloat" value="1.0000000000000001e-09"/>
        <Parameter name="Derivation Factor" type="unsignedFloat" value="0.001"/>
        <Parameter name="Use Newton" type="bool" value="1"/>
        <Parameter name="Use Integration" type="bool" value="1"/>
        <Parameter name="Use Back Integration" type="bool" value="0"/>
        <Parameter name="Accept Negative Concentrations" type="bool" value="0"/>
        <Parameter name="Iteration Limit" type="unsignedInteger" value="500"/>
        <Parameter name="Maximum duration for forward integration" type="unsignedFloat" value="1000000000"/>
        <Parameter name="Maximum duration for backward integration" type="unsignedFloat" value="1000000"/>
        <Parameter name="Target Criterion" type="string" value="Distance and Rate"/>
      </Method>
    </Task>
    <Task key="Task_18" name="Time-Course" type="timeCourse" scheduled="false" updateModel="false">
      <Report reference="Report_11" target="output.txt" append="0" confirmOverwrite="0"/>
      <Problem>
        <Parameter name="AutomaticStepSize" type="bool" value="1"/>
        <Parameter name="StepNumber" type="unsignedInteger" value="100"/>
        <Parameter name="StepSize" type="float" value="11.99"/>
        <Parameter name="Duration" type="float" value="1199"/>
        <Parameter name="TimeSeriesRequested" type="bool" value="1"/>
        <Parameter name="OutputStartTime" type="float" value="0"/>
        <Parameter name="Output Event" type="bool" value="0"/>
        <Parameter name="Start in Steady State" type="bool" value="0"/>
        <Parameter name="Use Values" type="bool" value="1"/>
        <Parameter name="Values" type="string" value="590&#x09;1190&#x09;1790&#x09;2390&#x09;2990&#x09;3590&#x09;4190&#x09;4790&#x09;5390&#x09;5990&#x09;6590&#x09;7190&#x09;7790&#x09;8390&#x09;8990&#x09;9590&#x09;10190&#x09;10790&#x09;11390&#x09;11990&#x09;12590&#x09;13190&#x09;13790&#x09;14390&#x09;14990"/>
      </Problem>
      <Method name="Deterministic (LSODA)" type="Deterministic(LSODA)">
        <Parameter name="Integrate Reduced Model" type="bool" value="1"/>
        <Parameter name="Relative Tolerance" type="unsignedFloat" value="9.9999999999999995e-07"/>
        <Parameter name="Absolute Tolerance" type="unsignedFloat" value="9.9999999999999998e-13"/>
        <Parameter name="Max Internal Steps" type="unsignedInteger" value="100000000"/>
        <Parameter name="Max Internal Step Size" type="unsignedFloat" value="10"/>
      </Method>
    </Task>
    <Task key="Task_19" name="Scan" type="scan" scheduled="false" updateModel="false">
      <Problem>
        <Parameter name="Subtask" type="unsignedInteger" value="0"/>
        <ParameterGroup name="ScanItems">
          <ParameterGroup name="ScanItem">
            <Parameter name="Number of steps" type="unsignedInteger" value="15"/>
            <Parameter name="Type" type="unsignedInteger" value="1"/>
            <Parameter name="Object" type="cn" value="CN=Root,Model=New Model,Vector=Values[Kd_cis],Reference=InitialValue"/>
            <Parameter name="Minimum" type="float" value="0.10000000000000001"/>
            <Parameter name="Maximum" type="float" value="1000"/>
            <Parameter name="log" type="bool" value="1"/>
            <Parameter name="Values" type="string" value=""/>
            <Parameter name="Use Values" type="bool" value="0"/>
          </ParameterGroup>
        </ParameterGroup>
        <Parameter name="Output in subtask" type="bool" value="0"/>
        <Parameter name="Adjust initial conditions" type="bool" value="0"/>
        <Parameter name="Continue on Error" type="bool" value="0"/>
      </Problem>
      <Method name="Scan Framework" type="ScanFramework">
      </Method>
    </Task>
    <Task key="Task_20" name="Elementary Flux Modes" type="fluxMode" scheduled="false" updateModel="false">
      <Report reference="Report_12" target="" append="1" confirmOverwrite="1"/>
      <Problem>
      </Problem>
      <Method name="EFM Algorithm" type="EFMAlgorithm">
      </Method>
    </Task>
    <Task key="Task_21" name="Optimization" type="optimization" scheduled="false" updateModel="false">
      <Report reference="Report_13" target="" append="1" confirmOverwrite="1"/>
      <Problem>
        <Parameter name="Subtask" type="cn" value="CN=Root,Vector=TaskList[Steady-State]"/>
        <ParameterText name="ObjectiveExpression" type="expression">
          
        </ParameterText>
        <Parameter name="Maximize" type="bool" value="0"/>
        <Parameter name="Randomize Start Values" type="bool" value="0"/>
        <Parameter name="Calculate Statistics" type="bool" value="1"/>
        <ParameterGroup name="OptimizationItemList">
        </ParameterGroup>
        <ParameterGroup name="OptimizationConstraintList">
        </ParameterGroup>
      </Problem>
      <Method name="Random Search" type="RandomSearch">
        <Parameter name="Log Verbosity" type="unsignedInteger" value="0"/>
        <Parameter name="Number of Iterations" type="unsignedInteger" value="100000"/>
        <Parameter name="Random Number Generator" type="unsignedInteger" value="1"/>
        <Parameter name="Seed" type="unsignedInteger" value="0"/>
      </Method>
    </Task>
    <Task key="Task_22" name="Parameter Estimation" type="parameterFitting" scheduled="false" updateModel="false">
      <Report reference="Report_14" target="" append="1" confirmOverwrite="1"/>
      <Problem>
        <Parameter name="Maximize" type="bool" value="0"/>
        <Parameter name="Randomize Start Values" type="bool" value="0"/>
        <Parameter name="Calculate Statistics" type="bool" value="1"/>
        <ParameterGroup name="OptimizationItemList">
        </ParameterGroup>
        <ParameterGroup name="OptimizationConstraintList">
        </ParameterGroup>
        <Parameter name="Steady-State" type="cn" value="CN=Root,Vector=TaskList[Steady-State]"/>
        <Parameter name="Time-Course" type="cn" value="CN=Root,Vector=TaskList[Time-Course]"/>
        <Parameter name="Create Parameter Sets" type="bool" value="0"/>
        <Parameter name="Use Time Sens" type="bool" value="0"/>
        <Parameter name="Time-Sens" type="cn" value=""/>
        <ParameterGroup name="Experiment Set">
        </ParameterGroup>
        <ParameterGroup name="Validation Set">
          <Parameter name="Weight" type="unsignedFloat" value="1"/>
          <Parameter name="Threshold" type="unsignedInteger" value="5"/>
        </ParameterGroup>
      </Problem>
      <Method name="Evolutionary Programming" type="EvolutionaryProgram">
        <Parameter name="Log Verbosity" type="unsignedInteger" value="0"/>
        <Parameter name="Number of Generations" type="unsignedInteger" value="200"/>
        <Parameter name="Population Size" type="unsignedInteger" value="20"/>
        <Parameter name="Random Number Generator" type="unsignedInteger" value="1"/>
        <Parameter name="Seed" type="unsignedInteger" value="0"/>
        <Parameter name="Stop after # Stalled Generations" type="unsignedInteger" value="0"/>
      </Method>
    </Task>
    <Task key="Task_23" name="Metabolic Control Analysis" type="metabolicControlAnalysis" scheduled="false" updateModel="false">
      <Report reference="Report_15" target="" append="1" confirmOverwrite="1"/>
      <Problem>
        <Parameter name="Steady-State" type="key" value="Task_17"/>
      </Problem>
      <Method name="MCA Method (Reder)" type="MCAMethod(Reder)">
        <Parameter name="Modulation Factor" type="unsignedFloat" value="1.0000000000000001e-09"/>
        <Parameter name="Use Reder" type="bool" value="1"/>
        <Parameter name="Use Smallbone" type="bool" value="1"/>
      </Method>
    </Task>
    <Task key="Task_24" name="Lyapunov Exponents" type="lyapunovExponents" scheduled="false" updateModel="false">
      <Report reference="Report_16" target="" append="1" confirmOverwrite="1"/>
      <Problem>
        <Parameter name="ExponentNumber" type="unsignedInteger" value="3"/>
        <Parameter name="DivergenceRequested" type="bool" value="1"/>
        <Parameter name="TransientTime" type="float" value="0"/>
      </Problem>
      <Method name="Wolf Method" type="WolfMethod">
        <Parameter name="Orthonormalization Interval" type="unsignedFloat" value="1"/>
        <Parameter name="Overall time" type="unsignedFloat" value="1000"/>
        <Parameter name="Relative Tolerance" type="unsignedFloat" value="9.9999999999999995e-07"/>
        <Parameter name="Absolute Tolerance" type="unsignedFloat" value="9.9999999999999998e-13"/>
        <Parameter name="Max Internal Steps" type="unsignedInteger" value="10000"/>
      </Method>
    </Task>
    <Task key="Task_25" name="Time Scale Separation Analysis" type="timeScaleSeparationAnalysis" scheduled="false" updateModel="false">
      <Report reference="Report_17" target="" append="1" confirmOverwrite="1"/>
      <Problem>
        <Parameter name="StepNumber" type="unsignedInteger" value="100"/>
        <Parameter name="StepSize" type="float" value="0.01"/>
        <Parameter name="Duration" type="float" value="1"/>
        <Parameter name="TimeSeriesRequested" type="bool" value="1"/>
        <Parameter name="OutputStartTime" type="float" value="0"/>
      </Problem>
      <Method name="ILDM (LSODA,Deuflhard)" type="TimeScaleSeparation(ILDM,Deuflhard)">
        <Parameter name="Deuflhard Tolerance" type="unsignedFloat" value="0.0001"/>
      </Method>
    </Task>
    <Task key="Task_26" name="Sensitivities" type="sensitivities" scheduled="false" updateModel="false">
      <Report reference="Report_18" target="" append="1" confirmOverwrite="1"/>
      <Problem>
        <Parameter name="SubtaskType" type="unsignedInteger" value="1"/>
        <ParameterGroup name="TargetFunctions">
          <Parameter name="SingleObject" type="cn" value=""/>
          <Parameter name="ObjectListType" type="unsignedInteger" value="7"/>
        </ParameterGroup>
        <ParameterGroup name="ListOfVariables">
          <ParameterGroup name="Variables">
            <Parameter name="SingleObject" type="cn" value=""/>
            <Parameter name="ObjectListType" type="unsignedInteger" value="41"/>
          </ParameterGroup>
          <ParameterGroup name="Variables">
            <Parameter name="SingleObject" type="cn" value=""/>
            <Parameter name="ObjectListType" type="unsignedInteger" value="0"/>
          </ParameterGroup>
        </ParameterGroup>
      </Problem>
      <Method name="Sensitivities Method" type="SensitivitiesMethod">
        <Parameter name="Delta factor" type="unsignedFloat" value="0.001"/>
        <Parameter name="Delta minimum" type="unsignedFloat" value="9.9999999999999998e-13"/>
      </Method>
    </Task>
    <Task key="Task_27" name="Moieties" type="moieties" scheduled="false" updateModel="false">
      <Report reference="Report_19" target="" append="1" confirmOverwrite="1"/>
      <Problem>
      </Problem>
      <Method name="Householder Reduction" type="Householder">
      </Method>
    </Task>
    <Task key="Task_28" name="Cross Section" type="crosssection" scheduled="false" updateModel="false">
      <Problem>
        <Parameter name="AutomaticStepSize" type="bool" value="0"/>
        <Parameter name="StepNumber" type="unsignedInteger" value="100"/>
        <Parameter name="StepSize" type="float" value="0.01"/>
        <Parameter name="Duration" type="float" value="1"/>
        <Parameter name="TimeSeriesRequested" type="bool" value="1"/>
        <Parameter name="OutputStartTime" type="float" value="0"/>
        <Parameter name="Output Event" type="bool" value="0"/>
        <Parameter name="Start in Steady State" type="bool" value="0"/>
        <Parameter name="Use Values" type="bool" value="0"/>
        <Parameter name="Values" type="string" value=""/>
        <Parameter name="LimitCrossings" type="bool" value="0"/>
        <Parameter name="NumCrossingsLimit" type="unsignedInteger" value="0"/>
        <Parameter name="LimitOutTime" type="bool" value="0"/>
        <Parameter name="LimitOutCrossings" type="bool" value="0"/>
        <Parameter name="PositiveDirection" type="bool" value="1"/>
        <Parameter name="NumOutCrossingsLimit" type="unsignedInteger" value="0"/>
        <Parameter name="LimitUntilConvergence" type="bool" value="0"/>
        <Parameter name="ConvergenceTolerance" type="float" value="0"/>
        <Parameter name="Threshold" type="float" value="0"/>
        <Parameter name="DelayOutputUntilConvergence" type="bool" value="0"/>
        <Parameter name="OutputConvergenceTolerance" type="float" value="0"/>
        <ParameterText name="TriggerExpression" type="expression">
          
        </ParameterText>
        <Parameter name="SingleVariable" type="cn" value=""/>
      </Problem>
      <Method name="Deterministic (LSODA)" type="Deterministic(LSODA)">
        <Parameter name="Integrate Reduced Model" type="bool" value="0"/>
        <Parameter name="Relative Tolerance" type="unsignedFloat" value="9.9999999999999995e-07"/>
        <Parameter name="Absolute Tolerance" type="unsignedFloat" value="9.9999999999999998e-13"/>
        <Parameter name="Max Internal Steps" type="unsignedInteger" value="100000"/>
        <Parameter name="Max Internal Step Size" type="unsignedFloat" value="0"/>
      </Method>
    </Task>
    <Task key="Task_29" name="Linear Noise Approximation" type="linearNoiseApproximation" scheduled="false" updateModel="false">
      <Report reference="Report_20" target="" append="1" confirmOverwrite="1"/>
      <Problem>
        <Parameter name="Steady-State" type="key" value="Task_17"/>
      </Problem>
      <Method name="Linear Noise Approximation" type="LinearNoiseApproximation">
      </Method>
    </Task>
    <Task key="Task_30" name="Time-Course Sensitivities" type="timeSensitivities" scheduled="false" updateModel="false">
      <Problem>
        <Parameter name="AutomaticStepSize" type="bool" value="0"/>
        <Parameter name="StepNumber" type="unsignedInteger" value="100"/>
        <Parameter name="StepSize" type="float" value="0.01"/>
        <Parameter name="Duration" type="float" value="1"/>
        <Parameter name="TimeSeriesRequested" type="bool" value="1"/>
        <Parameter name="OutputStartTime" type="float" value="0"/>
        <Parameter name="Output Event" type="bool" value="0"/>
        <Parameter name="Start in Steady State" type="bool" value="0"/>
        <Parameter name="Use Values" type="bool" value="0"/>
        <Parameter name="Values" type="string" value=""/>
        <ParameterGroup name="ListOfParameters">
        </ParameterGroup>
        <ParameterGroup name="ListOfTargets">
        </ParameterGroup>
      </Problem>
      <Method name="LSODA Sensitivities" type="Sensitivities(LSODA)">
        <Parameter name="Integrate Reduced Model" type="bool" value="0"/>
        <Parameter name="Relative Tolerance" type="unsignedFloat" value="9.9999999999999995e-07"/>
        <Parameter name="Absolute Tolerance" type="unsignedFloat" value="9.9999999999999998e-13"/>
        <Parameter name="Max Internal Steps" type="unsignedInteger" value="10000"/>
        <Parameter name="Max Internal Step Size" type="unsignedFloat" value="0"/>
      </Method>
    </Task>
  </ListOfTasks>
  <ListOfReports>
    <Report key="Report_11" name="Time-Course" taskType="timeCourse" separator="&#x09;" precision="6">
      <Comment>
        Automatically generated report.
      </Comment>
      <Header>
        <Object cn="String=# Time"/>
        <Object cn="Separator=&#x09;"/>
        <Object cn="String=14-3-3_Free"/>
        <Object cn="Separator=&#x09;"/>
        <Object cn="String=PRLR_Cis_Free"/>
        <Object cn="Separator=&#x09;"/>
        <Object cn="String=PRLR_Trans_Free"/>
        <Object cn="Separator=&#x09;"/>
        <Object cn="String=14-3-3_PRLR_Cis_Bound"/>
        <Object cn="Separator=&#x09;"/>
        <Object cn="String=14-3-3_PRLR_Trans_Bound"/>
        <Object cn="Separator=&#x09;"/>
        <Object cn="String=V_inj"/>
      </Header>
      <Body>
        <Object cn="CN=Root,Model=New Model,Reference=Time"/>
        <Object cn="Separator=&#x09;"/>
        <Object cn="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[14_3_3],Reference=Concentration"/>
        <Object cn="Separator=&#x09;"/>
        <Object cn="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[PRLR_cis],Reference=Concentration"/>
        <Object cn="Separator=&#x09;"/>
        <Object cn="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[PRLR_trans],Reference=Concentration"/>
        <Object cn="Separator=&#x09;"/>
        <Object cn="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[14_3_3_PRLR_cis],Reference=Concentration"/>
        <Object cn="Separator=&#x09;"/>
        <Object cn="CN=Root,Model=New Model,Vector=Compartments[cell],Vector=Metabolites[14_3_3_PRLR_trans],Reference=Concentration"/>
        <Object cn="Separator=&#x09;"/>
        <Object cn="CN=Root,Model=New Model,Vector=Values[V_inj_actual],Reference=Value"/>
      </Body>
    </Report>
    <Report key="Report_12" name="Elementary Flux Modes" taskType="fluxMode" separator="&#x09;" precision="6">
      <Comment>
        Automatically generated report.
      </Comment>
      <Footer>
        <Object cn="CN=Root,Vector=TaskList[Elementary Flux Modes],Object=Result"/>
      </Footer>
    </Report>
    <Report key="Report_13" name="Optimization" taskType="optimization" separator="&#x09;" precision="6">
      <Comment>
        Automatically generated report.
      </Comment>
      <Header>
        <Object cn="CN=Root,Vector=TaskList[Optimization],Object=Description"/>
        <Object cn="String=\[Function Evaluations\]"/>
        <Object cn="Separator=&#x09;"/>
        <Object cn="String=\[Best Value\]"/>
        <Object cn="Separator=&#x09;"/>
        <Object cn="String=\[Best Parameters\]"/>
      </Header>
      <Body>
        <Object cn="CN=Root,Vector=TaskList[Optimization],Problem=Optimization,Reference=Function Evaluations"/>
        <Object cn="Separator=&#x09;"/>
        <Object cn="CN=Root,Vector=TaskList[Optimization],Problem=Optimization,Reference=Best Value"/>
        <Object cn="Separator=&#x09;"/>
        <Object cn="CN=Root,Vector=TaskList[Optimization],Problem=Optimization,Reference=Best Parameters"/>
      </Body>
      <Footer>
        <Object cn="String=&#x0a;"/>
        <Object cn="CN=Root,Vector=TaskList[Optimization],Object=Result"/>
      </Footer>
    </Report>
    <Report key="Report_14" name="Parameter Estimation" taskType="parameterFitting" separator="&#x09;" precision="6">
      <Comment>
        Automatically generated report.
      </Comment>
      <Header>
        <Object cn="CN=Root,Vector=TaskList[Parameter Estimation],Object=Description"/>
        <Object cn="String=\[Function Evaluations\]"/>
        <Object cn="Separator=&#x09;"/>
        <Object cn="String=\[Best Value\]"/>
        <Object cn="Separator=&#x09;"/>
        <Object cn="String=\[Best Parameters\]"/>
      </Header>
      <Body>
        <Object cn="CN=Root,Vector=TaskList[Parameter Estimation],Problem=Parameter Estimation,Reference=Function Evaluations"/>
        <Object cn="Separator=&#x09;"/>
        <Object cn="CN=Root,Vector=TaskList[Parameter Estimation],Problem=Parameter Estimation,Reference=Best Value"/>
        <Object cn="Separator=&#x09;"/>
        <Object cn="CN=Root,Vector=TaskList[Parameter Estimation],Problem=Parameter Estimation,Reference=Best Parameters"/>
      </Body>
      <Footer>
        <Object cn="String=&#x0a;"/>
        <Object cn="CN=Root,Vector=TaskList[Parameter Estimation],Object=Result"/>
      </Footer>
    </Report>
    <Report key="Report_15" name="Metabolic Control Analysis" taskType="metabolicControlAnalysis" separator="&#x09;" precision="6">
      <Comment>
        Automatically generated report.
      </Comment>
      <Header>
        <Object cn="CN=Root,Vector=TaskList[Metabolic Control Analysis],Object=Description"/>
      </Header>
      <Footer>
        <Object cn="String=&#x0a;"/>
        <Object cn="CN=Root,Vector=TaskList[Metabolic Control Analysis],Object=Result"/>
      </Footer>
    </Report>
    <Report key="Report_16" name="Lyapunov Exponents" taskType="lyapunovExponents" separator="&#x09;" precision="6">
      <Comment>
        Automatically generated report.
      </Comment>
      <Header>
        <Object cn="CN=Root,Vector=TaskList[Lyapunov Exponents],Object=Description"/>
      </Header>
      <Footer>
        <Object cn="String=&#x0a;"/>
        <Object cn="CN=Root,Vector=TaskList[Lyapunov Exponents],Object=Result"/>
      </Footer>
    </Report>
    <Report key="Report_17" name="Time Scale Separation Analysis" taskType="timeScaleSeparationAnalysis" separator="&#x09;" precision="6">
      <Comment>
        Automatically generated report.
      </Comment>
      <Header>
        <Object cn="CN=Root,Vector=TaskList[Time Scale Separation Analysis],Object=Description"/>
      </Header>
      <Footer>
        <Object cn="String=&#x0a;"/>
        <Object cn="CN=Root,Vector=TaskList[Time Scale Separation Analysis],Object=Result"/>
      </Footer>
    </Report>
    <Report key="Report_18" name="Sensitivities" taskType="sensitivities" separator="&#x09;" precision="6">
      <Comment>
        Automatically generated report.
      </Comment>
      <Header>
        <Object cn="CN=Root,Vector=TaskList[Sensitivities],Object=Description"/>
      </Header>
      <Footer>
        <Object cn="String=&#x0a;"/>
        <Object cn="CN=Root,Vector=TaskList[Sensitivities],Object=Result"/>
      </Footer>
    </Report>
    <Report key="Report_19" name="Moieties" taskType="moieties" separator="&#x09;" precision="6">
      <Comment>
        Automatically generated report.
      </Comment>
      <Header>
        <Object cn="CN=Root,Vector=TaskList[Moieties],Object=Description"/>
      </Header>
      <Footer>
        <Object cn="String=&#x0a;"/>
        <Object cn="CN=Root,Vector=TaskList[Moieties],Object=Result"/>
      </Footer>
    </Report>
    <Report key="Report_20" name="Linear Noise Approximation" taskType="linearNoiseApproximation" separator="&#x09;" precision="6">
      <Comment>
        Automatically generated report.
      </Comment>
      <Header>
        <Object cn="CN=Root,Vector=TaskList[Linear Noise Approximation],Object=Description"/>
      </Header>
      <Footer>
        <Object cn="String=&#x0a;"/>
        <Object cn="CN=Root,Vector=TaskList[Linear Noise Approximation],Object=Result"/>
      </Footer>
    </Report>
    <Report key="Report_21" name="LinkerReport" taskType="timeCourse" separator="&#x09;" precision="6">
      <Comment>
      </Comment>
      <Body>
        <Object cn="CN=Root,Model=New Model,Vector=Values[linkerlength],Reference=InitialValue"/>
        <Object cn="Separator=&#x09;"/>
        <Object cn="CN=Root,Model=New Model,Vector=Values[dG_sim],Reference=Value"/>
      </Body>
    </Report>
    <Report key="Report_22" name="Steady-State" taskType="steadyState" separator="&#x09;" precision="6">
      <Comment>
        Automatically generated report.
      </Comment>
      <Footer>
        <Object cn="CN=Root,Vector=TaskList[Steady-State]"/>
      </Footer>
    </Report>
  </ListOfReports>
  <GUI>
  </GUI>
  <ListOfUnitDefinitions>
    <UnitDefinition key="Unit_1" name="meter" symbol="m">
      <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Unit_0">
</rdf:Description>
</rdf:RDF>
      </MiriamAnnotation>
      <Expression>
        m
      </Expression>
    </UnitDefinition>
    <UnitDefinition key="Unit_5" name="second" symbol="s">
      <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Unit_4">
</rdf:Description>
</rdf:RDF>
      </MiriamAnnotation>
      <Expression>
        s
      </Expression>
    </UnitDefinition>
    <UnitDefinition key="Unit_13" name="Avogadro" symbol="Avogadro">
      <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Unit_12">
</rdf:Description>
</rdf:RDF>
      </MiriamAnnotation>
      <Expression>
        Avogadro
      </Expression>
    </UnitDefinition>
    <UnitDefinition key="Unit_15" name="dimensionless" symbol="1">
      <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Unit_14">
</rdf:Description>
</rdf:RDF>
      </MiriamAnnotation>
      <Expression>
        1
      </Expression>
    </UnitDefinition>
    <UnitDefinition key="Unit_17" name="item" symbol="#">
      <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Unit_16">
</rdf:Description>
</rdf:RDF>
      </MiriamAnnotation>
      <Expression>
        #
      </Expression>
    </UnitDefinition>
    <UnitDefinition key="Unit_35" name="liter" symbol="l">
      <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Unit_34">
</rdf:Description>
</rdf:RDF>
      </MiriamAnnotation>
      <Expression>
        0.001*m^3
      </Expression>
    </UnitDefinition>
    <UnitDefinition key="Unit_41" name="mole" symbol="mol">
      <MiriamAnnotation>
<rdf:RDF
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about="#Unit_40">
</rdf:Description>
</rdf:RDF>
      </MiriamAnnotation>
      <Expression>
        Avogadro*#
      </Expression>
    </UnitDefinition>
  </ListOfUnitDefinitions>
</COPASI>
