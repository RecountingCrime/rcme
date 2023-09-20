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

  odds <- (D * (1 - R)) / (1 - (D * R))

  if (odds <= 0 | is.infinite(odds) | is.na(odds) | is.nan(odds)) {
    stop(
      str_c("The combination of D = ",
            D,
            " and R = ",
            R,
            " is not valid. Please try different values.\n See for more info: https://statisticsbyjim.com/probability/relative-risk/"))
  }


  data$error_hat <- exp(log(R / (1 - R)) + log(odds) * data[[focal_variable]]) /
    (1 + exp(log(R / (1 - R)) + log(odds) * data[[focal_variable]]))

  data$adjusted <- data[[outcome]] / data$error_hat

  if (log_var == FALSE) {
    reg_syntax <- paste0("adjusted ~ ",
                         paste0(predictors, collapse = "  + "))
  } else {
    reg_syntax <- paste0("log(adjusted) ~ ",
                         paste0(predictors, collapse = "  + "))
  }



  lm(reg_syntax, data = data) %>%
    summary() %>%
    coef() %>%
    .[focal_variable, c("Estimate", "Std. Error")]
}
