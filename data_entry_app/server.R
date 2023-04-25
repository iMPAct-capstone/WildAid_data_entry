source("./global.R")

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
    newtab <- switch(input$tabs,
      "data" = "enforcement",
      "enforcement" = "data"
    )
    validate(
      need(input$year_input != "", message = "Please enter a year.")
    )
    if (input$country_input == "Select Option" && input$name_input == "") {
      showModal(modalDialog("Country, Site and Evaluator are required fiels", easyClose = TRUE))
    } else if (input$country_input == "Select Option") {
      showModal(modalDialog("Please enter a country and site", easyClose = TRUE))
    } else if (input$site_input == "Select Option") {
      showModal(modalDialog("Please enter a site", easyClose = TRUE))
    } else if (input$name_input == "") {
      showModal(modalDialog("Please enter an evaluator", easyClose = TRUE))
      # proceed if all required fields are present
    } else {
      url <- "https://docs.google.com/spreadsheets/d/1RuMBpryb6Y7l8x6zP4hERyEJsj2GCodcL-vs9OPnLXY/edit#gid=0"
      # read in the sheet
      master_sheet <- read_sheet(url)

      # check whether this data already exists
      existing_data_check <- master_sheet |>
        filter(
          year == input$year_input,
          site == input$site_input,
          sub_category == "Surveillance Prioritization"
        )
      # if data already exists on the g-sheet, update boxes
      if (nrow(existing_data_check) == 1) {
        updateSelectInput(session, "surv_pri_score", selected = existing_data_check$score)
        updateTextInput(session, inputId = "surv_pri_comments", value = existing_data_check$comments)
      }
      # finally update the tab
      updateTabItems(session, "tabs", newtab)
    }
  }) # end data tab next button
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
      # read in the google sheet
      # need to do this each time we write in case multiple people are on the app
      # identify the url
      url <- "https://docs.google.com/spreadsheets/d/1RuMBpryb6Y7l8x6zP4hERyEJsj2GCodcL-vs9OPnLXY/edit#gid=0"
      # get for writing to
      master_tracker <- gs4_get(url)
      # also read in for checking for existing data
      master_sheet <- read_sheet(url) |> mutate(year = as.numeric(year))
      
      data_entry_function(google_instance = master_tracker, google_data = master_sheet, year_entered = input$year_input, category = "Surveillance and Enforcement", sub_category_entered = "Surveillance Prioritization", indicator_type = "Process Indicator", score = input$surv_pri_score, country = input$country_input, site_entered = input$site_input, comments = input$surv_pri_comments, evaluator = input$name_input)
  
      # change to the next tab
      updateTabItems(session, "tabs", newtab)
    }
  }) # end enforcement tab next button

  # policies and consequences next button
  observeEvent(input$next_3, {
    newtab <- switch(input$tabs,
      "policies" = "training",
      "training" = "policies"
    )
    updateTabItems(session, "tabs", newtab)
  }) # end policies tab next button

  # training and mentorship next button
  observeEvent(input$next_4, {
    newtab <- switch(input$tabs,
      "training" = "community",
      "community" = "training"
    )
    updateTabItems(session, "tabs", newtab)
  }) # end training tab next button

  # community engagement next button
  observeEvent(input$next_5, {
    newtab <- switch(input$tabs,
      "community" = "funding",
      "funding" = "community"
    )
    updateTabItems(session, "tabs", newtab)
  }) # end community engagement next button

  # end next buttons

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
