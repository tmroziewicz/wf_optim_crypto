library('xts')
library('yaml')
library('optparse')
library('tibble')
library('here')
library('tidyverse')
library('R6')

source("master//rcode//logic//strategy.r")
source("master//rcode//logic//WfHelper.r")

Sys.setlocale("LC_TIME", "English")

parser <- OptionParser()

parser <- add_option(parser, "--inputfile", action="store_true", type="character" ,
                     default=TRUE, help="Print extra output [default]")

parser <- add_option(parser,  "--outputfile", action="store_true",type="character" , default="" , help="Print little output")

parser <- add_option(parser,  "--indexes", action="store_true",type="character" , default="" , help="Print little output")

opt <- parse_args(parser)

metrics.df <- readRDS(opt$inputfile)

dvc.params.yaml <- yaml::read_yaml("params.yaml")

stats.to.chooose <- dvc.params.yaml$general$performance_stat

metrics.data.df <- metrics.df  %>%  filter(.data[["train_stat"]] ==stats.to.chooose) %>% select (-1:-3) %>% select ( starts_with("train"))


train.test.start.end.df <- metrics.df  %>%  filter(train_stat ==stats.to.chooose) %>% select ( train_start,  train_end, test_start, test_end)

lapply.result<- apply(metrics.data.df,1,function(x) which.max(x))

selected_value <- sapply(1:nrow(metrics.data.df), function(i) metrics.data.df[i,lapply.result[i]]) 

selected_col <- colnames(metrics.data.df)[max.col(metrics.data.df, ties.method = "first")]

max.stat.df <- data.frame(selected_value, selected_col )

max.stat.df <- cbind(train.test.start.end.df, max.stat.df)

saveRDS(max.stat.df, opt$outputfile)
