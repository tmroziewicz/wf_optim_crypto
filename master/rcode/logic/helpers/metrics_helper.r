sharpe <- function(rets, freq=0) {
  return  ( sqrt(freq)* (mean(as.matrix(rets))/ sd(as.matrix(rets))  ) )
}

#function wrapping max drawdown from tseries in order to cumsum before appling that function
drawdown <- function(rets) {
  return (maxdrawdown(cumsum(rets))$maxdrawdown)
}


annualized_sd <- function(rets, freq=0) {
  return ( sqrt(freq)*sd(as.matrix(rets)) )
} 

annualized_mean <- function(rets, freq=0) {
  return ( freq*mean(as.matrix(rets)) )
} 

ir2 <- function(rets,freq=0) {
  dd <- drawdown(rets)
  mean_rets <- mean(as.matrix(rets))
  sum_rets <- sum(as.matrix(rets))
  
  part_year <- freq/length(rets)
  
  return (  
          #sqrt(freq) * (mean_rets) * abs(mean_rets) / ( sd(as.matrix(rets))*dd )  
              part_year*(sum_rets) * abs(sum_rets) / (sqrt(freq)* sd(as.matrix(rets))*dd ) 
      )
}

sortino_ratio <- function(rets,freq=0) {
  negative.rets <- rets<0
  downside_deviation <- sqrt(mean( (pmin(rets - 0, 0))^2))
   
  return  (  sqrt(freq) *  mean(rets)/ downside_deviation  ) 
}











