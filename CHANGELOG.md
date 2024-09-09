# Changelog

All notable changes to pg collector will be documented in this file.


#  v1.1 
Create the script backbone to supprt HTML and HTML navigatation table .      
#  v1.2 
Add date to the HTML report file name and add report run date .              
#  v1.3 
Add the DB name to the HTML report file name .                                
#  v1.4 
Rename the script name to pg_collector.sql  .                                
#  v1.5 
Add the following sections vacuum_Statistics,Extensions, Memory_setting     
and pg_stat_statements_extension .                                           
#  v1.6 
Add the following sections Users , Roles , schema and Tablespaces Info .    
#  v1.7 
Add the following sections table Access Profile, Index Access Profile,      
Fragmentation (Bloat), DB UP TIME and Unused_Indexes Info .                   
#  v1.8 
Add the following sections Toast Tables Mapping and                         
change the report location to /tmp directory .                              
#  v1.9 
Add new section for replication slots .                                       
#  v2   
Add new section for Long_running_queries_transactions and                   
add PG Hostname / PG RDS ENDPOINT in the report .                          
#  v2.1 
Better view for objects size, inclding toast tables in their relations .     
#  v2.2 
Add new sections for Orphaned prepared transactions and  check for 
PK or FK columns that are using  numeric or integer data_type.           
#  v2.3 
Add new sections for public Schema and invalid indexes                      
#  v2.4 
Replace Long_running_queries_transactions with active_session_monitor       
#  v2.5 
Add new section for Default access privileges                               
#  v2.6 
Add new section for pgaudit_extension,unlogged_tables and access_privileges 
#  v2.7 
Add new section for ssl and Background processes
#  v2.8
```
 1- Add new section for Large objects
 2- Add new section for Partition tables 
 3- Update XID section by adding more queries to help in Transaction ID Wraparound investigation  
 4- Add new section for MXID (Multixact IDs) 
 5- Add cache hit ratio To the Memory setting section 
 6- Add new section for Temp tables 
 7- Add new section for FK without index
 8- Add new section for pg_shdepend 
 9- Add new section for sequences and sequence wraparound
 10- Add huge_pages parameter value to the Memory setting section 
 11- Add i.indisunique (If true, this is a unique index) to the unused indexes section 
 12- Add new section for pg_hba.conf (view pg_hba_file_rules)
 13- Add new section for Duplicate indexes
 14- update Tablespaces_Info section
 15- Print the Report name and location in the terminal
```
#  v2.9
```
1- Add HTML <details> Tag to each section so the user can open and close it on demand, it is closed by By default , this will help make the report more readable and Easy to navigate when the DB have a lot of objects.
2- Add new section for Functions statistics .
3- Change active session monitor section name to session/connection info and add more information .
4- Fix link issue (FK_without_index) .
5- Add log_temp_files to Temp tables section .
6- Add temp_buffers to Memory setting section .
7- Enhance the following sections  (tables without auto vacuum  , tables without auto analyze  , tables without auto analyze, auto vacuum, vacuum and analyze) .
8- Change Replication_slot section name to Replication and add Replication slot lag and Replication Parameters .
9- PG collector will be able to detect and report the PG server type and the database Role .
Note: Thanks to Jeremy Schneider as he the author of this part of the code .
PG server type :
RDS PG = RDS- < PG_Version >  
Aurora PG =  Aurora- < PG_Version > - < Aurora_Version >
PostgreSQL Community = PG- < PG_Version > 

Database Role :
Primary/writer DB (Read write)
Standby/Reader DB (Read Only)
10- Add new section for DB Load (wait events stats,Locks ,pg_stat_* views)
11- Add new section for Triggers .
12- Add new section for pg_config .
13- https://github.com/awslabs/pg-collector/issues/1 requested by thottr@

    13-1. Add queryid to the pg_stat_statements's queries ( pg_stat_statements extension section)
    13-2. Add Top SQL order by shared blocks read (physical reads)  ( pg_stat_statements extension section)
    13-3. Add Top 50 Tables by total physical reads and total physical reads percent to Table Access Profile section
    13-4. Add Top 50 indexes by physical reads and physical reads percent to Index Access Profile section
     

```
#  v3
```
1- Enhance the where condition in the following sections “current running vacuum process“and ”current running autovacuum process“.
2- Fix typos, Thanks to Vikas Gupta for highlighting them .
3- Upade percent_towards_wraparound's query with 2^31-1000000 .
4- Add reserved connections parameters info to the Connections Info section .
5- Add DB/username/status/Connections count to the Connections Info section .
6- Add objects list and count in each schema to the schema info section .
7- Update the Toast Tables Mapping's sql to order the toast by the size and add note about toast OID wraparound.
```

#  v3.1
```
1- The script should display the message "Report Generated Successfully" upon successful completion and relocate the report file name and location information to the end of the script..
2- Add a new section for Amazon Aurora PostgreSQL.
3- Add a new section for Invalid databases.
4- Implement a check for the pg_stat_statements extension. If the extension is not installed, the script should print the message "pg_stat_statements extension is not installed" in the report, instead of displaying the errors "ERROR: relation "pg_stat_statements_info" does not exist" or "ERROR: relation "pg_stat_statements" does not exist".

```