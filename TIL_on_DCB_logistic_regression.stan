data {
  int<lower=1> N;
  vector<lower=0, upper=1>[N] TIL;
  int DCB[N];
}

parameters {
  real beta;
  real alpha;
}

model {
  beta ~ normal(0, 5);
  alpha ~ normal(0, 5);
  DCB ~ bernoulli_logit(beta * TIL + alpha);
}

generated quantities {
  real p_hat_ppc = 0;
  
  for (n in 1:N) {
    int y_ppc = bernoulli_rng(inv_logit(TIL[n] * beta + alpha));
    p_hat_ppc = p_hat_ppc + y_ppc;
  }
  
  p_hat_ppc = p_hat_ppc / N;
}
