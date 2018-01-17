# h2 Lifespan Project Record & Notes

## Enoch Ng'oma (EN), Kevin Middleton (KM), and Elizabeth King (EK)

## Project Record

### Egg counter

### Heritability

A. DATA PREPARATION

Script: "InitialProcess.R" to process the raw .txt data file:

	1. Input file: feclife.txt 	- this is a raw data file converted from an xlxs file. 
								- The data is stored in an object called "lifec"
	
	2. Output files: 	a. lifespan_correctedData.txt - checked and cleaned for various small things
						b. Female_events_lifespan.txt - censoring accounted for (females only)
						c. Male_events_lifespan.txt - censoring accounted for (males only)


B. SURVIVAL ANALYSIS

Script: "h2surv_analysis1.Rmd" - reads in either female or male output files from A.
								:female file 'Female_events_lifespan.txt'
							- female-only data is stored in an object "h2life" (i.e. 7531 observations, 13 variables)
							
	1. Exploratory analysis
		i. Distribution histograms and density plots - baseR and ggplot2
		
	2. Kaplan-Meier plots of survival estimates
		a. Summary survival curves by treatment (3 lines) - multistrata
		b. Survival curves by sire ids (sireid), by treatment (treat) (82 levels) - multistrata
		c. Survival curves by dam ids (damid) (246 levels?)
		d. Comparisons of median lifespan across diets

## Project Notes

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

Data file feclife_with-image-ids updated:

1. added rows with missing image previously deleted, 
2. "Maybe" rows updated - with corresponding imaged placed in ‘h2_fec_images/’,
3.  updated listing of handcounts in data file. (EN)


### 2018-01-17

Data file feclife_with-image-ids updated:

1. Marking some rows as handcounted that were missed.

Analysis file Area_Summation_h2_fec_images.py updated:

1. Do not expect rows marked as "test_case", "handcounted", "missing", or "visually_recheck" to have images in h2_thresh_images.
2. Direct output to Data/Processed
