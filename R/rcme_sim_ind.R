# function for simulating ME when ME is on ind var.
#' Plotting graphs for
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
rcme_sim_ind <- function(data,
                    outcome,
                    predictors,
                    R,
                    focal_variable,
                    D,
                    log_var){



  log_odds <- log((D * R - D)/(D * R - 1))
  log_odds <- ifelse(is.infinite(log_odds), 0, log_odds)

  if (R != 1) {
    data$error_hat <- exp(log(R / (1 - R)) +
                            log_odds * data[[outcome]]) /
      (1 + exp(log(R / (1 - R)) +
                 log_odds * data[[outcome]]))
  } else {
    data$error_hat <- exp(0 + log_odds * data[[outcome]]) /
      (1 + 0 + log_odds * data[[outcome]])
  }



  data$adjusted <- data[[focal_variable]] / data$error_hat

  if (log_var == FALSE) {
    reg_syntax <- paste0(outcome, " ~ adjusted + ",
                         paste0(predictors[!predictors %in% focal_variable],
                                collapse = " + "))
  } else {
    reg_syntax <- paste0(outcome, " ~ log(adjusted) + ",
                         paste0(predictors[!predictors %in% focal_variable],
                                collapse = " + "))
  }


  out <- lm(reg_syntax, data = data) %>%
    summary() %>%
    coef() %>%
    .[stringr::str_detect(rownames(.), "adjusted"), c("Estimate", "Std. Error")]

  # calculate risk ratio
  rr <-  D / (1 - R + (R * D))

  c(out, "Risk Ratio of Error" = rr)

}
