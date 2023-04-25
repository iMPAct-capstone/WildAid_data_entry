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
site_url <- "https://docs.google.com/spreadsheets/d/1945sRz1BzspN4hCT5VOTuiNpwSSaWKxfoxZeozrn1_M/edit#gid=1669338265"

site_list <- read_sheet(site_url)


#master_tracker <- gs4_get("https://docs.google.com/spreadsheets/d/1RuMBpryb6Y7l8x6zP4hERyEJsj2GCodcL-vs9OPnLXY/edit#gid=0")

# find the current year plus 1----
#used for updating the default year in the app

current_year_plus_one <- year(Sys.Date()) + 1

#create a data entry function

data_entry_function <- function(google_instance,
                        google_data,
                        year_entered, category, sub_category_entered, indicator_type, score, country, site_entered, comments, evaluator){
  ## start of "surveillance prioritization data entry----
  # check whether this data already exists
  # check whether this data already exists
  old_data <- as.data.frame(google_data)
  
  old_data_2 <- old_data |> filter(year == as.numeric(year_entered) & site == site_entered & sub_category == sub_category_entered)
  
  # check that there is data to be written
  # if no data then don't do anything here
  if (score != "") {
    # if data has been entered then make a data frame
    textB <- reactive({
      data.frame(
        year = year_entered,
        category = category,
        sub_category = sub_category_entered,
        indicator_type = indicator_type,
        score = score,
        country = country,
        site = site_entered,
        if (comments != "") {
          comments <- comments
        } else {
          comments <- "NA"
        },
        entered_by = evaluator,
        visualization_include = "yes"
      )
    })
    
          if (nrow(old_data_2) == 1) {
          # overwrite where it already exists
          # Get the row index
          specific_row <- which(google_data$year == year_entered & google_data$site == site_entered & google_data$sub_category == sub_category_entered) + 1
          range_write(google_instance, data = textB(), range = cell_rows(specific_row), col_names = FALSE)
          # if it doesn't already exist then just append it to the bottom
        } else { # Append data to Google Sheet
          sheet_append(google_instance, data = textB())
        } #end of surveillance prioritization data entry
      } # end of all data entry for this category
  
  
}