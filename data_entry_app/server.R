source("./global.R")

# input and output will be lists of all defined inputs and outputs
server <- function(input, output, session) {
  entry_sur <- reactiveVal(FALSE)
  entry_pol <- reactiveVal(FALSE)
  entry_tra <- reactiveVal(FALSE)
  entry_comm <- reactiveVal(FALSE)
  entry_con <- reactiveVal(FALSE)
  
  progress <- reactiveVal(FALSE)
  
  # password authentication ----
  # call login module supplying data frame,
  # user and password cols and reactive trigger
  credentials <- shinyauthr::loginServer(
    id = "login",
    data = user_base,
    user_col = user,
    pwd_col = password,
    log_out = reactive(logout_init()),
    reload_on_logout = TRUE
  )
  
  # call the logout module with reactive trigger to hide/show
  logout_init <- shinyauthr::logoutServer(
    id = "logout",
    active = reactive(credentials()$user_auth)
  )
  
  # this opens or closes the sidebar on login/logout
  observe({
    if (credentials()$user_auth) {
      shinyjs::removeClass(selector = "body", class = "sidebar-collapse")
    } else {
      shinyjs::addClass(selector = "body", class = "sidebar-collapse")
    }
  })
  
  # only when credentials()$user_auth is TRUE, render your desired sidebar menu
  output$sidebar <- renderMenu({
    req(credentials()$user_auth)
    
    # render menu if authorized
    sidebarMenu(
      id = "tabs",
      menuItem(
        text = "Data Entry Main Page",
        tabName = "data",
        icon = icon("table")
      ),
      menuItem(
        text = "Surveillance and Enforcement",
        tabName = "enforcement",
        icon = icon("table")
      ),
      menuItem(
        text = "Policies and Consequences",
        tabName = "policies",
        icon = icon("table")
      ),
      menuItem(
        text = "Training and Mentorship",
        tabName = "training",
        icon = icon("table")
      ),
      menuItem(
        text = "Community Engagement",
        tabName = "community",
        icon = icon("table")
      ),
      menuItem(
        text = "Consistent Funding",
        tabName = "funding",
        icon = icon("table")
      )
    ) # END sidebar Menu
  })
  
  # next buttons and data entry ----
  # data tab next button
  observeEvent(input$next_1, {
    show_modal_spinner()
    newtab <- switch(input$tabs,
                     "data" = "enforcement",
                     "enforcement" = "data"
    )
    
    validate(
      need(input$year_input != "", message = "Please enter a year.")
    )
    if (input$country_input == "Select Option" && input$name_input == "") {
      showModal(modalDialog("Country, Site and Evaluator are required fields", easyClose = TRUE))
    } else if (input$country_input == "Select Option") {
      showModal(modalDialog("Please enter a country and site", easyClose = TRUE))
    } else if (input$site_input == "Select Option") {
      showModal(modalDialog("Please enter a site", easyClose = TRUE))
    } else if (input$name_input == "") {
      showModal(modalDialog("Please enter an evaluator", easyClose = TRUE))
      # proceed if all required fields are present
    } else{
      url <- "https://docs.google.com/spreadsheets/d/1RuMBpryb6Y7l8x6zP4hERyEJsj2GCodcL-vs9OPnLXY/edit#gid=0"
      master_sheet <- read_sheet(url) |> mutate(year = as.numeric(year)) 
      #test----
      for (i in seq_along(main_lookuptable$subcategory)) {
        # name of the subcategory
        sur_sub_category_name <- main_lookuptable$subcategory[i]
        
        # get the name of the score id
        sur_score_id <- main_lookuptable$score_id[i]
        
        # name of comment id
        sur_comment_id <- main_lookuptable$comment_id[i]
        
        data_update_function(master_sheet, sur_sub_category_name, sur_score_id, sur_comment_id, input$year_input, input$site_input,session) }
      # finally update the tab
      updateTabItems(session, "tabs", newtab)
      progress(TRUE)
      } })
  # end data tab next button
  
  observe(
    if (progress() && input$tabs == "enforcement"){
      remove_modal_spinner()
      })
  

  # enforcement tab next button
  observeEvent(input$next_2, {
    
    # create an object for switching tabs
    newtab <- switch(input$tabs,
                     "enforcement" = "policies",
                     "policies" = "enforcement"
    )
    # check year is not blank
    validate(
      need(input$year_input != "", message = "Please enter a year.")
    )
    # check if country has been updated
    if (input$country_input == "Select Option") {
      showModal(modalDialog("Please enter a country and site", easyClose = TRUE))
      # check that site has been updated
    } else if (input$site_input == "Select Option") {
      showModal(modalDialog("Please enter a site", easyClose = TRUE)) # check that name has been input
    } else if (input$name_input == "") {
      showModal(modalDialog("Please enter an evaluator", easyClose = TRUE))
      # if necessary boxes are filled out then proceed
    } else { 
      # change to the next tab
      updateTabItems(session, "tabs", newtab)
      entry_sur(TRUE)
    } 
  })
  
  
  # data entry for enforcement tab
  observe(
    if (entry_sur() && input$tabs == "policies") {
      
      # read in the google sheet
      # need to do this each time we write in case multiple people are on the app
      # identify the url
      url <- "https://docs.google.com/spreadsheets/d/1RuMBpryb6Y7l8x6zP4hERyEJsj2GCodcL-vs9OPnLXY/edit#gid=0"
      # get for writing to
      master_tracker <- gs4_get(url)
      # also read in for checking for existing data
      master_sheet <- read_sheet(url) |> mutate(year = as.numeric(year))
      
      
      process_iteration <- function(i) {
        sur_sub_category_name <- sur_lookuptable$subcategory[i]
        sur_score_input <- sur_lookuptable$score_id[i]
        sur_score_value <- input[[sur_score_input]]
        sur_comment_input <- sur_lookuptable$comment_id[i]
        sur_comment_value <- input[[sur_comment_input]]
        
        data_entry_function(
          google_instance = master_tracker,
          google_data = master_sheet,
          year_entered = input$year_input,
          category = "Surveillance and Enforcement",
          sub_category_entered = sur_sub_category_name,
          indicator_type = "Process Indicator",
          score = sur_score_value,
          country = input$country_input,
          site_entered = input$site_input,
          comments = sur_comment_value,
          evaluator = input$name_input
        )
      }
      
      lapply(seq_along(sur_lookuptable$subcategory), process_iteration)
      entry_sur(FALSE)
      
    }) # end enforcement tab data entry
  
  
 
  # policies and consequences previous button
  observeEvent(input$prev_1, {
    newtab <- switch(input$tabs,
                     "enforcement" = "policies",
                     "policies" = "enforcement"
    )
    
    # check year is not blank
    validate(
      need(input$year_input != "", message = "Please enter a year.")
    )
    # check if country has been updated
    if (input$country_input == "Select Option") {
      showModal(modalDialog("Please enter a country and site", easyClose = TRUE))
      # check that site has been updated
    } else if (input$site_input == "Select Option") {
      showModal(modalDialog("Please enter a site", easyClose = TRUE)) # check that name has been input
    } else if (input$name_input == "") {
      showModal(modalDialog("Please enter an evaluator", easyClose = TRUE))
      # if necessary boxes are filled out then proceed
    } else {
      # change to the last tab
      updateTabItems(session, "tabs", newtab)
      
      
    } 
  }) # end policies tab previous button
  

  # policies and consequences next button
  observeEvent(input$next_3, {
    newtab <- switch(input$tabs,
                     "policies" = "training",
                     "training" = "policies")
    
    validate(
      need(input$year_input != "", message = "Please enter a year.")
    )
    # check if country has been updated
    if (input$country_input == "Select Option") {
      showModal(modalDialog("Please enter a country and site", easyClose = TRUE))
      # check that site has been updated
    } else if (input$site_input == "Select Option") {
      showModal(modalDialog("Please enter a site", easyClose = TRUE)) # check that name has been input
    } else if (input$name_input == "") {
      showModal(modalDialog("Please enter an evaluator", easyClose = TRUE))
      # if necessary boxes are filled out then proceed
    } else { 
      # change to the next tab
      updateTabItems(session, "tabs", newtab)
      entry_pol(TRUE)
      
    }
  })
 #end policies tab next button
  
 # data entry for policies tab
   observe(
    if (entry_pol() && input$tabs == "training") {
       
       # read in the google sheet
       # need to do this each time we write in case multiple people are on the app
       # identify the url
       url <- "https://docs.google.com/spreadsheets/d/1RuMBpryb6Y7l8x6zP4hERyEJsj2GCodcL-vs9OPnLXY/edit#gid=0"
#       # get for writing to
       master_tracker <- gs4_get(url)
#       # also read in for checking for existing data
       master_sheet <- read_sheet(url) |> mutate(year = as.numeric(year))
      
#       
       for (i in seq_along(pol_lookuptable$subcategory)) {
        # name of the subcategory
         pol_sub_category_name <- pol_lookuptable$subcategory[i]
         
         # get the name of the score id
         pol_score_input <- pol_lookuptable$score_id[i]
         
         # get the value of the score
         pol_score_value <- input[[pol_score_input]]
         
         # name of comment id
         pol_comment_input <- pol_lookuptable$comment_id[i]
        
         # get the value of the comment
         pol_comment_value <- input[[pol_comment_input]]
         
         
         data_entry_function(google_instance = master_tracker, google_data = master_sheet, year_entered = input$year_input, category = "Policies and Consequences", sub_category_entered = pol_sub_category_name, indicator_type = "Process Indicator", score = pol_score_value, country = input$country_input, site_entered = input$site_input, comments = pol_comment_value, evaluator = input$name_input)
       }
       
       entry_sur(FALSE)
     }) 
  # end policies tab data entry
  
# training and mentorship next button
  observeEvent(input$next_4, {
    newtab <- switch(input$tabs,
                     "training" = "community",
                     "community" = "training"
    )
    
    validate(
      need(input$year_input != "", message = "Please enter a year.")
    )
    # check if country has been updated
    if (input$country_input == "Select Option") {
      showModal(modalDialog("Please enter a country and site", easyClose = TRUE))
      # check that site has been updated
    } else if (input$site_input == "Select Option") {
      showModal(modalDialog("Please enter a site", easyClose = TRUE)) # check that name has been input
    } else if (input$name_input == "") {
      showModal(modalDialog("Please enter an evaluator", easyClose = TRUE))
      # if necessary boxes are filled out then proceed
    } else { 
      # change to the next tab
      updateTabItems(session, "tabs", newtab)
     entry_tra(TRUE)
    }
  }) # end training tab next button
  
#start training tab data entry
  observe(
    if (entry_tra() && input$tabs == "community") {
      
      # read in the google sheet
      # need to do this each time we write in case multiple people are on the app
      # identify the url
      url <- "https://docs.google.com/spreadsheets/d/1RuMBpryb6Y7l8x6zP4hERyEJsj2GCodcL-vs9OPnLXY/edit#gid=0"
      # get for writing to
      master_tracker <- gs4_get(url)
      # also read in for checking for existing data
      master_sheet <- read_sheet(url) |> mutate(year = as.numeric(year))
      
      tra_lookup_url <- "https://docs.google.com/spreadsheets/d/1FeezrizNeRAPYXBG1uBqu_3lLLl0PZyKCyVU8wOKUYI/edit#gid=0"
      tra_lookuptable <- read_sheet(tra_lookup_url)
      
      
      for (i in seq_along(tra_lookuptable$subcategory)) {
        # name of the subcategory
        tra_sub_category_name <- tra_lookuptable$subcategory[i]
        
        # get the name of the score id
        tra_score_input <- tra_lookuptable$score_id[i]
        
        # get the value of the score
        tra_score_value <- input[[tra_score_input]]
        
        # name of comment id
        tra_comment_input <- tra_lookuptable$comment_id[i]
        
        # get the value of the comment
        tra_comment_value <- input[[tra_comment_input]]
        
        
        data_entry_function(google_instance = master_tracker, google_data = master_sheet, year_entered = input$year_input, category = "Training and Mentorship", sub_category_entered = tra_sub_category_name, indicator_type = "Process Indicator", score = tra_score_value, country = input$country_input, site_entered = input$site_input, comments = tra_comment_value, evaluator = input$name_input)
      }
      entry_tra(FALSE)
    }) 
# end training tab data entry
  
# training & mentorship tab previous button
  observeEvent(input$prev_2, {
    newtab <- switch(input$tabs,
                     "community" = "training",
                     "training" = "community"
    )
    
    # check year is not blank
    validate(
      need(input$year_input != "", message = "Please enter a year.")
    )
    # check if country has been updated
    if (input$country_input == "Select Option") {
      showModal(modalDialog("Please enter a country and site", easyClose = TRUE))
      # check that site has been updated
    } else if (input$site_input == "Select Option") {
      showModal(modalDialog("Please enter a site", easyClose = TRUE)) # check that name has been input
    } else if (input$name_input == "") {
      showModal(modalDialog("Please enter an evaluator", easyClose = TRUE))
      # if necessary boxes are filled out then proceed
    } else {
      # change to the last tab
      updateTabItems(session, "tabs", newtab)
      
      
    } 
  }) # end training and mentorship tab previous button
  
# community engagement next button
  observeEvent(input$next_5, {
    newtab <- switch(input$tabs,
                     "community" = "funding",
                     "funding" = "community"
    )
    entry_comm(TRUE) 
      updateTabItems(session, "tabs", newtab)
    } ) # end community engagement next button
  
  
#start community engagement data entry
  observe(
    if (entry_comm() && input$tabs == "funding") {
      
      # read in the google sheet
      # need to do this each time we write in case multiple people are on the app
      # identify the url
      url <- "https://docs.google.com/spreadsheets/d/1RuMBpryb6Y7l8x6zP4hERyEJsj2GCodcL-vs9OPnLXY/edit#gid=0"
      # get for writing to
      master_tracker <- gs4_get(url)
      # also read in for checking for existing data
      master_sheet <- read_sheet(url) |> mutate(year = as.numeric(year))
      
      
      for (i in seq_along(comm_lookuptable$subcategory)) {
        # name of the subcategory
        comm_sub_category_name <- comm_lookuptable$subcategory[i]
        
        # get the name of the score id
        comm_score_input <- comm_lookuptable$score_id[i]
        
        # get the value of the score
        comm_score_value <- input[[comm_score_input]]
        
        # name of comment id
        comm_comment_input <- comm_lookuptable$comment_id[i]
        
        # get the value of the comment
        comm_comment_value <- input[[comm_comment_input]]
        
        
        data_entry_function(google_instance = master_tracker, google_data = master_sheet, year_entered = input$year_input, category = "Community Engagement", sub_category_entered = comm_sub_category_name, indicator_type = "Process Indicator", score = comm_score_value, country = input$country_input, site_entered = input$site_input, comments = comm_comment_value, evaluator = input$name_input) }
        
        entry_comm(FALSE)
    })
#end community engagement data entry  

  
  
# community engagement tab previous button
  observeEvent(input$prev_3, {
    newtab <- switch(input$tabs,
                     "funding" = "community",
                     "community" = "funding"
    )
    
    # check year is not blank
    validate(
      need(input$year_input != "", message = "Please enter a year.")
    )
    # check if country has been updated
    if (input$country_input == "Select Option") {
      showModal(modalDialog("Please enter a country and site", easyClose = TRUE))
      # check that site has been updated
    } else if (input$site_input == "Select Option") {
      showModal(modalDialog("Please enter a site", easyClose = TRUE)) # check that name has been input
    } else if (input$name_input == "") {
      showModal(modalDialog("Please enter an evaluator", easyClose = TRUE))
      # if necessary boxes are filled out then proceed
    } else {
      # change to the last tab
      updateTabItems(session, "tabs", newtab)
      
      
    } 
  }) # end community engagement tab previous button
  
# consistent funding next button
  observeEvent(input$next_6, {
    newtab <- switch(input$tabs,
                     "funding" = "data",
                     "data" = "funding"
                     
            
    )  
    # check year is not blank
    validate(
      need(input$year_input != "", message = "Please enter a year.")
    )
    # check if country has been updated
    if (input$country_input == "Select Option") {
      showModal(modalDialog("Please enter a country and site", easyClose = TRUE))
      # check that site has been updated
    } else if (input$site_input == "Select Option") {
      showModal(modalDialog("Please enter a site", easyClose = TRUE)) # check that name has been input
    } else if (input$name_input == "") {
      showModal(modalDialog("Please enter an evaluator", easyClose = TRUE))
      # if necessary boxes are filled out then proceed
    } else {
      entry_con(TRUE)
      # change to the last tab
      updateTabItems(session, "tabs", newtab)
      
      
    } 
    
    })
    
#consistent funding tab data entry
  
  #start consistent funding data entry
  observe(
    if (entry_con() && input$tabs == "data") {
      
      # read in the google sheet
      # need to do this each time we write in case multiple people are on the app
      # identify the url
      url <- "https://docs.google.com/spreadsheets/d/1RuMBpryb6Y7l8x6zP4hERyEJsj2GCodcL-vs9OPnLXY/edit#gid=0"
      # get for writing to
      master_tracker <- gs4_get(url)
      # also read in for checking for existing data
      master_sheet <- read_sheet(url) |> mutate(year = as.numeric(year))
      
      con_lookup_url <- "https://docs.google.com/spreadsheets/d/1DSc-2LVlrFbdYTyFo7o-2V55OPkrFA6pVLOM6ZJuhYE/edit#gid=0"
      con_lookuptable <- read_sheet(con_lookup_url)
      
      
      for (i in seq_along(con_lookuptable$subcategory)) {
        # name of the subcategory
        con_sub_category_name <- con_lookuptable$subcategory[i]
        
        # get the name of the score id
        con_score_input <- con_lookuptable$score_id[i]
        
        # get the value of the score
        con_score_value <- input[[con_score_input]]
        
        # name of comment id
        con_comment_input <- con_lookuptable$comment_id[i]
        
        # get the value of the comment
        con_comment_value <- input[[con_comment_input]]
        
        
        data_entry_function(google_instance = master_tracker, google_data = master_sheet, year_entered = input$year_input, category = "Consistent Funding", sub_category_entered = con_sub_category_name, indicator_type = "Process Indicator", score = con_score_value, country = input$country_input, site_entered = input$site_input, comments = con_comment_value, evaluator = input$name_input)
      }
        
        #end consistent funding tab data entry
      
      entry_con(FALSE) 
    })
  
  
  # consistent funding tab previous button
    observeEvent(input$prev_4, {
      newtab <- switch(input$tabs,
                       "data" = "funding",
                       "funding" = "data")
        updateTabItems(session, "tabs", newtab)
        }) # end consistent funding tab previous button
    
  
  # end next buttons
  
#scroll when you switch tabs
  observeEvent(input$tabs,{ shinyjs::runjs("window.scrollTo(0, 0)")
   })
  
  # #end of data entry 
    
  # update site choices ----
  observeEvent(input$country_input, {
    if (input$country_input %in% site_list$country) {
      new_data <- site_list |> filter(country == input$country_input)
      updateSelectInput(session, "site_input",
                        choices = new_data$site
      )
    }
    if (input$country_input == "Select Option") {
      updateSelectInput(session, "site_input",
                        choices = "Select Option"
      )
    }
  }) # end observe input country box

}
