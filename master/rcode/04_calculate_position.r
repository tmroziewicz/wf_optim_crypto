library('xts')
library('yaml')
library('optparse')
library('tibble')
library('here')
library('tidyverse')
library('roll')
library('R6')

#Precalculate all data which could be later used withouth need for caluclation 
source("master//rcode//logic//strategy.r")
#setwd("c:\\todo-p\\UW\\Master-Thesis")
#read YAML params
#params <- yaml::read_yaml("params.yaml")
#params$`01_select`$currency

Sys.setlocale("LC_TIME", "English")

parser <- OptionParser()

parser <- add_option(parser, "--inputfile", action="store_true", type="character" ,
                     default=TRUE, help="Print extra output [default]")

parser <- add_option(parser,  "--outputfile", action="store_true",type="character" , default="" , help="Print little output")

opt <- parse_args(parser)

data.in.xts <- readRDS(opt$inputfile)
#data.in.xts <- readRDS("./master/data-wip/1/60/03_precalculated.rds")

param.path.str <- "master//rcode//logic/strategy_param.yaml"

strategy.obj <- Strategy$new(param.path.str = param.path.str)

data.out.xts <- strategy.obj$calculate.position(data.in.xts)

saveRDS(data.out.xts, file = opt$outputfile)
