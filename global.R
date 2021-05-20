library(shiny)
library(shinydashboard)
library(tidyverse)
library(leaflet)
library(leaflet.extras)
#install.packages("Cairo")
library(Cairo)
options(shiny.usecairo=T)

## data


data2 <- bind_rows(read.csv('data1.csv'),read.csv('data2.csv'),read.csv('data3.csv'))
routes <- read.csv('routes.csv')
species <- read.csv('species.csv')

minYear <- min(data2$Year)
maxYear <- max(data2$Year)


# breaks <- seq(19,70,1)
# lab <- as.character(seq(20,70,1))

# latitudeLabs <- 
#   cut(data2$Latitude,
#       breaks=breaks,
#       labels=as.character(lab))

# data2 <- data2 %>% select(-c('latitudeLabs'))

# data2 <- bind_cols(data2,latitudeLabs=latitudeLabs)




# i <- dim(data2)[1]/3
# 
# write_csv(data2[1:i,],'data1.csv')
# write_csv(data2[(i+1):(2*i),],'data2.csv')
# write_csv(data2[(2*i+1):(3*i),],'data3.csv')















