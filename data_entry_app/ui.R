# dashboard header ----------------------
header <- dashboardHeader(
  
  title = "WildAid Marine MPS Tracker Data Entry",
  titleWidth = 400
  
) #END Dashboard header

# dashboard sidebar ----------------------
sidebar <- dashboardSidebar(
  
  #sidebar menu
  sidebarMenu(
    
    menuItem(text = "Data Entry",
             tabName = "Data Entry",
             icon = icon("table")),
    menuItem(text = "How to Score",
             tabName = "How to Score",
             icon = icon("gauge"))
    
  ) #END sidebar Menu
  
  
) #END Dashboard sidebar