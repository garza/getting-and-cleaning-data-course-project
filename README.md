# Getting and Cleaning Data - Course Project

This is the course project for the Getting and Cleaning Data Coursera course.
The R script, `run_analysis.R`, does the following:

- Downloads the dataset if it doesn't exist, unzips
- Loads the activity and feature text files
- Loads training and test datasets, merges them
- Extracts only the measurements on mean and standard deviation.
- Applies descriptive activity and features names from the files loaded in the first load step above.
- Appropriately labels the dataset with descriptive names
- Saves the resultant data set to a file named`tidy.txt`


The R script requires the following packages to be installed:

- library(data.table): for easy data table reading
- library(reshape2): for melting the data
- library(dplyr): for creating a tidy data set