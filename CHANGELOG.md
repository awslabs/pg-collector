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
Add the following sections Tabel Access Profile, Index Access Profile,      
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