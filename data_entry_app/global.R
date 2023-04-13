
# Load packages ----
library(shiny)
library(shinydashboard) 
library(tidyverse)
library(shinycssloaders)
library(googlesheets4)


# dataframe that holds usernames, passwords and other user data
user_base <- tibble::tibble(
  user = c("user1", "user2"),
  password = c("pass1", "pass2"),
  permissions = c("admin", "standard"),
  name = c("User One", "User Two")
)

# Read in Data ---- 
#url for site list 
url <- "https://docs.google.com/spreadsheets/d/1945sRz1BzspN4hCT5VOTuiNpwSSaWKxfoxZeozrn1_M/edit#gid=1669338265"

site_list <- read_sheet(url)

