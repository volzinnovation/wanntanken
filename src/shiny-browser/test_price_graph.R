# Load Data
d2 = readRDS("stations.RDS")

# Calculate Densities
diesel_dense <- density(d2$diesel/10) # returns the density data
e5_dense <- density(d2$e5/10) # returns the density data
e10_dense <- density(d2$e10/10) # returns the density data



# Plot Density Diagram
plot(e5_dense,cex=2, col="lightblue", xlab="Preis in Euro Cent", main="Tagesdurchschnittspreis dt. Tankstellen 2019", xlim=c(100,160), ylim=c(0,0.25), ylab="Anteil der Tankstellen")
lines(diesel_dense,cex=2, col="red")
lines(e10_dense, cex=2,col="blue")
abline(v=median(d2$diesel/10), col="red")
abline(v=median(d2$e10/10), col="blue")
abline(v=median(d2$e5/10), col="lightblue")
legend("topright", c("E10","E5","Diesel"), col = c("blue", "lightblue", "red"), lty = c(1, 2))  
text(x=median(d2$diesel/10), col="red", y=0.2,labels=paste(round(median(d2$diesel/10),1)),pos=2,adj=0)
text(x=median(d2$e10/10), col="blue", y=0.2,labels=paste(round(median(d2$e10/10),1)),pos=2,adj=0)
text(x=median(d2$e5/10), col="lightblue", y=0.2,labels=paste(round(median(d2$e5/10),1)),pos=4,adj=1)
