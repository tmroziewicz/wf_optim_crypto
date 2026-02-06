library('xts')
library('yaml')
library('optparse')
library('tibble')
library('here')
library('tidyverse')

library('R6')


source("master/rcode//logic/strategy.r")
source("master/rcode/logic/WfHelper.r")
source("master/rcode/logic/helpers/datetime_helper.r")

Sys.setlocale("LC_TIME", "English")

parser <- OptionParser()

parser <- add_option(parser, "--inputfile", action="store_true", type="character" ,
                     default=TRUE, help="Print extra output [default]")

parser <- add_option(parser,  "--outputfile", action="store_true",type="character" , default="" , help="Print little output")

parser <- add_option(parser,  "--indexes", action="store_true",type="character" , default="" , help="Print little output")

opt <- parse_args(parser)

getwd()

wf.indexes.df <- readRDS(opt$indexes)

data.pnl.xts <- readRDS(opt$inputfile)

dvc.params.yaml <- yaml::read_yaml("params.yaml")

freq.per.day.int <-calc_frequency_per_day(dvc.params.yaml$general$tfmin)

WfHelper.obj <- WfHelper$new(param.path.str = dvc.params.yaml$wf$param.path)

metrics.df <- WfHelper.obj$calculate.metrics(data.pnl.xts,wf.indexes.df, NULL, freq.per.day=freq.per.day.int)

saveRDS(metrics.df, opt$outputfile)




