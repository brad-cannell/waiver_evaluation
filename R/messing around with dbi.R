library(odbc)


con <- DBI::dbConnect(odbc::odbc(),
                      driver = "ODBC Driver 13 for SQL Server",
                      server = "10.10.1.198",
                      database = "Navigator_UNT",
                      uid = "CCMRPT_UNT",
                      pwd = "Tasewe-E3recUBRE")


tables_look<-dbListTables(con, schema="lookup")
tables_dbo<-dbListTables(con, schema="dbo")

dbFetch((dbSendQuery(con, "SELECT * FROM lookup.EventType")))

dbDisconnect(con) 