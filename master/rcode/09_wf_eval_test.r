library('xts')
library('yaml')
library('optparse')
library('tibble')
library('here')
library('tidyverse')
library('lubridate')
library('R6')

source("master/rcode/logic/strategy.r")
source("master/rcode/logic/WfHelper.r")
source("master/rcode/logic/helpers/datetime_helper.r")
source("master/rcode/logic/helpers/metrics_helper.r")

calculate_statistic <- function(data.in, scaling=0) {
  sharpe.dbl <- sharpe(data.in, freq = scaling)
  ir2.dbl <- ir2(data.in, freq = scaling)
  stdev <- sd(data.in)
  sortino_ratio.dbl <- sortino_ratio(data.in, freq = scaling)
  start.str <- paste("start",as.character(first(index(data.in))))
  end.str <- paste("end",as.character(last(index(data.in))))
  
  first(index(data.in))
  print(sharpe)
  
  return (
    data.frame(sharpe_ratio=sharpe.dbl, stdev=stdev, ir2 = ir2.dbl, sortino_ratio = sortino_ratio.dbl, start= start.str, end = end.str )
  )
}


Sys.setlocale("LC_TIME", "English")

parser <- OptionParser()

parser <- add_option(parser, "--inputfile", action="store_true", type="character" ,
                     default=TRUE, help="Print extra output [default]")

parser <- add_option(parser, "--pnlfile", action="store_true", type="character" ,
                     default=TRUE, help="Print extra output [default]")

parser <- add_option(parser, "--metricsfile", action="store_true", type="character" ,
                     default=TRUE, help="Print extra output [default]")

parser <- add_option(parser,  "--outputfile", action="store_true",type="character" , default="" , help="Print little output")


parser <- add_option(parser,  "--downsampled", action="store_true",type="character" , default="" , help="Print little output")

parser <- add_option(parser,  "--positions", action="store_true",type="character" , default="" , help="Print little output")


opt <- parse_args(parser)


#timeframe<-20

max.stat.df  <- readRDS(opt$inputfile)

data.pnl.xts <- readRDS(opt$pnlfile)

downsampled.xts <- readRDS(opt$downsampled)

metrics.df <- readRDS(opt$metricsfile)

positions.xts <- readRDS(opt$positions)

dvc.params.yaml <- yaml::read_yaml("params.yaml")

dvc.yaml <- yaml::read_yaml("dvc.yaml")

freq.per.day.int <-calc_frequency_per_day(dvc.params.yaml$general$tfmin)

message(paste("frequency in 09 eval:",freq.per.day.int))

WfHelper.obj <- WfHelper$new(param.path.str = dvc.params.yaml$wf$param.path)

data.index <- "train_"

stats.to.chooose <- dvc.params.yaml$general$performance_stat

head(data.pnl.xts)


result.df <- WfHelper.obj$get.trg.rets(data.pnl.xts , positions.xts, max.stat.df =max.stat.df, 
                          src.data.name.str = "train_" , 
                          trg.data.name.str="test_", 
                          stats.to.chooose = stats.to.chooose  )

result.df$rowname <- seq(nrow(result.df))+as.integer(result.df$test_start[1])-1

wf.stats.list <- list()

trg.data.name.str = "test_"
src.data.name.str = "train_"

for( i in 1:nrow(max.stat.df)) {
  
  start.int <- max.stat.df[i,paste0(trg.data.name.str,"start")]
  end.int <- max.stat.df[i,paste0(trg.data.name.str,"end")]
  
  max.col.name <-  gsub(src.data.name.str,"", max.stat.df[i,'selected_col'])
  
  message(max.col.name)
  trg.col.name <- paste(trg.data.name.str, max.col.name ,sep="")  
  
  #from metrics table select only records which are equal to searched statistics , and are equal to test period start 
  stat_value <- metrics.df %>% filter(train_stat==stats.to.chooose & test_start == start.int ) %>% select(any_of(trg.col.name)) %>% as.double

  wf.step.stats <- cbind(max.stat.df[i,], stat_value)
  wf.stats.list <- append(wf.stats.list, list(wf.step.stats))
  
}

wf.stats.df <- do.call(rbind, wf.stats.list)

print(wf.stats.df)

saveRDS(result.df, opt$outputfile)

#================================== Calculate dates to be clipped ========================

class(dvc.params.yaml$wf$day_clip)
wf.start.date <- ceiling_date(first(index(downsampled.xts)) + days(dvc.params.yaml$wf$day_clip_front),unit = "day")

wf.end.date <- ceiling_date(last(index(downsampled.xts)) - days(dvc.params.yaml$wf$day_clip_back),unit = "day")

print("First date in data result.df")
print(first(index(result.df)))
print("Last date in data result.df")
print(last(index(result.df)))

print("First date in data downsampled.xts")
print(first(index(downsampled.xts)))
print("Last date in data downsampled.xts")
print(last(index(downsampled.xts)))

range.dates.df <- data.frame(datadesc = "WFclipped",
                          start= wf.start.date, 
                          end= wf.end.date
)

range.dates.df <- rbind(range.dates.df,data.frame(datadesc = "WFWhole",
                             start= first(index(result.df)), 
                             end= last(index(result.df)) ))


#==================================


print(range.dates.df)

date.filter.str <- paste(range.dates.df[1,]$start,range.dates.df[1,]$end, sep="/")
print(paste("Filtering date for WF clipped :", date.filter.str))
clipped.metrics.df <- calculate_statistic(result.df$return[date.filter.str], 365*freq.per.day.int)

date.filter.str <- paste(range.dates.df[2,]$start,range.dates.df[2,]$end, sep="/") 
print(paste("Filtering date for WF whole  :", date.filter.str))
full.metrics.df <- calculate_statistic(result.df$return[date.filter.str], 365*freq.per.day.int)

colnames(full.metrics.df) <- paste(colnames(full.metrics.df), "_full", sep = "")

metrics.df <- cbind(clipped.metrics.df,full.metrics.df)

print("Writing resuts to yaml")
con <- file(dvc.yaml$metrics[1], "w")
yaml::write_yaml(metrics.df, con)
close(con)

con <- file(dvc.yaml$metrics[2], "w")
yaml::write_yaml(wf.stats.df, con)
close(con)  

as.data.frame(yaml::read_yaml(dvc.yaml$metrics[2]))








