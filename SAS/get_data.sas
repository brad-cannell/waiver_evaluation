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

libname waiver "C:\Users\mbc0022\Dropbox\Research\
RF9987 - 1115 Waiver Managing Chronically Ill Medicaid Patients Using Interventional Telehealth\
waiverEvaluation\data";

proc sql;
	CREATE TABLE waiver.patient AS 
		SELECT * 
			FROM ccs.Patient;
quit;

** OR **;

data waiver.patient;
	set ccs.Patient;
run;

* View metadata;
proc contents data = waiver.patient;
run;

* NOTE: Data/time variables are read-in as character variables. Need to use 
* informats.

* =========================================================================== ;

* Lookup tables;

* Column B of the codebook is labeled "Schema".
* Tables with a "dbo" schema are data tables. Tables with a "lookup" schema
* are lookup tables. Not all dbo tables have corresponding lookup tables;

* To use a lookup table, first read-in a data table that has a corresponding
* lookup table;

* Lookup tables are variable-specific, not table-specific.;
* For example, in the Patient table, the variable SourceAgencyEMRId;
proc sql;
	CREATE TABLE waiver.ability_to_hear AS 
		SELECT * 
			FROM lookup.AbilityToHear;
quit;

proc print data = waiver.ability_to_hear;
run;

* Now the lookup table is in SAS and available to use. However, I don't know
* where to use this particular variable. For demonstration purposes only, I'm
* going to pretend that these values meaningfully align with the values of 
* the variables "TrackerUrgent" in waiver.patient;

* To merge the lookup table with the data table;
proc sql;
	CREATE TABLE waiver.patient2 AS
		SELECT patient.*,
			   ability_to_hear.name 
			FROM waiver.patient, 
				 waiver.ability_to_hear
			WHERE patient.trackerurgent = ability_to_hear.id;
quit;

* This sort of works.
* Need a better example variable.
* Also, doesn't keep any variables without a match.
















