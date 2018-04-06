#Use Open VPN;
#vpn username: CCMRPT_UNT;
#vpn password: 5eC$7S=DagapU2Ut;


# Load packages


library(tidyverse)
library(RODBC)

# Open a connection to an ODBC database


con <- odbcConnect(dsn = "ccs2", uid = "CCMRPT_UNT", pwd = "Tasewe-E3recUBRE")

# Read tables from database into a data frame

## Create a character vector containing the names of the tables of interest


tables_dbo <- sqlTables(con, schema="dbo")$TABLE_NAME
tables_look <- sqlTables(con, schema="lookup")$TABLE_NAME

## Read in the lookup tables


for (t in tables_dbo) {
  nam <- paste0(t)               # Grab table name
  assign(nam,  sqlFetch(con, t)) # Create a df by the same name and populate it with values from table

  p <- paste0("C:\\Users\\mdl0193\\Dropbox\\RF9987 - 1115 Waiver Managing Chronically Ill Medicaid Patients Using Interventional Telehealth\\waiverEvaluation\\data\\dbo_CSV\\", t, ".csv")
  t <- get(t)
  write_csv(x = t, path = p)
  }

rm(t, nam)

# Save lookups as a CSV
#for (t in tables_look) {
 # nam <- paste0(t)               # Grab table name
#  assign(nam,  sqlQuery(con, paste("SELECT * FROM", paste0("lookup.",t)))) # Create a df by the same name and populate it with values from table
  
#  p <- paste0("C:\\Users\\mdl0193\\Dropbox\\RF9987 - 1115 Waiver Managing Chronically Ill Medicaid Patients Using Interventional Telehealth\\waiverEvaluation\\data\\lookup_csv\\", t, ".csv")
#  t <- get(t)
#  write_csv(x = t, path = p)
#}

#rm(t, nam)


# Close the connection

odbcClose(con)
rm(con)
cat("Done")

# Clean up

rm(list = ls())
cat("Done")


