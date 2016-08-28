# Getting and Cleaning Data - Course Project

##Instructions for running the code
Required packages
* R version 3.3.1
* readr - 1.0.0
* dplyr - 0.5.0
* tidyr - 0.6.0

Save the file `run_analysis.R` to the R working dirctory and run `source('run_analysis.R')` in the R terminal.
The script will look for the folder *UCI HAR Dataset* in the working directory. If it is not found, the original zip file will be downloaded from [https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip), and unzipped into a new folder named as above.

Data from the files within this folder is read and processed to produce the output file *summary_data.txt* within the working directory. Further details of whow the data is processed and a description of the data contained in the output file can be found in **CodeBook.md**
