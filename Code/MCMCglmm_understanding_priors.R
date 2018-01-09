# Understanding the priors for MCMCglmm

# The default prior for variance components in MCMCglmm is the inverse
# Wishart. Parameter expanded models can also be use, enabling prior
# specifications from non-central F. These are often less informative
# priors than iW.

# For a single variance component the iW takes two scalar parameters, V and
# nu. The distribution tends to a point mass on V as nu (degree of belief
# parameter) goes to infinity. In other words, as we have stronger belief
# in our prior, our variance at the limit goes to V. the distribution tends
# to be right skewed when nu is not large. with a mode of V*nu/(nu+2) and a
# mean of V*nu/(nu-2).

# When V=1, and at the limit the iW is equivalent to inverse gamma with 
# shape=scale=nu/2 in general the inverse gamma ( a univariate case of
# inverse Wishart)  the parameterization for the iG is  shape=nu/2,
# scale=nu*V/2 or to go from iG to iW,  nu= 2*shape, and V=scale/shape.

# for the single variance, for the prior to be proper V>0, nu>0.

# A common prior for variance components is V=1, nu=0.002

require(MCMCpack)

V = 1
nu = 0.002
curve(dinvgamma(x, shape = nu / 2,
                scale = (V * nu) / 2), 0, 5,
      ylim=c(0, 1.2), xlim=c(0,5),
      main="Inverse Gamma/inverse Wishart with V=scale/shape=1", 
      ylab="density", lwd=2)

V = 1
nu = 0.02
curve(dinvgamma(x,shape=nu/2, scale=(V*nu)/2), 0, 5,
      ylim=c(0, 1.2), xlim=c(0,5),
      main="Inverse Gamma/inverse Wishart with V=scale/shape=1",
      ylab="density", lwd=2, col="grey", add=T)

V=1
nu=1
curve(dinvgamma(x,shape=nu/2, scale=(V*nu)/2), 0, 5,
      add=T, col="red", lwd=2)

V=1
nu=10
curve(dinvgamma(x,shape=nu/2, scale=(V*nu)/2), 0, 5,
      add=T, col="purple", lwd=2)

V=1
nu=15
curve(dinvgamma(x,shape=nu/2, scale=(V*nu)/2), 0, 5,
      add=T, col="blue", lwd=2)

legend(x=1.7, y=1.1, legend=c("iW: nu=0.002, iG: shape = scale = 0.001",
                              "iW: nu=1, iG: shape = scale = 0.5",
                              "iW: nu=10, iG: shape = scale = 5",
                              "iW: nu=15, iG: shape = scale = 7.5"),
       col=c("black", "red", "purple", "blue") , lwd=2)


######## Now play with values of V

#low nu
V=0.5
nu=0.002
curve(dinvgamma(x,shape=nu/2, scale=(V*nu)/2), 0, 5, ylim=c(0, 0.02), xlim=c(0,5), main="Inverse Gamma/inverse Wishart with nu=2*shape=0.002", ylab="density", lwd=2)


V=1
nu=0.002
curve(dinvgamma(x,shape=nu/2, scale=(V*nu)/2), 0, 5, add=T, col="red", lwd=2)

V=5
nu=0.002
curve(dinvgamma(x,shape=nu/2, scale=(V*nu)/2), 0, 5, add=T, col="purple", lwd=2)

V=50
nu=0.002
curve(dinvgamma(x,shape=nu/2, scale=(V*nu)/2), 0, 5, add=T, col="blue", lwd=2)

legend(x=1.7, y=0.018, legend=c("iW: V=0.5,  iG: scale= 5e-04",
                                "iW: V=1,  iG: scale=0.001",
                                "iW: V=5,  iG: scale=0.005",
                                "iW: V=50,  iG: scale=0.05"),
       col=c("black", "red", "purple", "blue") , lwd=2)

#lhigh nu
V=0.5
nu=1
curve(dinvgamma(x,shape=nu/2, scale=(V*nu)/2), 0, 5,
      ylim=c(0, 1), xlim=c(0,5),
      main="Inverse Gamma/inverse Wishart with nu=2*shape=1",
      ylab="density", lwd=2)

V=1
nu=1
curve(dinvgamma(x,shape=nu/2, scale=(V*nu)/2), 0, 5,
      add=T, col="red", lwd=2)

V=5
nu=1
curve(dinvgamma(x,shape=nu/2, scale=(V*nu)/2), 0, 5,
      add=T, col="purple", lwd=2)

V=50
nu=1
curve(dinvgamma(x,shape=nu/2, scale=(V*nu)/2), 0, 5,
      add=T, col="blue", lwd=2)

legend(x=1.7, y=0.8, legend=c("iW: V=0.5, iG: scale = 0.25",
                              "iW: V=1, iG: scale = 0.5",
                              "iW: V=5, iG: scale = 2.5",
                              "iW: V=50, iG: scale = 25"),
       col=c("black", "red", "purple", "blue") , lwd=2)


# improper priors are allowed in MCMCglmm, as they can allow for a variance
# component to be exactly zero (which can never happen with a proper prior
# since you are multiplying two non zero values together). However, using
# an improper prior can produce numerical problems and can get stuck  (the
# MCMC chain is reducible). a flat improper prior can be specified in
# MCMCglmm by by having nu=0 (V will be irrelevant), which is very diffuse.
# Specifying V=0 and nu=-1 is a uniform prior for the standard deviation on
# [0,inf] V=0, nu=-2 is non-informative for a variance component

V=1
nu=0.002
curve(dinvgamma(x,shape=nu/2, scale=(V*nu)/2), 0, 5, ylim=c(0, 0.05), xlim=c(0,5), main="Inverse Gamma/inverse Wishart with V=scale/shape=1", ylab="density", lwd=2)

V=1
nu=0.000001 # close to zero. cannot actually plot the improper prior
curve(dinvgamma(x,shape=nu/2, scale=(V*nu)/2), 0, 5,lwd=2, col="red", add=T)


# Parameter expansion (from chapter 8 of course notes), When variances are
# small and get stuck the columns of Z can be multipled by non-identified
# working parameters, they are then sampled, and then rescaled back to the
# original "scale".

# To use parameter expansion in MCMCglmm one must specify a prior
# covariance matrix for "alpha", the non-identified working parameters. i.e
# when specifying G1, include the prior mean, alpha.mu and prior covariance
# matrix alpha.V in the list.

