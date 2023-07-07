
# function to run simulation for one situation
#' Function that simulates the effect of measurement error on the dependent variable.
#'
#' @param formula Regression formula of interest
#' @param data Data that will be used
#' @param focal_variable The key independent variable of interest in the model. Only one variable can be used.
#' @param R The magnitude of the systematic error component, included as a scalar contained within the (0,1). Users can input multiple values using c().
#' @param D The magnitude of the association between the measurement error and the key variable of interest measured as relative risk. Users can input multiple values using c().
#' @param log_var Do you want the function to log the outcome? If log_var = TRUE users must remember that all sensitivity results will be presented on the log scale.
#'
#' @return
#' @export
#'
#' @examples
#' rcme_out(
#'   formula = "damage_crime ~ collective_efficacy + unemployment +
#'   white_british + median_age",
#'   data = crime_damage,
#'   focal_variable = "collective_efficacy",
#'   R = 0.29,
#'   D = 0.9,
#'   log_var = TRUE)
rcme_out <- function(formula,
                     data,
                     focal_variable, # main predictor of interest
                     R = 1, # reporting rate
                     D = 0, # correlation
                     log_var = FALSE # should we log the variable
                      ) {


# input checks ------------------------------------------------------------

  # check inputs and give error if not correct format and length
  if (!is.data.frame(data)) {
    stop("`data` must be a data")
  }
  if (!is.numeric(R)) {
    stop("`R` must be numeric")
  }
  # if (sum(S < 0, S > 1) > 0) {
  #   stop("`S` must be between 0 and 1")
  # }
  if (!is.numeric(D)) {
    stop("`D` must be numeric")
  }
  # if (sum(D < -1, D > 1) > 0) {
  #   stop("`D` must be between -1 and 1")
  # }
  if (length(focal_variable) != 1 | !is.character(focal_variable)) {
    stop("`focal_variable` must be character and of length 1")
  }
  if (is.logical(log_var) == FALSE) {
    stop("`log_var` must be logical type")
  }
  if (length(log_var) == 1) {
    if (log_var == TRUE) {
      warning("You have specified log_var = TRUE.\nThe crime variable will be logged to reflect the multiplicative error structure. If you wish to report the sensitivity results in the original crime metric they will need to be transformed. For a full discussion of the multiplicative error structure of crime see Pina-Sanchez et al., 2022.")
    }
  }
  # if (length(D) == 1) {
  #   if (D == 0) {
  #     warning("The correlation between measurement error in crime data and the key variable of interest is set to 0. Non-differentiality is assumed.")
  #   }
  # }

# parse inputs ------------------------------------------------------------

  # parse formula to separate outcome and ind. vars
  formula_info <- stringr::str_split(formula, "~")[[1]]

  # get outcome
  outcome <- stringr::str_trim(formula_info[1])

  # save predictors as separate object
  predictors <- stringr::str_split(formula_info[2], "\\+")[[1]] %>%
    stringr::str_trim()

  # check if all the variables are in the data
  all_vars <- c(outcome, predictors)
  name_check <- all_vars %in% names(data)
  if (sum(name_check) < length(all_vars)) {
    stop(paste("The following variables are not in the data:",
               all_vars[!name_check]))
  }

# make naive estimation ---------------------------------------------------


  # make different naive estimation depending if the variable should be logged
  # or not
  if (log_var == F) {
    lm_naive <- lm(paste0(outcome, " ~ ",
                          paste0(predictors, collapse = " + ")),
                   data)
  } else {
    lm_naive <- lm(paste0("log(", outcome, ")", " ~ ",
                          paste0(predictors, collapse = " + ")),
                   data)
  }


# run simulation ----------------------------------------------------------

  # if only one set of inputs run function just once. If more run multiple times
  if (length(R) +
      length(D) + length(log_var) == 3) {

    # run sim_out function once with inputs from above
    sim_res <- rcme_sim_out(data,
                       outcome,
                       predictors,
                       R,
                       focal_variable,
                       D,
                       log_var)

    # extract outputs from simulation
    slope <- sim_res[1]
    SE <- sim_res[2]

    # save simple results for printing
    sim_result <- data.frame(focal_variable = round(slope, 3),
                             SE = round(SE, 3))

  } else {

    # create all possible combination of inputs to loop over
    args <- expand.grid(R = R,
                        D = D,
                        log_var = log_var)

    # loop function over all combination of inputs
    res <- purrr::pmap(args,
                rcme_sim_out,
                data = data,
                predictors = predictors,
                outcome = outcome,
                focal_variable = focal_variable)

    # extract inputs from simulation
    # extract inputs from simulation
    slope <- purrr::map(res, function(x) x[1]) %>% unlist()
    SE <- purrr::map(res, function(x) x[2]) %>% unlist()

    # save simple results for printing
    sim_result <- cbind(args,
                        focal_variable = round(slope, 3),
                        SE = round(SE, 3))
  }


  # save result -------------------------------------------------------------

  # make list object to print
  out <- list(sim_result = sim_result,
              naive = lm_naive,
              focal_variable = focal_variable)

  # print result
  out
}
