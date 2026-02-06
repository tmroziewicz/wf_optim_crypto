apply.array.as.df <- function(data.arr,colToAdd=c(),prefix="train_" ) {
  df <- data.frame(t(c(colToAdd, data.arr)))
  colnames(df) <- paste(prefix,c(names(colToAdd),names(data.arr)),sep="")
  return(df)
}

getLogReturns <- function (dataInXts)  {
  dataOutXts <-   log(dataInXts) -log(lag.xts(dataInXts )) 
  return(dataOutXts)
}


read_data = function(file.path.str) {
  return (data.table::fread(file.path.str, stringsAsFactors = FALSE, encoding = "UTF-8"))
}

transform_data = function(data.df){

  #convert to tibble 
  df.tbl <- as_tibble(data.df)
  
  #convert it from row based to column based so each asset in separate column 
  df.tbl  %>% select(timestamp, Asset_ID, Close) %>%  spread( Asset_ID, Close)  ->  dfwide.tbl
  
  #replace null with last observed 
  dfwide.tmp.tbl <- na.locf(dfwide.tbl, na.rm = FALSE)
  
  dfwide.tmp.tbl %>% fill(everything(), .direction = "down") %>% fill(everything(), .direction = "up") -> dfwide.tmp.tbl

  dfwide.tmp.tbl <- dfwide.tmp.tbl[,-ncol(dfwide.tmp.tbl)]
   
  print( paste( " number of rols " , nrow(dfwide.tmp.tbl) , " number of cols " , ncol(dfwide.tmp.tbl)        ))
  
  print("Column names ")
  
  print(colnames(dfwide.tmp.tbl))
  
  print(head(dfwide.tmp.tbl))
  
  print(tail(dfwide.tmp.tbl))
  
  #check if null present 
  print( paste( " number of nulls " , sum(is.na(dfwide.tmp.tbl))))
  
  return (xts(dfwide.tmp.tbl[,-1], as_datetime(dfwide.tmp.tbl[,"timestamp"][[1]])) )
  
}

