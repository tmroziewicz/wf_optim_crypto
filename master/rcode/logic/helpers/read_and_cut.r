setwd()
source("./rcode/logic/helpers/data_helper.r")



path.data.str <- "c:\\todo-p\\UW\\S3\\seminarium\\r_seminar\\cyrpto\\data\\train.csv"
#data_csv_df <- read_data(path.data.str)

data_csv_df <- data.table::fread(path.data.str, stringsAsFactors = FALSE)

sum(data_csv_df$timestamp<=1569880740)
#1561939140  - 30/06/2019 23:59 
#1569887940  - 30/09/2019 23:59 
cut_off <- 1569887940
#trimed_df <- data_csv_df[data_csv_df$timestamp<=cut_off,]
#write.table(trimed_df, "data_20180101_20190930.csv",sep=",",row.names=FALSE,quote=FALSE)

unseen_df <- data_csv_df[data_csv_df$timestamp>=cut_off,]
write.table(unseen_df, "data_20191001_.csv",sep=",",row.names=FALSE,quote=FALSE)


#summary(unseen_df[unseen_df$Asset_ID==,])
unseen_df %>% head(5000) %>% group_by(Asset_ID) %>% summarize(s=mean(Open))
nrow(trimed_df)