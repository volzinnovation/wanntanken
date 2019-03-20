#
# Convert data for price updates in tankerkoenig git repository to format suitable to copy into Postgres
#

args = commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  stop("At least one argument must be supplied (input file).n", call. = FALSE)
} else if (length(args) == 1) {
  d = read.csv(args[1])
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
  # create import CSV file
  write.csv(e, file="import.csv", quote=TRUE, row.names=FALSE)
}