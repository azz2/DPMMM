# DPMMM
Dynamic Poisson Mixed Membership Model for neuron firing patterns

Working on code to for neuron firing patterns.  This code is still a work in progress.  There are some issues to fix and some changes to make.

# Running the Code
Most of the work in running the code should be done in MCMC_Production.R.  In that file, there are a few variables that needs to be set to run the code.  They are described below
-`FIRST_USE` is a boolean that should be set to `TRUE` if the code has never been run on this computer before.  It will installsome required packages
-`exper.name` is the experiment name.  The results will be stored in subfolders with the experiment name.  For example, the summary images will be in `Figures/MyTriplets` if `exper.name = "MyTriplets"`.  Similarly, the MCMC results will be stored in `Post_Summaries/MyTriplets`.  
- `burnIn` and `N.MC` determien the number of iterations.  `burnIn` specifies the length of the burn-in period, that is, the number of iterations that will be discarded.  A longer burn in period may give slightly cleaner results.  `N.MC` is the number of iterations to store.  More samples will give a better approximation for any distributions of interest.  Larger values for these quantities may give slightly better results, but will take longer to run.  Setting both quantities to 1000 will give decent results and run in roughtly a minute.  Setting both quantites to 2500 will give slightly better results and will run in a few minutes.  The largest values I use, which should produce fairly reproducable results, are `25e3`, which runs in approximately an hour.  
-`thin` is the thinning rate.  A larger value will make the samples more independent.  This is useful if storage space is a concern.
-`nCores` is the number of cores that should be used in parallel processing. 
`directory` is the root directory.  It should contain the `Code`, `Figures`, and other needed directories.  If you clone the repo, it is the path to the DPMMM folder.
-`Triplet_meta` is the path to the CSV file that contains the descriptions of the triplets for analysis.  Examples of such CSV files are found in the repo
-`triplets` specifies the rows of `Triplet_meta` that are to be analyzed

# Converting Images
The code saves images as PDFs (which can be very large because of the graphics).  I have written code to write a bash script to convert the PDFs to PNGs and rename them with descriptive names.  The bash script is stored in `Images/exper.name` and can be executed by typing `sh cleanup.sh` at the command line (assuming you are on a linux based machine).  This will copy the PDFs into the folder and convert them to PNGs, which can then be pushed to GitHub for viewing.
# Folder Descriptions
Code:  Contains most of the code for the project
Figures:  Contains random results from early runs.  Nothing too important
Figures_All:  PDFs for runs based on All-HMM-Poi.csv
Fiugres_Pass:  PDFs for runs based on Triplet_Pass_Criteria.csv
