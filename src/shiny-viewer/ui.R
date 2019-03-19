library(shiny)
library(shinycssloaders)
library(dygraphs)
library(DT)

source("app.R")


fluidPage(
   
   sidebarPanel(

     
     h3("Historische Preise"),
     
     htmlOutput("station"),

     selectInput("price", "Sorte",
                 c("Diesel" = "Diesel",
                   "E10" = "E10",
                   "E5" = "E5")),
     
     dateInput("start", "Beginn:", 
               value = format(Sys.Date()-31,"%Y-%m-%d"), 
               min="2014-06-09", max=format(Sys.Date()-1,"%Y-%m-%d")),
     
     dateInput("end", "Ende:", 
               value = format(Sys.Date()-2,"%Y-%m-%d"), 
               min="2014-06-09",
               max=format(Sys.Date()-1,"%Y-%m-%d"))
   ),
  
  mainPanel(
     withSpinner(dygraphOutput("dygraph"))
   ),
  
  fluidRow(
    
    column(12,
    h3("Abweichungen zum Durchschnittspreis im ausgewählten Zeitraum"))
  ),
  
  fluidRow(
    
    column(12,
           dataTableOutput('table')
    )
  ),
  
  fluidRow(
    
    column(12,
           p("(c) 2019 Raphael Volz (raphael.volz@hs-pforzheim.de) mit Daten CC-BY-SA 4.0 tankerkoenig.de"))
  )
   
)