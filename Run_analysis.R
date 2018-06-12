# Load & Attaching packages 
#install.packages("data.table")
#install.packages("reshape2")
library(data.table)
library(reshape2)

# downloading to local directory & un zipping 
setwd("C:\\Users\\xxxxxxxx\\Desktop\\Coursera\\Data_Cleaning\\Week4")
path<-getwd()
if (!file.exists("data"))
{
    dir.create("data")
}
URL<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(URL,file.path(path,"datafiles.zip"))
unzip(zipfile = "datafiles.zip")


# Load activity labels + features

activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
#activityLabels
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])
#features

# Extract only the data on mean and standard deviation

featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
#featuresWanted
featuresWanted_names <- features[featuresWanted,2]
#featuresWanted_names
featuresWanted_names<-gsub('-mean','Mean',featuresWanted_names)
#featuresWanted_names
featuresWanted_names<-gsub('-std','Std',featuresWanted_names)
#featuresWanted_names
featuresWanted_names<-gsub('[-()]','',featuresWanted_names)

#loading training data

#featuresWanted_names
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
#train
train_Activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train_data <- cbind(trainSubjects, train_Activities, train)

#loading testing  data
test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
test_Activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test_data <- cbind(testSubjects, test_Activities, test)

#Merge
allData <- rbind(train_data, test_data)
#head(allData)
colnames(allData) <- c("subject", "activity", featuresWanted_names)
#unique(allData$subject)
#unique(allData$activity)

# turn activities & subjects into factors

allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

#Melting data to find mean by variable type 
allData.melted <- melt(allData, id = c("subject", "activity"))
#allData.melted
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

#Write data 
write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)


