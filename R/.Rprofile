if (interactive()) {
  suppressMessages(require(devtools))
  suppressMessages(require(tidyverse))
}


# set the default CRAN mirror
local({
  r <- getOption("repos")
  r["CRAN"] <- "https://cran.rstudio.com/"
  options(repos = r)
})


options(
  prompt = ">> ",
  shiny.port = 7209,
  digits = 4
)


options(
  usethis.full_name = 'Kyle Grealis',
  usethis.description = list(
    `Authors@R` = 'person(
      given = "Kyle",
      family = "Grealis",
      role = c("aut", "cre"),
      email = "kyle@kyleGrealis.com",
      comment = c(ORCID = "0000-0002-9223-8854")
    )'
  )
)


# For NixOS -- for now...
# if (Sys.info()[["nodename"]] == "nixos") {
#   # Find the current R installation path dynamically
#   r_home <- R.home()
#   if (grepl("/nix/store", r_home)) {
#     nix_lib <- file.path(dirname(r_home), "R/library")
#     if (dir.exists(nix_lib)) {
#       .libPaths(c(nix_lib, .libPaths()))
#     }
#   }
# }
