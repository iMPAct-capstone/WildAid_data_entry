#input and output will be lists of all defined inputs and outputs
server <- function(input, output, session)#rest ofthis needs to be tested --, session) 
{
  observeEvent(input$next_1, {
    newtab <- switch(input$tabs, "data" = "enforcement","enforcement" = "data")
    updateTabItems(session, "tabs", newtab)
  })
  
  observeEvent(input$next_2, {
    newtab <- switch(input$tabs, "enforcement" = "policies", "policies" = "enforcement")
    updateTabItems(session, "tabs", newtab)
  })
}