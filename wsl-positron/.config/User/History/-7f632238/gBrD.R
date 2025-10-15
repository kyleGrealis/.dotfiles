load('data/study_data.rda')


# https://stats.oarc.ucla.edu/r/seminars/survey-data-analysis-with-r/
# corresponding code: https://stats.oarc.ucla.edu/wp-content/uploads/2020/08/code_for_webpage.r
# Create a baic survey design object based on reference above.

nh <- svydesign(
  ids = ~sdmvpsu,           # Primary sampling units
  strata = ~sdmvstra,       # Strata
  weights = ~wtmec2yr,      # MEC exam weights (use this for physical measurements)
  nest = TRUE,
  data = the_data
)

svymean(~ridageyr, nh)
svyquantile(~ridageyr, nh)

# See the counts applied properly vs raw data
svytable(~use_category, nh)
# versus
tabyl(the_data, use_category)

# Create table of the mean age by sex
svyby(~ridageyr, ~riagendr, nh, svymean)
#        riagendr ridageyr     se
# Female   Female    50.95 0.1682
# Male       Male    50.23 0.2070
# Create the same table and include ever_use_marijuana (use x + y syntax)
svyby(~ridageyr, ~riagendr + ever_use_marijuana, nh, svymean)