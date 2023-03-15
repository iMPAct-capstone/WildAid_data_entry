#input and output will be lists of all defined inputs and outputs
server <- function(input, output, session)
{ 
  
  #data tab next button
  observeEvent(input$next_1, {
    newtab <- switch(input$tabs, "data" = "enforcement","enforcement" = "data")
    updateTabItems(session, "tabs", newtab)
  }) #end data tab next button 
  
  #enforcement tab next button 
  observeEvent(input$next_2, {
    newtab <- switch(input$tabs, "enforcement" = "policies", "policies" = "enforcement")
    updateTabItems(session, "tabs", newtab)
  }) #end enforcement tab next button 
}