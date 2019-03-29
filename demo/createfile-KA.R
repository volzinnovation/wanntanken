library(zoo)
library(xts)
library(readr)
irreg= read.csv("data/ka.csv") # Assume WD is Project Directory
# Date Calculations
irreg$dt = as.POSIXct(irreg$date)
min= min(irreg$dt)
max=max(irreg$dt)
nextday = as.Date(format(min,"%Y-%m-%d"))+1
lastday = as.Date(format(max,"%Y-%m-%d"))
end = as.POSIXct(paste0(format(lastday,"%Y-%m-%d"), " 23:59:59"))
start = as.POSIXct(paste0(format(nextday,"%Y-%m-%d"), " 0:00:00"))
# Create Time Series
x = xts(x=irreg[,1:3] , order.by=irreg$dt, name="prices")
# Regularize TS to 1 min precision
ts.1min <- seq(min,end, by = paste0("60 s"))
res <- merge(x, xts(, ts.1min)) # make regular to 1 min with NAs for missing observations
res2 <- na.locf(res, na.rm = TRUE) # carry forward values that are NA
reg = window(res2, start = start, end=end)

# Link Oil price
oil_eur <- read_delim("data/wkn_COM062_historic_EUR_20190101_20190329.csv", 
                      ";", escape_double = FALSE, col_types = cols(Datum = col_date(format = "%Y-%m-%d"), 
                                                                   Stuecke = col_skip(), Volumen = col_skip()), 
                      locale = locale(decimal_mark = ",", grouping_mark = ""), 
                      trim_ws = TRUE)
oil = xts(oil_eur$Schlusskurs, order.by=oil_eur$Datum) # has gaps on weekends where market is closed
# Fill gaps
seq = seq(as.Date('2019-01-01'),lastday+1, by='days')
res <- merge(oil, xts(, seq)) # make regular to 1 day swith NAs for missing observations
res <- na.locf(res, na.rm = TRUE) # carry forward values that are NA
oil <- res
oillag16= lag(oil, k=16) # 16 days
oillag1 = lag(oil, k=1)
oillag16t =  data.frame(date=index(oillag16), coredata(oillag16))
oillag1t =  data.frame(date=index(oillag1), coredata(oillag1))
# convert to data frame
table = data.frame(date=index(reg), coredata(reg))
# Create a day view to link oil data
table$day = as.Date(format(table$date,"%Y-%m-%d"))
table$dt = table$date
table$date = table$day
table$hour = as.numeric(format(table$dt,"%H"))
table$day = NULL
table$weekday = as.numeric(format(table$date,"%w"))
# Merge Tables
m = merge(x=table, y=oillag1t, by.x="date", by.y="date", all.x=T)
m$oillag1 = m$oil
m$oil = NULL
m = merge(x=m, y=oillag16t, by.x="date", by.y="date", all.x=T)
m$oillag16 = m$oil
m$oil = NULL
d = m[!duplicated(m$dt),]
saveRDS(d,"KA.rds")
