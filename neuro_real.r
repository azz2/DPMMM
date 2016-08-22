setwd("~/Desktop/Research/Neuro/CodesNew/")
source("dynamic_neural_model.r")
triplet.meta <- unique(read.csv("~/Research/DPMMM/triplets_for_paper.csv"))
local.path <- "~/Research/DPMMM/"
web.url <- "http://www2.stat.duke.edu/~st118/Jenni/STCodes/"

require(parallel)
trip.set <- sample(1:nrow(triplet.meta), 10)

BW <- 25
data.path <- paste0(local.path, "LocalData")
save.path <- paste0(local.path, "NewResults5", BW)
if(!dir.exists(save.path)) dir.create(save.path)
if(!dir.exists(paste0(save.path, "/Figures"))) dir.create(paste0(save.path, "/Figures"))
if(!dir.exists(paste0(save.path, "/Summaries"))) dir.create(paste0(save.path, "/Summaries"))

all.set <- mclapply(trip.set, function(jj) try(fitter.fn(jj, triplet.meta, plot = FALSE, verbose = FALSE, bw = BW, save.figure = TRUE, save.out = TRUE, data.path = data.path, local.pull = TRUE, save.path = save.path)), mc.cores = 4)

trip.err <- (sapply(all.set, class) == "try-error")
while(any(trip.err)){
    all.set[trip.err] <- mclapply(trip.set[trip.err], function(jj) try(fitter.fn(jj, triplet.meta, plot = FALSE, verbose = FALSE, bw = BW, save.figure = TRUE, save.out = TRUE, data.path = data.path, local.pull = TRUE, save.path = save.path)), mc.cores = 4)
    trip.err <- (sapply(all.set, class) == "try-error")
}

