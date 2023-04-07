url <- "https://docs.google.com/spreadsheets/d/1jhKXPigQKs0r9vg1hAX3n0hAkwfFuNu0uPpA9MD8gTk/edit#gid=818092877"

test <- read_sheet(url)

#input and output will be lists of all defined inputs and outputs
server <- function(input, output, session)
{ 
#next buttons ----  
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
  
  #policies and consequences next button 
  observeEvent(input$next_3, {
    newtab <- switch(input$tabs, "policies" = "training", "training" = "policies")
    updateTabItems(session, "tabs", newtab)
  }) #end policies tab next button
  
  #training and mentorship next button
  observeEvent(input$next_4, {
    newtab <- switch(input$tabs, "training" = "community", "community" = "training")
    updateTabItems(session, "tabs", newtab)
  }) #end training tab next button
  
  #community engagement next button
  observeEvent(input$next_5, {
    newtab <- switch(input$tabs, "community" = "funding", "funding" = "community")
    updateTabItems(session, "tabs", newtab)
  }) #end community engagement next button
  
  
# end next buttons

#update site choices ---- 
  observeEvent(input$Country_input,{
    if (input$Country_input %in% test$country_final){
      new_data <- test |> filter(country_final == input$Country_input)
    updateSelectInput(session, 'Site_input',
                      choices= new_data$site)}
    if (input$Country_input == "Select Option"){
      updateSelectInput(session, 'Site_input',
                        choices= "Select Option")}
    
  }) #end observe input country box  
}