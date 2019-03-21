#
# Convert data for price updates in tankerkoenig git repository to format suitable to copy into Postgres
#
# /git/tankerkoenig-data
# prices/2019/03/2019-03-20-prices.csv
prefix = '/git/tankerkoenig-data'
date = Sys.Date()-1 # Yesterdays data is pulled from Git
year = format(date,"%Y")
month= format(date,"%m")
txtdate = format(date,"%Y-%m-%d")
filename = paste0(prefix,"/",year,"/",month,"/",txtdate,"-prices.csv")
d = read.csv(filename)
# drop colums
d$dieselchange = NULL
d$e5change = NULL
d$e10change = NULL
# rename columns to fit table gas_station_information_history
names(d) = c("date","stid","diesel","e5","e10")
# fit number formats
d$e5 = d$e5*1000
d$e10 = d$e10*1000
d$diesel = d$diesel*1000
# reorder columns
e = d[c(2,4,5,3,1)]
# create import CSV file at fixed location
write.csv(e, file="/tmp/import.csv", quote=TRUE, row.names=FALSE)
