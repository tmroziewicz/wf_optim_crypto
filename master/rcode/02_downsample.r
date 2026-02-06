library('xts')
library('yaml')
library('optparse')
library('tibble')
library('here')
library('tidyverse')
library('R6')
source("master/rcode/logic/helpers/datetime_helper.r")

#read YAML params
#params <- yaml::read_yaml("params.yaml")
#params$`01_select`$currency


Sys.setlocale("LC_TIME", "English")

parser <- OptionParser()

parser <- add_option(parser, "--inputfile", action="store_true", type="character" ,
                     default=TRUE, help="Print extra output [default]")

parser <- add_option(parser,  "--outputfile", action="store_true",type="character" , default="" , help="Print little output")

parser <- add_option(parser,  "--timeframe", action="store_true",type="character" , default="" , help="Print little output")

parser <- add_option(parser,  "--asset", action="store_true",type="character" , default="" , help="Print little output")


opt <- parse_args(parser)

asset.str <- opt$asset
timeframe.int <- as.integer(opt$timeframe)

dvc.params.yaml <- yaml::read_yaml("params.yaml")

#freq <- calc_frequency_per_day(dvc.params.yaml$general$curr.tf.min.int)

current.path <- getwd()

setwd(dvc.params.yaml$general$datapath)

message(opt$timeframe)

message(opt$asset)

dir.create( file.path(asset.str,timeframe.int), recursive = TRUE)

setwd(current.path)

data.xts <- readRDS(opt$inputfile)

downsampled.xts <- downsample.xts(data.xts[,asset.str], timeframe.int)

head(data.xts[,asset.str],10)

head(downsampled.xts)

saveRDS(downsampled.xts, opt$outputfile)




