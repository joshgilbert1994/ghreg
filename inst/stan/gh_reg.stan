// Gilbert & Himmelsbach persistence meta-regression, fully marginal likelihood.
//
//   theta1_jk = mu    + u1_k + eps1_jk
//   theta2_jk = alpha + beta * theta1_jk + u2_k + eps2_jk
//   (es1_jk, es2_jk) ~ N((theta1_jk, theta2_jk), Sigma_jk),  corr(e1, e2) = rho_jk
//
// theta, eps, and u are integrated out analytically (per-pair 2x2 blocks plus
// a rank-2 study term, by Woodbury), so the sampler sees only the
// hyperparameters. has_study = 0 drops the study level (u1, u2).
data {
  int<lower=1> K;                       // ES pairs
  int<lower=1> J;                       // studies
  array[K] int<lower=1, upper=J> g;     // study index
  int<lower=0, upper=1> has_study;      // 0: two-level model
  vector[K] y1;
  vector[K] y2;
  vector<lower=0>[K] v1;                // se1^2
  vector<lower=0>[K] v2;                // se2^2
  vector[K] c12;                        // rho * se1 * se2
  vector[2] p_mu;                       // normal(mean, sd) priors
  vector[2] p_alpha;
  vector[2] p_beta;
  real<lower=0> sd_scale;               // half-Cauchy(0, sd_scale) on all SDs
}
parameters {
  real mu;
  real alpha;
  real beta;
  vector<lower=0>[has_study] study_sd1;
  vector<lower=0>[has_study] study_sd2;
  real<lower=0> es_sd1;
  real<lower=0> es_sd2;
}
model {
  mu ~ normal(p_mu[1], p_mu[2]);
  alpha ~ normal(p_alpha[1], p_alpha[2]);
  beta ~ normal(p_beta[1], p_beta[2]);
  study_sd1 ~ cauchy(0, sd_scale);
  study_sd2 ~ cauchy(0, sd_scale);
  es_sd1 ~ cauchy(0, sd_scale);
  es_sd2 ~ cauchy(0, sd_scale);

  {
    real t1 = square(es_sd1);
    real t2 = square(es_sd2);
    // per pair: D = V + S_e, where S_e is the ES-level covariance of (theta1, theta2)
    vector[K] d11 = v1 + t1;
    vector[K] d12 = c12 + beta * t1;
    vector[K] d22 = v2 + square(beta) * t1 + t2;
    vector[K] det_d = d11 .* d22 - square(d12);
    vector[K] e1 = y1 - mu;
    vector[K] e2 = y2 - (alpha + beta * mu);
    // D^-1 e
    vector[K] w1 = (d22 .* e1 - d12 .* e2) ./ det_d;
    vector[K] w2 = (d11 .* e2 - d12 .* e1) ./ det_d;
    real quad = dot_product(e1, w1) + dot_product(e2, w2);
    real logdet = sum(log(det_d));

    if (has_study) {
      // S_u: study-level covariance of (theta1, theta2)
      real s1 = square(study_sd1[1]);
      real s11 = s1;
      real s12 = beta * s1;
      real s22 = square(beta) * s1 + square(study_sd2[1]);
      // per study: A = sum_j D_j^-1 (symmetric), f = sum_j D_j^-1 e_j
      vector[J] a11 = rep_vector(0, J);
      vector[J] a12 = rep_vector(0, J);
      vector[J] a22 = rep_vector(0, J);
      vector[J] f1 = rep_vector(0, J);
      vector[J] f2 = rep_vector(0, J);
      for (i in 1:K) {
        a11[g[i]] += d22[i] / det_d[i];
        a12[g[i]] += -d12[i] / det_d[i];
        a22[g[i]] += d11[i] / det_d[i];
        f1[g[i]] += w1[i];
        f2[g[i]] += w2[i];
      }
      // M = I + A S_u; H = S_u M^-1 = (S_u^-1 + A)^-1 (symmetric)
      vector[J] m11 = 1 + a11 * s11 + a12 * s12;
      vector[J] m12 = a11 * s12 + a12 * s22;
      vector[J] m21 = a12 * s11 + a22 * s12;
      vector[J] m22 = 1 + a12 * s12 + a22 * s22;
      vector[J] det_m = m11 .* m22 - m12 .* m21;
      vector[J] h11 = (s11 * m22 - s12 * m21) ./ det_m;
      vector[J] h12 = (s12 * m11 - s11 * m12) ./ det_m;
      vector[J] h22 = (s22 * m11 - s12 * m12) ./ det_m;
      quad -= dot_product(f1, h11 .* f1) + 2 * dot_product(f1, h12 .* f2)
              + dot_product(f2, h22 .* f2);
      logdet += sum(log(det_m));
    }
    target += -0.5 * (logdet + quad);
  }
}
