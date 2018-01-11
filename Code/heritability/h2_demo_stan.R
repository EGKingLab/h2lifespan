library(MCMCglmm)
library(pedigreemm)
library(rstan)
library(mvtnorm)
library(bayesplot)

rstan_options(auto_write = TRUE)
options(mc.cores = 10)

set.seed(17)

# Pedigree
ped <- read.table("https://raw.githubusercontent.com/diogro/QGcourse/master/tutorials/volesPED.txt",
                  header = TRUE)

# G variance
G <- 1.

# Residual variance
E <- 0.3

# Create relationship matrix
inv.phylo <- MCMCglmm::inverseA(ped, scale = TRUE)
A <- solve(inv.phylo$Ainv)
A <- (A + t(A))/2 # Not always symmetric after inversion
rownames(A) <- rownames(inv.phylo$Ainv)

# Simulated correlated random intercepts
a = t(rmvnorm(1, sigma = G*as.matrix(A)))

# Fixed effects
beta = matrix(c(1, 0.3), 2, 1, byrow = TRUE)
rownames(beta) = c("Intercept", "sex")
sex = sample(c(0, 1), nrow(a), replace = TRUE)
sex[rownames(a) %in% ped$SIRE] <- 1
sex[rownames(a) %in% ped$DAM] <- 0
Intercept = rep(1, nrow(a))
X = cbind(Intercept, sex)

# Uncorrelated noise
e = rnorm(nrow(a), sd = sqrt(E))

# Simulated data
Y = X %*% beta + a + e

## Fitting the model via REML just to be safe
ped2 <- pedigree(ped$SIRE, ped$DAM, ped$ID)  #restructure ped file
data = data.frame(Y = Y, sex = sex, ID = rownames(A))
mod_animalREML<-pedigreemm(Y ~ 1 + (1|ID), pedigree=list(ID=ped2), 
                           data = data, REML=TRUE, 
                           control = lmerControl(check.nobs.vs.nlev="ignore",
                                                 check.nobs.vs.nRE="ignore"))
summary(mod_animalREML)

stan_data = list(J = ncol(X),
                 N = nrow(Y),
                 X = X,
                 Y = as.numeric(Y),
                 A = as.matrix(A))
fm <- stan(file = "univar.stan", data = stan_data)

traceplot(fm)
pairs(fm)
post <- extract(fm)
str(post)
