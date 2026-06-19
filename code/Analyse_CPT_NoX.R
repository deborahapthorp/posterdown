library(readr)
library(dplyr)
library(psycho)

# Function to extract summary data from a file 
analyseNoXData <- function(filepath){
  session <- read_csv(filepath)
  sessionFilt <- filter(session, !is.na(response.corr)) # Filter out NA values 
  
  prop_correct <- sum(sessionFilt$response.corr)/length(sessionFilt$response.corr) # proportion correct overall
  
  noXtrials <- filter(sessionFilt, corrAns=='space') # Filter out only the no X trials
  prop_errors_omission <- 1-sum(noXtrials$response.corr/length(noXtrials$response.corr)) # proportion of misses
  
  Xtrials <- filter(sessionFilt, letter =='X')
  prop_errors_commission <- 1-sum(Xtrials$response.corr/length(Xtrials$response.corr)) # proportion of false alarms 
  
  correctTrials <- filter(noXtrials, response.corr==1)
  correctRTs_mean <- mean(correctTrials$response.rt) # reaction times from correct trials only in noX data (since pressing a button in an X trial would be an error)
  
  # calculate d prime
  indices <- dprime((1-prop_errors_omission), prop_errors_commission,
                    prop_errors_omission, (1-prop_errors_commission))
  
  dPrime <- indices$dprime
  participant <- sessionFilt$participant[1] # This is better than using the file name as sometimes participant code isn't saved there
  
  return(list(participant = participant, correct = prop_correct, 
              errors_omission=prop_errors_omission, 
              errors_commission =prop_errors_commission, 
              RTs = correctRTs_mean,
              dPrime = dPrime ))}

##  Here is the code to do the analysis for all the files 
folder <- "data/CPT/"

list = list.files(path = folder ,full.names=TRUE,recursive=TRUE) # list all files in the folder
all_names = basename(list) # Get names of all files from their corresponding paths

df <- data.frame(matrix(ncol = 6, nrow = 0)) # Make empty data frame

# Loop to go through all participants and append to data frame 

nSubs <- length(all_names)
for (i in 1:nSubs){
  
filepath <- paste0(folder, all_names[i])
subData <- analyseNoXData(filepath)
subData <- data.frame(t(sapply(subData,c))) # turn it into a data frame 
df <- rbind(df, subData) # Append it to the existing data frame

}

write.csv(df, "CPT_NoX_results.csv")