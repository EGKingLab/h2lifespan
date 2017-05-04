# Load and prepare h2life data

library(MCMCglmm)
library(tidyverse)

h2life <- read_delim('../Data/Processed/Female_events_lifespan.txt',
                     delim = "\t") %>% 
  filter(status != 3) %>% 
  mutate(animal = factor(seq(1, nrow(.))),
         treat = as.factor(treat),
         NewAge = as.numeric(scale(NewAge))) %>% 
  dplyr::select(NewAge, sireid, damid, animal, treat) %>% 
  rename(sire = sireid, dam = damid) %>% 
  as.data.frame()

pedigree <- h2life[, c("animal", "sire", "dam")]
pedigree$animal <- as.character(pedigree$animal)
sires <- data.frame(animal = unique(pedigree$sire),
                    sire = NA, dam = NA, stringsAsFactors = FALSE)
dams <- data.frame(animal = unique(pedigree$dam),
                   sire = NA, dam = NA, stringsAsFactors = FALSE)
pedigree <- bind_rows(sires, dams, pedigree) %>%
  as.data.frame()
