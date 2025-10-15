set.seed(305)

a_split <- initial_split(analysis, strata = "did_relapse")

a_train <- training(a_split)
save(a_train, file = "data/a_train.RData")

a_test <- testing(a_split)
save(a_test, file = "data/a_test.RData")

a_fold <- vfold_cv(a_train, v = 5)

a_recipe <-
  recipe(formula = did_relapse ~ ., data = a_train) |>
  # no update_role because DALEXtra::explain_tidymodels uses who as a predictor
  # update_role(who, new_role = "id variable") |>
  step_nzv(all_predictors()) |>
  # Needed for KNN see https://github.com/tidymodels/recipes/issues/926
  step_string2factor(all_nominal_predictors()) |>
  step_impute_knn(all_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_other(all_nominal_predictors()) |>
  step_corr(all_numeric_predictors()) |>
  step_normalize(all_numeric_predictors())
