load('data/study_data.rda')


# https://stats.oarc.ucla.edu/r/seminars/survey-data-analysis-with-r/
# corresponding code: https://stats.oarc.ucla.edu/wp-content/uploads/2020/08/code_for_webpage.r
# Create a baic survey design object based on reference above.

nhanes_design <- svydesign(
  ids = ~sdmvpsu,           # Primary sampling units
  strata = ~sdmvstra,       # Strata
  weights = ~wtmec2yr,      # MEC exam weights (use this for physical measurements)
  nest = TRUE,
  data = the_data
)
