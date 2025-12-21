if (!require("pacman")) install.packages("pacman", repos = "http://cran.us.r-project.org")
pacman::p_load(xts,yaml,optparse, tibble,here,tidyverse,roll,R6)

parser <- OptionParser()
#parser <- add_option(parser, "--inputfile", action="store_true", type="character" ,
                     # default=TRUE, help="Print extra output [default]")
#parser <- add_option(parser,  "--outputfile", action="store_true",type="character" , default="" , help="Print little output")

parser <- add_option(parser,  "--timeframe", action="store_true",type="character" , default="" , help="Print little output")

parser <- add_option(parser,  "--asset", action="store_true",type="character" , default="" , help="Print little output")

opt <- parse_args(parser)

print(opt$timeframe)

print(opt$asset)

setwd("c:\\todo-p\\UW\\Master-Thesis\\master\\data-wip")
#dir.create( file.path("1min","asset1","subfolder1"), recursive = TRUE)

dir.create( file.path(opt$timeframe,opt$asset), recursive = TRUE)
