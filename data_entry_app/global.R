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
library(shinyalert)
library(here)

warning_message <- reactiveVal(FALSE)

warning_ready <- reactiveVal(FALSE) 

subcategories_needed <- NULL

subcategories_completed <- NULL


#reactive list used for data that needs to be appended
append_frames <- reactiveValues(frames = list(), location = list())



#auto-authenticate google sheets ... this will have you interactively authenticate using broswer

options(gargle_oauth_cache = ".secrets/")
#auto authenticate without browser
gs4_auth(
cache = ".secrets",
email = "adelaide.robinson445@gmail.com" #eventually want to change this to silvia's email
)


drive_auth(cache = ".secrets",
           email = "adelaide.robinson445@gmail.com")

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

#read in the site list, only using current sites as an option 
tic()
site_list <- read_sheet(site_url) |>
  filter(active_site == "current")
toc()

# find the current year plus 1----
# used for updating the default year in the app

current_year_minus_one <- year(Sys.Date()) - 1

#create validation and old data pulling function----
duplicate <- reactiveVal(FALSE)

data_update_function <- function(google_data,
                                 sub_category_needed,
                                 score_box_id, comment_box_id,
                                 year_input, site_input,session) {
  
  existing_data_check <- google_data |>
    filter(
      year == year_input &
        site == site_input &
        sub_category == sub_category_needed
    ) |> mutate(score = as.character(score)) |> 
    mutate(score =
           case_when(is.na(score) ~"NA",
                     TRUE ~ score))
  
  
  if (nrow(existing_data_check) == 1) {
    updateSelectInput(session, score_box_id, selected = existing_data_check$score)
    updateTextInput(session, inputId = comment_box_id, value = existing_data_check$comments)
  } else if (nrow(existing_data_check > 1)){
    showModal(modalDialog("There appears to be a duplicate subcategory for the year and site you have entered, please contact the Marine Program manager to fix before completing data entry"))
    duplicate(TRUE) 
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
        score = as.numeric(score),
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
        mutate(score = as.character(score)) |> 
        mutate(comments =
                 case_when(is.na(comments) ~"None",
                           TRUE ~ comments),
               score = case_when(is.na(score) ~"None",
                                 TRUE ~score)) 
      
      new_data_check <- textB |>
        select(score,comments,entered_by) |> 
        mutate(score = as.character(score)) |> 
        mutate(comments = case_when(is.na(comments) ~"None",
                                    TRUE ~ comments),
               score = case_when(is.na(score) ~"None",
                                 TRUE ~score))
      # overwrite where it already exists and has changed
      row1 <- old_data_check[1, ]  # Row from the first data frame
      #make sure nas are comparable 
      row2 <- new_data_check[1, ]  # Row from the second data frame
    
      if(!row1$score == row2$score | !row1$comments == row2$comments){
        
        warning_message(TRUE)
        # Get the row index
        specific_row <- which(google_data$year == year_entered & google_data$site == site_entered & google_data$sub_category == sub_category_entered) + 1
        # range_write(google_instance, data = textB, range = cell_rows(specific_row), col_names = FALSE) 
        
        # Append the data frame to the list
        append_frames$frames <- c(append_frames$frames, list(textB))
        append_frames$location <- c(append_frames$location, specific_row)
        
        
      }
      row <-0
      return(row)
      
    } else { 
      #add it to a data frame outside the list 
      row <- textB
      return(row)
    } # end of surveillance prioritization data entry
  } # end of all data entry for this category
}


 #read in the combined lookup table 
lookup_id_url <- "https://docs.google.com/spreadsheets/d/1E_5OGhMWS1so8xu0vqcOQZy3vDKRGIugGsSBwtQbrIk/edit#gid=1796709482"
main_lookuptable <- read_sheet(lookup_id_url)


#read in all the data
folder_url <- "https://drive.google.com/drive/u/1/folders/1AvavGBfoZx_ThcXVn5gL_buQkip76ZtQ"
files <- drive_ls(folder_url) |>
  filter(name == "data_entry_test")
main_sheet_id <- as_id(files)
main_sheet <- read_sheet(main_sheet_id) |>
  mutate(year = as.numeric(year))



#ui function
sub_category_box <- function(inputrow, sub_category_number){
  my_box <- box(
    width = NULL, title = inputrow$subcategory,
    paste("Question", sub_category_number, "of", nrow(main_lookuptable)),
    id = inputrow$id,
    bsCollapse(id = inputrow$collapse_id,
      bsCollapsePanel(
        title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
        style = "info", br(tags$strong("1="), inputrow$score_1),
        br(tags$strong("3 ="), inputrow$score_3), br(tags$strong("5 ="), inputrow$score_5)
      ),
      bsCollapsePanel(
        title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
        div(
          class = "table-container",
          DTOutput(inputrow$previous_table)
        )
      )
    ),
    # end of collapsed scoring guidelines
    
    selectInput(
      inputId = inputrow$score_id, label = "Score",
      choices = c("", "1", "2", "3", "4", "5", "NA")
    ),
    textInput(inputId = inputrow$comment_id, " Comments")
  ) # end surveillance prioritization box
  
  return(my_box)
  
}
 
