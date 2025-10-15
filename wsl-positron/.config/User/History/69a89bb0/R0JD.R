# Create a data dictionary for project variables.
# NOTE: uncomment last line to update the Excel file

dictionary <- tibble::tribble(
  ~Variable, ~Description,
  'year', 'Year',
  'seqn', 'Participant ID',
  
  # Survey weights:
  'wtmec2yr', 'Full sample 2-year MEC exam weight',
  'survey_weights_mec', 'Survey weights',
  'wtint2yr', 'Full sample 2-year interview weight',
  'survey_weight_int', 'Survey weights (interview)',
  'sdmvpsu', 'Masked variance pseudo-PSU',
  'smvstra', 'Masked variance pseudo-stratum',

  # Demographics:
  'riagendr', 'Sex',
  'ridageyr', 'Age in years at screening',
  'ridreth1', 'Race/Hispanic origin',
  'ridreth3', 'Race/Hispanic origin w/ NH Asian',
  'dmdeduc2', 'Education level - Adults 20+',
  'indhhin2', 'Annual household income',

  # KDM Biological Age Variables:
  'kdm_bioage', 'Calculated biological age using KDM',
  'kdb_advance', 'Biological age advancement (bioage - chronological age)',

  # Derived biomarkers (KDM implementation):
  'nonhdl', 'Non-HDL cholesterol (mg/dL)',
  'pp', 'Pulse pressure',
  'acr', 'Albumin-to-creatinine ratio',
  'alt', 'Liver function biomarker (proxy using GGT)',
  'meanbp', 'Mean blood pressure',
  'pulse', 'Arterial stiffness (alternative blood pressure)',
  'fev1_1000', 'FEV1 (L)',
  'albumin_gL', 'Albumin (g/L)',
  'lnalp', 'Log-transformed ALP',
  'lnbun', 'Log-transformed BUN',
  'creat_umol', 'Creatinine (μmol/L)',
  'lncreat', 'Log-transformed creatinine',
  'lncreat_umol', 'Log-transformed creatinine (μmol/L)',
  'glucose_mmol', 'Glucose (mmol/L)',
  'lnuap', 'Log-transformed uric acid',
  'crp_cat', 'CRP categories',
  'lncrp', 'Log-transformed CRP',
  'lnhba1c', 'Log-transformed HbA1c',
  'grip_scaled', 'Scaled grip strength',
  'lnwalk', 'Log-transformed walking speed',

  # Substance use variables
  'duq200', '',
  'duq210', '',
  'duq211', '',
  'duq213', '',
  'duq215q', '',
  'duq215u', '',
  'duq217', '',
  'duq219', '',
  'duq220q', '',
  'duq220u', '',
  'duq230', '',
  'duq240', '',
  'duq250', '',
  'duq260', '',
  'duq270q', '',
  'duq270u', '',
  'duq272', '',
  'duq280', '',
  'duq290', '',
  'duq300', '',
  'duq310q', '',
  'duq310u', '',
  'duq320', '',
  'duq330', '',
  'duq340', '',
  'duq350q', '',
  'duq350u', '',
  'duq352', '',
  'duq360', '',
  'duq370', '',
  'duq380a', '',
  'duq380b', '',
  'duq380c', '',
  'duq380d', '',
  'duq380e', '',
  'duq390', '',
  'duq400q', '',
  'duq400u', '',
  'duq410', '',
  'duq420', '',
  'duq430' '',

)

# Output document
writexl::write_xlsx(dictionary, path = 'data/data_dictionary.xlsx')
