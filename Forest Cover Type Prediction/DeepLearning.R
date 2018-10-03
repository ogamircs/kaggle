library(darch)
#data <- read.csv("~/Kaggle/Forest Cover Type Prediction/train.csv", 
#                 na.strings=c(".", "NA", "", "?"), strip.white=TRUE, encoding="UTF-8")

data <- read.table("~/Kaggle/Forest Cover Type Prediction/train.csv", sep=",", 
             na.strings=c(".", "NA", "", "?"), encoding="UTF-8", header=TRUE)
colnames(data) <- NULL
inputs <- matrix(as.matrix(data[2:55]),ncol=54,byrow=TRUE)
outputs <- matrix(as.matrix(data[56]),nrow=15120)

#darch <- newDArch(c(54,54,1),batchSize=2)
darch <- newDArch(c(54,54,5),batchSize=1)
# Pre-Train the darch
darch <- preTrainDArch(darch,inputs,maxEpoch=3)
# Prepare the layers for backpropagation training for
# backpropagation training the layer functions must be
# set to the unit functions which calculates the also
# derivatives of the function result.
layers <- getLayers(darch)
for(i in length(layers):1){
  layers[[i]][[2]] <- sigmoidUnitDerivative
}
setLayers(darch) <- layers
rm(layers)
# Setting and running the Fine-Tune function
setFineTuneFunction(darch) <- backpropagation
darch <- fineTuneDArch(darch,inputs,outputs,maxEpoch=3)

Tdata <- read.table("~/Kaggle/Forest Cover Type Prediction/test.csv", sep=",", 
                   na.strings=c(".", "NA", "", "?"), encoding="UTF-8", header=TRUE)

Tinputs <- matrix(as.matrix(Tdata[2:55]),ncol=54,byrow=TRUE)
# Running the darch
darch <- darch <- getExecuteFunction(darch)(darch,Tinputs)
outputs <- getExecOutputs(darch)
outdata <- data.frame(cbind(Tdata[,1],round(outputs[[length(outputs)]],digits=0)))
colnames(outdata)[1]="Id"
colnames(outdata)[2]="Cover_Type"
write.csv(outdata,file="~/Kaggle/Forest Cover Type Prediction/sub.csv",row.names = FALSE)
## End(Not run)