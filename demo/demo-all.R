# Libraries to for decision trees
library(rpart)
library(rpart.plot)
library(ranger)
library(randomForest)
# File to load
filename = "ka.rds" 
# Load File
x = readRDS(filename)
# Convert Date to Date
x$date = as.Date(x$date)
# Convert to Cents
x$e10 = x$e10/10
x$e5 = x$e5/10
x$diesel = x$diesel/10
# Create Subsets
test = subset(x, date==as.Date("2019/03/28"))
train = subset(x,date<as.Date("2019/03/28"))
# Create linear regression model
lm = lm( e10 ~ oillag16 + as.factor(hour) + as.factor(weekday),  data=train)
# Create deciscion tree model
dt = rpart( e10 ~ oillag16 + as.factor(hour) + as.factor(weekday), data=train)
# Create random forest model
rf = ranger( e10 ~ oillag16 + hour + weekday, data=train, num.trees = 100)
rf2 = randomForest( e10 ~ oillag16 + hour + weekday, data=train, ntrees = 100)
# View Model properties
summary(lm)
# Use model to make prediction on test data
p_lm = predict(lm, newdata=test)
p_dt = predict(dt, newdata=test)
p_rf2 = predict(rf2, newdata=test)
p_rf = predict(rf, data=test)$predictions # ranger specific
# Calculate RMSE on Test
RMSE_lm = sqrt(sum((p_lm - test$e10)^2)/nrow(test)) 
RMSE_lm
RMSE_dt = sqrt(sum((p_dt - test$e10)^2)/nrow(test)) 
RMSE_dt
RMSE_rf = sqrt(sum((p_rf - test$e10)^2)/nrow(test)) 
RMSE_rf
RMSE_rf2 = sqrt(sum((p_rf2 - test$e10)^2)/nrow(test)) 
RMSE_rf2
# Single prediction
oilprice = 59.8868	
t = data.frame(oillag16=oilprice, hour=8, weekday=5)
p_t_lm = predict(lm, newdata=t)
p_t_lm
p_t_dt = predict(dt, newdata=t)
p_t_dt
p_t_rf = predict(rf, data=t)$predictions
p_t_rf
p_t_rf2 = predict(rf2, newdata=t)
p_t_rf2

