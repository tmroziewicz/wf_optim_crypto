library('xts')
library('yaml')
library('optparse')
library('tibble')
library('here')
library('tidyverse')
library('roll')
library('R6')

source("master//rcode//logic//strategy.r")
source("master//rcode//logic//helpers//data_helper.r")
#setwd("c:\\todo-p\\UW\\Master-Thesis")
#read YAML params
#params <- yaml::read_yaml("params.yaml")
#params$`01_select`$currency

param.path.str <- "master//rcode//logic//strategy_param.yaml"

strat.params.yaml <- yaml::read_yaml(param.path.str)

dvc.params.yaml <- yaml::read_yaml("params.yaml")

#strategy.obj <- Strategy$new(param.path.str = param.path.str)

Sys.setlocale("LC_TIME", "English")

parser <- OptionParser()

parser <- add_option(parser, "--inputfile", action="store_true", type="character" ,
                     default=TRUE, help="Print extra output [default]")
parser <- add_option(parser,  "--outputfile", action="store_true",type="character" , default="" , help="Print little output")

opt <- parse_args(parser)

print(opt)

#input.csv.df <- read.csv(opt$inputfile)
#setwd("C:\\todo-p\\UW\\Master-Thesis\\master\\")

fileout <- "master/data-wip/01_converted_to_xts.rds"

data.raw <- read_data(opt$inputfile)
#data.raw <- strategy.obj$read_data(dvc.params.yaml$general$raw_data)
#data.raw <- read.csv(dvc.params.yaml$general$raw_data, encoding = "UTF-8")
#names(data.raw)
data.xts <- transform_data(data.raw)

#df.xts <- read_file_to_xts("c:/todo-p/UW/Master-Thesis/master/data-raw/train_300klines.csv")
print("current working directory ")

getwd()

print("before saving ")

#asset.str <- dvc.params.yaml$general$asset

saveRDS(data.xts, opt$outputfile)


#currencies <- currencies[,params$`01_select`$currency]

#saveRDS(currencies, opt$outputfile)





