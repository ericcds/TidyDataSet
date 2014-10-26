---
title: "CodeBook"
author: "Eric C"
date: "October 26, 2014"
output: html_document
---

Original data from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip is contained in this repo under directory UCI HAR Dataset.

UCI HAR Dataset
  activity_labels.txt contains activity IDs and activity Names
  features.txt contains feature IDs and feature Names corresponding to the columns measured in X_test.txt and X_train.txt.
  /test/subject_test.txt contains the subject IDs for test measurements.
  /test/X_test.txt contains the accelerometer readings for test subjects.
  /test/Y_test.txt contains the activity IDs for test measurements.
  /train/subject_train.txt contains the subject IDs for training measurements.
  /train/X_train.txt contains the accelerometer readings for training subjects.
  /train/Y_train.txt contains the activity IDs for training measurements.
  
The script first reads in the common label files activity_labels.txt and features.txt and applies descriptive column names.

``` {r}
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
```


The script then reads in the test data files subject_test.txt, and Y_test.txt and applies descriptive column names.
Since these are single variable data frames with V1 being the subjectID and activityID respectively, a simple colnames function is used.

``` {r}
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
```

The script reads in the X_test measurements, and iterates through the column numbers to match up with the descriptive measurement/activity names in the activity_labels data frame.
(Rubric #4 - appropriately labels the data set with descriptive variable names)

``` {r}
## x_test contains the acceleration test data
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt",quote="\"")
## relabel the columns in testData using the column names from features
for (i in 1:ncol(X_test)){
  colnames(X_test)[i] <- as.character(features$featureName[i])
}
```

Now we combine the columns from subject_test and Y_test by column binding them to the front of X_test measurements.
Since we haven't done anything to reorder these measurements, we don't have to worry about creating a separate rowID sequence or ordering the data frames.

``` {r}
## bind subject, activity, and measurment data together
testData <- cbind("subjectID"=subject_test$subjectID, "activityID"=Y_test$activityID, X_test[])
```

Use the activityID in column 2 to lookup the activityName in activity_labels and add that in as column 3 of our data frame.
(Rubric # 3 - uses descriptive activity names to name the activities in the data set)

``` {r}
## add the activityName from the activity_labels table as column 3
testData <- cbind(testData[,1:2],"activityName"=as.character(activity_labels$activityName[testData[,2]]),testData[,3:ncol(testData)])
```

Use the grepl function to subset out those columns with "mean" or "std" in the column name
(Rubric #2 - extracts only the measurements on the mean and standard deviation for each measurment)

``` {r}
## subset only columns containing "mean" or "std" as part of the measurement name
testData <- cbind(testData[,1:3],testData[, grepl("mean|std", names(testData))])
```

Do the same thing for all the training data.

``` {r}
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

## add the activityName from the activity_labels table as column 3
trainData <- cbind(trainData[,1:2],"activityName"=as.character(activity_labels$activityName[trainData[,2]]),trainData[,3:ncol(trainData)])

## subset only columns containing "mean" or "std" as part of the measurement name
trainData <- cbind(trainData[,1:3], trainData[, grepl("mean|std", names(trainData))])
```

Now merge the datasets together (fulfills Rubric # 1: Merges the training and the test sets to create one data set)

``` {r}
#######
## combine the test and training datasets
#######

allData <- rbind(testData,trainData)

```

The script then creates a second, independent, tidy data set using melt and dcast to get the average for each measurement by activity by subject
(fulfills Rubric # 5)

``` {r}
#######
## from this data create a second, independent tidy data set with the average of each variable for each activity and each subject
#######

## melt the data using the first 3 columns (subjectID, activityID, activityName) as IDs
## and the rest of the columns as measure variables

meltData <- melt(allData,id=1:3,measure.vars=4:ncol(allData))

## use dcast to get the mean for each variable in the melted data frame by subjectID + activityID + activityName

meanData <- dcast(meltData,subjectID + activityID + activityName ~ variable, mean)
```

And finally write out the tidy datasets.

``` {r}
######
## write out our tidy datasets
######

if(!file.exists("./AccelerationData")){dir.create("./AccelerationData")}

saveRDS(allData,"./data/TidyDataSet1.rds")
saveRDS(meanData,"./data/TidyDataSet2.rds")
```