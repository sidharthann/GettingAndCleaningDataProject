library(readr)
library(dplyr)
library(tidyr)

linkdata <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
dirname <- 'UCI HAR Dataset' 

#Download and unzip the dataset to the current working directory
#if it doesnt already exist
if (!dir.exists(dirname)) {
    download.file(linkdata, 'Dataset.zip')
    unzip('Dataset.zip', exdir = getwd())
    unlink('Dataset.zip')
}


#Read the list of activities and features
createlevels <- function(filename) {
    data <- read_delim(file.path(dirname, filename),
                       ' ', col_names = c('id', 'label'),
                       col_types = c('nc')) %>% 
            arrange(id)
    data$label
}

actnames <- createlevels('activity_labels.txt')
allfeats <- createlevels('features.txt')

#Define filters to extract only mean() and std() measurements for each feature
featfilter = grep('mean\\(\\)|std\\(\\)', allfeats)
#This will be used as column names for the filtered set of features
featnames = grep('mean\\(\\)|std\\(\\)', allfeats, value = T)

#Modify the feature names by, for e.g.fBodyAcc()-mean()-Y to fBodyAcc()-Y+mean()
#This will allow easy application of seperate() later
fixfeatname <- function(featname) {
    if (grepl('-mean()', featname)) {
        return(paste0(sub('-mean()', '', featname), '+mean()'))
    }else if (grepl('-std()', featname)) {
        return(paste0(sub('-std()', '', featname), '+std()'))
    }
    featname
}
featnames <- sapply(featnames, fixfeatname)

#Read the test and training data sets
getdataset <- function(set) {
    #List of subjects
    subjects <- read_delim(file.path(dirname, set, paste0('subject_', set, '.txt')),
                           delim = ' ', col_names = c('subject'), col_types = c('c'))
    
    #List of activities, these are converted to string descriptions using the actnames dataframe generated earlier
    activities <- read_delim(file.path(dirname, set, paste0('y_', set, '.txt')), 
                             ' ', col_names = c('activity'), col_types = c('n')) %>%
                  mutate(activity = actnames[activity])    
    
    #Reads all the features measurements. Filters for mean() and std() are applied, and column names are applied 
    feats <- tbl_df(read.table(file.path(dirname, set, paste0('X_', set, '.txt')), stringsAsFactors = F)) %>%
                select(featfilter)
    names(feats) <- featnames
    
    #All the data is aggrgated ino a single dataframe
    #We add columns to indicate whether it is a test or training observation, and also the position within the 
    #  set of observations of that set
    cbind(set = rep(set, length(subjects)), obsnum = seq_len(nrow(subjects)), subjects, activities, feats)
}

#Aggregating test and traing data
alldata <- bind_rows(getdataset('test'), getdataset('train'))

#Extract all the 'mean()' columns and convert into a tidy df
means <- alldata %>% 
            select(-(contains('+std()'))) %>% 
            gather(feature, mean, contains('+mean()')) %>%
            mutate(feature = sub('\\+mean\\(\\)', '', feature))

#Similarly tidyize the std() columns
stds <- alldata %>% 
    select(-(contains('+mean()'))) %>% 
    gather(feature, std, contains('+std()')) %>%
    mutate(feature = sub('\\+std\\(\\)', '', feature))

#std() and mean() dataframes are joined using all the non-numerical variables to give the final tidy dtaset
tidydata <- merge(means, stds, all = TRUE)

#Calculate and write the final summary
avg_tidydata <- tidydata %>% group_by(subject, activity, feature) %>% 
                             summarise(avg_mean = mean(mean), avg_std = mean(std)) %>%
                             arrange(subject, activity, feature)

write.table(avg_tidydata, 'summary_data.txt', row.names = F)

