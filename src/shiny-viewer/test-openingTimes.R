# Test Opening Times
require(RPostgreSQL)
require(properties)
library(jsonlite)

stid = 'b4ed695f-2cfc-4688-8ecf-268b10cdb93e' # OMV Bad Herrenalb

p = read.properties("secret.properties")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname=p$dbname, user=p$user, password=p$password, host=p$host, port=p$port)
address = dbGetQuery(con, statement = paste0("select ot_json",
                                             " from gas_station",
                                             " where id='", stid, 
                                             "'"))
dbDisconnect(con)
minh = 24
maxh = 0

if(address$ot_json[1] == "{}") {
  minh = 0
  maxh = 24
} else {
ot = fromJSON(address$ot_json[1],simplifyVector = TRUE,simplifyDataFrame = TRUE, simplifyMatrix = FALSE,flatten = TRUE)$openingTimes


for(i in seq(1,nrow(ot))) {
  bits = getBitIndicators(ot$applicable_days[i],  c(Mo = 1, Di = 2, Mi = 4, Do = 8, Fr = 16, Sa = 32, So = 64, FT = 128))
  for( j in names(bits) ) {
    cat(i, " " , j, ":" , ot$periods[[i]]$startp[1], "-", ot$periods[[i]]$endp[1], "\n")
    starth = as.numeric(strsplit(ot$periods[[i]]$startp[1], ":")[[1]])[1]
    if(starth < minh) minh = starth
    endh = as.numeric(strsplit(ot$periods[[i]]$endp[1], ":")[[1]])[1]
    if(endh > maxh) maxh = endh
  }
}
} # else
cat("Min:", minh, "\n")
cat("Max:", maxh, "\n")