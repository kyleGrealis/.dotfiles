# Set the gtsummary theme
suppressMessages(
  set_gtsummary_theme(
    theme_gtsummary_compact("jama")
  )
)

# Misc table tweaks
date <- Sys.Date() |> format("%B %d, %Y")
subtitle <- glue("Processed: {date}")

#' Clean and standardize missing value display in gtsummary tables
#'
#' @description Improves table readability by replacing various missing value 
#'   representations with a consistent "--" symbol. This makes it easier to 
#'   distinguish between actual data and missing/undefined values in summary 
#'   tables, creating a cleaner and more professional appearance.
#'
#' @param tbl A gtsummary table object (e.g., from `tbl_summary()`, `tbl_regression()`)
#'
#' @returns A gtsummary table object with standardized missing value display
#'
#' @details The function uses `gtsummary::modify_table_body()` to transform 
#'   character columns and replace common missing value patterns with "--":
#'   * `"0 (NA%)"` - No events occurred and percentages cannot be calculated
#'   * `"NA (NA)"` - Completely missing data for both count and percentage
#'   * `"0 (0%)"` - Zero counts with zero percentage
#'   * `"NA (NA, NA)"` - Missing data with confidence intervals
#'   * `"NA, NA"` - Missing paired values (e.g., median and IQR)
#'   
#'   This standardization makes tables more scannable and reduces visual clutter
#'   from various "empty" data representations.
#'
#' @examples
#' # Basic usage - clean missing values in summary table
#' trial |> 
#'   tbl_summary(by = trt) |> 
#'   clean_table()
#'   
#' # Often used as part of a styling pipeline
#' trial |> 
#'   tbl_summary(by = trt) |> 
#'   add_auto_labels() |> 
#'   extras() |> 
#'   clean_table()
#'   
#' # Works with regression tables too
#' lm(age ~ trt + grade, data = trial) |> 
#'   tbl_regression() |> 
#'   clean_table()
#'
#' @seealso 
#' * [gtsummary::modify_table_body()] for general table body modifications
#' * [extras()] which includes `clean_table()` in its styling pipeline
#'
#' @export
clean_table <- function(tbl) {
  tbl |>
    modify_table_body(
      ~ .x |> 
        mutate(across(all_stat_cols(), ~ {
          # Detect any statistic containing "NA" or "Inf" using word boundaries
          # \\b ensures to match complete words, avoiding false positives
          na_pattern <- "\\bNA\\b|\\bInf\\b|^0 \\(0%\\)$"
          if_else(str_detect(., na_pattern), NA_character_, .)
        }))
    ) |> 
    modify_missing_symbol(
      symbol = "---",
      columns = all_stat_cols(),
      rows = 
        (var_type %in% c("continuous", "dichotomous") & row_type == "label") |
        (var_type %in% c("continuous2", "categorical") & row_type == "level")
    )
}


#' Apply compact JAMA-style theme to gt tables
#'
#' @description Applies a compact table theme to gt tables that matches the 
#'   'jama' theme from gtsummary. This ensures visual consistency when mixing 
#'   gtsummary tables (using `theme_gtsummary_compact("jama")`) with regular 
#'   gt tables in the same document. The theme reduces padding, adjusts font 
#'   sizes, and applies JAMA journal styling conventions.
#'
#' @param tbl A gt table object created with `gt::gt()`
#'
#' @returns A gt table object with compact JAMA-style formatting applied
#'
#' @details This function replicates the visual appearance of 
#'   `gtsummary::theme_gtsummary_compact("jama")` for use with regular gt tables.
#'   Key styling includes:
#'   * Reduced font size (13px) for compact appearance
#'   * Minimal padding (1px) on all row types
#'   * Bold column headers and table titles
#'   * Hidden top and bottom table borders
#'   * Consistent spacing that matches JAMA journal standards
#'
#' @examples
#' # Basic usage with a data frame
#' mtcars |> 
#'   head() |> 
#'   gt::gt() |> 
#'   theme_gt_compact()
#'   
#' # Combine with other gt functions
#' mtcars |> 
#'   head() |> 
#'   gt::gt() |> 
#'   gt::tab_header(title = "Vehicle Data") |> 
#'   theme_gt_compact()
#'   
#' # Use alongside gtsummary tables for consistency
#' # Set gtsummary theme first
#' gtsummary::set_gtsummary_theme(gtsummary::theme_gtsummary_compact("jama"))
#' 
#' # Then both tables will have matching appearance
#' summary_table <- trial |> gtsummary::tbl_summary()
#' data_table <- trial |> head() |> gt::gt() |> theme_gt_compact()
#'
#' @seealso 
#' * [gtsummary::theme_gtsummary_compact()] for gtsummary table themes
#' * [gtsummary::set_gtsummary_theme()] for setting global gtsummary themes
#' * [gt::tab_options()] for additional gt table styling options
#'
#' @export
theme_gt_compact <- function(tbl) {
 tbl |>
   gt::tab_options(
     table.font.size = gt::px(13),
     data_row.padding = gt::px(1),
     summary_row.padding = gt::px(1),
     grand_summary_row.padding = gt::px(1),
     footnotes.padding = gt::px(1),
     source_notes.padding = gt::px(1),
     row_group.padding = gt::px(1),
     heading.title.font.weight = "bold",
     column_labels.font.weight = "bold",
     table.border.top.style = "hidden",
     table.border.bottom.style = "hidden"
   )
}


#' Add standard styling and formatting to gtsummary tables
#'
#' @description Applies a consistent set of formatting options to gtsummary tables
#'   including overall column, bold labels, clean headers, and optional p-values.
#'   Streamlines the common workflow of adding multiple formatting functions.
#'
#' @param tbl A gtsummary table object (e.g., from `tbl_summary()`, `tbl_regression()`)
#' @param pval Logical indicating whether to add p-values. Default is `TRUE`.
#'   When `TRUE`, adds Kruskal-Wallis tests for continuous variables and 
#'   chi-square tests for categorical variables.
#'
#' @returns A gtsummary table object with standard formatting applied
#'
#' @details The function applies the following modifications:
#' * Adds an "Overall" column as the last column
#' * Bolds variable labels for emphasis
#' * Removes the "Characteristic" header label
#' * Applies `clean_table()` styling
#' * Optionally adds p-values with appropriate statistical tests
#'
#' @examples
#' # With p-values (default)
#' trial |> 
#'   tbl_summary(by = trt) |> 
#'   extras()
#'   
#' # Without p-values
#' trial |> 
#'   tbl_summary(by = trt) |> 
#'   extras(pval = FALSE)
#'   
#' # Chain with other functions
#' trial |> 
#'   tbl_summary(by = trt) |> 
#'   add_auto_labels() |> 
#'   extras(pval = TRUE) |> 
#'   group_styling()
#'
#' @seealso 
#' * [gtsummary::add_overall()] for adding overall columns
#' * [gtsummary::add_p()] for adding p-values
#' * [clean_table()] for additional table styling
#'
#' @export
extras <- function(tbl, pval = TRUE, overall = TRUE) {
  result <- tbl |>
    gtsummary::bold_labels() |> 
    gtsummary::modify_header(label ~ "")

  if (overall) {
    result <- result |> 
      gtsummary::add_overall(last = TRUE)
  }
  
  if (pval) {
    result <- result |> 
      gtsummary::add_p(
        test = list(
          gtsummary::all_continuous() ~ "kruskal.test",
          gtsummary::all_categorical() ~ "stats::chisq.test"
        ),
        pvalue_fun = ~ gtsummary::style_pvalue(.x, digits = 3)
      )
  }
  
  result |> clean_table()
}


#' Apply styling to variable group headers in gtsummary tables
#' 
#' @description Adds customizable formatting to variable group headers in 
#'   gtsummary tables. Variable groups are created when using functions like 
#'   `tbl_strata()` or when variables are organized into sections. This function 
#'   enhances table readability by making group headers visually distinct from 
#'   individual variable labels.
#' 
#' @param tbl A gtsummary table object (e.g., from `tbl_summary()`, `tbl_regression()`)
#' @param format Character vector specifying text formatting. Options include 
#'   `"bold"`, `"italic"`, or both. Default is `c("bold", "italic")`.
#' 
#' @returns A gtsummary table object with specified formatting applied to 
#'   variable group headers
#' 
#' @details The function targets rows where `row_type == 'variable_group'` and 
#'   applies the specified text formatting to the label column. This is 
#'   particularly useful for tables with multiple sections or stratified analyses 
#'   where clear visual hierarchy improves interpretation.
#' 
#' @examples
#' # Default formatting (bold and italic)
#' trial |> 
#'   tbl_summary(by = trt) |> 
#'   group_styling()
#'   
#' # Bold only
#' trial |> 
#'   tbl_summary(by = trt) |> 
#'   group_styling(format = "bold")
#'   
#' # Italic only
#' trial |> 
#'   tbl_summary(by = trt) |> 
#'   group_styling(format = "italic")
#'   
#' # Useful with stratified tables
#' trial |> 
#'   tbl_strata(
#'     strata = grade,
#'     .tbl_fun = ~ .x |> tbl_summary(by = trt)
#'   ) |> 
#'   group_styling(format = "bold")
#' 
#' @seealso 
#' * [gtsummary::modify_table_styling()] for general table styling options
#' * [gtsummary::tbl_strata()] for creating stratified tables with groups
#' 
#' @export
group_styling <- function(tbl, format = c('bold', 'italic')) {
  tbl |> 
    gtsummary::modify_table_styling(
      columns = label,
      rows = row_type == 'variable_group',
      text_format = format
    )
}


#' Create a list of variable labels from a dataset using a dictionary
#' 
#' @description Creates a list of formula objects for variable labeling compatible with 
#'   `gtsummary::tbl_summary()`. Matches dataset variable names against a dictionary 
#'   tibble to generate labels. Requires a global `dictionary` object with `Variable` 
#'   and `Description` columns. Can be used standalone or internally by `add_auto_labels()`.
#' 
#' @param data A data frame or tibble containing variables to be labeled
#' 
#' @returns A list of formula objects in the format `variable ~ "Description"` 
#'   suitable for use in `gtsummary::tbl_summary(label = )`
#' 
#' @details The function requires a `dictionary` object in the global environment 
#'   structured as a tibble with columns:
#'   - `Variable`: Character column with exact variable names from datasets
#'   - `Description`: Character column with human-readable labels
#'   
#'   Only variables present in both the input data and dictionary will be included 
#'   in the output. Missing variables are silently ignored.
#' 
#' @examples
#' # Create required dictionary first
#' dictionary <- tibble::tribble(
#'   ~Variable, ~Description,
#'   'record_id', 'Participant ID',
#'   'age', 'Age at enrollment',
#'   'sex', 'Biological sex'
#' )
#' 
#' # Generate labels for a dataset
#' my_labels <- create_labels(study_data)
#' 
#' # Use directly in tbl_summary
#' study_data |> 
#'   tbl_summary(label = create_labels(study_data))
#'   
#' @seealso [add_auto_labels()] for automatic application to existing tbl_summary objects
#' 
#' @export
create_labels <- function(data) {
  # Extract variable names from the input dataset
  variables <- names(data)

  # Filter dictionary to only include variables present in the dataset
  # This prevents errors from dictionary entries not in the current data
  filtered_dict <- dictionary |> 
    filter(Variable %in% variables)
  
  # Create list of formulas using map2 for pairwise iteration
  # Format: variable ~ "Description" as required by gtsummary::tbl_summary()
  labels_list <- purrr::map2(
    filtered_dict$Variable,
    filtered_dict$Description,
    ~as.formula(paste(.x, '~', shQuote(.y)))
  )

  return(labels_list)
}


#' Add automatic labels from dictionary to a tbl_summary object
#' @description Pipe a `gtsummary::tbl_summary` object to automatically add variable 
#'   labels from a dictionary tibble. Preserves any manual label overrides specified 
#'   in the original `tbl_summary()` call while adding dictionary labels for unlabeled 
#'   variables. Requires a `dictionary` object with `Variable` and `Description` columns.
#'   See `create_labels()` function for dictionary format requirements.
#' 
#' @param tbl A gtsummary table object created by `tbl_summary()`
#' 
#' @returns A gtsummary table object with automatic labels applied
#' 
#' @examples
#' # Basic usage - adds dictionary labels to all variables
#' table1_data |> 
#'   tbl_summary(by = diagnosis) |> 
#'   add_auto_labels()
#'   
#' # Preserves manual overrides while adding dictionary labels for the rest
#' table1_data |> 
#'   tbl_summary(by = diagnosis, label = c(age ~ "Patient Age")) |> 
#'   add_auto_labels()  # 'age' stays "Patient Age", others get dictionary labels
#'   
#' @seealso [create_labels()] for dictionary requirements
#' 
#' @export
add_auto_labels <- function(tbl) {

  # browser()
  
  # Extract the original dataset from the table object
  # This data is stored in tbl$inputs$data and contains all variables used in the table
  original_data <- tbl$inputs$data
  
  # Check if this is a survey table by looking at the table class, not just the data
  # Detects tbl_svysummary objects or survey design data to call the correct reconstruction function
  is_survey_table <- inherits(tbl, "tbl_svysummary") || 
                      any(grepl("svy", class(tbl))) ||
                      inherits(original_data, "survey.design")
  
  # For survey objects, extract the data frame from the design
  # Survey designs store actual data in $variables component
  if (inherits(original_data, "survey.design")) {
    data_for_labels <- original_data$variables
  } else {
    data_for_labels <- original_data
  }
  
  # Get the variables that are actually included in the table
  # Only label variables that were specified in the include argument to avoid errors
  included_vars <- tbl$inputs$include %||% names(data_for_labels)
  
  # Generate automatic labels from the dictionary using create_labels()
  # Returns a list of formulas: list(variable ~ "Description from dictionary")
  auto_labels_list <- create_labels(data_for_labels)
  
  # Filter auto labels to only include variables in the table
  # Extract variable names from formulas and keep only those in the current table
  auto_vars <- purrr::map_chr(auto_labels_list, ~ all.vars(.x)[1])
  keep_vars <- auto_vars %in% included_vars
  auto_labels_filtered <- auto_labels_list[keep_vars]
  
  # Extract any existing & overriding labels that were manually specified in tbl_summary()
  # Note: tbl_summary stores these as a named list: list(variable = "Custom Label")
  # The %||% operator means "use this, or if NULL use list()"
  override_labels <- tbl$inputs$label %||% list()
  
  if (length(override_labels) > 0) {
    # DON'T convert override labels - they're already in the correct format for reconstruction!
    # gtsummary expects the original input format when using do.call()
    
    # Extract variable names from the override custom labels
    # These variables should NOT be overwritten by dictionary labels
    existing_vars <- names(override_labels)
    
    # Extract variable names from the filtered auto-generated dictionary labels
    # all.vars(.x)[1] gets the left-hand side variable name from each formula
    filtered_auto_vars <- purrr::map_chr(auto_labels_filtered, ~ all.vars(.x)[1])
    
    # Filter auto_labels to exclude any variables that have custom labels
    # This preserves manual overrides while adding dictionary labels for the rest
    keep_auto <- !filtered_auto_vars %in% existing_vars
    final_auto_labels <- auto_labels_filtered[keep_auto]
    
    # Convert remaining dictionary labels to named list format to match override format
    if (length(final_auto_labels) > 0) {
      auto_as_named_list <- setNames(
        purrr::map_chr(final_auto_labels, ~ as.character(.x)[3]), # Extract description
        purrr::map_chr(final_auto_labels, ~ all.vars(.x)[1])      # Extract variable name
      )
      # Combine override labels (named list) with auto labels (converted to named list)
      combined_labels <- c(override_labels, auto_as_named_list)
    } else {
      # No additional dictionary labels needed, use only manual overrides
      combined_labels <- override_labels
    }

    # DEBUG: Check final structure
    # print("Manual override vars:")
    # print(existing_vars)
    # print("Dictionary vars being added:")
    # print(filtered_auto_vars[keep_auto])
    # print("Any duplicates?")
    # print(intersect(existing_vars, filtered_auto_vars[keep_auto]))

  } else {
    # No existing override custom labels found, use all filtered dictionary labels
    combined_labels <- auto_labels_filtered
  }
  
  # Reconstruct the table with the combined label set
  # Preserve all original arguments (data, by, missing, etc.) from tbl$inputs
  args <- tbl$inputs
  args$label <- combined_labels
  
  # Rebuild and return the table with automatic + custom labels applied
  # Use the survey detection to call the right function (tbl_svysummary vs tbl_summary)
  if (is_survey_table) {
    do.call(tbl_svysummary, args)
  } else {
    do.call(tbl_summary, args)
  }
}
