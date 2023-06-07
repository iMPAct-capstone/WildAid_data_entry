
# dashboard header ----------------------
entry_sur <- reactiveVal(FALSE)

# Dashboard Header ----  
header <-dashboardHeader(title = span(
  tags$img(src = "logo.png", height = "40px"),
  "MPS Tracker Data Entry", # main site title
  style = "color: #094074; font-size: 28px; font-family: 'Impact';",), 
  titleWidth = 400,
  # add logout button UI
  tags$li(
    class = "dropdown",
    tags$a(
      href = "https://github.com/iMPAct-capstone/WildAid_data_entry",
      target = "_blank",
      icon("question"),
      "Help"
    )
  ),
  
  tags$li(
    class = "dropdown",
    tags$a(
      href = "https://marine.wildaid.org/",
      target = "_blank",
      icon("fish"),
      "WildAid Marine"
    )
  ),
  tags$li(class = "dropdown", style = "margin-top: 10px; margin-right: 10px;", shinyauthr::logoutUI(id = "logout"))
) # End Dashboard header

# dashboard sidebar ----------------------
sidebar <- dashboardSidebar(
  collapsed = TRUE, sidebarMenuOutput("sidebar")
) # END Dashboard sidebar

# dashboardBody----

body <- dashboardBody(

  # add login panel UI function
  shinyauthr::loginUI(id = "login"),
  # setup table output to show user info after login
  tableOutput("user_table"),

  # tabItems ----
  tabItems(
    # Main Page data tabItem
    tabItem(
      tabName = "data",
      # fluidRow
      fluidRow(
        # start first column
        column(
          width = 6,
          # start data entry box
          box(
            width = NULL,
            textInput(inputId = "name_input", label = "Evaluator Name(s)"), # end text input

            numericInput(inputId = "year_input", label = "Data Year", value = current_year_minus_one, min = 2019, max = 2080), # end text input

            selectInput(
              inputId = "country_input", label = "Country",
              c("Select Option", unique(site_list$country)) # read list of countries from site sheet
            ), # end select input

            selectInput(
              inputId = "site_input", label = "Site",
              choices = "Select Option" # eventually replace this with an actual list pulling from a file
            ), # end site select input

            actionButton("next_1", "Save and Continue", class = "btn-primary", style="color: #FFFFFF; background-color: #094074"), # end next button
          ), # end data entry box
        ), # end column
        column(
          width = 6,
          box(width = NULL, title = "Data Entry Instructions",
            bsCollapse(
              id = "collapseExample",
              open = "Panel_data",
              bsCollapsePanel(
                title = HTML(paste0("Scoring <span class='arrow'>&#x25BE;</span>")),
                style = "info" ,  "There are six sections with 27 subcategories to score. Choose a score from the drop down menu based on the scoring criteria for each subcategory."),
           bsCollapsePanel(title = HTML(paste0("Saving <span class='arrow'>&#x25BE;</span>")), style = "info",
            "If you need to leave and come back to the application to finish entering data, your progress is saved once you select the 'save and continue' button at the bottom of the page.", tags$strong("If you exit or logout without clicking the save and continue button your data will not be saved")),
           bsCollapsePanel(HTML(paste0(" Translating (Traductorio) <span class='arrow'>&#x25BE;</span>")), style = "info", "To translate the instructions, use this application on Google Chrome. Set your preferences in Google Chrome to turn on translation for your preferred language. Begin by locating the ‘Customize and Control Google Chrome’ dropdown menu indicated by three dots on the right of the task bar. Navigate to Settings > Languages > Google Translate, select ‘Use Google Translate’ and select the language preference. Then, when on the data entry application, the right-click and select ‘Translate’ from the drop-down menu. More information on translating using Google Chrome can be found on", a("Google's help page", href = "https://support.google.com/chrome/answer/173424?hl=en&co=GENIE.Platform%3DDesktop#zippy=%2Cturn-translation-on-or-off")
           , br(),"Para traducir las instrucciones, utilice esta aplicación en Google Chrome. Configure sus preferencias en Google Chrome para activar la traducción en su idioma preferido. Comience localizando el menú desplegable Personalizar y controlar Google Chrome indicado por tres puntos a la derecha de la barra de tareas. Vaya a Configuración > Idiomas > Traductor de Google, seleccione Usar Traductor de Google y seleccione la preferencia de idioma. Luego, cuando esté en la aplicación de entrada de datos, haga clic con el botón derecho y seleccione Traducir en el menú desplegable. Puede encontrar más información sobre la traducción con Google Chrome en", a("la página de ayuda de Google", href = "https://support.google.com/chrome/answer/173424?hl=en&co=GENIE.Platform%3DDesktop#zippy=%2Cturn-translation-on-or-off.")
           
        ),
        bsCollapsePanel(HTML(paste0("Updating Data <span class='arrow'>&#x25BE;</span>")), style = "info", "If you enter a year and site combination for which there is already data, the boxes will auto populate with the previous data. Any changes will update the previously entered scores and comments. You will recieve a warning if you update values, please click ok to confirm."
                        
        ),# end panel
        
        bsCollapsePanel(HTML(paste0("Reviewing Submission <span class='arrow'>&#x25BE;</span>")), style = "info", "Please review and confirm accuraccy and completion of data on the final summary tab"
                        
        )# end panel
          ) #end bs collapse
      ) # end box
        ) # end column
      ), #end row

      # start next fluid row
      fluidRow(
        # start column
        column(12, ), # end column
      ), # end fluid row
    ), # end data main page tab item


    # Surveillance and enforcement tabItem ----
      
      tabItem(
        tabName = "enforcement",
        # first fluid row
        fluidRow(
          h1("Surveillance and Enforcement", align = "center"),
          br()
        ), # end title row
        
      
         uiOutput("ui_enforcement"),
        
       
        # start 6th fluid row
        fluidRow(
          column(10, ),
          column(2, align = "right", actionButton("next_2", "Save and Continue", class = "btn-primary", style="color: #FFFFFF; background-color: #094074")),
        ) # end 6th fluid row
        
        
      ), #end tab item

    # Policies and Consequences tabItem ----

    tabItem(
      tabName = "policies",
      # title row
      fluidRow(
        h1("Policies and Consequences", align = "center"),
        br()
      ), # end title 1st fluid row
      uiOutput("ui_policies"),
      # start fifth fluid row
      fluidRow(
        column(10, actionButton("prev_1", "Previous", class = "btn-primary", style="color: #FFFFFF; background-color: #094074")),
        column(2, align = "right", actionButton("next_3", "Save and Continue", class = "btn-primary", style="color: #FFFFFF; background-color: #094074")),
      ) # end fifth fluid row
    ), # end policies and consequences tabItem

     

    # Training and mentorship tabItem
    tabItem(
      tabName = "training",
      # title row
      fluidRow(
        h1("Training and Mentorship", align = "center"),
        br()
      ),
      uiOutput("ui_training"),
         
      # start fourth fluid row
      fluidRow(
        column(10, actionButton("prev_2", "Previous", class = "btn-primary", style="color: #FFFFFF; background-color: #094074")),
        column(2, align = "right", actionButton("next_4", "Save and Continue", class = "btn-primary", style="color: #FFFFFF; background-color: #094074")),
      ) # end fourth fluid row
      
    ), # end training and mentorship tab item

    # Community Engagement tabItem ----
    tabItem(
      tabName = "community",
      # title row
      fluidRow(
        h1("Community Engagement", align = "center"),
        br()
      ),
     uiOutput("ui_community"),
          
      # start fourth fluid row
      fluidRow(
        column(10, actionButton("prev_3", "Previous", class = "btn-primary",style="color: #FFFFFF; background-color: #094074")),
        column(2, align = "right", actionButton("next_5", "Save and Continue", class = "btn-primary",style="color: #FFFFFF; background-color: #094074")),
      ) # end fourth fluid row
    ), # end community engagement tabItem

    # Consistent Funding tabItem----
    tabItem(
      tabName = "funding",
      fluidRow(
        h1("Consistent Funding", align = "center"),
        br()
      ),
      
      uiOutput("ui_funding"),

      # start third fluid row
      fluidRow(
        column(10, actionButton("prev_4", "Previous", class = "btn-primary", style="color: #FFFFFF; background-color: #094074")),
        column(2, align = "right", actionButton("next_6", "Save and Continue", class = "btn-primary", style="color: #FFFFFF; background-color: #094074")),
      ) # end fourth fluid row
    ), # end consistent funding tab item
    
    
    #a new tab item can be added here 
    
    
    
    # a new tab item can end here 
    
    # start summary table tab item
    tabItem(
      h1("Summary", align = "center"),
      tabName = "summary",
      fluidRow(
        column(4, ),
        column(4, infoBoxOutput("my_info_box", width = NULL)
        
        ), column(4)),
      fluidRow(
        column(
          width = 12,
          div(class = "table-container",
            DTOutput("summary_table"))
          )
      ),
      #start 'save and exit' button
      fluidRow(
        column(10, actionButton("prev_5", "Previous", class = "btn-primary", style="color: #FFFFFF; background-color: #094074")),
        column(2, align = "right", actionButton("next_7", "Save and Exit", class = "btn-primary", style="color: #FFFFFF; background-color: #094074")),
      ), #end 'save & exit' button
    ) # end summary table tab item
  ) # end tab items
) # end dashboard body

dashboardPage(header, sidebar, body, skin= "black")


