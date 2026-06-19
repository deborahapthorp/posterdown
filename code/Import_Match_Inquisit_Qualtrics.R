# Note: You may have to install these packages if you don't have them.

library(readr) # for reading in csv files 
library(haven) # for SPSS data
library(dplyr) # for wrangling data
library(here)  # for simplifying file paths
library(tidyverse) # for making everything tidy

# read in data - replace with your folder and file names as needed, or just rename your files. 

Qualtrics_Data <- read_sav(here("data", "QualtricsData.sav")) # Read in Qualtrics saved as SPSS .sav file
CPT_Data <- read_csv(here("data","CPT_NoX_results.csv")) # Read in Inquisit file 

RealEye_Data <- read_csv(here("data","RealEye_results.csv"))


# Merge the data by participant IDs. 

Qualtrics_CPT <- merge(x = Qualtrics_Data, y = CPT_Data, 
                            by.x = "ResponseId", by.y = "participant", all.x = TRUE)

Qualtrics_CPT_RealEye <- merge(x = Qualtrics_CPT, y = RealEye_Data, 
                               by.x = "ResponseId", by.y = "participant", all.x = TRUE)

# Write main data to file (both .sav and .csv format)
write.csv(Qualtrics_CPT_RealEye, file = "Qualtrics_CPT_RealEye.csv") 
write_sav(Qualtrics_CPT_RealEye, "Qualtrics_CPT_RealEye.sav")

