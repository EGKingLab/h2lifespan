Analysis pipeline for H2 data


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
		

C. HERITABILITY ESTIMATES

