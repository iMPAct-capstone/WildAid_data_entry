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



#auto-authenticate google sheets ... this will have you interactively authenticate using broswer
options(gargle_oauth_cache = ".secrets/")
#auto authenticate without browser
gs4_auth(
cache = ".secrets",
email = "adelaide_robinson@ucsb.edu" #eventually want to change this to silvia's email
)

drive_auth(cache = ".secrets",
           email = "adelaide_robinson@ucsb.edu")

# dataframe that holds usernames, passwords and other user data
password_url <- "https://docs.google.com/spreadsheets/d/1pTWPJ10x66DgMFtFqy_8wZFPh8hgygkiBuGsW4BtejI/edit#gid=0"
password_sheet <- read_sheet(password_url, sheet = "data_entry")



user_base <- tibble::tibble(
  user = password_sheet$username,
  password = purrr::map_chr(password_sheet$password, sodium::password_store),
  permissions = password_sheet$permission,
  name = password_sheet$name
)

# Read in Data ----
# url for site list
site_url <- "https://docs.google.com/spreadsheets/d/1945sRz1BzspN4hCT5VOTuiNpwSSaWKxfoxZeozrn1_M/edit#gid=1669338265"

site_list <- read_sheet(site_url)


# find the current year plus 1----
# used for updating the default year in the app

current_year_minus_one <- year(Sys.Date()) - 1

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
                                year_entered, category, sub_category_entered, indicator_type, score, country, site_entered, comments_entered, evaluator) {
  # check whether this data already exists
  old_data <- as.data.frame(google_data)

  # filter google data to the specific year, site and subcategory entered
  old_data_2 <- old_data |> filter(year == as.numeric(year_entered) & site == site_entered & sub_category == sub_category_entered)

  # check that there is data to be written
  # if no data then don't do anything here
  if (score != "") {
    # if data has been entered then make a data frame
    if (comments_entered == ""){
      comments_entered <- NA
    }
    
    textB <- 
      data.frame(
        year = year_entered,
        category = category,
        sub_category = sub_category_entered,
        indicator_type = indicator_type,
        score = score,
        country = country,
        site = site_entered,
        comments = comments_entered,
        entered_by = evaluator,
        visualization_include = "yes"
      )
    
    
    #if there is old data 
    if (nrow(old_data_2) == 1) { 
      #make a placeholder to return since no data being appended
      
      
      #check if anything has changed
      
      old_data_check <- old_data_2 |>
        select(score,comments,entered_by) |> 
        mutate(comments =
                 case_when(is.na(comments) ~"None",
                           TRUE ~ comments))
      
      new_data_check <- textB |>
        select(score,comments,entered_by) |> mutate(comments =
                                                      case_when(is.na(comments) ~"None", TRUE ~ comments))
      # overwrite where it already exists and has changed
      row1 <- old_data_check[1, ]  # Row from the first data frame
      #make sure nas are comparable 
      row2 <- new_data_check[1, ]  # Row from the second data frame
      print("the problem is here")
      if(!row1$score == row2$score | !row1$comments == row2$comments | !row1$entered_by == row2$entered_by){
        print("overwriting")
        
        # Get the row index
        specific_row <- which(google_data$year == year_entered & google_data$site == site_entered & google_data$sub_category == sub_category_entered) + 1
        range_write(google_instance, data = textB, range = cell_rows(specific_row), col_names = FALSE) 
      }
      row <-0
      return(row)
      
    } else { # if it doesn't already exist then just append it to the bottom
      #add it to a data frame outside the list 
      row <- textB
      return(row)
      #sheet_append(google_instance, data = textB())
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


#summary table, should make this into a function that will take the rows from the google sheet that have been newly appended and output them into a dataframe 

