# this will rerun the previous step
source("penguins-mcmc.R")
source("R/penguins_add_simulation.R")
# predict to a new dataset - first the marginal effect of body mass on the link
# scale

penguins_for_prediction <- expand_grid(
  flipper_length_mm_scaled = seq(
    min(penguins_for_modelling$flipper_length_mm_scaled),
    max(penguins_for_modelling$flipper_length_mm_scaled),
    length.out = 50
  ),
  body_mass_g_scaled = seq(
    min(penguins_for_modelling$body_mass_g_scaled),
    max(penguins_for_modelling$body_mass_g_scaled),
    length.out = 50
  )
)

## note that this is creating a grid of values - we are going across the
## range of body mass and flipper length
expand_grid(
  x = 1:3,
  y = 1:3
)

penguins_for_prediction

# create a new linear predictor using these new "data"
# predict to these data
eta_pred <- intercept +
  coef_flipper_length * penguins_for_prediction$flipper_length_mm_scaled +
  coef_body_mass * penguins_for_prediction$body_mass_g_scaled

# create the link
probability_female_pred <- ilogit(eta_pred)

# compute posterior prediction simulations
# to do this we need some simulated predictions
# in a regular glm model, you might do something like:
# predict(glm_model)
# which would produce a vector of model predictions the same length as the
# data
# we will use greta's `calculate` function, which will act in a similar way
# but has a lot of other uses and is very flexible
n_sims <- 200
sims <- calculate(
  probability_female_pred,
  values = draws,
  nsim = n_sims
)

# we then add these simulations back to the data with a helper function,
# `penguins_add_simulation`

penguins_prediction <- penguins_add_simulation(
  sims = sims,
  penguins_for_prediction = penguins_for_prediction
)

penguins_prediction

# plot the conditional effect of bodymass, for the mean flipper length
# recall: the mean flipper length has been scaled to have mean of 0 and SD of 1
# also recall: we created a sequence from the min to max scaled flipper length
# so although we want to say "filter to the mean value, which is zero", we
# instead say: "filter to the mean value, which is the smallest absolute value"
# which will be very close to zero.
penguins_prediction_body_mass_conditional <- penguins_prediction |>
  filter(
    abs(flipper_length_mm_scaled) == min(abs(flipper_length_mm_scaled))
  )

# grouping by body mass is going conditional on body mass here - so for each
# body mass value
penguins_prediction_body_mass_conditional_summary <- penguins_prediction_body_mass_conditional |>
  group_by(
    body_mass_g_scaled
  ) |>
  summarise(
    probability_female_mean = mean(probability_female),
    probability_female_upper = quantile(probability_female, 0.975),
    probability_female_lower = quantile(probability_female, 0.025),
  )

penguins_prediction_body_mass_conditional_summary

ggplot(
  penguins_prediction_body_mass_conditional_summary,
  aes(
    x = body_mass_g_scaled
  )
) +
  geom_line(
    aes(
      x = body_mass_g_scaled,
      y = probability_female,
      colour = sim
    ),
    data = penguins_prediction_body_mass_conditional,
    linewidth = 0.1
  ) +
  geom_ribbon(
    aes(
      ymax = probability_female_upper,
      ymin = probability_female_lower
    ),
    fill = "transparent",
    colour = "black",
    linetype = 2
  ) +
  geom_line(
    aes(
      y = probability_female_mean
    )
  ) +
  theme_minimal() +
  theme(
    legend.position = "none"
  )

## Now explopre posterior predictive checks (ppc)
## penguins-ppc.R
