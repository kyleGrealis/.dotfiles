subjects <-
  randomization |>
  filter(which == 1) |>
  inner_join(everybody, by = "who") |>
  rename(rand_date = when) |>
  select(project, who, treatment, rand_date) |>
  mutate(
    medication =
      case_when(
        treatment == "Inpatient BUP" ~ "Buprenorphine",
        treatment == "Inpatient NR-NTX" ~ "Naltrexone",
        treatment == "Methadone" ~ "Methadone",
        treatment == "Outpatient BUP" ~ "Buprenorphine",
        treatment == "Outpatient BUP + EMM" ~ "Buprenorphine",
        treatment == "Outpatient BUP + SMM" ~ "Buprenorphine"
      ),
    medication = factor(medication),
    in_out = case_when(
      treatment == "Inpatient BUP" ~ "Inpatient",
      treatment == "Inpatient NR-NTX" ~ "Inpatient",
      treatment == "Methadone" ~ "Outpatient",
      treatment == "Outpatient BUP" ~ "Outpatient",
      treatment == "Outpatient BUP + EMM" ~ "Outpatient",
      treatment == "Outpatient BUP + SMM" ~ "Outpatient"
    ),
    in_out = factor(in_out)
  )

# asi -----
# I should use the indicator of who was injecting drugs: `used_iv`.
analysis <-
  left_join(subjects, asi, by = "who")
rm(subjects)

# demographics -----
# Use all demographic features
analysis <-
  left_join(analysis, demographics, by = "who") |>
  mutate(
    education =
      str_replace_all(education, stringr::fixed("/"), " or ") |>
        as.factor()
  ) |>
  mutate(
    education = if_else(
      education == "Refused/Missing", NA_character_, as.character(education)
    ),
    education = factor(education)
  ) |>
  mutate(
    job = if_else(
      job == "Refused/Missing", NA_character_, as.character(job)
    ),
    job = factor(job)
  ) |>
  mutate(
    marital = if_else(
      marital == "Refused/Missing", NA_character_, as.character(marital)
    ),
    marital = factor(marital)
  )

# fagerstrom -----
# Use all smoking features
analysis <-
  left_join(analysis, fagerstrom, by = "who") |>
  mutate(
    per_day =
      str_replace_all(per_day, stringr::fixed("-"), " TO "),
    per_day = if_else(per_day == "", "0", per_day),
    per_day = fct(
      per_day,
      levels = c("0", "10 OR LESS", "11 TO 20", "21 TO 30", "31 OR MORE")
    ),
    per_day = ordered(per_day)
  )


# pain -----
# select pain closest to randomization
pain <-
  public.ctn0094data::pain |>
  group_by(who) |>
  mutate(absolute = abs(when)) |>
  arrange(absolute) |>
  filter(row_number() == 1) |>
  filter(absolute <= 28) |>
  select(who, pain)

analysis <-
  left_join(analysis, pain, by = "who")
rm(pain)


# psychiatric -----
# Include psych conditions, brain damage, epilepsy, and drug use diagnoses

# self report or MD report is called yes, any no is next, otherwise unknown
either <- function(x1, x2) {
  answer <-
    case_when(
      x1 == "Yes" | x2 == "Yes" ~ "Yes",
      x1 == "No" & x2 == "No" ~ "No",
      TRUE ~ "Unknown"
    )
  factor(answer)
}

psychiatric <-
  public.ctn0094data::psychiatric |>
  mutate(any_schiz = either(has_schizophrenia, schizophrenia)) |>
  mutate(any_dep = either(has_major_dep, depression)) |>
  mutate(any_anx = either(has_anx_pan, anxiety)) |>
  select(
    c(
      who,
      any_schiz, any_dep, any_anx, has_bipolar, has_brain_damage, has_epilepsy,
      # has_opiates_dx, useless for modeling
      has_alcol_dx, has_amphetamines_dx, has_cannabis_dx,
      has_cocaine_dx, has_sedatives_dx
    )
  )

analysis <-
  left_join(analysis, psychiatric, by = "who")
rm(either, psychiatric)

# qol ----
# homelessness
analysis <-
  left_join(analysis, qol, by = "who")

# rbs ----
# rbs use info
rbs <-
  public.ctn0094data::rbs |>
  mutate(
    days =
      if_else(
        is.na(days) & did_use == "No", 0, days
      )
  ) |>
  pivot_wider(names_from = "what", values_from = c("did_use", days))


analysis <-
  left_join(analysis, rbs, by = "who")
rm(rbs)

# rbs_iv -----
# amount of IV drug use and needle sharing
rbs_iv <-
  public.ctn0094data::rbs_iv |>
  rename(
    days_iv_use = days,
    max_iv_use = max
  ) |>
  select(
    who, days_iv_use, max_iv_use, amount, shared, cocaine_inject_days,
    heroin_inject_days, speedball_inject_days, opioid_inject_days,
    speed_inject_days
  )

analysis <-
  left_join(analysis, rbs_iv, by = "who")
rm(rbs_iv)

# sex -----
# total partners
sex <-
  public.ctn0094data::sex |>
  rename(sex_partners = t_p) |>
  select(who, sex_partners)

analysis <-
  left_join(analysis, sex, by = "who")
rm(sex)


# site -----
analysis <-
  # left_join(analysis, public.ctn0094data::site_masked, by = "who")
  # swapping public.ctn0094data with code used to redo site_masked from code_with_notes.R
  left_join(analysis, site_masked, by = "who")


# tlfb -----
# how many days of use and what drugs
tlfb <-
  public.ctn0094data::tlfb |>
  group_by(who) |>
  filter(when > -29 & when < 0)

tlfb_days_of_use <-
  tlfb |>
  select(who, when) |>
  distinct() |>
  summarise(tlfb_days_of_use_n = n())

tlfb_what_used <-
  tlfb |>
  select(who, what) |>
  distinct() |>
  summarise(tlfb_what_used_n = n())

analysis <-
  left_join(analysis, tlfb_days_of_use, by = "who") |>
  left_join(tlfb_what_used, by = "who")
rm(tlfb, tlfb_days_of_use, tlfb_what_used)

# withdrawal -----
# select withdrawal closest to randomization
withdrawal <-
  public.ctn0094data::withdrawal |>
  group_by(who) |>
  mutate(absolute = abs(when)) |>
  arrange(absolute) |>
  filter(row_number() == 1) |>
  filter(absolute <= 28) |>
  select(who, withdrawal)

analysis <-
  left_join(analysis, withdrawal, by = "who")
rm(withdrawal)

detox <-
  public.ctn0094data::detox |>
  arrange(who, when) |>
  group_by(who) |>
  summarise(detox_days = last(when) - first(when)) |>
  ungroup()

analysis <-
  left_join(analysis, detox, by = "who") |>
  mutate(
    detox_days = 
      if_else(
        is.na(detox_days), 
        runif(nrow(analysis), min = -0.001, max = 0.001), 
        detox_days
      )
  )
# from sensitivity analysis - do not delete
# mutate(
#  detox_days = 
#    if_else(is.na(detox_days), rpois(nrow(analysis), lambda = 5), detox_days))

# data from Dr Pan
latent_class <- 
  read_rds("data/public_polysubstane_group.rds")

almost_analysis <-
  analysis |>
  mutate(
    x = case_when(
      project == "27" ~ "CTN-0027",
      project == "30" ~ "CTN-0030",
      project == "51" ~ "CTN-0051"
    )
  ) |>
  mutate(`CTN Trial Number` = factor(x)) |>
  select(-x) |>
  inner_join(latent_class, by = "who")


# this is Ray's variables with or without latent class
analysis <- 
  almost_analysis |>
  rename(trial = `CTN Trial Number`) |>
  select(
    who,
    # basics
    trial, medication, in_out,
    # asi
    used_iv,
    # demographics
    age, race, is_hispanic, job, is_living_stable, education, marital, is_male,
    # fagerstrom
    is_smoker, per_day, ftnd,
    # pain
    pain,
    # psychiatric
    any_schiz, any_dep, any_anx, has_bipolar, has_brain_damage, has_epilepsy,
    has_alcol_dx, has_amphetamines_dx, has_cannabis_dx,
    has_cocaine_dx, has_sedatives_dx,
    # qol
    is_homeless,
    # rbs
    did_use_cocaine, did_use_heroin, did_use_speedball,
    did_use_opioid, did_use_speed, days_cocaine, days_heroin,
    days_speedball, days_opioid, days_speed,
    # rbs_iv
    days_iv_use, shared,
    # not in kyles variables - medication is also extra - he had who and treatment
    # max_iv_use,  amount, cocaine_inject_days,
    # heroin_inject_days, speedball_inject_days, opioid_inject_days,
    # speed_inject_days,
    # sex
    # sex_partners, # see if DALEX will work if this is dropped
    # tlfb
    tlfb_days_of_use_n, tlfb_what_used_n,
    # withdrawal
    withdrawal,
    # detox
    detox_days,
    # latent class
    # group, # dont use latent clas groups
    # site
    site_masked
  )

# analysis <- analysis |> select(1:45)

outcome <- 
  public.ctn0094extra::derived_weeklyOpioidPattern |>
  mutate(use_pattern_uds = paste0(Phase_1, Phase_2)) |>
  rowwise() |>
  mutate(
    udsPattern = recode_missing_visits(
      use_pattern = use_pattern_uds
    )
  ) |>
  mutate(
    udsPattern = recode_missing_visits(
      use_pattern = udsPattern,
      missing_is = "*"
    )
  ) |>
  mutate(
    udsPatternTrimmed = str_sub(udsPattern, start = 3L)
  ) |>
  rowwise() |>
  mutate(
    lee2018_rel = detect_in_window(
      use_pattern = udsPatternTrimmed,
      window_width = 4L,
      threshold = 4L
    )
  ) |>
  unnest(cols = "lee2018_rel", names_sep = "_") |>
  mutate(lee2018_rel_time = lee2018_rel_time + 2) |>
  select(who, starts_with("lee2018_rel")) |>
  rename(
    RsT_ctnFiftyOne_2018 = lee2018_rel_time,
    RsE_ctnFiftyOne_2018 = lee2018_rel_event
  ) |>
  transmute(
    who,
    did_relapse = factor(RsE_ctnFiftyOne_2018, levels = c("0", "1"))
  )

analysis <- 
  inner_join(analysis, outcome, by = "who") |>
  select(-who)

write_rds(analysis, "data/analysis.rds")

final_analysis <- 
  analysis
write_rds(final_analysis, "data/final_analysis.rds")

####


# set to subset or subset_not_used
# uses latent class variables instead of history

# use this version to use latent class instead of my preprocessing
analysis2 <- 
  almost_analysis |>
  select(
    -contains("did_use"), -contains("tlfb"), -contains("_iv"),
    -c(
      days_cocaine, days_heroin, days_speedball, days_opioid, days_speed,
      days_iv_use, cocaine_inject_days, heroin_inject_days,
      speedball_inject_days, opioid_inject_days, speed_inject_days, 
      tlfb_days_of_use_n
    )
  )
write_rds(analysis2, "data/analysis2.rds")


alternative_analysis <- 
  analysis2 |>
  rename(trial = `CTN Trial Number`) |>
  select(
    # who, # removed because DALEXtra::explain_tidymodels uses who as predictor
    # basics
    trial, treatment, in_out,
    # asi
    # used_iv,
    # demographics
    age, race, is_hispanic, job, is_living_stable, education, marital, is_male,
    # fagerstrom
    is_smoker, per_day, ftnd,
    # pain
    pain,
    # psychiatric
    any_schiz, any_dep, any_anx, has_bipolar, has_brain_damage, has_epilepsy,
    has_alcol_dx, has_amphetamines_dx, has_cannabis_dx,
    has_cocaine_dx, has_sedatives_dx,
    # qol
    is_homeless,
    # rbs
    # did_use_cocaine, did_use_heroin, did_use_speedball,
    # did_use_opioid, did_use_speed, days_cocaine, days_heroin,
    # days_speedball, days_opioid, days_speed,
    # rbs_iv
    # days_iv_use, shared,
    # sex
    sex_partners,
    # tlfb
    # tlfb_days_of_use_n, tlfb_what_used_n,
    # withdrawal
    withdrawal,
    # detox
    detox_days,
    # latent class
    group
  )

check_exclusion <- 
  analysis |>
  select(
    contains("days"), contains("did_use"), contains("tlfb"), contains("_iv")
  )

suppressMessages(conflict_prefer("col_factor", "readr"))
