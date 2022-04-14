library(dplyr)
library(hrbrthemes)
library(tidyr)
library(ggplot2)
library(tidyverse)
library(DT)
# install_github("trestletech/shinyTable")
# library(shinyTable)
# install.packages("rhandsontable")
library(rhandsontable)


hrbrthemes::import_roboto_condensed()

slapnea22 <- readRDS(paste0(here::here(), "/data/slapnea22.RDS"))
slapnea22_eurostat <- readRDS(paste0(here::here(), "/data/slapnea22_eurostat.RDS"))
europe_spdf <- readRDS(paste0(here::here(), "/data/europe_spdf.RDS"))

locations <- unique(slapnea22$location_name)