source('R/_libraries.R')
library(ggconsort)
library(ggtext)
load('data/the_data.rda')

######################################################################################
# There have been some adjustments to certain steps that mimic the adjustments
# required in ggconsort.R for closely replicating the original study consort diagram.
# 
# This file is to create a MODIFIED Mosslemi approach based on guidelines from 
# Dr. Galindo on 09.05.2025. Steps were reordered per his instructions. Also, there
# will be commented out lines with a description of "as described in the paper" that
# designate how that line adheres to the strict wording of the original paper, but
# we needed to implement slight adaptions. See original Steps 2 & 3 for more details 
# in the ggconsort.R file and compare to Steps 3 & 4 here!
######################################################################################
the_data <- the_data |> 
  mutate(diq010 = if_else(is.na(diq010), 'N/A', diq010))

study_cohorts <- the_data |> 
  cohort_start('Assessed for eligibility') |> 
  cohort_define(

    initially_excluded = .full |> 
      filter(
        # Those less than 16 years of age
        ridageyr < 16 |
          # Those less than 16 years of age
          dmdeduc2 %in% c('Don\'t Know', 'Refused') |
          # Those without prior diagnosis of diabetes
          diq010 != 'Yes' |
          # Those without prior age at diabetes diagnosis
          is.na(did040) |
          # Those without duration of diabetes
          is.na(diab_duration)
      ),

    undiagnosed_type2 = initially_excluded |> 
      filter(lbxglu >= 126 | lbxgh >= 6.5),

    undiagnosed_type2_fpg = undiagnosed_type2 |> 
      filter(lbxglu >= 126),

    undiagnosed_type2_hba1c = undiagnosed_type2 |> 
      filter(lbxgh >= 6.5),

    undiagnosed_type2_both = undiagnosed_type2 |> 
      filter(lbxglu >= 126 & lbxgh >= 6.5),

    # Enter classification algorithm
    met_inclusion = .full |> anti_join(initially_excluded, by = 'seqn'),
    # Step 1
    step_1_removed = met_inclusion |> 
      filter(
        # Did not report yes or no for taking insulin now
        !diq050 %in% c('Yes', 'No') |
          # Did not report yes or no for taking diabetic pills
          !diq070 %in% c('Yes', 'No') |
          # diq060: Numeric duration of years using insulin
          # Reported insulin longer than disease duration
          did060 > diab_duration
      ),
    step_1_insulin = met_inclusion |> filter(!diq050 %in% c('Yes', 'No')),
    step_1_pills = met_inclusion |> filter(!diq070 %in% c('Yes', 'No')),
    step_1_duration = met_inclusion |> filter(did060 > diab_duration),
    step_1_continue = met_inclusion |> anti_join(step_1_removed, by = 'seqn'),

    # Step 2: find Type I diabetes
    type_one = step_1_continue |> filter(diab_duration - did060 <= 1),
    # using anti_join() here since using the opposite filtering lead to inaccurate
    # totals for those that should continue. could be due to either duration or
    # years using insulin is NA value. below works:
    step_2 = step_1_continue |> anti_join(type_one, by = 'seqn'),

    # Step 3: currently taking medication for diabetes
    type_two_step_3 = step_2 |> filter(diq070 == 'No'),
    step_3 = step_2 |> filter(diq070 != 'No'),

    # Step 4: currently takes insulin
    type_two_step_4 = step_3 |> filter(diq050 != 'Yes'),
    step_4 = step_3 |> anti_join(type_two_step_4, by = 'seqn'),

    # Step 5: currently takes *only* insulin
    type_two_step_5 = step_3 |> filter(diq050 == 'Yes'),

    # Not classified but has diabetes diagnosis
    not_classified = step_1_continue |> 
      anti_join(type_one, by = 'seqn') |> 
      anti_join(type_two_step_3, by = 'seqn') |> 
      anti_join(type_two_step_4, by = 'seqn') |> 
      anti_join(type_two_step_5, by = 'seqn')
  ) |> 
  cohort_label(
    initially_excluded = 'initially excluded (to assess for undiagnosed type 2)',
    undiagnosed_type2 = 'Undiagnosed Type 2 (total -- unique participants)',
    undiagnosed_type2_fpg = 'Undiagnosed Type 2 (FPG)',
    undiagnosed_type2_hba1c = 'Undiagnosed Type 2 (HbA1c)',
    undiagnosed_type2_both = 'Undiagnosed Type 2 (FPG & HbA1c)',
    met_inclusion = 'Met inclusion criteria',
    step_1_removed = 'Removed during Step 1 (total -- unique participants)',
    step_1_insulin = 'Removed for inadequate response for insulin',
    step_1_pills = 'Removed for inadequate response for diabetic pills',
    step_1_duration = 'Removed for reported insulin duration',
    step_1_continue = 'Continue for diabetes classification',
    type_one = 'Type 1 (step 2)',
    step_2 = '*** NOT TYPE 1 ***',
    type_two_step_3 = 'Type 2 (step 3)',
    type_two_step_4 = 'Type 2 (step 4)',
    type_two_step_5 = 'Type 2 (step 5)',
    not_classified = 'Has diabetes diagnosis but not classified'
  )
summary(study_cohorts) |> print(n=50)

 total_t2dm <- 
    nrow(study_cohorts$data$type_two_step_3) +
    nrow(study_cohorts$data$type_two_step_4) +
    nrow(study_cohorts$data$type_two_step_5)

study_cohorts |> 
  # Initial entry
  consort_box_add(
    'full', 0, 160, 
    cohort_count_adorn(study_cohorts, .full)
  ) |> 
  consort_box_add(
    'exclusions_1', 3, 160, glue::glue(
    '<strong>Exclusions</strong><br>
    • {cohort_count_adorn(study_cohorts, initially_excluded)}
    ')
  ) |> 
  # Point to exclusions_1 box
  consort_arrow_add('full', 'right', 'exclusions_1', 'left') |> 
  # Point to participants diagnosed with diabetes
  consort_arrow_add('full', 'bottom', 'step_0c', 'top') |> 


  # Undiagnosed diabetes ------
  # Add a hidden box for arrow origins
  consort_box_add('fudge_it', 10, 135, '') |> 
  consort_box_add(
    'diabetes_not_yes', 10, 135, cohort_count_adorn(study_cohorts, undiagnosed_type2)
  ) |> 
  # Point to Participants without diagnosed diabetes
  consort_line_add(
    start_x = 0, start_y = 135, end_x = 16, end_y = 135
  ) |> 
  # Fasting blood glucose >= 126
  consort_box_add('fpg', 5, 125, cohort_count_adorn(study_cohorts, undiagnosed_type2_fpg)) |>
  # Point from fudge_it hidden box to fpg
  consort_arrow_add(
    'fudge_it', 'bottom', end = 'fpg', end_side = 'top'
  ) |> 
  # HbA1c % >= 6.5
  consort_box_add('hb', 15, 125, cohort_count_adorn(study_cohorts, undiagnosed_type2_hba1c)) |>
  # Point from fudge_it hidden box to hb
  consort_arrow_add(
    'fudge_it', 'bottom', end = 'hb', end_side = 'top'
  ) |> 

  # Adding plus symbol where undiagnosed Type 2 DM converge
  consort_box_add('plus_sign_1', 10, 108, '\\+') |> 
  consort_line_add('fpg', 'bottom', 'plus_sign_1', 'top') |> 
  consort_line_add('hb', 'bottom', 'plus_sign_1', 'top') |> 
  # consort_arrow_add(start_x = 0, start_y = 125, end = 'undx', end_side = 'left') |> 


  
  # Diagnosed with diabetes
  consort_box_add(
    'step_0c', 0, 106, 'step 0c?'
    # cohort_count_adorn(study_cohorts, step_0c)
  ) |> 
  # Right side box
  consort_box_add('enter', -7, 101, 'Met inclusion<br>criteria') |> 
  # Connect met inclusion criteria (left) & dx w/diabetes (right)
  consort_line_add(start_x = 0, end_x = -7, start_y = 101, end_y = 101) |> 
  # Point to "Step 1" box
  consort_arrow_add('step_0c', 'bottom', 'step_1', 'top') |> 
  
  
  # adding this or else the arrow is diagonal and looks like crap
  consort_box_add('fudge_it1', 0, 77, '') |> 

  
  # Step 1 ----
  consort_box_add('step_1', 0, 80, 'Step 1') |> 
  # Right side box
  consort_box_add(
    'step_1_box', -7, 77,
    '1: Has valid<br>diabetes-related<br>information'
  ) |> 
  # Connect right box to "Step 1" box
  consort_line_add(start_x = 0, end_x = -7, start_y = 77.5, end_y = 77.5) |> 
  consort_box_add(
    'step_one_exclusions', 3, 77, glue::glue(
    '<strong>{cohort_count_adorn(study_cohorts, step_1_removed)}</strong><br>
    • {cohort_count_adorn(study_cohorts, step_1_insulin)}<br>
    • {cohort_count_adorn(study_cohorts, step_1_pills)}<br>
    • {cohort_count_adorn(study_cohorts, step_1_duration)} 
    ')
  ) |> 
  # Point from hidden box to the right Exclusions 2 box
  consort_arrow_add('fudge_it1', 'bottom', 'step_one_exclusions', 'left') |> 
  # "Yes" box just to left of center line (continued)
  consort_box_add(
    'step_1_yes', -2, 68,
    cohort_count_adorn(study_cohorts, step_1_continue)
  ) |> 
  # Connect "Yes" box to center line
  consort_line_add(start_x = -2, start_y = 68, end_x = 0, end_y = 68) |> 
  # Point from from "Step 1" box to "Step 2" box
  consort_arrow_add('step_1', 'bottom', 'step_2', 'top') |> 

  
  # Step 2 ----
  consort_box_add('step_2', 0, 60, 'Step 2') |> 
  # Right side box
  consort_box_add(
    'step_2_box', -7, 58,
    '2: Started taking insulin<br>within a year<br>after diagnosis'
  ) |> 
  # Type 1 DM box just to right of "Step 2" WITHOUT a count
  consort_box_add('yes', 4, 58, 'Yes') |>
  # "No" box with count just to left of center line (continue)
  consort_box_add(
    'step_2_no', -2, 48,
    cohort_count_adorn(study_cohorts, step_2)
  ) |> 
  # Connect "No" box to center line
  consort_line_add(start_x = -2, start_y = 48, end_x = 0, end_y = 48) |>
  # Connect "Yes" box to green "Type 1 DM" box
  consort_line_add(start_x = -7, start_y = 58, end_x = 10, end_y = 58) |> 
  # Point from "Step 2" box to "Step 3" box
  consort_arrow_add('step_2', 'bottom', 'step_3', 'top') |> 

  # Step 3 ----
  consort_box_add('step_3', 0, 40, 'Step 3') |> 
  # Right side box
  consort_box_add(
    'step_3_box', -7, 38,
    '3: Currently takes<br>medication for diabetes'
  ) |> 
  # Type 2 DM ---- "No" with count to right of "Step 3"
  consort_box_add(
    'step_3dm', 4, 38,
    cohort_count_adorn(study_cohorts, type_two_step_3)
  ) |> 
  # "Yes" box with count just to left of center line (continue)
  consort_box_add(
    'step_3_yes', -2, 28,
    cohort_count_adorn(study_cohorts, step_3)
  ) |> 
  # Connect "Yes" box with count to center line
  consort_line_add(start_x = -2, start_y = 28, end_x = 0, end_y = 28) |>
  # Draw longer line from "3: Currently takes medication..." to top corner of 
  # Type 2 DM connecting lines
  consort_line_add(start_x = -7, start_y = 38, end_x = 7, end_y = 38) |> 
  # Point from "Step 3" box to "Step 4" box
  consort_arrow_add('step_3', 'bottom', 'step_4', 'top') |> 

  
  # Step 4 ----
  consort_box_add('step_4', 0, 20, 'Step 4') |> 
  # Right side box
  consort_box_add(
    'step_4_box', -7, 18,
    '4: Currently takes<br>insulin'
  ) |> 
  # Type 2 DM ---- "No" with count to right of "Step 4"
  consort_box_add(
    'step_4dm', 4, 18,
    cohort_count_adorn(study_cohorts, type_two_step_4)
  ) |> 
  # "Yes" box with count just to left of center line (continue)
  consort_box_add(
    'step_4_yes', -2, 8,
    cohort_count_adorn(study_cohorts, step_4)
  ) |> 
  # Connect "Yes" box with count to center line
  consort_line_add(start_x = -2, start_y = 8, end_x = 0, end_y = 8) |>
  # Draw longer line from "4. Currently takes insulin" to blue "Type 2 DM" box
  consort_line_add(start_x = -7, start_y = 18, end_x = 10, end_y = 18) |> 
  # Point from "Step 4" box to "Step 5" box
  consort_arrow_add('step_4', 'bottom', 'step_5', 'top') |> 
  
  
  # Step 5 ----
  consort_box_add('step_5', 0, 0, 'Step 5') |> 
  # Right side box
  consort_box_add(
    'step_5_box', -7, -2,
    '5: Currently takes<br><i>only</i> insulin'
  ) |> 
  # Type 2 DM ---- "No" with count to right of "Step 5"
  consort_box_add(
    'step_5dm', 4, -2,
    cohort_count_adorn(study_cohorts, type_two_step_5)
  ) |> 
  # Not classified "yes" box
  consort_box_add(
    'yes', 4, -18,
    'Yes'
  ) |>
  # Draw longer line from "5. Currently takes only insulin" to bottom corner of 
  # Type 2 DM connecting lines
  consort_line_add(start_x = -7, start_y = -2, end_x = 7, end_y = -2) |> 

    
  # Not classified path
  # Downward center line; first part along "Not Classified" pathway
  consort_line_add(start_x = 0, start_y = -18, end_x = 0, end_y = 0) |> 
  # Connect first part above to final "Not Classified" box
  consort_line_add(start_x = 0, start_y = -18, end_x = 10, end_y = -18) |> 
    
    
  # Adding plus symbol where all Type 2 DM converge
  consort_box_add('plus_sign_2', 7, 18, '\\+') |> 
  # Draw vertical line through "+" box 
  # Connect end of line from Step 3 and end of line from Step 5
  consort_line_add(start_x = 7, start_y = -2, end_x = 7, end_y = 38) |>
  
  
  ggplot() + 
  geom_consort() +
  theme_consort(margin_h = 12, margin_v = 1) + 
  
  # Type 1 DM box
  ggplot2::annotate(
    geom = "richtext",
    x = 10, y = 58,
    label = cohort_count_adorn(study_cohorts, type_one),
    fill = "#9bfcd2ff",
    color = "black"
  ) +

  # Type 2 DM box
  ggplot2::annotate(
    geom = "richtext",
    x = 10, y = 18, 
    label = glue::glue('<strong>Type 2 DM</strong><br>(N = {total_t2dm})'),
    fill = "#9bc0fc",
    color = "black"
  ) +
  
  # Not Classified box
  ggplot2::annotate(
    geom = "richtext",
    x = 10, y = -18,
    label = cohort_count_adorn(study_cohorts, not_classified),
    fill = "#f5fc9bff",
    color = "black"
  ) +
  
  # Undiagnosed diabetes
  ggplot2::annotate(
    geom = "richtext",
    x = 10, y = 106,
    label = cohort_count_adorn(study_cohorts, undiagnosed_type2),
    fill = "#fc9be2ff",
    color = "black"
  ) +
  
  # Not diagnosed with either method
  ggplot2::annotate(
    geom = "richtext",
    x = 16, y = 135,
    label = cohort_count_adorn(study_cohorts, not_classified),
    fill = "#cf9bfcff",
    color = "black"
  ) 


