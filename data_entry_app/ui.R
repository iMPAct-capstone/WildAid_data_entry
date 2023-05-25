# dashboard header ----------------------
header <- dashboardHeader(
  title = span("WildAid Marine MPS Tracker Data Entry",
    style = "color: white; font-size: 28px; font-family: 'Impact'"
  ),
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
  tags$style(
    HTML(
      ".table-container {
          width: 100%;
          max-height: 300px;
          overflow-y: auto;
        }"
    )
  ),

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
            width = 8,
            textInput(inputId = "name_input", label = "Evaluator Name(s)"), # end text input

            numericInput(inputId = "year_input", label = "Data Year", value = current_year_plus_one, min = 2019, max = 2080), # end text input

            selectInput(
              inputId = "country_input", label = "Country",
              c("Select Option", unique(site_list$country)) # read list of countries from site sheet
            ), # end select input

            selectInput(
              inputId = "site_input", label = "Site",
              choices = "Select Option" # eventually replace this with an actual list pulling from a file
            ), # end site select input

            actionButton("next_1", "Save and Continue", class = "btn-primary"), # end next button
          ), # end data entry box
        ), # end column
        column(
          width = 6,
          box(
            title = "Data Entry Instructions ",
            width = 14,
            "This application is for entering site data for the Marine Protection System Tracker. There are six sections with 27 subcategories to rank. Choose a score from the drop down menu and pick the best answer to match your scenario. If you need to leave and come back to the application to finish entering data, your progress is saved once you select the 'save and continue' button at the bottom of the page. Your responses will not be recorded unless this button is selected. To translate the instructions, use this application on Google Chrome and use these instructions to enable Google Translate."
          ),
        ) # end column
      ), # end fluid row

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
            br("Question 1 of 27"),
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
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")),
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
            width = 12, title = "Patrol Planning", br("Question 2 of 27"), id = "pat_pla",
            bsCollapse(
              id = "pat_pla_collapse",
              open = "Panel 1",
              bsCollapsePanel(
                title = HTML(paste0("Scoring Guidelines <span class='arrow'>&#x25BE;</span>")),
                style = "info", br(tags$strong("1="), "The enforcement agency does not engage in a formal patrol planning process."),
                br(tags$strong("3 ="), "The enforcement agency has a patrol plan but it is not implemented consistently."), br(tags$strong("5 ="), "The enforcement agency follows a strategic, data-driven patrol plan.")
              ),
              bsCollapsePanel(
                title = HTML(paste0("Previous Scores <span class='arrow'>&#x25BE;</span>")),
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
            br("Question 3 of 27"), id = "ves_ava",
            br("How to Score"),
            br("1 = Vessels are in poor shape. Vessel availability is low."),
            br("3 = Vessels are in good condition. Vessel availability is average (approximately 50% or more)."),
            br("5 = Vessels are in good condition. Vessel availability is higher than 75%."),
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
            br("Question 4 of 27"), id = "pat_exe",
            br("How to Score"),
            br("1 = The enforcement agency does not conduct patrols."),
            br("3 = The enforcement agency conduct some patrols but they are infrequent, inconsistent, and not targeted for high-risk areas."),
            br("5 = The enforcement agency conducts frequent, consistent, strategic, data-driven patrols."),
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
            width = 12, title = "Fleet Adequacy", br("Question 5 of 27"), id = "fle_ade",
            br("How to Score"),
            br("1 = There are not enough vessels to patrol the marine area and/ or they are not the right kinds of vessels."),
            br("3 = There are enough vessels to patrol the marine area, but they are not the right kind of vessels (e.g. coastal vessels only when the marine area needs oceanic)."),
            br("5 = There are enough vessels to patrol the marine area. The marine area has the right types of vessels for their needs."),
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
            width = 12, title = "Patrol Equipment", br("Question 6 of 27"), id = "pat_equ",
            br("How to Score"),
            br("1 = Patrol vessels lack essential safety equipment and boarding kits."),
            br("3 = Patrol vessels are equipped with essential safety equipment, but lack adequate boarding kits, or vice versa."),
            br("5 = Patorl vessels are equipped with both essential safety equipment and boarding kits."),
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
            width = 12, title = "Intelligence Sources", br("Question 7 of 27"), id = "int_sou",
            br("How to Score"),
            br("1 = Intelligence information is limited to what is gathered from patrols."),
            br("3 = The enforcement agency has some access to external intelligence (e.g. informants or surveillance technology)."),
            br("5 = he enforcement agency uses multiple channels to gather intelligence information, including but not limited to: surveillance technology to track infractions as they occur, an informant hotline, and other outside sources."),
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
            width = 12, title = "Investigation Procedures", br("Question 8 of 27"), id = "inv_pro",
            br("How to Score"),
            br("1 = There are no boarding or chain of custody procedures in place."),
            br("3 = There are some investigation procedures in place, but they have not have been reviewed or approved by legal teams."),
            br("5 = There are boarding and chain of custody procedures in place. These have been reviewed and approved by legal teams. "),
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
            width = 12, title = "Institutional Collaboration (National)", br("Question 9 of 27"), id = "nat_inst",
            br("How to Score"),
            br("1 = Overlapping jurisdictions, unclear lines of authority, and / or competing interests lead to limited or no focus on enforcement."),
            br("3 = Overlapping jurisdictions, unclear lines of authority, and / or competing interests lead to inefficient, ineffective, or minimal enforcement."),
            br("5 = Institutions have clearly defined responsibilities and collaborate effectively on enforcement efforts."),
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
            width = 12, title = "Institutional Collaboration (International/Regional - if applicable)", br("Question 10 of 27"), id = "int_inst",
            br("How to Score"),
            br("1 = Overlapping jurisdictions, unclear lines of authority, and / or competing interests lead to limited or no focus on enforcement of foreign-flagged fishing infractions."),
            br("3 = Overlapping jurisdictions, unclear lines of authority, and / or competing interests lead to inefficient, ineffective, or minimal enforcement of foreign-flagged fishing infractions."),
            br("5 = Individual countries have clearly defined responsibilities and collaborate effectively on enforcement efforts."),
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
            width = 12, title = "Staff Numbers", br("Question 11 of 27"), id = "sta_num",
            br("How to Score"),
            br("1 = There are no staff for enforcement operations (e.g. surveillance such as patrols and community engagement). "),
            br("3 = Staff numbers are insufficient for enforcement operations and/ or staff retention is low."),
            br("5 = Staff numbers are sufficient for enforcement operations. Staff retention and/ or morale are high."),
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
        column(2, actionButton("next_2", "Save and Continue", class = "btn-primary")),
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
            width = 12, title = "Laws and Regulations", br("Question 12 of 27"), id = "law_reg",
            br("How to Score"),
            br("1 = Laws/ regulations are unclear (have many loopholes) or not enforceable re: prohibited species, activities, tools / gear that can be used in the area."),
            br("3 = Laws/ regulations are clear (few loopholes) or not enforceable Or vice versa re:  re: prohibited species, activities, tools / gear that can be used in the area."),
            br("5 = Laws/ regulations are clear (no loopholes) and enforceable re: prohibited species, activities, tools / gear that can be used in the area."),
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
            width = 12, title = "Zoning (n/a for EEZ-wide projects)", br("Question 13 of 27"), id = "zon",
            br("How to Score"),
            br("1 = Marine area size and zoning does not match conservation goals / address threats or is difficult to enforce."),
            br("3 = Marine area size and zoning aligns with some conservation goals and addresses some threats but not all and/ or is easier to enforce."),
            br("5 = Marine area size and zoning aligns with key conservation goals and addresses key threats, and is enforceable."),
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
            width = 12, title = "Sanctions / Prosecutions", br("Question 14 of 27"), id = "san_pro",
            br("How to Score"),
            br("1 = Few cases are sanctioned and / or sanctions levied are not strong enough to deter future illegal activity."),
            br("3 = A majority of cases are sanctioned; however sanctions are not strong enough to act as a deterrent."),
            br("5 = A majority of cases are strongly sanctioned to the extent of the law."),
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
            width = 12, title = "Case Database", br("Question 15 of 27"), id = "cas_dat",
            br("How to Score"),
            br("1 = There is no central database to keep track of cases."),
            br("3 = There is a database, but it is not used regularly or it does not track all information needed."),
            br("5 = There is a central database that is consistently used for case monitoring, follow up, and to track repeat offenders. "),
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
            width = 12, title = "Scientific Monitoring", br("Question 16 of 27"), id = "sci_mon",
            br("How to Score"),
            br("1 = No scientific monitoring or baseline assessments of target species are carried out. "),
            br("3 = Scientific monitoring is currently being carried out and/ or a baseline has been established."),
            br("5 = Baseline sudies and assessments are regularly carried out for target marine species or priority habitat, and assessments are integrated into the management plan. "),
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
        column(10, actionButton("prev_1", "Previous", class = "btn-primary")),
        column(2, actionButton("next_3", "Save and Continue", class = "btn-primary")),
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
            width = 12, title = "Enforcement Training", br("Question 17 of 27"), id = "enf_tra",
            br("How to Score"),
            br("1 = No standardized enforcement training exists for staff and other relevant agencies."),
            br("3 = Enforcement training for staff and other relevant agencies may exist, but training is irregular and not comprehensive."),
            br("5 = Staff and other relevant agencies receive regular enforement trainings (sometimes multi-agency)."),
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
            width = 12, title = "Standard Operating Procedures (SOPs)", br("Question 18 of 27"), id = "sta_ope",
            br("How to Score"),
            br("1 = No operational SOPs exist for enforcement staff and other relevant agencies."),
            br("3 = Some operational SOPs for enforcement staff and other relevant agencies may exist, but SOPs are outdated or incomplete."),
            br("5 = Enforcement staff and other relevant agencies have comprehensive operational SOPs covering boarding, crime scene investigation, and chain of custody procedures. All relevant staff receive regular trainings (sometimes multi-agency) on SOPs and SOPs are updated annually."),
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
            width = 12, title = "Staff Qualifications", br("Question 19 of 27"), id = "sta_qua",
            br("How to Score"),
            br("1 = Agency staff are not qualified for enforcement work."),
            br("3 = Agency staff receive minimal enforcement training."),
            br("5 = Agency staff receive regular comprehensive enforcement training and are qualified for their jobs. Staff is selected based on experience. Training occurs regularly and includes all relevant topics. Site has received 'train-the-trainer' instruction."),
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
            width = 12, title = "Legal Training", br("Question 20 of 27"), id = "leg_tra",
            br("How to Score"),
            br("1 = Legal team does not exist or has not been trained."),
            br("3 = Legal team has had some training, but it is not regular or comprehensive."),
            br("5 = Legal team receives regular training, together with enforcement staff, on environmental laws and respective sanctions."),
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
        column(10, actionButton("prev_2", "Previous", class = "btn-primary")),
        column(2, actionButton("next_4", "Save and Continue", class = "btn-primary")),
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
            width = 12, title = "Community Education & Outreach", br("Question 21 of 27"), id = "com_edu",
            br("How to Score"),
            br("1 = Community Education & Outreach is not included in the area's management plan and little or no outreach efforts take place."),
            br("3 = Community Education/ Outreach is included in the area's management plan and some attempts at outreach take place."),
            br("5 = Community Education/ Outreach is included in the area's management plan and outreach efforts occur on a frequent and ongoing basis; outreach strategies are adjusted based on community needs and as public knowledge and awareness increases."),
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
            width = 12, title = "Community Involvement", br("Question 22 of 27"), id = "com_inv",
            br("How to Score"),
            br("1 = The community has little to no involvement in marine area management."),
            br("3 = The community has some involvement in marine area management."),
            br("5 = The community is highly involved in all aspects of marine area management (e.g. community members participate in town hall meetings, management processes, call in tips, etc.) through both informal processes or more formal governance structures."),
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
            width = 12, title = "Fishing Sector Collaboration", br("Question 23 of 27"), id = "fis_sec",
            br("How to Score"),
            br("1 = The fishing sector has little to no involvement in marine area management."),
            br("3 = The fishing sector has some involvement in marine area management."),
            br("5 = The fishing sector is highly involved in all aspects of marine area management (e.g. fishers participate in town hall meetings, management processes, call in tips, etc.) through both informal processes or more formal governance structures."),
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
            width = 12, title = "Tourism & Private Sector Collaboration", br("Question 24 of 27"), id = "tou_pri",
            br("How to Score"),
            br("1 = The tourism industry and private sector have little to no involvement in marine area management."),
            br("3 = The tourism industry and private sector have some involvement in marine area management."),
            br("5 = The tourism industry and private sector are highly involved in all aspects of marine area management (e.g. participate in town hall meetings, management processes, call in tips, etc.) through both informal processes or more formal governance structures."),
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
        column(10, actionButton("prev_3", "Previous", class = "btn-primary")),
        column(2, actionButton("next_5", "Save and Continue", class = "btn-primary")),
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
            width = 12, title = "Funding", br("Question 25 of 27"), id = "fun",
            br("How to Score"),
            br("1 = Little or no funding is available for enforcement efforts."),
            br("3 = Enforcement needs are budgeted and some of the enforcement budget is met. Funding comes from several continuing sources, is budgeted and allocated efficiently, and is enough to cover day-to-day enforcement expenses."),
            br("5 = Enforcement needs are budgeted. The full enforcement budget is met. Funding comes from several continuing sources, is budgeted and allocated efficiently, and is enough to cover day-to-day enforcement expenses."),
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
            width = 12, title = "Cost Efficiency", br("Question 26 of 27"),
            id = "cos_eff",
            br("How to Score"),
            br("1 = There are no cost-efficiency measures* in place."),
            br("3 = Some cost-efficiency measures are in place. However, there is little or no funding for unforeseen expenses (i.e. prosecution costs, unexpected repairs, new surveillance assets, etc.)"),
            br("5 = The agency has identified and implemented all potential cost-efficiency measures. Additional funding, managed through some sort of savings account, is available for unforeseen expenses (i.e. prosecution costs, unexpected repairs, new surveillance assets, etc.)."),
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
            width = 12, title = "Diversified Funding Sources", br("Question 27 of 27"), id = "div_fun",
            br("How to Score"),
            br("1 = Funding comes from a single source."),
            br("3 = Funding comes from a one or two sources with most funds coming from one source."),
            br("5 = Funding comes from 2 or more sources, with a more diverse and balanced composition."),
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
        column(10, actionButton("prev_4", "Previous", class = "btn-primary")),
        column(2, actionButton("next_6", "Submit", class = "btn-primary")),
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



dashboardPage(header, sidebar, body, title = "WildAid Marine MPS Tracker Data Entry")
