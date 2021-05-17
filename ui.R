




## ui code

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
    tags$div(
      h1(strong(textOutput("commonName")), style ='display: inline;'),
      h2(em(textOutput("scienceName")), style ='display: inline;')
    ),
    leafletOutput("heatmap"),
    br(),
    fluidRow(
      
      box(
        title = "Times Series", status = "primary", solidHeader = TRUE,
        collapsible = TRUE,
        plotOutput("timeSeries")
      ),
      
      box(
        title = "Frequency by Latitude", status = "primary", solidHeader = TRUE,
        collapsible = TRUE,
        plotOutput("latitude")
      )
    ),
    br()
    
  )
)












