data {
  int<lower=1> N;
  vector<lower=0, upper=1>[N] TIL;
  real<lower=0> PFS[N];
}

parameters {
  real beta;
  real alpha;
  real<lower=0> sigma;
}

model {
  beta ~ normal(0, 10);
  alpha ~ normal(0, 10);
  sigma ~ normal(0, 5);

  PFS ~ normal(beta * TIL + alpha, sigma);
}

generated quantities {
  real pfs_ppc[N];
  {
    vector[N] mu = beta * TIL + alpha;
    for (n in 1:N)
      pfs_ppc[n] = normal_rng(mu[n], sigma);
  }
}
