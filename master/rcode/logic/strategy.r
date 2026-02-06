library('xts')
library('yaml')
library('quantmod')
library('R6')

source("master//rcode//logic//helpers//data_helper.r")
Strategy <- R6Class(
  "Strategy",
  public = list(
  
    # Initialize the fields
    position.type.int = NULL,
    fee_int = NULL,
    ma_cutoff_int = 0,
    #this should not contain name of parmeters otehrwise it will be not general 
    parameters = list(),
    params.yaml = NULL,
    
    # Define the constructor
    initialize = function(param.path.str) {
	
      self$params.yaml <- yaml::read_yaml(param.path.str)
        
      self$position.type.int <- self$params.yaml$strategy$position.type.int
      self$fee_int <-self$params.yaml$strategy$fee_int
      self$ma_cutoff_int <-self$params.yaml$strategy$ma_cutoff_int
      
      #do mapping between yaml and internal params (this is not really needed?)
      #it separate type of configuration from later usage in the code, 
      #params could be stored in db instead of yaml
      self$parameters[['ma_periods_array']] <- self$params.yaml$strategy$ma_periods_array
      
    },
    
    
    #do all pre-calculation needed for further processing 
    #Example: calculate ma, bands, 
    precalculate = function(data.xts){   

      print(self$parameters[['ma_periods_array']])
      period.array <- self$parameters[['ma_periods_array']]
      
      result.xts <- xts(coredata(data.xts), 
                        index(data.xts))
      
      current.period.int <- 10
      
      for ( i in 1:length(period.array)) {
        print(i)
        print(paste("Current MA period --- " , period.array[i]))
        
        current.ema.xts <- EMA(na.locf(data.xts, na.rm = FALSE),
                               period.array[i])
        
        # put missing values whenever the original price is missing
        current.ema.xts[is.na(data.xts)] <- NA  
        
        #merge result with newly calculated moving average
        result.xts <- merge.xts(result.xts,current.ema.xts)
        
      }
      
      colnames(result.xts ) <- c(c("Asset"), period.array)
      
      #get all rows starting from max period, so no NA in the dataframe 
      return(result.xts[max(period.array):nrow(result.xts),])

    },
    
    calculate.position = function(data.xts) {
      
      period.array <- self$parameters[['ma_periods_array']]
      
      message('This is array periods')
      
      message(period.array)
      
      period.groups <- split(period.array,period.array>self$ma_cutoff_int )

      fast.array <- period.groups[[1]]

      slow.array <- period.groups[[2]]
      
      result.xts <- xts(coredata(data.xts$Asset), index(data.xts))
      
      colnames.array <- c()
      
      for (  s in 1:length(slow.array)){
        
        for ( f in 1:length(fast.array)){
          slow.int <- slow.array[s]
          fast.int <- fast.array[f]
          print(paste( " slow ", slow.int, " fast ", fast.int))
          colname.str <- paste(fast.int,"_",slow.int ,sep='')
          colnames.array <- append(colnames.array, colname.str)
          slow.xts <- data.xts[, as.character(slow.int)] 
          fast.xts <- data.xts[, as.character(fast.int)]
          
          
          # calculate position when fast is over slow take long 1 , short otherwise -1
          pos.mom.xts <- ifelse(lag.xts(fast.xts) >
                              lag.xts(slow.xts),
                            1, -1)
          #temp.xts <- merge.xts(slow.xts,fast.xts,pos.mom.xts)    
          # put last position when missing
          pos.mom <- na.locf(pos.mom.xts, na.rm = FALSE)
          result.xts <- merge.xts(result.xts, pos.mom.xts)
        }
      }
      
      colnames(result.xts ) <- c(c("Asset"), colnames.array)
      return(result.xts)
    },
    
    calculate.pnl = function(positions.xts) {

      pos.mom.xts <- positions.xts[, !names(positions.xts) %in% "Asset"]
      ntrans <- abs(diff.xts(pos.mom.xts))
      ntrans[is.na(ntrans)] <- 0
      
      logRets.xts <- getLogReturns(positions.xts$Asset)
      logRets.xts$Asset[is.na(logRets.xts$Asset)] <- 0 
      
      # gross pnl
      pnl.gross.matrix <- ifelse(is.na(pos.mom.xts * drop(diff.xts(positions.xts$Asset))),
                                 0, 
                                 pos.mom.xts * drop(logRets.xts$Asset)  )
      
      pnl.gross.xts <- xts(pnl.gross.matrix , index(positions.xts))
      
      pnl.net.xts <- pnl.gross.xts - ntrans * self$fee_int
      
      return(pnl.net.xts)
    }
    
  )
)