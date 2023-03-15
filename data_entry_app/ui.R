
#read in site list 
url <- "https://docs.google.com/spreadsheets/d/1jhKXPigQKs0r9vg1hAX3n0hAkwfFuNu0uPpA9MD8gTk/edit#gid=818092877"

test <- read_sheet(url)


# dashboard header ----------------------
header <- dashboardHeader(
  
  title = "WildAid Marine MPS Tracker Data Entry",
  titleWidth = 400
  
) #End Dashboard header

# dashboard sidebar ----------------------
sidebar <- dashboardSidebar(
  
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
  
  
) #END Dashboard sidebar

#..........................dashboardBody.........................


body <- dashboardBody(

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
              textInput("name", " Evaluator Name(s)"), #end text input
                
              textInput("year", "Year"), #end text input
                
              selectInput("os_type", "Country",
                          c("Nothing Selected", unique(test$country_final)) #read list of countries from site sheet
                          ), #end select input
                
              selectInput("os_type", "Site",
                            c("Nothing Selected",  "Celestun Fishery Refuge", "Parque Nacional Machalilla", "Scorpion Reef National Park (Arrecife Alacranes Biosphere Reserve)"
                              ) #eventually replace this with an actual list pulling from a file
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
      box(width = 12, "Surveillance Prioritization",
        br("How to Score"),
        br("1 = No priority areas are defined or priority areas are not under surveillance."),
        br("3 = Some of the priority areas are under constant surveillance via regular patrols and surveillance equipment or all priority areas are monitored, but not continuously."),
        br("5 = 100% of the priority areas are monitored continuously via regular patrols and surveillance equipment."	),
        selectInput("os_type", "Score",
                c("",  "1", "2", "3", "4", "5", "NA")),
        textInput("comments", " Comments")
  
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
  column(10,),
  column(2, actionButton("next_2", "Save and Continue", class = "btn-primary")),
) #end fourth fluid row
), #end surveillance and enforcement tab item  

# Policies and Consequences tabItem ----
 
tabItem(tabName = "policies",
        #title row
        fluidRow(h1("Policies and Consequences", align="center"),
                 br()),#end title row
), # end policies tab item

#Training and mentorship tabItem ----
tabItem(tabName = "training",
        #title row
        fluidRow(h1("Training and Mentorship", align="center"),
                 br()),
), #end training and mentorship tabItem

#Community Engagement tabItem ----
tabItem(tabName = "community",
                #title row
                fluidRow(h1("Community Engagement", align="center"),
                         br()),
), #end community engagement tabItem

#Consistent Funding----
tabItem(tabName = "funding",
        fluidRow(h1("Consistent Funding", align="center"),
                 br()),
) #end consisten funding tab item

) #end tab items 
) #end dashboard body 



dashboardPage(header, sidebar, body)
