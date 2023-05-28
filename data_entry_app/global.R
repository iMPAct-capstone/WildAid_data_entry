# Load packages ----
library(shiny)
library(shinydashboard)
library(tidyverse)
library(shinycssloaders)
library(googlesheets4)
library(lubridate)
library(shinyBS)
library(shinybusy)
library(DT)
library(googledrive)
library(lubridate)



# auto-authenticate google sheets ... this will have you interactively authenticate using broswer
# options(gargle_oauth_cache = ".secrets/")
 #auto authenticate without browser
  # gs4_auth(
  # cache = ".secrets",
  # email = "adelaide_robinson@ucsb.edu" #eventually want to change this to silvia's email
  # )

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


# find the current year plus 1----
# used for updating the default year in the app

current_year_plus_one <- year(Sys.Date()) + 1

#create validation and old data pulling function----
data_update_function <- function(google_data,
                                 sub_category_needed,
                                 score_box_id, comment_box_id,
                                 year_input, site_input,session) {
  
  existing_data_check <- google_data |>
    filter(
      year == year_input &
        site == site_input &
        sub_category == sub_category_needed
    ) 
  
  if (nrow(existing_data_check) == 1) {
    updateSelectInput(session, score_box_id, selected = existing_data_check$score)
    updateTextInput(session, inputId = comment_box_id, value = existing_data_check$comments)
  } else {
    updateSelectInput(inputId = score_box_id, selected = "")
    updateTextInput(inputId = comment_box_id, value = "")
  }
}

#create a data entry function----

data_entry_function <- function(google_instance,
                                google_data,
                                year_entered, category, sub_category_entered, indicator_type, score, country, site_entered, comments, evaluator) {
  # check whether this data already exists
  old_data <- as.data.frame(google_data)

  # filter google data to the specific year, site and subcategory entered
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
    } # end of surveillance prioritization data entry
  } # end of all data entry for this category
}


#read in the combined lookup table 
lookup_id_url <- "https://docs.google.com/spreadsheets/d/1rrjUr8uxrLINKsoYWifX_D0_XoDmbM7m5Ji8QVHmUIs/edit#gid=0"
main_lookuptable <- read_sheet(lookup_id_url)


#read in all the data
folder_url <- "https://drive.google.com/drive/u/0/folders/11jjznh0MFuhy8oLxHp8uGePF4xR5T-GW"
files <- drive_ls(folder_url) |>
  filter(name == "data_entry_test")
main_sheet_id <- as_id(files)
main_sheet <- read_sheet(main_sheet_id) |> mutate(year = as.numeric(year))
