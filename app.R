library(shiny)
library(shinydashboard)
library(tidyverse)
library(leaflet)
library(leaflet.extras)
#install.packages("Cairo")
library(Cairo)
options(shiny.usecairo=T)

## data

CA_data <- read.csv('CA_occurrence_data.csv')
US_data1 <- read.csv('US_occurence_data1.csv')
US_data2 <- read.csv('US_occurence_data1.csv')
data <- bind_rows(CA_data,US_data1,US_data2)

routes <- read.csv('routes.csv')
species <- read.csv('species.csv')


data2 <-
data %>%
  left_join(routes, by=c('CountryNum','StateNum','Route')) %>%
  mutate(lab = paste0(RouteName,': ', as.character(SpeciesTotal)))

min <- range(data2$Year)[1]
max <- range(data2$Year)[2]




## Shiny App code

ui <- dashboardPage(
  dashboardHeader(title = 'Breeding Bird Survey'),
  dashboardSidebar(
    sidebarMenu(
      selectInput(
        inputId = 'birdSelect',
        label = 'Bird...',
        choices = species$English_Common_Name,
        selected = 'Canada Goose',
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
    tags$style(type="text/css",
               ".shiny-output-error { visibility: hidden; }",
               ".shiny-output-error:before { visibility: hidden; }"
    ),
    leafletOutput("heatmap"),
    br(),
    plotOutput("timeSeries"),
    br()
    
  )
)

server <- function(input, output, session){
  
  aou <- reactive({ species$AOU[which(species$English_Common_Name == input$birdSelect)] })
  
  choices <- reactive({ data2 %>% filter(AOU == aou()) %>% select('Year') %>% unique() %>% arrange(Year) })
  
  observeEvent(
    input$birdSelect,{
      
      freezeReactiveValue(input, "yearSelect")
      updateSelectInput(session,"yearSelect",label = "Year...",choices = choices())
      
    }
  )
  
  
  
  output$heatmap <- renderLeaflet({
    
    

    data2 %>%
      filter(AOU == aou() & Year == input$yearSelect) %>%
      group_by(StateNum, Route) %>%
      summarize(total = sum(SpeciesTotal)/n(),
                Longitude = Longitude[1],
                Latitude = Latitude[1],
                RouteName = RouteName[1]) %>%
      mutate(lab = paste0(RouteName,': ', as.character(total))) %>%
      leaflet(options = leafletOptions(minZoom = 2, maxZoom = 5)) %>%
        addProviderTiles(providers$CartoDB.Positron) %>%
        setView( lng = -97,
                 lat = 38,
                 zoom = 3 ) %>%
        setMaxBounds(lng1 = -55,
                     lat1 = 10,
                     lng2 = -160,
                     lat2 = 80) %>%
        addHeatmap(lng=~Longitude,
                   lat=~Latitude,
                   intensity = ~total,
                   radius = 25,
                   blur = 50) %>%
        addCircleMarkers(lng=~Longitude,
                         lat=~Latitude,
                         label = ~lab,
                         radius = 2,
                         opacity = 0.3,
                         col = "black")
    
  })
  
  
  
  
  
  
  output$timeSeries <- renderPlot({
    
    data2 %>%
      filter(AOU == aou()) %>%
      group_by(Year) %>%
      summarize(raw_abund = sum(SpeciesTotal),
                norm_abund = sum(SpeciesTotal)/n()) %>%
      ggplot(aes(x=Year,y=norm_abund))+
      geom_line(size = 2, color = 'dark gray')+
      geom_smooth(color ='black',linetype=3,se=FALSE,size=1.5)+
      geom_point(size = 2.5, color = 'blue')+
      labs(title=input$birdSelect,
           x = 'Year',
           y = 'Normalized Abundance')+
      theme_bw()+
      theme(panel.grid = element_blank(),
            text = element_text(size = 15))+
      scale_x_continuous(limits = c(1966,2019),breaks = seq(1965,2020,5))
    
    
  })
  
  
}

shinyApp(ui, server)












