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

    # Step 2
    type_one = step_1_continue |> filter(diab_duration - did060 <= 1),
    # using anti_join() here since using the opposite filtering lead to inaccurate
    # totals for those that should continue. could be due to either duration or
    # years using insulin is NA value. below works:
    step_2 = step_1_continue |> anti_join(type_one, by = 'seqn'),

    # Step 3
    type_two_step_3 = step_2 |> filter(diq070 == 'No'),
    step_3 = step_2 |> filter(diq070 != 'No'),
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

  )
summary(study_cohorts) |> print(n=50)



#' @param strict Logical. Adhere to strict description in the original manuscript? This
#' applies only to Steps 3 & 4 below of our modified method (original Steps 2 & 3).
galindo_method <- function(func_data, time, strict = TRUE) {

  study_cohorts <- func_data |> 

    # ----- This revision was added after meeting 09.05.2025 ------- #
    # 
    # This allows further classifcation of undiagnosed diabetes using
    # available lab values for HbA1c% and FPG.
    # 
    # Convert is.na(diq010) to a character value to be included in revised analysis
    mutate(diq010 = if_else(is.na(diq010), 'N/A', diq010)) |>
    #
    # -------------------------------------------------------------- #
    
    cohort_start('Assessed for eligibility') |> 
    # Define cohorts ----
    cohort_define(

      # Remove those with "Don't know" or "Refused" education (dmdeduc2)
      entry = .full |> filter(!dmdeduc2 %in% c('Don\'t know', 'Refused')),
      init_excl = anti_join(.full, entry, by = 'seqn'),

      # Step 0a: valid prior diagnosis of diabetes
      step_0a = entry |> filter(diq010 == 'Yes'),
      step_0a_excl = anti_join(.full, step_0a, by = 'seqn'),

      # ----- This revision was added after meeting 09.05.2025 ------- #
      # 
      # This allows further classifcation of undiagnosed diabetes using
      # available lab values for HbA1c% and FPG.
      # 
      # undiagnosed_1 = step_0a_excl,
      undiagnosed_1 = step_0a_excl,
      fpg_t2dm = undiagnosed_1 |> filter(lbxglu >= 126),
      fpg_no = anti_join(undiagnosed_1, fpg_t2dm, by = 'seqn'),
      
      hba1c_t2dm = fpg_no |> filter(lbxgh >= 6.5),
      not_diagnosed = anti_join(fpg_no, hba1c_t2dm, by = 'seqn'),
      
      # Total those from fpg_t2dm & hba1c_t2dm
      undiagnosed_t2dm = bind_rows(fpg_t2dm, hba1c_t2dm),
      #
      # -------------------------------------------------------------- #

      # Step 0b: valid reported age at diabetes diagnosis
      step_0b = step_0a |> filter(!is.na(did040)),
      step_0b_excl = anti_join(step_0a, step_0b, by = 'seqn'),

      # Step 0c
      step_0c = step_0b |> filter(!is.na(diab_duration)),
      step_0c_excl = anti_join(step_0b, step_0c, by = 'seqn'),


      # Step 1a: taking insulin now
      step_1a = step_0c |> 
        mutate(
          # diq060q: Numeric duration
          yrs_using_insulin = did060,
            
          # Flag those where their insulin treatment period exceeds their diab_duration
          flag_duration = case_when(
            yrs_using_insulin > diab_duration ~ 'Remove', 
            is.na(yrs_using_insulin) ~ 'Keep',  # these are ok to keep
            .default = 'Keep'
          )
        ) |> 
        # Only keep those who knew yes/no that they were on insulin
        filter(diq050 %in% c('Yes', 'No')),
        # filter(flag_duration == 'Keep'),
      step_1a_excl = anti_join(step_0c, step_1a, by = 'seqn'),

      # Step 1b: report using insulin longer than diabetes duration
      step_1b = step_1a |> filter(flag_duration != 'Remove'),
      step_1b_excl = anti_join(step_1a, step_1b, by = 'seqn'),

      # Step 1c: take diabetic pills to lower blood sugar
      step_1_continue = step_1b |> filter(diq070 %in% c('Yes', 'No')),
      step_1c_excl = anti_join(step_1b, step_1_continue, by = 'seqn'),
      # END OF STEP 1
      # NOTE: step_1_continue (N=1049) -- matches main report


      # Step 2: started taking insulin within a year after diagnosis
      step_2 = step_1_continue |> 
        mutate(
          the_duration = diab_duration - yrs_using_insulin
        ) |> 
        filter(the_duration <= 1),
      step_2_continue = anti_join(step_1_continue, step_2, by = 'seqn')
      # END OF STEP 2 -- THIS IS THE MODIFIED ORDER
      # Note: step_2 (275) for Type 1 DM matches report
    )
  
  if (strict) {
    # Strict manuscript interpretation:
    study_cohorts <- study_cohorts |> 
      cohort_define(
        # Step 3: currently taking medication for diabetes
        # "neither currently taking insulin nor an oral hypoglycemic agent..."
        step_3 = step_2_continue |> filter(diq050 == 'No', diq070 == 'No'),
        # Identified in this step as Type 2 DM
        step_3_continue = anti_join(step_2_continue, step_3, by = 'seqn'),

        # Step 4: currently takes insulin
        step_4 = step_3_continue |> filter(diq050 == 'No'),
        # Identified in this step as Type 2 DM
        step_4_continue = anti_join(step_3_continue, step_4, by = 'seqn'),

        # Step 5: currently takes *only* insulin
        step_5 = step_4_continue |> filter(diq050 == 'Yes', diq070 == 'Yes'),
        # Identified in this step as Type 2 DM
        step_5_continue = anti_join(step_4_continue, step_5, by = 'seqn')
      )
  } else {
    # Modified interpretation
    study_cohorts <- study_cohorts |> 
      cohort_define(
        # Step 3: currently taking medication for diabetes
        step_3 = step_2_continue |> filter(diq070 == 'No'),
        step_3_continue = anti_join(step_2_continue, step_3, by = 'seqn'),

        # Step 4: currently takes insulin
        step_4 = step_3_continue |> filter(diq050 != 'Yes'),
        step_4_continue = anti_join(step_3_continue, step_4, by = 'seqn'),

        # Step 5: currently takes *only* insulin
        step_5 = step_4_continue |> filter(diq050 == 'Yes', diq070 == 'Yes'),
        step_5_continue = anti_join(step_4_continue, step_5, by = 'seqn')
      )
  }

  study_cohorts <- study_cohorts |> 
    # Add labels for cohorts
    cohort_label(
      .full = glue::glue('<strong>NHANES<br>({time})</strong><br>'),
      entry = glue::glue('Participants with<br>complete education information<br>'),
      
      init_excl = 'Without complete education information',
      step_0a_excl = 'Without valid prior diabetes diagnosis',
      step_0b_excl = 'Without valid reported age at diabetes diagnosis',
      step_0c_excl = 'Without valid duration of diabetes',
      step_0c = 'Participants with<br>diagnosed diabetes<br>',

      undiagnosed_1 = 'Participants without<br>diagnosed diabetes<br>',
      fpg_t2dm = 'Fasting<br>blood glucose >= 126<br>',
      hba1c_t2dm = 'HbA1c % >= 6.5<br>',

      not_diagnosed = 'Total not<br>diagosed with diabetes<br>',
      undiagnosed_t2dm = 'Total undiagnosed<br>with Type 2 DM<br>',


      step_1a_excl = 'Did not report "Yes" or "No" for taking insulin now',
      step_1b_excl = 'Reported using insulin longer than diabetes duration',
      step_1c_excl = 'Did not report "Yes" or "No" for taking diabetic pills',
      step_1_continue = 'Yes',

      step_2 = '<strong>Type 1 DM</strong><br>',
      # These are "No" because they did NOT start taking insulin <= 1 yr post-dx
      step_2_continue = 'No',

      step_3 = 'No<br>',
      step_3_continue = 'Yes',

      step_4 = 'No<br>',
      step_4_continue = 'Yes',

      step_5 = 'No<br>',
      step_5_continue = '<strong><i>Not</i><br>Classified</strong><br>'
    )
  
  # study_cohorts
  # summary(study_cohorts) |> print(n=50)

  total_t2dm <- 
    nrow(study_cohorts$data$step_3) +
    nrow(study_cohorts$data$step_4) +
    nrow(study_cohorts$data$step_5)

  galindo_consort <- study_cohorts |> 
    
    # Initial entry
    consort_box_add(
      'full', 0, 160, 
      cohort_count_adorn(study_cohorts, .full)
    ) |> 
    consort_box_add(
      'exclusions_1', 3, 160, glue::glue(
      '<strong>Exclusions</strong> (part 1)<br>
      • {cohort_count_adorn(study_cohorts, init_excl)}<br>
      • {cohort_count_adorn(study_cohorts, step_0a_excl)}<br>
      • {cohort_count_adorn(study_cohorts, step_0b_excl)}<br>
      • {cohort_count_adorn(study_cohorts, step_0c_excl)} 
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
      'diabetes_not_yes', 10, 135, cohort_count_adorn(study_cohorts, undiagnosed_1)
    ) |> 
    # Point to Participants without diagnosed diabetes
    consort_line_add(
      start_x = 0, start_y = 135, end_x = 16, end_y = 135
    ) |> 
    # Fasting blood glucose >= 126
    consort_box_add('fpg', 5, 125, cohort_count_adorn(study_cohorts, fpg_t2dm)) |>
    # Point from fudge_it hidden box to fpg
    consort_arrow_add(
      'fudge_it', 'bottom', end = 'fpg', end_side = 'top'
    ) |> 
    # HbA1c % >= 6.5
    consort_box_add('hb', 15, 125, cohort_count_adorn(study_cohorts, hba1c_t2dm)) |>
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
      'step_0c', 0, 106,
      cohort_count_adorn(study_cohorts, step_0c)
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
      'exclusions_2', 3, 77, glue::glue(
      '<strong>Exclusions</strong> (part 2)<br>
      • {cohort_count_adorn(study_cohorts, step_1a_excl)}<br>
      • {cohort_count_adorn(study_cohorts, step_1b_excl)}<br>
      • {cohort_count_adorn(study_cohorts, step_1c_excl)} 
      ')
    ) |> 
    # Point from hidden box to the right Exclusions 2 box
    consort_arrow_add('fudge_it1', 'bottom', 'exclusions_2', 'left') |> 
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
      cohort_count_adorn(study_cohorts, step_2_continue)
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
      cohort_count_adorn(study_cohorts, step_3)
    ) |> 
    # "Yes" box with count just to left of center line (continue)
    consort_box_add(
      'step_3_yes', -2, 28,
      cohort_count_adorn(study_cohorts, step_3_continue)
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
      cohort_count_adorn(study_cohorts, step_4)
    ) |> 
    # "Yes" box with count just to left of center line (continue)
    consort_box_add(
      'step_4_yes', -2, 8,
      cohort_count_adorn(study_cohorts, step_4_continue)
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
      cohort_count_adorn(study_cohorts, step_5)
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
      label = cohort_count_adorn(study_cohorts, step_2),
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
      label = cohort_count_adorn(study_cohorts, step_5_continue),
      fill = "#f5fc9bff",
      color = "black"
    ) +
    
    # Undiagnosed diabetes
    ggplot2::annotate(
      geom = "richtext",
      x = 10, y = 106,
      label = cohort_count_adorn(study_cohorts, undiagnosed_t2dm),
      fill = "#fc9be2ff",
      color = "black"
    ) +
    
    # Not diagnosed with either method
    ggplot2::annotate(
      geom = "richtext",
      x = 16, y = 135,
      label = cohort_count_adorn(study_cohorts, not_diagnosed),
      fill = "#cf9bfcff",
      color = "black"
    ) 
    
  return(galindo_consort)

}

strict <- the_data |> 
  filter(between(year, 1999, 2021)) |> 
  galindo_method(time = '1999-2022', strict = TRUE)
strict

not_strict <- the_data |> 
  filter(between(year, 1999, 2021)) |> 
  galindo_method(time = '1999-2022', strict = FALSE)
not_strict

######################################################################################
# Adjusting for strict vs loose wording in Steps 3 & 4 had an impact in our
# modified classification method. Strict wording in Step 3 espeically allowed for 343 participants to not be classified. After only filtering on diq070 as opposed to diq070 & diq050, those 343 were now classified with T2DM in Step 3. All 4761 who entered at modified Step 2 were classified after completing the algorithm.
######################################################################################

# saving a modified versions
save(strict, file = 'data/main_consort_mod_stict.RData')
save(not_strict, file = 'data/main_consort_mod_not_strict.RData')
