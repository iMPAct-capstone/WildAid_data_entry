

# input and output will be lists of all defined inputs and outputs
server <- function(input, output, session) {

# password authentication ----
  # call login module supplying data frame,
  # user and password cols and reactive trigger
  credentials <- shinyauthr::loginServer(
    id = "login",
    data = user_base,
    user_col = user,
    pwd_col = password,
    sodium_hashed = TRUE,
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
      ),
      #add a new category menu item here
      
      
      #end new category menu item here
      menuItem(
        text = "Summary",
        tabName = "summary",
        icon = icon("table")
      )
    ) # END sidebar Menu
  })
  
# next buttons and data entry ----
#data tab functions ----
  
  progress <- reactiveVal(FALSE)
  
  # data tab next button
  observeEvent(input$next_1, {
    show_modal_spinner(spin = "spring",
                       color ="#094074")
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
      master_sheet <- read_sheet(main_sheet_id) |> 
        mutate(year = as.numeric(year))
      
      
      # read in the existing data
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
      #check on and save backup     
      #look in the backup folder
      backup_list <- drive_ls("https://drive.google.com/drive/folders/14npufqTR_om8HrzhkKVx2S4trHbiuwuS")
      
      
      #find the backup dates
      backup_list <- backup_list |> 
        mutate(backup_date = mdy(str_remove(name, "MPS_backup_")))
      #find the date of the last backup if there is one
      if (nrow(backup_list) > 0) {
        last_backup <- max(backup_list$backup_date)
        days_since_backup <- as.numeric(Sys.Date() - last_backup) } else {days_since_backup <- 100}
      if (days_since_backup > 14){
        #save the google sheet to the backup folder
        file_name <- paste0("MPS_backup_", 
                            month(Sys.Date()), "_",
                            day(Sys.Date()), "_",
                            year(Sys.Date()))
        gs4_create(name = file_name, sheets = main_sheet)
        
        folder_id <- "14npufqTR_om8HrzhkKVx2S4trHbiuwuS"
        drive_mv(file_name, path = as_id(folder_id))
        
      }
      
      progress(TRUE)
    } })
  # end data tab next button
  
  #once we get to the next page remove the loading spinner
  observe(
    
    if (progress() && input$tabs == "enforcement"){
      remove_modal_spinner()
    })
  
#update site choices on data tab
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
  
#start enforcement tab actions----
  
  #reactive value used to trigger data entry
  entry_sur <- reactiveVal(FALSE)
  
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
      #if any of the boxes are empty show a warning message
      
      
    } 
  })
  
  
  # data entry for enforcement tab
  observe(
    if (entry_sur() && input$tabs == "policies") {
      
      # read in the google sheet
      # need to do this each time we write in case multiple people are on the app
      
      main_sheet <- read_sheet(main_sheet_id) |> 
        mutate(year = as.numeric(year))
      
      #read in lookup table
      sur_lookuptable <- main_lookuptable |> 
        filter(tab == "enforcement")
      
      
      #initiate empty data frame
      append_data <- tibble()   
      for (i in seq_along(sur_lookuptable$subcategory)) {
        # name of the subcategory
        sur_sub_category_name <- sur_lookuptable$subcategory[i]
        
        # get the name of the score id
        sur_score_input <- sur_lookuptable$score_id[i]
        # get the value of the score
        sur_score_value <- input[[sur_score_input]]
        # name of comment id
        sur_comment_input <- sur_lookuptable$comment_id[i]
        # get the value of the comment
        sur_comment_value <- input[[sur_comment_input]]
        
        sur_row <-  data_entry_function(
          google_instance = main_sheet_id,
          google_data = main_sheet,
          year_entered = input$year_input,
          category = "Surveillance and Enforcement",
          sub_category_entered = sur_sub_category_name,
          indicator_type = "Process Indicator",
          score = sur_score_value,
          country = input$country_input,
          site_entered = input$site_input,
          comments_entered = sur_comment_value,
          evaluator = input$name_input
        )
        
        if (!is.null(nrow(sur_row))){
          
          append_data <- bind_rows(sur_row, append_data) 
          
        }
        
      }
      if (nrow(append_data) >0){
        sheet_append(main_sheet_id, data = append_data) }
      entry_sur(FALSE)
    }
  )  # end enforcement tab data entry
  
#end enforcement tab actions
  
#start policies tab actions----
  entry_pol <- reactiveVal(FALSE)
  # policies and consequences previous button
  observeEvent(input$prev_1, {
    newtab <- switch(input$tabs,
                     "enforcement" = "policies",
                     "policies" = "enforcement"
    )
    
    # change to the last tab
    updateTabItems(session, "tabs", newtab)
  } 
  ) # end policies tab previous button
  
  
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
      
      
      # read in for checking for existing data
      main_sheet <- read_sheet(main_sheet_id) |> mutate(year = as.numeric(year))
      
      pol_lookuptable <- main_lookuptable |> 
        filter(tab == "policies")
      
      #initiate empty data frame
      append_data <- tibble()   
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
        
        
        pol_row <- data_entry_function(google_instance = main_sheet_id, google_data = main_sheet, year_entered = input$year_input, category = "Policies and Consequences", sub_category_entered = pol_sub_category_name, indicator_type = "Process Indicator", score = pol_score_value, country = input$country_input, site_entered = input$site_input, comments_entered = pol_comment_value, evaluator = input$name_input)
        
        if (!is.null(nrow(pol_row))){
          append_data <- bind_rows(pol_row, append_data) 
          
        }
        
      }
      if (nrow(append_data) >0){
        sheet_append(main_sheet_id, data = append_data) }
      entry_pol(FALSE)
    }
  ) 
  # end policies tab data entry
#end policies tab actions
  
  
#start training and mentorship tab actions----
  entry_tra <- reactiveVal(FALSE)
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
  
  # training and mentorship previous button
  observeEvent(input$prev_2, {
    newtab <- switch(input$tabs,
                     "training" = "policies",
                     "policies" = "training")
    # change to the last tab
    updateTabItems(session, "tabs", newtab)
  }) # end training and mentorship tab previous button
  
  
  #start training tab data entry
  observe(
    if (entry_tra() && input$tabs == "community") {
      
      # read in the google sheet
      # need to do this each time we write in case multiple people are on the app
      
      # also read in for checking for existing data
      main_sheet <- read_sheet(main_sheet_id) |> 
        mutate(year = as.numeric(year))
      
      tra_lookuptable <- main_lookuptable |> 
        filter(tab == "training")
      
      append_data <- tibble()
      
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
        
        
        tra_row <- data_entry_function(google_instance = main_sheet_id, google_data = main_sheet, year_entered = input$year_input, category = "Training and Mentorship", sub_category_entered = tra_sub_category_name, indicator_type = "Process Indicator", score = tra_score_value, country = input$country_input, site_entered = input$site_input, comments_entered = tra_comment_value, evaluator = input$name_input)
        if (!is.null(nrow(tra_row))){
          append_data <- bind_rows(tra_row, append_data) 
          
        }
        
      }
      if (nrow(append_data) >0){
        sheet_append(main_sheet_id, data = append_data) }
      
      entry_tra(FALSE)
    }) 
  # end training tab data entry
#start community engagement tab actions ----  
  entry_comm <- reactiveVal(FALSE)

  # community engagement tab previous button
  observeEvent(input$prev_3, {
    newtab <- switch(input$tabs,
                     "training" = "community",
                     "community" = "training")
    # change to the last tab
    updateTabItems(session, "tabs", newtab)
  }) # end community engagement tab previous button
  
  
  # community engagement next button
  observeEvent(input$next_5, {
    
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
    
    
    
    newtab <- switch(input$tabs,
                     "community" = "funding",
                     "funding" = "community"
    )
    entry_comm(TRUE) 
    updateTabItems(session, "tabs", newtab)
    
    }
  } ) # end community engagement next button
  
  
  #start community engagement data entry
  observe(
    if (entry_comm() && input$tabs == "funding") {
      
      # read in the google sheet
      # need to do this each time we write in case multiple people are on the app
      
      # also read in for checking for existing data
      main_sheet <- read_sheet(main_sheet_id) |> 
        mutate(year = as.numeric(year))
      
      comm_lookuptable <- main_lookuptable |> 
        filter(tab == "community")
      
      #initialize blank data frame
      append_data <- tibble()
      
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
        
        
        comm_row <- data_entry_function(google_instance = main_sheet_id, google_data = main_sheet, year_entered = input$year_input, category = "Community Engagement", sub_category_entered = comm_sub_category_name, indicator_type = "Process Indicator", score = comm_score_value, country = input$country_input, site_entered = input$site_input, comments_entered = comm_comment_value, evaluator = input$name_input) 
        if (!is.null(nrow(comm_row))){
          
          append_data <- bind_rows(comm_row, append_data) 
          
        }
        
      }
      if (nrow(append_data) >0){
        sheet_append(main_sheet_id, data = append_data) }
      entry_comm(FALSE)
    }
  ) 
  #end community engagement data entry  
  
  
  
#start consistent funding tab actions ----
  entry_con <- reactiveVal(FALSE)
  #consistent funding tab data entry
  
  #start consistent funding data entry
  observe(
    if (entry_con()) {
      
      
      # read in the google sheet
      # need to do this each time we write in case multiple people are on the app
      # identify the url
      # also read in for checking for existing data
      main_sheet <- read_sheet(main_sheet_id) |> 
        mutate(year = as.numeric(year))
      
      con_lookuptable <- main_lookuptable |> 
        filter(tab == "funding")
      
      #initialize blank data frame
      append_data <- tibble()
      
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
        
        
        con_row <- data_entry_function(google_instance = main_sheet_id, google_data = main_sheet, year_entered = input$year_input, category = "Consistent Funding", sub_category_entered = con_sub_category_name, indicator_type = "Process Indicator", score = con_score_value, country = input$country_input, site_entered = input$site_input, comments_entered = con_comment_value, evaluator = input$name_input)
        if (!is.null(nrow(con_row))){
          append_data <- bind_rows(con_row, append_data) 
          
        }
        
      }
      if (nrow(append_data) >0){
        sheet_append(main_sheet_id, data = append_data) }
      entry_con(FALSE)
    }
  ) 
  


  # consistent funding tab previous button
  observeEvent(input$prev_4, {
    newtab <- switch(input$tabs,
                     "community" = "funding",
                     "funding" = "community")
    updateTabItems(session, "tabs", newtab)
  }) # end consistent funding tab previous button
  
  # consistent funding next button
  observeEvent(input$next_6, {
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
    
    newtab <- switch(input$tabs,
                     "funding" = "summary",
                     "data" = "summary")  
    # change to the last tab
    updateTabItems(session, "tabs", newtab)
    entry_con(TRUE)
    }
  })
  
# end consistent funding tab actions
  
#add buttons and data entry functionality for a new category here----
  
  
#end buttons and data entry functionality for a new category here 
  
  
  
#summary tab functionality----
  
  summary_data <- reactiveVal(NULL)
  
  # Use observeEvent to trigger the reading of the sheet when input$tabs changes to "summary"
  observeEvent(input$tabs, {
    if (input$tabs == "summary") {
      show_modal_spinner(spin = "spring",
                         color ="#094074")
      main_sheet_new <- read_sheet(main_sheet_id) %>%
        mutate(year = as.numeric(year)) |> 
        filter(year == input$year_input,
               site == input$site_input) |> 
        select(-c(indicator_type, visualization_include,
                  entered_by, country))
      summary_data(main_sheet_new)
      remove_modal_spinner()
      
      subcategories_completed <- nrow(main_sheet_new)
      # Update the infoBox value based on the variable
      output$my_info_box <- renderInfoBox({
        if (subcategories_completed == 27) {
          infoBox(
            color = "green",
            title = NULL,
            value = paste0(subcategories_completed, " of 27 subcategories completed"),
            width = NULL,
            icon = icon('check-circle', lib = "font-awesome")
          )
        } else {
          infoBox(
            color = "red",
            title = NULL,
            value = paste0(subcategories_completed, " of 27 subcategories completed"),
            width = NULL,
            icon = icon('circle-exclamation', lib = "font-awesome")
          )
        }
      })
      
    }
  })
  
  #once summary table loads remove the loading spinner
  observe(
    
    if (progress() && input$tabs == "summary"){
      remove_modal_spinner()
    })
  
  #start 'save and exit' button summary tab
  observeEvent(input$next_7, {
    shinyalert(
      title = "Thank you!",
      text = "Your data has been submitted.",
      type = "success"
    )
  }) #end 'save and exit' button on summary tab
  
  #start summary tab 'previous button'
  observeEvent(input$prev_5, {
    newtab <- switch(input$tabs,
                     "funding" = "summary",
                     "summary" = "funding")
    updateTabItems(session, "tabs", newtab)
  }) #end summary tab 'previous button  
  
#end summary tab functionality
# general functionality ----  
  
  #scroll when you switch tabs
  observeEvent(input$tabs,{ shinyjs::runjs("window.scrollTo(0, 0)")
  })

  
 
  
  #function to generate the previous data tables  
  previous_data_reactive <- function(subcategory){
    filtered_data <- main_sheet %>%
      filter(year < as.numeric(input$year_input) & sub_category == subcategory & site == input$site_input) |> 
      select(year, score, comments)
    return(filtered_data)
  } 
  
  #render all of the reactives in a list
  #pull the subcategories as a list  
  sub_categories <- main_lookuptable$subcategory
  #pull the ids as a list 
  ids <- main_lookuptable$id
  
  reactive_objects <- reactive({
    
    list_data <-lapply(sub_categories, previous_data_reactive)
    names(list_data) <- ids
    return(list_data)
  })
  #end of function to generate the tables
  
  #generate all of the tables using the function 
  
  #function with code for generating tables 
  generateTableRenderCode <- function(id) {
    table_code <- paste0("output$table_", id, " <- renderDT({",
                         "datatable(reactive_objects()[['", id, "']],",
                         "options = list(dom = 't',",
                         "paging = FALSE,",
                         "autowidth = TRUE,",
                         "scrollCollapse = TRUE,",
                         "order = list(list(0, 'desc'))",
                         "),",
                         "rownames = FALSE)",
                         "})")
    return(table_code)
  }  
  
  # Render tables for each subcategory
  #name will be table_id
  for (id in seq_along(ids)) {
    eval(parse(text = generateTableRenderCode(ids)))
  }
  
  
 
  
  #DT summary data table ----
  output$summary_table <- DT::renderDataTable(
    DT::datatable(data = summary_data(),
                  rownames = FALSE,
                  escape=TRUE, 
                  caption = "Review data entered before submission.",
                  options = list(
                    searching = FALSE, paging = FALSE  # Disable the search function
                  )))
  
  
#Dynamically generate ui for each tab ---- 
  enforcement_row <- main_lookuptable |> filter(tab == "enforcement")
  
  v <- list()
  current_row <- fluidRow()
  box_counter <- 0
  
  for (i in 1:nrow(enforcement_row)) {
    current_place <- enforcement_row[i,]
    box <- sub_category_box(current_place)
    column <- column(width = 4, box)
    current_row <- tagAppendChild(current_row, column)
    box_counter <- box_counter + 1
    
    
    if (box_counter == 3 || i == nrow(enforcement_row)) {
      # Add the current row to the list and reset the counter and row
      v[[length(v) + 1]] <- current_row
      current_row <- fluidRow()
      box_counter <- 0
    }
  }

  output$ui_enforcement <- renderUI(v)
  outputOptions(output, "ui_enforcement", suspendWhenHidden = FALSE)

  
#repeat for policies
  policies_row <- main_lookuptable |> filter(tab == "policies")
  
  p <- list()
  current_row <- fluidRow()
  box_counter <- 0
  
  for (i in 1:nrow(policies_row)) {
    current_place <- policies_row[i,]
    box <- sub_category_box(current_place)
    column <- column(width = 4, box)
    current_row <- tagAppendChild(current_row, column)
    box_counter <- box_counter + 1
    
    
    if (box_counter == 3 || i == nrow(policies_row)) {
      # Add the current row to the list and reset the counter and row
      p[[length(p) + 1]] <- current_row
      current_row <- fluidRow()
      box_counter <- 0
    }
  }
  
  output$ui_policies <- renderUI(p)
  outputOptions(output, "ui_policies", suspendWhenHidden = FALSE)
  
  
#repeat for training
  
  training_row <- main_lookuptable |> filter(tab == "training")
  
  t <- list()
  current_row <- fluidRow()
  box_counter <- 0
  
  for (i in 1:nrow(training_row)) {
    current_place <- training_row[i,]
    box <- sub_category_box(current_place)
    column <- column(width = 4, box)
    current_row <- tagAppendChild(current_row, column)
    box_counter <- box_counter + 1
    
    
    if (box_counter == 3 || i == nrow(training_row)) {
      # Add the current row to the list and reset the counter and row
      t[[length(t) + 1]] <- current_row
      current_row <- fluidRow()
      box_counter <- 0
    }
  }
  
  output$ui_training <- renderUI(t)
  
  outputOptions(output, "ui_training", suspendWhenHidden = FALSE)
  
#repeat for community
  
  community_row <- main_lookuptable |> filter(tab == "community")
  
  co <- list()
  current_row <- fluidRow()
  box_counter <- 0
  
  for (i in 1:nrow(community_row)) {
    current_place <- community_row[i,]
    box <- sub_category_box(current_place)
    column <- column(width = 4, box)
    current_row <- tagAppendChild(current_row, column)
    box_counter <- box_counter + 1
    
    
    if (box_counter == 3 || i == nrow(community_row)) {
      # Add the current row to the list and reset the counter and row
      co[[length(co) + 1]] <- current_row
      current_row <- fluidRow()
      box_counter <- 0
    }
  }
  
  output$ui_community <- renderUI(co)
  
  outputOptions(output, "ui_community", suspendWhenHidden = FALSE)
  
#repeat for funding
  funding_row <- main_lookuptable |> filter(tab == "funding")
  
  f <- list()
  current_row <- fluidRow()
  box_counter <- 0
  
  for (i in 1:nrow(funding_row)) {
    current_place <- funding_row[i,]
    box <- sub_category_box(current_place)
    column <- column(width = 4, box)
    current_row <- tagAppendChild(current_row, column)
    box_counter <- box_counter + 1
   
    
    if (box_counter == 3 || i == nrow(funding_row)) {
      # Add the current row to the list and reset the counter and row
      f[[length(f) + 1]] <- current_row
      current_row <- fluidRow()
      box_counter <- 0
    }
    } 
  
  output$ui_funding <- renderUI(f)
  
  outputOptions(output, "ui_funding", suspendWhenHidden = FALSE)
  
  
  
  
}


