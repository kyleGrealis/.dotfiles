library(ggconsort)
library(ggtext)
load('data/sensitivity.rds')
load('data/the_data.rda')

######################################################################################
# There are minor differences in variable names from the sensitivity cohort and the
# recent cohort 2011-2022:
# did040g does not exist in "the_data"; using is.na(did040) in its place
######################################################################################

nhanes_consort <- function(func_data, time) {

  study_cohorts <- func_data |> 
  filter(ridageyr >= 16) |> 
  cohort_start('Assessed for eligibility') |> 
  # Define cohorts ----
  cohort_define(

    # Step 0a: valid prior diagnosis of diabetes
    step_0a = .full |> filter(diq010 == 'Yes'),
    step_0a_excl = anti_join(.full, step_0a, by = 'seqn'),
    # Step 0b: valid reported age at diabetes diagnosis
      
    ################################################################################
    # This section evaluates if the variable is found in the dataset and adjusts
    # the consort definition accordingly.
    ################################################################################
    step_0b = if('did040g' %in% names(step_0a)) {
      step_0a |> filter(did040g %in% c('Enter number', 'Less than 1 year'))
    } else {
      step_0a |> filter(!is.na(did040))
    },

    step_0b_excl = anti_join(step_0a, step_0b, by = 'seqn'),
    # Step 0c
    step_0c = step_0b |> filter(!is.na(diab_duration)),
    step_0c_excl = anti_join(step_0b, step_0c, by = 'seqn'),

    # Step 1a: taking insulin now
    step_1a = step_0c |> 
      filter(!diq050 %in% c("Don't know", 'Refused') |
        !diq070 %in% c("Don't know", 'Refused') |
        !diq160 %in% c("Don't know", 'Refused')),
      # mutate(
      #   # Standardize -- Convert number of months taking insulin to years:
      #   # diq060u: Months or Years or NA
      #   # diq060q: Numeric duration
      #   yrs_using_insulin = if('diq060u' %in% names(step_0c)) {
      #     case_when(
      #       diq060u == 'Months' ~ did060q / 12,
      #       .default = did060q
      #     )
      #   } else {
      #     did060
      #   },
      #   # Flag those where their insulin treatment period exceeds their diab_duration
      #   flag_duration = case_when(
      #     yrs_using_insulin > diab_duration ~ 'Remove', 
      #     is.na(yrs_using_insulin) ~ 'Keep',  # these are ok to keep
      #     .default = 'Keep'
      #   )
      # ) |> 
      # # Only keep those who knew yes/no that they were on insulin
      # filter(diq050 %in% c('Yes', 'No')),
      
    step_1a_excl = anti_join(step_0c, step_1a, by = 'seqn'),
    # Step 1b: report using insulin longer than diabetes duration
    step_1b = step_1a |> 
      mutate(
        # Standardize -- Convert number of months taking insulin to years:
        # diq060u: Months or Years or NA
        # diq060q: Numeric duration
        yrs_using_insulin = if('diq060u' %in% names(step_0c)) {
          case_when(
            diq060u == 'Months' ~ did060q / 12,
            .default = did060q
          )
        } else {
          did060
        },
        # Flag those where their insulin treatment period exceeds their diab_duration
        flag_duration = case_when(
          yrs_using_insulin > diab_duration ~ 'Remove', 
          is.na(yrs_using_insulin) ~ 'Keep',  # these are ok to keep
          .default = 'Keep'
        )
      ) |> 
      filter(flag_duration != 'Remove'),
    step_1b_excl = anti_join(step_1a, step_1b, by = 'seqn'),
    # Step 1c: take diabetic pills to lower blood sugar
    # step_1_continue = step_1b |> filter(diq070 %in% c('Yes', 'No')),
    step_1_continue = step_1b,
    step_1c_excl = anti_join(step_1b, step_1_continue, by = 'seqn'),
    # END OF STEP 1
    # NOTE: step_1_continue (N=1049) -- matches main sensitivity analysis

    # Step 2: currently taking medication for diabetes
    step_2 = step_1_continue |> 
      # "neither currently taking insulin nor an oral hypoglycemic agent..."
      filter(diq050 == 'No', diq070 == 'No'),
    # Identified in this step as Type 2 DM
    step_2_continue = anti_join(step_1_continue, step_2, by = 'seqn'),
    # END OF STEP 2
    # NOTE: step_2 (172) matches same number identifed in sensitivity analysis

    # Step 3: currently takes insulin
    step_3 = step_2_continue |> 
      filter(diq050 == 'No'),
    step_3_continue = anti_join(step_2_continue, step_3, by = 'seqn'),
    # END OF STEP 3
    # NOTE: step_3 (620) matches same number identifed in sensitivity analysis

    # Step 4: currently takes *only* insulin
    step_4 = step_3_continue |> 
      filter(diq050 == 'Yes', diq070 == 'Yes'),
    step_4_continue = anti_join(step_3_continue, step_4, by = 'seqn'),
    # END OF STEP 4
    # NOTE: step_4 (104) matches same number identifed in sensitivity analysis

    step_5 = step_4_continue |> 
      mutate(
        the_duration = diab_duration - yrs_using_insulin
      ) |> 
      filter(the_duration <= 1),
    step_5_end = anti_join(step_4_continue, step_5, by = 'seqn')

  ) |> 
  # Add labels for cohorts
  cohort_label(
    .full = glue::glue('<strong>NHANES<br>({time})</strong><br>'),
    step_0a_excl = 'Without valid prior diabetes diagnosis',
    step_0b_excl = 'Without valid reported age at diabetes diagnosis',
    step_0c_excl = 'Without valid duration of diabetes',
    step_0c = 'Participants with<br>diagnosed diabetes<br>',

    step_1a_excl = 'Did not have a reply for treatment questions',
    step_1b_excl = 'Reported using insulin longer than diabetes duration',
    step_1c_excl = 'Did not report "Yes" or "No" for taking diabetic pills',
    step_1_continue = 'Yes',

    step_2 = 'No<br>',
    step_2_continue = 'Yes',

    step_3 = 'No<br>',
    step_3_continue = 'Yes',

    step_4 = 'No<br>',
    step_4_continue = 'Yes',

    step_5 = '<strong>Type 1 DM</strong><br>',
    step_5_end = '<strong><i>Possible</i><br>Type 2 DM</strong><br>'
  )

# study_cohorts
# summary(study_cohorts) |> print(n=50)

total_t2dm <- 
  nrow(study_cohorts$data$step_2) +
  nrow(study_cohorts$data$step_3) +
  nrow(study_cohorts$data$step_4)

study_cohorts |> 
  consort_box_add(
    'full', 0, 120, 
    cohort_count_adorn(study_cohorts, .full)
  ) |> 
  consort_box_add(
    'exclusions_1', 3, 120, glue::glue(
    '<strong>Exclusions</strong> (part 1)<br>
    • {cohort_count_adorn(study_cohorts, step_0a_excl)}<br>
    • {cohort_count_adorn(study_cohorts, step_0b_excl)}<br>
    • {cohort_count_adorn(study_cohorts, step_0c_excl)} 
    ')
  ) |> 
  consort_arrow_add('full', 'right', 'exclusions_1', 'left') |> 
  
  # Met inclusion criteria
  consort_box_add(
    'step_0c', 0, 106,
    cohort_count_adorn(study_cohorts, step_0c)
  ) |> 
  consort_arrow_add('full', 'bottom', 'step_0c', 'top') |> 
  consort_box_add('enter', -7, 101, 'Met inclusion<br>criteria') |> 
  consort_line_add(start_x = 0, end_x = -7, start_y = 101, end_y = 101) |> 

  # Step 1 ----
  # adding this or else the arrow is diagonal and looks like crap
  consort_box_add('fudge_it', 0, 77, '') |> 
  
  consort_box_add('step_1', 0, 80, 'Step 1') |> 
  consort_arrow_add('step_0c', 'bottom', 'step_1', 'top') |> 
  consort_box_add(
    'step_1_box', -7, 77,
    '1: Has valid<br>diabetes-related<br>information'
  ) |> 
  consort_line_add(start_x = 0, end_x = -7, start_y = 77.5, end_y = 77.5) |> 
  # exclusions
  consort_box_add(
    'exclusions_2', 3, 77, glue::glue(
    '<strong>Exclusions</strong> (part 2)<br>
    • {cohort_count_adorn(study_cohorts, step_1a_excl)}<br>
    • {cohort_count_adorn(study_cohorts, step_1b_excl)}<br>
    • {cohort_count_adorn(study_cohorts, step_1c_excl)} 
    ')
  ) |> 
  consort_arrow_add('fudge_it', 'bottom', 'exclusions_2', 'left') |> 
  # continued
  consort_box_add(
    'step_1_yes', -2, 68,
    cohort_count_adorn(study_cohorts, step_1_continue)
  ) |> 
  consort_line_add(start_x = -2, start_y = 68, end_x = 0, end_y = 68) |> 
  
  # Step 2 ----
  consort_box_add('step_2', 0, 60, 'Step 2') |> 
  consort_arrow_add('step_1', 'bottom', 'step_2', 'top') |> 
  consort_box_add(
    'step_2_box', -7, 58,
    '2: Currently takes<br>medication for diabetes'
  ) |> 
  consort_box_add(
    'step_2_c', -2, 48,
    cohort_count_adorn(study_cohorts, step_2_continue)
  ) |> 
  consort_line_add(start_x = -2, start_y = 48, end_x = 0, end_y = 48) |>
  # Type 2 DM ----
  consort_box_add(
    'step_2dm', 4, 58,
    cohort_count_adorn(study_cohorts, step_2)
  ) |> 
  consort_line_add(start_x = -7, start_y = 58, end_x = 7, end_y = 58) |> 
  consort_line_add(start_x = 7, start_y = 58, end_x = 7, end_y = 38) |> 
   

  # Step 3 ----
  consort_box_add('step_3', 0, 40, 'Step 3') |> 
  consort_arrow_add('step_2', 'bottom', 'step_3', 'top') |> 
  consort_box_add(
    'step_3_box', -7, 38,
    '3: Currently takes<br>insulin'
  ) |> 
  consort_box_add(
    'step_3_c', -2, 28,
    cohort_count_adorn(study_cohorts, step_3_continue)
  ) |> 
  consort_line_add(start_x = -2, start_y = 28, end_x = 0, end_y = 28) |>
  # Type 2 DM ----
  consort_box_add(
    'step_3dm', 4, 38,
    cohort_count_adorn(study_cohorts, step_3)
  ) |> 
  consort_line_add(start_x = -7, start_y = 38, end_x = 10, end_y = 38) |> 

  # Step 4 ----
  consort_box_add('step_4', 0, 20, 'Step 4') |> 
  consort_arrow_add('step_3', 'bottom', 'step_4', 'top') |> 
  consort_box_add(
    'step_4_box', -7, 18,
    '4: Currently takes<br><i>only</i> insulin'
  ) |> 
  consort_box_add(
    'step_4_c', -2, 8,
    cohort_count_adorn(study_cohorts, step_4_continue)
  ) |> 
  consort_line_add(start_x = -2, start_y = 8, end_x = 0, end_y = 8) |>
  # Type 2 DM ----
  consort_box_add(
    'step_4dm', 4, 18,
    cohort_count_adorn(study_cohorts, step_4)
  ) |> 
  
  consort_line_add(start_x = -7, start_y = 18, end_x = 7, end_y = 18) |> 
  consort_line_add(start_x = 7, start_y = 18, end_x = 7, end_y = 38) |> 
  
  # Step 5 ----
  consort_box_add('step_5', 0, 0, 'Step 5') |> 
  consort_arrow_add('step_4', 'bottom', 'step_5', 'top') |> 
  consort_box_add(
    'step_5_box', -7, -2,
    '5: Started taking insulin<br>within a year<br>after diagnosis'
  ) |> 
  consort_line_add(start_x = -7, start_y = -2, end_x = 0, end_y = -2) |> 
  
  # Adding plus symbol where all Type 2 DM converge
  consort_box_add('plus_sign', 7, 38, '\\+') |> 

  # Possible Type 2 DM box
  consort_box_add(
    'no', 4, -2,
    'No'
  ) |>
  consort_line_add(start_x = 0, start_y = -2, end_x = 10, end_y = -2) |> 

  # Type 1 DM box
  consort_box_add(
    'yes', 4, -18,
    'Yes'
  ) |>
  consort_line_add(start_x = 0, start_y = -18, end_x = 10, end_y = -18) |> 
  consort_line_add(start_x = 0, start_y = -18, end_x = 0, end_y = 0) |> 
  
  ggplot() + 
  geom_consort() +
  theme_consort(margin_h = 12, margin_v = 1) + 
  
  ggplot2::annotate(
    geom = "richtext",
    x = 10, y = 38, 
    label = glue::glue('<strong>Type 2 DM</strong><br>(N = {total_t2dm})'),
    fill = "#9bc0fc",
    color = "black"
  ) +
  
  ggplot2::annotate(
    geom = "richtext",
    x = 10, y = -2,
    label = cohort_count_adorn(study_cohorts, step_5_end),
    fill = "#f5fc9bff",
    color = "black"
  ) + 
  
  ggplot2::annotate(
    geom = "richtext",
    x = 10, y = -18,
    label = cohort_count_adorn(study_cohorts, step_5),
    fill = "#9bfcd2ff",
    color = "black"
  ) +
  
  ggtitle(glue::glue(
    'Diabetes classification for NHANES ({time})\nAges 16+'
  ))

}

# the sensitivity analysis group
# sens_consort <- nhanes_consort(sensitivity, '2001-2004')
# sens_consort

# Replicate the Mosslemi cohort... do we match???
the_data |> 
  filter(between(year, 1999, 2016)) |>
  nhanes_consort('1999-2016')
# No we don't. The main issue stems from how many from the study enter Step 1:
# 5645 versus our 5651... close
# Then differences really are noticeable for how they filter for Yes or No diabetes
# diagnosis. They have 5457 after Step 1 where we only have 2889! 
# However, our prevalence of each category is not vastly different:
# Type     Mosslemi  (N=5457)          Us  (N=2889)
# T2DM         4732  (86.71%)        2552  (88.34%)
# T1DM          280   (5.13%)         118   (4.08%)
# PosT2         445   (8.16%)         219   (7.58%)

  # the main cohort
main_consort <- nhanes_consort(the_data, '2011-2022')
main_consort

save(sens_consort, file = 'data/sens_consort.RData')
save(main_consort, file = 'data/main_consort.RData')
