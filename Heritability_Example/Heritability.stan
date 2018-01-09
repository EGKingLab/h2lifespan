data {
	int<lower=0> N;            //N species
	vector[N] phen;
	matrix[N, N] invA;         //inverse of phylovcv
}

parameters {
	real alpha;                //intercept
	real beta;                 //slope
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
	phen ~ multi_normal_prec(mu, tau * invA);
}
