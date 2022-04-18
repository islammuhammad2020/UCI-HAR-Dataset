library(tidyverse)

files_unzippered <- unzip("UCI_Dataset.zip")

#after unzipping the combined file, character vector of the path to the 28 text files has been generated
#all the test data and traing data are included in the following files:
# [15] "./UCI HAR Dataset/test/X_test.txt", [27] "./UCI HAR Dataset/train/X_train.txt"
#the two files have been combined in new tibble called "all_data"


test_data <- read_table(files_unzippered[15],col_names = FALSE)
training_data <- read_table(files_unzippered[27],col_names = FALSE)
all_data <- bind_rows(test_data,training_data)

# the discriptive names of variables in the new tibble are contained in the file :
# [2] "./UCI HAR Dataset/features.txt",
# these names have been assigned as new column names for the tibble

all_features <- read_table(files_unzippered[2],col_names = "feature")
colnames(all_data) <- all_features$feature

# the measurments with mean  and standard  values have been selected

combined_data <- all_data %>%
    select( contains(c("mean","std"),ignore.case = FALSE) )


# the activity index for both the test and training data are included in the followin files:
# [16] "./UCI HAR Dataset/test/y_test.txt", [28] "./UCI HAR Dataset/train/y_train.txt"
# both data have been combined in new tibble

test_activity_index <- read_table(files_unzippered[16],col_names = "activity")
training_activity_index <- read_table(files_unzippered[28],col_names = "activity")
activity_index <- bind_rows(test_activity_index,training_activity_index)

# all the data have combined with activity and the activity has been labelled like these:
# `1` = "WALKING",`2` = "WALKING_UPSTAIRS",`3` = "WALKING_DOWNSTAIRS",`4` = "SITTING",`5` = "STANDING",`6` = "LAYING")
# also, the subjects of these experiment has combined to the data


combined_activity_data <- bind_cols(combined_data,activity_index)
new_data <- combined_activity_data %>%
    mutate(activity = recode(activity, `1` = "WALKING",
           `2` = "WALKING_UPSTAIRS",
           `3` = "WALKING_DOWNSTAIRS",
           `4` = "SITTING",
           `5` = "STANDING",
           `6` = "LAYING"), .keep = "unused")


test_subject <- read_table(files_unzippered[14],col_names = "subject")
training_subject <- read_table(files_unzippered[26],col_names = "subject")
all_subject <- bind_rows(test_subject,training_subject)

final_data <- bind_cols(new_data,all_subject)

# the final data has been groupped by subject and activity and summarised to the value of mean of measurments

final_data %>%
    group_by(subject, activity) %>%
    summarise(across(everything(),mean)) %>%
    write.table(file = "week4.txt",row.names = FALSE)


