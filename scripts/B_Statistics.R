# French multiple negation production prosody experiment
# Statistics
# (C) Jeremy D Yeaton
# January 2019; updated August 2021

## Load packages ####
library(tidyverse)
library(mgcv)
library(lme4)
library(lmerTest)

## Read in data ####
source('scripts/A_Preprocessing.R')


# GAMMs -------------------------------------------------------------------

## GAMM: Window 1 (first 6 syllables) ####
window1.gam <- f0.df %>%
  # Select first 6 syllables
  filter(normTime < 60) %>%
  # Select critical conditions
  filter(condition %in% c('nc','dn')) %>%
  mutate(syll_num = as.factor(syll_num),
         condition = factor(condition, levels = c('nc','dn'))) %>%
  gamm(raw_f0 ~ s(normTime) + 
         condition * syll_num +
         s(subj,bs='re') + s(trial,bs='re'),data=.,method = 'REML')
summary(window1.gam$gam)

# Reshape to list and adjust p-values
as.list(p.adjust(summary(window1.gam$gam)$p.pv,method='BY'))

## GAMM: Window 2 (last 2 syllables) ####
wind2.df <- f0.df %>%
  group_by(trial) %>%
  summarize(max_syll = max(syll_num)) %>%
  merge(f0.df) %>%
  mutate(time_from_end = -10*max_syll + normTime + 1,
         syll_num2 = as.character(syll_num - max_syll)) %>%
  filter(time_from_end > -20)

window2.gam <- wind2.df %>%
  filter(condition %in% c('nc','dn')) %>%
  mutate(syll_num = as.factor(syll_num),
         condition = factor(condition, levels = c('nc','dn','negsub','negob'))) %>%
  gamm(demeaned_f0 ~ s(time_from_end) +
         condition * syll_num2 + 
         s(subj,bs='re') + s(trial,bs='re'),
       data=.,method = 'REML')
summary(window2.gam$gam)

# LMERs -------------------------------------------------------------------

## LMER: Duration ####
duration.lmer <- syll_vals.df %>%
  filter(syll_num < 7) %>%
  filter(abs(dur_z) < 3) %>%
  # Change order of levels to run test with different baseline conditions
  mutate(condition = factor(condition, levels = c('nc','dn','negsub','negob')),
  # mutate(condition = factor(condition, levels = c('dn','nc','negsub','negob')),
  # mutate(condition = factor(condition, levels = c('negsub','nc','dn','negob')),
  # mutate(condition = factor(condition, levels = c('negob','nc','dn','negsub')),
         syll_num = as.character(syll_num)) %>%
  lmer(dur_z ~ syll_num + condition : syll_num + 
         (1|subj) * (1|trial),
       data=.,control = lmerControl(optimizer = 'bobyqa',optCtrl = list(maxfun = 10000)))
summary(duration.lmer)

# Reshape to dataframe and adjust p-values
dur.lmer.coef <- as.data.frame(summary(duration.lmer)$coefficients) %>%
  mutate(p_adj = p.adjust(.$`Pr(>|t|)`,method='BY'))

## LMER: Max F0 ####
maxz.lmer <- syll_vals.df %>%
  filter(syll_num < 7, abs(maxf0_z) < 3) %>%
  # Change order of levels to run test with different baseline conditions
  mutate(condition = factor(condition, levels = c('nc','dn','negsub','negob')),
  # mutate(condition = factor(condition, levels = c('dn','nc','negsub','negob')),
  # mutate(condition = factor(condition, levels = c('negsub','nc','dn','negob')),
  # mutate(condition = factor(condition, levels = c('negob','nc','dn','negsub')),
         syll_num = as.character(syll_num)) %>%
  lmer(maxf0_z ~ syll_num + condition : syll_num + (1|subj) * (1|trial),data=.,REML=TRUE)
summary(maxz.lmer)

# Reshape to dataframe and adjust p-values
maxz.lmer.coef <- as.data.frame(summary(maxz.lmer)$coefficients) %>%
  mutate(p_adj = p.adjust(.$`Pr(>|t|)`,method='BY'))

## LMER: Min F0 ####
minz.lmer <- syll_vals.df %>%
  filter(syll_num < 7,abs(minf0_z) < 3) %>%
  mutate(condition = factor(condition, levels = c('nc','dn','negob','negsub')),
         syll_num = as.character(syll_num)) %>%
  lmer(minf0_z ~ syll_num + condition : syll_num + (1|subj) * (1|trial),data=.,REML=TRUE)
summary(minz.lmer)

