# French multiple negation production prosody experiment
# Import and preprocessing
# (C) Jeremy D Yeaton
# January 2019

library(tidyverse)

## READ IN DATA ####
f0_over_time <- read_csv('data/master.csv',col_types = cols())

line_max_min <- read_csv('data/max_min_syll.csv',col_types = cols())

behavior_raw <- read.table('data/behavior.csv', sep = '\t', header = TRUE)

## Pitch data ####
f0.df <- f0_over_time %>%
  merge(line_max_min, all.x = TRUE) %>%
  group_by(subj) %>%
  # Get mean and SD by subject
  summarize(meanf0_sub = mean(raw_f0),
            sdf0_sub = sd(raw_f0)) %>%
  merge(f0_over_time, all = TRUE) %>%
  merge(line_max_min, all = TRUE) %>%
  merge(read_csv('data/serAll.csv',col_types = cols()),col_types = cols()) %>%
  # Take z-scores of F0
  mutate(f0_Z = (raw_f0-meanf0_sub)/sdf0_sub,
         normTime = as.numeric(series)) %>%
  # Filter outliers more than 3 SD away from mean
  filter(abs(f0_Z) < 3) %>%
  mutate(condition = factor(condition,levels = c('nc','dn','negsub','negob')),
         subj = as.factor(subj),
         trial = as.factor(trial)) %>%
  select(-c(max_f0,min_f0,duration,series,meanf0_sub,sdf0_sub))

## Duration & max/min data ####

syll_vals.df <- f0.df %>%
  group_by(subj,syll_num) %>%
  # Get mean and SD by subject AND syllable
  summarize(syll_f0 = mean(raw_f0),
            syll_sd = sd(raw_f0)) %>%
  merge(line_max_min %>%
          group_by(subj) %>%
          mutate(meanDur_sub = mean(duration, na.rm = TRUE),
                 sdDur_sub = sd(duration, na.rm = TRUE)) %>%
          merge(line_max_min) %>%
          merge(read_csv('data/serAll.csv',col_types = cols())) %>%
          # Z-score duration values
          mutate(dur_z = (duration-meanDur_sub)/sdDur_sub)) %>%
  # Take z-scores
  mutate(maxf0_z = (max_f0-syll_f0)/syll_sd,
         minf0_z = (min_f0-syll_f0)/syll_sd) %>%
  select(-c(series,syll_f0,syll_sd,meanDur_sub,sdDur_sub))


## Behavioral data ####
behavior.df <- behavior_raw %>%
  mutate(cond_old = condition,
         condition = case_when(cond_old == 'dn' ~ 'DN',
                               cond_old == 'nc' ~ 'NC',
                               TRUE ~ 'Control')) %>%
  # Reorder factors for nicer plotting
  mutate(condition = factor(condition,levels=c('DN','NC','Control')),
         check_mm = factor(check_mm,levels = c('nc_mm','dn_mm','dn','nc','0')))

## Remove unnecessary variables ####
rm(f0_over_time,line_max_min,behavior_raw)
