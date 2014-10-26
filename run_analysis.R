## require the reshape2 package

require(reshape2)

## read in the activity labels
## activity_labels contains the activity IDs and activity descriptive labels

activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt",quote="\"")
## relabel the activity columns with something more descriptive
colnames(activity_labels) <- c("activityID","activityName")

## read in the feature labels
## features contains the column number to measurement descriptive label information

features <- read.table("./UCI HAR Dataset/features.txt",quote="\"")

## relabel the features columns with something more descriptive
colnames(features) <- c("featureID","featureName")

#######
## read in the test data
#######

## subject_test contains the subject test data
subject_test  <- read.table("./UCI HAR Dataset/test/subject_test.txt",quote="\"")
## relabel the subject_test columns with something more descriptive
colnames(subject_test) <- "subjectID"

## y_test contains the activity test data
Y_test <- read.table("./UCI HAR Dataset/test/Y_test.txt",quote="\"")
## relabel the Y_test columns with something more descriptive
colnames(Y_test) <- "activityID"

## x_test contains the acceleration test data
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt",quote="\"")
## relabel the columns in testData using the column names from features
for (i in 1:ncol(X_test)){
  colnames(X_test)[i] <- as.character(features$featureName[i])
}

## bind subject, activity, and measurment data together
testData <- cbind("subjectID"=subject_test$subjectID, "activityID"=Y_test$activityID, X_test[])

## add a rowID column (for reordering as needed later)

##testData <- cbind("rowID" = 1:nrow(testData),testData[])

## add the activityName from the activity_labels table as column 3
testData <- cbind(testData[,1:2],"activityName"=as.character(activity_labels$activityName[testData[,2]]),testData[,3:ncol(testData)])

## subset only columns containing "mean" or "std" as part of the measurement name
testData <- cbind(testData[,1:3],testData[, grepl("mean|std", names(testData))])

#######
## read in the train data
#######

## subject_train contains the subject training data
subject_train  <- read.table("./UCI HAR Dataset/train/subject_train.txt",quote="\"")
## relabel the subject_train columns with something more descriptive
colnames(subject_train) <- "subjectID"

## y_train contains the activity training data
Y_train <- read.table("./UCI HAR Dataset/train/Y_train.txt",quote="\"")
## relabel the Y_test columns with something more descriptive
colnames(Y_train) <- "activityID"

## x_train contains the acceleration training data
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt",quote="\"")
## relabel the columns in testData using the column names from features
for (i in 1:ncol(X_train)){
  colnames(X_train)[i] <- as.character(features$featureName[i])
}

## bind subject, activity, and measurment data together
trainData <- cbind("subjectID"=subject_train$subjectID, "activityID"=Y_train$activityID, X_train[])

## add a rowID column (for reordering as needed later)

##trainData <- cbind("rowID" = 1:nrow(trainData),trainData[])

## add the activityName from the activity_labels table as column 3
trainData <- cbind(trainData[,1:2],"activityName"=as.character(activity_labels$activityName[trainData[,2]]),trainData[,3:ncol(trainData)])

## subset only columns containing "mean" or "std" as part of the measurement name
trainData <- cbind(trainData[,1:3], trainData[, grepl("mean|std", names(trainData))])

#######
## combine the test and training datasets
#######

allData <- rbind(testData,trainData)

#######
## from this data create a second, independent tidy data set with the average of each variable for each activity and each subject
#######

## melt the data using the first 3 columns (subjectID, activityID, activityName) as IDs
## and the rest of the columns as measure variables

meltData <- melt(allData,id=1:3,measure.vars=4:ncol(allData))

## use dcast to get the mean for each variable in the melted data frame by subjectID + activityID + activityName

meanData <- dcast(meltData,subjectID + activityID + activityName ~ variable, mean)

######
## write out our tidy datasets
######

if(!file.exists("./AccelerationData")){dir.create("./AccelerationData")}

saveRDS(allData,"./data/TidyDataSet1.rds")
saveRDS(meanData,"./data/TidyDataSet2.rds")
