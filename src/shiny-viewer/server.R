library(shiny)
library(data.table)
library(xts)
library(dygraphs)
library(dplyr)
library(DT)

list_to_string <- function(obj, listname) {
  if (is.null(names(obj))) {
    paste(listname, "[[", seq_along(obj), "]] = ", obj,
          sep = "", collapse = "\n")
  } else {
    paste(listname, "$", names(obj), " = ", obj,
          sep = "", collapse = "\n")
  }
}
 
function(input, output, session) {

  
  # This code will be run after the client has disconnected
  session$onSessionEnded(function() {
    # Something to do here ?
  })

   dataset <- reactive({
     # Parse Query    
     query <- parseQueryString(session$clientData$url_search)
     # Return a string with key-value pairs
     if("stid" %in% names(query)) {
       stid = query$stid
     } else {
       stid = 'b4ed695f-2cfc-4688-8ecf-268b10cdb93e' # OMV Bad Herrenalb
     }
     # Last known price update for this station
     
     con <- dbConnect(drv, dbname=p$dbname, user=p$user, password=p$password, host=p$host, port=p$port)
     max_station =  dbGetQuery(con, statement = paste0("select max(date)",
                                                       " from gas_station_information_history ",
                                                       "where stid='", stid, 
                                                       "'"))
     max = max_station$max
     # First known price update for this station
     min_station =  dbGetQuery(con, statement = paste0("select min(date)",
                                                       " from gas_station_information_history ",
                                                       "where stid='", stid, 
                                                       "'"))
     min = min_station$min
     # Calculate next price update after user chosen interval
     maxts = dbGetQuery(con, statement = paste0("select min(date)",
                                                " from gas_station_information_history ",
                                                "where stid='", stid, 
                                                "' and date >= '", input$daterange[2], " 23:59:59'"))
     if( !is.na(maxts$min)) { if ( maxts$min < max) {  max = maxts$min }}
     # Calculate least price update before chosen interval
     mints = dbGetQuery(con, statement = paste0("select max(date)",
                                                " from gas_station_information_history ",
                                                "where stid='", stid, 
                                                "' and date <= '", input$daterange[1], " 0:00:00'"))
     if( !is.na(mints$max)) { if(mints$max > min) { min = mints$max }}
     ts <- dbGetQuery(con, statement = paste0("select date,diesel,e5,e10",
                                              " from gas_station_information_history ",
                                              "where stid='", stid, 
                                              "' and date <= '", max, 
                                              "' and date >= '", ( min - 60*60), # 1 hour back for GMT vs CET, lala 
                                              "' order by date"))
     
     dbDisconnect(con)
     
     
      if(input$price == "E10") {
         xts(x=ts$e10/10 , order.by=ts$date, name="E10")
      } else if( input$price=="E5") {
         xts(x=ts$e5/10 , order.by=ts$date, name="E5")
      } else {
         xts(x=ts$diesel/10 , order.by=ts$date, name="Diesel")
      }
  })

  #
  output$station  <- renderUI({ 
    
    query <- parseQueryString(session$clientData$url_search)
    if("stid" %in% names(query)) {
      stid = query$stid
    } else {
      stid = 'b4ed695f-2cfc-4688-8ecf-268b10cdb93e' # OMV Bad Herrenalb
    }
    
    con <- dbConnect(drv, dbname=p$dbname, user=p$user, password=p$password, host=p$host, port=p$port)
    address = dbGetQuery(con, statement = paste0("select *",
                                       " from gas_station",
                                       " where id='", stid, 
                                       "'"))
    
    dbDisconnect(con)
    tagList(
      
     h4(paste(address$brand[1], address$name[1])),
     p(paste(address$street[1],address$house_number[1])),
     p(paste(address$post_code[1],address$place[1]))
     
  )})
  
  # Graph Output
  output$dygraph <- renderDygraph({
    dygraph(dataset(), main = paste('Preis von',input$price, "in Cent")) %>%
      dyOptions(drawGrid = input$showgrid) %>%
      dyOptions(stepPlot = TRUE)
  })
  
  # Table Output
  output$table <- renderDataTable({
    d = dataset()
    start = as.POSIXct(paste0(input$daterange[1], " 0:00:00"))
    end = as.POSIXct(paste0(input$daterange[2], " 23:59:59"))
    min = min(index(dataset()))
    max = max(index(dataset()))
    # Regularize TS to 1 min precision
    ts.1min <- seq(min,max, by = paste0("60 s"))
    res <- merge(dataset(), xts(, ts.1min)) # make regular to 1 min with NAs for missing observations
    res <- na.locf(res, na.rm = TRUE) # carry forward values that are NA
    res <- window(x = res,start = start, end= end) # Old window corresponding to user request

    # Aggregate by hours
    ends <- endpoints(res,'minutes',60)
    table =  period.apply(res, ends ,mean)-mean(res)  # abs. savings in cents rounded to two digits
    table = data.frame(date=index(table), coredata(table))
    table$hour = format(table$date, "%H")
    table$date = NULL
    names(table) = c("price","hour")
    result <- tapply(table$price, table$hour, mean)
    result.frame = data.frame(key=names(result), value=result)
    names(result.frame)  = c("hour","price")
    result.frame[,2] = round (  result.frame[,2] ,1) # Show only two Digits
    result.frame =  result.frame[order( result.frame$price), ]
    min_price = min(result.frame$price)
    max_price = max(result.frame$price)
    names(result.frame) = c("Stunde", "Abweichung in Cent")
    result.frame

    DT::datatable(result.frame,
     #             caption = 'Tabelle: Abweichungen zum Durchschnittspreis im ausgewählten Zeitraum (in Cent)',
                  options = list(pageLength = 24, paging = FALSE, searching=FALSE
                                ,
                                  rowCallback = DT::JS(
  ' function(row, data) {
       if (parseFloat(data[1]) >= 2 )
         $("td:eq(1)", row).css("background-color", "#FF0000");
       if (parseFloat(data[1]) <= -2 )
         $("td:eq(1)", row).css("background-color", "#00FF00");
  }'
                 ) #JS
                  ) #Options
                  , rownames= FALSE)
  })

} # End Function (input, output, session)