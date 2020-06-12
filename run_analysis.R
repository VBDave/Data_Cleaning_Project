library(reshape2)
Filename <- "getdata_dataset.zip"
## Download and unzip the data:
if (!file.exists(Filename)){
  FileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(FileURL, Filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(Filename) 
}

## Load Activity Labels and Features data from the respective files:
ActivityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
ActivityLabels[,2] <- as.character(ActivityLabels[,2])
Features <- read.table("UCI HAR Dataset/features.txt")
Features[,2] <- as.character(Features[,2])	

## Extract the mean and standard deviation
MeanAndSTDev <- grep(".*mean.*|.*std.*", Features[,2])
MeanAndSTDev.names <- Features[MeanAndSTDev,2]
MeanAndSTDev.names = gsub('-mean', 'Mean', MeanAndSTDev.names)
MeanAndSTDev.names = gsub('-std', 'Std', MeanAndSTDev.names)
MeanAndSTDev.names <- gsub('[-()]', '', MeanAndSTDev.names)

## Load and bind the data for Train and Test
Train <- read.table("UCI HAR Dataset/train/X_train.txt")[MeanAndSTDev]
TrainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
TrainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
Train <- cbind(TrainSubjects, TrainActivities, Train)
Test <- read.table("UCI HAR Dataset/test/X_test.txt")[MeanAndSTDev]
TestActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
TestSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
Test <- cbind(TestSubjects, TestActivities, Test)

## Merge the data and add labels
AllData <- rbind(Train, Test)
colnames(AllData) <- c("Subject", "Activity", MeanAndSTDev.names)

## Define factors
AllData$Activity <- factor(AllData$Activity, levels = ActivityLabels[,1], labels = ActivityLabels[,2])
AllData$Subject <- as.factor(AllData$Subject)
AllData.melted <- melt(AllData, id = c("Subject", "Activity"))
AllData.mean <- dcast(AllData.melted, Subject + Activity ~ variable, mean)
write.table(AllData.mean, "TidyAccelerometerData.txt", row.names = FALSE, quote = FALSE)

