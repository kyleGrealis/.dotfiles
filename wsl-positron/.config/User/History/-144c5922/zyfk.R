# load libraries ----------------------------------------------------------
# library(conflicted)
# suppressPackageStartupMessages(library(tidymodels))
# conflicted::conflict_prefer("filter", "dplyr")


# import comparison objects -----------------------------------------------
models <- 
  list(
    "knn", "logistic", "logistic_via_lasso", "lasso",
    "mars", "cart", "rf", "xgb", "bart", "svm", "nnet"
  )
for (model in models) {
  # metrics data
  metrics_data_file <- glue::glue("data/{model}_metrics.RData")
  data <- rio::import(metrics_data_file, trust = TRUE)
  assign(glue::glue("{model}_metrics"), data)

  # resample data
  resample_data_file <- glue::glue("data/{model}_resample_best.RData")
  data <- rio::import(resample_data_file, trust = TRUE)
  assign(glue::glue("{model}_resample_best"), data)

  # metrics TEST data
  metrics_test_data_file <- glue::glue("data/{model}_metrics_test.RData")
  data <- rio::import(metrics_test_data_file, trust = TRUE)
  assign(glue::glue("{model}_metrics_test"), data)
}

# do the comparison -------------------------------------------------------

best_full_train <-
  bind_rows(
    knn_metrics |>
      filter(.metric == "roc_auc") |>
      mutate(Model = "KNN") |>
      select(Model, .estimate),
    logistic_via_lasso_metrics |>
      filter(.metric == "roc_auc") |>
      mutate(Model = "Logistic LASSO") |>
      select(Model, .estimate),
    logistic_metrics |>
      filter(.metric == "roc_auc") |>
      mutate(Model = "Logistic") |>
      select(Model, .estimate),
    lasso_metrics |>
      filter(.metric == "roc_auc") |>
      mutate(Model = "LASSO") |>
      select(Model, .estimate),
    mars_metrics |>
      filter(.metric == "roc_auc") |>
      mutate(Model = "MARS") |>
      select(Model, .estimate),
    cart_metrics |>
      filter(.metric == "roc_auc") |>
      mutate(Model = "CART") |>
      select(Model, .estimate),
    rf_metrics |>
      filter(.metric == "roc_auc") |>
      mutate(Model = "Random Forest") |>
      select(Model, .estimate),
    bart_metrics |>
      filter(.metric == "roc_auc") |>
      mutate(Model = "BART") |>
      select(Model, .estimate),
    xgb_metrics |>
      filter(.metric == "roc_auc") |>
      mutate(Model = "Boosted Trees") |>
      select(Model, .estimate),
    svm_metrics |>
      filter(.metric == "roc_auc") |>
      mutate(Model = "Support Vector") |>
      select(Model, .estimate),
    nnet_metrics |>
      filter(.metric == "roc_auc") |>
      mutate(Model = "Neural Net") |>
      select(Model, .estimate)
  ) |>
  arrange(desc(.estimate)) |>
  rename(`Full Training Dataset` = .estimate)

best_cv <-
  bind_rows(
    knn_resample_best |>
      slice_head(n = 1) |>
      mutate(Model = "KNN") |>
      select(Model, mean),
    logistic_via_lasso_resample_best |>
      slice_head(n = 1) |>
      mutate(Model = "Logistic LASSO") |>
      select(Model, mean),
    logistic_resample_best |>
      slice_head(n = 1) |>
      mutate(Model = "Logistic") |>
      select(Model, mean),
    lasso_resample_best |>
      slice_head(n = 1) |>
      mutate(Model = "LASSO") |>
      select(Model, mean),
    mars_resample_best |>
      slice_head(n = 1) |>
      mutate(Model = "MARS") |>
      select(Model, mean),
    cart_resample_best |>
      slice_head(n = 1) |>
      mutate(Model = "CART") |>
      select(Model, mean),
    rf_resample_best |>
      slice_head(n = 1) |>
      mutate(Model = "Random Forest") |>
      select(Model, mean),
    bart_resample_best |>
      slice_head(n = 1) |>
      mutate(Model = "BART") |>
      select(Model, mean),
    xgb_resample_best |>
      slice_head(n = 1) |>
      mutate(Model = "Boosted Trees") |>
      select(Model, mean),
    svm_resample_best |>
      slice_head(n = 1) |>
      mutate(Model = "Support Vector") |>
      select(Model, mean),
    nnet_resample_best |>
      slice_head(n = 1) |>
      mutate(Model = "Neural Net") |>
      select(Model, mean)
  ) |>
  arrange(desc(mean)) |>
  rename(`Cross Validation` = mean) |>
  mutate(`Cross Validation` = round(`Cross Validation`, 4))

testing_results <-
  bind_rows(
    knn_metrics_test |> transmute(Model = "KNN", `Testing Dataset` = .estimate),
    logistic_via_lasso_metrics_test |> 
      transmute(Model = "Logistic LASSO", `Testing Dataset` = .estimate),
    logistic_metrics_test |> 
      transmute(Model = "Logistic", `Testing Dataset` = .estimate),
    lasso_metrics_test |> 
      transmute(Model = "LASSO", `Testing Dataset` = .estimate),
    mars_metrics_test |> 
      transmute(Model = "MARS", `Testing Dataset` = .estimate),
    cart_metrics_test |> 
      transmute(Model = "CART", `Testing Dataset` = .estimate),
    rf_metrics_test |> 
      transmute(Model = "Random Forest", `Testing Dataset` = .estimate),
    bart_metrics_test |> 
      transmute(Model = "BART", `Testing Dataset` = .estimate),
    xgb_metrics_test |> 
      transmute(Model = "Boosted Trees", `Testing Dataset` = .estimate),
    svm_metrics_test |> 
      transmute(Model = "Support Vector", `Testing Dataset` = .estimate),
    nnet_metrics_test |> 
      transmute(Model = "Neural Net", `Testing Dataset` = .estimate)
  )

best_ROC <- 
  inner_join(best_cv, best_full_train, by = join_by(Model)) |>
  left_join(
    testing_results,
    by = join_by(Model)
  ) |>
  # 2 = round(2, digits = 4),
  mutate(across(3:4, ~ round(.x, digits = 3))) |>
  arrange(desc("Cross Validation"))


# ----------------------- calculate accuracy on train & test ------------------
# Function to calculate accuracy and F1
calculate_model_metrics <- function(model_fit, data) {
  augmented_data <- augment(model_fit, new_data = data)

  sens <- 
    augmented_data |>
    sens(truth = did_relapse, estimate = .pred_class) |>
    pull(.estimate)

  spec <-
    augmented_data |>
    spec(truth = did_relapse, estimate = .pred_class) |>
    pull(.estimate)

  accuracy <-
    augmented_data |>
    accuracy(truth = did_relapse, estimate = .pred_class) |>
    pull(.estimate)

  f1 <- 
    augmented_data |>
    f_meas(truth = did_relapse, estimate = .pred_class) |>
    pull(.estimate)

  return(c(sens, spec, accuracy, f1))
}

# Initialize empty lists to store results
train_results <- list()
test_results <- list()

# Initialize an empty tibble to store results
results_table <-
  tibble(
    Model = character(),
    `Train Sensitivity` = numeric(),
    `Train Specificity` = numeric(),
    `Train Accuracy` = numeric(),
    `Train F1` = numeric(),
    `Test Sensitivity` = numeric(),
    `Test Specificity` = numeric(),
    `Test Accuracy` = numeric(),
    `Test F1` = numeric()
  )

# Loop through models
for (model in models) {
  # Load model fit
  metrics_data_file <- glue::glue("data/{model}_final_fit.RData")
  model_fit <- rio::import(metrics_data_file, trust = TRUE)

  # Calculate metrics for train and test sets
  train_metrics <- calculate_model_metrics(model_fit, a_train)
  test_metrics <- calculate_model_metrics(model_fit, a_test)

  # Store results
  results_table <-
    results_table |>
    add_row(
      Model = model,
      `Train Sensitivity` = train_metrics[1],
      `Train Specificity` = train_metrics[2],
      `Train Accuracy` = train_metrics[3],
      `Train F1` = train_metrics[4],
      `Test Sensitivity` = test_metrics[1],
      `Test Specificity` = test_metrics[2],
      `Test Accuracy` = test_metrics[3],
      `Test F1` = test_metrics[4]
    )
}

best_sens_spec <-
  results_table |>
  arrange(desc(`Train F1`))
