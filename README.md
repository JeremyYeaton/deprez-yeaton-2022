# README
This repository contains the data processing and analysis scripts for:
Déprez, V. & Yeaton, J.D. (2021). _On the prosody of French ambiguous multiple negative sentences._ [[manuscript]](https://jeremyyeaton.github.io/papers/Deprez_Yeaton-2021-manuscript-ProsodyNegation_revised.pdf)

Any questions regarding the data or analysis can be directed to the second author at: jyeaton@uci.edu

## Data
To comply with GDPR, the raw data are hosted on OSF: https://osf.io/u35mq/

## Analysis setup
The analysis pipeline presented in the paper relies on the following R packages (available from CRAN):
- tidyverse
- mgcv
- lme4
- lmerTest
- modelr
- ggpubr

It expects the scripts to be in a "scripts" directory, as well as data in a "data" directory. The figures script will expect a "figures" directory to save them in.

## Scripts
This repository contains 3 R scripts in the "scripts" directory:
- **A_Preprocessing.R** Imports the data files, tidies them up, and returns three dataframes: _behavior.df_, _f0.df_, and _syll_vals.df_ for which the columns are laid ou in the **Codebook** section below.
- **B_Statistics.R**
- **C_Figures.R** 

## Codebook
### Columns -- _behavior.df_ dataframe

### Columns -- _f0.df_ dataframe

### Columns -- _syll_vals.df dataframe
