# h2 Lifespan Project Record & Notes

## Enoch Ng'oma (EN), Kevin Middleton (KM), and Elizabeth King (EK)

## Project Record

### Egg counter

### Heritability

## Project Notes

### Data preparation (EN)

- Load and run script: PreProcess_lifespan_functions.R (a bunch of functions)

- Run InitialProcess.R  to process the raw .txt data file:
	- Input file: lifespan_only.txt - raw data file 
	
- Output files: 
	1. lifespan_correctedData.txt
	2. Female_events_lifespan.txt - censoring accounted for (females only)
	3. Male_events_lifespan.txt - censoring accounted for (males only)


### Survival analysis

- Load data: 'Female_events_lifespan.txt'
- Run script: "h2surv_kaplan-meier.Rmd" 	# females only								
	- Exploratory analysis - histograms, density plots in baseR and ggplot2	
	- Kaplan-Meier plots of survival estimates
		- Summary survival curves by treatment (3 lines) - multistrata
		- Comparisons of median lifespan across diets

### Heritability


### General Notes

#### Launching remote Jupyter NB

See https://coderwall.com/p/ohk6cg/remote-access-to-ipython-notebooks-via-ssh

On nivalis:

1. `tmux new-session -s jupyter_session`
2. `jupyter notebook --no-browser --port=8889`
3. Ctrl-b d
4. `tmux attach -t jupyter_session`
5. `exit` to end tmux session

On Localhost:

1. `ssh -N -f -L localhost:8887:localhost:8889 remote_user@nivalis.biology.missouri.edu`
2. Chrome load `localhost:8887`


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

### 2018-03-18

Original data "lifespan_only.xlsx", fID S11D33_a_LY edited to match data sheet records:
	- entry error at age 74 (i.e. 1 female died but was entered as 0)
	- NstartF changed to 15 - was entered incorrectly as 11 
	- 12 female and 6 male death events only!
	- necessitates rerun of mcmcglmm

### 2018-03-14 (KMM)

- Cleaning up the proliferation of image area calculations. Now just running the area summation on all the images across the range of possible threshold values. We can filter out the coarse vs. fine set of threshold values in the optimization step.
- Using image size in the linear model now.

### 2018-03-18 (KMM)

- Rerunning optimization with sqrt(area) and imgage size. Predicting new (final) values for eggs.
- Cleaning up old unneeded files.

### 2018-03-26 (KMM)

- Analyze lifetime fecundity with MCMCglmm.

### 2018-03-28 (KMM)

- Normalize egg_total by the starting number of females in the vial.

