SCRIPTS, INPUT FILES AND OUTPUT FILES IN ORDER OF EXECUTION


A. ANALYSIS OF SURVIVAL

1) Prepare lifespan data
`Code/heritability/PreProcess_lifespan_functions.R`
A set of functions to converts death and censored events individual events

`Code/heritability/InitialProcess.R`
Runs `Code/heritability/PreProcess_lifespan_functions.R` on a raw lifespan data file
Input: `Data/Processed/Data/Processed/lifespan_only.txt` 
Performs general quality checks

Output: 
`Data/Processed/lifespan_correctedData.txt` (both sexes)
`Data/Processed/Female_events_lifespan.txt` (females only)
`Data/Processed/Male_events_lifespan.txt` (males only)


2) Estimate and visualize survival
`Code/heritability/h2surv_models_visualization.Rmd`
Input: `Data/Processed/Female_events_lifespan.txt`
Kaplan-Meier plot with survival, survminer and ggplot2, 
Test of difference, 

3) Analyze genotype x diet interactions for lifespan
`Code/heritability/h2surv_models_visualization.Rmd`
Input: `Data/Processed/Female_events_lifespan.txt`
Output: plot of reaction norms

4) Estimate heritability in each diet (animal model in MCMCglmm)
`Code/heritability/h2surv_analysis.R`
Input: `Data/Processed/Female_events_lifespan.txt`
output: 
`Data/Processed/HS.Rda`, `LY.Rda`, `STD.Rda`
`Data/Processed/heritab.Rda` (combines all 3)

5) Estimate cross-diet genetic correlations
`Code/heritability/h2surv_MANOVA.R`
Runs: `Code/heritability/h2life_load_data.R` to set up pedigree
Input: `Data/Processed/Female_events_lifespan.txt`
Output: `Data/Processed/tri_model_prior1.Rda`, `tri_model_prior2.Rda`, `tri_model_prior3.Rda`
Model `Data/Processed/tri_model_prior1.Rda` used for in report


B. ANALYSIS OF FECUNDITY

1) Extract image dimensions
`Code/egg_counter/get_image_dimensions.R`
Loads each image file and outputs the maximum dimension. Each image is (roughly) square, so the maximum dimension is a good estimate.
Input: Image files from `h2_fec_images`
Output: `Data/Processed/image_dimensions.csv`

2) Process the full set of images, calcaulting area for thresholds between 30 and 150).
`Code/egg_counter/area_summation.py`
Input:
Images in `Data/Processed/h2_fec_images`
Information in`Data/Processed/feclife_with-image-ids.xlsx`: Excel file with information on image names and those that were manually handcounted (but not part of the training set).
Output: `Data/Processed/area_summation.Rda`

3) Perform either coarse or fine (`coarse` flag) optimization on training images
`Code/egg_counter/threshold_optimization_linear.R`
Finds the threshold value that minimizes MSE between prediction and handcount using a linear model with square root of 'egg' area: `handcount ~ I(area^0.5) + img_size - 1`.
Uses a variable percentage of the data (for rarefaction) and a variable train/test split.
Input:
`Data/Processed/area_summation.csv`: Areas calculated for all thresholds from 30 to 150
`Data/Processed/feclife_with-image-ids.xlsx`: Excel file with information on image names and those that were manually handcounted (but not part of the training set).
Output:
`Data/Processed/threshold_optimization_linear_coarse.csv`
`Data/Processed/threshold_optimization_linear_fine.csv`
Analysis of the resulting coarse optimization are used to guide the fine optimization. Results of the fine optimization are used to determine the optimal threshold value to use for the full image set.

4) Predict egg counts from image areas for the full set using the threshold value (`linear_threshold <- 46`) determined above. Training image data are loaded and used to create a linear model for predicting egg counts for the full set.
`Code/egg_counter/h2_fec_prediction.Rmd`
Input:
`hd_hand_counted.xlsx`: Excel file with hand counts for training images
`bad_images.xlsx`: Images that were handcouned but should not be part of the training set
`Data/Processed/area_summation_HC.csv`: Areas for the training set
`Data/Processed/image_dimensions_hd_hand_counted_masked.csv`: Maximum image dimensions for the training set
`Data/Processed/Data/Original/egg_notes_EGK.xlsx`
`Data/Processed/handcount_new_bad_images.xlsx`: Additional handcounted images
Output: `Data/Processed/predicted_egg_counts.rda`

5) Merge predicted counts, hand counts and lifespan dats
`Code/heritability/h2fecund.Rmd`
Input: 
`Data/Processed/predicted_egg_counts.rda`
`Data/Processed/lifespan_correctedData.txt`
Output:
`Data/Processed/eggs_per_female.csv`: Egg count in each vial/number of females
`Data/Processed/eggs_per_vial.txt`: Total eggs in each vial

6) Visualize fecundity
`Code/heritability/h2fec_visualization.Rmd`
Input:
`Data/Processed/eggs_per_vial.txt	
Output: various plots including reaction norms for fecundity.

7) Estimate heritability for fecundity in each vial (animal model in MCMCglmm)
`Code/heritability/h2fec_lifetime_heritability.Rmd`
Input: 
`Data/Processed/eggs_per_female.txt`
Output: `HS.Rda`, `LY.Rda`, `STD.Rda` (LY and STD later named DR and C, respectively)
`Data/Processed/herit.Rda`: Combines HS, DR, and C
`Data/Processed/eggs_per_vial.txt`: analysis of early fecundity

8) Estimate genetic cross-diet correlations for fecundity (animal model in MCMCglmm)
`Code/heritability/h2fec_lifetime_MANOVA.Rmd`
Input: `eggs_per_vial.txt`
Output:
`Data/Processed/FEC_lifetime_model_prior1.Rda`
`Genetic_Correlations_Fecundity.csv`
`Data/Processed/re.Rda`: pairwise diet comparisons

C. CORRELATION BETWEEN LIFESPAN AND FECINDITY
`Two_trait.Rmd`
Input: 
`Data/Processed/Female_events_lifespan.txt`
`Data/Processed/eggs_per_female.tx`

D. COLOR THEME AND IMAGE PACKAGING
`Figures/color_map.R`: sets theme for plot color
`Gigures/Figure_Constructor.R`: put figures in panels for publication

