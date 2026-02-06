library('xts')
library('yaml')
library('optparse')
library('tibble')
library('here')
library('tidyverse')
library('R6')
library('lubridate')

source("master//rcode//logic//strategy.r")
source("master//rcode//logic//helpers//data_helper.r")

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

data.raw <- read_data(opt$inputfile)
data.xts <- transform_data(data.raw)
print("current working directory ")
getwd()
print("before saving ")
saveRDS(data.xts, opt$outputfile)




