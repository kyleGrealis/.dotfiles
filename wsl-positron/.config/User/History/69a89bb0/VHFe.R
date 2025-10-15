# Create a data dictionary for project variables.
# NOTE: uncomment last line to update the Excel file

dictionary <- tibble::tribble(
  ~Variable, ~Description,
  'year', 'Year',
  'seqn', 'Participant ID',
  
  'wtmec2yr', 'Full sample 2-year MEC exam weight',
  'survey_weights_mec', 'Survey weights',
  'wtint2yr', 'Full sample 2-year interview weight',
  'survey_weight_int', 'Survey weights (interview)',
  'sdmvpsu', 'Masked variance pseudo-PSU',
  'smvstra', 'Masked variance pseudo-stratum',

  'riagendr', 'Sex',
  'ridageyr', 'Age in years at screening',
  'ridreth1', 'Race/Hispanic origin',
  'ridreth3', 'Race/Hispanic origin w/ NH Asian',
  'dmdeduc2', 'Education level - Adults 20+',
  'indhhin2', 'Annual household income',

  # KDM Biological Age Variables
  'kdm_bioage', 'Calculated biological age using KDM',
  'kdb_advance', 'Biological age advancement (bioage - chronological age)',

  # Derived biomarkers (KDM implementation)
  'nonhdl', 'Non-HDL cholesterol',
  'pp', 'Pulse pressure',
  'acr', 'Albumin-to-creatinine ratio',
  'alt', 'Liver function biomarker (proxy using GGT)',

  'meanbp', 'Mean blood pressure',
  'pulse', 'Arterial stiffness (alternative blood pressure)',
  'fev1_1000', 'FEV1 (L)',
  'albumin_gL', 'Albumin (g/L)',
  'lnalp', 'Log-transformed ALP',
  'lnbun', 'Log-transformed BUN',
  'creat_umol', 'Creatinine in μmol/L',
  'lncreat', 'Log-transformed creatinine',
  'lncreat_umol', 'Log-transformed creatinine (μmol/L)',
  'glucose_mmol', 'Glucose in mmol/L',
  'lnuap', 'Log-transformed uric acid',
  'crp_cat', 'CRP categories',
  'lncrp', 'Log-transformed CRP',
  'lnhba1c', 'Log-transformed HbA1c',
  'grip_scaled', 'Scaled grip strength',
  'lnwalk', 'Log-transformed walking speed',

  'lbxgh', 'HbA1c %',  # Glycohemoglobin %
  'lbxtr', 'Triglycerides (mg/dL)',
  'lbdldl', 'LDL Cholesterol (mg/dL)',
  'lbxtc', 'Total Cholesterol (mg/dL)',
  'lbdhdd', 'HDL Cholesterol (mg/dL)',
  'lbxglu', 'Fasting Glucose (mg/dL)',

  'mean_sbp', 'Systolic BP (mean)',
  'mean_dbp', 'Diastolyic BP (mean)',

)

# Output document
writexl::write_xlsx(dictionary, path = 'data/data_dictionary.xlsx')
