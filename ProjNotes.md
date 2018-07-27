
---
title: "h2 Lifespan Project Record & Notes"
author: "Enoch Ng'oma (EN), Kevin Middleton (KM), and Elizabeth King (EK)"
date: "6/8/2018"
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

## Project Notes 

### 2018-01-11

Setting up this record. All work done on analyses should get an entry with some notes of what was done and who did it. This file will also keep track of the order of analyses, file names, etc. in the Project Record section. (EK)

Missing images will be coded as "missing" in the camera_id column. (EK)

Moved egg counter analysis files into Code/egg_counter. (KM)

Moved h2_fec_images up to the same directory level as h2_lifespan. (KM)

### 2018-01-16

Data file feclife_with-image-ids updated: (EN)

1. added rows with missing image previously deleted,
2. "Maybe" rows updated - with corresponding imaged placed in ‘h2_fec_images/’,
3. updated listing of handcounts in data file.


### 2018-01-17

Data file feclife_with-image-ids updated: (KM)

1. Marking some rows as handcounted that were missed.

Analysis file Area_Summation_h2_fec_images.py updated: (KM)

1. Do not expect rows marked as "test_case", "handcounted", "missing", or "visually_recheck" to have images in h2_thresh_images.
2. Direct output to Data/Processed

Resquaring some of the h2_fec_images: (KM)

- IMG_1961.JPG
- IMG_1976.JPG
- IMG_2956.JPG
- IMG_1992.JPG
- IMG_2865.JPG
- IMG_3070.JPG
- IMG_3071.JPG
- IMG_3184.JPG
- IMG_3641.JPG
- IMG_3642.JPG
- IMG_3737.JPG
- IMG_3738.JPG
- IMG_3739.JPG
- IMG_3760.JPG
- IMG_3771.JPG
- IMG_4546.JPG
- IMG_5056.JPG
- IMG_5555.JPG

Rarefaction analysis: (KM)

- Merged the fine and coarse R rarefaction code into one file.

### 2018-01-22

Rerun egg counter analysis (KM)

- Run coarse rarefaction
- Run fine rarefaction
- Optimal threshold value 52
- Run area estimation for all images
- Run prediction to check for possible bad images.

### 2018-01-23

Add file with handcounts only for threshold optimization. (EN)

Changes to thresholding optimization: (KM)

- Pull handcounts from hd_hand_counted.xlsx
- Remove images listed as 'bad' in bad_images.xlsx
- Set search space to 35 to 80 using all the data to start.

### 2018-01-24

Rerun threshold optimization using the full set of images, less those marked bad.

### 2018-01-30 (EN)

- EXCEL file lifespan_only.xlsx and text file lifespan_only.txt added to Processed folder
- Script PreProcess_lifespan_functions.R added to Code folder
- Run PreProcess_lifespan_functions.R (see record above)
- Run h2surv_kaplan-meier.Rmd on Female_events_lifespan.txt
- New folder created 'Figures' and populated

### 2018-02-01

- Reran coarse and fine optimization (threshold = 45). Reran fecundity predicition. (KM)
- Trying forcing the intercept through the origin. (KM)

### 2018-02-02

- Using an asymptotic through the origin model for prediction. (KM)

### 2018-02-03

- Finished optimizing using new model minimizing MSD via optim. Threshold 76.

### 2018-02-06

- Reorganize and rename files. Use separate file names for linear vs. asymptotic analyses.

### 2018-02-07

- made changes to lifespan data exploration script: (EN)
- script h2surv_kaplan-meier.Rmd renamed h2surv_expore
- h2surv_expore produces a lifetime density plot, Kaplan-Meier plot, cummulative hazard,
	and reaction norms

*Linear optimization, minimizing MSD* (KM)

```
   prop_data prop_train lower     r   MSD lower_f prop_train_f
 1         1      0.900    46 0.901 0.262 46      0.9
 2         1      0.900    45 0.901 0.262 45      0.9
 3         1      0.900    47 0.900 0.262 47      0.9
```

*Asymptotic optimization, minimizing MSD*

Coarse

```
   prop_data prop_train lower     r   MSD lower_f prop_train_f
 1         1      0.800    75 0.848 0.627 75      0.8
 2         1      0.900    75 0.787 0.628 75      0.9
 3         1      0.700    75 0.866 0.628 75      0.7

```

Fine

```
   prop_data prop_train lower     r   MSD lower_f prop_train_f
 1         1      0.900    74 0.793 0.623 74      0.9
 2         1      0.800    74 0.853 0.623 74      0.8
 3         1      0.700    74 0.871 0.624 74      0.7
```

- Reprocessing h2 fecundity images for prediction. Files output: area_summation_asymp_h2_fecimages.csv and area_summation_linear_h2_fecimages.csv based on optimiztion values above.

```
##             WAIC pWAIC dWAIC weight    SE   dSE
## fm_linear 2378.9   2.6   0.0      1 20.01    NA
## fm_asymp  2421.7   3.8  42.8      0 20.39 21.55
```

```
cor(HC$handcount, HC$lm_pred)
## [1] 0.8127161
cor(HC$handcount, HC$asymp_pred)
## [1] 0.6756418
```

Prediction via `lm()` is much better.


### 2018-03-07

The list 'high_eggs_per_female.xlsx contains females that have more than 100 each. EGK and EN
agreed to do nothing about these unless something gets obviously odd after analysis.

### 2018-03-14 (KMM)

- Cleaning up the proliferation of image area calculations. Now just running the area summation on all the images across the range of possible threshold values. We can filter out the coarse vs. fine set of threshold values in the optimization step.
- Using image size in the linear model now.

### 2018-03-18 (EN)

Original data "lifespan_only.xlsx", fID S11D33_a_LY edited to match data sheet records:
	- entry error at age 74 (i.e. 1 female died but was entered as 0)
	- NstartF changed to 15 - was entered incorrectly as 11
	- 12 female and 6 male death events only!
	- necessitates rerun of mcmcglmm

### 2018-03-18 (KMM)

- Rerunning optimization with sqrt(area) and imgage size. Predicting new (final) values for eggs.
- Cleaning up old unneeded files.

### 2018-03-26 (KMM)

- Analyze lifetime fecundity with MCMCglmm.

### 2018-03-28 (KMM)

- Normalize egg_total by the starting number of females in the vial.

### 2018-03-28 (EN)

- Phenotype analysis of fecundity

### 2018-03-29 (EGK)

-Fixed a copy error between lifespan and fecundity data sheets (April 12). Code for this is in egg counter folder. Changed in the feclife_with-image-ids.xlsx file.

### 2018-03-29 (EN)

- a list of corrections made to lifespan_only.slsx and feclife_with-image-ids.xlsx based on correct_Apr12.R
1. S11_D33_a_LY: NstartF chnaged to 15 based on set-up record
2. S13D39_a_STD: NstartF chnaged to 16 based on set-up record
3. S17D50_b_STD: box coordinates suggest a copying error resulting in repetion of row. Row is deleted from _b replicate
4. S19D56_b_HS:  A replicate made on 3.2.16 seemed to have bee ceased and replaced on 3.28.16 without a note written. NstartF amended to 20
5. S23D68_b_STD: N=23, was made on 3.11.16 but went missing; replaced on 3.28.16. The single row is deleted deleted
6. S41D121_b_LY: N=22 changed to N=24 (consistency of coordinates). N=16 on 5.3.16 changed to N=25 as this seems most plausible
7. S53D159_a_LY: N=19 (not 17) - seems to be entry error
8. S59D175_b_LY: no set-up record; set to N=24 based on observed dead events.

### 2018-03-29 (KMM)

- Rerun fecundity heritabilty & genetic correlation models.

### 2018-03-30 (EN)

These two images dropped from analysis: 1) no females left in vial at this date, 2) lifespan data sheet for this date was lost, 3) high count inconsistent at end of line

camera_id     flipDate      fID        treat days predicted_count_linear
IMG_5736.JPG	2016-06-14	S17D50_b	HS	 82	  243.7068
IMG_5738.JPG	2016-06-14	S57D169_b	HS	 78	  255 (handcount)

### 2018-04-04 (KMM)

Merge in second round of handcounted images from late in the experiment.

### 2018-04-05 (KMM)

Cleaning up egg counter files. Beginning work on Analysis pipeline description for egg counter.

### 2018-04-06 (KMM)

- Update feclife file
- Delete old unused files

### 2018-04-07 (KMM)

- `get_image_dimensions.R` only writes one file for all images.

### 2018-04-11 (KMM)

- Reran the threshold optimization using the additional images.
- Reran egg count prediction.
- Set `h2fecund` to code all negative predicted egg counts as 0.

### 2018-05-04 (KMM)

- Unify color palette in h2surv_models_visualization and h2fec_visualization

### 2018-05-30 (EGK)

- Made supplemental table 2 with counts of replicates for all sire and dam families in all diets. In dropbox for now. Code to create is in two-trait but could be moved. 

### 2018-07-25 (KMM)

- Add code for parameter expanded priors for genetic correlations.
