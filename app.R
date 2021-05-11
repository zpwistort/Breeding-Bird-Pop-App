## app.R ##
library(shiny)
library(shinydashboard)
library(tidyverse)
library(leaflet)
library(leaflet.extras)
#install.packages("Cairo")
library(Cairo)
options(shiny.usecairo=T)

## data
setwd('D:/Bird pop app/')

data <- read.csv('all_observations.csv')
routes <- read.csv('routes.csv')
species <- read_table('SpeciesList.txt',skip = 9)
species <- species[-1,]

y <- data %>% group_by(Year) %>% summarize(count = n())



ui <- dashboardPage(
  dashboardHeader(title = 'Breeding Bird Survey'),
  dashboardSidebar(
    sidebarMenu(
      selectInput(
        inputId = 'birdSelect',
        label = 'Bird...',
        choices = species$English_Common_Name,
        selected = NULL,
        multiple = FALSE,
        selectize = TRUE,
        width = NULL,
        size = NULL
      ),
      selectInput(
        inputId = 'yearSelect',
        label = 'Year...',
        choices = "",
        selected = NULL,
        multiple = FALSE,
        selectize = TRUE,
        width = NULL,
        size = NULL
      )
    )
  ),
  dashboardBody(
    # tags$style(type="text/css",
    #            ".shiny-output-error { visibility: hidden; }",
    #            ".shiny-output-error:before { visibility: hidden; }"
    # ),
    leafletOutput("birdmap"),
    br(),
    plotOutput("timeSeries"),
    br(),
    actionButton("button", "An action button")
    
  )
)

server <- function(input, output, session){
  
  rowBird <- reactive({ which(species$English_Common_Name == input$birdSelect) })
  
  year <- reactive({
    
    data %>% 
      filter(AOU == as.numeric(species$AOU[rowBird()])) %>%
      select('Year') %>%
      arrange(Year)
    
  })
  
  
  # this says.... hey when a year() changes update the year input selector with the new list of available years
  observeEvent(
    year(),
    updateSelectInput(session,
                      "yearSelect", 
                      label = "Year...", 
                      choices = data %>% 
                                filter(AOU == as.numeric(species$AOU[rowBird()])) %>%
                                select('Year') %>%
                                arrange(Year)
    )
  )
  

  
  output$birdmap <- renderLeaflet({
    
    
    data %>%
      filter(AOU == as.numeric(species$AOU[rowBird()]) & Year == input$yearSelect) %>%
      left_join(routes, by=c('CountryNum','StateNum','Route')) %>% 
      mutate(lab = paste0(RouteName,': ', as.character(SpeciesTotal))) %>%
      leaflet(options = leafletOptions(minZoom = 2, maxZoom = 5)) %>%
        addProviderTiles(providers$CartoDB.Positron) %>%
        setView( lng = -97,
                 lat = 38,
                 zoom = 3 ) %>%
        setMaxBounds(lng1 = -55,
                     lat1 = 10,
                     lng2 = -160,
                     lat2 = 80) %>%
        addHeatmap(lng=~as.numeric(Longitude),
                   lat=~as.numeric(Latitude),
                   intensity = ~as.numeric(SpeciesTotal),
                   radius = 25,
                   blur = 40) %>%
        addCircleMarkers(lng=~as.numeric(Longitude),
                         lat=~as.numeric(Latitude),
                         label = ~lab,
                         radius = 2,
                         opacity = 0.3,
                         col = "black")
    
  })
  
  
  
  
  
  
  output$timeSeries <- renderPlot({
    

    data %>%
      filter(AOU == as.numeric(species$AOU[rowBird()])) %>%
      group_by(Year) %>%
      summarize(raw_abund = sum(SpeciesTotal),
                norm_abund = sum(SpeciesTotal)/n()) %>% # just total frequency
      ggplot(aes(x=Year,y=norm_abund))+
      geom_line(size = 2, color = 'dark gray')+
      geom_smooth(color ='black',linetype=3,se=FALSE,size=1.5)+
      geom_point(size = 2.5, color = 'blue')+
      labs(title=species$English_Common_Name[rowBird()],
           x = 'Year',
           y = 'Normalized Abundance')+
      theme_bw()+
      theme(panel.grid = element_blank(),
            text = element_text(size = 15))+
      scale_x_continuous(limits = c(1966,2019),breaks = seq(1965,2020,5))
    
    
  })
  
  
}

shinyApp(ui, server)












