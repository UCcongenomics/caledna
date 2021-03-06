export const CSCI = "CSCI";
export const MMI = "MMI";
export const OE = "O/E";
export const D18 = "D18";
export const S2 = "S2";
export const CRAM = "Overall CRAM Score";
export const BioticStructure = "Biotic Structure";
export const Buffer = "Buffer and Landscape Context";
export const Hydrology = "Hydrology";
export const PhysicalStructure = "Physical Structure";
export const Temperature = "Temperature (C°)";
export const Oxygen = "Dissolved Oxygen (mg/L)";
export const pH = "pH";
export const Salinity = "Salinity (ppt)";
export const SpecificConductivity = "Specific Conductivity (us/cm)";
export const Alkalinity = "Alkalinity as CaCO3 (mg/L)";
export const Hardness = "Hardness as CaCO3 (mg/L)";
export const Chloride = "Chloride (mg/L)";
export const Sulfate = "Sulfate (mg/L)";
export const TSS = "TSS (mg/L)";
export const Ammonia = "Ammonia as N (mg/L)";
export const Nitrate = "Nitrate as N (mg/L)";
export const Nitrite = "Nitrite as N (mg/L)";
export const NitrogenTotal = "Nitrogen Total (mg/L)";
export const OrthoPhosphate = "OrthoPhosphate as P (mg/L)";
export const Phosphorus = "Phosphorus as P (mg/L)";
export const DissolvedOrganicCarbon = "Dissolved Organic Carbon (mg/L)";
export const TotalOrganicCarbon = "Total Organic Carbon (mg/L)";
export const AFDM = "AFDM (mg/cm2)";
export const Chla = "Chl-a (ug/cm2)";
export const Arsenic = "Arsenic (ug/L)";
export const Cadmium = "Cadmium (ug/L)";
export const Chromium = "Chromium (ug/L)";
export const Copper = "Copper (ug/L)";
export const Iron = "Iron (ug/L)";
export const Lead = "Lead (ug/L)";
export const Mercury = "Mercury (ug/L)";
export const Nickel = "Nickel (ug/L)";
export const Selenium = "Selenium (ug/L)";
export const Zinc = "Zinc (ug/L)";
export const PouR = "Protecting Our River";
export const LARWMP = "Los Angeles River Watershed Monitoring Program (2018)";

export const biodiversity = {
  eDNA: "eDNA",
  iNaturalist: "iNaturalist",
  eBird: "eBird",
};

// export const allLayers = {
//   ...locations,
//   ...benthicMacroinvertebrates,
//   ...attachedAlgae,
//   ...riparianHabitatScore,
//   ...inSituMeasurements,
//   ...generalChemistry,
//   ...nutrients,
//   ...algalBiomass,
//   ...dissolvedMetals,
// };

export const locations = {
  [PouR]: `Protecting our River is collecting eDNA from sediment and water
  samples at 12 locations along the LA River and its tributaries in three
  separate rounds.`,
  [LARWMP]: `"The Los Angeles River Watershed Monitoring Program conducts annual
  assessments to better understand the health of a dynamic and predominantly
  urban watershed. The guiding questions and corresponding monitoring framework
  of the LARWMP provide both the public and resource managers with an
  improved understanding of conditions and trends in the watershed."
  - Los Angeles River Watershed Monitoring Program 2018 Annual Report`,
};

export const benthicMacroinvertebrates = {
  [CSCI]: null,
  [MMI]: null,
  [OE]: null,
};

export const attachedAlgae = {
  [D18]: null,
  [S2]: null,
};

export const riparianHabitatScore = {
  [CRAM]: null,
  [BioticStructure]: null,
  [Buffer]: null,
  [Hydrology]: null,
  [PhysicalStructure]: null,
};

export const inSituMeasurements = {
  [Temperature]: null,
  [Oxygen]: null,
  [pH]: null,
  [Salinity]: null,
  [SpecificConductivity]: null,
};

export const generalChemistry = {
  [Alkalinity]: null,
  [Hardness]: null,
  [Chloride]: null,
  [Sulfate]: null,
  [TSS]: null,
};

export const nutrients = {
  [Ammonia]: null,
  [Nitrate]: null,
  [Nitrite]: null,
  [NitrogenTotal]: null,
  [OrthoPhosphate]: null,
  [Phosphorus]: null,
  [DissolvedOrganicCarbon]: null,
  [TotalOrganicCarbon]: null,
};

export const algalBiomass = {
  [AFDM]: null,
  [Chla]: null,
};

export const dissolvedMetals = {
  [Arsenic]: null,
  [Cadmium]: null,
  [Chromium]: null,
  [Copper]: null,
  [Iron]: null,
  [Lead]: null,
  [Mercury]: null,
  [Nickel]: null,
  [Selenium]: null,
  [Zinc]: null,
};

export const legends = {
  [CSCI]: "/data/river_explorer/legend/na.png",
  [MMI]: "/data/river_explorer/legend/na.png",
  [OE]: "/data/river_explorer/legend/na.png",
  [D18]: "/data/river_explorer/legend/na.png",
  [S2]: "/data/river_explorer/legend/na.png",
  [CRAM]: "/data/river_explorer/legend/na.png",
  [BioticStructure]: "/data/river_explorer/legend/na.png",
  [Buffer]: "/data/river_explorer/legend/na.png",
  [Hydrology]: "/data/river_explorer/legend/na.png",
  [PhysicalStructure]: "/data/river_explorer/legend/na.png",
  [Temperature]: "/data/river_explorer/legend/Temperature.png",
  [Oxygen]: "/data/river_explorer/legend/DissolvedOxygen.png",
  [pH]: "/data/river_explorer/legend/pH.png",
  [Salinity]: "/data/river_explorer/legend/Salinity.png",
  [SpecificConductivity]:
    "/data/river_explorer/legend/SpecificConductivity.png",
  [Alkalinity]: "/data/river_explorer/legend/na.png",
  [Hardness]: "/data/river_explorer/legend/na.png",
  [Chloride]: "/data/river_explorer/legend/na.png",
  [Sulfate]: "/data/river_explorer/legend/na.png",
  [TSS]: "/data/river_explorer/legend/na.png",
  [Ammonia]: "/data/river_explorer/legend/na.png",
  [Nitrate]: "/data/river_explorer/legend/na.png",
  [Nitrite]: "/data/river_explorer/legend/na.png",
  [NitrogenTotal]: "/data/river_explorer/legend/na.png",
  [OrthoPhosphate]: "/data/river_explorer/legend/na.png",
  [Phosphorus]: "/data/river_explorer/legend/na.png",
  [DissolvedOrganicCarbon]: "/data/river_explorer/legend/na.png",
  [TotalOrganicCarbon]: "/data/river_explorer/legend/na.png",
  [AFDM]: "/data/river_explorer/legend/na.png",
  [Chla]: "/data/river_explorer/legend/na.png",
  [Arsenic]: "/data/river_explorer/legend/na.png",
  [Cadmium]: "/data/river_explorer/legend/na.png",
  [Chromium]: "/data/river_explorer/legend/na.png",
  [Copper]: "/data/river_explorer/legend/na.png",
  [Iron]: "/data/river_explorer/legend/na.png",
  [Lead]: "/data/river_explorer/legend/na.png",
  [Mercury]: "/data/river_explorer/legend/na.png",
  [Nickel]: "/data/river_explorer/legend/na.png",
  [Selenium]: "/data/river_explorer/legend/na.png",
  [Zinc]: "/data/river_explorer/legend/na.png",
};
