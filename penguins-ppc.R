# Note that this will also run penguins-mcmc.R!
source("penguins-predict.R")

## Posterior predictive check

# we want to see how well the data match the predictions from the model that
# we have fit
# to do this we are going to do a graphical "posterior predictive check" (or
# PPC for short).
# you can think of this as being analogous to comparing your data to the model
# predictions. If the model and the data are similar, we've done a good job
# fitting our model. If they are not similar, our model doesn't represent the
# data very well
# There are some helpful ways to visualise this build into the "bayesplot" R
# package. But we need to do some summaries of the data first.
# this next step is inspired by the well worked vignette,
# "graphical PPCs", found at:
# https://cran.r-project.org/web/packages/bayesplot/vignettes/graphical-ppcs.html
library(bayesplot)

# to do this we need some simulated predictions
# in a regular glm model, you might do something like:
# predict(glm_model)
# which would produce a vector of model predictions the same length as the
# data
# we will use greta's `calculate` function, which will act in a similar way
# but has a lot of other uses and is very flexible
# for the moment, we will focus on this specific use, for calculating predictions
# We take our vector, y, which is out outcome
# then we tell it to use the draws object
# and to calculate 500 simulations
sims_model <- calculate(
  y,
  values = draws,
  nsim = 500
)

# each row represents a draw from the posterior predictive distribution
# There is one element for each of the datapoints in Y
# there were 333 rows in the data:
length(y)
# and then there are 500 rows, one for each simulation we drew earlier.
# given that there are
dim(sims_model$y)
str(y)
# What we require here is a matrix
# where the rows are the number of draws
# and the columns are the number of observations
# this object is actually a 3 dimensional array.
# We want to keep everything in the first two
yrep_matrix <- sims_model$y[,, 1]
y_values <- as.integer(y)

## distribution of test statistics

# we can  look at the distribution of ones over the replicated datasets
# from the posterior predictive distribution in yrep_matrix and compare to the
# proportion of observed ones in y.

# we define a function that tells us the proportion of ones
prop_ones <- function(x) mean(x == 1)
prop_ones(y_values) # check proportion of ones in y

# We can visualise the proportion of ones in the simulations from the model
ppc_stat(y_values, yrep_matrix, stat = "prop_ones", binwidth = 0.005)

# we can split this by grouping variables to look for things missing from our model
ppc_stat_grouped(
  y_values,
  yrep_matrix,
  stat = "prop_ones",
  penguins_for_modelling$island,
  binwidth = 0.005
)

# there are other uses of PPC
# see
# https://cran.r-project.org/web/packages/bayesplot/vignettes/graphical-ppcs.html

###
# we can also do *Prior* predictive checks
sims_prior <- calculate(
  y,
  nsim = 500
)

yrep_prior_matrix <- sims_prior$y[,, 1]

# We can visualise the proportion of ones in the simulations from the model
ppc_stat(y_values, yrep_prior_matrix, stat = "prop_ones", binwidth = 0.005)

# there are other uses of PPC

# how to check your priors:
sims_params_prior <- calculate(
  # parameter values
  intercept,
  coef_flipper_length,
  coef_body_mass,
  # estimate of first observation on link scale
  eta[1, ],
  # estimate of probability for first observation
  probability_female[1, ],
  nsim = 500
)

par(mfrow = c(3, 2))
hist(sims_params_prior$intercept)
hist(sims_params_prior$coef_flipper_length)
hist(sims_params_prior$coef_body_mass)
hist(sims_params_prior$`eta[1, ]`)
hist(sims_params_prior$`probability_female[1, ]`)

# your turn: how to visualise your posterior samples
###
