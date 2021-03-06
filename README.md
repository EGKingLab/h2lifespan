---
title: "h2 Lifespan Project Record & Notes"
author: "Enoch Ng'oma (EN), Kevin Middleton (KM), and Elizabeth King (EK)"
date: "6/8/2018"
---

## Project Record

The following steps should be followed to reproduce the analysis.

### Estimation of egg counts

See fecundity estimation repository for detailed instructions for the estimation of fecundity from image data: https://github.com/EGKingLab/fecundity_estimation
   
### Main Data Analysis

General Functions
    - `Code/heritability/color_map.R`: sets theme for plot color
    - `Code/heritability/ggplot_theme.R`: sets theme for plotting
    - `Figures/Figure_Constructor.R`: put figures in panels for publication

1. Prepare lifespan data: `Code/heritability/01_InitialProcess.R`
    - Performs general quality checks and performs initial processing 
    - Reads: `Data/Processed/Data/Processed/lifespan_only.txt`
    - Sources: `Code/heritability/PreProcess_lifespan_functions.R` 
    - Writes:
        - `Data/Processed/lifespan_correctedData.txt` (both sexes)
        - `Data/Processed/Female_events_lifespan.txt` (females only)
        - `Data/Processed/Male_events_lifespan.txt` (males only)

2. Estimate and visualize survival: `Code/heritability/02_h2surv_models_visualization.Rmd`
    - Produces a Kaplan-Meier plot of survival (Figure fixme) and performs survival model fitting and comparisons. Also produces sire by diet plot (Figure fixme)
    - Reads: `Data/Processed/Female_events_lifespan.txt`

3. Merge predicted counts, hand counts and lifespan data: `Code/heritability/03_h2fecund.Rmd`
    - Reads: 
        - `Data/Processed/predicted_egg_counts.rda`
        - `Data/Processed/lifespan_correctedData.txt`
    - Writes:
        - `Data/Processed/eggs_per_female.csv`: Egg count in each vial/number of females
        - `Data/Processed/eggs_per_vial.txt`: Total eggs in each vial

4. Visualize fecundity data and perform model comparison: `Code/heritability/04_h2fec_visualization.Rmd`
    - Produces figures (fixme) and performs Bayesian model comparison of fecundity data
    - Reads:
        - `Data/Processed/eggs_per_female.csv`
        - `Data/Processed/eggs_per_vial.txt`

5. Estimate heritability in each diet for lifespan (animal model in MCMCglmm): `Code/heritability/05_h2surv_analysis.Rmd`
    - Reads: `Data/Processed/Female_events_lifespan.txt`
    - Writes: 
        - `Data/Processed/HS_lifespan.Rda`, `DR_lifespan.Rda`, `STD_lifespan.Rda`
        - `Data/Processed/herit_lifespan.Rda` (combines all 3 analyses)

6. Estimate heritability for early and total fecundity in each vial (animal model in MCMCglmm)
`Code/heritability/06_h2fec_heritability.Rmd`
    - Reads: 
        - `Data/Processed/eggs_per_female.txt`
        - `Data/Processed/eggs_per_vial.txt`
    - Writes
        - Output: `HS_early_fec.Rda`, `DR_early_fec.Rda`, `STD_early_fec.Rda` (C), `HS_total_fec.Rda`, `DR_total_fec.Rda`, `STD_total_fec.Rda` (C)
        - `Data/Processed/herit_early.Rda`: Combines HS, DR, and C
        - `Data/Processed/herit_total.Rda`: Combines HS, DR, and C

7. Estimate cross-diet genetic correlations: `Code/heritability/07_h2surv_multivariate.R`
    - Sources: `Code/heritability/h2life_load_data.R` to set up pedigree
    - Reads: `Data/Processed/Female_events_lifespan.txt`
    - Writes: `Data/Processed/surv_multivariate_model_prior1.Rda`, `surv_multivariate_model_prior2.Rda`, `surv_multivariate_model_prior3.Rda`

8. Estimate genetic cross-diet correlations for early and total fecundity (animal model in MCMCglmm)
`Code/heritability/08_fec_multivariate.Rmd`
    - Reads: 
        - `Data/Processed/eggs_per_female.txt`
        - `Data/Processed/eggs_per_vial.txt`
    - Writes
        - `Data/Processed/fec_total_multivariate_model_prior1.Rda`
        - `Genetic_Correlations_Fecundity.csv`
        - `Data/Processed/fec_total_multivariate_model_output.Rda`: pairwise diet comparisons

9. Visualize fecundity and lifespan relationship: `Code/heritability/09_Two_trait.Rmd`
    - Creates figure (fixme #) and supplementary table (fixme)
    - Reads: 
        - `Data/Processed/Female_events_lifespan.txt`
        - `Data/Processed/eggs_per_female.txt`
        - `Data/Processed/eggs_per_vial.txt`
    - Writes:
        - `Data/Processed/Sample_counts.txt`

