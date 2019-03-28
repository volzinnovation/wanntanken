#
# Update Station Labels
#
# Requires avg_by_stid loaded into memory (!)


# Load Data
d = readRDS("stations.RDS")
d2 = merge(x=d, y=avg_by_stid, by.x = "uuid", by.y="stid")

# Calculate Quantiles
diesel_q = quantile(d2$diesel)
e10_q = quantile(d2$e10)
e5_q = quantile(d2$e5)

# Label Data by diesel price
d2$label = ifelse( d2$diesel >= diesel_q["75%"], "red",
                   ifelse(d2$diesel <= diesel_q["25%"], "green", 
                          ifelse(d2$diesel < 1000, "grey", "yellow")))

saveRDS(d2, "stations.RDS",)