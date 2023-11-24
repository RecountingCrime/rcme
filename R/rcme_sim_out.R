# function for simulating ME when ME is on outcome var.
#' Title
#'
#' @param data
#' @param outcome
#' @param predictors
#' @param R
#' @param focal_variable
#' @param D
#' @param log_var
#'
#' @return
#' @export
#'
#' @examples
rcme_sim_out <- function(data,
                    outcome,
                    predictors,
                    R,
                    focal_variable,
                    D,
                    log_var
){

  # transform D to log odds and then add below instead of cor
  log_odds <- log((D * R - D)/(D * R - 1))
  log_odds <- ifelse(is.infinite(log_odds)| is.nan(log_odds), 0, log_odds)

  # new version
  if (R != 1) {
    data$error_hat <- exp(log(R / (1 - R)) +
                            log_odds * data[[focal_variable]]) /
      (1 + exp(log(R / (1 - R)) +
                 log_odds * data[[focal_variable]]))
  } else {
    data$error_hat <- exp(0 + log_odds * data[[focal_variable]]) /
      (1 + log_odds * data[[focal_variable]])
  }




  data$adjusted <- data[[outcome]] / data$error_hat

  if (log_var == FALSE) {
    reg_syntax <- paste0("adjusted ~ ",
                         paste0(predictors, collapse = "  + "))
  } else {
    reg_syntax <- paste0("log(adjusted) ~ ",
                         paste0(predictors, collapse = "  + "))
  }



  out <- lm(reg_syntax, data = data) %>%
    summary() %>%
    coef() %>%
    .[focal_variable, c("Estimate", "Std. Error")]

  # calculate risk ratio
  rr <-  D / (1 - R + (R * D))

  c(out, "Risk Ratio of Error" = rr)
}
