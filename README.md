
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rcme - Recounting Crime Measurement Error <img src="man/figures/logo.png" align="right" />

<!-- badges: start -->

[![DOI](https://zenodo.org/badge/505738456.svg)](https://zenodo.org/badge/latestdoi/505738456)
<!-- badges: end -->

The goal of the rcme package is to support the sensitivity analysis of
crime data to different types of measurement error. It is result of the
[Recounting Crime Project](https://recountingcrime.com/). You can see
the publications informing this work
[here](https://recountingcrime.com/scientific-articles/).

## Installation

You can install the development version of rcme from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("RecountingCrime/rcme")
```

## Example

This is a basic example which shows how to get a corrected regression
estimate when we assume measurement error on the independent variable
with a recording rate (`R`) of 0.3, and an association between the focal
variable and the recording rate (`D`) of 0.9 odds ratios.

``` r
rcme_ind(
  formula = "disorder ~ log_violent_crime + white_british + unemployment + median_age",
  data = crime_disorder,
  focal_variable = "log_violent_crime",
  R = 0.3,
  D = 0.9) 
#> $sim_result
#>          focal_variable    SE    rr
#> Estimate           0.34 0.034 0.928
#> 
#> $naive
#> 
#> Call:
#> lm(formula = paste0(outcome, " ~ ", paste0(c(paste0(focal_variable, 
#>     collapse = ""), predictors[!predictors %in% focal_variable]), 
#>     collapse = " + ")), data = data)
#> 
#> Coefficients:
#>       (Intercept)  log_violent_crime      white_british       unemployment  
#>          -1.02838            0.39849           -0.08915            0.21015  
#>        median_age  
#>          -0.17004  
#> 
#> 
#> $focal_variable
#> [1] "log_violent_crime"
```

It is possible to run the function over multiple scenarios as well as
enable the function to log the focal variable:

``` r
rcme_ind(
  formula = "disorder ~ violent_crime + white_british + unemployment + median_age",
  data = crime_disorder,
  focal_variable = "violent_crime",
  R = c(0.3, 0.6, 0.9),
  D = c(0.9, 0.95, 1, 1.05, 1.1),
  log_var = T) 
#> Warning in rcme_ind(formula = "disorder ~ violent_crime + white_british + unemployment + median_age", : You have specified log_var = TRUE.
#> The crime variable will be logged to reflect the multiplicative error structure. If you wish to report the sensitivity results in the original crime metric they will need to be transformed. For a full discussion of the multiplicative error structure of crime see Pina-Sanchez et al., 2022.
#> $sim_result
#>      R    D log_var    rr focal_variable    SE
#> 1  0.3 0.90    TRUE 0.928          0.774 0.142
#> 2  0.6 0.90    TRUE 0.957          0.626 0.149
#> 3  0.9 0.90    TRUE 0.989          0.458 0.154
#> 4  0.3 0.95    TRUE 0.964          0.595 0.150
#> 5  0.6 0.95    TRUE 0.979          0.513 0.153
#> 6  0.9 0.95    TRUE 0.995          0.428 0.155
#> 7  0.3 1.00    TRUE 1.000          0.398 0.155
#> 8  0.6 1.00    TRUE 1.000          0.398 0.155
#> 9  0.9 1.00    TRUE 1.000          0.398 0.155
#> 10 0.3 1.05    TRUE 1.034          0.195 0.159
#> 11 0.6 1.05    TRUE 1.019          0.283 0.157
#> 12 0.9 1.05    TRUE 1.005          0.370 0.156
#> 13 0.3 1.10    TRUE 1.068         -0.008 0.160
#> 14 0.6 1.10    TRUE 1.038          0.169 0.159
#> 15 0.9 1.10    TRUE 1.009          0.342 0.157
#> 
#> $naive
#> 
#> Call:
#> lm(formula = paste0(outcome, " ~ ", paste0(c(paste0("log(", focal_variable, 
#>     ")", collapse = ""), predictors[!predictors %in% focal_variable]), 
#>     collapse = " + ")), data = data)
#> 
#> Coefficients:
#>        (Intercept)  log(violent_crime)       white_british        unemployment  
#>           -1.02838             0.39849            -0.08915             0.21015  
#>         median_age  
#>           -0.17004  
#> 
#> 
#> $focal_variable
#> [1] "violent_crime"
```

When measurement error is on the outcome you can use the `rcme_out()`
function:

``` r
rcme_out_ex <- rcme_out(
  formula = "damage_crime ~ collective_efficacy + unemployment + white_british + median_age",
  data = crime_damage,
  focal_variable = "collective_efficacy",
  R = c(0.25, 0.35, 0.45),
  D = c(0.9, 0.95, 1, 1.05, 1.10),
  log_var = F)
```

You can also visualize the results of the simulations easily using
`rcme_sim_plot()`:

``` r
rcme_sim_plot(rcme_out_ex, ci = T, naive = T, rr = F)
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />

The result of this function is just a normal `ggplot2` object which can
be changed and saved accordingly:

``` r
rcme_sim_plot(rcme_out_ex, ci = T, naive = T) +
  ggplot2::theme_dark()
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />
