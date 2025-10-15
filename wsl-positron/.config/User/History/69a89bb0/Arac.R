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

  'bmxwt', 'Weight (kg)',
  'bmxht', 'Standing Height (cm)',
  'bmxbmi', 'Body Mass Index (kg/m^2)',
  'bmxwaist', 'Waist Circumference (cm)',
  'waist_height_ratio', 'Waist-to-Height Ratio (calculated)',

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
