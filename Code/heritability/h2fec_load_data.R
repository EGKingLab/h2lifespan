# Load and prepare eggs data

library(MCMCglmm)
library(tidyverse)

h2fec_manova <- read_delim('../../Data/Processed/eggs_per_female.txt',
                     delim = "\t") %>% 
  mutate(animal = factor(seq(1, nrow(.))),
         treat = as.factor(treat),
         eggs_per_female = as.numeric(scale(eggs_per_female)),
         sireid = factor(sireid),
         damid = factor(damid)) %>% 
  dplyr::select(eggs_per_female, sireid, damid, animal, treat) %>% 
  rename(sire = sireid, dam = damid) %>% 
  as.data.frame()

pedigree <- h2fec_manova[, c("animal", "sire", "dam")]
pedigree$animal <- as.character(pedigree$animal)
pedigree$sire <- as.character(pedigree$sire)
pedigree$dam <- as.character(pedigree$dam)
sires <- data.frame(animal = unique(pedigree$sire),
                    sire = NA, dam = NA, stringsAsFactors = FALSE)
dams <- data.frame(animal = unique(pedigree$dam),
                   sire = NA, dam = NA, stringsAsFactors = FALSE)
pedigree <- bind_rows(sires, dams, pedigree) %>%
  as.data.frame()
