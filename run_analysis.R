#install.packages("data.table")
#install.packages("reshape2")
#install.packages("dplyr")
library(data.table)
library(reshape2)
library(dplyr)

fileSource <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip";
downloadedFile <- "data.zip";

if (!file.exists(downloadedFile)) {
  download.file(fileSource, file.path(downloadedFile));
}

dataDir <- "UCI HAR Dataset";
datasets <- file.path("UCI HAR Dataset");

if (!file.exists(datasets)) {
  unzip(dataDir) 
} else {
  #read in all the data files
  
  #subject data files
  if (!exists("testDataTable")) {
    ## read in training and test data
    
    #read subject data files
    trainSub <- data.table(read.table(file.path(dataDir, "train", "subject_train.txt"), header = FALSE))
    testSub <- data.table(read.table(file.path(dataDir, "test", "subject_test.txt"), header = FALSE))
    #activity Y data files
    trainAct <- data.table(read.table(file.path(dataDir, "train", "Y_train.txt"), header = FALSE))
    testAct <- data.table(read.table(file.path(dataDir, "test", "Y_test.txt"), header = FALSE))
    #read X data files
    trainData <- data.table(read.table(file.path(dataDir, "train", "X_train.txt"), header = FALSE))
    testData <- data.table(read.table(file.path(dataDir, "test", "X_test.txt"), header = FALSE))
  
    #make a data table out of the data
    trainDataTable <- data.table(trainData)
    testDataTable <- data.table(testData)
    
    ## PROJECT REQUIREMENT
    ## 1. Merges the training and the test sets to create one data set.

    #use row bind to merge the data sets
    allSubjects <- rbind(trainSub, testSub)
    allActivities <- rbind(trainAct, testAct)
    #use setnames to rename our subject and activity columns with more descriptive names
    setnames(allSubjects, "V1", "subject")
    setnames(allActivities, "V1", "activityid")
    
    allData <- rbind(trainDataTable, testDataTable)
  }

  ## PROJECT REQUIREMENT
  ## 3. Uses descriptive activity names to name the activities in the data set

  #merge our columns for more readable activity names
  subjAct <- cbind(allSubjects, allActivities)
  data <- cbind(subjAct, allData)
  setkey(data, subject, activityid)
  #load the feature name from features.txt and rename
  features <- data.table(read.table(file.path(dataDir, "features.txt")))
  setnames(features, names(features), c("fNum", "fName"))
  
  ## PROJECT REQUIREMENT
  ## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
  
  #keep only the avg and std features
  features <- features[grepl("mean\\(\\)|std\\(\\)", fName)]
  #translate fNum to vector naming "V<num>"
  features$fVector <- features[, paste0("V", fNum)]
  #create our subselect vector
  featureColumns <- c(key(data), features$fVector)
  #only keep the data we care about in curatedData
  curatedData <- data[, featureColumns, with=FALSE]

  ## PROJECT REQUIREMENT
  ## 4. Appropriately labels the data set with descriptive variable names.
  #load activity names from activity_labels.txt and rename
  activities <- data.table(read.table(file.path(dataDir, "activity_labels.txt")))
  setnames(activities, names(activities), c("activityid", "aName"))
  curatedData <- merge(curatedData, activities, by="activityid", all.x=TRUE)
  #update key with activity name "aname"
  setkey(curatedData, subject, activityid, aName)
  
  #melt on feature data type
  meltedData <- data.table(melt(curatedData, key(curatedData), variable.name="fVector"))
  meltedData <- merge(meltedData, features[, list(fNum, fVector, fName)], by="fVector", all.x=TRUE)
  #create factor and activity vector
  meltedData$activityFactor <- factor(meltedData$aName)
  meltedData$featureFactor <- factor(meltedData$fName)
  meltedData$subject <- as.factor(meltedData$subject)
  
  ## PROJECT REQUIREMENT
  ## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
  ## we'll use dplyr for this last step

    tidydf <- tbl_df(meltedData)
    tidy <- select(tidydf, subject, activityFactor, featureFactor, value)
    write.table(tidy, "tidy.txt", row.names = FALSE, quote = FALSE)
  }


