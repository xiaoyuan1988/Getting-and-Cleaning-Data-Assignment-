#import libraries
library(plyr)
library(data.table)
library(dplyr)
#data processing and download
if(!getwd()=="./newplace"){
  dir.create("./newplace")
}
#download project files
download.file(url="http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile="./assignment")
unzip("./assignment",list=TRUE)
test_x<-read.table(unzip("./assignment","UCI HAR Dataset/test/X_test.txt"))
test_y<-read.table(unzip("./assignment","UCI HAR Dataset/test/y_test.txt"))
test_subject<-read.table(unzip("./assignment","UCI HAR Dataset/test/subject_test.txt"))
train_x<-read.table(unzip("./assignment","UCI HAR Dataset/train/X_train.txt"))
train_y<-read.table(unzip("./assignment","UCI HAR Dataset/train/y_train.txt"))
train_subject<-read.table(unzip("./assignment","UCI HAR Dataset/train/subject_train.txt"))
features<-read.table(unzip("./assignment","UCI HAR Dataset/features.txt"))
unlink("./assignment")

#take a loot at the data
names(test_x)
head(test_y)
head(features)

#data cleaning
colnames(test_x)<-t(features[2])
colnames(train_x)<-t(features[2])

names(test_x)
#add a few more columns
test_x$activities<-test_y[,1]
test_x$participants<-test_subject[,1]
train_x$activities<-train_y[,1]
train_x$participants<-train_subject[,1]
#merge the test and train table
newtable<-rbind(test_x,train_x)
names(newtable)
duplicate<-duplicated(colnames(newtable))
newtable<-newtable[,!duplicate]

#find the mean and st
mean<-grep("mean()",names(newtable),value=FALSE,fixed=TRUE)
updatedmean<-append(mean,471:477)
Mean<-newtable[updatedmean]
std<-grep("std()",names(newtable),value=FALSE)
STD<-newtable[std]
#to name the descriptive activities
newtable$activities<-as.character(newtable$activities)
newtable$activities[newtable$activities==1]<-"Walking"
newtable$activities[newtable$activities==2]<-"Walking upstairs"
newtable$activities[newtable$activities==3]<-"Walking downstairs"
newtable$activities[newtable$activities==4]<-"Sitting"
newtable$activities[newtable$activities==5]<-"Standing"
newtable$activities[newtable$activities==6]<-"Laying"
newtable$activities<-as.factor(newtable$activities)
#lable the data
names(newtable)<-gsub("ACC","Accelerator",names(newtable))
names(newtable)<-gsub("Mag","Magnitude",names(newtable))
names(newtable)<-gsub("Gyro","Gyroscope",names(newtable))
names(newtable)<-gsub("^t","time",names(newtable))
names(newtable)<-gsub("^f","frequency",names(newtable))

final<-data.table(newtable)
newtable$participants<-as.factor(newtable$participants)
tidy<-final[,lapply(.SD,mean),by='participants,activities']
write.table(tidy,file="tidy.txt",row.names=FALSE)
getwd()
