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

    # password authentication ----
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

  # next buttons ----
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
    } else {
      url <- "https://docs.google.com/spreadsheets/d/1RuMBpryb6Y7l8x6zP4hERyEJsj2GCodcL-vs9OPnLXY/edit#gid=0"
      master_sheet <- read_sheet(url)
      # check whether this data already exists
      existing_data <- master_sheet |> filter(
        year == input$year_input,
        site == input$site_input,
        sub_category == "Surveillance Prioritization"
      ) 
      #if data already exists on the g-sheet, update boxes
      if (nrow(existing_data) == 1) {
        updateSelectInput(session, "surv_pri_score", selected = existing_data$score)
        updateTextInput(session, inputId = "surv_pri_comments", value = existing_data$comments)
      }
      #finally update the tab
      updateTabItems(session, "tabs", newtab)
    }
  }) #end data tab next button

  observeEvent(input$next_2, {
    newtab <- switch(input$tabs,
      "enforcement" = "policies",
      "policies" = "enforcement"
    )
    validate(
      need(input$year_input != "", message = "Please enter a year.")
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

  # Data entry ----

# Surveilance and Enforcement Tab

  textB <- reactive({
    data.frame(
      year = input$year_input,
      category = "Surveillance and Enforcement",
      sub_category = "Surveillance Prioritization",
      indicator_type = "Process Indicator",
      score = input$surv_pri_score,
      country = input$country_input,
      site = input$site_input,
      if (input$surv_pri_comments != "") {
        comments <- input$surv_pri_comments
      } else {
        comments <- "NA"
      },
      entered_by = input$name_input,
      visualization_include = "yes"
    )
  })

  observeEvent(input$next_2, {
    master_tracker <- gs4_get("https://docs.google.com/spreadsheets/d/1RuMBpryb6Y7l8x6zP4hERyEJsj2GCodcL-vs9OPnLXY/edit#gid=0")

    url <- "https://docs.google.com/spreadsheets/d/1RuMBpryb6Y7l8x6zP4hERyEJsj2GCodcL-vs9OPnLXY/edit#gid=0"

    master_sheet <- read_sheet(url)

    # check whether this data already exists
    existing_data <- master_sheet |> filter(
      year == input$year_input,
      site == input$site_input,
      sub_category == "Surveillance Prioritization"
    )
    # first check that there is data to be written
    # if no data to be written, do nothing
    validate(
      need(input$year_input != "", message = "Please enter a year.")
    )
    if (input$year_input != "" && input$country_input != "Select Option" && input$site_input != "Select Option" && input$name_input != "" && input$surv_pri_score != "") {
      # next check whether the data already exists and needs to be updated
      if (nrow(existing_data) == 1) {
        # overwrite where it already exists
        # Get the row index
        specific_row <- which(master_sheet$year == input$year_input & master_sheet$site == input$site_input & master_sheet$sub_category == "Surveillance Prioritization") + 1
        range_write(url, data = textB(), range = cell_rows(specific_row), col_names = FALSE)
        # if it doesn't already exist then just append it to the bottom
      } else { # Append data to Google Sheet
        sheet_append(master_tracker, data = textB())
      }
    }
  })
}
