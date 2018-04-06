/******************************************************************************
Retrieve tables from MS SQL Database

2017-02-22

This program is just for pulling data tables down from the CCM (Waiver)
database. It should not be used for cleaning any of the individual data sets.

Prior to running this program: 
* the computer should already have an established VPN.
* the computer should already have an ODBC connection.

Useful websites:

[Accessing a Microsoft SQL Server Database from SAS on MS Windows]
(https://support.sas.com/techsup/technote/ts765.pdf)

[SQL Style Guide]
(http://www.sqlstyle.guide/)
******************************************************************************/

* Make sure the current SAS instance has either the SAS/Access Interface to
* ODBC, or SAS/Access to OLEDB, or both;
proc setinit noalias;
run;

* If you have one or both of the Access products licensed for your site, the 
* next step is to determine if the products have been installed on your 
* machine;

* From Windows Explorer, you can browse to !SASROOT\Access\Sasexe and look for 
* the following files:
* sasioodb.dll
* sasioole.dll
;

* Once the driver has been configured and the test connection is successful, 
* then you can use a LIBNAME statement to create a library within SAS:

* LIBNAME SQL ODBC DSN=’sql server’ user=sasjlb pw=pwd;

* Where 'sql server' is the name of the Data Source configured in the ODBC 
* Administrator; 

*Use Open VPN;
*vpn username: CCMRPT_UNT;
*vpn password: 5eC$7S=DagapU2Ut;


libname ccs odbc 
	dsn = "CCS" 
	user = "CCMRPT_UNT" 
	pw = "Tasewe-E3recUBRE"
	schema="dbo";

* View all tables in the database;
proc sql;
	CONNECT TO odbc(dsn = "CCS" user = "CCMRPT_UNT" pw = "Tasewe-E3recUBRE");
	CREATE TABLE all_tables AS 
		SELECT * 
			FROM connection to odbc(ODBC::SQLTables);
quit;

* Notice that not all tables have the same schema (TABLE_SCHEM). The default
* schema is dbo. This is fine for the data tables. However, the lookup tables
* have a schema of lookup. In order to access them, we will need a second
* libname statement with the schema option set to lookup;

libname lookup odbc 
	dsn = "CCS" 
	user = "CCMRPT_UNT" 
	pw = "Tasewe-E3recUBRE"
	schema = "lookup";

* After connection is established, start importing tables of interest as SAS
* data sets.

* To begin with, I'm pulling in the highlighted tables in the codebook Stacey
* sent us. The current codebook is located at:

* ~\RF9987 - 1115 Waiver Managing Chronically Ill Medicaid Patients Using 
* Interventional Telehealth\waiverEvaluation\codebook\UNT DATA Portal Key 
* Update 2.xlsx;

* Also, create a library to strore newly created SAS data sets;

libname waiver "C:\Users\mdl0193\Dropbox\RF9987 - 1115 Waiver Managing Chronically Ill Medicaid Patients Using Interventional Telehealth\waiverEvaluation\data\dbo_sas";

proc sql;
select TABLE_NAME into :dbo_name separated by '*' from work.all_tables where TABLE_SCHEM="dbo";
%let count2 = &sqlobs;
quit;

data test;
set ccs.'CoordinationTrackerCocPhysicianNotifiedReason'n;
run;

%macro dbo;
%do i = 1 %to &count2;
%let j = %scan(&dbo_name,&i,*);
data waiver.&j;
	set ccs."&j"n;
run;
%end;
%mend;

%dbo;

/*check unique ids*/
proc sort data=HospitalizationEvent out=unique nodupkey;
by patientid  ;
run;

/*
i need to figure out where the SOC date is located in the tables and see if the SOC date lines up correctly with the 
first hospitilization event (HE). Was the first HE what got them on the program?

there are only 283 unique ids in the hospitlization data compared to over 600 in the patient file... so im guessing the answer
above is no. Talk with Brad.

*/












