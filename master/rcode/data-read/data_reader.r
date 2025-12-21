
get_xts <- function(data, timestampcol="timestamp") {
  stopifnot(is.tibble(data))
  #this need to be fixed insteda of hardcoded take column, currently not sure how to 
  # this does not return integer just next dataframe class(coredata(df[,1]))
  return  (xts(data[,-1], as_datetime(data[,timestampcol][[1]]) ))
}


read_file_to_xts <- function(file.csv.str) {

  #convert to tibble 
  df.tbl <- as.tibble(read.csv(file.csv.str))
  
  #convert it from row based to column based so each asset in separate column 
  df.tbl  %>% select(timestamp, Asset_ID, Close) %>%  spread( Asset_ID, Close)  ->  dfwide.tbl
  
  #replace null with last observed 
  dfwide.tmp.tbl <- na.locf(dfwide.tbl, na.rm = FALSE)
  
  dfwide.tmp.tbl %>% fill(everything(), .direction = "down") %>% fill(everything(), .direction = "up") -> dfwide.tmp.tbl
  
  #drop column 13 which 
  dfwide.tmp.tbl <- dfwide.tmp.tbl[,-ncol(dfwide.tmp.tbl)]
  
  #chart_Series(get_xts(dfwide[,c('timestamp','13')]))
  
  print( paste( " number of rols " , nrow(dfwide.tmp.tbl) , " number of cols " , ncol(dfwide.tmp.tbl)        ))
  
  print("Column names ")
  
  print(colnames(dfwide.tmp.tbl))
  
  print(head(dfwide.tmp.tbl))
  
  print(tail(dfwide.tmp.tbl))
  
  #check if null present 
  print( paste( " number of nulls " , sum(is.na(dfwide.tmp.tbl))))

  return (get_xts(dfwide.tmp.tbl))
}

