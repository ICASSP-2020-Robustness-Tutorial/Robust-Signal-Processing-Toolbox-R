#' ekf_Masreliez
#'
#' Masreliez type EKF for tracking with time-of-arrival (ToA) estimates.
#'
#' @note
#' requires following libraries:
#'    * pracma
#'    * zeallot
#' @export
ekf_toa_Masreliez <- function(r_ges, theta_init, BS, parameter = NULL){
  if(is.null(parameter)){
    print('Using default parameters')
    sigma_v <- 1
    M <- nrow(BS)
    P0 <- diag(x = c(100, 100, 10, 10))
    R <- 150^2 * diag(x = 1, M, M)
    Ts <- 0.2
    A <- matrix(data = c(1.,0,0,0, 0,1,0,0, Ts,0,1,0, 0,Ts,0,1), 4, 4)
    Q <- sigma_v^2 * diag(1,2,2)
    G <- rbind(Ts^2 / 2 * diag(1, 2, 2), Ts * diag(1,2,2))
    #dimension of positions, default is 2
    parameter <- list('dim' = ncol(BS), 'var.est' = 1)
  } else {
    P0 <- parameter$P0
    R <- parameter$R
    Q <- parameter$Q
    G <- parameter$G
    A <- parameter$A
  }

  if(2 * parameter$dim != length(theta_init) |
     2 * parameter$dim != nrow(P0)){
    simpleError('State vector or state covariance do not match the dimensions of the BS')
  }

  x <- BS[, 1]
  y <- BS[, 2]

  M <- length(x)
  N <- ncol(r_ges)

  P <- tensorA::to.tensor(0,c(U=4,V=4,W=N))
  th_hat <- matrix(theta_init, length(theta_init), N)
  th_hat_min <- matrix(0, 4, N)
  P_min <- to.tensor(0,c(U=4,V=4,W=N))
  H <- matrix(0, M, 4)
  h_min <- numeric(M)

  for(kk in 2:N){
    th_hat_min[ , kk] <- A %*% th_hat[ , kk - 1]

    P_min[,,kk] <- A %*% P[,,kk-1] %*% t(A) + G %*% Q %*% t(G)

    for(ii in 1:M){
      h_min[ii] <- sqrt(
        (th_hat_min[1,kk] - x[ii])^2
        + (th_hat_min[2,kk] - y[ii])^2)
      H[ii,] <- c((th_hat_min[1, kk] - x[ii])/h_min[ii],
                  (th_hat_min[2, kk] - y[ii])/h_min[ii], 0, 0)
    }

    S <- H %*% P_min[,,kk] %*% t(H) * R

    tryCatch(C <- chol(S), finally = {
      warning('matrix modified in Masreliez filter')
      S <- S + diag(500000, M, M)
      C <- chol(S)
    })

    nu <- pracma::inv(C) %*% (r_ges[,kk] - h_min)

    K <- P_min[,,kk] %*% t(H) %*% inv(t(C))

    c(v, vp) %<-% asymmetric_tanh(nu, parameter$c1, parameter$c2, parameter$x1)

    th_hat[, kk] <- th_hat_min[,kk] + K %*% v

    P[,,kk] <- (diag(1, 4, 4) - K %*% inv(C) %*% H * mean(vp)) %*% P_min[,,kk]

    }
}
