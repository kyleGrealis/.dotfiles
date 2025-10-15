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
  'duq200', 'Ever used marijuana or hashish',
  'duq210', 'Age when first tried marijuana',
  'duq211', 'Used marijuana every month for a year?',
  'duq213', ' Age started regularly using marijuana',
  'duq215q', 'Time since last used marijuana regularly',
  'duq215u', 'Time since used marijuana regularly/unit',
  'duq217', 'How often would you use marijuana?',
  'duq219', 'How many joints or pipes smoke in a day?',
  'duq220q', 'How long has it been since you last used marijuana or hashish?',
  'duq220u', 'How long has it been since you last used marijuana or hashish?',
  'duq230', 'During the past 30 days, how many days did you use marijuana or hashish?',

  'duq240', ' Ever used cocaine/heroin/methamphetamine',
  'duq250', 'Ever use any form of cocaine',
  'duq260', ' Age first used cocaine',
  'duq270q', 'Last time used cocaine, in any form',
  'duq270u', ' Last time used cocaine/unit',
  'duq272', 'Number of times used cocaine (lifetime)',
  'duq280', 'Number of days used cocaine/month',

  'duq290', 'Ever used heroin',
  'duq300', 'Age first used heroin',
  'duq310q', 'How long has it been since you last used heroin?',
  'duq310u', 'How long has it been since you last used heroin?',
  'duq320', 'During the past 30 days, on how many days did you use heroin?',

  'duq330', ' Ever used methamphetamine',
  'duq340', 'Age first used methamphetamine',
  'duq350q', 'How long has it been since you last used methamphetamine?',
  'duq350u', 'How long has it been since you last used methamphetamine?',
  'duq352', 'Number of times used methamphetamine (lifetime)',
  'duq360', 'During the past 30 days, on how many days did you use methamphetamine?',

  'duq370', 'Ever use a needle to inject illegal drug',
  'duq380a', 'Drugs injected - Cocaine',
  'duq380b', 'Drugs injected - Heroin',
  'duq380c', 'Drugs injected - Methamphetamine',
  'duq380d', 'Drugs injected - Steroids',
  'duq380e', 'Drugs injected - Any other drugs',
  'duq390', 'Age first injected drugs',
  'duq400q', 'How long ago has it been since you last used a needle to inject a drug not prescribed by a doctor?',
  'duq400u', 'How long ago has it been since you last used a needle to inject a drug not prescribed by a doctor?',
  'duq410', 'Number of times injected drugs (lifetime)',
  'duq420', 'How often did you inject drugs?',
  'duq430', 'Ever been in rehabilitation program?',

  'ever_use_marijuana', 'Ever used marijuana or hashish',
  'use_category', 'Marijuana use category'

)

# Output document
writexl::write_xlsx(dictionary, path = 'data/data_dictionary.xlsx')
