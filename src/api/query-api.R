# Test history API
require(RPostgreSQL)
require(xts)
require(properties)


#* @param fuel The fuel type either E10, E5, or Diesel, where Diesel is the default
#* param stid The station id
#* @get /min
function(stid="",fuel=""){
  # remove injections, take default stid
  if(nchar(stid)<30) {
    stid = 'b4ed695f-2cfc-4688-8ecf-268b10cdb93e' # OMV Bad Herrenalb
  }
  # take default type
  if(!(fuel=='E10' | fuel=='E5' | fuel=='Diesel')) {
    fuel = 'Diesel'
  }
  # TODO allow other data ranges
  yesterday <- format(Sys.Date()-1,"%Y-%m-%d")
  priorday <- format(Sys.Date()-1,"%Y-%m-%d")
  # Setup Database Connection
  
  p = read.properties("secret.properties")
  drv <- dbDriver("PostgreSQL")
  
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
                                             "' and date >= '", yesterday, " 23:59:59'"))
  if( !is.na(maxts$min)) { if ( maxts$min < max) {  max = maxts$min }}
  # Calculate least price update before chosen interval
  mints = dbGetQuery(con, statement = paste0("select max(date)",
                                             " from gas_station_information_history ",
                                             "where stid='", stid, 
                                             "' and date <= '", priorday, " 0:00:00'"))
  if( !is.na(mints$max)) { if(mints$max > min) { min = mints$max }}
  ts <- dbGetQuery(con, statement = paste0("select date,diesel,e5,e10",
                                           " from gas_station_information_history ",
                                           "where stid='", stid, 
                                           "' and date <= '", max, 
                                           "' and date >= '", ( min - 60*60), # 1 hour back for GMT vs CET, lala 
                                           "' order by date"))
  dbDisconnect(con)
  if(fuel == "E10") {
    min(ts$e10)
  } else if( fuel=="E5") {
    min(ts$e5)
  } else {
    min(ts$diesel)
  }
}


#* @param fuel The fuel type either E10, E5, or Diesel, where Diesel is the default
#* param stid The station id
#* @get /max
function(stid="",fuel=""){
  # remove injections, take default stid
  if(nchar(stid)<30) {
    stid = 'b4ed695f-2cfc-4688-8ecf-268b10cdb93e' # OMV Bad Herrenalb
  }
  # take default type
  if(!(fuel=='E10' | fuel=='E5' | fuel=='Diesel')) {
    fuel = 'Diesel'
  }
  # TODO allow other data ranges
  yesterday <- format(Sys.Date()-1,"%Y-%m-%d")
  priorday <- format(Sys.Date()-1,"%Y-%m-%d")
  # Setup Database Connection
  
  p = read.properties("secret.properties")
  drv <- dbDriver("PostgreSQL")
  
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
                                             "' and date >= '", yesterday, " 23:59:59'"))
  if( !is.na(maxts$min)) { if ( maxts$min < max) {  max = maxts$min }}
  # Calculate least price update before chosen interval
  mints = dbGetQuery(con, statement = paste0("select max(date)",
                                             " from gas_station_information_history ",
                                             "where stid='", stid, 
                                             "' and date <= '", priorday, " 0:00:00'"))
  if( !is.na(mints$max)) { if(mints$max > min) { min = mints$max }}
  ts <- dbGetQuery(con, statement = paste0("select date,diesel,e5,e10",
                                           " from gas_station_information_history ",
                                           "where stid='", stid, 
                                           "' and date <= '", max, 
                                           "' and date >= '", ( min - 60*60), # 1 hour back for GMT vs CET, lala 
                                           "' order by date"))
  dbDisconnect(con)
  if(fuel == "E10") {
    max(ts$e10)
  } else if( fuel=="E5") {
   max(ts$e5)
  } else {
    max(ts$diesel)
  }
}


#* @param fuel The fuel type either E10, E5, or Diesel, where Diesel is the default
#* @param stid The station ID of the fuel station
#* @get /history
function(stid="",fuel=""){
  # remove injections, take default stid
  if(nchar(stid)<30) {
    stid = 'b4ed695f-2cfc-4688-8ecf-268b10cdb93e' # OMV Bad Herrenalb
  }
  # take default type
  if(!(fuel=='E10' | fuel=='E5' | fuel=='Diesel')) {
    fuel = 'Diesel'
  }
  # TODO allow other data ranges
  yesterday <- format(Sys.Date()-1,"%Y-%m-%d")
  priorday <- format(Sys.Date()-1,"%Y-%m-%d")
  # Setup Database Connection

  p = read.properties("secret.properties")
  drv <- dbDriver("PostgreSQL")
  
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
                                             "' and date >= '", yesterday, " 23:59:59'"))
  if( !is.na(maxts$min)) { if ( maxts$min < max) {  max = maxts$min }}
  # Calculate least price update before chosen interval
  mints = dbGetQuery(con, statement = paste0("select max(date)",
                                             " from gas_station_information_history ",
                                             "where stid='", stid, 
                                             "' and date <= '", priorday, " 0:00:00'"))
  if( !is.na(mints$max)) { if(mints$max > min) { min = mints$max }}
  ts <- dbGetQuery(con, statement = paste0("select date,diesel,e5,e10",
                                           " from gas_station_information_history ",
                                           "where stid='", stid, 
                                           "' and date <= '", max, 
                                           "' and date >= '", ( min - 60*60), # 1 hour back for GMT vs CET, lala 
                                           "' order by date"))
  
  dbDisconnect(con)
  
  
  if(fuel == "E10") {
    dataset=xts(x=ts$e10/10 , order.by=ts$date, name="E10")
  } else if( fuel=="E5") {
    dataset=xts(x=ts$e5/10 , order.by=ts$date, name="E5")
  } else {
    dataset=xts(x=ts$diesel/10 , order.by=ts$date, name="Diesel")
  }
  
  start = as.POSIXct(paste0(yesterday, " 0:00:00"))
  end = as.POSIXct(paste0(yesterday, " 23:59:59"))
  min = min(index(dataset))
  max = max(index(dataset))
  # Regularize TS to 1 min precision
  ts.1min <- seq(min,max, by = paste0("60 s"))
  res <- merge(dataset, xts(, ts.1min)) # make regular to 1 min with NAs for missing observations
  res <- na.locf(res, na.rm = TRUE) # carry forward values that are NA
  # res <- window(x = res,start = start, end= end) # Old window corresponding to user request
  
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
 #  result.frame =  result.frame[order( result.frame$price), ]
  min_price = min(result.frame$price)
  max_price = max(result.frame$price)
  #names(result.frame) = c("Stunde", "Abweichung in Cent")
  result.frame$price
  #list(prices=result.frame$price) 
  #list(min_price=paste0("",min_price),max_price=paste0("",max_price)) # ,history=result.frame)
  # list(msg = paste0("The station id is: '", stid, "', you requested data for ", fuel))
}

