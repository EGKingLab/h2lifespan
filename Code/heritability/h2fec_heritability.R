#' ---
#' title: "Dmel half-sib heritability in fecundity"
#' author: "Kevin Middleton"
#' date: "3/7/2017"
#' output:
#'   html_document:
#'     theme: flatly
#'     toc: true
#'     toc_float:
#'       collapsed: false
#'       smooth_scroll: true
#' ---
#' 
## ------------------------------------------------------------------------
library(MCMCglmm)
library(tidyverse)
library(cowplot)

#' 
#' #### Heritability ###
#' 
## ----eval=TRUE-----------------------------------------------------------
set.seed(33416)

iter <- 2e6
burnin <- 2e4


h2fec <- read.table('../../Data/Processed/eggs_per_female.txt',
                     sep = "\t", dec = ".", header = TRUE,
                     stringsAsFactors = FALSE)

#' 
## ------------------------------------------------------------------------
h2_filtered <- h2fec[h2fec$eggs_per_female, ]
h2_filtered$animal <- seq(1, nrow(h2_filtered))
h2_filtered$treat <- as.factor(h2_filtered$treat)

#' 
#' ##### high sugar, HS
#' 
## ------------------------------------------------------------------------
HS <- subset(h2_filtered, treat == "HS")

pedigree <- HS[, c("animal", "sireid", "damid")]
names(pedigree) <- c("animal", "sire", "dam")
pedigree$animal <- as.character(pedigree$animal)
sires <- data.frame(animal = unique(pedigree$sire),
                    sire = NA, dam = NA, stringsAsFactors = FALSE)
dams <- data.frame(animal = unique(pedigree$dam),
                   sire = NA, dam = NA, stringsAsFactors = FALSE)
pedigree <- bind_rows(sires, dams, pedigree) %>% as.data.frame()

#' 
## ------------------------------------------------------------------------
# Inverse Gamma(0.001; 0.001)
# a = nu / 2
# b = nu * V / 2

prior <- list(R = list(V = 1, nu = 0.002),
              G = list(G1 = list(V = 1, nu = 0.002)))

model <- MCMCglmm(eggs_per_female~ 1,
                  random = ~ animal,
                  family = "gaussian",
                  prior = prior,
                  pedigree = pedigree,
                  data = HS,
                  nitt = iter,
                  burnin = burnin,
                  thin = 50,
                  verbose = FALSE)

save(model, file = "../../Data/Processed/HS_FEC.Rda")

#' 
## ------------------------------------------------------------------------
 

#' 
#' ##### Low yeast, LY
#' 
## ------------------------------------------------------------------------
t1<-Sys.time()

LY <- subset(h2_filtered, treat == "LY")

pedigree <- LY[, c("animal", "sireid", "damid")]
names(pedigree) <- c("animal", "sire", "dam")
pedigree$animal <- as.character(pedigree$animal)
sires <- data.frame(animal = unique(pedigree$sire),
                    sire = NA, dam = NA, stringsAsFactors = FALSE)
dams <- data.frame(animal = unique(pedigree$dam),
                   sire = NA, dam = NA, stringsAsFactors = FALSE)
pedigree <- bind_rows(sires, dams, pedigree) %>% as.data.frame()

# Inverse Gamma(0.001; 0.001)
# a = nu / 2
# b = nu * V / 2

prior <- list(R = list(V = 1, nu = 0.002),
              G = list(G1 = list(V = 1, nu = 0.002)))

model <- MCMCglmm(eggs_per_female ~ 1,
                  random = ~ animal,
                  family = "gaussian",
                  prior = prior,
                  pedigree = pedigree,
                  data = LY,
                  nitt = iter,
                  burnin = burnin,
                  thin = 50,
                  verbose = FALSE)

save(model, file = "../../Data/Processed/LY_FEC.Rda")

t2<-Sys.time()
cat(t2-t1)

#' 
## ------------------------------------------------------------------------


 
#' ##### Standard, STD
#' 
## ------------------------------------------------------------------------
s1<-Sys.time()

STD <- subset(h2_filtered, treat == "STD")

pedigree <- STD[, c("animal", "sireid", "damid")]
names(pedigree) <- c("animal", "sire", "dam")
pedigree$animal <- as.character(pedigree$animal)
sires <- data.frame(animal = unique(pedigree$sire),
                    sire = NA, dam = NA, stringsAsFactors = FALSE)
dams <- data.frame(animal = unique(pedigree$dam),
                   sire = NA, dam = NA, stringsAsFactors = FALSE)
pedigree <- bind_rows(sires, dams, pedigree) %>% as.data.frame()

# Inverse Gamma(0.001; 0.001)
# a = nu / 2
# b = nu * V / 2

prior <- list(R = list(V = 1, nu = 0.002),
              G = list(G1 = list(V = 1, nu = 0.002)))

model <- MCMCglmm(eggs_per_female ~ 1,
                  random = ~ animal,
                  family = "gaussian",
                  prior = prior,
                  pedigree = pedigree,
                  data = STD,
                  nitt = iter,
                  burnin = burnin,
                  thin = 50,
                  verbose = FALSE)

save(model, file = "../../Data/Processed/STD_FEC.Rda")

s2<-Sys.time()
cat(s2-s1)

#' 
## ------------------------------------------------------------------------

