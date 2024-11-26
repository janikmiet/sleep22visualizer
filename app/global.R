library(shiny)
library(dplyr)
library(hrbrthemes)
library(tidyr)
library(ggplot2)
library(leaflet)
library(here)
library(DT)
library(rhandsontable)


hrbrthemes::import_roboto_condensed()

slapnea22 <- readRDS(paste0(here::here(), "/data/slapnea22.RDS"))
europe_spdf <- readRDS(paste0(here::here(), "/data/europe_spdf.RDS"))
locations <- unique(slapnea22$location_name)