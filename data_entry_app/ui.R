# dashboard header ----------------------
header <- dashboardHeader(
  
  title = "WildAid Marine MPS Tracker Data Entry",
  titleWidth = 400
  
) #END Dashboard header

# dashboard sidebar ----------------------
sidebar <- dashboardSidebar(
  
  #sidebar menu
  sidebarMenu(
    
    menuItem(text = "Data Entry Main Page",
             tabName = "Data",
             icon = icon("table")),
    
    menuItem(text = "Surveilance and Enforcement",
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
  tabItem(tabName = "Data",
   #column row ---- 
   column(width = 7,
  #fluidRow ----      
     fluidRow(
            box(width = 7,
                
                textInput("name", " Evaluator Name(s)"), #end text input
                
                textInput("year", "Year"), #end text input
                
                selectInput("os_type", "Country",
                            c("",  "Ecuador", "Gabon", "Mexico") #eventually replace this with an actual list
                ), #end select input
                
                selectInput("os_type", "Site",
                            c("",  "Celestun Fishery Refuge", "Parque Nacional Machalilla", "Scorpion Reef National Park (Arrecife Alacranes Biosphere Reserve)") #eventually replace this with an actual list pulling from a file
                ), #end site select input
                
                actionButton("submit", "Submit", class = "btn-primary") #submit button
            ) #end box
          ), #end fluid row 
   ), #end column
 
  #Second Column on main page ---- 
  column(width = 3,
  
#second fluid Row ----
  fluidRow(
    
# general instructions box ----
    box(width = NULL,
        
        "Some general data entry instructions can go here"
        
    ) # END general instructions box
    
  ) # END second fluidRow  
  
  ) #end column
  ), #end main data entry tab item


# Surveillance tabItem ----
tabItem(tabName = "enforcement", 
        #first fluid Row ---- 
        fluidRow(
#surveillance prioritization box ----        
box(width = 4, "Surveilance Prioritization",
    br("How to Score"),
    br("1 = No priority areas are defined or priority areas are not under surveillance."),
br("3 = Some of the priority areas are under constant surveillance via regular patrols and surveillance equipment or all priority areas are monitored, but not continuously."),
br("5 = 100% of the priority areas are monitored continuously via regular patrols and surveillance equipment."	),
    selectInput("os_type", "Score",
                c("",  "1", "2", "3", "4", "5")),
    textInput("comments", " Comments")
  
) # end surveilance prioritization box
), #end first fluid row 

#second fluid Row ---- 
fluidRow(
 #start vessel availability box
   box(width = 4, "Vessel Availability",
      br("How to Score"),
      br("1 = Vessels are in poor shape. Vessel availability is low."),
      br("3 = Vessels are in good condition. Vessel availability is average (approximately 50% or more)."),
      br("5 = Vessels are in good condition. Vessel availability is higher than 75%."),
      selectInput("os_type", "Score",
                  c("",  "1", "2", "3", "4", "5")),
      textInput("comments", " Comments")
      
) # end vessel availability box
) #end second fluid row 
) #end surveillance and enforcement tab item  
) #end tab items 
) #end dashboard body 


dashboardPage(header, sidebar, body)
