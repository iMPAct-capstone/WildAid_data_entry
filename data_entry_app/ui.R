
# dashboard header ----------------------

# Dashboard Header ----  
header <-dashboardHeader(title = span(
  tags$img(src = "logo.png", height = "30px"),
  "WildAid Marine MPS Tracker Data Explorer", # main site title
  style = "color: #094074; font-size: 28px; font-family: 'Impact'"),
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
          6,
          # start data entry box
          box(
            width = 12,
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
           bsCollapsePanel(HTML(paste0(" Translating (Traductorio) <span class='arrow'>&#x25BE;</span>")), style = "info", "To translate the instructions, use this application on Google Chrome and use these instructions to enable Google Translate.", br(),"Para traducir las instrucciones, use esta aplicación en Google Chrome y use estas instrucciones para habilitar Google Translate."
           
        ),
        bsCollapsePanel(HTML(paste0("Updating Data <span class='arrow'>&#x25BE;</span>")), style = "info", "If you enter a year and site combination for which there is already data, the boxes will auto populate with the previous data. Any changes will update the previously entered scores and comments."
                        
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
      # second fluid Row
      fluidRow(
        # first column in the row
        column(
          6,

          # surveillance prioritization box
          box(
            width = 12, title = "Surveillance Prioritization",
            "Question 1 of 27",
            id = "sur_pri",
            bsCollapse(
              id = "collapseExample",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "No priority areas are defined or priority areas are not under surveillance."),
                br(tags$strong("3 ="), "Some of the priority areas are under constant surveillance via regular patrols and surveillance equipment or all priority areas are monitored, but not continuously."), br(tags$strong("5 ="), "100% of the priority areas are monitored continuously via regular patrols and surveillance equipment.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_sur_pri")
                )
              )
            ),
            # end of collapsed scoring guidelines

            selectInput(
              inputId = "sur_pri_score", label = "Score",
              choices = c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "sur_pri_comments", " Comments")
          ) # end surveillance prioritization box
        ), # END FIRST COLUMN IN THE ROW
        # start second column

        column(
          6,
          # Patrol Planning Box
          box(
            width = 12, title = "Patrol Planning", "Question 2 of 27", id = "pat_pla",
            bsCollapse(
              id = "pat_pla_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "The enforcement agency does not engage in a formal patrol planning process."),
                br(tags$strong("3 ="), "The enforcement agency has a patrol plan but it is not implemented consistently."), br(tags$strong("5 ="), "The enforcement agency follows a strategic, data-driven patrol plan.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info", 
                div(
                  class = "table-container",
                  DTOutput("table_pat_pla")
                )
              )
            ),
          
            selectInput(
              inputId = "pat_pla_score", label = "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "pat_pla_comments", " Comments")
          ) # end patrol planning box
        ) # end second column in the row
      ), # end second fluid row

      # third fluid Row
      fluidRow(
        # first column in the row
        column(
          6,
          # start vessel availability box
          box(
            width = 12, title = "Vessel Availability",
            "Question 3 of 27", id = "ves_ava",
            bsCollapse(
              id = "ves_ava_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "Vessels are in poor shape. Vessel availability is low."),
                br(tags$strong("3 = "), "Vessels are in good condition. Vessel availability is average (approximately 50% or more)."), br(tags$strong("5 ="), "Vessels are in good condition. Vessel availability is higher than 75%.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_ves_ava")
                )
              )
            ),
            selectInput(
              inputId = "ves_ava_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "ves_ava_comments", " Comments")
          ) # end vessel availability box
        ), # end first column in the row
        # second column
        column(
          6,
          # start patrol execution box
          box(
            width = 12, title = "Patrol Execution",
            "Question 4 of 27", id = "pat_exe",
            bsCollapse(
              id = "pat_exe_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "The enforcement agency does not conduct patrols."),
                br(tags$strong("3 ="), "The enforcement agency conduct some patrols but they are infrequent, inconsistent, and not targeted for high-risk areas."), br(tags$strong("5 ="), "The enforcement agency conducts frequent, consistent, strategic, data-driven patrols.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_pat_exe")
                )
              )
            ),
            selectInput(
              inputId = "pat_exe_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "pat_exe_comments", " Comments")
          ) # end patrol execution box
        ), # end second column
      ), # end third fluid row

      # start fourth fluid row
      fluidRow(
        # first column in the row
        column(
          6,
          # start fleet adequacy box
          box(
            width = 12, title = "Fleet Adequacy", "Question 5 of 27", id = "fle_ade",
            bsCollapse(
              id = "fle_ade_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "There are not enough vessels to patrol the marine area and/ or they are not the right kinds of vessels."),
                br(tags$strong("3 ="), "There are enough vessels to patrol the marine area, but they are not the right kind of vessels (e.g. coastal vessels only when the marine area needs oceanic)."), br(tags$strong("5 ="), " There are enough vessels to patrol the marine area. The marine area has the right types of vessels for their needs.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_fle_ade")
                )
              )
            ),
            selectInput(
              inputId = "fle_ade_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "fle_ade_comments", " Comments")
          ) # end fleet adequacy box
        ), # end first column in the row
        # second column
        column(
          6,
          # start patrol equipment box
          box(
            width = 12, title = "Patrol Equipment", "Question 6 of 27", id = "pat_equ",
            bsCollapse(
              id = "pat_equ_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "Patrol vessels lack essential safety equipment and boarding kits."),
                br(tags$strong("3 ="), "Patrol vessels are equipped with essential safety equipment, but lack adequate boarding kits, or vice versa."), br(tags$strong("5 ="), "Patrol vessels are equipped with both essential safety equipment and boarding kits.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_pat_equ")
                )
              )
            ),
            selectInput(
              inputId = "pat_equ_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "pat_equ_comments", " Comments")
          ) # end patrol equipment box
        ), # end second column
      ), # end fourth fluid row

      # start fifth fluid row
      fluidRow(
        # first column in the row
        column(
          6,
          # start Intelligence Sources box
          box(
            width = 12, title = "Intelligence Sources", "Question 7 of 27", id = "int_sou",
            bsCollapse(
              id = "int_sou_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "Intelligence information is limited to what is gathered from patrols."),
                br(tags$strong("3 ="), "The enforcement agency has some access to external intelligence (e.g. informants or surveillance technology)."), br(tags$strong("5 ="), "The enforcement agency uses multiple channels to gather intelligence information, including but not limited to: surveillance technology to track infractions as they occur, an informant hotline, and other outside sources.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_int_sou")
                )
              )
            ),
        
            selectInput(
              inputId = "int_sou_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "int_sou_comments", " Comments")
          ) # end Intelligence Sources box
        ), # end first column in the row
        # second column
        column(
          6,
          # start investigation procedures box
          box(
            width = 12, title = "Investigation Procedures", "Question 8 of 27", id = "inv_pro",
            bsCollapse(
              id = "inv_pro_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "There are no boarding or chain of custody procedures in place."),
                br(tags$strong("3 ="), "There are some investigation procedures in place, but they have not have been reviewed or approved by legal teams."), br(tags$strong("5 ="), "There are boarding and chain of custody procedures in place. These have been reviewed and approved by legal teams.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_inv_pro")
                )
              )
            ),
            selectInput(
              inputId = "inv_pro_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "inv_pro_comments", " Comments")
          ) # end investigation procedures box
        ), # end second column
      ), # end fifth fluid row

      # start sixth fluid row
      fluidRow(
        # first column in the row
        column(
          6,
          # start Institutional Collaboration (National) box
          box(
            width = 12, title = "Institutional Collaboration (National)", "Question 9 of 27", id = "nat_inst",
            bsCollapse(
              id = "nat_inst_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), " Overlapping jurisdictions, unclear lines of authority, and/or competing interests lead to limited or no focus on enforcement."),
                br(tags$strong("3 ="), "Overlapping jurisdictions, unclear lines of authority, and/or competing interests lead to inefficient, ineffective, or minimal enforcement."), br(tags$strong("5 ="), "Institutions have clearly defined responsibilities and collaborate effectively on enforcement efforts.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_nat_inst")
                )
              )
            ),
            selectInput(
              inputId = "nat_inst_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "nat_inst_comments", " Comments")
          ) # end Institutional Collaboration (National) box
        ), # end first column in the row
        # second column
        column(
          6,
          # start Institutional Collaboration (International/Regional - if applicable) box
          box(
            width = 12, title = "Institutional Collaboration (International/Regional - if applicable)", "Question 10 of 27", id = "int_inst",
            bsCollapse(
              id = "int_inst_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "Overlapping jurisdictions, unclear lines of authority, and/or competing interests lead to limited or no focus on enforcement of foreign-flagged fishing infractions."),
                br(tags$strong("3 ="), "Overlapping jurisdictions, unclear lines of authority, and/or competing interests lead to inefficient, ineffective, or minimal enforcement of foreign-flagged fishing infractions."), br(tags$strong("5 ="), "Individual countries have clearly defined responsibilities and collaborate effectively on enforcement efforts.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_int_inst")
                )
              )
            ),
            selectInput(
              inputId = "int_inst_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "int_inst_comments", " Comments")
          ) # end Institutional Collaboration (International/Regional - if applicable) box
        ), # end second column
      ), # end sixth fluid row

      # start seventh fluid row
      fluidRow(
        # first column in the row
        column(
          6,
          # start Staff numbers box
          box(
            width = 12, title = "Staff Numbers", "Question 11 of 27", id = "sta_num",
            bsCollapse(
              id = "sta_num_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "There are no staff for enforcement operations (e.g. surveillance such as patrols and community engagement)."),
                br(tags$strong("3 ="), "Staff numbers are insufficient for enforcement operations and/ or staff retention is low."), br(tags$strong("5 ="), "Staff numbers are sufficient for enforcement operations. Staff retention and/ or morale are high.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_sta_num")
                )
              )
            ),
            selectInput(
              inputId = "sta_num_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "sta_num_comments", " Comments")
          ) # end staff numbers box
        ), # end first column in the row
      ), # end seventh fluid row

      # start eighth fluid row
      fluidRow(
        column(10, ),
        column(2, actionButton("next_2", "Save and Continue", class = "btn-primary", style="color: #FFFFFF; background-color: #094074")),
      ) # end eighth fluid row
    ), # end surveillance and enforcement tab item

    # Policies and Consequences tabItem ----

    tabItem(
      tabName = "policies",
      # title row
      fluidRow(
        h1("Policies and Consequences", align = "center"),
        br()
      ), # end title row
      # second fluid Row
      fluidRow(
        # first column in the row
        column(
          6,

          # start Laws and Regulations box
          box(
            width = 12, title = "Laws and Regulations", "Question 12 of 27", id = "law_reg",
            bsCollapse(
              id = "law_reg_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "Law/regulations are unclear (have many loopholes) or not enforceable re: prohibited species, activities, tools/gear that can be used in the area."),
                br(tags$strong("3 ="), "Laws/regulations are clear (few loopholes) or not enforceable Or vice versa re: prohibited species, activities, tools/gear that can be used in the area."), br(tags$strong("5 ="), "Laws/regulations are clear (no loopholes) and enforceable re: prohibited species, activities, tools / gear that can be used in the area.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_law_reg")
                )
              )
            ),
            selectInput(
              inputId = "law_reg_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "law_reg_comments", " Comments")
          ) # end Laws and Regulations box
        ), # END FIRST COLUMN IN THE ROW
        # start second column

        column(
          6,
          # start Zoning (n/a for EEZ-wide projects) Box
          box(
            width = 12, title = "Zoning (n/a for EEZ-wide projects)", "Question 13 of 27", id = "zon",
            bsCollapse(
              id = "zon_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "Marine area size and zoning does not match conservation goals/address threats or is difficult to enforce."),
                br(tags$strong("3 ="), "Marine area size and zoning aligns with some conservation goals and addresses some threats but not all and/ or is easier to enforce."), br(tags$strong("5 ="), "Marine area size and zoning aligns with key conservation goals and addresses key threats, and is enforceable.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_zon")
                )
              )
            ),
            selectInput(
              inputId = "zon_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "zon_comments", " Comments")
          ) # end Zoning (n/a for EEZ-wide projects) box
        ) # end second column in the row
      ), # end second fluid row

      # third fluid Row
      fluidRow(
        # first column in the row
        column(
          6,
          # start Sanctions / Prosecutions box
          box(
            width = 12, title = "Sanctions/Prosecutions", "Question 14 of 27", id = "san_pro",
            bsCollapse(
              id = "san_pro_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "Few cases are sanctioned and/or sanctions levied are not strong enough to deter future illegal activity."),
                br(tags$strong("3 ="), "A majority of cases are sanctioned; however sanctions are not strong enough to act as a deterrent."), br(tags$strong("5 ="), "A majority of cases are strongly sanctioned to the extent of the law.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_san_pro")
                )
              )
            ),
            selectInput(
              inputId = "san_pro_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "san_pro_comments", " Comments")
          ) # end Sanctions / Prosecutions box
        ), # end first column in the row
        # second column
        column(
          6,
          # start case database box
          box(
            width = 12, title = "Case Database", "Question 15 of 27", id = "cas_dat",
            bsCollapse(
              id = "cas_dat_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "There is no central database to keep track of cases."),
                br(tags$strong("3 ="), "There is a database, but it is not used regularly or it does not track all information needed."), br(tags$strong("5 ="), "There is a central database that is consistently used for case monitoring, follow up, and to track repeat offenders.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_cas_dat")
                )
              )
            ),
        
            selectInput(
              inputId = "cas_dat_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "cas_dat_comments", " Comments")
          ) # end case database box
        ), # end second column
      ), # end third fluid row

      # start fourth fluid row
      fluidRow(
        # first column in the row
        column(
          6,
          # start Scientific Monitoring box
          box(
            width = 12, title = "Scientific Monitoring", "Question 16 of 27", id = "sci_mon",
            bsCollapse(
              id = "sci_mon_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "No scientific monitoring or baseline assessments of target species are carried out."),
                br(tags$strong("3 ="), "Scientific monitoring is currently being carried out and/ or a baseline has been established."), br(tags$strong("5 ="), "Baseline sudies and assessments are regularly carried out for target marine species or priority habitat, and assessments are integrated into the management plan.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_sci_mon")
                )
              )
            ),
            selectInput(
              inputId = "sci_mon_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "sci_mon_comments", " Comments")
          ) # end Scientific Monitoring box
        ), # end first column in the row
      ), # end fourth fluid row

      # start fifth fluid row
      fluidRow(
        column(10, actionButton("prev_1", "Previous", class = "btn-primary", style="color: #FFFFFF; background-color: #094074")),
        column(2, actionButton("next_3", "Save and Continue", class = "btn-primary", style="color: #FFFFFF; background-color: #094074")),
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
      # second fluid Row
      fluidRow(
        # first column in the row
        column(
          6,

          # start Enforcement Training box
          box(
            width = 12, title = "Enforcement Training", "Question 17 of 27", id = "enf_tra",
            bsCollapse(
              id = "enf_tra_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), " No standardized enforcement training exists for staff and other relevant agencies."),
                br(tags$strong("3 ="), "Enforcement training for staff and other relevant agencies may exist, but training is irregular and not comprehensive."), br(tags$strong("5 ="), "Staff and other relevant agencies receive regular enforement trainings (sometimes multi-agency).")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_enf_tra")
                )
              )
            ),
            selectInput(
              inputId = "enf_tra_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "enf_tra_comments", " Comments")
          ) # end Enforcement Training box
        ), # END FIRST COLUMN IN THE ROW
        # start second column

        column(
          6,
          # start Standard Operating Procedures (SOPs) Box
          box(
            width = 12, title = "Standard Operating Procedures (SOPs)", "Question 18 of 27", id = "sta_ope",
            bsCollapse(
              id = "sta_ope_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "No operational SOPs exist for enforcement staff and other relevant agencies."),
                br(tags$strong("3 ="), "Some operational SOPs for enforcement staff and other relevant agencies may exist, but SOPs are outdated or incomplete."), br(tags$strong("5 ="), "Enforcement staff and other relevant agencies have comprehensive operational SOPs covering boarding, crime scene investigation, and chain of custody procedures. All relevant staff receive regular trainings (sometimes multi-agency) on SOPs and SOPs are updated annually.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_sta_ope")
                )
              )
            ),
            selectInput(
              inputId = "sta_ope_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "sta_ope_comments", " Comments")
          ) # end Standard Operating Procedures (SOPs) box
        ) # end second column in the row
      ), # end second fluid row

      # third fluid Row
      fluidRow(
        # first column in the row
        column(
          6,
          # start Staff Qualifications box
          box(
            width = 12, title = "Staff Qualifications", "Question 19 of 27", id = "sta_qua",
            bsCollapse(
              id = "sta_qua_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "Agency staff are not qualified for enforcement work."),
                br(tags$strong("3 ="), "Agency staff receive minimal enforcement training."), br(tags$strong("5 ="), "Agency staff receive regular comprehensive enforcement training and are qualified for their jobs. Staff is selected based on experience. Training occurs regularly and includes all relevant topics. Site has received 'train-the-trainer' instruction.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_sta_qua")
                )
              )
            ),
            selectInput(
              inputId = "sta_qua_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "sta_qua_comments", " Comments")
          ) # end Staff Qualifications box
        ), # end first column in the row
        # start second column
        column(
          6,
          # start Legal Training Box
          box(
            width = 12, title = "Legal Training", "Question 20 of 27", id = "leg_tra",
            bsCollapse(
              id = "leg_tra_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "Legal team does not exist or has not been trained."),
                br(tags$strong("3 ="), "Legal team has had some training, but it is not regular or comprehensive."), br(tags$strong("5 ="), "Legal team receives regular training, together with enforcement staff, on environmental laws and respective sanctions.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_leg_tra")
                )
              )
            ),
            selectInput(
              inputId = "leg_tra_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "leg_tra_comments", " Comments")
          ) # end Legal Training box
        ) # end second column in the row
      ), # end third fluid row
      # start fourth fluid row
      fluidRow(
        column(10, actionButton("prev_2", "Previous", class = "btn-primary", style="color: #FFFFFF; background-color: #094074")),
        column(2, actionButton("next_4", "Save and Continue", class = "btn-primary", style="color: #FFFFFF; background-color: #094074")),
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
      # second fluid Row
      fluidRow(
        # first column in the row
        column(
          6,

          # start Community Education & Outreach box
          box(
            width = 12, title = "Community Education & Outreach", "Question 21 of 27", id = "com_edu",
            bsCollapse(
              id = "com_edu_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "Community Education & Outreach is not included in the area's management plan and little or no outreach efforts take place."),
                br(tags$strong("3 ="), "Community Education/Outreach is included in the area's management plan and some attempts at outreach take place."), br(tags$strong("5 ="), "Community Education/Outreach is included in the area's management plan and outreach efforts occur on a frequent and ongoing basis; outreach strategies are adjusted based on community needs and as public knowledge and awareness increases.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_com_edu")
                )
              )
            ),
            selectInput(
              inputId = "com_edu_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "com_edu_comments", " Comments")
          ) # end Community Education & Outreach box
        ), # END FIRST COLUMN IN THE ROW
        # start second column

        column(
          6,
          # start Community Involvement Box
          box(
            width = 12, title = "Community Involvement", "Question 22 of 27", id = "com_inv",
            bsCollapse(
              id = "com_inv_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "The community has little to no involvement in marine area management."),
                br(tags$strong("3 ="), "The community has some involvement in marine area management."), br(tags$strong("5 ="), "The community is highly involved in all aspects of marine area management (e.g. community members participate in town hall meetings, management processes, call in tips, etc.) through both informal processes or more formal governance structures.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_com_inv")
                )
              )
            ),
            selectInput(
              inputId = "com_inv_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput("com_inv_comments", " Comments")
          ) # end Community Involvement box
        ) # end second column in the row
      ), # end second fluid row

      # third fluid Row
      fluidRow(
        # first column in the row
        column(
          6,
          # start Fishing Sector Collaboration box
          box(
            width = 12, title = "Fishing Sector Collaboration", "Question 23 of 27", id = "fis_sec",
            bsCollapse(
              id = "fis_sec_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "The fishing sector has little to no involvement in marine area management."),
                br(tags$strong("3 ="), "The fishing sector has some involvement in marine area management."), br(tags$strong("5 ="), "The fishing sector is highly involved in all aspects of marine area management (e.g. fishers participate in town hall meetings, management processes, call in tips, etc.) through both informal processes or more formal governance structures.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_fis_sec")
                )
              )
            ),
            selectInput(
              inputId = "fis_sec_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "fis_sec_comments", " Comments")
          ) # end Fishing Sector Collaboration box
        ), # end first column in the row
        # start second column
        column(
          6,
          # start Tourism & Private Sector Collaboration Box
          box(
            width = 12, title = "Tourism & Private Sector Collaboration", "Question 24 of 27", id = "tou_pri",
            bsCollapse(
              id = "fis_sec_collapse",
              open = "Panel 1",
              bsCollapsePanel(
              title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
              style = "info", br(tags$strong("1="), "The tourism industry and private sector have little to no involvement in marine area management."),
              br(tags$strong("3 ="), "The tourism industry and private sector have some involvement in marine area management."), br(tags$strong("5 ="), "The tourism industry and private sector are highly involved in all aspects of marine area management (e.g. participate in town hall meetings, management processes, call in tips, etc.) through both informal processes or more formal governance structures.")
            ),
            bsCollapsePanel(
              title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
              div(
                class = "table-container",
                DTOutput("table_tou_pri")
              )
            )
          ),
            selectInput(
              inputId = "tou_pri_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "tou_pri_comments", " Comments")
          ) # end Tourism & Private Sector Collaboration box
        ) # end second column in the row
      ), # end third fluid row
      # start fourth fluid row
      fluidRow(
        column(10, actionButton("prev_3", "Previous", class = "btn-primary",style="color: #FFFFFF; background-color: #094074")),
        column(2, actionButton("next_5", "Save and Continue", class = "btn-primary",style="color: #FFFFFF; background-color: #094074")),
      ) # end fourth fluid row
    ), # end community engagement tabItem

    # Consistent Funding tabItem----
    tabItem(
      tabName = "funding",
      fluidRow(
        h1("Consistent Funding", align = "center"),
        br()
      ),
      # second fluid Row
      fluidRow(
        # first column in the row
        column(
          6,

          # start Funding box
          box(
            width = 12, title = "Funding", "Question 25 of 27", id = "fun",
            bsCollapse(
              id = "fun_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "Little or no funding is available for enforcement efforts."),
                br(tags$strong("3 ="), "Enforcement needs are budgeted and some of the enforcement budget is met. Funding comes from several continuing sources, is budgeted and allocated efficiently, and is enough to cover day-to-day enforcement expenses."), br(tags$strong("5 ="), "Enforcement needs are budgeted. The full enforcement budget is met. Funding comes from several continuing sources, is budgeted and allocated efficiently, and is enough to cover day-to-day enforcement expenses.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_fun")
                )
              )
            ),
            selectInput(
              inputId = "fun_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "fun_comments", " Comments")
          ) # end Funding box
        ), # END FIRST COLUMN IN THE ROW
        # start second column

        column(
          6,
          # start Cost Efficiency Box
          box(
            width = 12, title = "Cost Efficiency", "Question 26 of 27",
            id = "cos_eff",
            bsCollapse(
              id = "cost_eff_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "There are no cost-efficiency measures* in place."),
                br(tags$strong("3 ="), "Some cost-efficiency measures are in place. However, there is little or no funding for unforeseen expenses (i.e. prosecution costs, unexpected repairs, new surveillance assets, etc.)"), br(tags$strong("5 ="), "The agency has identified and implemented all potential cost-efficiency measures. Additional funding, managed through some sort of savings account, is available for unforeseen expenses (i.e. prosecution costs, unexpected repairs, new surveillance assets, etc.).")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_cos_eff")
                )
              )
            ),
            selectInput(
              inputId = "cos_eff_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "cos_eff_comments", " Comments")
          ) # end Cost Efficiency box
        ) # end second column in the row
      ), # end second fluid row

      # third fluid Row
      fluidRow(
        # first column in the row
        column(
          6,
          # start Diversified Funding Sources box
          box(
            width = 12, title = "Diversified Funding Sources", "Question 27 of 27", id = "div_fun",
            bsCollapse(
              id = "div_fun_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "Funding comes from a single source."),
                br(tags$strong("3 ="), "Funding comes from a one or two sources with most funds coming from one source."), br(tags$strong("5 ="), "Funding comes from a one or two sources with most funds coming from one source.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")), style = "info",
                div(
                  class = "table-container",
                  DTOutput("table_div_fun")
                )
              )
            ),
            selectInput(
              inputId = "div_fun_score", "Score",
              c("", "1", "2", "3", "4", "5", "NA")
            ),
            textInput(inputId = "div_fun_comments", " Comments")
          ) # end Diversified Funding Sources box
        ), # end first column in the row
      ), # end third fluid row
      # start fourth fluid row
      fluidRow(
        column(10, actionButton("prev_4", "Previous", class = "btn-primary", style="color: #FFFFFF; background-color: #094074")),
        column(2, actionButton("next_6", "Submit", class = "btn-primary", style="color: #FFFFFF; background-color: #094074")),
      ) # end fourth fluid row
    ), # end consistent funding tab item
    # start summary table tab item
    tabItem(
      tabName = "summary",
      fluidRow(
        h1("Summary", align = "center"),
        br()
      )
    ) # end summary table tab item
  ) # end tab items
) # end dashboard body

dashboardPage(header, sidebar, body, title = "WildAid Marine MPS Tracker Data Entry", skin= "black")


