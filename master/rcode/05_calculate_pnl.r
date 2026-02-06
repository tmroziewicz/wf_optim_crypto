library('xts')
library('yaml')
library('optparse')
library('tibble')
library('here')
library('tidyverse')

library('R6')


source("master//rcode//logic//strategy.r")

Sys.setlocale("LC_TIME", "English")

parser <- OptionParser()

parser <- add_option(parser, "--inputfile", action="store_true", type="character" ,
                     default=TRUE, help="Print extra output [default]")

parser <- add_option(parser,  "--outputfile", action="store_true",type="character" , default="" , help="Print little output")

opt <- parse_args(parser)

param.path.str <- "master//rcode//logic/strategy_param.yaml"

strat.params.yaml <- yaml::read_yaml(param.path.str)

dvc.params.yaml <- yaml::read_yaml("params.yaml")

strategy.obj <- Strategy$new(param.path.str = param.path.str)

data.in.xts <- readRDS(opt$inputfile)

data.out.xts <- strategy.obj$calculate.pnl(data.in.xts)

saveRDS(data.out.xts, opt$outputfile)

