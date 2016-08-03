## rdirichlet and rinvgamma scraped from MCMCpack
rDirichlet <- function(n, alpha){
  #######################################
  # This function samples from a dirichlet distribution
  #
  # Args:
  #   n: number of samples
  #   alpha: parameter vector
  #
  # Return:
  #   A matrix with n rows where each row is a probability vector
  #   whose length is equal to the length of alpha
  #######################################
  l <- length(alpha)
  x <- matrix(rgamma(l * n, alpha), ncol = l, byrow = TRUE)
  sm <- x %*% rep(1, l)
  return(x/as.vector(sm))
}

rinvgamma <-function(n,shape, scale = 1) return(1/rgamma(n = n, shape = shape, rate = scale))

rtruncgamma <- function(n, low = 0, up = Inf, ...){
  unifs <- runif(n)
  return(qgamma(pgamma(low, ...) + unifs*(pgamma(up, ...) - pgamma(low, ...)), ...))
}
