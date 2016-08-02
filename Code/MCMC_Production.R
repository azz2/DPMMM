# clear the environment
rm(list=ls())
# if set to T, will install needed packages
# once packages are installed, no need to set to T
FIRST_USE = F
if(FIRST_USE) install.packages(c("BayesLogit", "parallel", "ggplot2"), 
                               repos = "http://cran.us.r-project.org")
exper.name <- "RealFixParam"
# set burn in
burnIn = 3000
# set number of iterations
N.MC = 2000
# set thinning rate
# if set to 1, no thinning
thin = 1
# number of cores to use if running in parallel
nCores = 8



# load needed libraries
library(BayesLogit)
library(parallel)
library(ggplot2)
library(MASS)
library(reshape2)
library(dplyr)
library(compiler)
enableJIT(3)
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

#directory = "~/DPMMM/"

# this should be modified for increased flexibility
# right now it requires a specific directory path
# so the code is not portable
# it is also inconvinient because this file is not in the root directory

# directory on my local machine
# directory = "/Users/azeemzaman/Documents/Research/Neuro/DPMMM/"
# directory on Saxon
directory = "/home/grad/azz2/Research/DPMMM/"
Code_dir = paste(directory,"Code/",sep="")
Fig_dir = paste(directory,"Figures/", exper.name, "/", sep="")
Triplet_dir = paste(directory,"Post_Summaries/", exper.name, "/", sep="")
for (direc in c(Code_dir, Fig_dir, Triplet_dir)){
  if (!file.exists(direc)){
    dir.create(direc)
  }
}


source(paste(Code_dir,"A_step.R",sep="") )
source(paste(Code_dir,"A_star_step.R",sep="") )
source(paste(Code_dir,"B_star_step.R",sep="") )
source(paste(Code_dir,"lambda_A_step.R", sep="") )
source(paste(Code_dir,"lambda_B_step.R",sep="") )
source(paste(Code_dir,"Omega_step.R",sep="") )
source(paste(Code_dir,"K_Matern.R",sep="") )
source(paste(Code_dir,"eta_Matern.R", sep="") )
source(paste(Code_dir,"eta_Matern_mod.R", sep="") )
source(paste(Code_dir,"ell_prior_step.R",sep="") )
source(paste(Code_dir,"sigma2_Matern_step.R", sep="") )
source(paste(Code_dir,"p_step.R",sep="") )
source(paste(Code_dir,"gamma_step.R",sep="") )
source(paste(Code_dir,"m_gamma_step.R",sep="") )
source(paste(Code_dir,"sigma2_gamma_step.R",sep="") )
source(paste(Code_dir,"pi_gamma_step.R",sep="") )
source(paste(Code_dir,"Bincounts.R",sep="") )
source(paste(Code_dir,"Data_Pre_Proc.R", sep="") )
source(paste(Code_dir,"MCMC_Triplet.R", sep="") )
source(paste(Code_dir,"MCMC_plot.R", sep="") )
source(paste(Code_dir,"Count_Switches.R", sep="") )
source(paste(Code_dir,"Data_Merge.R", sep="") )

#parameters for mixture components
K = 5
m_0= 0 
sigma2_0 = 1 #.01
r_gamma = 101
s_gamma = 1

#ell = c(1,2,3,4,5,15)
# using new length scales
#ell = c(3, 6, 8, 20, 80)
#L = length(ell)
#ell_0 = c( rep(.5/(L-1),(L-1) ), .5)
#ell_0 = rep(1/L, L)
#ell_0 = c(.05, .05, .125, .725, .05)

ell <- c(3, 5, 8, 12, 20)
L = length(ell)
ell_0 <- c(.2, .15, .1, .1, .45)
r_0 = 0.01
s_0 = 1

#sampling for sigma2
delta = 2e4
#r_0 = 51
#s_0 = (r_0 - 1)*(1-exp(-delta^2/ell^2)) 
#r_0 = s_0 = 10
r_0 = 0.01; s_0 = r_0
#parameters for pi_gamma
alpha_gamma = 1/K
nSamples = N.MC

# radius values for switch counts
widthes = seq(from = 0.01, to = .15, length.out = 20)

# read data from Surja's website
# Triplet_meta = read.csv("http://www2.stat.duke.edu/~st118/Jenni/STCodes/ResultsV2/All-HMM-Poi-selected.csv", 
#                        stringsAsFactors=F)
# this is the file location on my laptop
# Triplet_meta = read.csv("/Users/azeemzaman/Documents/Research/Neuro/DPMMM/Triplets_pass_criteria.csv")
# this is the file address on Saxon
#Triplet_meta = read.csv("/home/grad/azz2/Research/DPMMM/Triplets_pass_criteria.csv")
# file taking into account already run Triplets
Triplet_meta = read.csv("/home/grad/azz2/Research/DPMMM/Filtered_All_HMM.csv")
Triplet_meta = unique(Triplet_meta)
#Triplet_meta = Triplet_meta[order(Triplet_meta[,"SepBF"], decreasing=T),]
# Triplet_meta = Triplet_meta[order(Triplet_meta[,"WinPr"], decreasing=T),]
triplets = c(283, 816, 1041, 1643)

source(paste(Code_dir,"eta_bar_mixture.R",sep="") )
source(paste(Code_dir,"MinMax_Prior.R",sep="") )

# small section of test code
# compile to byte code
burnIn = 10
N.MC = 50
test_run = MCMC.triplet(1, ell_0, ETA_BAR_PRIOR, MinMax.Prior)
MCMC.plot(test_run, F, 2, widthes)

# reset burnin and N.MC
burnIn = 3000
N.MC = 2000
#triplets is the index (or row number) of the triplet in the Triplet_Meta dataframe
pt = proc.time()[3]
MCMC.results = mclapply(triplets, function(triplet) {try(MCMC.triplet(triplet, ell_0, ETA_BAR_PRIOR, MinMax.Prior))}, mc.cores = nCores)
proc.time()[3] - pt
mclapply(MCMC.results, function(x) {try(MCMC.plot(x, F, 100, widthes))}, mc.cores = nCores)

# collect error messages
errors = which(sapply(MCMC.results, typeof) == "character")
for (error in errors){
  cat("\n", file = "all_log.txt", append = TRUE)
  cat(colnames(Triplet_meta)[1:11], file = "all_log.txt", append = TRUE)
  cat("\n", file = "all_log.txt", append = TRUE)
  cat(paste(sapply(Triplet_meta[error,1:11], as.character), sep = ","), file = "all_log.txt", append = TRUE)
  cat("\n", file = "all_log.txt", append = TRUE)
  cat(as.character(MCMC.results[[error]]), file = "all_log.txt", append = TRUE)
  cat("===============", file = "all_log.txt", append = TRUE)
  #print(MCMC.results[[error]])
}

# clean up and conversion
image.dir <- paste0("Images/", exper.name)
if (!file.exists(image.dir)){
  dir.create(image.dir)
}
relevant_trips <- Triplet_meta[triplets,]
names_ext <- paste0(relevant_trips$Cell, "_Site", relevant_trips$Site,
                    "_Freq", relevant_trips$AltFreq,
                    "_Pos", relevant_trips$AltPos, ".png")
curr_files <- paste0("Summary_Triplet", triplets, ".pdf-1.png")
cbind(curr_files, names_ext)
conv_csv <- paste0(image.dir, "/rename.csv")
write.csv(cbind(curr_files, names_ext), file = conv_csv, row.names = F, col.names = F)
clean_file <- paste0(image.dir, "/cleanup.sh")
str1 = paste0("START=",min(triplets), "
              END=",max(triplets))
str2 = paste0('EXT=".pdf"
              for ((i=START;i<=END;i++));
              do
              file="../../Figures/', exper.name,'/Triplet_$i/Summary_Triplet$i"')
str3 = 'file+=".pdf"	
echo "Copying $file"
cp $file ./
echo "Converting Summary_Triplet$i$EXT "
file="Summary_Triplet$i$EXT"
pdftoppm -rx 300 -ry 300 -png "$file" "$file"
done'
str4 = "awk -F, \'{print("
str5 = '"mv \\"" $1 "\\" \\"" $2 "\\"")}'
str6 = "' rename.csv | bash -"
full_file = paste0(paste(str1, str2, str3, str4, sep = "\n"), str5, str6)
cat(full_file, file = clean_file)