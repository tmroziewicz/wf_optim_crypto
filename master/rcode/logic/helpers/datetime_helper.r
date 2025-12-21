##how many periods is in 24 hours 
#params in mins
#current.time.frequency in min 
calc_frequency_per_day <- function(current.time.frequency =0  ) {
    return (1440/current.time.frequency )
}

downsample.xts <- function(data.xts, frequency=0) {
    return(data.xts[endpoints(data.xts,"minutes",k = frequency)])
}