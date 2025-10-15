# Create a data dictionary for project variables.
# NOTE: uncomment last line to update the Excel file

dictionary <- tibble::tribble(
  ~Variable, ~Description,
  'year', 'Year',
  'seqn', 'Participant ID',
  
  'wtmec2yr', 'Full sample 2-year MEC exam weight',
  'wtint2yr', 'Full sample 2-year interview weight',
  'sdmvpsu', 'Masked variance pseudo-PSU',
  'smvstra', 'Masked variance pseudo-stratum',

  'riagendr', 'Sex',
  'ridageyr', 'Age in years at screening',
  'ridreth1', 'Race/Hispanic origin',
  'ridreth3', 'Race/Hispanic origin w/ NH Asian',
  'dmdeduc2', 'Education level - Adults 20+',
  'indhhin2', 'Annual household income',

  'diq010', 'Doctor told you have diabetes',
  'did040', 'Age when first told you had diabetes',
  'diq160', 'Ever told you have prediabetes',
  'diq050', 'Taking insulin now',
  'did060', 'How long taking insulin',
  'diq060u', 'How long taking insulin (units)',
  'diq070', 'Take diabetic pills to lower blood sugar',
  'diab_duration', 'Duration of Diabetes diagnosis',
  'how_long_taking_insulin_yrs', 'How long taking insulin (yrs)',
  'time_to_insulin', 'Time from diagnosis to starting insulin (yrs)',
  'insulin_within_1yr', 'Started taking insulin within 1 yr',

  'bmxwt', 'Weight (kg)',
  'bmxht', 'Standing Height (cm)',
  'bmxbmi', 'Body Mass Index (kg/m^2)',
  'bmxwaist', 'Waist Circumference (cm)',
  'waist_height_ratio', 'Waist-to-Height Ratio (calculated)',

  'dxdlapf', 'Left Arm (%)',
  'dxdllpf', 'Left Leg (%)',
  'dxdrapf', 'Right Arm (%)',
  'dxdrlpf', 'Right Leg (%)',
  'dxdtrpf', 'Trunk (%)',
  'dxdstpf', 'Subtotal (%)',
  'dxdtopf', 'Body Fat (%)',
  'dxdtofat', 'Total Fat (g)',

  'dxxanfm', 'Android fat mass',
  'dxxanlm', 'Android lean mass',
  'dxxgyfm', 'Gynoid fat mass',
  'dxxgylm', 'Gynoid lean mass',
  'dxxagrat', 'Android to Gynoid ratio',
  'dxxsatm', 'Subcutaneous fat mass',
  'dxxtatm', 'Total abdominal fat mass',
  'dxxvfatm', 'Visceral adipose tissue mass',

  'lbxgh', 'HbA1c %',  # Glycohemoglobin %
  'lbxtr', 'Triglycerides (mg/dL)',
  'lbdldl', 'LDL Cholesterol (mg/dL)',
  'lbxtc', 'Total Cholesterol (mg/dL)',
  'lbdhdd', 'HDL Cholesterol (mg/dL)',
  'lbxglu', 'Fasting Glucose (mg/dL)',

  'mean_sbp', 'Systolic BP (mean)',
  'mean_dbp', 'Diastolyic BP (mean)',

  # Variables used in the sensitivity analysis:
  'did040g', 'Age when first told you had diabetes',
  'did040q', 'Number of years of age',
  'did060g', 'How long taking insulin',
  'did060q', 'Number of mos/yrs taking insulin',
  'did060u', 'Unit of measure (month/year)',  # 1=months; 2=years
  'lbxcpsi', 'C-Peptide'
)

# Output document
# writexl::write_xlsx(dictionary, path = 'data/data_dictionary.xlsx')
