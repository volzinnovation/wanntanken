library(plumber)
r<-plumb("query-api.R")
r$run("0.0.0.0", port=8000)
