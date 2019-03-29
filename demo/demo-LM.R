
# File to load
filename = "ka.rds" # Daten für vergangene 8 Tage vom 21.3.-28.3.
# Load File
x = readRDS(filename)
# Convert Date from Text to Date
x$date = as.Date(x$date)
# Convert to Cents
x$e10 = x$e10/10
x$e5 = x$e5/10
x$diesel = x$diesel/10
# Create Subsets
test = subset(x, date==as.Date("2019/03/28")) # gestern
train = subset(x,date<as.Date("2019/03/28")) # letzte woche
# Create linear regression model
lm = lm( e10 ~ oillag16 + as.factor(hour),  data=train)
# View Model properties
summary(lm)
# Use model to make prediction on test data
p_lm = predict(lm, newdata=test)
# Calculate RMSE on Test
RMSE_lm = sqrt(sum((p_lm - test$e10)^2)/nrow(test)) 
RMSE_lm
# Make a Single prediction
oilprice16 = 59.8868 # EUR Schlusskurs vor 16 Tagen am 13.3.
oilprice1 = 60.599 # # Schlusskurs gestern 27.3.
hour = 12
weekday = 5 # Friday
# Predict for today
t = data.frame(oillag16=oilprice16, hour=hour, weekday=weekday)
p_t_lm = predict(lm, newdata=t)
p_t_lm

