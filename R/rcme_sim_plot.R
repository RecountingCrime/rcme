#' Title
#'
#' @param rcme_sim_range_object Object saved by `rcme_ind()` or `rcme_out()` with multiple values.
#' @param ci include confidence interval in the graph
#' @param naive include naive estimate in the graph
#'
#' @return
#' @export
#'
#' @examples
#' ex <- rcme_out(
#'   formula = "damage_crime ~ collective_efficacy + unemployment +
#'   white_british + median_age",
#'   data = crime_damage,
#'   focal_variable = "collective_efficacy",
#'   R = c(0.29, 0.85, 0.9),
#'   D = c(0.9, 1, 1.1),
#'   log_var = TRUE)
#'
#' rcme_sim_plot(ex)
rcme_sim_plot <- function(rcme_sim_range_object,
                          ci = TRUE,
                          naive = TRUE) {

  # make plot
  plot <- rcme_sim_range_object$sim_result %>%
    dplyr::mutate(lci = focal_variable - (1.96 * SE),
           uci = focal_variable + (1.96 * SE)) %>%
    ggplot2::ggplot(ggplot2::aes(D, focal_variable)) +
    ggplot2::geom_line(ggplot2::aes(color = "Adjusted")) +
    ggplot2::facet_wrap( ~ R) +
    ggplot2::theme_bw() +
    ggplot2::labs(
      x = "Risk ratio",
      y = "Effect of focal variable",
      color = ""
    ) +
    ggplot2::scale_color_manual(values = "black")

  if (ci == T) {
    plot <- plot +
      ggplot2::geom_ribbon(ggplot2::aes(ymin = lci, ymax = uci), alpha = 0.05)

  }



  if (naive == T) {

    naive_coefs <- rcme_sim_range_object$naive$coefficients
    names(naive_coefs) <- stringr::str_remove_all(names(naive_coefs), "log|\\(|\\)")

    naive_est <- naive_coefs[rcme_sim_range_object$focal_variable]

    plot <- plot +
      ggplot2::geom_point(ggplot2::aes(
        x = 1,
        y = naive_est,
        shape = "Naive"
      ), size = 3) +
      ggplot2::guides(
        shape = ggplot2::guide_legend(order = 2),
        color = ggplot2::guide_legend(order = 1),
        fill = ggplot2::guide_legend(order = 1)
      ) +
      ggplot2::labs(shape = "")

  }

  plot


}
