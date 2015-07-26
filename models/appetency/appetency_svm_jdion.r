##  appetency_svm_jdion

##################################################################################################
###       COMMENT FOR SUPPORT VECTOR MACHINE MODEL FOR CHURN 
##################################################################################################
#
#
#The variable selection process started with the variables selected by the random forrest as being 
#the strongest and then do to performance issues, was reduced to only the 5 strongest variables.
#
#Training the model was also taking as long as an hour for the training data set as well as 
#even a small subset of variables, so, a separate dataset of 20% of the observations was created
#for the SVM model. 
#
#When the results were applied to the test dataset, the ROC curve shows results that don't differ
#signifcantly from a random model. The model herein relies on the radial kernel with a cost of 10.
#linear, polynomial, radial and sigmoid methods were all attempted without signficant improvement.
#
##################################################################################################
##################################################################################################

###ADD LIBRARIES AND FUNCTION
library(kernlab)
library(e1071)
library(ROCR)

rocplot = function (pred, truth, ...){ 
  predob = prediction(pred,truth)
  perf = performance (predob, "tpr", "fpr")
  plot(perf,...)}


###   SET DIRECTORY PATH:
setwd("C:/Users/JoeD/Dropbox/pred_454_team/data")

###   READ DATA FILES:
d <- read.table('orange_small_train.data',  	
                header=T,
                sep='\t',
                na.strings=c('NA','')) 	

churn <- read.table('orange_small_train_churn.labels',
                    header=F,sep='\t') 
d$churn <- churn$V1 	 

upselling <- read.table('orange_small_train_upselling.labels',
                        header=F,sep='\t')
d$upselling <- upselling$V1 	

appetency <- read.table('orange_small_train_appetency.labels',
                        header=F,sep='\t')
d$appetency <- appetency$V1 


###   CREATE TRAINING, TEST AND TINY DATA SETS (TINY INCREASED TO 20% AND USED FOR TRAINING)

set.seed(123)
smp_size <- floor(0.75 * nrow(df))
train_ind <- sample(seq_len(nrow(df)), size = smp_size)
# making a "tiny" data set so I cn quickly test r markdown and graphical paramters
# this will be removed in the submitted version
tiny_ind <- sample(seq_len(nrow(df)), size = floor(0.2 * nrow(df)))
# split the data
train <- df[train_ind, ]
test <- df[-train_ind, ]
tiny <- df[tiny_ind, ]

###   IMPUTE MISSING VARIABLES

for (i in names(df)){
vclass <- class(df[,i])
if(vclass == 'logical'){
# some of the variables are 100% missing, they are the only logical class vars
# so we can safely remove all logical class vars
df[,i] <- NULL
}else if(vclass %in% c('integer', 'numeric')){
#first check that there are missing variables
if(sum(is.na(df[,i])) == 0) next
# create a missing variable column
df[,paste(i,'_missing',sep='')] <- as.integer(is.na(df[,i]))
# fill missing variables with 0
df[is.na(df[,i]),i] <- 0
}else{
# gather infrequent levels into 'other'
levels(df[,i])[xtabs(~df[,i])/dim(df)[1] < 0.015] <- 'other'
# replace NA with 'missing'
levels(df[,i]) <- append(levels(df[,i]), 'missing')
df[is.na(df[,i]), i] <- 'missing'
}
}



### SVM MODEL TRAINED WITH TINY (20% OF DATASET)

svmfit.opt = svm(appetency ~ Var204 + Var226 + Var126 + Var57 + Var113 
#+ Var6 + Var81 + Var125 + Var153 + Var28 + Var216 + Var119 + Var134
#+ Var123 + Var94 + Var76 + Var133 + Var22 + Var206 + Var140 + Var197 + Var73 + Var160 + Var25 + Var13
#+ Var38 + Var21 + Var163 + Var112 + Var83    
, data = tiny, kernel = 'radial', cachesize = 2000, cost=10, decision.values = T)


fitted = attributes(predict(svmfit.opt, test, decision.values = TRUE))$decision.values
rocplot(fitted, test$appetency , main = "ROC Curve for Appetency")

###SAVE RData File 

save(list = c('svmfit.opt'), file = "C:/Users/JoeD/Dropbox/pred_454_team/models/appetency/appetency_svm_jdion.RData")