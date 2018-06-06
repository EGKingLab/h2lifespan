---
title: "h2 Lifespan Project Record & Notes"
author: "Enoch Ng'oma (EN), Kevin Middleton (KM), and Elizabeth King (EK)"
date: "6/5/2018"
---


## Project Record
The following steps should be followed to reproduce the analysis.

### Estimation of egg counts

1. Extract image dimensions:
`Code/egg_counter/01_get_image_dimensions.R`

    - Loads each image file and outputs the maximum dimension. Each image is (roughly) square, so the maximum dimension is a good estimate.
    - Reads: Image files from `Data/Processed/h2_fec_images` See (fixme) for image files. 
    - Writes: `Data/Processed/image_dimensions.csv`

2. Get white area for each image at range of thresholds:
`Code/egg_counter/02_area_summation.py`

    - Processes the full set of images, calculating area for thresholds between 30 and 150).
    - Reads:
        - Images in `Data/Processed/h2_fec_images`. See (fixme) for image files.
        - `Data/Processed/feclife_with-image-ids.xlsx`: Excel file with information on image names and those that were manually handcounted.
    - Writes:
        - `Data/Processed/area_summation.Rda`

3. Optimize threshold: `Code/egg_counter/03_threshold_optimization_linear.R`

    - Performs either coarse or fine (`coarse` flag) optimization on training images to find the threshold value that minimizes MSE between prediction and handcount using a linear model with square root of 'egg' area: `handcount ~ I(area^0.5) + img_size - 1`. Uses a variable percentage of the data (for rarefaction) and a variable train/test split. Analysis of the resulting coarse optimization are used to guide the fine optimization. Results of the fine optimization are used to determine the optimal threshold value to use for the full image set.

    - Reads:
        - `Data/Processed/area_summation.csv`: Areas calculated for all thresholds from 30 to 150
        - `Data/Processed/feclife_with-image-ids.xlsx`: Excel file with information on image names and those that were manually handcounted.
    - Writes:
        - `Data/Processed/threshold_optimization_linear_coarse.csv`
        - `Data/Processed/threshold_optimization_linear_fine.csv`

4. Predict egg counts from images: `Code/egg_counter/04_h2_fec_prediction.Rmd`

    - Predicts egg counts from image areas for the full set using the threshold value (`linear_threshold <- 53`) determined above. Training image data are loaded and used to create a linear model for predicting egg counts for the full set.
    - Reads:
        - `Data/Processed/feclife_with-image-ids.xlsx`: Excel file with information for all images
        - `Data/Processed/area_summation.Rda`: Areas for the training set
        - `Data/Processed/image_dimensions.csv`: Maximum image dimensions for the training set
    - Writes: 
        - `Data/Processed/predicted_egg_counts.rda`
    
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
    - Produces a Kaplan-Meier plot of survival (Figure fixme) and performs survival model comparisons. Also produces sire by diet plot (Figure fixme)
    - Reads: `Data/Processed/Female_events_lifespan.txt`

3. Merge predicted counts, hand counts and lifespan data: `Code/heritability/03_h2fecund.Rmd`
    - Reads: 
        - `Data/Processed/predicted_egg_counts.rda`
        - `Data/Processed/lifespan_correctedData.txt`
    - Writes:
        - `Data/Processed/eggs_per_female.csv`: Egg count in each vial/number of females
        - `Data/Processed/eggs_per_vial.txt`: Total eggs in each vial

4. Visualize fecundity data and perform model comparison: `Code/heritability/h2fec_visualization.Rmd`
    - Produces figures (fixme) and performs Bayesian model comparison of fecundity data
    - Reads:
        - `Data/Processed/eggs_per_female.csv`
        - `Data/Processed/eggs_per_vial.txt`

5. Estimate heritability in each diet for lifespan (animal model in MCMCglmm): `Code/heritability/05_h2surv_analysis.R`
    - Reads: `Data/Processed/Female_events_lifespan.txt`
    - Writes: 
        - `Data/Processed/HS.Rda`, `LY.Rda`, `STD.Rda` fixme filenames
        - `Data/Processed/herit.Rda` (combines all 3) fixme filenames

6. Estimate heritability for early and total fecundity in each vial (animal model in MCMCglmm)
`Code/heritability/06_h2fec_lifetime_heritability.Rmd`
    - Reads: 
        - `Data/Processed/eggs_per_female.txt`
        - `Data/Processed/eggs_per_vial.txt`
    - Writes fixme files below
        - Output: `HS.Rda`, `LY.Rda`, `STD.Rda` (LY and STD later named DR and C, respectively)
        - `Data/Processed/herit.Rda`: Combines HS, DR, and C

7. Estimate cross-diet genetic correlations: `Code/heritability/07_h2surv_MANOVA.R`
    - Sources: `Code/heritability/h2life_load_data.R` to set up pedigree
    - Reads: `Data/Processed/Female_events_lifespan.txt`
    - Writes: `Data/Processed/tri_model_prior1.Rda`, `tri_model_prior2.Rda`, `tri_model_prior3.Rda`

8. Estimate genetic cross-diet correlations for early and total fecundity (animal model in MCMCglmm)
`Code/heritability/08_h2fec_lifetime_MANOVA.Rmd`
    - Reads: 
        - `Data/Processed/eggs_per_female.txt`
        - `Data/Processed/eggs_per_vial.txt`
    - Writes  fixme files below
        - `Data/Processed/FEC_lifetime_model_prior1.Rda`
        - `Genetic_Correlations_Fecundity.csv`
        - `Data/Processed/re.Rda`: pairwise diet comparisons

9. Visualize fecundity and lifespan relationship: `Code/heritability/09_Two_trait.Rmd`
    - Creates figure (fixme #) and supplementary table (fixme)
    - Reads: 
        - `Data/Processed/Female_events_lifespan.txt`
        - `Data/Processed/eggs_per_female.txt`
        - `Data/Processed/eggs_per_vial.txt`
    - Writes:
        - `Data/Processed/Sample_counts.txt`

