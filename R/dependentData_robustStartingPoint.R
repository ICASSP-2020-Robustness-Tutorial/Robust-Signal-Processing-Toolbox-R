#' roubst_starting_point
#'
#' The function  robust_starting_point(x,p,q) provides a
#' robust initial estimate for robust ARMA parameter estimation
#' based on BIP-AR(p_long) approximation.
#' It also computes an outlier cleaned signal using BIP-AR(p_long)
#' predictions
#'
#' @param x: numeriv vector, the time series / signal
#' @param p: AR order
#' @param q: MA order
#' @param recursion_num: integer. If parameter estimation is instationary, run robust_starting_point recursively on the filtered signal.
#'
#' @return beta_inital: ARMA coefficient estimate and the intercept
#' @return cleaned_signal: cleaned signal
#'
#' @examples
#' data(x_ao_arma)
#' library(pracma)
#'
#' robust_starting_point(x_ao_arma, 1, 1)
#' #$beta_initial
#' #ar1         ma1   intercept
#' #0.81314423  0.14617580 -0.05612576
#' @export
#' @importFrom pracma polyval
#' @importFrom pracma polyfit
robust_starting_point <- function(x, p, q, recursion_num = 0){
  # usually a short AR model provides best results.
  # Change to longer model, if necessary.
  if(q == 0) p_long <- p else p_long <- min(2 * (p + q), 4)

  x_filt <- ar_est_bip_s(x, p_long)$x_filt

  beta_initial <- arima(x_filt, order = c(p, 0, q), include.mean = T, transform.pars = T)$coef

  if(sum(abs(roots(c(1, -beta_initial[0:p])))) > 1 |
     sum(abs(roots(c(1, -beta_initial[(0+p):(p+q)]))) > 1)
  ){
    if(recursion_num < 3)
      c(beta_initial, x_filt) %<-% robust_starting_point(x_filt, p, q, recursion_num + 1)
    else beta_initial <- numeric(p+q+1)#arima(x_filt, order = c(p, 0, q), include.mean = T, transform.pars = T)$coef
  }

  return(list('beta_initial' = beta_initial, 'x_filt' = x_filt))
}
