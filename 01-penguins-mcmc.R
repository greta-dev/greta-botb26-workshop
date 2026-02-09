library(palmerpenguins)
library(tidyverse)
library(bayesplot)

# source functions
source("R/prepare_penguins.R")

# we are going to build a model to predict the sex of an individual penguin
# based on measurements of that individual.

# this is a thing people do
# https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0090081

# here's the data from that paper (from the palmerpenguins package)
head(penguins)

# The package also has some great artwork:
# https://github.com/allisonhorst/palmerpenguins#artwork

# before we can fit a model, we need to tidy up the data and transform some variables
penguins_for_modelling <- prepare_penguins(penguins)

# this is the model we are going to fit to start with:

# likelihood
#   is_female_numeric[i] ~ Bernoulli(probability_female[i])
# link function
#   logit(probability_female[i]) = eta[i]
# linear predictor
#   eta[i] = intercept + coef1 * flipper_length_mm_scaled[i] +
#              coef2 * body_mass_g_scaled[i]

# here's a non-bayesian (maximum-likelihood) version
non_bayesian_model <- glm(
  is_female_numeric ~ flipper_length_mm_scaled + body_mass_g_scaled,
  data = penguins_for_modelling,
  family = stats::binomial
)

summary(non_bayesian_model)

# now let's fit the Bayesian equivalent
library(greta)

# define priors
intercept <- normal(0, 10)
coef_flipper_length <- normal(0, 10)
coef_body_mass <- normal(0, 10)

# define linear predictor
eta <- intercept +
  coef_flipper_length * penguins_for_modelling$flipper_length_mm_scaled +
  coef_body_mass * penguins_for_modelling$body_mass_g_scaled

# apply link function
probability_female <- ilogit(eta)

# define likelihood
# distribution(penguins_for_modelling$is_female_numeric) <- bernoulli(probability_female)
y <- as_data(penguins_for_modelling$is_female_numeric)
distribution(y) <- bernoulli(probability_female)

# combine into a model object
m <- model(intercept, coef_flipper_length, coef_body_mass)

# Show the dag - there's a couple of extra things here.
plot(m)

# do MCMC - 4 chains, 1000 on each after 1000 warmuup (default is 2 chains)
draws <- mcmc(
  m,
  sampler = hmc(),
  n_samples = 1000,
  warmup = 1000,
  chains = 4,
  n_cores = 3
)

# visualise the MCMC traces with {coda}
plot(draws[, "coef_flipper_length"])

# we can also use bayesplot to explore the convergence of the model
bayesplot::mcmc_trace(draws)
bayesplot::mcmc_dens(draws)

# check convergence (we already discarded burn-in and don't need the
# multivariate stat)
coda::gelman.diag(draws, autoburnin = FALSE, multivariate = FALSE)

# look at the parameter estimates
summary(draws)

# compare to glm
summary(non_bayesian_model)

## doing prediction - go to penguins-predictions.R
