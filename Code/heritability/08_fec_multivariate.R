#' ---
#' title: "Fecundity MANOVA"
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
library(knitr)
# purl("08_fec_multivariate.Rmd", output = "08_fec_multivariate.R", documentation = 2)

#' 
#' # Setup
#' 
## ----setup---------------------------------------------------------------
rerun_MCMC <- TRUE

set.seed(224819)

library(MCMCglmm)
library(tidyverse)
library(parallel)

source("color_map.R")

#' 
## ------------------------------------------------------------------------
h2fec <- read.table("../../Data/Processed/eggs_per_vial.txt",
                    sep = '\t',
                    dec = ".", header = TRUE,
                    stringsAsFactors = FALSE)

# Standardize egg_total
h2fec$egg_total <- as.numeric(scale(h2fec$egg_total))

h2fec$animal <- seq(1, nrow(h2fec))
h2fec$treat <- as.factor(h2fec$treat)

pedigree <- h2fec[, c("animal", "sireid", "damid")]
names(pedigree) <- c("animal", "sire", "dam")
pedigree$animal <- as.character(pedigree$animal)
pedigree$sire <- as.character(pedigree$sire)
pedigree$dam <- as.character(pedigree$dam)
sires <- data.frame(animal = unique(pedigree$sire),
                    sire = NA, dam = NA, stringsAsFactors = FALSE)
dams <- data.frame(animal = unique(pedigree$dam),
                   sire = NA, dam = NA, stringsAsFactors = FALSE)
pedigree <- bind_rows(sires, dams, pedigree) %>%
  as.data.frame()

genet_corr <- tibble(model = character(),
                     HS_STD = numeric(),
                     LY_STD = numeric(),
                     HS_LY = numeric(),
                     n_eff = numeric())

iter <- 6.5e6
burnin <- 5e4
thinning <- 500
chains <- 12

#' 
#' ## Multivariate analysis
#' 
## ----MANOVA_Models, cache=TRUE-------------------------------------------
if (rerun_MCMC) {
  HS <- h2fec %>% 
    filter(treat == "HS") %>% rename(Eggs_HS = egg_total) %>% 
    as.data.frame()
  DR <- h2fec %>% 
    filter(treat == "LY") %>% rename(Eggs_DR = egg_total) %>% 
    as.data.frame()
  STD <- h2fec %>%
    filter(treat == "STD") %>% rename(Eggs_STD = egg_total) %>% 
    as.data.frame()
  
  h2fec_mrg <- full_join(full_join(HS, DR), STD)
  
  prior1 <- list(R = list(V = diag(3) * 1.002, nu = 1.002),
                 G = list(G1 = list(V = diag(3) * 1.002, nu = 0.002)))
  
  priors <- list(prior1)
  prior_names <- c("Tri: V = diag(3) * 1.002, nu = 0.02")
  
  for (ii in 1:length(priors)) {
    prior <- priors[[ii]]
    fm <- mclapply(1:chains, function(i) {
      MCMCglmm(cbind(Eggs_STD, Eggs_HS, Eggs_DR) ~ trait - 1,
               random = ~ us(trait):animal,
               rcov = ~ idh(trait):units,
               data = h2fec_mrg,
               prior = prior,
               pedigree = pedigree,
               family = rep("gaussian", 3),
               nitt = iter,
               burnin = burnin,
               thin = thinning)
    }, mc.cores = chains)
    outfile <- paste0("../../Data/Processed/fec_total_multivariate_model_prior", ii, ".Rda")
    save(fm, file = outfile)
    
    re <- lapply(fm, function(m) m$VCV)
    re <- do.call(mcmc.list, re)
    re <- as.mcmc(as.matrix(re))
    
    n_eff <- effectiveSize(re)
    
    # STD vs. HS
    HS_STD <- re[ , "traitEggs_HS:traitEggs_STD.animal"] /
      sqrt(re[ , "traitEggs_STD:traitEggs_STD.animal"] *
             re[ , "traitEggs_HS:traitEggs_HS.animal"])
    
    # STD vs. DR
    DR_STD <- re[ , "traitEggs_DR:traitEggs_STD.animal"] /
      sqrt(re[ , "traitEggs_STD:traitEggs_STD.animal"] *
             re[ , "traitEggs_DR:traitEggs_DR.animal"])
    
    # DR vs. HS
    HS_DR <- re[ , "traitEggs_HS:traitEggs_DR.animal"] /
      sqrt(re[ , "traitEggs_DR:traitEggs_DR.animal"] *
             re[ , "traitEggs_HS:traitEggs_HS.animal"])
    
    genet_corr <- bind_rows(genet_corr,
                            tibble(model = prior_names[[ii]],
                                   HS_STD = median(HS_STD),
                                   DR_STD = median(DR_STD),
                                   HS_DR = median(HS_DR),
                                   n_eff = mean(n_eff)))
  }
  
  write_csv(genet_corr, path = "../../Data/Processed/Genetic_Correlations_Fecundity.csv")
}

#' 
#' ### Analyze model
#' 
## ----analyze_multivariate_analysis---------------------------------------
load("../../Data/Processed/fec_total_multivariate_model_prior1.Rda")

fe <- lapply(fm, function(m) m$Sol)
fe <- do.call(mcmc.list, fe)
plot(fe, ask = FALSE)
plot(fe[, 1, drop = FALSE], ask = FALSE)
plot(fe[, 2, drop = FALSE], ask = FALSE)
plot(fe[, 3, drop = FALSE], ask = FALSE)

# Extract random effects, convert to mcmc.list
re <- lapply(fm, function(m) m$VCV)
re <- do.call(mcmc.list, re)

plot(re[, 1, drop = FALSE], ask = FALSE)
plot(re[, 2, drop = FALSE], ask = FALSE)
plot(re[, 3, drop = FALSE], ask = FALSE)

autocorr.diag(re)
effectiveSize(re)

# Concatenate samples
re <- as.mcmc(as.matrix(re))

head(re)

# STD vs. HS
plot(re[ , "traitEggs_HS:traitEggs_STD.animal"])
plot(re[ , "traitEggs_STD:traitEggs_STD.animal"])
HS_STD <- re[ , "traitEggs_HS:traitEggs_STD.animal"] /
  sqrt(re[ , "traitEggs_STD:traitEggs_STD.animal"] *
         re[ , "traitEggs_HS:traitEggs_HS.animal"])
plot(HS_STD)
median(HS_STD)
HPDinterval(HS_STD)

# STD vs. DR
DR_STD <- re[ , "traitEggs_DR:traitEggs_STD.animal"] /
  sqrt(re[ , "traitEggs_STD:traitEggs_STD.animal"] *
         re[ , "traitEggs_DR:traitEggs_DR.animal"])
plot(DR_STD)
median(DR_STD)
HPDinterval(DR_STD)

# DR vs. HS
HS_DR <- re[ , "traitEggs_HS:traitEggs_DR.animal"] /
  sqrt(re[ , "traitEggs_DR:traitEggs_DR.animal"] *
         re[ , "traitEggs_HS:traitEggs_HS.animal"])
plot(HS_DR)
median(HS_DR)
HPDinterval(HS_DR)

save(re, file = "../../Data/Processed/fec_total_multivariate_model_output.Rda")

#' 
#' ### Plot for paper
#' 
## ------------------------------------------------------------------------
library(tidyverse)
library(cowplot)

B <- data_frame(`HS vs. STD` = as.numeric(HS_STD),
                `DR vs. STD` = as.numeric(DR_STD),
                `HS vs. DR` = as.numeric(HS_DR))

B <- as_tibble( B ) %>%  
  select(`HS vs. STD`, `DR vs. STD`, `HS vs. DR`) %>% 
  rename(`HS vs. C` = `HS vs. STD`) %>% 
  rename(`DR vs. C` = `DR vs. STD`) %>% 
  rename(`HS vs. DR` = `HS vs. DR`)

colMeans(B)

B %>% gather(Comparison, value) %>%
  ggplot(aes(value, color = Comparison)) +
  geom_line(stat = "density", size = 1) +
  labs(x = "Genetic Correlation", y = "Density") +
  theme(legend.position = c(0.15, 0.85),
        text = element_text(size = 12),
        legend.text = element_text(size = 12))+
  scale_x_continuous(expand = c(0, 0), limits = c(-1.2, 1.2)) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 12))
ggsave(last_plot(), file = "../../Figures/Fecundity_Genetic_Correlation_Plot.pdf",
       width = 4, height = 4)

