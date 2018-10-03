#load the libraries
library(randomForest)

##################
##DATA PREP
##################

#read the data
offers <- read.csv("~/Kaggle/AcquiredShoppers/offers.csv",sep=",")
txns <- read.csv("~/Kaggle/AcquiredShoppers/aggTxns.csv",sep=",")
train <- read.csv("~/Kaggle/AcquiredShoppers/trainHistory.csv",sep=",")

#merge train with offers
trainWoffer <- merge(offers,train,by="offer")


fullTrain <- merge(trainWoffer,txns,
                   by=c("id","chain","category","company","brand"),all.x=TRUE)

fullTrain <- na.roughfix(fullTrain)
aggfullTrain <- aggregate(fullTrain, by=list(AGid=fullTrain$id,AGrepeater=fullTrain$repeater), 
                    FUN=mean, na.rm=TRUE)

aggfullTrain <- subset( aggfullTrain, select = -c(id,repeater) )
colnames(aggfullTrain)[1] <- "id"
colnames(aggfullTrain)[2] <- "repeater"

write.csv(aggfullTrain,"~/Kaggle/AcquiredShoppers/fullTrain.csv",row.names = FALSE)
rm(train);rm(trainWoffer);rm(fullTrain);rm(aggfullTrain);

#read the test data
test <- read.csv("~/Kaggle/AcquiredShoppers/testHistory.csv",sep=",")

#merge train with offers
testWoffer <- merge(offers,test,by="offer")
fullTest <- merge(testWoffer,txns,by=c("id","chain","category","company","brand"),all.x=TRUE)

fullTest <- na.roughfix(fullTest)
aggfullTest <- aggregate(fullTest, by=list(AGid=fullTest$id), 
                          FUN=mean, na.rm=TRUE)
aggfullTest <- subset( aggfullTest, select = -id )
colnames(aggfullTest)[1] <- "id"


write.csv(aggfullTest,"~/Kaggle/AcquiredShoppers/fullTest.csv",row.names = FALSE)
rm(test);rm(testWoffer);rm(fullTest);rm(aggfullTest);
rm(txns);rm(offers);

#################
## MODELING
#################

#load training data
fullTrain <- read.csv("~/Kaggle/AcquiredShoppers/fullTrain.csv",sep=",")

print("running the RF ...")
rf <- randomForest( repeater ~ category + dept +
                      offervalue +
                       purchaseamount,
                    data = fullTrain,
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
fullTest <- read.csv("~/Kaggle/AcquiredShoppers/fullTest.csv",sep=",")

preds <- predict(rf, fullTest, type="prob")

output <- data.frame(cbind(fullTest$id,preds[,2]))
colnames(output)[1] = "id"
colnames(output)[2] = "repeatProbability"

write.csv(output,"~/Kaggle/AcquiredShoppers/submission.csv",row.names = FALSE)
