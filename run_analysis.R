install.packages("data.table")
install.packages("dplyr")
library(data.table)
library(dplyr)

#Loading data from the URL

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = paste0(getwd(), '/finalproject.zip'))
unzip(zipfile = "finalproject.zip")


#Loading feature and activity names

activityLabels <- read.table(paste0(getwd(), "/UCI HAR Dataset/activity_labels.txt"), col.names = c("classLabels", "activityName"))
features <- read.table(paste0(getwd(), "/UCI HAR Dataset/features.txt"), col.names = c("index", "featureNames"))


#Exercise 2: Extract only the measurements on the mean and standard deviation for each measurement. 
#These indices have the required mean and std measurements only

ff_mean <- grep("mean\\(\\)", features[,"featureNames"])
ff_std <- grep("std\\(\\)", features[,"featureNames"])
ff <- sort(c(ff_mean, ff_std))

req_data <- features[ff, "featureNames"]
req_data <- gsub("[()]", "", req_data)


#Exercise 4: Appropriately label the data set with descriptive variable names. 
#TRAINING SET

train <- read.table(paste0(getwd(),"/UCI HAR Dataset/train/X_train.txt"))
train <- train[,ff]
setnames(train, colnames(train), req_data)
train_y <- read.table(paste0(getwd(), "/UCI HAR Dataset/train/y_train.txt"), col.names = c("Activity"))
train_ppl <- read.table(paste0(getwd(), "/UCI HAR Dataset/train/subject_train.txt"), col.names = c("Subject"))

train <- cbind(train, train_ppl, train_y)


#TESTING SET
test <- read.table(paste0(getwd(), "/UCI HAR Dataset/test/X_test.txt"))
test <- test[,ff]
setnames(test, colnames(test), req_data)
test_y <- read.table(paste0(getwd(), "/UCI HAR Dataset/test/y_test.txt"), col.names = c("Activity"))
test_ppl <- read.table(paste0(getwd(), "/UCI HAR Dataset/test/subject_test.txt"), col.names = c("Subject"))

test <- cbind(test, test_ppl, test_y)


#Exercise 1: Merge the training and the test sets to create one data set.

data <- rbind(train, test)


#Exercise 3: Use descriptive activity names to name the activities in the data set.

data$Activity <- factor(data[,"Activity"], levels = activityLabels$classLabels, labels= activityLabels$activityName)


#Exercise 5: Create a second, independent tidy data set with the average of each variable for each activity and each subject.

avg <- data %>% group_by(Subject, Activity) %>% summarise(across(everything(), mean), .groups = "drop")
write.table(avg, file="TidyData.txt")
