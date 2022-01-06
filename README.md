# README
This repository contains the data processing and analysis scripts for:
Déprez, V. & Yeaton, J.D. (2022). _On the prosody of French ambiguous multiple negative sentences._ [[manuscript]](https://jeremyyeaton.github.io/papers/Deprez_Yeaton-2021-manuscript-ProsodyNegation_revised.pdf)

Any questions regarding the data or analysis can be directed to: jyeaton@uci.edu

## Data
To comply with GDPR, the raw data are hosted on OSF: https://osf.io/u35mq/

All "raw" (i.e.: not z-transformed) F0 values are in Hz.
This OSF repository also stores a R environment file which contains all of the models and figures.

## Analysis setup
The analysis pipeline presented in the paper relies on the following R packages (available from CRAN):
- tidyverse
- mgcv
- lme4
- lmerTest
- ggpubr

It expects the scripts to be in a "scripts" directory, as well as data in a "data" directory. The figures script will expect a "figures" directory to save them in.

## Scripts
This repository contains 3 R scripts in the "scripts" directory:
- **A_Preprocessing.R** Imports the data files, tidies them up, and returns three dataframes: _behavior.df_, _f0.df_, and _syll_vals.df_ for which the columns are laid ou in the **Codebook** section below.
- **B_Statistics.R** Contains code to calculate the GAMMs as well as the LMERs presented in the paper
- **C_Figures.R** Code to produce results figures in the paper

## Codebook
### Columns -- _behavior.df_ dataframe
- subject: participant identifier
- item: stimulus item
- response: participant response to T/F verification statement (V for true, F for false)
- rt: response time (sentences had different lengths so this isn't especially meaningful)
- category: experimental condition
- condition: DN, NC, or Control for single negative controls & fillers 
- truthVal: correct answer to verification statement
- check: does response match truthVal? TRUE for correct answer, FALSE for incorrect
- prsntOrd: order in which the item was presented in the experiment to that participant
- check_mm: only for DN and NC conditions. If "check" is TRUE, then check_mm is the same as condition. If "check" is FALSE, then it is a condition mismatch, and ultimately the opposite interpretation.
- cond_old: short version of category

### Columns -- _f0.df_ dataframe
- subj: participant identifier (same as "subject" above)
- obj_id: concatenation of participant number and item number
- trial: item number (same as "item" above)
- syll: text corresponding to that syllable in Praat phonetic format
- condition: DN, NC, NegOb, or NegSub
- unique: concatenation of obj_id and normTime
- raw_f0: F0 value output by ProsodyPro for that sample
- demeaned_f0: raw F0 minus the mean F0 for that participant in all syllables in the same position
- syll_num: syllable number in the utterance
- f0_Z: demeaned_f0 divided by the standard deviation for that participant within the same syllable position across all utterances
- normTime: 10 time-normalized values per syllable using pythonic numbering (0-9 is the first syllable, 10-19 is the second, etc.)

### Columns -- _syll_vals.df_ dataframe
- subj: same as above
- syll_num: same as above
- unique: same as above
- obj_id: same as above
- trial: same as above
- syll: same as above
- max_f0: raw maximum F0 output by ProsodyPro for that syllable
- duration: syllable duration (in ms)
- condition: same as above
- dur_z: z-scored duration
- maxf0_z: z-scored max F0 using mean and SD from time-normalized data
- minf0_z: z-scored min F0 using mean and SD from time-normalized data
