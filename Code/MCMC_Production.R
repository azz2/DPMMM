# clear the environment
rm(list=ls())
# if set to T, will install needed packages
# once packages are installed, no need to set to T
FIRST_USE = F

exper.name <- "TestNewPlots"
# set burn in
burnIn = 1000
# set number of iterations
N.MC = 1000
# set thinning rate
# if set to 1, no thinning
thin = 1
# number of cores to use if running in parallel
nCores = 8

# specify directory of repository
# this should point to the folder with the 
# Code, Figures, etc subdirectories
directory = "/home/grad/azz2/Research/DPMMM/"
# specify data file
Triplet_meta = read.csv("/home/grad/azz2/Research/DPMMM/Filtered_All_HMM.csv")
Triplet_meta = unique(Triplet_meta)
# this vector specifies the ROWS of
# Triplet_meta that we want to analyze
triplets = c(283, 816, 1041, 1643)

# load needed libraries
if(FIRST_USE) install.packages(c("BayesLogit", "parallel", "ggplot2"), 
                               repos = "http://cran.us.r-project.org")
library(BayesLogit)
library(parallel)
library(ggplot2)
library(MASS)
library(reshape2)
library(dplyr)
library(compiler)
enableJIT(3)


# this should be modified for increased flexibility
# right now it requires a specific directory path
# so the code is not portable
# it is also inconvinient because this file is not in the root directory

Code_dir = paste(directory,"Code/",sep="")
Fig_dir = paste(directory,"Figures/", exper.name, "/", sep="")
Triplet_dir = paste(directory,"Post_Summaries/", exper.name, "/", sep="")
for (direc in c(Code_dir, Fig_dir, Triplet_dir)){
  if (!file.exists(direc)){
    dir.create(direc)
  }
}

# source files from Code folder
source(paste(Code_dir,"Source_All.R",sep="") )

#parameters for mixture components
K = 5
m_0= 0 
sigma2_0 = 1 #.01
r_gamma = 101
s_gamma = 1


ell <- c(3, 5, 8, 12, 20)
L = length(ell)
ell_0 <- c(.2, .15, .1, .1, .45)
r_0 = 0.01
s_0 = 1
delta = 2e4
nSamples = N.MC
alpha_gamma = 1/K


# radius values for switch counts
# for line plot
#widthes = seq(from = 0.01, to = .15, length.out = 20)
# for violin plot
widthes = c(.1, .2, .3)

#Triplet_meta = Triplet_meta[order(Triplet_meta[,"SepBF"], decreasing=T),]
# Triplet_meta = Triplet_meta[order(Triplet_meta[,"WinPr"], decreasing=T),]


source(paste(Code_dir,"eta_bar_mixture.R",sep="") )
source(paste(Code_dir,"MinMax_Prior.R",sep="") )


tempburnIN = burnIn
tempN.MC = N.MC
# small section of test code
# compile to byte code
burnIn = 10
N.MC = 50
test_run = MCMC.triplet(1, ell_0, ETA_BAR_PRIOR, MinMax.Prior)
MCMC.plot(test_run, F, 2, widthes)

# reset burnin and N.MC
burnIn = tempburnIN
N.MC = tempN.MC
#triplets is the index (or row number) of the triplet in the Triplet_Meta dataframe
pt = proc.time()[3]
MCMC.results = mclapply(triplets, function(triplet) {try(MCMC.triplet(triplet, ell_0, ETA_BAR_PRIOR, MinMax.Prior))}, mc.cores = nCores)
proc.time()[3] - pt
mclapply(MCMC.results, function(x) {try(MCMC.plot(x, F, 30, widthes))}, mc.cores = nCores)

# collect error messages
errors = which(sapply(MCMC.results, typeof) == "character")
log_file = "all_log.txt"
log_errors(errors, log_file)

# clean up and conversion

clean_convert(exper.name)

