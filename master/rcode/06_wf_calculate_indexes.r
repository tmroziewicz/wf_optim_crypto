library('xts')
library('yaml')
library('optparse')
library('tibble')
library('here')
library('tidyverse')

library('R6')


source("master//rcode//logic//strategy.r")
source("master//rcode//logic//WfHelper.r")
source("master/rcode/logic/helpers/datetime_helper.r")

#read YAML params
#params <- yaml::read_yaml("params.yaml")
#params$`01_select`$currency

Sys.setlocale("LC_TIME", "English")

parser <- OptionParser()

parser <- add_option(parser, "--inputfile", action="store_true", type="character" ,
                     default=TRUE, help="Print extra output [default]")

parser <- add_option(parser,  "--outputfile", action="store_true",type="character" , default="" , help="Print little output")

parser <- add_option(parser,  "--trainlen", action="store_true",type="character" , default="" , help="Print little output")

parser <- add_option(parser,  "--testlen", action="store_true",type="character" , default="" , help="Print little output")

inputfile <- "master/data-wip/05_pnl.rds"

opt <- parse_args(parser)

train.length.int  <- as.integer(opt$trainlen)

test.length.int  <-  as.integer(opt$testlen)

#data.pnl.xts <- readRDS(inputfile)

data.pnl.xts <- readRDS(opt$inputfile)

per <- periodicity(data.pnl.xts)

dvc.params.yaml <- yaml::read_yaml("params.yaml")

WfHelper.obj <- WfHelper$new(param.path.str = dvc.params.yaml$wf$param.path)

periods.per.day.int <- calc_frequency_per_day(dvc.params.yaml$general$tfmin)

wf.indexes.df <- WfHelper.obj$calculate.indexes(data.pnl.xts, train_days = train.length.int*periods.per.day.int, test_days = test.length.int*periods.per.day.int)

saveRDS(wf.indexes.df, opt$outputfile)

