library(leaflet)
library(shiny)
library(tmaptools)
library(sf)

d = readRDS("stations.RDS")

old_cx = 8.4
old_cy = 49
o = 0.05

r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # # Geolocation of user
  # tags$script('
  #     $(document).ready(function () {
  #             navigator.geolocation.getCurrentPosition(onSuccess, onError);
  #             
  #             function onError (err) {
  #             Shiny.onInputChange("geolocation", false);
  #             }
  #             
  #             function onSuccess (position) {
  #             setTimeout(function () {
  #             var coords = position.coords;
  #             console.log(coords.latitude + ", " + coords.longitude);
  #             Shiny.onInputChange("geolocation", true);
  #             Shiny.onInputChange("lat", coords.latitude);
  #             Shiny.onInputChange("long", coords.longitude);
  #             }, 1100)
  #             }
  #             });
  #             '),
  
  titlePanel("Preishistorie der Tankstellen in Deutschland"),
  
  fluidRow(
    column(12,
    textInput("place", "Finde Tankstellen im Umkreis von:", "Karlsruhe"))
  ),
  
  # Show a plot of the generated distribution
  
  fluidRow(leafletOutput("mymap")),
  
  fluidRow(
    
    column(12,
           p("Farben entsprechen Durchschnittspreisen für Diesel in Deutschland 2019: Grün: Günstigste 25%, Rot:  Teuerste 25%, Gelb: Interquartilbereich, Grau: Vermutlich nicht operativ.")
           ,
           p('(c) 2019',
             tags$a(href='https://www.raphaelvolz.de/','Raphael Volz (raphael.volz@hs-pforzheim.de)'),' | ',
             tags$a(href='https://github.com/volzinnovation/wanntanken','Open Source - Fork me on Github'),' | ',
             tags$a(href='http://tankerkoenig.de','Daten von tankerkoenig.de unter CC-BY-SA 4.0')
           )
    )       
  )
) # Fluidpage UI

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  # #Update on geolocation of user
  # # Zoom in on user location if given
  # observeEvent(input$lat, {
  #   if(!is.null(input$lat)){
  #     map <- leafletProxy("mymap")
  #     dist <- 0.5
  #     lat <- input$lat
  #     lng <- input$long
  #     cx = lng
  #     cy = lat
  #     data = subset(d, latitude < (cy+o) & latitude > (cy-o) & longitude > (cx-o) & longitude < (cx+o) )
  #     map %>% fitBounds(lng - dist, lat - dist, lng + dist, lat + dist) %>%
  #       clearMarkers()   %>% 
  #       addMarkers(~longitude, ~latitude, 
  #                  popup = ~paste0('<a href="https://wanntanken.shinyapps.io/TankeWann/?stid=',as.character(uuid),'">',paste(brand,name),'</a>'), 
  #                  label = ~paste(brand,name))
  #   }
  # })
  # 
  # Update on place search
  place <- eventReactive(input$place, {
    geocode_OSM(input$place)
    
  }, ignoreNULL = FALSE)
  
  # Update on larger map moves
  observeEvent(input$mymap_center, {
    p <- input$mymap_center
    cx = as.numeric(p["lng"])
    cy = as.numeric(p["lat"])
    if(!( cx == 0 | cy == 0)) {
      #print(cx)
      #print(cy)
      if( abs(old_cx - cx) > o | abs(old_cy - cy) > o ) {
        old_cx = cx
        old_cy = cy
        # Reset leaflet
        data = subset(d, latitude < (cy+o) & latitude > (cy-o) & longitude > (cx-o) & longitude < (cx+o) )
        leafletProxy("mymap", data = data) %>%
          clearMarkers()   %>% 
          addCircleMarkers(~longitude, ~latitude, 
                   popup = ~paste0('<a href="https://wanntanken.shinyapps.io/TankeWann/?stid=',as.character(uuid),'">',paste(brand,name),'</a>'), 
                   label = ~paste(brand,name), color=~label, radius=6)
      }
    }
  })
  
  output$mymap <- renderLeaflet({
    p = place()
    tryCatch({
    x = as.numeric(p$coords["x"])
    y = as.numeric(p$coords["y"])
    }, error = function(err) {
      x = old_cx
      y = old_cy
    })
    data = subset(d, latitude < (y+o) & latitude > (y-o) & longitude > (x-o) & longitude < (x+o) )
    print(nrow(data))
    if(nrow(data) > 0) {
      
      m <- leaflet(data=data) %>% addProviderTiles(providers$Stamen.TonerLite, options = providerTileOptions(noWrap = TRUE)) %>% 
        setView(x,y,13) %>% addCircleMarkers( ~longitude, ~latitude, 
                              popup = ~paste0('<a href="https://wanntanken.shinyapps.io/TankeWann/?stid=',as.character(uuid),'">',paste(brand,name),'</a>'), 
                              label = ~paste(brand,name), color=~label, radius=6)
    } else {
      m <- leaflet() %>% addProviderTiles(providers$Stamen.TonerLite, options = providerTileOptions(noWrap = TRUE)) %>% 
        setView(x,y,13) 
      
    }
    # Output map
    m
    
  })
  #
  # output$distPlot <- renderPlot({
  #    # generate bins based on input$bins from ui.R
  #    x    <- faithful[, 2]
  #    bins <- seq(min(x), max(x), length.out = input$bins + 1)
  #
  #    # draw the histogram with the specified number of bins
  #    hist(x, breaks = bins, col = 'darkgray', border = 'white')
  # })
}

# Run the application
shinyApp(ui = ui, server = server)
