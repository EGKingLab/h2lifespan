library(brms)

data("BTdata", package = "MCMCglmm")
head(BTdata)

fit1 <- brm(
  cbind(tarsus, back) ~ sex + hatchdate + (1|p|fosternest) + (1|q|dam),
  data = BTdata,
  chains = 4,
  cores = 4
)

plot(fit1)

add_ic(fit1) <- "loo"
summary(fit1)

theme_set(theme_default())
pp_check(fit1, resp = "tarsus")
pp_check(fit1, resp = "back")
bayes_R2(fit1)

