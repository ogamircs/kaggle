library(rattle)

building <- TRUE
scoring  <- ! building

library(colorspace)

HomeFolder = "/Users/amir/Temp/Wallmart3/"

crv$seed <- 42 

print("Reading Data ...")

#choose the DB ro read from for test or scoring
crs$dataset <- read.csv(paste(HomeFolder,"compiled_full_train5.csv",sep=""), na.strings=c(".", "NA", "", "?"), strip.white=TRUE, encoding="UTF-8")

print("Data Reading Finished.")

#crs$dataset <- read.csv("/Users/amir/Temp/Wallmart3/compiled_train3.csv", na.strings=c(".", "NA", "", "?"), strip.white=TRUE, encoding="UTF-8")

set.seed(crv$seed) 
# The following variable selections have been noted.

crs$input <- c("Month", "Week", "IsHoliday",
     "Size", "Dept", "Type", "Temperature",
     "Fuel_Price", "MarkDown1", "MarkDown2", "MarkDown3",
     "MarkDown4", "MarkDown5", "CPI", "Unemployment",
     "Weekly_Sales_N")

crs$numeric <- c("Month", "Week", "Size",
     "Dept", "Temperature", "Fuel_Price", "MarkDown1",
     "MarkDown2", "MarkDown3", "MarkDown4", "MarkDown5",
     "CPI", "Unemployment", "Weekly_Sales_N")

crs$categoric <- "Type"

crs$target  <- "Weekly_Sales"
crs$risk    <- NULL
crs$ident   <- NULL
crs$ignore  <- c("Year", "Date", "Store")
crs$weights <- NULL

#============================================================
# Random Forest 
# The 'randomForest' package provides the 'randomForest' function.

print("Reading Random Forest ...")

require(randomForest, quietly=TRUE)

#Nulls Nulls Nulls!
crs$dataset[["MarkDown1"]][is.na(crs$dataset[["MarkDown1"]])] <- 0
crs$dataset[["MarkDown2"]][is.na(crs$dataset[["MarkDown2"]])] <- 0
crs$dataset[["MarkDown3"]][is.na(crs$dataset[["MarkDown3"]])] <- 0
crs$dataset[["MarkDown4"]][is.na(crs$dataset[["MarkDown4"]])] <- 0
crs$dataset[["MarkDown5"]][is.na(crs$dataset[["MarkDown5"]])] <- 0

crs$dataset[["CPI"]]<- na.roughfix(crs$dataset[["CPI"]])
crs$dataset[["Unemployment"]] <- na.roughfix(crs$dataset[["Unemployment"]])

crs$dataset[["Weekly_Sales_N"]] <- na.roughfix(crs$dataset[["Weekly_Sales_N"]])


# Build the Random Forest model.
set.seed(crv$seed)

crs$rf <- randomForest(Weekly_Sales ~ .,
      data=crs$dataset[,c(crs$input,crs$target)], 
      ntree=2000,
      mtry=15,
      sampsize=c(100000),
      importance=TRUE,
      replace=TRUE)

# Generate textual output of 'Random Forest' model.

print(crs$rf)

# List the importance of the variables.

rn <- round(importance(crs$rf), 2)
print(rn[order(rn[,1], decreasing=TRUE),])


#============================================================
# Score a test dataset. 

print("Running the test ...")

# Read a dataset from file for testing the model.

crs$testset <- read.csv(paste(HomeFolder,"compiled_test5.csv",sep=""), na.strings=c(".", "NA", "", "?"), header=TRUE, sep=",", encoding="UTF-8", strip.white=TRUE)

#Nulls nulls nulls!
crs$testset[["MarkDown1"]][is.na(crs$testset[["MarkDown1"]])] <- 0
crs$testset[["MarkDown2"]][is.na(crs$testset[["MarkDown2"]])] <- 0
crs$testset[["MarkDown3"]][is.na(crs$testset[["MarkDown3"]])] <- 0
crs$testset[["MarkDown4"]][is.na(crs$testset[["MarkDown4"]])] <- 0
crs$testset[["MarkDown5"]][is.na(crs$testset[["MarkDown5"]])] <- 0

crs$testset[["CPI"]]<- na.roughfix(crs$testset[["CPI"]])
crs$testset[["Unemployment"]] <- na.roughfix(crs$testset[["Unemployment"]])
crs$testset[["Weekly_Sales_N"]] <- na.roughfix(crs$testset[["Weekly_Sales_N"]])

# Ensure the levels are the same as the training data

levels(crs$testset[["Date"]]) <- 
  c(levels(crs$testset[["Date"]]), 
    setdiff(levels(crs$dataset[["Date"]]), 
               levels(crs$testset[["Date"]])))

levels(crs$testset[["Type"]]) <- 
  c(levels(crs$testset[["Type"]]), 
    setdiff(levels(crs$dataset[["Type"]]), 
               levels(crs$testset[["Type"]])))

# Obtain predictions for the Random Forest model
crs$pr <- predict(crs$rf, newdata=crs$testset[,c(crs$input)])


#Calculate the Mean Absolute Error and Weighted Mean Absolute Error measures for test dataset
print(paste("MAE=",mean(abs(crs$testset[,c(crs$target)]-crs$pr))))
print(paste("WMAE=",weighted.mean(abs(crs$testset[,c(crs$target)]-crs$pr),crs$testset[["Weight"]])))

# Extract the relevant variables from the dataset.
sdata <- crs$testset[,]


# Output the combined data.
write.csv(cbind(sdata, crs$pr), file=paste(HomeFolder,"compiled_test5_SCORES.csv",sep=""), row.names=FALSE)



#============================================================
# Score the final dataset. 
# Read a dataset from file for scoring the model.

print("Running the final score ...")

crs$testset <- read.csv(paste(HomeFolder,"compiled_full_score5.csv",sep=""), na.strings=c(".", "NA", "", "?"), header=TRUE, sep=",", encoding="UTF-8", strip.white=TRUE)

#nulls nulls nulls!
crs$testset[["MarkDown1"]][is.na(crs$testset[["MarkDown1"]])] <- 0
crs$testset[["MarkDown2"]][is.na(crs$testset[["MarkDown2"]])] <- 0
crs$testset[["MarkDown3"]][is.na(crs$testset[["MarkDown3"]])] <- 0
crs$testset[["MarkDown4"]][is.na(crs$testset[["MarkDown4"]])] <- 0
crs$testset[["MarkDown5"]][is.na(crs$testset[["MarkDown5"]])] <- 0

crs$testset[["CPI"]]<- na.roughfix(crs$testset[["CPI"]])
crs$testset[["Unemployment"]] <- na.roughfix(crs$testset[["Unemployment"]])
crs$testset[["Weekly_Sales_N"]] <- na.roughfix(crs$testset[["Weekly_Sales_N"]])

# Ensure the levels are the same as the training data
levels(crs$testset[["Date"]]) <- 
  c(levels(crs$testset[["Date"]]), 
    setdiff(levels(crs$dataset[["Date"]]), 
               levels(crs$testset[["Date"]])))

levels(crs$testset[["Type"]]) <- 
  c(levels(crs$testset[["Type"]]), 
    setdiff(levels(crs$dataset[["Type"]]), 
               levels(crs$testset[["Type"]])))

# Obtain predictions for the Random Forest model on compiled_full_score2.csv.
crs$pr <- predict(crs$rf, newdata=crs$testset[,c(crs$input)])

# Extract the relevant variables from the dataset.
sdata <- crs$testset[,]

# Output the combined data.
write.csv(cbind(sdata, crs$pr), file=paste(HomeFolder,"compiled_full_score5_SCORES.csv",sep=""), row.names=FALSE)

