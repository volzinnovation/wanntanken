# install.packages("RPostgreSQL")
# install.packages("properties")
# install.packages("xts")
# install.packages("dygraphs")

require(RPostgreSQL)
require(properties)
require(xts)
require(dygraphs)
stid = '0be32f00-8ff4-45bf-bb4c-1588d6e03aa1'

p = read.properties("secret.properties")
# Establish connection
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname=p$dbname, user=p$user, password=p$password, host=p$host, port=p$port)
# Query DB
start = as.POSIXct('2019-02-01 0:00:00')
end = as.POSIXct('2019-02-01 23:59:59')
# Convert to Time Series Object


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
# Calculate next price update after interval
maxts = dbGetQuery(con, statement = paste0("select min(date)",
                                           " from gas_station_information_history ",
                                           "where stid='", stid, 
                                           "' and date >= '", end, "'"))
if(maxts$min < max) {  max = maxts$min }
# Calculate least price update before interval
mints = dbGetQuery(con, statement = paste0("select max(date)",
                                           " from gas_station_information_history ",
                                           "where stid='", stid, 
                                           "' and date >= '", (start-24*60*60), "'",
                                           " and date <= '", start, "'"))
if(mints$max > min) { min = mints$max }
query = paste0("select date,diesel,e5,e10",
               " from gas_station_information_history ",
               " where stid='", stid, 
               "' and date <= '", max, 
               "' and date >= '", min, 
               "' order by date")
query
ts <- dbGetQuery(con, statement = paste0("select date,diesel,e5,e10",
                                         " from gas_station_information_history ",
                                         " where stid='", stid, 
                                         "' and date <= '", max, 
                                         "' and date >= '", (min-60*60), 
                                         "' order by date"))


x = xts(x=ts$diesel/10 , order.by=ts$date, name="Diesel")
dygraph(x)


# Map to 1 minutes precision
ts.1min <- seq(min,max, by = paste0("60 s"))
res <- merge(x, xts(, ts.1min)) # make regular to 1 min with NAs for missing observations
forw = na.locf(res, na.rm = TRUE) # carry forward values that are NA
win = window(x = forw,start = start, end= end)

# Aggregate by hours
ends <- endpoints(win,'minutes',60) 
table = round ( period.apply(win,ends ,mean)-mean(win) , 2)  # abs. savings in cents rounded to two digits
table = data.frame(date=index(table), coredata(table))
table$hour = format(table$date, "%H")
table$date = NULL
tapply(table$x, table$hour, mean)

address = dbGetQuery(con, statement = paste0("select *",
                                   " from gas_station ",
                                   "where id='", stid, 
                                   "'"))
