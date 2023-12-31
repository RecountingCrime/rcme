% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rcme_ind.R
\name{rcme_ind}
\alias{rcme_ind}
\title{Function that simulates the effect of measurement error on an independent variable.}
\usage{
rcme_ind(formula, data, focal_variable, R = 0, D = 1, log_var = FALSE)
}
\arguments{
\item{formula}{Regression formula of interest}

\item{data}{Data that will be used}

\item{focal_variable}{The key independent variable of interest in the model. Only one variable can be used.}

\item{R}{The magnitude of the systematic error component, included as a scalar contained within the (0,1). Users can input multiple values using c().}

\item{D}{The magnitude of the association between the measurement error and the key variable of interest measured as risk ratios. Users can input multiple values using c().}

\item{log_var}{Do you want the function to log the outcome? If log_var = TRUE users must remember that all sensitivity results will be presented on the log scale.}
}
\description{
Function that simulates the effect of measurement error on an independent variable.
}
\examples{
rcme_ind(
  formula = "disorder ~ log_violent_crime + white_british + unemployment + median_age",
  data = crime_disorder,
  focal_variable = "log_violent_crime",
  R = 0.31,
  D = 0.9)
}
