log_errors <- function(errors, log_file){
  for (error in errors){
    cat("\n", file = "log_file", append = TRUE)
    cat(colnames(Triplet_meta)[1:11], file = "log_file", append = TRUE)
    cat("\n", file = "log_file", append = TRUE)
    cat(paste(sapply(Triplet_meta[error,1:11], as.character), sep = ","), file = "log_file", append = TRUE)
    cat("\n", file = "log_file", append = TRUE)
    cat(as.character(MCMC.results[[error]]), file = "log_file", append = TRUE)
    cat("===============", file = "log_file", append = TRUE)
  }
}

short_log <- function(errors, log_file, triplets){
  cat(errors + min(triplets) - 1, file = log_file, append = TRUE)
  cat("\n", file = log_file, append = TRUE)
}
