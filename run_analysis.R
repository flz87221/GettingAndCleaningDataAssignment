library(dplyr)
setwd("C:/RProjects")

# download data zip file
if(!file.exists("./data")) { 
    dir.create("./data")
}

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipfilepath <- "./data/fuci_har_dataset.zip"
download.file(fileUrl, destfile = zipfilepath)

# extract zip file
listZip <- unzip(zipfilepath, exdir = "./data")

# load data from unziped files
train.x <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
train.y <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
train.subject <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

test.x <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
test.y <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
test.subject <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

# requirement 1. merges the training and the test sets to create one data set
trainData <- cbind(train.subject, train.y, train.x)
testData <- cbind(test.subject, test.y, test.x)
fullData <- rbind(trainData, testData)

# load feature name
featureName <- read.table("./data/UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)[,2]

# requirement 2. extracts only the measurements on the mean and standard deviation for each measurement
featureIndex <- grep(("mean\\(\\)|std\\(\\)"), featureName)
finalData <- fullData[, c(1, 2, featureIndex+2)]
colnames(finalData) <- c("subject", "activity", featureName[featureIndex])

# load activity data
activityName <- read.table("./data/UCI HAR Dataset/activity_labels.txt")

# requirement 3. uses descriptive activity names to name the activities in the data set
finalData$activity <- factor(finalData$activity, levels = activityName[,1], labels = activityName[,2])

# requirement 4. appropriately labels the data set with descriptive variable names
names(finalData) <- gsub("\\()", "", names(finalData))
names(finalData) <- gsub("^t", "Time", names(finalData))
names(finalData) <- gsub("^f", "Frequence", names(finalData))
names(finalData) <- gsub("-mean", "Mean", names(finalData))
names(finalData) <- gsub("-std", "Std", names(finalData))

# requirement 5. from the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
groupData <- finalData %>%
    group_by(subject, activity) %>%
    summarise_all(funs(mean))

write.table(groupData, "./uci_har_meandata.txt")