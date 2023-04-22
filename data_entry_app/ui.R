

# dashboard header ----------------------
header <- dashboardHeader(
  
  title = "WildAid Marine MPS Tracker Data Entry",
  titleWidth = 400
  
) #End Dashboard header

# dashboard sidebar ----------------------
sidebar <- dashboardSidebar(
  
  collapsed = TRUE, sidebarMenuOutput("sidebar")
  
) #END Dashboard sidebar

#..........................dashboardBody.........................


body <- dashboardBody(
  # add logout button UI
  div(class = "pull-right", shinyauthr::logoutUI(id = "logout")),
  # add login panel UI function
  shinyauthr::loginUI(id = "login"),
  # setup table output to show user info after login
  tableOutput("user_table"),

# tabItems ----    
tabItems(
  # Main Page data tabItem ----
  tabItem(tabName = "data",
  #fluidRow ----      
    fluidRow(
    #start first column 
      column(6,
          #start data entry box
          box(width = 8,
              textInput(inputId = "name_input",  label = "Evaluator Name(s)"), #end text input
                
              textInput(inputId = "year_input", label = "Data Year"), #end text input
                
              selectInput(inputId ="country_input", label = "Country",
                          c("Select Option", unique(site_list$country)) #read list of countries from site sheet
                          ), #end select input
                
              selectInput(inputId = "site_input", label = "Site",
                            choices = "Select Option" #eventually replace this with an actual list pulling from a file
                          ), #end site select input
                
                actionButton("next_1", "Save and Continue", class = "btn-primary"
                             ) #end next button
                ), #end data entry box
              ), #end column
      column(6, "General Data Entry Instructions Will Go Here"), 
            ), #end fluid row 
  
  #start next fluid row -----
    fluidRow(
    #start column ---- 
      column(10,
           ), #end column ----
            ), #end fluid row 
  ), #end data main page tab item


# Surveillance tabItem ----

tabItem(tabName = "enforcement", 
    #first fluid row ---- 
    fluidRow(h1("Surveillance and Enforcement", align="center"),
                br()),#end title row
    #second fluid Row ---- 
        fluidRow(
        #first column in the row ---- 
        column(6, 

#surveillance prioritization box ----        
      box(width = 12, title = "Surveillance Prioritization", id = "surv_pri",
        br("How to Score"),
        br("1 = No priority areas are defined or priority areas are not under surveillance."),
        br("3 = Some of the priority areas are under constant surveillance via regular patrols and surveillance equipment or all priority areas are monitored, but not continuously."),
        br("5 = 100% of the priority areas are monitored continuously via regular patrols and surveillance equipment."	),
        selectInput(inputId = "surv_pri_score", label = "Score",
              choices = c("",  "1", "2", "3", "4", "5", "NA")),
        textInput(inputId = "surv_pri_comments", " Comments")
  
) # end surveillance prioritization box
), # END FIRST COLUMN IN THE ROW
#start second column ---- 

column(6, 
       #Patrol Planning Box ----        
       box(width = 12, "Patrol Planning",
           br("How to Score"),
           br("1 = The enforcement agency does not engage in a formal patrol planning process."),
           br("3 = The enforcement agency has a patrol plan but it is not implemented consistently."),
           br("5 = The enforcement agency follows a strategic, data-driven patrol plan."	),
           selectInput("os_type", "Score",
                       c("",  "1", "2", "3", "4", "5", "NA")),
           textInput("comments", " Comments")
           
       ) # end patrol planning box
) #end second column in the row

), #end second fluid row 

#third fluid Row ---- 
fluidRow(
  #first column in the row ---- 
  column(6, 
 #start vessel availability box
   box(width = 12, "Vessel Availability",
      br("How to Score"),
      br("1 = Vessels are in poor shape. Vessel availability is low."),
      br("3 = Vessels are in good condition. Vessel availability is average (approximately 50% or more)."),
      br("5 = Vessels are in good condition. Vessel availability is higher than 75%."),
      selectInput("os_type", "Score",
                  c("",  "1", "2", "3", "4", "5", "NA")),
      textInput("comments", " Comments")
      
) # end vessel availability box
), #end first column in the row
#second column ---- 
column(6, 
       #start patrol execution box ----
       box(width = 12, "Patrol Execution",
              br("How to Score"),
              br("1 = The enforcement agency does not conduct patrols."),
              br("3 = The enforcement agency conduct some patrols but they are infrequent, inconsistent, and not targeted for high-risk areas."),
              br("5 = The enforcement agency conducts frequent, consistent, strategic, data-driven patrols."),
              selectInput("os_type", "Score",
                          c("",  "1", "2", "3", "4", "5", "NA")),
              textInput("comments", " Comments")
              
) #end patrol execution box
 ),#end second column

), #end third fluid row 

#start fourth fluid row
fluidRow(
  #first column in the row ---- 
  column(6, 
         #start fleet adequacy box
         box(width = 12, "Fleet Adequacy",
             br("How to Score"),
             br("1 = There are not enough vessels to patrol the marine area and/ or they are not the right kinds of vessels."),
             br("3 = There are enough vessels to patrol the marine area, but they are not the right kind of vessels (e.g. coastal vessels only when the marine area needs oceanic)."),
             br("5 = There are enough vessels to patrol the marine area. The marine area has the right types of vessels for their needs."),
             selectInput("os_type", "Score",
                         c("",  "1", "2", "3", "4", "5", "NA")),
             textInput("comments", " Comments")
             
         ) # end fleet adequacy box
  ), #end first column in the row
  #second column ---- 
  column(6, 
         #start patrol equipment box ----
         box(width = 12, "Patrol Equipment",
             br("How to Score"),
             br("1 = Patrol vessels lack essential safety equipment and boarding kits."),
             br("3 = Patrol vessels are equipped with essential safety equipment, but lack adequate boarding kits, or vice versa."),
             br("5 = Patorl vessels are equipped with both essential safety equipment and boarding kits."),
             selectInput("os_type", "Score",
                         c("",  "1", "2", "3", "4", "5", "NA")),
             textInput("comments", " Comments")
             
         ) #end patrol equipment box
  ),#end second column
  
), #end fourth fluid row

#start fifth fluid row
fluidRow(
  #first column in the row ---- 
  column(6, 
         #start Intelligence Sources box
         box(width = 12, "Intelligence Sources",
             br("How to Score"),
             br("1 = Intelligence information is limited to what is gathered from patrols."),
             br("3 = The enforcement agency has some access to external intelligence (e.g. informants or surveillance technology)."),
             br("5 = he enforcement agency uses multiple channels to gather intelligence information, including but not limited to: surveillance technology to track infractions as they occur, an informant hotline, and other outside sources."),
             selectInput("os_type", "Score",
                         c("",  "1", "2", "3", "4", "5", "NA")),
             textInput("comments", " Comments")
             
         ) # end Intelligence Sources box
  ), #end first column in the row
  #second column ---- 
  column(6, 
         #start investigation procedures box ----
         box(width = 12, "Investigation Procedures",
             br("How to Score"),
             br("1 = There are no boarding or chain of custody procedures in place."),
             br("3 = There are some investigation procedures in place, but they have not have been reviewed or approved by legal teams."),
             br("5 = There are boarding and chain of custody procedures in place. These have been reviewed and approved by legal teams. "),
             selectInput("os_type", "Score",
                         c("",  "1", "2", "3", "4", "5", "NA")),
             textInput("comments", " Comments")
             
         ) #end investigation procedures box
  ),#end second column
  
), #end fifth fluid row

#start sixth fluid row
fluidRow(
  #first column in the row ---- 
  column(6, 
         #start Institutional Collaboration (National) box
         box(width = 12, "Institutional Collaboration (National)",
             br("How to Score"),
             br("1 = Overlapping jurisdictions, unclear lines of authority, and / or competing interests lead to limited or no focus on enforcement."),
             br("3 = Overlapping jurisdictions, unclear lines of authority, and / or competing interests lead to inefficient, ineffective, or minimal enforcement."),
             br("5 = Institutions have clearly defined responsibilities and collaborate effectively on enforcement efforts."),
             selectInput("os_type", "Score",
                         c("",  "1", "2", "3", "4", "5", "NA")),
             textInput("comments", " Comments")
             
         ) # end Institutional Collaboration (National) box
  ), #end first column in the row
  #second column ---- 
  column(6, 
         #start Institutional Collaboration (International/Regional - if applicable) box ----
         box(width = 12, "Institutional Collaboration (International/Regional - if applicable)",
             br("How to Score"),
             br("1 = Overlapping jurisdictions, unclear lines of authority, and / or competing interests lead to limited or no focus on enforcement of foreign-flagged fishing infractions."),
             br("3 = Overlapping jurisdictions, unclear lines of authority, and / or competing interests lead to inefficient, ineffective, or minimal enforcement of foreign-flagged fishing infractions."),
             br("5 = Individual countries have clearly defined responsibilities and collaborate effectively on enforcement efforts."),
             selectInput("os_type", "Score",
                         c("",  "1", "2", "3", "4", "5", "NA")),
             textInput("comments", " Comments")
             
         ) #end Institutional Collaboration (International/Regional - if applicable) box
  ),#end second column
  
), #end sixth fluid row

#start seventh fluid row
fluidRow(
  #first column in the row ---- 
  column(6, 
         #start Staff numbers box
         box(width = 12, "Staff Numbers",
             br("How to Score"),
             br("1 = There are no staff for enforcement operations (e.g. surveillance such as patrols and community engagement). "),
             br("3 = Staff numbers are insufficient for enforcement operations and/ or staff retention is low."),
             br("5 = Staff numbers are sufficient for enforcement operations. Staff retention and/ or morale are high."),
             selectInput("os_type", "Score",
                         c("",  "1", "2", "3", "4", "5", "NA")),
             textInput("comments", " Comments")
             
         ) # end staff numbers box
  ), #end first column in the row
), #end seventh fluid row

#start eighth fluid row
fluidRow(
  column(10,),
  column(2, actionButton("next_2", "Save and Continue", class = "btn-primary")),
) #end eighth fluid row
), #end surveillance and enforcement tab item  

# Policies and Consequences tabItem ----
 
tabItem(tabName = "policies",
        #title row
        fluidRow(h1("Policies and Consequences", align="center"),
                 br()),#end title row
        #second fluid Row ---- 
        fluidRow(
          #first column in the row ---- 
          column(6, 
                 
                 #start Laws and Regulations box ----        
                 box(width = 12, "Laws and Regulations",
                     br("How to Score"),
                     br("1 = Laws/ regulations are unclear (have many loopholes) or not enforceable re: prohibited species, activities, tools / gear that can be used in the area."),
                     br("3 = Laws/ regulations are clear (few loopholes) or not enforceable Or vice versa re:  re: prohibited species, activities, tools / gear that can be used in the area."),
                     br("5 = Laws/ regulations are clear (no loopholes) and enforceable re: prohibited species, activities, tools / gear that can be used in the area."	),
                     selectInput("os_type", "Score",
                                 c("",  "1", "2", "3", "4", "5", "NA")),
                     textInput("comments", " Comments")
                     
                 ) # end Laws and Regulations box
          ), # END FIRST COLUMN IN THE ROW
          #start second column ---- 
          
          column(6, 
                 #start Zoning (n/a for EEZ-wide projects) Box ----        
                 box(width = 12, "Zoning (n/a for EEZ-wide projects)",
                     br("How to Score"),
                     br("1 = Marine area size and zoning does not match conservation goals / address threats or is difficult to enforce."),
                     br("3 = Marine area size and zoning aligns with some conservation goals and addresses some threats but not all and/ or is easier to enforce."),
                     br("5 = Marine area size and zoning aligns with key conservation goals and addresses key threats, and is enforceable."	),
                     selectInput("os_type", "Score",
                                 c("",  "1", "2", "3", "4", "5", "NA")),
                     textInput("comments", " Comments")
                     
                 ) # end Zoning (n/a for EEZ-wide projects) box
          ) #end second column in the row
          
        ), #end second fluid row 
        
        #third fluid Row ---- 
        fluidRow(
          #first column in the row ---- 
          column(6, 
                 #start Sanctions / Prosecutions box
                 box(width = 12, "Sanctions / Prosecutions",
                     br("How to Score"),
                     br("1 = Few cases are sanctioned and / or sanctions levied are not strong enough to deter future illegal activity."),
                     br("3 = A majority of cases are sanctioned; however sanctions are not strong enough to act as a deterrent."),
                     br("5 = A majority of cases are strongly sanctioned to the extent of the law."),
                     selectInput("os_type", "Score",
                                 c("",  "1", "2", "3", "4", "5", "NA")),
                     textInput("comments", " Comments")
                     
                 ) # end Sanctions / Prosecutions box
          ), #end first column in the row
          #second column ---- 
          column(6, 
                 #start case database box ----
                 box(width = 12, "Case Database",
                     br("How to Score"),
                     br("1 = There is no central database to keep track of cases."),
                     br("3 = There is a database, but it is not used regularly or it does not track all information needed."),
                     br("5 = There is a central database that is consistently used for case monitoring, follow up, and to track repeat offenders. "),
                     selectInput("os_type", "Score",
                                 c("",  "1", "2", "3", "4", "5", "NA")),
                     textInput("comments", " Comments")
                     
                 ) #end case database box
          ),#end second column
          
        ), #end third fluid row 

#start fourth fluid row
fluidRow(
  #first column in the row ---- 
  column(6, 
         #start Scientific Monitoring box
         box(width = 12, "Scientific Monitoring",
             br("How to Score"),
             br("1 = No scientific monitoring or baseline assessments of target species are carried out. "),
             br("3 = Scientific monitoring is currently being carried out and/ or a baseline has been established."),
             br("5 = Baseline sudies and assessments are regularly carried out for target marine species or priority habitat, and assessments are integrated into the management plan. "),
             selectInput("os_type", "Score",
                         c("",  "1", "2", "3", "4", "5", "NA")),
             textInput("comments", " Comments")
             
         ) # end Scientific Monitoring box
  ), #end first column in the row
), #end fourth fluid row
        
#start fifth fluid row
        fluidRow(
          column(10,),
          column(2, actionButton("next_3", "Save and Continue", class = "btn-primary")),
        ) #end fifth fluid row
), #end policies and consequences tabItem  

#Training and mentorship tabItem ----
tabItem(tabName = "training",
        #title row
        fluidRow(h1("Training and Mentorship", align="center"),
                 br()),
        #second fluid Row ---- 
        fluidRow(
          #first column in the row ---- 
          column(6, 
                 
                 #start Enforcement Training box ----        
                 box(width = 12, "Enforcement Training",
                     br("How to Score"),
                     br("1 = No standardized enforcement training exists for staff and other relevant agencies."),
                     br("3 = Enforcement training for staff and other relevant agencies may exist, but training is irregular and not comprehensive."),
                     br("5 = Staff and other relevant agencies receive regular enforement trainings (sometimes multi-agency)."),
                     selectInput("os_type", "Score",
                                 c("",  "1", "2", "3", "4", "5", "NA")),
                     textInput("comments", " Comments")
                     
                 ) # end Enforcement Training box
          ), # END FIRST COLUMN IN THE ROW
          #start second column ---- 
          
          column(6, 
                 #start Standard Operating Procedures (SOPs) Box ----        
                 box(width = 12, "Standard Operating Procedures (SOPs)",
                     br("How to Score"),
                     br("1 = No operational SOPs exist for enforcement staff and other relevant agencies."),
                     br("3 = Some operational SOPs for enforcement staff and other relevant agencies may exist, but SOPs are outdated or incomplete."),
                     br("5 = Enforcement staff and other relevant agencies have comprehensive operational SOPs covering boarding, crime scene investigation, and chain of custody procedures. All relevant staff receive regular trainings (sometimes multi-agency) on SOPs and SOPs are updated annually."),
                     selectInput("os_type", "Score",
                                 c("",  "1", "2", "3", "4", "5", "NA")),
                     textInput("comments", " Comments")
                     
                 ) # end Standard Operating Procedures (SOPs) box
          ) #end second column in the row
          
        ), #end second fluid row 
        
        #third fluid Row ---- 
        fluidRow(
          #first column in the row ---- 
          column(6, 
                 #start Staff Qualifications box
                 box(width = 12, "Staff Qualifications",
                     br("How to Score"),
                     br("1 = Agency staff are not qualified for enforcement work."),
                     br("3 = Agency staff receive minimal enforcement training."),
                     br("5 = Agency staff receive regular comprehensive enforcement training and are qualified for their jobs. Staff is selected based on experience. Training occurs regularly and includes all relevant topics. Site has received 'train-the-trainer' instruction."),
                     selectInput("os_type", "Score",
                                 c("",  "1", "2", "3", "4", "5", "NA")),
                     textInput("comments", " Comments")
                     
                 ) # end Staff Qualifications box
          ), #end first column in the row
          #start second column -----
          column(6, 
                 #start Legal Training Box ----        
                 box(width = 12, "Legal Training",
                     br("How to Score"),
                     br("1 = Legal team does not exist or has not been trained."),
                     br("3 = Legal team has had some training, but it is not regular or comprehensive."),
                     br("5 = Legal team receives regular training, together with enforcement staff, on environmental laws and respective sanctions."),
                     selectInput("os_type", "Score",
                                 c("",  "1", "2", "3", "4", "5", "NA")),
                     textInput("comments", " Comments")
                     
                 ) # end Legal Training box
          ) #end second column in the row
          
        ), #end third fluid row 
        #start fourth fluid row
        fluidRow(
          column(10,),
          column(2, actionButton("next_4", "Save and Continue", class = "btn-primary")),
        ) #end fourth fluid row
), #end training and mentorship tab item

#Community Engagement tabItem ----
tabItem(tabName = "community",
                #title row
                fluidRow(h1("Community Engagement", align="center"),
                         br()),
        #second fluid Row ---- 
        fluidRow(
          #first column in the row ---- 
          column(6, 
                 
                 #start Community Education & Outreach box ----        
                 box(width = 12, "Community Education & Outreach",
                     br("How to Score"),
                     br("1 = Community Education & Outreach is not included in the area's management plan and little or no outreach efforts take place."),
                     br("3 = Community Education/ Outreach is included in the area's management plan and some attempts at outreach take place."),
                     br("5 = Community Education/ Outreach is included in the area's management plan and outreach efforts occur on a frequent and ongoing basis; outreach strategies are adjusted based on community needs and as public knowledge and awareness increases."),
                     selectInput("os_type", "Score",
                                 c("",  "1", "2", "3", "4", "5", "NA")),
                     textInput("comments", " Comments")
                     
                 ) # end Community Education & Outreach box
          ), # END FIRST COLUMN IN THE ROW
          #start second column ---- 
          
          column(6, 
                 #start Community Involvement Box ----        
                 box(width = 12, "Community Involvement",
                     br("How to Score"),
                     br("1 = The community has little to no involvement in marine area management."),
                     br("3 = The community has some involvement in marine area management."),
                     br("5 = The community is highly involved in all aspects of marine area management (e.g. community members participate in town hall meetings, management processes, call in tips, etc.) through both informal processes or more formal governance structures."	),
                     selectInput("os_type", "Score",
                                 c("",  "1", "2", "3", "4", "5", "NA")),
                     textInput("comments", " Comments")
                     
                 ) # end Community Involvement box
          ) #end second column in the row
          
        ), #end second fluid row 
        
        #third fluid Row ---- 
        fluidRow(
          #first column in the row ---- 
          column(6, 
                 #start Fishing Sector Collaboration box
                 box(width = 12, "Fishing Sector Collaboration",
                     br("How to Score"),
                     br("1 = The fishing sector has little to no involvement in marine area management."),
                     br("3 = The fishing sector has some involvement in marine area management."),
                     br("5 = The fishing sector is highly involved in all aspects of marine area management (e.g. fishers participate in town hall meetings, management processes, call in tips, etc.) through both informal processes or more formal governance structures."),
                     selectInput("os_type", "Score",
                                 c("",  "1", "2", "3", "4", "5", "NA")),
                     textInput("comments", " Comments")
                     
                 ) # end Fishing Sector Collaboration box
          ), #end first column in the row
          #start second column -----
          column(6, 
                 #start Tourism & Private Sector Collaboration Box ----        
                 box(width = 12, "Tourism & Private Sector Collaboration",
                     br("How to Score"),
                     br("1 = The tourism industry and private sector have little to no involvement in marine area management."),
                     br("3 = The tourism industry and private sector have some involvement in marine area management."),
                     br("5 = The tourism industry and private sector are highly involved in all aspects of marine area management (e.g. participate in town hall meetings, management processes, call in tips, etc.) through both informal processes or more formal governance structures."),
                     selectInput("os_type", "Score",
                                 c("",  "1", "2", "3", "4", "5", "NA")),
                     textInput("comments", " Comments")
                     
                 ) # end Tourism & Private Sector Collaboration box
          ) #end second column in the row
          
        ), #end third fluid row 
        #start fourth fluid row
        fluidRow(
          column(10,),
          column(2, actionButton("next_5", "Save and Continue", class = "btn-primary")),
        ) #end fourth fluid row
), #end community engagement tabItem

#Consistent Funding----
tabItem(tabName = "funding",
        fluidRow(h1("Consistent Funding", align="center"),
                 br()),
        #second fluid Row ---- 
        fluidRow(
          #first column in the row ---- 
          column(6, 
                 
                 #start Funding box ----        
                 box(width = 12, "Funding",
                     br("How to Score"),
                     br("1 = Little or no funding is available for enforcement efforts."),
                     br("3 = Enforcement needs are budgeted and some of the enforcement budget is met. Funding comes from several continuing sources, is budgeted and allocated efficiently, and is enough to cover day-to-day enforcement expenses."),
                     br("5 = Enforcement needs are budgeted. The full enforcement budget is met. Funding comes from several continuing sources, is budgeted and allocated efficiently, and is enough to cover day-to-day enforcement expenses."),
                     selectInput("os_type", "Score",
                                 c("",  "1", "2", "3", "4", "5", "NA")),
                     textInput("comments", " Comments")
                     
                 ) # end Funding box
          ), # END FIRST COLUMN IN THE ROW
          #start second column ---- 
          
          column(6, 
                 #start Cost Efficiency Box ----        
                 box(width = 12, "Cost Efficiency",
                     br("How to Score"),
                     br("1 = There are no cost-efficiency measures* in place."),
                     br("3 = Some cost-efficiency measures are in place. However, there is little or no funding for unforeseen expenses (i.e. prosecution costs, unexpected repairs, new surveillance assets, etc.)"),
                     br("5 = The agency has identified and implemented all potential cost-efficiency measures. Additional funding, managed through some sort of savings account, is available for unforeseen expenses (i.e. prosecution costs, unexpected repairs, new surveillance assets, etc.)."	),
                     selectInput("os_type", "Score",
                                 c("",  "1", "2", "3", "4", "5", "NA")),
                     textInput("comments", " Comments")
                     
                 ) # end Cost Efficiency box
          ) #end second column in the row
          
        ), #end second fluid row 
        
        #third fluid Row ---- 
        fluidRow(
          #first column in the row ---- 
          column(6, 
                 #start Diversified Funding Sources box
                 box(width = 12, "Diversified Funding Sources",
                     br("How to Score"),
                     br("1 = Funding comes from a single source."),
                     br("3 = Funding comes from a one or two sources with most funds coming from one source."),
                     br("5 = Funding comes from 2 or more sources, with a more diverse and balanced composition."),
                     selectInput("os_type", "Score",
                                 c("",  "1", "2", "3", "4", "5", "NA")),
                     textInput("comments", " Comments")
                     
                 ) # end Diversified Funding Sources box
          ), #end first column in the row
        ), #end third fluid row 
        #start fourth fluid row
        fluidRow(
          column(10,),
          column(2, actionButton("next_6", "Submit", class = "btn-primary")),
        ) #end fourth fluid row
) #end consistent funding tab item

) #end tab items 
) #end dashboard body 



dashboardPage(header, sidebar, body)
