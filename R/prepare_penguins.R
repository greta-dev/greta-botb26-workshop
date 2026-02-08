#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param penguins
#' @return
#' @author njtierney
#' @export
prepare_penguins <- function(penguins) {
  penguins |>
    # remove missing value records
    drop_na() |>
    # rescale the length and mass variables to make the coefficient priors easier
    # to define
    mutate(
      across(
        c(bill_length_mm, bill_depth_mm, flipper_length_mm, body_mass_g),
        .fns = list(scaled = \(x) scale(x))
      ),
      # code the sex as per a Bernoulli distribution
      is_female_numeric = if_else(sex == "female", 1, 0),
      .after = island
    )

  # an aside - if you haven't seen `across` before, here is what it is
  # equivalent to:
  #  penguins |>
  #    # remove missing value records
  #    drop_na() |>
  #    # rescale the length and mass variables to make the coefficient priors easier
  #    # to define
  #    mutate(
  #         bill_length_mm_scaled = scale(bill_length_mm_scaled),
  #         bill_depth_mm_scaled = scale(bill_depth_mm_scaled),
  #         flipper_length_mm_scaled = scale(flipper_length_mm_scaled),
  #         body_mass_g_scaled = scale(body_mass_g_scaled)
  #       )
  #    )
}
