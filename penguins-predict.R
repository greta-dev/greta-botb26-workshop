source("penguins-mcmc.R")
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

penguins_for_prediction

# predict to these data
eta_pred <- intercept +
  coef_flipper_length * penguins_for_prediction$flipper_length_mm_scaled +
  coef_body_mass * penguins_for_prediction$body_mass_g_scaled

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

dim(sims$probability_female_pred)

sims_wide <- sims$probability_female_pred[,, 1] |>
  t() |>
  as_tibble(.name_repair = "unique_quiet") |>
  set_names(paste0("sim_", seq_len(n_sims)))

sims_wide

penguin_sims <- bind_cols(penguins_for_prediction, sims_wide)

penguin_sims

penguins_prediction <- pivot_longer(
  penguin_sims,
  cols = starts_with("sim"),
  names_to = "sim",
  values_to = "probability_female",
  names_prefix = "sim_"
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
