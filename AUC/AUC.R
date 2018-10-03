#load the data
data <- read.csv(file="~/Downloads/auc_test.csv",sep=",")
library(dplyr)
data <- arrange(data,PRED)

n = nrow(data)

ones = sum(data$REAL)
if(ones == 0 || ones == n) return(1)

truePos = tp0 = ones
accum = tn = 0
thershold = data$PRED[1]

for(i in 1:n) {
  if(data$PRED[i] != thershold) {
    thershold = data$PRED[i]
    #calculating the trapzoid area
    # truePos and tp0 are the two parallel lines and tn is the height
    accum = accum + tn*(truePos + tp0)
    
    #keep the tp0 to the previous value
    tp0 = truePos
    tn = 0
  }
  tn = tn + 1 - data$REAL[i]
  truePos = truePos - data$REAL[i]
}

accum = accum +  tn * (truePos + tp0)
AUC = accum / (2 * ones * (n-ones))

print(AUC)
