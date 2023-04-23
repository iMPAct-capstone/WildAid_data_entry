# Load packages ----
library(shiny)
library(shinydashboard)
library(tidyverse)
library(shinycssloaders)
library(googlesheets4)
library(lubridate)

# dataframe that holds usernames, passwords and other user data
user_base <- tibble::tibble(
  user = c("user1", "user2"),
  password = c("pass1", "pass2"),
  permissions = c("admin", "standard"),
  name = c("User One", "User Two")
)

# Read in Data ----
# url for site list
url <- "https://docs.google.com/spreadsheets/d/1945sRz1BzspN4hCT5VOTuiNpwSSaWKxfoxZeozrn1_M/edit#gid=1669338265"

site_list <- read_sheet(url)


master_tracker <- gs4_get("https://docs.google.com/spreadsheets/d/1RuMBpryb6Y7l8x6zP4hERyEJsj2GCodcL-vs9OPnLXY/edit#gid=0")

# find the current year plus 1----
#used for updating the default year in the app

current_year_plus_one <- year(Sys.Date()) + 1
