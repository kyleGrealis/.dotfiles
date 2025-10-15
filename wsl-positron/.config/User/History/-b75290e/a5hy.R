suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(conflicted))
suppressPackageStartupMessages(library(janitor))
suppressPackageStartupMessages(library(foreign))
suppressPackageStartupMessages(library(glue))
suppressPackageStartupMessages(library(gtsummary))
suppressPackageStartupMessages(library(gt))
suppressPackageStartupMessages(library(haven))
suppressPackageStartupMessages(library(nhanesA))
suppressPackageStartupMessages(library(readxl))
suppressPackageStartupMessages(library(remotes))
suppressPackageStartupMessages(library(survey))

if (!suppressPackageStartupMessages(require(MEPS))) {
  remotes::install_github("e-mitchell/meps_r_pkg/MEPS")
}
suppressPackageStartupMessages(library('MEPS'))

if (!require(sumExtras)) {
  remotes::install_github('kyleGrealis/sumExtras')
}
library(sumExtras)

suppressMessages(conflicted::conflict_prefer("filter", "dplyr"))
