#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param sims
#' @param penguins_for_prediction
#' @return
#' @author njtierney
#' @export
penguins_add_simulation <- function(sims, penguins_for_prediction) {
  n_sims <- dim(sims$probability_female_pred)[1]
  sims_wide <- sims$probability_female_pred[,, 1] |>
    t() |>
    as_tibble(.name_repair = "unique_quiet") |>
    set_names(paste0("sim_", seq_len(n_sims)))

  penguin_sims <- bind_cols(penguins_for_prediction, sims_wide)

  penguins_prediction <- pivot_longer(
    penguin_sims,
    cols = starts_with("sim"),
    names_to = "sim",
    values_to = "probability_female",
    names_prefix = "sim_"
  )

  penguins_prediction
}
