SCRIPTS IN ORDER THEY RUN

DATA PREPARATION

InitialProcess.R
	- will source PreProcess_lifespan_functions.R (a set of functions)
	- Input data: lifespan_only.txt (raw data file) 	
	- Output files: 
		1. lifespan_correctedData.txt (all data)
		2. Female_events_lifespan.txt - censoring accounted for females only
		3. Male_events_lifespan.txt - censoring accounted for males only


SURVIVAL ANALYSIS

h2surv_explore.R
	- input data: Female_events_lifespan.txt 								
	- histograms, density plots in baseR and ggplot2	
	- Kaplan-Meier plots of survival estimates
	- tests of difference
	- reaction norms


HERITABILITY

h2surv_analysis1.R
	- input data: Female_events_lifespan.txt
	- animal models in mcmcglmm on each diet singly
	- output: 
		- HS.Rda, Ly.Rda, STD.Rda
		- heritab.Rda (combines all 3)
