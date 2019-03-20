library(shiny)
library(shinycssloaders)
library(dygraphs)
library(DT)

source("app.R")


fluidPage(
   
   sidebarPanel(

     
     h3("Historische Preise"),
     
     htmlOutput("station"),

     selectInput("price", "Sorte:",
                 c("Diesel" = "Diesel",
                   "E10" = "E10",
                   "E5" = "E5")),
     dateRangeInput("daterange", "Zeitraum:",
                    start = format(Sys.Date()-8,"%Y-%m-%d"),
                    end   = format(Sys.Date()-1,"%Y-%m-%d"),
                    min="2014-06-09",
                    max=format(Sys.Date()-1,"%Y-%m-%d")
                    )
   ),
  
  mainPanel(
     withSpinner(dygraphOutput("dygraph"))
   ),
  fluidRow(
    
    column(12,
           h4("Unterschied zum Durchschnittspreis im Zeitraum")
           )
    
  ),
  fluidRow(
    
    column(12,
           dataTableOutput('table')
    )
  ),
  
  fluidRow(
    
    column(12,
           p('(c) 2019',
             tags$a(href='https://www.raphaelvolz.de/','Raphael Volz (raphael.volz@hs-pforzheim.de)'),' | ',
             tags$a(href='https://github.com/volzinnovation/wanntanken','Open Source - Fork me on Github'),' | ',
             tags$a(href='http://tankerkoenig.de','Daten von tankerkoenig.de unter CC-BY-SA 4.0')
           )
    )       
  )
   
)