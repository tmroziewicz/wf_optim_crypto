library('xts')
library('yaml')
library('optparse')
library('tibble')
library('here')
library('tidyverse')
library('R6')


source("master//rcode//logic//strategy.r")


#read YAML params
#params <- yaml::read_yaml("params.yaml")
#params$`01_select`$currency

Sys.setlocale("LC_TIME", "English")

parser <- OptionParser()

parser <- add_option(parser, "--inputfile", action="store_true", type="character" ,
                     default=TRUE, help="Print extra output [default]")

parser <- add_option(parser,  "--outputfile", action="store_true",type="character" , default="" , help="Print little output")

opt <- parse_args(parser)

param.path.str <- "master//rcode//logic/strategy_param.yaml"

strat.params.yaml <- yaml::read_yaml(param.path.str)

strat.params.yaml$strategy$ma_periods_array

dvc.params.yaml <- yaml::read_yaml("params.yaml")

strategy.obj <- Strategy$new(param.path.str = param.path.str)

data.in.xts <- readRDS(opt$inputfile)

data.out.xts <- strategy.obj$precalculate(data.in.xts)

#data.out.xts$lagAsset <- lag(data.out.xts$Asset)

#data.out.xts$chng <- diff.xts(data.out.xts$Asset)

#data.out.xts$pctchng <- data.out.xts$chng/data.out.xts$lagAsset

#data.pos.xts <- strategy.obj$calculate.position(data.out.xts)

#data.pnl.xts <- strategy.obj$calculate.pnl(data.pos.xts)

saveRDS(data.out.xts, opt$outputfile)
