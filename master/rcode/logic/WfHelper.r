library('xts')
library('yaml')
library('R6')
library('tseries')
library('PerformanceAnalytics')

source("master//rcode//logic//helpers//data_helper.r")
source("master//rcode//logic//helpers//metrics_helper.r")


WfHelper <- R6Class(
  "WfHelper",
  public = list(
    # Initialize the fields

    #this should not contain name of parmeters otehrwise it will be not general 
    parameters = list(),
    
    params.yaml = NULL,
    
    #train lenght days
    train.length = 0,
    
    #test lenght days
    test.length = 0,
    
    
    # Define the constructor
    initialize = function(param.path.str) {
      self$params.yaml <- yaml::read_yaml(param.path.str)
    }, 
    
    
    calculate.indexes = function(data.xts, train_days, test_days) {
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
    },
    
    calculate.metrics = function(data.pnl.xts, wf.indexes.df,  metrics.list, freq.per.day=0) {
      
      sharpe.wf.list <- list()
      
	  #iterate through each index genereated in previous step
      for (i in 1:nrow(wf.indexes.df)) {
        #print(wf.index.df.idx[i, "train_start_date"])
        train_start_date <- wf.indexes.df[i, "train_start_date"]
        train_end_date <- wf.indexes.df[i, "train_end_date"]
        test_start_date <- wf.indexes.df[i, "test_start_date"]
        test_end_date <- wf.indexes.df[i, "test_end_date"]
        
        train.data.xts <- data.pnl.xts[train_start_date:train_end_date,]
        
        test.data.xts <- data.pnl.xts[test_start_date:test_end_date,]  
        
        #construct list  of lists   key which is name of data set and entry which contains actaul data and start and end date
        data.list <- list("train"=list("data"=train.data.xts, "start_date"=train_start_date, "end_date"=train_end_date ),
                          "test"=list("data"=test.data.xts, "start_date"=test_start_date, "end_date"=test_end_date ))
        
        
        freq.annual <- 365*freq.per.day
        fun.list <- list(sum=NULL,sharpe=freq.annual,annualized_sd=freq.annual, annualized_mean=freq.annual, drawdown=NULL, ir2=freq.annual ,  sortino_ratio=freq.annual, kurtosis=NULL, skewness=NULL )
        
        #go through different function which should be applied
        for (k in names(fun.list)) {
          arg <- fun.list[[k]]
          
          stats.train.test.list <- list()
        
   		  #go through train test and apply each function 
          for (data.index in names(data.list)) {
          			
            current.data <- data.list[[data.index]][['data']]
            start_date <- data.list[[data.index]][['start_date']]
            end_date <- data.list[[data.index]][['end_date']]

            if(is.null(arg)) {
              stats.array <- apply(current.data,2,k)  
            } else {
              stats.array <- apply(current.data,2,k, arg)  
            }
            
            stats.df <- apply.array.as.df(stats.array, c("stat"=k, "start"=start_date,"end"=end_date ), prefix=paste(data.index,"_",sep=""))
            stats.train.test.list <- append(stats.train.test.list, list(stats.df))
          }
          #end of iteration through dataset   
          
          stat.per.data.df <- do.call(cbind,stats.train.test.list)
          
          sharpe.wf.list <- append(sharpe.wf.list, list(stat.per.data.df))    
          
        }
        
        #end of iteration through functions  
        
      }
      
      
      
      sharpe.wf.df <- do.call(rbind, sharpe.wf.list)      
      return(sharpe.wf.df)
    },
    
    get.trg.rets = function(data.pnl.xts, positions.xts,max.stat.df,src.data.name.str,  trg.data.name.str,  stats.to.chooose.str) {
      
      
      col.ret <- "return"
      result.list <- list()
      
      for( i in 1:nrow(max.stat.df)) {
        
        start.int <-as.numeric(as.character( max.stat.df[i,paste0(trg.data.name.str,"start")]))
        end.int <-  as.numeric(as.character(max.stat.df[i,paste0(trg.data.name.str,"end")]))
        
        selected_col <-  gsub(src.data.name.str,"", max.stat.df[i,'selected_col'])
        
        wf.step.xts <- data.pnl.xts[start.int:end.int, selected_col  ]

        colnames(wf.step.xts)[1] <- col.ret

        wf.step.xts$positions <- positions.xts[start.int:end.int, selected_col  ]
        
        wf.step.xts$test_start <- start.int
        
        wf.step.xts$test_end  <- end.int
        
        result.list <- append(result.list, list(wf.step.xts))
		
      }
      
      result.df <- do.call(rbind, result.list)
      result.xts <- merge.xts(result.df, positions.xts$Asset, join="left")
      result.xts <- merge.xts(result.xts, getLogReturns(positions.xts$Asset), join="left")
      
      colnames(result.xts)[(ncol(result.xts)-1):ncol(result.xts)] <- c("Asset","Asset_returns")      
      return (result.xts)
    }

  )
)