library(readr)
library(ggplot2)
library(raincloudplots)
library(ggrain)
library(tableone)
library(janitor)
library(tidyverse)
library(expss)
library(psych)
library(patchwork)
library(ggpubr)

allData <- read_csv("data/Qualtrics_CPT_RealEye.csv")

allData  <- clean_names(allData ) # use janitor to clean column names

val_lab(allData$gender) = num_lab("
             1 Male
             2 Female
             3 Other    ")  # Add value labels

val_lab(allData$adhd_yn) = num_lab("
             0 No
             1 Yes ")  # Add value labels


allData <- allData %>%
  mutate(adhd_diagnosed = case_when(
    adhd_yn ==  0 ~ "No",
    adhd_yn ==  1 ~ "Yes",
    TRUE ~ NA  # Keep other values unchanged
  ))

myVars <- c("age","gender")
catVars <- c("gender")

allData$log_scanpath_length <- log10(allData$scanpath_length)


tab1 <- print(CreateTableOne(vars = myVars, strata = "adhd_yn", data = allData, factorVars = catVars))

## ASRS scoring and screening

ASRS <- select(allData, starts_with("q23"))

ASRS_hyperactive <- select(ASRS, contains("hyper_impulsivity"))
ASRS_inattentive <- select(ASRS, contains("inattentiveness"))

ASRS_screener <- select(ASRS, 1:6)
keys_ASRS <-  rep(1, 18)
keys_ASRS_screener <- rep(1,6)
keys_ASRS_subscales <- rep(1,9)

ASRS_screen_scores <- scoreItems(keys_ASRS_screener, ASRS_screener, totals = TRUE)
allData$asrs_part_a<-ASRS_screen_scores$scores[,1]

ASRS_total <- scoreItems(keys_ASRS, ASRS, totals = TRUE)
allData$asrs_total <- ASRS_total$scores[,1]

ASRS_inattentiveness_scores <- scoreItems(keys_ASRS_subscales, ASRS_inattentive, totals = TRUE)
allData$asrs_inattentiveness <- ASRS_inattentiveness_scores$scores[,1]

ASRS_hyperactivity_scores <- scoreItems(keys_ASRS_subscales, ASRS_hyperactive, totals = TRUE)
allData$asrs_hyperactivity_impulsivity <- ASRS_inattentiveness_scores$scores[,1]


# Make a new variable with probable OR diagnosed ADHD
allData <- allData %>%
  mutate(adhd_probable = case_when(
    adhd_diagnosed == 'Yes' ~ "Yes",
    asrs_part_a <  14 ~ "No",
    asrs_part_a >=  14 ~ "Yes",
    TRUE ~ NA  # Keep other values unchanged
  ))


## ASRS plots from survey part

asrs_screen_plot <- ggplot(data=subset(allData, !is.na(adhd_diagnosed)), aes(x = adhd_diagnosed, y = asrs_part_a, fill = adhd_diagnosed)) +
  geom_rain(rain.side = 'l', alpha = .7) + scale_fill_brewer(palette = 'Set1', guide = 'none')+ylab('ASRS part A (screener)') + xlab('ADHD diagnosis') + theme_classic()

asrs_inattentiveness_plot <- ggplot(data=subset(allData, !is.na(adhd_diagnosed)), aes(x = adhd_diagnosed, y = asrs_inattentiveness, fill = adhd_diagnosed)) +
  geom_rain(rain.side = 'l', alpha = .7) + scale_fill_brewer(palette = 'Set1', guide = 'none')+ylab('ASRS inattentiveness') + xlab('ADHD diagnosis') + theme_classic()

asrs_hyperactivity_plot <- ggplot(data=subset(allData, !is.na(adhd_diagnosed)), aes(x = adhd_diagnosed, y = asrs_hyperactivity_impulsivity, fill = adhd_diagnosed)) +
  geom_rain(rain.side = 'l', alpha = .7) + scale_fill_brewer(palette = 'Set1', guide = 'none')+ylab('ASRS hyperactivity and impulsivity') + xlab('ADHD diagnosis') + theme_classic()

asrs_screen_plot + asrs_inattentiveness_plot + asrs_hyperactivity_plot

## CPT-noX plots

dPrime_plot <- ggplot(data=subset(allData, !is.na(adhd_diagnosed)), aes(x = adhd_diagnosed, y = d_prime, fill = 	adhd_diagnosed)) +
  geom_rain(rain.side = 'l', alpha = .7) + scale_fill_brewer(palette = 'Set1', guide = 'none')+ylab('CPT No-X d Prime') + xlab('ADHD diagnosis') + theme_classic()

rt_plot <- ggplot(data=subset(allData, !is.na(adhd_diagnosed)), aes(x = adhd_diagnosed, y = r_ts, fill = 	adhd_diagnosed)) +
  geom_rain(rain.side = 'l', alpha = .7) + scale_fill_brewer(palette = 'Set1', guide = 'none')+ylab('CPT No-X mean RT') + xlab('ADHD diagnosis') + theme_classic()

comissions_plot <- ggplot(data=subset(allData, !is.na(adhd_diagnosed)), aes(x = adhd_diagnosed, y = errors_commission, fill = 	adhd_diagnosed)) +
  geom_rain(rain.side = 'l', alpha = .7) + scale_fill_brewer(palette = 'Set1', guide = 'none')+ylab('CPT No-X errors of commission') + xlab('ADHD diagnosis') + theme_classic()

dPrime_plot + rt_plot + comissions_plot


## Scatter plots

errors_commission_scatter <- ggscatter(allData, x = 'asrs_hyperactivity_impulsivity', y = 'errors_commission',
                               color = 'darkred', shape = 21, size = 1,
                               add = 'reg.line', conf.int = TRUE, cor.coef = TRUE,
                               cor.coeff.args = list(method = "spearman", label.x = 3.5, label.sep = "\n")) + xlab ('ASRS hyperactivity/impulsivity score') + ylab('CPT-X errors of commission')

inattentiveness_scatter <- ggscatter(allData, x = 'asrs_inattentiveness', y = 'errors_commission',
                                       color = "#008080", shape = 21, size = 1,
                                       add = 'reg.line', conf.int = TRUE, cor.coef = TRUE,
                                       cor.coeff.args = list(method = "spearman", label.x = 3.5, label.sep = "\n")) + xlab ('ASRS inattentivness score') + ylab('CPT-X errors of commission')

dPrime_scatter <- ggscatter(allData, x = 'asrs_hyperactivity_impulsivity', y = 'd_prime',
                                       color = '#0b4545', shape = 21, size = 1,
                                       add = 'reg.line', conf.int = TRUE, cor.coef = TRUE,
                                       cor.coeff.args = list(method = "spearman", label.x = 3.5, label.sep = "\n")) + xlab ('ASRS hyperactivity/impulsivity score') + ylab('CPT-X d Prime score')

scanpath_scatter <- ggscatter(allData, x = 'asrs_total', y = 'log_scanpath_length',
                              color = 'darkred', shape = 21, size = 1,
                              add = 'reg.line', conf.int = TRUE, cor.coef = TRUE,
                              cor.coeff.args = list(method = "spearman", label.x = 3.5, label.sep = "\n")) + xlab ('ASRS total score') + ylab('Log scanpath length')

fixation_count_scatter <- ggscatter(allData, x = 'asrs_total', y = 'fixation_count',
                            color = '#008080', shape = 21, size = 1,
                            add = 'reg.line', conf.int = TRUE, cor.coef = TRUE,
                            cor.coeff.args = list(method = "spearman", label.x = 3.5, label.sep = "\n")) + xlab ('ASRS total score') + ylab('Fixation count')

fixation_duration_scatter <- ggscatter(allData, x = 'asrs_total', y = 'fixation_duration_ms',
                               color = '#0b4545', shape = 21, size = 1,
                               add = 'reg.line', conf.int = TRUE, cor.coef = TRUE,
                               cor.coeff.args = list(method = "spearman", label.x = 3.5, label.sep = "\n")) + xlab ('ASRS total score') + ylab('Fixation duration (ms)')
