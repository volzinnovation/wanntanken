require(RPostgreSQL)
require(properties)
p = read.properties("secret.properties")
drv <- dbDriver("PostgreSQL")

# on.exit(dbDisconnect(con))

# df <- dbGetQuery(con, statement = paste("SELECT count(*)","FROM gas_station"))

# e5 = zoo(fuel$e5, order.by=as.POSIXlt(fuel$Index))
# diesel = zoo(fuel$diesel, order.by=as.POSIXlt(fuel$Index))
# s = subset(fuel, fuel$date>=as.Date("2016-01-01") & date<=as.Date("2017-12-31"))
