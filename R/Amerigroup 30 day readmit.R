library(plyr)
library(dplyr)
library(sjPlot)


setwd("C:\\Users\\mdl0193\\Dropbox\\RF9987 - 1115 Waiver Managing Chronically Ill Medicaid Patients Using Interventional Telehealth\\waiverEvaluation\\data")

#read raw data
data<-read.csv("amerigroup.csv")


#ICD codes to filter
pattern<-c("Z96","Z4","Z50","Z51","Z52","Z53","C","D1","D2","D3","D4")
data1<-filter(data, !(grepl(paste(pattern, collapse="|"), ADMIT_DX)))
data1<-select(data, MCAID_ID,AGE,GENDER,ADMIT_DX,ADMIT_DT,DC_DT)

data2<-data1 %>%
  group_by(MCAID_ID) %>%
  mutate(next.date = lead(ADMIT_DT, order_by=MCAID_ID)) %>%
                                                  ungroup()
 data2<-mutate(data2,time_till=as.Date(data2$next.date,format="%m/%d/%y")-as.Date(data2$DC_DT,format="%m/%d/%y"))

#
 data2<-mutate(data2,readmit=ifelse(time_till<=30 & time_till>=0,1,0))

#play around with age cut off for amerigroup to approx the age distribution of telehealth pop (mean~56), will need to age match for analysis
merged<-filter(data2,!(AGE<40))


