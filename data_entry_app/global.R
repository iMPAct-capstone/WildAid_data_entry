
# Load packages ----
library(shiny)
library(shinydashboard) 
library(tidyverse)
library(shinycssloaders)
library(googlesheets4)

# Read in Data ---- 
#url for site list 
url <- "https://docs.google.com/spreadsheets/d/1945sRz1BzspN4hCT5VOTuiNpwSSaWKxfoxZeozrn1_M/edit#gid=1669338265"

site_list <- read_sheet(url)

