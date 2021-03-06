% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Regression.R
\name{wmed}
\alias{wmed}
\title{weighted median}
\usage{
wmed(y, w, verbose = F, tol = 1e-07, iter_max = 2000)
}
\arguments{
\item{y}{: (numeric) data given (real or complex)}

\item{w}{: (nubmer) positive real-valued weights. Inputs need to be of
same length}

\item{verbose:}{(logical) true of false (default). Set as true if you wish
to see convergence as iterations evolve}

\item{tol:}{threshold for iteration in complex case \cr default = 1e-7}

\item{iter_max:}{number of iterations in complex case \cr default = 2000}
}
\value{
beta: (numeric) weighted median

converged: (logical) flag of convergence (in the complex-valued
                                                        data case)

iter: (numeric) the number of iterations (complex-valued case)
}
\description{
wmed computes the weighted median for data vector y and weights w, i.e.
it solves the optimization problem:
}
\details{
beta = arg min_b  SUM_i | y_i - b | * w_i
}
\examples{
wmed(1:5, c(1,0,1,2,3))
wmed(1:5 +1i, c(1,0,1,2,3))

}
