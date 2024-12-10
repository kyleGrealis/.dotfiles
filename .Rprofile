# Only run all of this in interactive sessions
if (interactive()) {
  suppressMessages(require(devtools))
  
  # set default CRAN mirror
  local({
    r <- getOption("repos")
    r["CRAN"] <- "https://cran.rstudio.com/"
    options(repos = r)
  })
  
  options(shiny.port = 7209)
  
  # Print welcome message
  cat("\n------------------------------------------\n")
  cat(paste0("[Today is ", format(Sys.Date(), "%m-%d-%Y"), "]\n"))
  cat(paste0("Using R ", R.version$major, ".", R.version$minor))
  cat("\n------------------------------------------\n\n")
  
  # Set prompt at the very end
  options(prompt = glue::glue("[{emo::ji('frog')}", "]> "))
}

# froggeR Quarto YAML options:
options(
  froggeR.options = list(
    name = "Kyle Grealis",
    email = "kylegrealis@icloud.com",
    orcid = "0000-0002-9223-8854",
    url = "https://github.com/kyleGrealis",
    affiliations = "",
    toc = "Table of Contents"
  )
)
