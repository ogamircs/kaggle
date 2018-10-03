#load the libraries
library(randomForest)

#################
## MODELING
#################

#load training data
fullTrain <- read.csv("~/Kaggle/AcquiredShoppers/fullTrainM2.csv",sep=",")
fullTrain <- subset( fullTrain, select = -id )

print("running the RF ...")
rf <- randomForest( repeater ~ .,
                    data = na.roughfix(fullTrain),
                    mtry = 10,
                    ntree = 200,
                    sampsize=c(2000),
                    importance=TRUE,
                    replace=TRUE)

# Model Testing and Assessment

print(rf)
plot(rf)

rn <- round(importance(rf), 2)
print(rn[order(rn[,1], decreasing=TRUE),])

predsTest <- predict(rf, fullTrain, type="prob")
#AUC on seen data
library(pROC)
print("AUC on the seen data:")
print(auc(fullTrain$repeater,predsTest[,2]))
rm(predsTest)
############################
### SCORING for SUBMISSION
############################

rm(fullTrain)

#load training data
fullTest <- read.csv("~/Kaggle/AcquiredShoppers/fullTestM2.csv",sep=",")

preds <- predict(rf, na.roughfix(fullTest), type="prob")

output <- data.frame(cbind(fullTest$id,preds[,2]))
colnames(output)[1] = "id"
colnames(output)[2] = "repeatProbability"

write.csv(output,"~/Kaggle/AcquiredShoppers/submission.csv",row.names = FALSE)
