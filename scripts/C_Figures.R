# French multiple negation production prosody experiment
# Figures
# (C) Jeremy D Yeaton
# January 2019

## Load packages ####
library(tidyverse)
library(ggpubr)

## Read in data ####
source('scripts/A_Preprocessing.R')

## Define plot size ####
plot.w <- 18
plot.h <- 10

## Define colors ####
dn_color <- '#1c79b6'
nc_color <- '#fe7e0f'
negOb_color <- '#e477c1'
negSub_color <- '#2ba02d'
dn_mm_color <- '#ffbb78'
nc_mm_color <- '#aec6e8'
control_color <- '#7f7f7f'


## Behavioral results ####

# Figure 3: Behavior by condition
behCond.plot <- behavior.df %>%
  group_by(condition) %>%
  summarize(correct = sum(Check == TRUE)/n(),
            se = sd(Check)/(n()^.5)) %>%
  ggplot(aes(x=condition,y=correct,fill=condition)) +
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar(aes(ymin=correct-se, ymax=correct+se), width=.2,
                position=position_dodge(.9)) +
  theme(legend.position = 'none') +
  labs(x = 'Condition', y = 'Proportion correct') +
  coord_cartesian(y = c(0,1)) +
  scale_fill_manual(values=c(dn_color,nc_color,control_color)) +
  scale_x_discrete(labels = c('DN','NC','Control'))
behCond.plot
behCond.plot %>%
  ggsave(plot=.,"figures/Figure_3.jpeg",width=plot.w/2,height=plot.h,units="cm")

# Figure S1: Behavior by interpretation
behInterp.tbl <- behavior.df %>%
  filter(check_mm != 0) %>%
  group_by(subject,check_mm) %>%
  summarize(interpretation = n()) %>%
  mutate(cond2 = ifelse(check_mm %in% c('dn','nc_mm'),'dn','nc'))

interp.se <- behInterp.tbl %>%
  group_by(subject,cond2) %>%
  summarize(condInterp = sum(interpretation)/16) %>%
  group_by(cond2) %>%
  summarize(se = sd(condInterp)/(28^.5),
            condInterp = mean(condInterp))
  
behInterp.plot <- behInterp.tbl %>%
  group_by(check_mm,cond2) %>%
  summarize(interp = sum(interpretation)/448) %>%
  ggplot(aes(x=cond2,y = interp,fill = check_mm)) +
  geom_bar(stat = 'identity') +
  geom_errorbar(inherit.aes = FALSE,data = interp.se, 
                aes(x= cond2,
                    ymin=condInterp-se, 
                    ymax=condInterp+se), width=.2) +
  labs(x = 'Interpretation',y = 'Proportion of responses',fill='Response type') +
  coord_cartesian(y = c(0,1)) +
  scale_fill_manual(values=c(nc_mm_color,dn_mm_color,dn_color,nc_color),
                    labels = c('NC incongruent','DN incongruent','DN congruent','NC congruent')) +
  scale_x_discrete(labels = c('DN','NC'))
behInterp.plot

behPlots <- ggarrange(behCond.plot,behInterp.plot,
                      labels = c("A", "B"),
                      ncol = 2, nrow = 1)
behPlots
behPlots %>%
  ggsave(plot=.,"figures/Figure_S1.jpeg",width=plot.w,height=plot.h,units="cm")


## Figure 5: Prosodic contours in critical conditions ####

# Y-value for annotations
annY = 165

# Filter data
critContours.df <- f0.df %>%
  filter(condition %in% c('nc','dn'),normTime < 60) %>%
  mutate(condition = factor(condition, levels = c('dn','nc')))

critContours.plot <- ggplot() + 
  geom_smooth(data = critContours.df, aes(x = normTime, y = raw_f0, color = condition),size = 1.5) +
  scale_color_manual(values = c(dn_color,nc_color),
                     labels = c('DN','NC')) +
  labs(x="Time",y="F0 (Hz)",color='Condition') +
  theme(legend.position = "top") +
  annotate(geom="text", x=10, y=annY, label="subject",color="black") +
  annotate(geom="text", x=25, y=annY, label="ne",color="black") +
  annotate(geom="text", x=35, y=annY, label="verb",color="black") +
  annotate(geom="text", x=45, y=annY, label="object",color="black") +
  annotate(geom="text", x=55, y=annY, label="PP1",color="black")
critContours.plot
critContours.plot %>%
  ggsave(plot=.,"figures/Figure_5.jpeg",width=plot.w,height=plot.h,units="cm")

## Figure 7: Prosodic contour for last 2 syllables ####

## Supplemental figure XX: Contour of last 2 syllables ####
last2.df <- f0.df %>%
  merge(f0.df %>%
          group_by(trial) %>%
          summarize(maxTime = max(normTime))) %>%
  mutate(time_reverse = normTime - maxTime) %>%
  filter(time_reverse > -20, condition %in% c('dn','nc'))

last2.plot <- last2.df %>%
  ggplot(.,aes(x = time_reverse, y = raw_f0, color = condition)) +
  geom_smooth(size = 1.5) +
  scale_color_manual(values = c(dn_color,nc_color),
                     labels = c('DN','NC')) +
  labs(x="Time", y="F0 (Hz)",color='Condition') + 
  theme(legend.position = "top") +
  annotate(geom="text", x=-15, y=150, label="penultimate",color="black") +
  annotate(geom="text", x=-5, y=150, label="ultimate",color="black")
last2.plot
last2.plot %>%
  ggsave(plot=.,'figures/Figure_7.jpeg',width=.5*plot.w,height=plot.h,units="cm")

## Figure 8: Duration boxplot ####
durNCI.plot <- syll_vals.df %>%
  filter(syll_num %in% c(5,6)) %>%
  filter(condition == 'dn' | condition == 'nc') %>%
  mutate(syll_name = case_when(syll_num == 5 ~ 'Object NCI',
                               syll_num == 6 ~ 'First syllable of PP')) %>%
  mutate(syll_name = factor(syll_name, levels = c('Object NCI','First syllable of PP'))) %>%
  group_by(subj,condition,syll_name) %>%
  summarize(dur_z = mean(dur_z)) %>%
  ggplot(aes(x= syll_name,y = dur_z, fill = condition)) +
  geom_boxplot() +
  scale_fill_manual(values = c(dn_color,nc_color),
                    labels = c('DN','NC')) +
  labs(x='Syllable',y="Z-scored duration",fill='Condition') +
  theme(legend.position = "top")
durNCI.plot
durNCI.plot %>%
  ggsave(plot=.,'figures/Figure_8.jpeg',width=plot.w/2,height=plot.h,units="cm")

## Figure 9: Contours by condition on NCIs ####

f0.df <- f0.df %>%
  mutate(condition = factor(condition, levels = c('dn','nc','negob','negsub')))

# A: Subject zoom: NegSub condition
subNS.plot <- f0.df %>%
  filter(condition != 'negob') %>%
  filter(normTime < 30) %>%
  ggplot(.,aes(x = normTime, y = raw_f0, color = condition)) +
  geom_smooth(size = 1.5) +
  scale_color_manual(values = c(dn_color,nc_color,negSub_color),
                     labels = c('DN','NC','NegSub')) +
  labs(x=element_blank(), y=element_blank(),color='Condition') + 
  coord_cartesian(y = c(160,245)) +
  theme(legend.position = "top") +
  annotate(geom="text", x=10, y=annY, label="subject",color="black") +
  annotate(geom="text", x=25, y=annY, label="ne",color="black")
subNS.plot

# B: Subject zoom: NegOb condition
subNO.plot <- f0.df %>%
  filter(condition != 'negsub') %>%
  filter(normTime < 30) %>%
  ggplot(.,aes(x = normTime, y = raw_f0, color = condition)) +
  geom_smooth(size = 1.5) +
  scale_color_manual(values = c(dn_color,nc_color,negOb_color),
                     labels = c('DN','NC','NegOb')) +
  labs(x=element_blank(),y="F0 (Hz)",color='Condition') + 
  coord_cartesian(y = c(160,245)) +
  theme(legend.position = "top") +
  annotate(geom="text", x=10, y=annY, label="subject",color="black") +
  annotate(geom="text", x=25, y=annY, label="ne",color="black")
subNO.plot

# C: Object zoom: NegSub condition
objNS.plot <- f0.df %>%
  filter(condition != 'negob') %>%
  filter(normTime > 29 & normTime < 60) %>%
  ggplot(.,aes(x = normTime, y = raw_f0, color = condition)) +
  geom_smooth(size = 1.5) +
  scale_color_manual(values = c(dn_color,nc_color,negSub_color),
                     labels = c('DN','NC','NegSub')) +
  labs(x="Time", y=element_blank(),color='Condition') + 
  coord_cartesian(y = c(160,245)) +
  theme(legend.position = "none") +
  annotate(geom="text", x=35, y=annY, label="verb",color="black") +
  annotate(geom="text", x=45, y=annY, label="object",color="black") +
  annotate(geom="text", x=55, y=annY, label="PP1",color="black")
objNS.plot  

# D: Object zoom: NegOb condition
objNO.plot <- f0.df %>%
  filter(condition != 'negsub') %>%
  filter(normTime > 29 & normTime < 60) %>%
  ggplot(.,aes(x = normTime, y = raw_f0, color = condition)) +
  geom_smooth(size = 1.5) +
  scale_color_manual(values = c(dn_color,nc_color,negOb_color),
                     labels = c('DN','NC','NegOb')) +
  labs(x="Time", y="F0 (Hz)",color='Condition') + 
  coord_cartesian(y = c(160,245)) +
  theme(legend.position = "none") +
  annotate(geom="text", x=35, y=annY, label="verb",color="black") +
  annotate(geom="text", x=45, y=annY, label="object",color="black") +
  annotate(geom="text", x=55, y=annY, label="PP1",color="black")
objNO.plot

# Merge to combined plot
compContours <- ggarrange(subNO.plot,subNS.plot,objNO.plot,objNS.plot,
          labels = c('A','B','C','D'),
          ncol = 2, nrow = 2)
compContours
compContours %>%
  ggsave(plot=.,'figures/Figure_9.jpeg',width=1.5*plot.w,height=1.5*plot.h,units="cm")
