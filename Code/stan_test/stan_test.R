# https://cran.r-project.org/web/packages/brms/vignettes/brms_phylogenetics.html
# https://cran.r-project.org/web/packages/brms/vignettes/brms_multivariate.html

set.seed(37264)

library(MCMCglmm)
library(tidyverse)
library(rstan)
library(brms)

iter <- 1000000
burnin <- 15000

h2life <- read.table('../Data/Processed/Female_events_lifespan.txt',
                     sep = "\t", header = TRUE,
                     stringsAsFactors = FALSE)

h2_filtered <- h2life[h2life$status!=3, ] # remove censored events
h2_filtered$animal <- seq(1, nrow(h2_filtered))
h2_filtered$treat <- as.factor(h2_filtered$treat)

HS <- subset(h2_filtered, treat == "HS")

pedigree <- HS[, c("animal", "sireid", "damid")]
names(pedigree) <- c("animal", "sire", "dam")
pedigree$animal <- as.character(pedigree$animal)
sires <- data.frame(animal = unique(pedigree$sire),
                    sire = NA, dam = NA, stringsAsFactors = FALSE)
dams <- data.frame(animal = unique(pedigree$dam),
                   sire = NA, dam = NA, stringsAsFactors = FALSE)
pedigree <- bind_rows(sires, dams, pedigree) %>% as.data.frame()

#########################################################################
# Create relationship matrix
inv.phylo <- MCMCglmm::inverseA(pedigree, scale = TRUE)
A <- solve(inv.phylo$Ainv)
A <- (A + t(A))/2 # Not always symmetric after inversion
rownames(A) <- rownames(inv.phylo$Ainv)

X <- matrix(rep(1, nrow(HS)), ncol = 1)
Y <- matrix(HS$NewAge, ncol = 1)

stan_data <- list(J = ncol(X),
                  N = nrow(Y),
                  X = X,
                  Y = as.numeric(Y),
                  A = as.matrix(A))

# fm <- stan(file = "univar.stan", data = stan_data)

# brms
fm1 <- brm(NewAge ~ 1 + (1|animal),
           data = HS,
           family = gaussian(),
           cov_ranef = list(animal = A),
           prior = c(prior(normal(50, 10), "Intercept"),
                     prior(cauchy(0, 3), "sd"),
                     prior(cauchy(0, 3), "sigma")),
           chains = 4,
           cores = 4,
           iter = 15000,
           warmup = 5000,
           control = list(max_treedepth = 15))
save(fm1, file = "fm1.Rda")

load("fm1.Rda")
plot(fm1)
pairs(fm1)

add_ic(fm1) <- "loo"
summary(fm1)

theme_set(theme_default())
pp_check(fm1, resp = "tarsus")
pp_check(fm1, resp = "back")
bayes_R2(fm1)

post <- posterior_samples(fm1)

brms_animal <- post$sd_animal__Intercept
brms_units <- post$sigma
brms_herit <- brms_animal / (brms_animal + brms_units)
hist(brms_herit)
median(brms_herit)
HPDinterval(as.mcmc(brms_herit))

#########################################################################

load("../Data/Processed/HS.Rda")
# Fixed
# plot(model$Sol)
# autocorr.diag(model$Sol)
# effectiveSize(model$Sol)

# Random
# plot(model$VCV)
# autocorr.diag(model$VCV)
# effectiveSize(model$VCV)
# 
# summary(model)

herit <- model$VCV[, "animal"] / (model$VCV[, "animal"] + model$VCV[, "units"])
plot(herit)
median(herit)
HPDinterval(herit)

