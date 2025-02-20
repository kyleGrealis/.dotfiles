if (interactive()) {
  suppressMessages(require(devtools))
}


# set the default CRAN mirror
local({
  r <- getOption("repos")
  r["CRAN"] <- "https://cran.rstudio.com/"
  options(repos = r)
})


# Custom prompt
cat("\n-------------------------------------------\n")
cat(paste0("[Today is ", format(Sys.Date(), "%Y-%m-%d"), "]\n"))
cat(paste0("Using R ", R.version$major, ".", R.version$minor, "\n"))
cat("-------------------------------------------\n\n")

options(
  prompt = ">> ",
  shiny.port = 7209,
  digits = 4
)

# who am i?
options(
  usethis.full_name = 'Kyle Grealis',
  usethis.description = list(
    `Authors@R` = 'person(
      given = "Kyle",
      family = "Grealis",
      role = c("aut", "cre"),
      email = "kyle@azimuth-project.tech",
      comment = c(ORCID = "0000-0002-9223-8854")
    )'
  )
)
