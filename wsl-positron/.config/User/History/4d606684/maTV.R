#' do_everything.R
#'
#' Main script for running all modeling analyses
#' This script coordinates the entire modeling pipeline from data preparation
#' through model fitting and evaluation.

# ---- Helper Functions ----
#' Wrapper function for \code{source} to include processing time
#' @param script_path Machine learning modeling script
source_wrapper <- function(script_path) {
  message(glue::glue('Starting {script_path}...'))
  start_time <- Sys.time()
  source(script_path)
  process_time <- hms::as_hms(round(Sys.time() - start_time, 2))
  message(glue::glue('{script_path} ran in {process_time}\n\n'))
}

#' Function to process modeling scripts
#' @param model_script R script for specific machine learning model.
#' @param run_parallel Boolean value to use \code{doParallel} package
run_models <- function(model_script, run_parallel = FALSE) {
  message(glue::glue(
    "\nTime now: {hms::round_hms(hms::as_hms(Sys.time()), digits=0)}..."
  ))
  if (run_parallel) {
    doParallel::registerDoParallel(cores = parallel::detectCores() - 2)
  }
  source_wrapper(model_script)
  if (run_parallel) doParallel::stopImplicitCluster()
}

# ---- Initialize Settings ----
options(digits = 8)
set.seed(305)

# ---- Initialize Timing ----
beginning <- hms::round_hms(hms::as_hms(Sys.time()), digits=0)
message(sprintf('Start time: %s', beginning))

# ---- Data Preparation Phase ----
# These scripts handle library loading, data importing, and initial preprocessing
# To use latent class variables set the data use subset and subset_not_used
# in preprocess_recipe.R
setup_scripts <- c(
  "libraries.R",
  "code_with_notes.R",
  "load.R",
  "preprocess_recipe.R"
)
setup_scripts |>
  purrr::walk(source_wrapper)

# ---- Recipe Processing ----
# Prepare and bake the recipe for model training
prepped_recipe <- prep(a_recipe, training = a_train)
baked_recipe <- bake(prepped_recipe, new_data = a_train)
print(glue::glue(
  "Dimensions after modified recipe: {dim(baked_recipe)[1]} rows x {dim(baked_recipe)[2]} columns\n\n"
))

# ---- Model Fitting Phase ----
# Neural Network must be run without parallel processing on Mac systems
run_models("nnet.R", run_parallel = FALSE)

# Define and run models that can utilize parallel processing
models <- c(
  "logistic.R",
  "logistic_via_lasso.R",
  "lasso.R",
  "knn.R",
  "mars.R",
  "cart.R",
  "rf.R",
  "xgboost.R",
  "bart.R",
  "svm.R"
)
models |> purrr::walk(run_models, run_parallel = TRUE)

# ---- Results Processing ----
# Summarize results across all models
run_models("summarize.R", run_parallel = TRUE)

# Display total modeling time
message(glue::glue(
  'Total modeling time: {hms::round_hms(hms::as_hms(Sys.time() - beginning), 60)}'
))

# ---- Results Output ----
# Display primary performance metrics
best_ROC
best_sens_spec

# Set up results directory and save outputs
# Change iteration_name if using non-default recipe or want to date results
# iteration_name <- "default_recipe"
iteration_name <- "April2025"

# Create directory for results if it doesn't exist
if (!dir.exists(glue::glue("{here::here()}/data/{iteration_name}/"))) {
  dir.create(glue::glue("{here::here()}/data/{iteration_name}/"))
}

# Save performance metrics
save(
  best_ROC,
  file = glue::glue("data/{iteration_name}/best_ROC.RData")
)
save(
  best_sens_spec,
  file = glue::glue("data/{iteration_name}/best_sens_spec.RData")
)

# ---- Variable Importance Calculations ----
# WARNING: THIS SECTION IS COMPUTATIONALLY EXPENSIVE!
# Please close unnecessary programs and be advised that this will take 
# multiple hours to complete. Consider processing overnight or when 
# computer resources aren't immediately needed.
if (!require('DALEX')) install.packages('DALEX')
DALEX::install_dependencies()
source_wrapper("vip_calcs.R")

# ---- Final Timing ----
message(glue::glue(
  'Total processing time: {hms::round_hms(hms::as_hms(Sys.time() - beginning), 60)}'
))
