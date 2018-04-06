---
title: "Descriptives for Waiver Group"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

```{r, message=FALSE}
library(plyr)
library(dplyr)
library(sjPlot)
```


## Data Manipulation
First we need to read in and clean the data on patient demographics and hospitalizations 

```{r }

setwd("C:\\Users\\mdl0193\\Dropbox\\RF9987 - 1115 Waiver Managing Chronically Ill Medicaid Patients Using Interventional Telehealth\\waiverEvaluation\\data\\dbo_CSV")

#read raw data
demos<-read.csv("patient.csv")
hospital<-read.csv("HospitalizationEvent.csv")

demos<-mutate(demos, PatientId=Id)


#clean duplicates
demos<-distinct(demos,Id,.keep_all=TRUE)


```


Patients could have had multiple different types of hospitalization events over the study period. We need to first seperate hospital data by visit type then remove dupes. Currently unsure what to do about those with missing event types. 

```{r}
hosp<-filter(hospital, EventTypeId==1)
obser23<-filter(hospital, EventTypeId==2)
outp<-filter(hospital, EventTypeId==3)
er<-filter(hospital, EventTypeId==4)
miss<-filter(hospital, is.na(EventTypeId))

hosp<-distinct(hosp,PatientId,.keep_all=TRUE)
obser23<-distinct(obser23,PatientId,.keep_all=TRUE)
outp<-distinct(outp,PatientId,.keep_all=TRUE)
er<-distinct(er,PatientId,.keep_all=TRUE)
```


We also need to filter out "planned" readmissions (cancer treatments, etc).
```{r}
hosp<-filter(hosp, !(AdmissionReasonId %in% c(19,28,29,36,37) ))
```

Then we create indicators for hospitalization event type, and merge them back into the patient demographic data.

```{r}
#add variable for "in this dataframe"
hosp<-mutate(hosp, inpatient=1)
obser23<-mutate(obser23, observation=1)
er<-mutate(er, er.visit=1)
outp<-mutate(outp, outpatient=1)
miss<-mutate(miss, missing=1)

#drop everything but previously created variables and patientid

hosp<-select(hosp, c(PatientId,inpatient))
obser23<-select(obser23, c(PatientId,observation))
er<-select(er, c(PatientId,er.visit))
outp<-select(outp, c(PatientId,outpatient))
miss<-select(miss, c(PatientId,missing))

#merge indicators back into patient file
joins<-list(hosp,obser23,er,outp,miss)
merged<-join_all(joins, by="PatientId",type="full")
merged<-distinct(merged)
for.descrip<-left_join(demos,merged,by="PatientId")

for.descrip<-mutate(for.descrip,inpatient=replace(inpatient, is.na(inpatient), 0))
for.descrip<-mutate(for.descrip,observation=replace(observation, is.na(observation), 0))
for.descrip<-mutate(for.descrip,er.visit=replace(er.visit, is.na(er.visit), 0))
for.descrip<-mutate(for.descrip,outpatient=replace(outpatient, is.na(outpatient), 0))
for.descrip<-mutate(for.descrip,missing=replace(missing, is.na(missing), 0))

make.table<-select(for.descrip, c(Gender, MaritalStatus, Race, inpatient,observation,er.visit,outpatient))
```


## Demographic and Hospitalization Frequencies

```{r, echo=FALSE}
sjt.frq(make.table)

```

