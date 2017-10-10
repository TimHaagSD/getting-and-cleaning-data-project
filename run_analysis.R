library('dplyr')
library('reshape2')
#This script will not work with plyr loaded.  Use the following line to detach if attached.
#detach('package:plyr')

#set working directory
setwd('C:/R/4_peer')
#Save URL
fileurl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
#Download file
zipfile <- download.file(fileurl,'Dataset')

#List files in the zip archive.
unzip('Dataset', list = TRUE)
#Extract files from or list a zip archive.
unzip('Dataset')

#More specific working directory
setwd('C:/R/4_peer/UCI HAR Dataset')

#Import necessary data
X_train <- read.table('train/X_train.txt')
y_train <- read.table('train/y_train.txt')
X_test <- read.table('test/X_test.txt')
y_test <- read.table('test/y_test.txt')
activity_labels <- read.table('activity_labels.txt')
features <- read.table('features.txt')
subject_test <- read.table('test/subject_test.txt')
subject_train <- read.table('train/subject_train.txt')

#Format column for join
features$V1 <- paste('V',features$V1, sep = '')
#Rename column
names(features)[2] <- 'feature'
#Rename column
names(subject_test)[1] <- 'subject'
names(subject_train)[1] <- 'subject'

#combine training data
train_all = cbind(y_train, X_train, subject_train)
#combine testing data
test_all = cbind(y_test, X_test, subject_test)
#combine all training and testing
all_data = rbind(train_all, test_all)

#Prepare data to join features
#Rename columns for joins and clarity
names(all_data)[1] <- 'join'
names(all_data)[2] <- 'V1'
names(activity_labels)[2] <- "act"

#Combine all data
all_data_labeled = merge(x = all_data, y = activity_labels,  by.x = "join", by.y = "V1")
#Remove join column
all_data_labeled$join <- NULL
#Pivot dataset
set_1 <- melt(all_data_labeled, id.vars = c("act", "subject"),
              variable.name = "feature_join",
              value.name = "measure")

#Join feature labels to the data
all_data_w_features = merge(x = set_1, y = features, by.x = "feature_join", by.y = "V1")
#Remove join column
all_data_w_features$feature_join <- NULL

#Create data set with features containing 'mean(' or 'std(' 
deliverable_1 <- subset(all_data_w_features, grepl('.*(mean|std)\\(.*', all_data_w_features$feature))
#Tell R to group by the act and subject columns
deliverable_1_gb <- group_by(deliverable_1, act, subject, feature)
#Summarize by appropriate columns and return mean and standard deviation
deliverable_2 <- summarise(deliverable_1_gb, mean = mean(measure), standdev = sd(measure))
#verify result
write.csv(deliverable_2, 'tidy.csv')



