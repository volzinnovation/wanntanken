library(plumber)
r<-plumb("test-api.R")
r$run(port=8080)