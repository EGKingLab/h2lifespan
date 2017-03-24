library(MCMCglmm)

pedigree <- read.table("pedigree.txt", header = TRUE)
data <- read.table("data.txt", header = TRUE)

####################################################################

library(brms)

invA <- inverseA(pedigree)$Ainv
A <- solve(invA)
rownames(A) <- data$animal

fm_brm <- brm(phen ~ 1 + (1 | animal),
              data = data,
              family = gaussian(),
              cov_ranef = list(animal = A),
              prior = c(prior(normal(0, 100), "Intercept"),
                        prior(cauchy(0, 1), "sd"),
                        prior(cauchy(0, 1), "sigma")),
              control = list(adapt_delta = 0.95),
              iter = 1e4)
print(fm_brm, digits = 4)

hyp <- "sd_tree__Intercept^2 / (sd_tree__Intercept^2 + sigma^2) = 0"
(hyp <- hypothesis(fm_brm, hyp, class = NULL))
plot(hyp)

####################################################################

library(rstan)

```{r}
phymodel <- "
data {
  int<lower=0> N;            //N species
  vector[N] y;
  matrix[N, N] invA;         //inverse of phylovcv
}

parameters {
  real alpha;                //intercept
  real<lower=0> tau;         // scaling factor
}

transformed parameters {
  real sigma;                //regression error
  sigma = 1 / sqrt(tau);
}

model {
  vector[N] mu;              //multivariate normal mean
  alpha ~ normal(0, 100);
  sigma ~ uniform(0, 1000);
  tau ~ gamma(1, 1);

  for(n in 1:N){
    mu[n] = alpha;
  }
  y ~ multi_normal_prec(mu, tau * invA);
}
"

invA <- as.matrix(inverseA(pedigree)$Ainv)
rownames(invA) <- data$animal
colnames(invA) <- data$animal

stdat <- list(
  N = nrow(data),
  y = data$phen,
  invA = invA,
  animal = 1:nrow(invA)
)

phystan <- stan(model_code = phymodel,
                data = stdat,
                iter = 10000,
                chains = 2,
                cores = 2)
rstan::traceplot(phystan)
precis(phystan, digits = 4)
