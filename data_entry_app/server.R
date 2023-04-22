

#input and output will be lists of all defined inputs and outputs
server <- function(input, output, session)
{ 
#password authentication ----
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
    if(credentials()$user_auth) {
      shinyjs::removeClass(selector = "body", class = "sidebar-collapse")
    } else {
      shinyjs::addClass(selector = "body", class = "sidebar-collapse")
    }
  })
  
  # only when credentials()$user_auth is TRUE, render your desired sidebar menu
  output$sidebar <- renderMenu({
    req(credentials()$user_auth)
    #sidebar menu
    sidebarMenu(
      id = "tabs",
      menuItem(text = "Data Entry Main Page",
               tabName = "data",
               icon = icon("table")),
      
      menuItem(text = "Surveillance and Enforcement",
               tabName = "enforcement",
               icon = icon("table")),
      
      menuItem(text = "Policies and Consequences",
               tabName = "policies",
               icon = icon("table")),
      
      menuItem(text = "Training and Mentorship",
               tabName = "training",
               icon = icon("table")),
      
      menuItem(text = "Community Engagement",
               tabName = "community",
               icon = icon("table")),
      
      menuItem(text = "Consistent Funding",
               tabName = "funding",
               icon = icon("table"))
      
    ) #END sidebar Menu
    
  })  

#next buttons ----  
  #data tab next button
    observeEvent(input$next_1, {
      newtab <- switch(input$tabs, "data" = "enforcement","enforcement" = "data")
      validate(
        need(input$year_input != '', message = "Please enter a year.")
      )
      if (input$country_input == "Select Option") {
        showModal(modalDialog("Please enter a country and site", easyClose = TRUE))
      } else if (input$site_input == "Select Option") {
        showModal(modalDialog("Please enter a site", easyClose = TRUE))
      } else if (input$name_input == "") {
        showModal(modalDialog("Please enter an evaluator", easyClose = TRUE))
      } else {
        updateTabItems(session, "tabs", newtab)
      }
    }) 
  
  observeEvent(input$next_2, {
    newtab <- switch(input$tabs, "enforcement" = "policies", "policies" = "enforcement")
    validate(
      need(input$year_input != '', message = "Please enter a year.")
    )
    if (input$country_input == "Select Option") {
      showModal(modalDialog("Please enter a country and site", easyClose = TRUE))
    } else if (input$site_input == "Select Option") {
      showModal(modalDialog("Please enter a site", easyClose = TRUE))
    } else if (input$name_input == "") {
      showModal(modalDialog("Please enter an evaluator", easyClose = TRUE))
    } else {
      updateTabItems(session, "tabs", newtab)
    }
  }) #end enforcement tab next button 
  
  #policies and consequences next button 
  observeEvent(input$next_3, {
    newtab <- switch(input$tabs, "policies" = "training", "training" = "policies")
    updateTabItems(session, "tabs", newtab)
  }) #end policies tab next button
  
  #training and mentorship next button
  observeEvent(input$next_4, {
    newtab <- switch(input$tabs, "training" = "community", "community" = "training")
    updateTabItems(session, "tabs", newtab)
  }) #end training tab next button
  
  #community engagement next button
  observeEvent(input$next_5, {
    newtab <- switch(input$tabs, "community" = "funding", "funding" = "community")
    updateTabItems(session, "tabs", newtab)
  }) #end community engagement next button
  
  
# end next buttons

#update site choices ---- 
  observeEvent(input$country_input,{
    if (input$country_input %in% site_list$country){
      new_data <- site_list |> filter(country == input$country_input)
    updateSelectInput(session, 'site_input',
                      choices= new_data$site)}
    if (input$country_input == "Select Option"){
      updateSelectInput(session, 'site_input',
                        choices= "Select Option")}
    
  }) #end observe input country box  

#Data entry ----
#Surveilance and Enforcement Tab
  
  textB <- reactive({
    data.frame(year = input$year_input,
               category = "Surveillance and Enforcement",
               sub_category = 'Surveillance Prioritization',
               indicator_type = "Process Indicator",
               score= input$surv_pri_score,
               #country= input$country_input,
               site= input$site_input,
               comments = input$surv_pri_comments,
               entered_by = input$name_input,
               visualization_include = "yes")
  })
  
  observeEvent(input$next_2, {
    sheet <- gs4_get('https://docs.google.com/spreadsheets/d/1RuMBpryb6Y7l8x6zP4hERyEJsj2GCodcL-vs9OPnLXY/edit#gid=0')
    if (input$year_input != "" && input$country_input != "Select Option" && input$site_input != "Select Option" && input$name_input != "") {
      # Append data to Google Sheet
      sheet_append(sheet, data = textB())
    }
  })
  
  
}