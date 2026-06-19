library(readr)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(gganimate)

# Mean fixation duration; fixation count; scan path (could get this from saccade length (px)?)

fixations <- read_csv("data/study-eye-tracking_study_adults_adhd-cc2d9c28-777f-44b0-9985-b587eaa1fdb1-fixations.csv")
# View(fixations)

fixation_duration <- aggregate(data=fixations, fixation_duration_ms ~ external_data_participant, FUN="mean") # Get mean fixation duration in ms

fixation_counts <- aggregate(data=fixations, fixation_duration_ms ~ external_data_participant, FUN="length") # Get fixation count 
fixation_counts <- fixation_counts %>% rename_at('fixation_duration_ms', ~'fixation_count') # rename variable to make more sense 

scanpath <- aggregate(data=fixations, saccade_length_px ~ external_data_participant, FUN="sum") # add up all saccade lengths to get total scan path length 
scanpath <- scanpath %>% rename_at('saccade_length_px', ~'scanpath_length') # rename variable to make more sense 

# put all data frames into list
df_list <- list(fixation_duration,fixation_counts, scanpath)

# merge all data frames in list using "reduce"
RealEyeData <- df_list %>% reduce(full_join, by='external_data_participant')

RealEyeData <- RealEyeData %>% rename_at('external_data_participant', ~'participant')

write.csv(RealEyeData, "RealEye_results.csv")

## Plot individual data as an animated GIF if desired 
names <- unique(fixations$external_data_participant)
Name1 <- names[14]
individual_data <- filter(fixations, fixations$external_data_participant==Name1)

p1 <- ggplot(individual_data, aes(x = fixation_point_x, y = fixation_point_y)) + 
  geom_point(colour = "blue", size = .5) + theme_classic()+
  transition_time(individual_data$fixation_starts_at_ms)+ 
  theme(text = element_text(size=13)) +
  shadow_mark(past = T, future=F, alpha=0.3)+
  coord_fixed(ratio = 1)+
  theme(plot.title = element_text(hjust = 0.5))+
  #xlim(0,100)+ ylim(20,120)+
  labs(title = paste("Eye movement animation", Name1, sep = " "), 
       x = "X position (pixels)", 
       y = "Y position (pixels)")
a_gif <- animate(p1, width = 350, height = 350, detail = 20, fps = 5)
a_gif

saveFname <- paste("EyeAnimation_", Name1, ".gif", sep = "")
anim_save(saveFname)



## Static plot 

p2 <- ggplot(individual_data, aes(x = fixation_point_x, y = fixation_point_y)) + 
  geom_point(colour = "blue", aes(size = fixation_duration_ms)) + theme_classic()+
  scale_size(range = c(0.2, 2))+
  geom_path(colour = "grey", alpha = 0.7)+
  theme(text = element_text(size=13)) +
  coord_fixed(ratio = 1)+
  theme(plot.title = element_text(hjust = 0.5))+
  xlim(0,100)+ ylim(5,105)+
  labs(title = paste("Fixation plot", Name1, sep = " "), 
       x = "X position (pixels)", 
       y = "Y position (pixels)")
p2