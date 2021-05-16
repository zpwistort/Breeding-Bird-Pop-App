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




