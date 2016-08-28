# Getting and Cleaning Data - Course Project

##Codebook
This document describes the processing steps followed in the script ``run_analysis.R`` to 
transform the raw data into the final output found in *summary_data.txt*.

The raw data is read from the folder *UCI HAR Dataset* in the R working directory. If this folder is not found, 
the zip file containing the raw data is downloaded and unzipped into a new folder of this name. The raw data used for the present 
version of the output was download on 28th Aug 2016, 06:51 BST.

Below files are used to construct the final dataset

File Path | rows | columns|
 ------------ | :-----------: | -----------: |
UCI HAR Dataset/activity_labels.txt |distinct activities - 6|1
UCI HAR Dataset/features.txt |features vector - 561|1
UCI HAR Dataset/test/subject_test.txt|subject of each test record - 2947|1
UCI HAR Dataset/test/X_test.txt |test records - 2947|features vector - 561
UCI HAR Dataset/test/y_test.txt |activity for each test record - 2947|1
UCI HAR Dataset/train/subject_train.txt |subject of each training record - 7352|1
UCI HAR Dataset/train/X_train.txt |training records - 7352|features vector - 561
UCI HAR Dataset/train/y_train.txt |activity for each training record - 7352|1

###Main steps of the data tidying process
1. The features vector is filtered based on the presence of the strings mean() or std() in its names, since we are not interested in any other feature.
2. The features vector names are transformed so that the ``mean()`` and ``std()`` strings appear at the end rather than in the middle of the name. This is to ease application of the separate() function.
3. For each of the **test** and **train** sets
  1. The data in the file X_{set}.txt, i.e. the features data for each record, is read into a DataFrame
  2. The columns not corresponding to mean() or std() features are dropped
  3. The columns are named using the modified feature names (created in step 2 above)
  4. The activity name and subject id for each record is added to the above dataframe
  5. Two columns, one indicating the set(test/training) and another indicating the specific record number within the set are added to the dataframe
4. The test and training records are concatenated 
5. The data is split into two dataframes, one containing all the ``mean()`` columns along with the non-numeric id columns. 
6. We apply gather() to this dataframes to change the ``mean()`` feature columns into a single variable column, 
     with one 'mean' column containing the values
7. Similarly, we construct another dataframes to hold all the ``std()`` values
8. These two dataframes are then joined by matching all the id columns (i.e. columns other than mean and std) to create a full data set containing both mean and std values for each set/subject/activity/feature combination in each row
9. This dataframe is then grouped by subject, activity and feature and the mean and std values are averaged for each group to produce the summary_data.txt output

###Description of the data in **summary_data.txt**
1. subject - numbers 1 to 30 - Subject id to identify participants
2. activity - varchar() - One of 6 possible activity labels
3. feature - varchar() - One of 33 possible features
4. avg_mean - double - Average of feature value means across all measurements 
5. 4. avg_mean - double - Average of feature value standard deviations across all measurements 
