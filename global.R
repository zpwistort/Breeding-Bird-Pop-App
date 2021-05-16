library(shiny)
library(shinydashboard)
library(tidyverse)
library(leaflet)
library(leaflet.extras)
#install.packages("Cairo")
library(Cairo)
options(shiny.usecairo=T)

## data

# CA_data <- read.csv('CA_occurrence_data.csv')
# US_data1 <- read.csv('US_occurence_data1.csv')
# US_data2 <- read.csv('US_occurence_data1.csv')
# data <- bind_rows(CA_data,US_data1,US_data2)

data2 <- read.csv('data_filtered_2000.csv')
routes <- read.csv('routes.csv')
species <- read.csv('species.csv')


# data_filtered_2000
# data_join <-
# data %>%
#   # filter(Year >= 2000) %>%
#   left_join(routes, by=c('CountryNum','StateNum','Route')) %>%
#   mutate(lab = paste0(RouteName,': ', as.character(SpeciesTotal)))


# write.csv(data_filtered_2000, 'data_filtered_2000.csv')


# 
# 
# colnames(data_join)
# 
# 
# data_filtered_2000 <-
#   data_join %>% 
#     select(-c('Active','BCR','Stratum','RouteTypeDetailID'))
# 
# 
# data_filtered_2000 %>% View()
# 
# 
# write.csv(data_filtered_2000, 'data_filtered_2000.csv')

# min <- range(data2$Year)[1]
# max <- range(data2$Year)[2]





