library('xts')
library('yaml')
library('optparse')
library('tibble')
library('here')
library('tidyverse')

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


inputfile <- "master/data-wip/05_pnl.rds"
data.pnl.xts <- readRDS(inputfile)



#calculate sharpe
#example frequ = 24*60*365

calc_sharpe <- function(rets, freq=0) {
  return  ( sqrt(freq)* (mean(as.matrix(rets))/ sd(as.matrix(rets))  ) )
}


walk_forward <- function(data.xts, train_days, test_days) {
  # Get the index of the xts object as dates
  dates <- index(data.xts)
  # Initialize an empty list to store the results
  results <- list()
  # Loop through the dates with a step size of test_days
  for (i in seq(1, length(dates), by = test_days)) {
    # Calculate the start and end index of the train period
    train_start <- i
    train_end <- i + train_days - 1
    # Check if the train period is within the data range
    if (train_end <= length(dates)) {
      # Calculate the start and end index of the test period
      test_start <- train_end + 1
      test_end <- test_start + test_days - 1
      # Check if the test period is within the data range
      if (test_end <= length(dates)) {
        # Get the start and end dates of the train and test period
        train_start_date <- dates[train_start]
        train_end_date <- dates[train_end]
        test_start_date <- dates[test_start]
        test_end_date <- dates[test_end]
        # Append the dates to the results list as a data frame
        results[[length(results) + 1]] <- data.frame(train_start_date, train_end_date, test_start_date, test_end_date)
      }
    }
  }
  # Return the results list as a single data frame
  return(do.call(rbind, results))
}


walk_forward_idx <- function(data.xts, train_days, test_days) {
  # Get the index of the xts object as dates
  dates <- index(data.xts)
  # Initialize an empty list to store the results
  results <- list()
  # Loop through the dates with a step size of test_days
  for (i in seq(1, length(dates), by = test_days)) {
    # Calculate the start and end index of the train period
    train_start <- i
    train_end <- i + train_days - 1
    # Check if the train period is within the data range
    if (train_end <= length(dates)) {
      # Calculate the start and end index of the test period
      test_start <- train_end + 1
      test_end <- test_start + test_days - 1
      # Check if the test period is within the data range
      if (test_end <= length(dates)) {
        # Get the start and end dates of the train and test period
        train_start_date <- train_start
        train_end_date <- train_end
        test_start_date <- test_start
        test_end_date <- test_end
        # Append the dates to the results list as a data frame
        results[[length(results) + 1]] <- data.frame(train_start_date, train_end_date, test_start_date, test_end_date)
      }
    }
  }
  # Return the results list as a single data frame
  return(do.call(rbind, results))
}

calculate.per.period.dates <- function(data.pnl.xts, wf.index.df) {
  asset <- "5_40"
  for (i in 1:nrow(wf.index.df)) {
    # Get the dates for the train and test period
    train_start_date <- wf.index.df[i, "train_start_date"]
    train_end_date <- wf.index.df[i, "train_end_date"]
    test_start_date <- wf.index.df[i, "test_start_date"]
    test_end_date <- wf.index.df[i, "test_end_date"]
    
    # Subset data.pct.change.xts by the train period dates
    train_data <- subset(data.pnl.xts, index(data.pnl.xts) >= train_start_date & index(data.pnl.xts) <= train_end_date)
    
    train_sum <- 10
    # Calculate the total sum of the asset column for the test period
    #test_sum <- colSums(test_data[, ])
    test_sum <- 10
    # Print the results for each period
    cat("Train period:", train_start_date, "-", train_end_date, "\n")
    cat("Test period:", test_start_date, "-", test_end_date, "\n")
    cat("Total sum of", asset, "for train period:", train_sum, "\n")
    cat("Total sum of", asset, "for test period:", test_sum, "\n")
    cat("\n")
  }
}


calculate.per.index <- function(data.pnl.xts, wf.index.df.idx) {
  asset <- "5_40"
  for (i in 1:nrow(wf.index.df)) {
    # Get the dates for the train and test period
    train_start_date <- wf.index.df.idx[i, "train_start_date"]
    train_end_date <- wf.index.df.idx[i, "train_end_date"]
    test_start_date <- wf.index.df.idx[i, "test_start_date"]
    test_end_date <- wf.index.df.idx[i, "test_end_date"]
    
    # Subset data.pct.change.xts by the train period dates
    train_data <- data.pnl.xts[train_start_date:train_end_date,] 
    
    # Subset data.pct.change.xts by the test period dates
    test_data <- data.pnl.xts[test_start_date :test_end_date,] 
    
    
    
    
    # Calculate the total sum of the asset column for the train period
    train_sum <- colSums(train_data[, ])
    #train_sum <- 10
    #Calculate the total sum of the asset column for the test period
    test_sum <- colSums(test_data[, ])
    #test_sum <- 10
    # Print the results for each period
    cat("Train period:", train_start_date, "-", train_end_date, "\n")
    cat("Test period:", test_start_date, "-", test_end_date, "\n")
    cat("Total sum of", asset, "for train period:", train_sum, "\n")
    cat("Total sum of", asset, "for test period:", test_sum, "\n")
    cat("\n")
  }
}


period.per.day.int <- 1440
train.days.int <- 2
test.days.int <- 1

wf.index.df <- walk_forward(data.pnl.xts,train_days = period.per.day.int * train.days.int, test_days = period.per.day.int * test.days.int)

wf.index.df.idx <- walk_forward_idx(data.pnl.xts,train_days = period.per.day.int * train.days.int, test_days = period.per.day.int * test.days.int)


calculate.per.period(data.pnl.xts, wf.index.df)
calculate.per.index(data.pnl.xts, wf.index.df.idx)

apply.array.as.df <- function(data.arr,colToAdd=c(),prefix="train_" ) {
  df <- data.frame(t(c(colToAdd, data.arr)))
  colnames(df) <- paste(prefix,c(names(colToAdd),names(sharpe.array)),sep="")
  return(df)
}


sharpe.wf.list <- list()
#iterate through each index genereated in previous 
for (i in 1:nrow(wf.index.df.idx)) {
  #print(wf.index.df.idx[i, "train_start_date"])
  train_start_date <- wf.index.df.idx[i, "train_start_date"]
  train_end_date <- wf.index.df.idx[i, "train_end_date"]
  test_start_date <- wf.index.df.idx[i, "test_start_date"]
  test_end_date <- wf.index.df.idx[i, "test_end_date"]

  train.data.xts <- data.pnl.xts[train_start_date:train_end_date,]
  
  test.data.xts <- data.pnl.xts[test_start_date:test_end_date,]  
  
  #apply(train.data.xts,2,calc_sharpe,24*60*365)
  #TODO still need to pass this as argument or parametrs : 
  freq =   24*60*365

  
#  data.list <- list("train"=train.data.xts, "test"=test.data.xts)
  
  data.list <- list("train"=list("data"=train.data.xts, "start_date"=train_start_date, "end_date"=train_end_date ),
                    "test"=list("data"=test.data.xts, "start_date"=test_start_date, "end_date"=test_end_date ))
  
  #data.dates.list <- list ("train"= )
  #for (data.index in names(data.list)) {
  #  #print(data.list[[data.index]][['start_date']])
  #}
  
  
  fun.list <- list(sum=NULL,calc_sharpe=freq,sd=NULL )

    #go through different function which should be applied
    for (k in names(fun.list)) {
      arg <- fun.list[[k]]

      stats.train.test.list <- list()
      #go through train test and apply each function 
      for (data.index in names(data.list)) {
        #print(data.index)
        current.data <- data.list[[data.index]][['data']]
        start_date <- data.list[[data.index]][['start_date']]
        end_date <- data.list[[data.index]][['end_date']]
        
        

        if(is.null(arg)) {
          stats.array <- apply(current.data,2,k)  
        } else {
          stats.array <- apply(current.data,2,k, arg)  
        }
        
        stats.df <- apply.array.as.df(stats.array, c("stat"=k, "start"=start_date,"end"=end_date ), prefix=paste(data.index,"_",sep="")
        stats.train.test.list <- append(stats.train.test.list, list(stats.df))
      }
      #end of iteration through dataset   
      
      stat.per.data.df <- do.call(cbind,stats.train.test.list)
      
      sharpe.wf.list <- append(sharpe.wf.list, list(stat.per.data.df))    
      
    }
    
    #end of iteration through functions  

}



sharpe.wf.df <- do.call(rbind, sharpe.wf.list)
sample.df <- data.frame(a = c(1,2,3,4,5), b=c(6,7,8,9,10))

#period.sum(c(1,2,3,4,5), INDEX = c(1,3,2,4))




#this is one way to calcualte the wf statictis : rolling with moving window by 
data.roll.xts <- rollapply(data.pnl.xts,width = period.per.day.int * train.days.int,by=1442, colSums)
data.roll.wf.xts <- na.omit(data.roll.xts)
data.array <- index(data.roll.xts)

data.array[!is.na(data.roll.xts$`5_40`)]

data.roll.xts[,]

#rollapply(c(1,2,3,4,5), width = 3, sum)

metrics.df <- readRDS("master//data-wip//07_wf_metrics.rds")

wf.sharpe.df <- metrics.df  %>%  filter(trainstat =="calc_sharpe") %>% select (-1:-3) %>% select ( starts_with("train"))

#colnames(wf.sharpe.df)[max.col(wf.sharpe.df, ties.method = "first")]

#max.col(wf.sharpe.df, ties.method = "first")

#which.max(wf.sharpe.df[1,])

#wf.sharpe.df[2,which.max(wf.sharpe.df[2,])] 


lapply.result<- apply(wf.sharpe.df,1,function(x) which.max(x))

max.values <- sapply(1:nrow(wf.sharpe.df), function(i) wf.sharpe.df[i,lapply.result[i]]) 

max.names <- colnames(wf.sharpe.df)[max.col(wf.sharpe.df, ties.method = "first")]

max.sharpe.df <- data.frame(unique(metrics.df$trainstart), unique(metrics.df$trainend), max.values, max.names )




