

server <- function(input, output, session){
  
  # finds the aou of the selected bird species
  aou <- reactive({ species$AOU[which(species$English_Common_Name == input$birdSelect)] })
  
  # updates the year selection
  choices <- reactive({ data2 %>% filter(AOU == aou()) %>% select('Year') %>% unique() %>% arrange(Year) })
  
  # this observes changes in the input$birdSelect
  observeEvent(
    input$birdSelect,{
      
      freezeReactiveValue(input, "yearSelect")
      updateSelectInput(session,"yearSelect",label = "Year...",choices = choices())
      
    }
  )
 
  # creates title 
  output$commonName <- renderText({ as.character(input$birdSelect) })
  output$scienceName <- renderText({ paste(species %>% filter(AOU == aou()) %>% select(Genus),
                                           species %>% filter(AOU == aou()) %>% select(Species)) })
  # output$title <- renderText({
  #   
  #   div(
  #     h1(paste(input$birdSelect), style = "display: inline;")#,
  #     # h5(paste(c('', selecteds[3:length(selecteds)]), collapse = " > "), style = "display: inline;")
  #   )
  #   
  # })  

  
  # creates the heat map plot
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
  
  # creates the time series plot
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
      labs(x = 'Year',
           y = 'Normalized Abundance')+
      theme_bw()+
      theme(panel.grid = element_blank(),
            text = element_text(size = 15))+
      scale_x_continuous(limits = c(minYear,maxYear),breaks = seq(minYear,maxYear,2))
    
    
  })
  
  # creates the latitude histogram
  output$latitude <- renderPlot({
    
    data2 %>%
      filter(AOU == aou()) %>%
      group_by(latitudeLabs) %>%
      summarize(total = sum(SpeciesTotal)) %>%
      ggplot(aes(x=total,y=latitudeLabs))+
      geom_bar(stat='identity',color = 'dark gray')+
      scale_y_discrete(limits = lab,
                       breaks = seq(20,70,5))+
      labs(x = 'Raw abundance',
           y = 'Latitude')+
      theme_bw()+
      theme(panel.grid = element_blank(),
            text = element_text(size = 15))
    
  })
  
  
}










