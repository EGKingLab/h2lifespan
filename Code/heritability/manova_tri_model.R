
# title: "Survival MANOVA"
set.seed(234876)

library(MCMCglmm)
library(tidyverse)
library(parallel)
library(knitr)

source("h2life_load_data.R")

genet_corr <- tibble(model = character(),
                     HS_STD = numeric(),
                     LY_STD = numeric(),
                     HS_LY = numeric(),
                     n_eff = numeric())

iter <- 1e6
burnin <- 2e4
thinning <- 500
chains <- 12

rerun <- TRUE


## MANOVA analysis


if (rerun) {
  HS <- h2life %>% 
    filter(treat == "HS") %>% rename(Age_HS = NewAge) %>% 
    as.data.frame()
  LY <- h2life %>% 
    filter(treat == "LY") %>% rename(Age_LY = NewAge) %>% 
    as.data.frame()
  STD <- h2life %>%
    filter(treat == "STD") %>% rename(Age_STD = NewAge) %>% 
    as.data.frame()
  
  h2life_mrg <- full_join(full_join(HS, LY), STD)
  
  prior1 <- list(R = list(V = diag(3) * 1.002, nu = 1.002),
                 G = list(G1 = list(V = diag(3) * 1.002, nu = 0.002)))
  
  prior2 <- list(R = list(V = diag(3) / 3, nu = 1.002),
                 G = list(G1 = list(V = diag(3) / 3, nu = 0.002)))
  
  prior3 <- list(R = list(V = diag(3) * 1.002, nu = 1),
                 G = list(G1 = list(V = diag(3) * 0.5, nu = 0.002)))
  
  priors <- list(prior1, prior2, prior3)
  prior_names <- c("Tri: V = diag(3) * 1.002, nu = 0.02",
                   "Tri: V = diag(3) / 3, nu = 0.02",
                   "Tri: V = diag(3) * 0.5, nu = 0.02")
  
  for (ii in 1:length(priors)) {
    prior <- priors[[ii]]
    fm <- mclapply(1:chains, function(i) {
      MCMCglmm(cbind(Age_STD, Age_HS, Age_LY) ~ trait - 1,
               random = ~ us(trait):animal,
               rcov = ~ idh(trait):units,
               data = h2life_mrg,
               prior = prior,
               pedigree = pedigree,
               family = rep("gaussian", 3),
               nitt = iter,
               burnin = burnin,
               thin = thinning)
    }, mc.cores = chains)
    outfile <- paste0("tri_model_prior", ii, ".Rda")
    save(fm, file = outfile)
    
    re <- lapply(fm, function(m) m$VCV)
    re <- do.call(mcmc.list, re)
    re <- as.mcmc(as.matrix(re))
    n_eff <- effectiveSize(re)
    
    # STD vs. HS
    HS_STD <- re[ , "traitAge_HS:traitAge_STD.animal"] /
      sqrt(re[ , "traitAge_STD:traitAge_STD.animal"] *
             re[ , "traitAge_HS:traitAge_HS.animal"])
    
    # STD vs. LY
    LY_STD <- re[ , "traitAge_LY:traitAge_STD.animal"] /
      sqrt(re[ , "traitAge_STD:traitAge_STD.animal"] *
             re[ , "traitAge_LY:traitAge_LY.animal"])
    
    # LY vs. HS
    HS_LY <- re[ , "traitAge_HS:traitAge_LY.animal"] /
      sqrt(re[ , "traitAge_LY:traitAge_LY.animal"] *
             re[ , "traitAge_HS:traitAge_HS.animal"])
    
    genet_corr <- bind_rows(genet_corr,
                            tibble(model = prior_names[[ii]],
                                   HS_STD = median(HS_STD),
                                   LY_STD = median(LY_STD),
                                   HS_LY = median(HS_LY),
                                   n_eff = mean(n_eff)))
  }
  
  write_csv(genet_corr, path = "../../Data/Processed/Genetic_Correlations_1M.csv")
}
