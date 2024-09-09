-- +-------------------------------------------------------------------------------------------------------------+
-- |  -- Script Name: pg_collector.sql                                                                           |
-- |  -- Author : Mohamed Ali                                                                                    |
-- |  -- Create Date : 16 SEPT 2019                                                                              |
-- |  -- Description : Script to Collect PostgreSQL Database Informations                                        |
-- |                   and generate HTML Report                                                                  |
-- |  -- version : V1.1 for PostgreSQL 15                                                                        |
-- |  -- Changelog : https://github.com/awslabs/pg-collector/blob/pg-collector-for-postgresql-15/CHANGELOG.md    | 
-- | Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.                                          |
-- | SPDX-License-Identifier: MIT-0                                                                              |
-- +-------------------------------------------------------------------------------------------------------------+
\H
\set filename :DBNAME-`date +%Y-%m-%d_%H%M%S`
\o /tmp/pg_collector_:filename.html
\pset footer  off
\qecho <style type='text/css'> 
\qecho body { 
\qecho font:10pt Arial,Helvetica,sans-serif;
\qecho color:Black Russian; background:white; } 
\qecho p { 
\qecho font:10pt Arial,sans-serif;
\qecho color:Black Russian; background:white; } 
\qecho table,tr,td { 
\qecho font:10pt Arial,Helvetica,sans-serif; 
\qecho text-align:center; 
\qecho color:Black Russian; background:white; 
\qecho padding:0px 0px 0px 0px; margin:0px 0px 0px 0px; } 
\qecho th { 
\qecho font:bold 10pt Arial,Helvetica,sans-serif; 
\qecho color:#16191f; 
\qecho background:#e59003; 
\qecho padding:0px 0px 0px 0px;} 
\qecho h1 { 
\qecho font:bold 16pt Arial,Helvetica,Geneva,sans-serif; 
\qecho color:#16191f; 
\qecho background-color:#e59003; 
\qecho border-bottom:1px solid #e59003;
\qecho margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;} 
\qecho h2 {
\qecho font:bold 10pt Arial,Helvetica,Geneva,sans-serif;
\qecho color:#16191f; 
\qecho background-color:White; 
\qecho margin-top:4pt; margin-bottom:0pt;}
\qecho h3 {
\qecho font:bold 10pt Arial,Helvetica,Geneva,sans-serif;
\qecho color:#16191f;
\qecho background-color:White;
\qecho margin-top:4pt; margin-bottom:0pt;} 
\qecho a { 
\qecho font:9pt Arial,Helvetica,sans-serif; 
\qecho color:#663300; 
\qecho background:#ffffff; 
\qecho margin-top:0pt; margin-bottom:0pt; vertical-align:top;} 
\qecho .threshold-critical { 
\qecho font:bold 10pt Arial,Helvetica,sans-serif; 
\qecho color:red; } 
\qecho .threshold-warning { 
\qecho font:bold 10pt Arial,Helvetica,sans-serif; 
\qecho color:orange; } 
\qecho .threshold-ok { 
\qecho font:bold 10pt Arial,Helvetica,sans-serif; 
\qecho color:green; } 
\qecho </style> 
\qecho <h1 align="center" style="background-color:#e59003" >PG COLLECTOR  V1.1 for PostgreSQL 15</h1>
\qecho <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><a href="https://github.com/awslabs/pg-collector/tree/pg-collector-for-postgresql-15" target="_blank">For more information about PG Collector, visit the project github repository</a></font><hr align="left" >
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>DB INFO</b></font><hr align="left" width="150">
\qecho <br>
\qecho 'PG Host Name / PG RDS ENDPOINT: ':HOST
\qecho <br>
\set QUIET 1
select case when count(*)=0 then 'select ''not-aurora'' as avers'
                            else 'select aurora_version() as avers'
       end as aurora_version_query
from pg_settings where name='rds.extensions' and setting like '%aurora_stat_utils%' \gset
prepare detect_aurora as :aurora_version_query;
execute detect_aurora \gset
deallocate detect_aurora;
with
  pgvers as (
    select current_setting('server_version') as v
  ), allvers as (
    select 1 priority, 'Aurora-'||v||'-'||:'avers' as version from pgvers
    where :'avers' <> 'not-aurora'
      union all
    select 2, 'RDS-'||v from pgvers, pg_settings s
    where s.name like 'rds.%'
      union all
    select 3, 'pg-'||v from pgvers
  )
select first_value(version) over (order by priority) as server_version
from allvers limit 1 \gset
select case when pg_is_in_recovery() then 'Standby/Reader DB (Read Only)' else 'Primary/writer DB (Read write)' end as standby_mode \gset
\unset QUIET
\qecho :server_version
\qecho :standby_mode
\qecho <br>
\qecho <br>
select  now () as "Date" ,pg_postmaster_start_time() as "DB_START_DATE", current_timestamp - pg_postmaster_start_time() as "UP_TIME"  ,current_database() as "DB_connected" ,current_user USER_NAME,inet_server_port() as "DB_PORT ",version()  as "DB_Version" , setting AS block_size FROM pg_settings WHERE name = 'block_size';
\qecho <br>
\qecho <br>
\l+
\qecho <br>
select * from pg_database; 
\qecho <br>
\qecho <br>
\qecho <table width="90%" border="1"> 
\qecho <tr><th colspan="4"><div align="center"><font color="#16191f"><b>INFO</b></font></div></th></tr> 
\qecho <tr> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Database_size">Database size</a></td> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#DB_parameters">DB parameters</a></td> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Transaction_ID_TXID">Transaction ID TXID (Wraparound)</a></td> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Table_Size">Table Size</a></td> 
\qecho </tr> 
\qecho <tr> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#index_Size">Index Size</a></td> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#vacuum_Statistics">Vacuum & Statistics</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Extensions">Extensions</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Memory_setting">Memory setting</a></td>
\qecho </tr> 
\qecho <tr> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#pg_stat_statements_extension">pg_stat_statements extension</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Users_Roles_Info">Users & Roles Info</a></td> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Schema_Info">schema Info</a></td> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Tablespaces_Info">Tablespaces Info</a></td> 
\qecho </tr> 
\qecho <tr> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#table_Access_Profile">Table Access Profile</a></td> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Unused_Indexes">Unused Indexes</a></td> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Index_Access_Profile">Index Access Profile</a></td> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Fragmentation">Fragmentation (Bloat)</a></td> 
\qecho </tr>
\qecho <tr>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Toast_Tables_Mapping">Toast Tables Mapping</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Replication">Replication</a></td>
\qecho <td nowrap align="center"width="25%"><a class="link"href="#sessions_info">Sessions/Connections Info</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Orphaned_prepared_transactions">Orphaned prepare transactions</a></td>
\qecho </tr>
\qecho <tr> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#PK_FK_using_numeric_or_integer_data_type">PK or FK using numeric or integer data type</a></td> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#public_Schema">public Schema</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#invalid_indexes">invalid indexes</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#default_access_privileges">Default access privileges</a></td> 
\qecho </tr>   
\qecho <tr>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#pgaudit_extension">pgaudit extension</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#unlogged_tables">Unlogged Tables</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#access_privileges">Access privileges</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#ssl">ssl</a></td>
\qecho </tr>
\qecho <tr>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#background_processes">Background processes</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Multixact_ID_MXID">Multixact ID MXID (Wraparound)</a></td> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Temp_tables">Temp tables</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Large_objects">Large objects</a></td>
\qecho </tr>
\qecho <tr>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Partition_tables">Partition tables</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#pg_shdepend">pg_shdepend</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#FK_without_index">FK without index</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#sequences">sequences</a></td>
\qecho </tr>
\qecho <tr>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#pg_hba.conf">pg_hba.conf</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Duplicate_indexes">Duplicate indexes</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#functions_statistics">Functions statistics</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#DB_Load">DB Load</a></td>
\qecho </tr>
\qecho <tr>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#triggers">Triggers</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#pg_config">pg_config</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#COPY_command_progress">COPY command progress</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Invalid_databases">Invalid databases</a></td>
\qecho </tr>
\qecho </table>
\qecho <br>
\qecho <br>
\qecho <br>
\qecho <table width="90%" border="1">
\qecho <tr><th colspan="4"><div align="center"><font color="#16191f"><b>Amazon Aurora PostgreSQL</b></font></div></th></tr>
\qecho <tr>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Aurora_version">Aurora version</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Aurora_PostgreSQL_built-in_functions">Aurora PostgreSQL built-in functions</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Aurora_db_instance_identifier">Aurora db instance identifier</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Aurora_cluster_instances">Aurora cluster instances</a></td>
\qecho </tr>
\qecho <tr>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Aurora_reader_instances-Replica_Lag">Aurora reader instances - Replica Lag</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Aurora_cluster_cache_management_(CCM)">Aurora cluster cache management (CCM)</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Aurora_global_db_status">Aurora global db status</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Aurora_wait_event_stat">Aurora wait event stat</a></td>
\qecho </tr>
\qecho <tr>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#query_plan_management">Query Plan Management (QPM)</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Aurora_dml_activity">Aurora DML activity</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#process_memory_context_usage">process memory context usage</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#aurora_stat_statements">Aurora_stat_statements</a></td>
\qecho </tr>
\qecho <tr>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#aurora_stat_plans">Aurora_stat_plans</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#logical_replication_write_through_cache">Logical replication write-through cache</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#******">******</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#******">******</a></td>
\qecho </tr>
\qecho </table>
\qecho <br>
\qecho <br>
\qecho <br>

-- +----------------------------------------------------------------------------+
-- |      - Database_size                                    -                  |
-- +----------------------------------------------------------------------------+

\qecho <a name="Database_size"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Database size</b></font><hr align="left" width="460">
SELECT pg_database.datname Database_Name , pg_size_pretty(pg_database_size(pg_database.datname)) AS Database_Size FROM pg_database;

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Transaction ID TXID                                   -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Transaction_ID_TXID"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Transaction ID TXID (Wraparound)</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
\qecho <h3>oldest xid:</h3>

SELECT max(age(datfrozenxid)) oldest_xid FROM pg_database;


\qecho <h3>oldest xid per database:</h3>

SELECT datname database_name ,age(datfrozenxid) oldest_xid_per_DB 
FROM pg_database order by 2 limit 20;


\qecho <h3>percent_towards_emergency_autovac & percent_towards_wraparound :</h3>

WITH max_age AS ( SELECT 2^31-3000000 as max_old_xid , setting AS 
autovacuum_freeze_max_age FROM pg_catalog.pg_settings 
WHERE name = 'autovacuum_freeze_max_age' ) , 
per_database_stats AS ( SELECT datname , m.max_old_xid::int , 
m.autovacuum_freeze_max_age::int , age(d.datfrozenxid) AS oldest_current_xid 
FROM pg_catalog.pg_database d JOIN max_age m ON (true) WHERE d.datallowconn ) 
SELECT max(oldest_current_xid) AS oldest_current_xid , 
max(ROUND(100*(oldest_current_xid/max_old_xid::float))) AS percent_towards_wraparound
 , max(ROUND(100*(oldest_current_xid/autovacuum_freeze_max_age::float))) AS percent_towards_emergency_autovac 
 FROM per_database_stats ;


\qecho <h3>current running autovacuum process:</h3>

SELECT datname,usename,state,query,
now() - pg_stat_activity.query_start AS duration, 
wait_event from pg_stat_activity where query ~ '^autovacuum:' order by 5;



\qecho <h3>current running vacuum process:</h3>

SELECT datname,usename,state,query,
now() - pg_stat_activity.query_start AS duration,
 wait_event from pg_stat_activity where query ~* '\A\s*vacuum\M' order by 5;


\qecho <h3>vacuum progress process:</h3>

SELECT p.pid, now() - a.xact_start AS duration, coalesce(wait_event_type ||'.'|| wait_event, 'f') AS waiting, 
  CASE WHEN a.query ~ '^autovacuum.*to prevent wraparound' THEN 'wraparound' WHEN a.query ~ '^vacuum' THEN 'user' ELSE 'regular' END AS mode, 
  p.datname AS database, p.relid::regclass AS table, p.phase, a.query ,
  pg_size_pretty(p.heap_blks_total * current_setting('block_size')::int) AS table_size, 
  pg_size_pretty(pg_total_relation_size(p.relid)) AS total_size, 
  pg_size_pretty(p.heap_blks_scanned * current_setting('block_size')::int) AS scanned, 
  pg_size_pretty(p.heap_blks_vacuumed * current_setting('block_size')::int) AS vacuumed, 
  round(100.0 * p.heap_blks_scanned / p.heap_blks_total, 1) AS scanned_pct, 
  round(100.0 * p.heap_blks_vacuumed / p.heap_blks_total, 1) AS vacuumed_pct, 
  p.index_vacuum_count,
  p.max_dead_tuples as max_dead_tuples_per_cycle,
  s.n_dead_tup as total_num_dead_tuples ,
  ceil(s.n_dead_tup::float/p.max_dead_tuples::float) index_cycles_required
FROM pg_stat_progress_vacuum p JOIN pg_stat_activity a using (pid) 
     join pg_stat_all_tables s on s.relid = p.relid
ORDER BY now() - a.xact_start DESC;



\qecho <h3>Inactive replication slots order by age_xmin:</h3>

select *,age(xmin) age_xmin,age(catalog_xmin) age_catalog_xmin 
from pg_replication_slots where active = false order by age(xmin) desc;


\qecho <h3>Active replication slots order by age_xmin:</h3>

select *,age(xmin) age_xmin,age(catalog_xmin) age_catalog_xmin 
from pg_replication_slots 
where active = true 
order by age(xmin) desc;

\qecho <h3>Invalid databases count:</h3> 
select count(*) FROM pg_database WHERE datconnlimit = '-2' ;


\qecho <h3>Invalid databases list:</h3> 
SELECT * FROM pg_database WHERE datconnlimit = '-2' ;

\qecho <h3>Orphaned prepared transactions:</h3>

SELECT gid, prepared, owner, database, age(transaction) AS ag_xmin 
FROM pg_prepared_xacts
ORDER BY age(transaction) DESC;

\qecho <h3>MAX XID held:</h3>
SELECT
(SELECT max(age(backend_xmin)) FROM pg_stat_activity) as oldest_running_xact,
(SELECT max(age(transaction)) FROM pg_prepared_xacts) as oldest_prepared_xact,
(SELECT max(age(xmin)) FROM pg_replication_slots) as oldest_replication_slot,
(SELECT max(age(backend_xmin))FROM pg_stat_replication)as oldest_replica_xact;


--\qecho <h3>XID Rate:</h3>


--SELECT max(age(datfrozenxid)) as xid1 FROM pg_database \gset 
--select pg_sleep(60);
--SELECT max(age(datfrozenxid)) as xid2 FROM pg_database \gset 
--select txid_current() current_txid \gset
     

--select (select :xid2 - :xid1)as XID_Rate,(2000000000-:current_txid) as Remaining_XIDs,
--(2000000000-:current_txid)/ ( select :xid2 - :xid1 ) /10/3600 hours_before_wraparound_prevention,
--(2000000000-:current_txid)/ ( select :xid2 - :xid1 ) /10/3600/24 days_before_wraparound_prevention
--;


\qecho <h3>Autovacuum , vacuum and maintenance_work_mem Parameters:</h3>


SELECT name,setting,source,sourcefile from pg_settings where name like '%vacuum%' order by 1;
SELECT name,setting,source,sourcefile from pg_settings where name ='maintenance_work_mem';




\qecho <h3>Which tables are currently eligible for autovacuum ? </h3>

WITH vbt AS (SELECT setting AS autovacuum_vacuum_threshold FROM pg_settings WHERE name = 'autovacuum_vacuum_threshold')
    , vsf AS (SELECT setting AS autovacuum_vacuum_scale_factor FROM pg_settings WHERE name = 'autovacuum_vacuum_scale_factor')
    , fma AS (SELECT setting AS autovacuum_freeze_max_age FROM pg_settings WHERE name = 'autovacuum_freeze_max_age')
    , sto AS (select opt_oid, split_part(setting, '=', 1) as param, split_part(setting, '=', 2) as value from (select oid opt_oid, unnest(reloptions) setting from pg_class) opt)
SELECT
    '"'||ns.nspname||'"."'||c.relname||'"' as relation
    , pg_size_pretty(pg_table_size(c.oid)) as table_size
    , age(relfrozenxid) as xid_age
    , coalesce(cfma.value::float, autovacuum_freeze_max_age::float) autovacuum_freeze_max_age
    , (coalesce(cvbt.value::float, autovacuum_vacuum_threshold::float) + coalesce(cvsf.value::float,autovacuum_vacuum_scale_factor::float) * c.reltuples) as autovacuum_vacuum_tuples
    , n_dead_tup as dead_tuples
FROM pg_class c join pg_namespace ns on ns.oid = c.relnamespace
join pg_stat_all_tables stat on stat.relid = c.oid
join vbt on (1=1) join vsf on (1=1) join fma on (1=1)
left join sto cvbt on cvbt.param = 'autovacuum_vacuum_threshold' and c.oid = cvbt.opt_oid
left join sto cvsf on cvsf.param = 'autovacuum_vacuum_scale_factor' and c.oid = cvsf.opt_oid
left join sto cfma on cfma.param = 'autovacuum_freeze_max_age' and c.oid = cfma.opt_oid
WHERE c.relkind = 'r' and nspname <> 'pg_catalog'
and (
    age(relfrozenxid) >= coalesce(cfma.value::float, autovacuum_freeze_max_age::float)
    or
    coalesce(cvbt.value::float, autovacuum_vacuum_threshold::float) + coalesce(cvsf.value::float,autovacuum_vacuum_scale_factor::float) * c.reltuples <= n_dead_tup
   -- or 1 = 1
)
ORDER BY age(relfrozenxid) DESC ;


\qecho <h3>autovacuum progress per day:</h3>
\qecho <br>
\qecho <h3> Note:</h3>
\qecho <h4> This section presents the number of tables that have been vacuumed by the autovacuum , grouped by the date (in the format YYYY-MM-DD) of the last_autovacuum column. </h4>
\qecho <h4> If the value in the date column is NULL, it indicates that the corresponding value in the table count column represents the number of tables that the autovacuum did not vacuum. </h4>
\qecho <br>

select to_char(last_autovacuum, 'YYYY-MM-DD') as date , count(*) as table_count from pg_stat_all_tables   group by to_char(last_autovacuum, 'YYYY-MM-DD') order by 1;



 
\qecho <h3>The most recent 20 tables that have been vacuumed by the autovacuum:</h3> 
\qecho <h3> Note:</h3>
\qecho <h4> - If the value in the last_autovacuum column is NULL, it indicates that the autovacuum  did not vacuum this table. </h4>
\qecho <br>
select schemaname as schema_name,relname as table_name,n_live_tup, n_tup_upd, n_tup_del, n_dead_tup, 
last_vacuum, last_autovacuum, last_analyze, last_autoanalyze 
from pg_stat_all_tables 
order by last_autovacuum desc limit 20 ;




\qecho <h3>Top-20 tables order by xid age:</h3>

-- this need to be run in each DB in the instance 

SELECT c.oid::regclass as relation_name,     
        greatest(age(c.relfrozenxid),age(t.relfrozenxid)) as age,
        pg_size_pretty(pg_table_size(c.oid)) as table_size,
        c.relkind
FROM pg_class c
LEFT JOIN pg_class t ON c.reltoastrelid = t.oid
WHERE c.relkind in ('r', 't','m')
order by 2 desc limit 20;



\qecho <h3>Index Inforamtion for Top-20 tables order by xid age:</h3>

SELECT schemaname,relname AS tablename,
indexrelname AS indexname,
idx_scan ,
pg_relation_size(indexrelid) as index_size,
pg_size_pretty(pg_relation_size(indexrelid)) AS pretty_index_size
FROM pg_catalog.pg_stat_all_indexes
WHERE  relname in (select relation_name::text from (SELECT c.oid::regclass as relation_name,     
        greatest(age(c.relfrozenxid),age(t.relfrozenxid)) as age,
        pg_size_pretty(pg_table_size(c.oid)) as table_size,
        c.relkind
FROM pg_class c
LEFT JOIN pg_class t ON c.reltoastrelid = t.oid
WHERE c.relkind in ('r', 't','m')
order by 2 desc limit 20) as r1 )
order by 2,4 ;

\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Table_Size                                   -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Table_Size"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Table Size</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h3>Table Size order by schema name and table size:</h3>
\qecho <br>
\qecho <details>
SELECT *, pg_size_pretty(total_bytes) AS TOTAL_PRETTY
    , pg_size_pretty(index_bytes) AS INDEX_PRETTY
    , pg_size_pretty(toast_bytes) AS TOAST_PRETTY
    , pg_size_pretty(table_bytes) AS TABLE_PRETTY
  FROM (
  SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS TABLE_BYTES FROM (
      SELECT c.oid,nspname AS table_schema, relname AS TABLE_NAME
              , c.reltuples::bigint AS ROW_ESTIMATE
              , pg_total_relation_size(c.oid) AS TOTAL_BYTES
              , pg_indexes_size(c.oid) AS INDEX_BYTES
              , pg_total_relation_size(reltoastrelid) AS TOAST_BYTES
          FROM pg_class c
          LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE relkind = 'r'
  ) a
) a
order by 2,8 desc;
\qecho </details>
\qecho <br>
\qecho <h3>biggest 50 tables in the DB: </h3>
\qecho <br>
\qecho <h3> Note:</h3>
\qecho <h4> - If the table has never yet been vacuumed or analyzed, ROW_ESTIMATE column (pg_class.reltuples) contains -1 indicating that the row count is unknown. </h4>
\qecho <details>
SELECT *, pg_size_pretty(total_bytes) AS TOTAL_PRETTY
    , pg_size_pretty(index_bytes) AS INDEX_PRETTY
    , pg_size_pretty(toast_bytes) AS TOAST_PRETTY
    , pg_size_pretty(table_bytes) AS TABLE_PRETTY
  FROM (
  SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS TABLE_BYTES FROM (
      SELECT c.oid,nspname AS table_schema, relname AS TABLE_NAME
              , c.reltuples::bigint AS ROW_ESTIMATE
              , pg_total_relation_size(c.oid) AS TOTAL_BYTES
              , pg_indexes_size(c.oid) AS INDEX_BYTES
              , pg_total_relation_size(reltoastrelid) AS TOAST_BYTES
          FROM pg_class c
          LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE relkind = 'r'
  ) a
) a
order by 5 desc
LIMIT 50;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - index_Size                                    -                  |
-- +----------------------------------------------------------------------------+

\qecho <a name="index_Size"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Index_Size</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h3>Index Size order by schema name and table name :</h3>
\qecho <br>
\qecho <details>
SELECT
schemaname,relname as "Table",
indexrelname AS indexname,
pg_relation_size(indexrelid),
pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_catalog.pg_statio_all_indexes  ORDER BY 1,2 desc ;
\qecho </details>
\qecho <br>
\qecho <h3>biggest 50 Index in the DB :</h3>
\qecho <br>
\qecho <details>
SELECT
schemaname as schema_name,relname as "Table",
indexrelname AS indexname,
pg_relation_size(indexrelid),
pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_catalog.pg_statio_all_indexes  ORDER BY 4 desc limit 50;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - vacuum and Statistics           -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="vacuum_Statistics"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Vacuum & Statistics</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h3>Autovacuum Parameters:</h3>
\qecho <br>
\qecho <details>
SELECT * from pg_settings where category like 'Autovacuum';
\qecho <br>
SELECT *  FROM pg_settings where name in ('rds.force_autovacuum_logging_level','log_autovacuum_min_duration','vacuum_failsafe_age','vacuum_multixact_failsafe_age') order by category;
\qecho <br>
\qecho </details>
\qecho <br>
\qecho <h3>current running autovacuum process:</h3>
\qecho <br>
\qecho <details>
SELECT datname,usename,state,query,
now() - pg_stat_activity.query_start AS duration, 
wait_event from pg_stat_activity where query ~ '^autovacuum:' order by 5;
\qecho <br>
\qecho </details>
\qecho <br>
\qecho <h3>current running vacuum process:</h3>
\qecho <br>
\qecho <details>
SELECT datname,usename,state,query,
now() - pg_stat_activity.query_start AS duration,
 wait_event from pg_stat_activity where query ~* '\A\s*vacuum\M' order by 5;
\qecho </details>
\qecho <br>
--  Whenever VACUUM is running, the pg_stat_progress_vacuum view will contain one row for each backend (including autovacuum worker processes) that is currently vacuuming (vacuum porgress)
\qecho <h3>Vacuum progress:</h3>
\qecho <br>
\qecho <details>
SELECT p.pid, now() - a.xact_start AS duration, coalesce(wait_event_type ||'.'|| wait_event, 'f') AS waiting, CASE WHEN a.query ~ '^autovacuum.*to prevent wraparound' THEN 'wraparound' WHEN a.query ~ '^vacuum' THEN 'user' ELSE 'regular' END AS mode, p.datname AS database, p.relid::regclass AS table, p.phase, pg_size_pretty(p.heap_blks_total * current_setting('block_size')::int) AS table_size, pg_size_pretty(pg_total_relation_size(relid)) AS total_size, pg_size_pretty(p.heap_blks_scanned * current_setting('block_size')::int) AS scanned, pg_size_pretty(p.heap_blks_vacuumed * current_setting('block_size')::int) AS vacuumed, round(100.0 * p.heap_blks_scanned / p.heap_blks_total, 1) AS scanned_pct, round(100.0 * p.heap_blks_vacuumed / p.heap_blks_total, 1) AS vacuumed_pct, p.index_vacuum_count, round(100.0 * p.num_dead_tuples / p.max_dead_tuples,1) AS dead_pct FROM pg_stat_progress_vacuum p JOIN pg_stat_activity a using (pid) ORDER BY now() - a.xact_start DESC;
\qecho </details>
\qecho <br>
\qecho <h3>Autovacuum progress per day: </h3>
\qecho <br>
\qecho <h3> Note:</h3>
\qecho <h4> This section presents the number of tables that have been vacuumed by the autovacuum , grouped by the date (in the format YYYY-MM-DD) of the last_autovacuum column. </h4>
\qecho <h4> If the value in the date column is NULL, it indicates that the corresponding value in the table count column represents the number of tables that the autovacuum did not vacuum. </h4>
\qecho <br>
\qecho <details>
select to_char(last_autovacuum, 'YYYY-MM-DD') as date , count(*) as table_count from pg_stat_all_tables   group by to_char(last_autovacuum, 'YYYY-MM-DD') order by 1;
\qecho </details>
\qecho <br>
\qecho <h3>Autoanalyze progress per day: </h3>
\qecho <br>
\qecho <h3> Note:</h3>
\qecho <h4> This section presents the number of tables that have been analyzed by the autoanalyze , grouped by the date (in the format YYYY-MM-DD) of the last_autoanalyze column. </h4>
\qecho <h4> If the value in the date column is NULL, it indicates that the corresponding value in the table count column represents the number of tables that the autoanalyze did not analyze. </h4>
\qecho <br>
\qecho <details>
select to_char(last_autoanalyze, 'YYYY-MM-DD') as date , count(*) as table_count from pg_stat_all_tables   group by to_char(last_autoanalyze, 'YYYY-MM-DD') order by 1;
\qecho </details>
\qecho <br>
--Which tables are currently eligible for autovacuum based on curret parameters
\qecho <h3>Which tables are currently eligible for autovacuum based on current parameters : </h3>
\qecho <br>
\qecho <details>
WITH vbt AS (SELECT setting AS autovacuum_vacuum_threshold FROM pg_settings WHERE name = 'autovacuum_vacuum_threshold')
    , vsf AS (SELECT setting AS autovacuum_vacuum_scale_factor FROM pg_settings WHERE name = 'autovacuum_vacuum_scale_factor')
    , fma AS (SELECT setting AS autovacuum_freeze_max_age FROM pg_settings WHERE name = 'autovacuum_freeze_max_age')
    , sto AS (select opt_oid, split_part(setting, '=', 1) as param, split_part(setting, '=', 2) as value from (select oid opt_oid, unnest(reloptions) setting from pg_class) opt)
SELECT
    '"'||ns.nspname||'"."'||c.relname||'"' as relation
    , pg_size_pretty(pg_table_size(c.oid)) as table_size
    , age(relfrozenxid) as xid_age
    , coalesce(cfma.value::float, autovacuum_freeze_max_age::float) autovacuum_freeze_max_age
    , (coalesce(cvbt.value::float, autovacuum_vacuum_threshold::float) + coalesce(cvsf.value::float,autovacuum_vacuum_scale_factor::float) * c.reltuples) as autovacuum_vacuum_tuples
    , n_dead_tup as dead_tuples
FROM pg_class c join pg_namespace ns on ns.oid = c.relnamespace
join pg_stat_all_tables stat on stat.relid = c.oid
join vbt on (1=1) join vsf on (1=1) join fma on (1=1)
left join sto cvbt on cvbt.param = 'autovacuum_vacuum_threshold' and c.oid = cvbt.opt_oid
left join sto cvsf on cvsf.param = 'autovacuum_vacuum_scale_factor' and c.oid = cvsf.opt_oid
left join sto cfma on cfma.param = 'autovacuum_freeze_max_age' and c.oid = cfma.opt_oid
WHERE c.relkind = 'r' and nspname <> 'pg_catalog'
and (
    age(relfrozenxid) >= coalesce(cfma.value::float, autovacuum_freeze_max_age::float)
    or
    coalesce(cvbt.value::float, autovacuum_vacuum_threshold::float) + coalesce(cvsf.value::float,autovacuum_vacuum_scale_factor::float) * c.reltuples <= n_dead_tup
   -- or 1 = 1
)
ORDER BY age(relfrozenxid) DESC LIMIT 50;
\qecho </details>
\qecho <br>
-- check if the statistics collector is enabled (track_counts is on)
\qecho <h3>Check if the statistics collector is enabled (track_counts is on) : </h3>
\qecho <br>
\qecho <details>
SELECT name, setting FROM pg_settings WHERE name='track_counts';
\qecho </details>
\qecho <br>
-- to check the number of dead rows for the top 50 table
\qecho <h3>Top 50 tables based on number of dead tuples: </h3>
\qecho <br>
\qecho <details>
select schemaname as schema_name,relname AS table_name,n_live_tup, n_tup_upd, n_tup_del, n_dead_tup, last_vacuum, last_autovacuum, last_analyze, last_autoanalyze  from pg_stat_all_tables order by n_dead_tup desc limit 50;
\qecho </details>
\qecho <br>
\qecho <h3>Tables have more than 20% dead rows :</h3>
\qecho <br>
\qecho <details>
select schemaname,relname , last_vacuum,last_autovacuum,n_live_tup,n_dead_tup , trunc((n_dead_tup::numeric/nullif(n_live_tup+n_dead_tup,0))* 100,2) as "n_dead_tup_%" from pg_stat_user_tables where n_dead_tup::float/nullif(n_live_tup+n_dead_tup,0) >.2 order by n_live_tup desc ;
\qecho </details>
\qecho <br>
\qecho <h3>pg_stat_all_tables : </h3>
\qecho <br>
\qecho <details>
select * from pg_stat_all_tables order by schemaname;
\qecho </details>
\qecho <br>
\qecho <h3>pg_stat_all_tables order by autovacuum_count : </h3>
\qecho <br>
\qecho <details>
select relname,schemaname,last_vacuum,last_autovacuum,last_analyze,last_autoanalyze,vacuum_count,autovacuum_count,analyze_count,autoanalyze_count from pg_stat_all_tables  where schemaname not in ('pg_catalog','pg_toast') order by autovacuum_count desc;
\qecho </details>
\qecho <br>
\qecho <h3>pg_stat_all_tables order by autoanalyze_count: </h3>
\qecho <br>
\qecho <details>
select relname,schemaname,last_vacuum,last_autovacuum,last_analyze,last_autoanalyze,vacuum_count,autovacuum_count,analyze_count,autoanalyze_count from pg_stat_all_tables  where schemaname not in ('pg_catalog','pg_toast') order by autoanalyze_count desc;
\qecho </details>
\qecho <br>
\qecho <h3>tables without auto analyze : </h3>
\qecho <br>
\qecho <details>
select count(*) from pg_stat_all_tables  where  autoanalyze_count = 0 ;
\qecho <br>
select relname,schemaname,last_vacuum,last_autovacuum,autovacuum_count,autoanalyze_count,last_analyze,last_autoanalyze,n_mod_since_analyze,n_ins_since_vacuum from pg_stat_all_tables  where  autoanalyze_count = 0  order by 2;
\qecho </details>
\qecho <br>
\qecho <h3>tables without auto vacuum : </h3>
\qecho <br>
\qecho <details>
select count(*) from pg_stat_all_tables  where autovacuum_count  = 0 ;
\qecho <br>
select relname,schemaname,last_vacuum,last_autovacuum,autovacuum_count,autoanalyze_count,last_analyze,last_autoanalyze,n_dead_tup,n_tup_ins ,n_ins_since_vacuum from pg_stat_all_tables  where autovacuum_count  = 0  order by 2;
\qecho </details>
\qecho <br>
\qecho <h3>Tables that have not been manually analyzed :</h3>
\qecho <br>
\qecho <details>
select count (analyze_count) from pg_stat_all_tables where analyze_count = 0;
\qecho <br>
select relname,schemaname,last_vacuum,vacuum_count,last_autovacuum,autovacuum_count,last_autoanalyze,autoanalyze_count,last_analyze,analyze_count from pg_stat_all_tables  where analyze_count = 0;
\qecho </details>
\qecho <br>
\qecho <h3>tables without auto analyze,auto vacuum,vacuum and analyze : </h3>
\qecho <br>
\qecho <details>
select count (*) from pg_stat_all_tables  where  autoanalyze_count = 0 and autovacuum_count  = 0 and analyze_count = 0 and vacuum_count=0 ;
\qecho <br>
select relname,schemaname,last_vacuum,vacuum_count,last_autovacuum,autovacuum_count,last_autoanalyze,autoanalyze_count,last_analyze,analyze_count from pg_stat_all_tables  where  autoanalyze_count = 0 and autovacuum_count  = 0 and analyze_count = 0 and vacuum_count=0 ;  
\qecho </details>
\qecho <br>
-- to show tables that have specific table-level parameters set
\qecho <h3>Tables that have specific table-level parameters set : </h3>
\qecho <br>
\qecho <details>
select relname, reloptions from pg_class where reloptions is not null;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - Extensions                                     -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Extensions"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Extensions</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
\qecho <h3>shared_preload_libraries parameter: </h3>
show shared_preload_libraries;
\qecho <br>
\qecho <h3>Installed extension :  </h3>
SELECT e.extname AS "Extension Name", e.extversion AS "Version", n.nspname AS "Schema",pg_get_userbyid(e.extowner)  as Owner,  c.description AS "Description" , e.extrelocatable as "relocatable to another schema", e.extconfig ,e.extcondition
FROM pg_catalog.pg_extension e LEFT JOIN pg_catalog.pg_namespace n ON n.oid = e.extnamespace LEFT JOIN pg_catalog.pg_description c ON c.objoid = e.oid AND c.classoid = 'pg_catalog.pg_extension'::pg_catalog.regclass
ORDER BY 1;
\qecho <br>
\qecho <h3>Available Extension versions that are available to upgrade the installed Extension: </h3>
select b.name as extension_name , b.version as version ,b.installed as installed
from
(SELECT extname ,extversion FROM pg_extension) a ,
(SELECT name ,version ,installed FROM pg_available_extension_versions where name in (SELECT extname FROM pg_extension)) b
where a.extname = b.name
and b.version > a.extversion
order by b.name , b.version;
\qecho <br>
\qecho <h3>Latest Extension version that is available to upgrade the installed Extension: </h3>
select name as extension_name , max(version) as latest_version
from
(select b.name , b.version ,b.installed
from
(SELECT extname ,extversion FROM pg_extension) a ,
(SELECT name ,version ,installed FROM pg_available_extension_versions where name in (SELECT extname FROM pg_extension)) b
where a.extname = b.name
and b.version > a.extversion
order by b.name , b.version ) e
group by name ;
\qecho </details>
\qecho <br>
\qecho <h3>Available extensions: </h3>
\qecho <br>
\qecho <details>
\qecho <h4> pg_available_extension_versions : </h4>
select * from pg_available_extension_versions order by name,version;
\qecho <br>
\qecho <h4> pg_available_extensions : </h4>
select * from pg_available_extensions order by installed_version;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Memory setting                                   -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Memory_setting"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Memory setting</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
(
select name as parameter_name , setting , unit, (setting::BIGINT/1024)::BIGINT  as "size_MB" ,(setting::BIGINT/1024/1024)::BIGINT  as "size_GB" ,  pg_size_pretty((setting::BIGINT*1024)::BIGINT)   
from pg_settings where name in ('work_mem','maintenance_work_mem')
)
UNION ALL
(
select name as parameter_name, setting , unit , (((setting::BIGINT)*8)/1024)::BIGINT  as "size_MB" ,(((setting::BIGINT)*8)/1024/1024)::BIGINT  as "size_GB", pg_size_pretty((((setting::BIGINT)*8)*1024)::BIGINT)  
from pg_settings where name in ('shared_buffers','wal_buffers','effective_cache_size','temp_buffers')
) order by 4  desc;

select name as parameter_name,setting  FROM pg_catalog.pg_settings WHERE name in ('huge_pages' ) ;
\qecho <br>
\qecho cach read hit for the whole instance
select 
round((sum(blks_hit)::numeric / (sum(blks_hit) + sum(blks_read)::numeric))*100,2) as cache_read_hit_percentage
from pg_stat_database ;
\qecho <br>
\qecho cach read hit per Database 
select datname as database_name, 
round((blks_hit::numeric / (blks_hit + blks_read)::numeric)*100,2) as cache_read_hit_percentage
from pg_stat_database 
where blks_hit + blks_read > 0
and datname is not null 
order by 2 desc;
\qecho </details>
\qecho <br>
\qecho cach read hit per table
\qecho <br>
\qecho <details>
SELECT schemaname,relname as table_name,
 round((heap_blks_hit::numeric / (heap_blks_hit + heap_blks_read)::numeric)*100,2) as read_hit_percentage
FROM 
  pg_statio_all_tables
  where heap_blks_hit + heap_blks_read > 0
  and schemaname not in ('pg_catalog','information_schema')
  order by 3;
  \qecho </details>
\qecho <br>
\qecho cach read hit per index 
\qecho <br>
\qecho <details>
SELECT schemaname,relname as table_name,indexrelname as index_name ,
 round((idx_blks_hit::numeric / (idx_blks_hit + idx_blks_read)::numeric)*100,2) as read_hit_percentage
FROM 
  pg_statio_all_indexes
  where idx_blks_hit + idx_blks_read > 0
  and schemaname not in ('pg_catalog','information_schema')
  order by 4;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - pg_stat_statements extension                                    -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="pg_stat_statements_extension"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>pg_stat_statements extension</b></font><hr align="left" width="460">
\qecho <br>
select count(*) > 0 is_pg_stat_statements_enabled FROM pg_catalog.pg_extension where extname = 'pg_stat_statements' \gset
\if :is_pg_stat_statements_enabled
\qecho <h3> pg_stat_statements installed version: </h3>
\qecho <br>
\qecho <details>
SELECT e.extname AS "Extension Name", e.extversion AS "Version", n.nspname AS "Schema",pg_get_userbyid(e.extowner)  as Owner, c.description AS "Description" , e.extrelocatable as "relocatable to another schema", e.extconfig ,e.extcondition
 FROM pg_catalog.pg_extension e LEFT JOIN pg_catalog.pg_namespace n ON n.oid = e.extnamespace LEFT JOIN pg_catalog.pg_description c ON c.objoid = e.oid AND c.classoid = 'pg_catalog.pg_extension'::pg_catalog.regclass
 where e.extname = 'pg_stat_statements';
\qecho <br>
\qecho <h3>Parameters values: </h3>
-- pg_stat_statements extension configuration 
select name as parameter_name, setting  from pg_settings where name in ('pg_stat_statements.track','pg_stat_statements.track_utility','pg_stat_statements.save'
,'pg_stat_statements.max','shared_preload_libraries');
\qecho <br>
\qecho <h3>Available versions that are available to upgrade: </h3>
select * from
(
select b.name as extension_name , b.version as version ,b.installed as installed
from
(SELECT extname ,extversion FROM pg_extension) a ,
(SELECT name ,version ,installed FROM pg_available_extension_versions where name in (SELECT extname FROM pg_extension)) b
where a.extname = b.name
and b.version > a.extversion
order by b.name , b.version
) as r
where r.extension_name='pg_stat_statements';
;
\qecho <br>
\qecho <h3>Latest Extension version that is available to upgrade: </h3>
select * from
(
select name as extension_name , max(version) as latest_version
from
(select b.name , b.version ,b.installed
from
(SELECT extname ,extversion FROM pg_extension) a ,
(SELECT name ,version ,installed FROM pg_available_extension_versions where name in (SELECT extname FROM pg_extension)) b
where a.extname = b.name
and b.version > a.extversion
order by b.name , b.version ) e
group by name
) as r
where r.extension_name='pg_stat_statements';
;
\qecho </details>
\qecho <br>        
\qecho <h3> pg_stat_statements_info view: </h3>       
\qecho <br>
\qecho <details>
\qecho <h4> The statistics of the pg_stat_statements module itself are tracked and made available via a view named pg_stat_statements_info </h4>
\qecho <h4> dealloc column show the Total number of times pg_stat_statements entries about the least-executed statements were deallocated because more distinct statements than pg_stat_statements.max were observed </h4> 
select * from pg_stat_statements_info ;
\qecho </details>
\qecho <br>
\qecho <h3> Top SQL order by total_exec_time: </h3>
\qecho <br>
\qecho <details>
--Top SQL order by total_exec_time
select queryid,substring(query,1,60) as query , calls, 
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from pg_stat_statements 
order by total_time_Msec desc limit 20;
\qecho </details>

\qecho <br>
\qecho <h3> Top SQL order by avg_time: </h3>
\qecho <br>
\qecho <details>
--Top SQL order by avg_time
select queryid,substring(query,1,60) as query , calls,
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from pg_stat_statements 
order by avg_time_Msec desc limit 20;
\qecho </details>

\qecho <br>
\qecho <h3> Top SQL order by percent of total DB time percent: </h3>
\qecho <br>
\qecho <details>
--Top SQL order by percent of total DB time
select queryid,substring(query,1,60) as query , calls, 
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from pg_stat_statements 
order by percent desc limit 20;
\qecho </details>

\qecho <br>
\qecho <h3> Top SQL order by number of execution (CALLs): </h3>
\qecho <br>
\qecho <details>
--Top SQL order by number of execution (CALLs)  
select queryid,substring(query,1,60) as query , calls,
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from pg_stat_statements 
order by calls desc limit 20;
\qecho </details>

\qecho <br>
\qecho <h3> Top SQL order by shared blocks read (physical reads): </h3>
\qecho <br>
\qecho <details>
--Top SQL order by shared blocks read (physical reads) 
select queryid, substring(query,1,60) as query , calls,
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent,
shared_blks_read
from pg_stat_statements 
order by shared_blks_read desc limit 20;
\qecho </details>
\else
    \if yes
        \qecho 'pg_stat_statements extension is not installed'
    \endif
\endif

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Users_Roles_Info                                  -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Users_Roles_Info"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Users & Roles Info</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
\du
\qecho <br>
-- list of per database role settings (settings set at the role level)
\drds
\qecho <br>
select * FROM pg_user;
\qecho </details>


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Schema_Info                                    -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Schema_Info"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Schema Info</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h3>List of schemas:</h3>
\qecho <br>
\qecho <details>
\dn+
\qecho </details>
\qecho <br>
\qecho <h3>Total objects Count in the database:</h3>
\qecho <br>
\qecho <details>
select count (*) from pg_catalog.pg_class;
\qecho </details>
\qecho <br>
\qecho <h3>objects count per schema :</h3>
\qecho <br>
\qecho <details>
select 
n.nspname as schema_name, count (*) 
from pg_catalog.pg_class c
lEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
GROUP BY n.nspname
order by  2 desc ;
\qecho </details>
\qecho <br>
\qecho <h3>object type count per schema:</h3>
\qecho <br>
\qecho <details>
SELECT
n.nspname as schema_name
,CASE c.relkind
   WHEN 'r' THEN 'table'
   WHEN 'v' THEN 'view'
   WHEN 'i' THEN 'index'
   WHEN 'S' THEN 'sequence'
   WHEN 't' THEN 'TOAST table'
   WHEN 'm' THEN 'materialized view'
   WHEN 'c' THEN 'composite type'
   WHEN 'f' THEN 'foreign table'
   WHEN 'p' THEN 'partitioned table'
   WHEN 'I' THEN 'partitioned index'
END as object_type
,count(1) as object_count
FROM pg_catalog.pg_class c
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r','v','i','S','s')
GROUP BY  n.nspname,
CASE c.relkind
   WHEN 'r' THEN 'table'
   WHEN 'v' THEN 'view'
   WHEN 'i' THEN 'index'
   WHEN 'S' THEN 'sequence'
   WHEN 't' THEN 'TOAST table'
   WHEN 'm' THEN 'materialized view'
   WHEN 'c' THEN 'composite type'
   WHEN 'f' THEN 'foreign table'
   WHEN 'p' THEN 'partitioned table'
   WHEN 'I' THEN 'partitioned index'
END
ORDER BY n.nspname,
CASE c.relkind
   WHEN 'r' THEN 'table'
   WHEN 'v' THEN 'view'
   WHEN 'i' THEN 'index'
   WHEN 'S' THEN 'sequence'
   WHEN 't' THEN 'TOAST table'
   WHEN 'm' THEN 'materialized view'
   WHEN 'c' THEN 'composite type'
   WHEN 'f' THEN 'foreign table'
   WHEN 'p' THEN 'partitioned table'
   WHEN 'I' THEN 'partitioned index'
END;
\qecho </details>
\qecho <br>
\qecho <h3>list of objects:</h3>
\qecho <br>
\qecho <details>
select nsp.nspname as schema,
       rol.rolname as owner, 
       cls.relname as object_name,        
       case cls.relkind
         WHEN 'r' THEN 'table'
         WHEN 'v' THEN 'view'
         WHEN 'i' THEN 'index'
         WHEN 'S' THEN 'sequence'
         WHEN 't' THEN 'TOAST table'
         WHEN 'm' THEN 'materialized view'
         WHEN 'c' THEN 'composite type'
         WHEN 'f' THEN 'foreign table'
         WHEN 'p' THEN 'partitioned table'
         WHEN 'I' THEN 'partitioned index'
         else cls.relkind::text
       end as object_type
from pg_class cls
  join pg_roles rol on rol.oid = cls.relowner
  join pg_namespace nsp on nsp.oid = cls.relnamespace
order by 1,2,4;
\qecho </details>
\qecho <br>


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Tablespaces_Info                                   -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Tablespaces_Info"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Tablespaces Info</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
SELECT spcname as Tablespace_Name,
  pg_catalog.pg_get_userbyid(spcowner) as Owner,
CASE
WHEN 
pg_tablespace_location(oid)=''
AND     spcname='pg_default'
THEN
current_setting('data_directory')||'/base/'
WHEN 
pg_tablespace_location(oid)=''
AND     spcname='pg_global'
THEN
current_setting('data_directory')||'/global/'
ELSE
pg_tablespace_location(oid)
END
AS      location          ,
spcacl,spcoptions
FROM pg_catalog.pg_tablespace
ORDER BY 1;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      -table_Access_Profile                                    -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="table_Access_Profile"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Table Access Profile</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details> 
with table_size_info as 
(SELECT
schemaname as schema_name,relname as "Table",
pg_relation_size(relid) relation_size,
relid,
pg_size_pretty(pg_relation_size(relid)) AS "table_size",
pg_size_pretty(pg_total_relation_size(relid)) AS "TABLE size + indexes",
pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) as "indexes size"
FROM pg_catalog.pg_statio_all_tables ORDER BY 1,3  desc)
Select
b.schema_name,
a.relname as "Table_Name",
b.table_size as "Table_Size",
a.seq_scan  total_fts_scan ,
a.seq_tup_read total_fts_num_rows_reads,
a.seq_tup_read/NULLIF(a.seq_scan,0)  fts_rows_per_read ,
a.idx_scan total_idx_scan,
a.idx_tup_fetch total_Idx_num_rows_read ,
a.idx_tup_fetch/NULLIF(a.idx_scan,0)  idx_rows_per_read,
trunc((idx_scan::numeric/NULLIF((idx_scan::numeric+seq_scan::numeric),0)) * 100,2) as "IDX_scan_%",
trunc((seq_scan::numeric/NULLIF((idx_scan::numeric+seq_scan::numeric),0)) * 100,2) as "FTS_scan_%",
case when seq_scan>idx_scan then 'FTS' else 'IDX' end access_profile,
a.n_live_tup,
a.n_dead_tup,
trunc((n_dead_tup::numeric/NULLIF(n_live_tup::numeric,0)) * 100,2) as "dead_tup_%",
a.n_tup_ins,
a.n_tup_upd, 
a.n_tup_del,
trunc((n_tup_ins::numeric/NULLIF((n_tup_ins::numeric+n_tup_upd::numeric+n_tup_del::numeric),0)) * 100,2) as "tup_ins_%",
trunc((n_tup_upd::numeric/NULLIF((n_tup_ins::numeric+n_tup_upd::numeric+n_tup_del::numeric),0)) * 100,2) as "tup_upd_%",
trunc((n_tup_del::numeric/NULLIF((n_tup_ins::numeric+n_tup_upd::numeric+n_tup_del::numeric),0)) * 100,2) as "tup_del_%" 
from pg_stat_all_tables  a ,  table_size_info  b
where a.relid=b.relid 
and schema_name not in ('pg_catalog')
order  by b.relation_size  desc;
\qecho </details>
\qecho <br>
\qecho <h3> Tables have more full table scan than index scan : </h3>
\qecho <br>
\qecho <details>
with table_size_info as 
(SELECT
schemaname as schema_name,relname as "Table",
pg_relation_size(relid) relation_size,
relid,
pg_size_pretty(pg_relation_size(relid)) AS "table_size",
pg_size_pretty(pg_total_relation_size(relid)) AS "TABLE size + indexes",
pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) as "indexes size"
FROM pg_catalog.pg_statio_all_tables ORDER BY 1,3  desc)
Select
b.schema_name,
a.relname as "Table_Name",
b.table_size as "Table_Size",
a.seq_scan  total_fts_scan ,
a.seq_tup_read total_fts_num_rows_reads,
a.seq_tup_read/NULLIF(a.seq_scan,0)  fts_rows_per_read ,
a.idx_scan total_idx_scan,
a.idx_tup_fetch total_Idx_num_rows_read ,
a.idx_tup_fetch/NULLIF(a.idx_scan,0)  idx_rows_per_read,
trunc((idx_scan::numeric/NULLIF((idx_scan::numeric+seq_scan::numeric),0)) * 100,2) as "IDX_scan_%",
trunc((seq_scan::numeric/NULLIF((idx_scan::numeric+seq_scan::numeric),0)) * 100,2) as "FTS_scan_%",
case when seq_scan>idx_scan then 'FTS' else 'IDX' end access_profile,
a.n_live_tup,
a.n_dead_tup,
trunc((n_dead_tup::numeric/NULLIF(n_live_tup::numeric,0)) * 100,2) as "dead_tup_%",
a.n_tup_ins,
a.n_tup_upd, 
a.n_tup_del,
trunc((n_tup_ins::numeric/NULLIF((n_tup_ins::numeric+n_tup_upd::numeric+n_tup_del::numeric),0)) * 100,2) as "tup_ins_%",
trunc((n_tup_upd::numeric/NULLIF((n_tup_ins::numeric+n_tup_upd::numeric+n_tup_del::numeric),0)) * 100,2) as "tup_upd_%",
trunc((n_tup_del::numeric/NULLIF((n_tup_ins::numeric+n_tup_upd::numeric+n_tup_del::numeric),0)) * 100,2) as "tup_del_%" 
from pg_stat_all_tables  a ,  table_size_info  b
where a.relid=b.relid 
and schema_name not in ('pg_catalog', 'pg_toast')
and seq_scan>idx_scan
and b.relation_size > 10485760
order by b.relation_size desc;
\qecho </details>
\qecho <br>
\qecho <h4> pg_statio_all_tables View : </h4>
\qecho <h4> Total physical reads (disk blocks read or Reads from Disk) = heap_blks_read + idx_blks_read + toast_blks_read + tidx_blks_read  </h4>
\qecho <h4> Total logical reads (buffer hits or Read from Memory)  = heap_blks_hits + idx_blks_hits + toast_blks_hits + tidx_blks_hits  </h4>
\qecho <br>
\qecho <h3> Top 50 Tables by total physical reads : </h3>
\qecho <br> 
\qecho <details>
select
s2.* , 
coalesce(trunc((s2.total_physical_reads::numeric/NULLIF((s2.total_physical_reads::numeric+s2.total_logical_reads::numeric),0)) * 100,2),0)  as physical_reads_percent,
coalesce(trunc((s2.total_logical_reads::numeric/NULLIF((s2.total_physical_reads::numeric+s2.total_logical_reads::numeric),0)) * 100,2),0)  as logical_reads_percent
from 
(
select 
s.* ,
s.table_disk_blocks_read+
s.indexes_disk_blocks_read+
s.TOAST_table_disk_blocks_read+
s.TOAST_indexes_disk_blocks_read as total_physical_reads,

s.table_buffer_hits+
s.indexes_buffer_hits+
s.TOAST_table_buffer_hits+
s.TOAST_indexes_buffer_hits as total_logical_reads 
from
(
select
schemaname as schema_name,
relname as table_name,
coalesce(heap_blks_read,0) table_disk_blocks_read ,
coalesce(heap_blks_hit,0)  table_buffer_hits ,
coalesce(idx_blks_read,0) indexes_disk_blocks_read ,
coalesce(idx_blks_hit,0)   indexes_buffer_hits ,
coalesce(toast_blks_read,0) TOAST_table_disk_blocks_read ,
coalesce(toast_blks_hit,0)  TOAST_table_buffer_hits ,
coalesce(tidx_blks_read,0)  TOAST_indexes_disk_blocks_read ,
coalesce(tidx_blks_hit,0)   TOAST_indexes_buffer_hits 
from pg_statio_all_tables 
where schemaname not in ('pg_toast','pg_catalog','information_schema')
 ) as s

) as s2
order by s2.total_physical_reads  desc limit 50 ;
\qecho </details>
\qecho <br> 
\qecho <h3> Top 50 Tables by total physical reads percent  : </h3>
\qecho <br> 
\qecho <details>
select 
s2.* , 
coalesce(trunc((s2.total_physical_reads::numeric/NULLIF((s2.total_physical_reads::numeric+s2.total_logical_reads::numeric),0)) * 100,2),0)  as physical_reads_percent,
coalesce(trunc((s2.total_logical_reads::numeric/NULLIF((s2.total_physical_reads::numeric+s2.total_logical_reads::numeric),0)) * 100,2),0)  as logical_reads_percent
from 
(
select 
s.* ,
s.table_disk_blocks_read+
s.indexes_disk_blocks_read+
s.TOAST_table_disk_blocks_read+
s.TOAST_indexes_disk_blocks_read as total_physical_reads,

s.table_buffer_hits+
s.indexes_buffer_hits+
s.TOAST_table_buffer_hits+
s.TOAST_indexes_buffer_hits as total_logical_reads 
from
(
select
schemaname as schema_name,
relname as table_name,
coalesce(heap_blks_read,0) table_disk_blocks_read ,
coalesce(heap_blks_hit,0)  table_buffer_hits ,
coalesce(idx_blks_read,0) indexes_disk_blocks_read ,
coalesce(idx_blks_hit,0)   indexes_buffer_hits ,
coalesce(toast_blks_read,0) TOAST_table_disk_blocks_read ,
coalesce(toast_blks_hit,0)  TOAST_table_buffer_hits ,
coalesce(tidx_blks_read,0)  TOAST_indexes_disk_blocks_read ,
coalesce(tidx_blks_hit,0)   TOAST_indexes_buffer_hits 
from pg_statio_all_tables
where schemaname not in ('pg_toast','pg_catalog','information_schema')  
) as s

) as s2 
order by physical_reads_percent  desc limit 50  ;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Unused_Indexes                                   -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Unused_Indexes"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Unused Indexes</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
SELECT ai.schemaname,ai.relname AS tablename,ai.indexrelid  as index_oid ,
ai.indexrelname AS indexname,i.indisunique ,
ai.idx_scan ,
pg_relation_size(ai.indexrelid) as index_size,
pg_size_pretty(pg_relation_size(ai.indexrelid)) AS pretty_index_size
FROM pg_catalog.pg_stat_all_indexes ai , pg_index i
WHERE ai.indexrelid=i.indexrelid
and ai.idx_scan = 0 
and ai.schemaname not in ('pg_catalog')
order by index_size desc;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - Index_Access_Profile                                    -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Index_Access_Profile"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Index Access Profile</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
with index_size_info as 
(
SELECT
schemaname,relname as "Table",
indexrelname AS indexname,
indexrelid,
pg_relation_size(indexrelid) index_size_byte,
pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_catalog.pg_statio_all_indexes  ORDER BY 1,4 desc) 
Select a.schemaname, 
a.relname as "Table_Name",
a.indexrelname AS indexname,
b.index_size,
a.idx_scan,
a.idx_tup_read,
a.idx_tup_fetch
from pg_stat_all_indexes a ,  index_size_info b
where a.idx_scan >0  
and a.indexrelid=b.indexrelid
and a.schemaname not in ('pg_catalog')
order by b.index_size_byte desc,a.idx_scan asc ;
\qecho </details>
\qecho <br> 
\qecho <h4> pg_statio_all_indexes  View : </h4>
\qecho <h4> physical reads (disk blocks read or Reads from Disk) = idx_blks_read  </h4>
\qecho <h4> logical reads (buffer hits or Read from Memory) = idx_blks_hit  </h4>
\qecho <br>
\qecho <h3> Top 50 index by physical reads : </h3>
\qecho <br> 
\qecho <details>
select
schemaname        as schema_name  ,
relname            as table_name     ,
indexrelname    as index_name,
coalesce(idx_blks_read,0)   as indexe_disk_blocks_read,
coalesce(idx_blks_hit,0)    as indexe_buffer_hits    ,
coalesce(trunc((coalesce(idx_blks_read,0)
/ 
NULLIF(
coalesce(idx_blks_read,0)
+coalesce(idx_blks_hit,0)
,0) ) * 100,2),0) as physical_reads_percent ,
coalesce(trunc((coalesce(idx_blks_hit,0)
/ 
NULLIF(
coalesce(idx_blks_read,0)
+coalesce(idx_blks_hit,0)
,0) ) * 100,2),0) as logical_reads_percent
from 
pg_statio_all_indexes 
where schemaname not in ('pg_toast','pg_catalog','information_schema')
order by indexe_disk_blocks_read desc limit 50 ;
\qecho </details>
\qecho <br>
\qecho <h3> Top 50 index by physical reads percent  : </h3>
\qecho <br> 
\qecho <details>
select
schemaname        as schema_name  ,
relname            as table_name     ,
indexrelname    as index_name,
coalesce(idx_blks_read,0)   as indexe_disk_blocks_read,
coalesce(idx_blks_hit,0)    as indexe_buffer_hits    ,
coalesce(trunc((coalesce(idx_blks_read,0)
/ 
NULLIF(
coalesce(idx_blks_read,0)
+coalesce(idx_blks_hit,0)
,0) ) * 100,2),0) as physical_reads_percent ,
coalesce(trunc((coalesce(idx_blks_hit,0)
/ 
NULLIF(
coalesce(idx_blks_read,0)
+coalesce(idx_blks_hit,0)
,0) ) * 100,2),0) as logical_reads_percent
from 
pg_statio_all_indexes 
where schemaname not in ('pg_toast','pg_catalog','information_schema')
order by physical_reads_percent desc limit 50 ;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Fragmentation                                    -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Fragmentation"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Fragmentation (Bloat)</b></font><hr align="left" width="460">
-- Show database bloat
\qecho <br>
\qecho <h3>Tables and indexes Bloat [Fragmentation] order by table wasted size :</h3>
\qecho <br>
\qecho <details>
SELECT
  current_database(), schemaname, tablename, /*reltuples::bigint, relpages::bigint, otta,*/
  ROUND((CASE WHEN otta=0 THEN 0.0 ELSE sml.relpages::FLOAT/otta END)::NUMERIC,1) AS "table_bloat_ratio",
  CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::BIGINT END AS wastedbytes,
  pg_size_pretty(CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::BIGINT END) AS table_wasted_size,
  iname AS Index_nam, /*ituples::bigint, ipages::bigint, iotta,*/
  ROUND((CASE WHEN iotta=0 OR ipages=0 THEN 0.0 ELSE ipages::FLOAT/iotta END)::NUMERIC,1) AS "Index_bloat_ratio",
  CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta) END AS wastedibytes,
  pg_size_pretty(CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta) ::BIGINT END) AS Index_wasted_size
FROM (
  SELECT
    schemaname, tablename, cc.reltuples, cc.relpages, bs,
    CEIL((cc.reltuples*((datahdr+ma-
      (CASE WHEN datahdr%ma=0 THEN ma ELSE datahdr%ma END))+nullhdr2+4))/(bs-20::FLOAT)) AS otta,
    COALESCE(c2.relname,'?') AS iname, COALESCE(c2.reltuples,0) AS ituples, COALESCE(c2.relpages,0) AS ipages,
    COALESCE(CEIL((c2.reltuples*(datahdr-12))/(bs-20::FLOAT)),0) AS iotta -- very rough approximation, assumes all cols
  FROM (
    SELECT
      ma,bs,schemaname,tablename,
      (datawidth+(hdr+ma-(CASE WHEN hdr%ma=0 THEN ma ELSE hdr%ma END)))::NUMERIC AS datahdr,
      (maxfracsum*(nullhdr+ma-(CASE WHEN nullhdr%ma=0 THEN ma ELSE nullhdr%ma END))) AS nullhdr2
    FROM (
      SELECT
        schemaname, tablename, hdr, ma, bs,
        SUM((1-null_frac)*avg_width) AS datawidth,
        MAX(null_frac) AS maxfracsum,
        hdr+(
          SELECT 1+COUNT(*)/8
          FROM pg_stats s2
          WHERE null_frac<>0 AND s2.schemaname = s.schemaname AND s2.tablename = s.tablename
        ) AS nullhdr
      FROM pg_stats s, (
        SELECT
          (SELECT current_setting('block_size')::NUMERIC) AS bs,
          CASE WHEN SUBSTRING(v,12,3) IN ('8.0','8.1','8.2') THEN 27 ELSE 23 END AS hdr,
          CASE WHEN v ~ 'mingw32' THEN 8 ELSE 4 END AS ma
        FROM (SELECT version() AS v) AS foo
      ) AS constants
      GROUP BY 1,2,3,4,5
    ) AS foo
  ) AS rs
  JOIN pg_class cc ON cc.relname = rs.tablename
  JOIN pg_namespace nn ON cc.relnamespace = nn.oid AND nn.nspname = rs.schemaname AND nn.nspname <> 'information_schema'
  LEFT JOIN pg_index i ON indrelid = cc.oid
  LEFT JOIN pg_class c2 ON c2.oid = i.indexrelid
) AS sml
ORDER BY wastedbytes DESC; 
\qecho </details>

\qecho <br>
\qecho <h3>Tables and indexes Bloat [Fragmentation] order by table wasted ratio :</h3>
\qecho <br>
\qecho <details>
SELECT
  current_database(), schemaname, tablename, /*reltuples::bigint, relpages::bigint, otta,*/
  ROUND((CASE WHEN otta=0 THEN 0.0 ELSE sml.relpages::FLOAT/otta END)::NUMERIC,1) AS "table_bloat_ratio",
  CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::BIGINT END AS wastedbytes,
  pg_size_pretty(CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::BIGINT END) AS table_wasted_size,
  iname AS Index_nam, /*ituples::bigint, ipages::bigint, iotta,*/
  ROUND((CASE WHEN iotta=0 OR ipages=0 THEN 0.0 ELSE ipages::FLOAT/iotta END)::NUMERIC,1) AS "Index_bloat_ratio",
  CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta) END AS wastedibytes,
  pg_size_pretty(CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta) ::BIGINT END) AS Index_wasted_size
FROM (
  SELECT
    schemaname, tablename, cc.reltuples, cc.relpages, bs,
    CEIL((cc.reltuples*((datahdr+ma-
      (CASE WHEN datahdr%ma=0 THEN ma ELSE datahdr%ma END))+nullhdr2+4))/(bs-20::FLOAT)) AS otta,
    COALESCE(c2.relname,'?') AS iname, COALESCE(c2.reltuples,0) AS ituples, COALESCE(c2.relpages,0) AS ipages,
    COALESCE(CEIL((c2.reltuples*(datahdr-12))/(bs-20::FLOAT)),0) AS iotta -- very rough approximation, assumes all cols
  FROM (
    SELECT
      ma,bs,schemaname,tablename,
      (datawidth+(hdr+ma-(CASE WHEN hdr%ma=0 THEN ma ELSE hdr%ma END)))::NUMERIC AS datahdr,
      (maxfracsum*(nullhdr+ma-(CASE WHEN nullhdr%ma=0 THEN ma ELSE nullhdr%ma END))) AS nullhdr2
    FROM (
      SELECT
        schemaname, tablename, hdr, ma, bs,
        SUM((1-null_frac)*avg_width) AS datawidth,
        MAX(null_frac) AS maxfracsum,
        hdr+(
          SELECT 1+COUNT(*)/8
          FROM pg_stats s2
          WHERE null_frac<>0 AND s2.schemaname = s.schemaname AND s2.tablename = s.tablename
        ) AS nullhdr
      FROM pg_stats s, (
        SELECT
          (SELECT current_setting('block_size')::NUMERIC) AS bs,
          CASE WHEN SUBSTRING(v,12,3) IN ('8.0','8.1','8.2') THEN 27 ELSE 23 END AS hdr,
          CASE WHEN v ~ 'mingw32' THEN 8 ELSE 4 END AS ma
        FROM (SELECT version() AS v) AS foo
      ) AS constants
      GROUP BY 1,2,3,4,5
    ) AS foo
  ) AS rs
  JOIN pg_class cc ON cc.relname = rs.tablename
  JOIN pg_namespace nn ON cc.relnamespace = nn.oid AND nn.nspname = rs.schemaname AND nn.nspname <> 'information_schema'
  LEFT JOIN pg_index i ON indrelid = cc.oid
  LEFT JOIN pg_class c2 ON c2.oid = i.indexrelid
) AS sml
ORDER BY 4 desc; 
\qecho </details>

\qecho <br>
\qecho <h3>Tables and indexes Bloat [Fragmentation] order by index wasted ratio :</h3>
\qecho <br>
\qecho <details>
SELECT
  current_database(), schemaname, tablename, /*reltuples::bigint, relpages::bigint, otta,*/
  ROUND((CASE WHEN otta=0 THEN 0.0 ELSE sml.relpages::FLOAT/otta END)::NUMERIC,1) AS "table_bloat_ratio",
  CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::BIGINT END AS wastedbytes,
  pg_size_pretty(CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::BIGINT END) AS table_wasted_size,
  iname AS Index_nam, /*ituples::bigint, ipages::bigint, iotta,*/
  ROUND((CASE WHEN iotta=0 OR ipages=0 THEN 0.0 ELSE ipages::FLOAT/iotta END)::NUMERIC,1) AS "Index_bloat_ratio",
  CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta) END AS wastedibytes,
  pg_size_pretty(CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta) ::BIGINT END) AS Index_wasted_size
FROM (
  SELECT
    schemaname, tablename, cc.reltuples, cc.relpages, bs,
    CEIL((cc.reltuples*((datahdr+ma-
      (CASE WHEN datahdr%ma=0 THEN ma ELSE datahdr%ma END))+nullhdr2+4))/(bs-20::FLOAT)) AS otta,
    COALESCE(c2.relname,'?') AS iname, COALESCE(c2.reltuples,0) AS ituples, COALESCE(c2.relpages,0) AS ipages,
    COALESCE(CEIL((c2.reltuples*(datahdr-12))/(bs-20::FLOAT)),0) AS iotta -- very rough approximation, assumes all cols
  FROM (
    SELECT
      ma,bs,schemaname,tablename,
      (datawidth+(hdr+ma-(CASE WHEN hdr%ma=0 THEN ma ELSE hdr%ma END)))::NUMERIC AS datahdr,
      (maxfracsum*(nullhdr+ma-(CASE WHEN nullhdr%ma=0 THEN ma ELSE nullhdr%ma END))) AS nullhdr2
    FROM (
      SELECT
        schemaname, tablename, hdr, ma, bs,
        SUM((1-null_frac)*avg_width) AS datawidth,
        MAX(null_frac) AS maxfracsum,
        hdr+(
          SELECT 1+COUNT(*)/8
          FROM pg_stats s2
          WHERE null_frac<>0 AND s2.schemaname = s.schemaname AND s2.tablename = s.tablename
        ) AS nullhdr
      FROM pg_stats s, (
        SELECT
          (SELECT current_setting('block_size')::NUMERIC) AS bs,
          CASE WHEN SUBSTRING(v,12,3) IN ('8.0','8.1','8.2') THEN 27 ELSE 23 END AS hdr,
          CASE WHEN v ~ 'mingw32' THEN 8 ELSE 4 END AS ma
        FROM (SELECT version() AS v) AS foo
      ) AS constants
      GROUP BY 1,2,3,4,5
    ) AS foo
  ) AS rs
  JOIN pg_class cc ON cc.relname = rs.tablename
  JOIN pg_namespace nn ON cc.relnamespace = nn.oid AND nn.nspname = rs.schemaname AND nn.nspname <> 'information_schema'
  LEFT JOIN pg_index i ON indrelid = cc.oid
  LEFT JOIN pg_class c2 ON c2.oid = i.indexrelid
) AS sml
ORDER BY 8 desc; 
\qecho </details>



\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Toast_Tables_Mapping                                  -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Toast_Tables_Mapping"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Toast Tables Mapping</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h3> Note:</h3>
\qecho <h4> When a column is written to the toast table, an OID is used to identify the chunk to be toasted. When a toast table grows very large, and contains chunk_ids that are nearing the value of 2^32, it can lead to performance degredation when writing to toast. This is because PostgreSQL must check if an OID is available for assignment by scanning the table </h4>
\qecho <h4> A large Toast table can be a good indication that your toast can face OID wraparound </h4>
\qecho <h4> over time the insert statement will be slower as the Database will be searching for an unused OID and it will have to read from the disk , you will see the insert statements is waiting on IPC:BufferiO or IO:DataFileRead  </h4>
\qecho <h4> you can use below SQL to check the toast table  </h4>
\qecho <h4> select COUNT(DISTINCT chunk_id),2^31 - COUNT(DISTINCT chunk_id) as remaining_OID ,ROUND(100*((2^31 - COUNT(DISTINCT chunk_id)))/2^31::float) AS remaining_OID_PCT ,ROUND(100*(COUNT(DISTINCT chunk_id)/2^31::float)) as percent_towards_Toast_oid_wraparound from pg_toast.pg_toast_{number};</h4> 
\qecho <br>
\qecho <h4> when the toast hits the OID wraparound, you will see the following wait event LWLock:OidGen and the insert statements will fail and you will see below error in the log file </h4>
\qecho <br>
\qecho <h4> :LOG:  still searching for an unused OID in relation "pg_toast_{number}"  </h4>
\qecho <h4> :DETAIL:  OID candidates have been checked 1000000 times, but no unused OID has been found yet. </h4>
\qecho <br>
\qecho <h3>Toast Tables Mapping and sizes:</h3>
\qecho <br>
\qecho <details>
select t.relname table_name, r.relname toast_name,r.oid as toast_oid, pg_relation_size(t.reltoastrelid) as toast_size_bytes  ,pg_size_pretty(pg_relation_size(t.reltoastrelid)) as toast_size
FROM
    pg_class r
INNER JOIN pg_class t ON r.oid = t.reltoastrelid
order by toast_size_bytes desc ;  
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Replication                                   -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Replication"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Replication</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
\qecho <h3> Active replication slots order by age_xmin:</h3> 
select *,age(xmin) age_xmin,age(catalog_xmin) age_catalog_xmin 
from pg_replication_slots 
where active = true 
order by age(xmin) desc;
\qecho <br>
\qecho <h3> Replication Slot Lag:</h3> 
select slot_name,slot_type,database,active,
coalesce(round(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn) / 1024 / 1024 , 2),0) AS Lag_MB_behind ,
coalesce(round(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn) / 1024 / 1024 / 1024, 2),0) AS Lag_GB_behind
from pg_replication_slots 
order by Lag_MB_behind desc;
\qecho <br>
\qecho <h3> Inactive replication slots order by age_xmin::</h3> 
select *,age(xmin) age_xmin,age(catalog_xmin) age_catalog_xmin 
from pg_replication_slots where active = false order by age(xmin) desc;
\qecho <br>
\qecho <h3> Note:</h3>
\qecho <h4> RDS Postgres instance storage may get full because inactive replication slots were not removed after DMS task completed </h4>
\qecho <h4> If replication slot is created and it becomes in-active, then transaction logs wont recycle from master instance. So eventually storage gets full </h4> 
\qecho <h4> These replication slots can be cleaned as below </h4>
\qecho <br>
\qecho <h4> Drop inactive replication slot : </h4>
\qecho <h4> Use the below SQL to Generate SQL to drop the inactive slots </h4>
\qecho <h4>  select 'select pg_drop_replication_slot('''||slot_name||''');' from pg_replication_slots where active = false; </h4>
\qecho <h4> then Verify the CLoudWatch metrics Free Storage Space to confirm that disk space was released </h4>
\qecho <br>
\qecho <h3> Replication Slot wal status :</h3> 
select 
name as parameter_name,setting,unit,short_desc  
FROM pg_catalog.pg_settings 
WHERE name in ('max_slot_wal_keep_size' ) ;
\qecho <br>
select slot_name,slot_type,database,active,wal_status ,safe_wal_size ,
coalesce(round(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn) / 1024 / 1024 , 2),0) AS Lag_MB_behind ,
coalesce(round(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn) / 1024 / 1024 / 1024, 2),0) AS Lag_GB_behind
from pg_replication_slots 
order by safe_wal_size ;
\qecho <h4> wal_status : the Availability of WAL files claimed by this slot. Possible values are: </h4>
\qecho <h4> - reserved means that the claimed files are within max_wal_size. </h4>
\qecho <h4> - extended means that max_wal_size is exceeded but the files are still retained, either by the replication slot or by wal_keep_size. </h4>
\qecho <h4> - unreserved means that the slot no longer retains the required WAL files and some of them are to be removed at the next checkpoint. This state can return to reserved or extended. </h4>
\qecho <h4> - lost means that some required WAL files have been removed and this slot is no longer usable. </h4>
\qecho <h4> The last two states are seen only when max_slot_wal_keep_size is non-negative. If restart_lsn is NULL, this field is null. </h4>
\qecho <h4> safe_wal_size : The number of bytes that can be written to WAL such that this slot is not in danger of getting in state "lost". It is NULL for lost slots, as well as if max_slot_wal_keep_size is -1. </h4>
\qecho <br>
\qecho <h3> pg_stat_replication_slots view:</h3> 
\qecho <h4> pg_stat_replication_slots is a statistics view showing statistics about logical replication slot usage, specifically about transactions spilled to disk from the ReorderBuffer once the memory used by logical decoding to decode changes from WAL has exceeded logical_decoding_work_mem </h4>
SELECT * FROM pg_stat_replication_slots order by spill_bytes;

\qecho <h3>Replication Parameters :</h3> 
select 
name as parameter_name,setting,unit,short_desc  
FROM pg_catalog.pg_settings 
WHERE name in ('wal_level','max_wal_senders','max_replication_slots',
'max_worker_processes','max_logical_replication_workers','wal_receiver_timeout',
'max_sync_workers_per_subscription','wal_receiver_status_interval','wal_retrieve_retry_interval','logical_decoding_work_mem','max_slot_wal_keep_size' ) ;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - sessions_info                                                     - |
-- +----------------------------------------------------------------------------+

\qecho <a name="sessions_info"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Sessions/Connections Info</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h3>Connections utilization:</h3>
\qecho <br>
\qecho <details>
with
settings as (SELECT setting::float AS "max_connections" FROM pg_settings WHERE name = 'max_connections'),
connections as (select sum (numbackends)::float total_connections from pg_stat_database)
select   settings.max_connections AS "Max_connections" ,total_connections as "Total_connections",ROUND((100*(connections.Total_connections/settings.max_connections))::numeric,2) as "Connections utilization %" from  settings, connections;
\qecho </details>
\qecho <br>
\qecho <h3>Reserved connections settings:</h3>
\qecho <br>
\qecho <details>
select  name as parameter_name , setting , short_desc from pg_settings WHERE name in ('superuser_reserved_connections', 'rds.rds_superuser_reserved_connections');
\qecho </details>
\qecho <br>
\qecho <h3>Sessions statistics:</h3>
\qecho <br>
\qecho <details>
select 
datname as Database_name
,session_time
,active_time
,idle_in_transaction_time
,sessions
,sessions_abandoned
,sessions_fatal
,sessions_killed
from pg_stat_database 
where datname is not null 
order by active_time desc ;
\qecho </details>
\qecho <br>
\qecho <h3> DB/Connections count :</h3>
\qecho <br>
\qecho <details>
SELECT datname as "Database_Name",count(*) as "Connections_count" FROM pg_stat_activity where datname is not null group by datname order by 2 desc;
\qecho </details>
\qecho <br>
\qecho <h3> DB/username/Connections count :</h3>
\qecho <br>
\qecho <details>
SELECT datname as "Database_Name",usename as "User_Name" ,count(*) as "Connections_count" FROM pg_stat_activity  where datname is not null  group by datname,usename order by 1,3 desc;
\qecho </details>
\qecho <br>
\qecho <h3> username/Connections count :</h3>
\qecho <br>
\qecho <details>
SELECT usename as "User_Name",count(*) as "connections_count" FROM pg_stat_activity  where datname is not null  group by usename order by 2 desc;
\qecho </details>
\qecho <br>
\qecho <h3> username/status/Connections count :</h3>
\qecho <br>
\qecho <details>
SELECT usename as "User_Name",state as status,count(*) as "Connections_count" FROM pg_stat_activity  where datname is not null group by usename,state order by 1,2 desc;
\qecho </details>
\qecho <br>
\qecho <h3> DB/username/status/Connections count :</h3>
\qecho <br>
\qecho <details>
select datname as "Database_Name" ,usename as "User_Name",state as status,count(*) as "Connections_count" FROM pg_stat_activity where datname is not null group by datname ,usename,state order by 4 desc;
\qecho </details>
\qecho <br>
\qecho <h3> status/Connections count :</h3>
\qecho <br>
\qecho <details>
SELECT state as status ,count(*) as "Connections_count" FROM pg_stat_activity where datname is not null GROUP BY status order by 2 desc;
\qecho </details>
\qecho <br>
\qecho <h3> username/status/SQL/count : </h3>
\qecho <br>
\qecho <details>
SELECT usename as "User_Name" , state as status , query, count(*) FROM pg_stat_activity where datname is not null group by usename,state,query ;
\qecho </details>
\qecho <br>
\qecho <h3> username/status/query_id/count : </h3>
\qecho <br>
\qecho <details>
SELECT usename as "User_Name" , state as status , query_id, count(*) FROM pg_stat_activity where datname is not null group by usename,state,query_id ;
\qecho </details>
\qecho <br>
\qecho <h3>Active sessions:</h3>
\qecho <br>
\qecho <details>
/* active_session_monitor*/ select * from
(
    SELECT
usename,pid, now() - pg_stat_activity.xact_start AS xact_duration ,now() - pg_stat_activity.query_start AS query_duration,
substr(query,1,50) as query,query_id,state,wait_event
FROM pg_stat_activity
) as s where (xact_duration is not null  or query_duration is not null ) and state!='idle' and query not like '%active_session_monitor%'
order by xact_duration desc, query_duration desc;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - Orphaned_prepared_transactions                   -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Orphaned_prepared_transactions"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Orphaned prepared transactions</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
SELECT gid, prepared, owner, database, transaction AS xmin
FROM pg_prepared_xacts
ORDER BY age(transaction) DESC; 

\qecho <br>
\qecho <h3> Note:</h3>
\qecho <h4> During two-phase commit, a distributed transaction is first prepared with the PREPARE statement and then committed with the COMMIT PREPARED statement </h4>
\qecho <h4> Once a transaction has been prepared, it is kept hanging around until it is committed or aborted. It </h4> 
\qecho <h4> even has to survive a server restart! Normally, transactions don not remain in the prepared state for long,  </h4>
\qecho <h4> but sometimes things go wrong and a prepared transaction has to be removed manually by an administrator.  </h4>
\qecho <h4> any Orphaned prepared transactions will prevent the VACUUM to remove the dead rows   </h4>               
\qecho <h4>  EXAMPLE: DETAIL:  50000 dead row versions cannot be removed yet,oldest xmin: 22300 </h4>
\qecho <br>
\qecho <h4>  Use the ROLLBACK PREPARED transaction_id SQL statement to  remove prepared transactions    </h4>
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - PK_FK_using_numeric_or_integer_data_type         -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="PK_FK_using_numeric_or_integer_data_type"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>PK or FK using numeric or integer data type</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
with column_data_type as 
(select kcu.table_schema,
       kcu.table_name,
       tco.constraint_name,
       tco.constraint_type,
       kcu.ordinal_position as position,
       kcu.column_name as column_name
from information_schema.table_constraints tco
join information_schema.key_column_usage kcu 
     on kcu.constraint_name = tco.constraint_name
     and kcu.constraint_schema = tco.constraint_schema
     and kcu.constraint_name = tco.constraint_name
where tco.constraint_type in ('PRIMARY KEY', 'FOREIGN KEY')
order by kcu.table_schema,
         kcu.table_name,
         kcu.ordinal_position)
select 
c.table_schema,
c.table_name,
c.constraint_name,
c.constraint_type,
c.position,
c.column_name,
i.data_type
from information_schema.columns  i, column_data_type c
where i.column_name=c.column_name
and i.table_name = c.table_name
and i.data_type in ('numeric','integer')
order by 
c.table_schema,
c.table_name,
c.position
;
\qecho </details>


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - public_Schema                                  -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="public_Schema"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Public Schema</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h3>object / count:</h3>
\qecho <br>
\qecho <details>
SELECT
n.nspname as schema_name
,CASE c.relkind
   WHEN 'r' THEN 'table'
   WHEN 'v' THEN 'view'
   WHEN 'i' THEN 'index'
   WHEN 'S' THEN 'sequence'
   WHEN 's' THEN 'special'
END as object_type
,count(1) as object_count
FROM pg_catalog.pg_class c
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r','v','i','S','s')
and n.nspname ='public'
GROUP BY  n.nspname,
CASE c.relkind
   WHEN 'r' THEN 'table'
   WHEN 'v' THEN 'view'
   WHEN 'i' THEN 'index'
   WHEN 'S' THEN 'sequence'
   WHEN 's' THEN 'special'
END
ORDER BY n.nspname,
CASE c.relkind
   WHEN 'r' THEN 'table'
   WHEN 'v' THEN 'view'
   WHEN 'i' THEN 'index'
   WHEN 'S' THEN 'sequence'
   WHEN 's' THEN 'special'
END;
\qecho </details>

-- list of object
\qecho <br>
\qecho <h3>list of object:</h3>
\qecho <br>
\qecho <details>
select nsp.nspname as schema,
       rol.rolname as owner, 
       cls.relname as object_name,        
       case cls.relkind
         when 'r' then 'TABLE'
         when 'm' then 'MATERIALIZED_VIEW'
         when 'i' then 'INDEX'
         when 'S' then 'SEQUENCE'
         when 'v' then 'VIEW'
         when 'c' then 'TYPE'
         else cls.relkind::text
       end as object_type
from pg_class cls
  join pg_roles rol on rol.oid = cls.relowner
  join pg_namespace nsp on nsp.oid = cls.relnamespace
where nsp.nspname ='public'
order by 1,2,4;
\qecho </details>

-- list of function
\qecho <br>
\qecho <h3>list of function:</h3>
\qecho <br>
\qecho <details>
select nsp.nspname as schema,
       rol.rolname as owner, 
       f.proname as function_name       
from pg_proc f
  join pg_roles rol on rol.oid = f.proowner
  join pg_namespace nsp on nsp.oid = f.pronamespace
where nsp.nspname ='public'
order by 1,2;
\qecho </details>

\qecho <br>
-- list of triggers
\qecho <h3>list of triggers:</h3>
\qecho <br>
\qecho <details>
select event_object_schema as schema,
 event_object_table as table_name,
trigger_schema,
 trigger_name,
string_agg(event_manipulation, ',') as event,
        action_timing as activation,
        action_condition as condition,
        action_statement as definition
 from information_schema.triggers
 where event_object_schema ='public'
 group by 1,2,3,4,6,7,8
 order by schema,
          table_name;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - invalid_indexes                                 -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="invalid_indexes"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Invalid indexes</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
select count (*) as count_of_invalid_indxes from pg_index WHERE pg_index.indisvalid = false ;
with table_info as 
(SELECT pg_index.indrelid , pg_class.oid, pg_class.relname as table_name 
from   pg_class , pg_index
where pg_index.indrelid = pg_class.oid )
SELECT distinct pg_index.indexrelid as INDX_ID,pg_class.relname as index_name ,table_info.table_name,pg_namespace.nspname as schema_name  , pg_class.relowner as owner_id , pg_index.indisvalid as indx_is_valid
FROM pg_class , pg_index ,pg_namespace , table_info
WHERE pg_index.indisvalid = false 
AND pg_index.indexrelid = pg_class.oid
and pg_class.relnamespace = pg_namespace.oid
and pg_index.indrelid = table_info.oid
;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - default_access_privileges                                    -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="default_access_privileges"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Default access privileges</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
SELECT pg_catalog.pg_get_userbyid(d.defaclrole) AS "Owner",
  n.nspname AS "Schema",
  CASE d.defaclobjtype WHEN 'r' THEN 'table' WHEN 'S' THEN 'sequence' WHEN 'f' THEN 'function' WHEN 'T' THEN 'type' WHEN 'n' THEN 'schema' ELSE 'unknown' END AS "Type", 
pg_catalog.array_to_string(d.defaclacl, E'\n') AS "Access privileges"
FROM pg_catalog.pg_default_acl d
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = d.defaclnamespace
ORDER BY 1, 2, 3;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - pgaudit_extension                                  -                |
-- +----------------------------------------------------------------------------+


\qecho <a name="pgaudit_extension"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>pgaudit extension</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
SELECT e.extname AS "Extension Name", e.extversion AS "Version", n.nspname AS "Schema",pg_get_userbyid(e.extowner)  as Owner, c.description AS "Description" , e.extrelocatable as "relocatable to another schema", e.extconfig ,e.extcondition
 FROM pg_catalog.pg_extension e LEFT JOIN pg_catalog.pg_namespace n ON n.oid = e.extnamespace LEFT JOIN pg_catalog.pg_description c ON c.objoid = e.oid AND c.classoid = 'pg_catalog.pg_extension'::pg_catalog.regclass
 where e.extname = 'pgaudit';
\qecho <br>
SELECT name as "parameter_name", setting from pg_settings where name like 'pgaudit.%' or name = 'shared_preload_libraries';
\qecho <br>
\qecho <h3>pgaudit user level configuration : </h3>
select usename as user_name,useconfig as user_config FROM pg_user where useconfig::text like '%pgaudit.%';
\qecho </details>


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - unlogged_tables                                    -                |
-- +----------------------------------------------------------------------------+


\qecho <a name="unlogged_tables"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Unlogged Tables</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
\qecho <h3>Number of Unlogged Tables : </h3>
select count (*) FROM pg_class WHERE relpersistence = 'u';
\qecho <br>
select relname as table_name, relpersistence FROM pg_class WHERE relpersistence = 'u';
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - access_privileges                                    -              |
-- +----------------------------------------------------------------------------+


\qecho <a name="access_privileges"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Access privileges</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
SELECT n.nspname as "Schema",
  c.relname as "Name",
  CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'm' THEN 'materialized view' WHEN 'S' THEN 'sequence' WHEN 'f' THEN 'foreign table' END as "Type",
  pg_catalog.array_to_string(c.relacl, E'\n') AS "Access privileges",
  pg_catalog.array_to_string(ARRAY(
    SELECT attname || E':\n  ' || pg_catalog.array_to_string(attacl, E'\n  ')
    FROM pg_catalog.pg_attribute a
    WHERE attrelid = c.oid AND NOT attisdropped AND attacl IS NOT NULL
  ), E'\n') AS "Column access privileges"
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r', 'v', 'm', 'S', 'f')
  AND n.nspname !~ '^pg_' AND pg_catalog.pg_table_is_visible(c.oid)
ORDER BY 1, 3, 2;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - ssl   -                                                             |
-- +----------------------------------------------------------------------------+


\qecho <a name="ssl"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>SSL</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
select name as "Parameter_Name" , setting as value,short_desc  from pg_settings where name like '%ssl%';
\qecho <br>
select version as ssl_version , count (*) as "Connection_count" FROM pg_stat_ssl group by version ;
\qecho <br>
select ssl , count (*) as "Connection_count" FROM pg_stat_ssl group by ssl ;
\qecho <br>
SELECT datname as "Database_Name" ,usename as "User_Name", ssl , client_addr , application_name, backend_type
FROM pg_stat_ssl
JOIN pg_stat_activity
ON pg_stat_ssl.pid = pg_stat_activity.pid
order by ssl ;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - background_processes                                   -            |
-- +----------------------------------------------------------------------------+


\qecho <a name="background_processes"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Background processes</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
\qecho <h3>Count of Postgres background processess : </h3>
select count (*) as "Background processes count" FROM pg_stat_activity where datname is null ;
\qecho <br>
SELECT  pid , backend_type as  "Background processes Type" , backend_start as "start time" FROM pg_stat_activity where datname is null order by 3 ;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Multixact ID MXID                                -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Multixact_ID_MXID"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Multixact ID MXID (Wraparound)</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
\qecho <h3>oldest mxid::</h3>
SELECT max(mxid_age(datminmxid)) oldest_mxid FROM pg_database ;

\qecho <h3>oldest mxid per database:</h3>
SELECT datname database_name , mxid_age(datminmxid) oldest_mxid FROM pg_database order by 2 desc;

\qecho <h3>autovacuum_multixact_freeze_max_age parameter value:</h3>

select setting AS autovacuum_multixact_freeze_max_age FROM pg_catalog.pg_settings WHERE name = 'autovacuum_multixact_freeze_max_age';

\qecho <h3>Top-20 tables order by MXID age:</h3>


select relname as table_name ,mxid_age(relminmxid) mmxid_age from pg_class where relname not like 'pg_toast%'
and relminmxid::text::int>0
order by 2 desc limit 20;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - Temp tables                                      -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Temp_tables"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Temp tables</b></font><hr align="left" width="460">

\qecho <br>
\qecho <details>
\qecho <h3>Parameters:</h3>

select 
name as parameter_name,setting,unit,short_desc  
FROM pg_catalog.pg_settings 
WHERE name in ('temp_tablespaces','temp_file_limit','log_temp_files' ) ;
\qecho <br>
select name as parameter_name, setting , unit,   (((setting::BIGINT)*8)/1024)::BIGINT  as "size_MB" ,(((setting::BIGINT)*8)/1024/1024)::BIGINT  as "size_GB", pg_size_pretty((((setting::BIGINT)*8)*1024)::BIGINT),short_desc  
from pg_settings where name in ('temp_buffers') ;
\qecho <br>
\qecho <h3>Temp tables statistics:</h3>
\qecho <h4>Note: Number of temporary files created by queries in every Database and total amount of data written to temporary files by queries in every Database </h4>
\qecho <br>
select datname as database_name, temp_bytes/1024/1024 temp_size_MB,
temp_bytes/1024/1024/1024 temp_size_GB ,temp_files  from  pg_stat_database
where  temp_bytes + temp_files > 0
and datname is not null  
order by 2  desc;

\qecho <br>
SELECT
n.nspname as SchemaName
,c.relname as RelationName
,CASE c.relkind
WHEN 'r' THEN 'table'
WHEN 'v' THEN 'view'
WHEN 'i' THEN 'index'
WHEN 'S' THEN 'sequence'
WHEN 's' THEN 'special'
END as RelationType
,pg_catalog.pg_get_userbyid(c.relowner) as RelationOwner
,pg_size_pretty(pg_relation_size(n.nspname ||'.'|| c.relname)) as RelationSize
FROM pg_catalog.pg_class c
LEFT JOIN pg_catalog.pg_namespace n
ON n.oid = c.relnamespace
WHERE c.relkind IN ('r','s')
AND (n.nspname !~ '^pg_toast' and nspname like 'pg_temp%')
ORDER BY pg_relation_size(n.nspname ||'.'|| c.relname) DESC ;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Large_objects                                    -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Large_objects"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Large objects</b></font><hr align="left" width="460">

\qecho <br>
\qecho <details>
\qecho <h4>Note:The catalog pg_largeobject_metadata holds metadata associated with large objects. The actual large object data is stored in pg_largeobject</h4>
\qecho <br>
\qecho <h3>Number of Large objects in pg_largeobject_metadata table: </h3>
select count(*)  from pg_largeobject_metadata ;

\qecho <br>
\qecho <h3>which user own the lo ? </h3>
select pg_get_userbyid(lomowner) as user_name ,count (*) as number_of_lo from pg_largeobject_metadata 
group by 1  order by 2 desc;


\qecho <br>
\qecho <h3>pg_largeobject_metadata table size: </h3>
\dt+ pg_largeobject_metadata;

\qecho <br>
--select count(*)  from pg_largeobject;
-- in RDS PG : ERROR:  permission denied for table pg_largeobject

\qecho <br>
\qecho <h3>pg_largeobject table size: </h3>
\qecho <h4>Each large object is broken into segments or pages small enough to be conveniently stored as rows in pg_largeobject. </h4>
\qecho <h4>The amount of data per page is defined to be LOBLKSIZE (which is currently BLCKSZ/4, or typically 2 kB)</h4>
\qecho <br>
\dt+ pg_largeobject;
\qecho </details>


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - Partition_tables                                    -               |
-- +----------------------------------------------------------------------------+


\qecho <a name="Partition_tables"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Partition tables</b></font><hr align="left" width="460">

\qecho <br>
\qecho <details>
\qecho <h4>Note:The catalog pg_inherits records information about table and index inheritance hierarchies. There is one entry for each direct parent-child table or index relationship in the database</h4>
SELECT
    parent.oid                        AS parent_table_oid,
    parent.relname                    AS parent_table_name,
    count(child.oid)                  AS partition_count
FROM pg_inherits
    JOIN pg_class parent            ON pg_inherits.inhparent = parent.oid
    JOIN pg_class child             ON pg_inherits.inhrelid   = child.oid 
    group by 1,2
    order by 3 desc;


\qecho <br>

SELECT
    parent.relnamespace::regnamespace AS parent_table_schema,
    parent.relowner::regrole          AS parent_table_owner,
    parent.oid                        AS parent_table_oid,
    parent.relname                    AS parent_table_name,
  --child.relnamespace::regnamespace  AS partition_schema,
    child.oid                         AS partition_oid,
    child.relname                     AS partition_name
FROM pg_inherits
    JOIN pg_class parent            ON pg_inherits.inhparent = parent.oid
    JOIN pg_class child             ON pg_inherits.inhrelid   = child.oid 
    order by 3 ,6;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - pg_shdepend                                    -                    |
-- +----------------------------------------------------------------------------+


\qecho <a name="pg_shdepend"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>pg_shdepend</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
\qecho <h4>The catalog pg_shdepend records the dependency relationships between database objects and shared objects</h4>

select d.datname as database_name, c.relname as table_name, count(*)
from pg_catalog.pg_shdepend ps, pg_class c, pg_database d
where c.oid = ps.classid
and ps.dbid = d.oid
group by d.datname,c.relname
order by 1,3 desc;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - FK_without_index                                 -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="FK_without_index"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>FK without index</b></font><hr align="left" width="460">

\qecho <br>
\qecho <details>
SELECT c.conrelid::regclass AS "table",
       /* list of key column names in order */
       string_agg(a.attname, ',' ORDER BY x.n) AS columns,
       pg_catalog.pg_size_pretty(
          pg_catalog.pg_relation_size(c.conrelid)
       ) AS size,
       c.conname AS constraint,
       c.confrelid::regclass AS referenced_table
FROM pg_catalog.pg_constraint c
   /* enumerated key column numbers per foreign key */
   CROSS JOIN LATERAL
      unnest(c.conkey) WITH ORDINALITY AS x(attnum, n)
   /* name for each key column */
   JOIN pg_catalog.pg_attribute a
      ON a.attnum = x.attnum
         AND a.attrelid = c.conrelid
WHERE NOT EXISTS
        /* is there a matching index for the constraint? */
        (SELECT 1 FROM pg_catalog.pg_index i
         WHERE i.indrelid = c.conrelid
           /* the first index columns must be the same as the
              key columns, but order doesn't matter */
           AND (i.indkey::smallint[])[0:cardinality(c.conkey)-1]
               OPERATOR(pg_catalog.@>) c.conkey)
  AND c.contype = 'f'
GROUP BY c.conrelid, c.conname, c.confrelid
ORDER BY pg_catalog.pg_relation_size(c.conrelid) DESC;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - sequences                                    -                      |
-- +----------------------------------------------------------------------------+


\qecho <a name="sequences"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Sequences</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
\qecho <h3>sequence wraparound:</h3>
\qecho <h3>Sequences with less than 10% of the remain values</h3>
--sequence wraparound
select * from 
(
select * ,(sec.max_value - coalesce(sec.last_value,0)) as remain_values ,round((((sec.max_value - coalesce(sec.last_value,0)::float)/sec.max_value::float) *100)::int,2) remain_values_pct from pg_sequences sec ) t
where remain_values_pct <= 10 
and cycle is false 
order by remain_values_pct;
\qecho <br>
\qecho <h3>All sequences:</h3>
select * ,(sec.max_value - coalesce(sec.last_value,0)) as remain_values ,round((((sec.max_value - coalesce(sec.last_value,0)::float)/sec.max_value::float) *100)::int,2) remain_values_pct from pg_sequences sec order by remain_values_pct;
\qecho </details>


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - pg_hba.conf                                   -                     |
-- +----------------------------------------------------------------------------+


\qecho <a name="pg_hba.conf"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>pg_hba.conf</b></font><hr align="left" width="460">

\qecho <br>
\qecho <details>
\qecho <h4>Note: this view pg_hba_file_rules reports on the current contents of the file, not on what was last loaded by the server </h4>
select * from pg_hba_file_rules;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |      - Duplicate_indexes                                   -               |
-- +----------------------------------------------------------------------------+


\qecho <a name="Duplicate_indexes"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Duplicate indexes</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
SELECT pg_size_pretty(sum(pg_relation_size(idx))::bigint) as size,
       (array_agg(idx))[1] as idx1, (array_agg(idx))[2] as idx2,
       (array_agg(idx))[3] as idx3, (array_agg(idx))[4] as idx4
FROM (
    SELECT indexrelid::regclass as idx, (indrelid::text ||E'\n'|| indclass::text ||E'\n'|| indkey::text ||E'\n'||
                                         coalesce(indexprs::text,'')||E'\n' || coalesce(indpred::text,'')) as key
    FROM pg_index) sub
GROUP BY key HAVING count(*)>1
ORDER BY sum(pg_relation_size(idx)) DESC;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - functions_statistics                             -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="functions_statistics"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Functions statistics</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h4>The pg_stat_user_functions view will contain one row for each tracked function, showing statistics about executions of that function. </h4>
\qecho <h4> The track_functions parameter controls exactly which functions are tracked. </h4>
\qecho <h4>track_functions parameter Enables tracking of function call counts and time used. </h4>
\qecho <h4>Specify pl to track only procedural-language functions, all to also track SQL and C language functions. </h4>
\qecho <details>
SELECT name,setting from pg_settings where name ='track_functions';
\qecho <br>
select
schemaname||'.'||funcname func_name, calls, total_time,
round((total_time/calls)::numeric,2) as mean_time, self_time
from pg_catalog.pg_stat_user_functions
order by total_time desc;

\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - DB_Load                                          -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="DB_Load"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>DB Load</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h3>How many session waiting on CPU and Non CPU wait event:</h3>
\qecho <details>
select coalesce(count(*),'0') as  count_of_sessions_waiting_on_CPU
FROM pg_stat_activity 
where wait_event is null and state = 'active' group by wait_event ;
\qecho <br>
select coalesce(sum(count),'0') as count_of_sessions_waiting_on_Non_CPU
from (SELECT count(*) as count
FROM pg_stat_activity  
where wait_event is not null and state = 'active' 
group by wait_event) as c;
\qecho </details>

\qecho <br>
\qecho <h3>wait events:</h3>
\qecho <details>
\qecho <h3>wait events/session count :</h3>
SELECT coalesce(wait_event,'CPU') as wait_event , count(*) FROM pg_stat_activity group by wait_event order by 2 desc;
\qecho <br>
\qecho <h3>wait events/query  :</h3>
SELECT  coalesce(wait_event,'CPU') as wait_event, substr(query,1,150) as query,count(*) FROM pg_stat_activity   group by  query,wait_event order by 3 desc;
\qecho <br>
\qecho <h3>wait events/query_id  :</h3>
SELECT  coalesce(wait_event,'CPU') as wait_event, query_id ,count(*) FROM pg_stat_activity   group by  query_id,wait_event order by 3 desc;
\qecho <br>
\qecho <h3>wait events/user name :</h3>
SELECT coalesce(wait_event,'CPU') wait_event,usename as user_name, count(*) FROM pg_stat_activity group by wait_event, usename order by 3 desc ;
\qecho </details>


\qecho <br>
\qecho <h3>Lock :</h3>
\qecho <details>
\qecho <br>
\qecho <h3>Not granted lock :</h3>
SELECT coalesce(count(*),0) as "not_granted_lock" FROM pg_locks WHERE NOT GRANTED;
\qecho <br>
\qecho <h3>blocked sessions :</h3>
select count(*) from pg_stat_activity where cardinality(pg_blocking_pids(pid)) > 0 ;
\qecho <br>
\qecho <h3>lock_mode :</h3>
SELECT mode as lock_mode , count(*) FROM pg_locks group by mode;
\qecho <br>
\qecho <h3>lock_type :</h3>
SELECT locktype as lock_type , count(*) FROM pg_locks group by locktype;
\qecho </details>


\qecho <br>
\qecho <h3>pg_stat_* views:</h3>
\qecho <details>
\qecho <br>
\qecho <h3>pg_stat_bgwriter view:</h3>
select * from pg_stat_bgwriter;
\qecho <br>
\qecho <h3>pg_stat_database view:</h3>
select * from pg_stat_database;
\qecho <br>
\qecho <h3>pg_stat_database_conflicts view:</h3>
select * from pg_stat_database_conflicts;
\qecho <h3>pg_stat_wal view:</h3>
select count(*) > 0 isaurora from pg_settings where name='rds.extensions' and setting like '%aurora_stat_utils%' \gset
\if :isaurora
\qecho 'pg_stat_wal is currently not supported for Aurora'
\else
    \if yes
        SELECT * FROM pg_stat_wal;
    \endif
\endif
\qecho </details>


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - triggers                                         -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="triggers"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Triggers</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
\qecho <h3>Trigger status/count:</h3>
select 
CASE pg_trigger.tgenabled 
       WHEN 'O' THEN 'trigger fires while session_replication_role set to "origin" and "local"'
   WHEN 'D' THEN 'disabled'
   WHEN 'R' THEN 'trigger fires while session_replication_role set to replica'
   WHEN 'A' THEN 'trigger fires always'
   END as  trigger_status , count (*)
   from  pg_trigger 
   group by 1;
\qecho <br>
\qecho <h3>information_schema.triggers view:</h3> 
select event_object_schema as schema,
 event_object_table as table_name,
trigger_schema,
 trigger_name,
string_agg(event_manipulation, ',') as event,
        action_timing as activation,
        action_condition as condition,
        action_statement as definition
 from information_schema.triggers
 group by 1,2,3,4,6,7,8
 order by schema,
          table_name;
\qecho <br>
\qecho <h3>Triggers created by users (not internally generated):</h3>
select 
pg_trigger.tgrelid as table_id, pg_class.relname as table_name,
pg_trigger.tgname as trigger_name , 
pg_trigger.tgfoid as function_id ,
pg_proc.proname as function_name , 
pg_trigger.tgenabled as trigger_status_code ,
CASE pg_trigger.tgenabled 
       WHEN 'O' THEN 'trigger fires while session_replication_role set to "origin" and "local"'
   WHEN 'D' THEN 'disabled'
   WHEN 'R' THEN 'trigger fires while session_replication_role set to replica'
   WHEN 'A' THEN 'trigger fires always'
   END as  trigger_status , 
pg_trigger.tgisinternal is_internal_trigger ,  
pg_trigger.tgconstraint as constraint_associated_with_trigger
from  pg_trigger, pg_proc ,  pg_class
where pg_trigger.tgfoid= pg_proc.oid
and   pg_trigger.tgrelid = pg_class.oid
and pg_trigger.tgisinternal is false
order by table_id , trigger_status_code;
\qecho <br>
\qecho <h3>Triggers internally generated (usually, to enforce the constraint identified by tgconstraint):</h3>
\qecho <h3> pg_trigger.tgisinternal is true </h3>
select 
pg_trigger.tgrelid as table_id, pg_class.relname as table_name,
pg_trigger.tgname as trigger_name , 
pg_trigger.tgfoid as function_id ,
pg_proc.proname as function_name , 
pg_trigger.tgenabled as trigger_status_code ,
CASE pg_trigger.tgenabled 
       WHEN 'O' THEN 'trigger fires while session_replication_role set to "origin" and "local"'
   WHEN 'D' THEN 'disabled'
   WHEN 'R' THEN 'trigger fires while session_replication_role set to replica'
   WHEN 'A' THEN 'trigger fires always'
   END as  trigger_status , 
pg_trigger.tgisinternal is_internal_trigger ,  
pg_trigger.tgconstraint as constraint_associated_with_trigger
from  pg_trigger, pg_proc ,  pg_class
where pg_trigger.tgfoid= pg_proc.oid
and   pg_trigger.tgrelid = pg_class.oid
and pg_trigger.tgisinternal is true
order by table_id , trigger_status_code;

\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - pg_config                                        -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="pg_config"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>pg_config</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
\qecho <br>
\qecho <h3> The view pg_config describes the compile-time configuration parameters of the currently installed version of PostgreSQL. </h3>
\qecho <br>
select count(*) > 0 isaurora from pg_settings where name='rds.extensions' and setting like '%aurora_stat_utils%' \gset
\if :isaurora
\qecho 'pg_config() is currently not supported for Aurora'
\else
    \if yes
        select * from pg_config();
    \endif
\endif
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - DB_parameters                                    -                  |
-- +----------------------------------------------------------------------------+

\qecho <a name="DB_parameters"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>DB parameters</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
SELECT *  FROM pg_settings where name not in ('rds.extensions') order by category;
SELECT *  FROM pg_settings where name in ('rds.extensions') order by category;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - COPY_command_progress                                    -          |
-- +----------------------------------------------------------------------------+


\qecho <a name="COPY_command_progress"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>COPY command progress</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
SELECT * FROM pg_stat_progress_copy ;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Invalid_databases                                -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Invalid_databases"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Invalid databases</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h3>If the DROP DATABASE command is interrupted, the database will become invalid,starting from versions 11.21 and later, 12.16 and later, 13.12 and later, 14.9 and later, 15.4 and later, all versions of 16 as well as PostgreSQL 16 and all subsequent major versions. </h3> 
\qecho <h3>you will not be able to connect to it again. In this case, you will see the below error message: </h3>
\qecho <h3>  failed: FATAL: cannot connect to invalid database <DB Name>  </h3> 
\qecho <h3>  HINT: Use DROP DATABASE to drop invalid databases. </h3> 
\qecho <details>
\qecho <br>
\qecho <h3>Invalid databases count:</h3> 
select count(*) FROM pg_database WHERE datconnlimit = '-2' ;

\qecho <br>
\qecho <h3>Invalid databases list:</h3> 
SELECT * FROM pg_database WHERE datconnlimit = '-2' ;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - *************                                    -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="-----"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>*****</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
-- sql
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Aurora_version                                   -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Aurora_version"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Aurora version</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
select count(*) > 0 isaurora from pg_settings where name='rds.extensions' and setting like '%aurora_stat_utils%' \gset
\if :isaurora
SELECT * FROM aurora_version();
\else
    \if yes
        \qecho 'This is not Aurora instance'
    \endif
\endif
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |      - Aurora_PostgreSQL_built-in_functions             -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Aurora_PostgreSQL_built-in_functions"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Aurora PostgreSQL built-in functions</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
select count(*) > 0 isaurora from pg_settings where name='rds.extensions' and setting like '%aurora_stat_utils%' \gset
\if :isaurora
SELECT * FROM aurora_list_builtins();
\else
    \if yes
        \qecho 'This is not Aurora instance'
    \endif
\endif
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - Aurora_db_instance_identifier             -                         |
-- +----------------------------------------------------------------------------+


\qecho <a name="Aurora_db_instance_identifier"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Aurora db instance identifier</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
select count(*) > 0 isaurora from pg_settings where name='rds.extensions' and setting like '%aurora_stat_utils%' \gset
\if :isaurora
SELECT server_id,
    CASE
        WHEN 'MASTER_SESSION_ID' = session_id THEN 'writer'
        ELSE 'reader'
    END AS instance_role
FROM aurora_replica_status() rt,
         aurora_db_instance_identifier() di
    WHERE rt.server_id = di;
\else
    \if yes
        \qecho 'This is not Aurora instance'
    \endif
\endif
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Aurora_cluster_instances                  -                         |
-- +----------------------------------------------------------------------------+


\qecho <a name="Aurora_cluster_instances"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Aurora cluster instances</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
select count(*) > 0 isaurora from pg_settings where name='rds.extensions' and setting like '%aurora_stat_utils%' \gset
\if :isaurora
 SELECT server_id,
    CASE
        WHEN 'MASTER_SESSION_ID' = session_id THEN 'writer'
        ELSE 'reader'
    END AS instance_role
FROM aurora_replica_status() ;
\else
    \if yes
        \qecho 'This is not Aurora instance'
    \endif
\endif
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Aurora_reader_instances-Replica_Lag              -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Aurora_reader_instances-Replica_Lag"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Aurora reader instances - Replica Lag</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
select count(*) > 0 isaurora from pg_settings where name='rds.extensions' and setting like '%aurora_stat_utils%' \gset
\if :isaurora
SELECT server_id, 
    CASE 
        WHEN 'MASTER_SESSION_ID' = session_id THEN 'writer'
        ELSE 'reader' 
    END AS instance_role,
    replica_lag_in_msec AS replica_lag_ms,
    round(extract (epoch FROM (SELECT age(clock_timestamp(), last_update_timestamp))) * 1000) AS last_update_age_ms
FROM aurora_replica_status()
ORDER BY replica_lag_in_msec NULLS FIRST;
\else
    \if yes
        \qecho 'This is not Aurora instance'
    \endif
\endif
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |      - Aurora_cluster_cache_management_(CCM)            -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Aurora_cluster_cache_management_(CCM)"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Aurora cluster cache management (CCM)</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
select count(*) > 0 isaurora from pg_settings where name='rds.extensions' and setting like '%aurora_stat_utils%' \gset
\if :isaurora
SELECT *  FROM aurora_ccm_status();
SELECT buffers_sent_last_minute * 8/60 AS warm_rate_kbps,
100 * (1.0-buffers_sent_last_scan/buffers_found_last_scan) AS warm_percent 
FROM aurora_ccm_status ();
\else
    \if yes
        \qecho 'This is not Aurora instance'
    \endif
\endif
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |      - Aurora_global_db_status                          -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Aurora_global_db_status"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Aurora global db status</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
select count(*) > 0 isaurora from pg_settings where name='rds.extensions' and setting like '%aurora_stat_utils%' \gset
\if :isaurora
SELECT CASE 
          WHEN '-1' = durability_lag_in_msec THEN 'Primary'
          ELSE 'Secondary'
       END AS global_role,
       *
  FROM aurora_global_db_status();
\else
    \if yes
        \qecho 'This is not Aurora instance'
    \endif
\endif
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Aurora_wait_event_stat                        -                     |
-- +----------------------------------------------------------------------------+


\qecho <a name="Aurora_wait_event_stat"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Aurora wait event stat</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h3> Note:</h3>
\qecho <h4> aurora_stat_system_waits()function returns the cumulative number of waits and cumulative wait time for each wait event generated by the DB instance that you are currently connected to.</h4>
\qecho <h4> Statistics returned by this function are reset when a DB instance restarts.</h4>
\qecho <h4> waits :The number of times the wait event occurred.</h4>
\qecho <h4> wait_time : The total amount of time in microseconds spent waiting for this event.</h4>
\qecho <br>
\qecho <details>
select count(*) > 0 isaurora from pg_settings where name='rds.extensions' and setting like '%aurora_stat_utils%' \gset
\if :isaurora
SELECT type_name as wait_event_type,
             event_name as wait_event_name,
             waits,
             wait_time
        FROM aurora_stat_system_waits()
NATURAL JOIN aurora_stat_wait_event()
NATURAL JOIN aurora_stat_wait_type() order by wait_time desc;
\else
    \if yes
        \qecho 'This is not Aurora instance'
    \endif
\endif
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - query_plan_management                            -                  |
-- +----------------------------------------------------------------------------+

\qecho <a name="query_plan_management"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Query Plan Management (QPM)</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
select count(*) > 0 isaurora from pg_settings where name='rds.extensions' and setting like '%aurora_stat_utils%' \gset
select count(*) > 0 is_apg_plan_mgmt_enabled FROM pg_catalog.pg_extension where extname = 'apg_plan_mgmt' \gset
select count(*) = 0 is_apg_plan_mgmt_not_enabled FROM pg_catalog.pg_extension where extname = 'apg_plan_mgmt' \gset
\if :isaurora
    \if :is_apg_plan_mgmt_not_enabled
       \qecho 'Query Plan Management (QPM) is not enabled'
    \else
       \if :is_apg_plan_mgmt_enabled
        show rds.enable_plan_management ;
        SELECT e.extname AS "Extension Name", e.extversion AS "Version", n.nspname AS "Schema",pg_get_userbyid(e.extowner)  as Owner, c.description AS "Description" , e.extrelocatable as "relocatable to another schema", e.extconfig ,e.extcondition
        FROM pg_catalog.pg_extension e LEFT JOIN pg_catalog.pg_namespace n ON n.oid = e.extnamespace LEFT JOIN pg_catalog.pg_description c ON c.objoid = e.oid AND c.classoid = 'pg_catalog.pg_extension'::pg_catalog.regclass
        where e.extname = 'apg_plan_mgmt';
        select * from pg_available_extensions where name='apg_plan_mgmt';
        SELECT name ,version ,installed FROM pg_available_extension_versions where  name='apg_plan_mgmt' order by version;
        select name,setting from pg_settings  where name like 'apg_plan_mgmt%';
        with plans_stored_count as (select count(*) as cnt from apg_plan_mgmt.dba_plans)
        select s.setting as max_plans, p.cnt as plans_stored_count, (p.cnt/s.setting::int)*100 as plans_stored_PCT_from_max_plans from pg_settings s, plans_stored_count p where s.name ='apg_plan_mgmt.max_plans';
       \endif
    \endif  
\else
    \if yes
        \qecho 'This is not Aurora instance'
    \endif
\endif
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Aurora_dml_activity                              -                  |
-- +----------------------------------------------------------------------------+
\qecho <a name="Aurora_dml_activity"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Aurora dml activity</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
select count(*) > 0 isaurora from pg_settings where name='rds.extensions' and setting like '%aurora_stat_utils%' \gset
\if :isaurora 
with dml_details as (
SELECT db.datname AS datname,
 NULLIF(BTRIM(SPLIT_PART(db.asdmla::TEXT, ',', 1), '()'),'') AS select_count,
 NULLIF(BTRIM(SPLIT_PART(db.asdmla::TEXT, ',', 2), '()'),'') AS select_latency_microsecs,
 NULLIF(BTRIM(SPLIT_PART(db.asdmla::TEXT, ',', 3), '()'),'') AS insert_count,
 NULLIF(BTRIM(SPLIT_PART(db.asdmla::TEXT, ',', 4), '()'),'') AS insert_latency_microsecs,
 NULLIF(BTRIM(SPLIT_PART(db.asdmla::TEXT, ',', 5), '()'),'') AS update_count,
 NULLIF(BTRIM(SPLIT_PART(db.asdmla::TEXT, ',', 6), '()'),'') AS update_latency_microsecs,
 NULLIF(BTRIM(SPLIT_PART(db.asdmla::TEXT, ',', 7), '()'),'') AS delete_count,
 NULLIF(BTRIM(SPLIT_PART(db.asdmla::TEXT, ',', 8), '()'),'') AS delete_latency_microsecs
 FROM  (SELECT datname,
        aurora_stat_dml_activity(oid) AS asdmla
       FROM pg_database --where datname = 'rathoran_db'
 ) AS db)
select datname as database_name ,
          select_count::numeric,
          select_latency_microsecs::numeric,
          TRUNC(select_latency_microsecs::numeric/NULLIF(select_count::numeric,0),3) select_latency_per_exec,
          insert_count::numeric,
          insert_latency_microsecs::numeric,
          TRUNC(insert_latency_microsecs::numeric/NULLIF(insert_count::numeric,0),3) insert_latency_per_exec,
          update_count::numeric,
          update_latency_microsecs::numeric,
          TRUNC(update_latency_microsecs::numeric/NULLIF(update_count::numeric,0),3) update_latency_per_exec,
          delete_count::numeric,
          delete_latency_microsecs::numeric,
          TRUNC(delete_latency_microsecs::numeric/NULLIF(delete_count::numeric,0) ,3)delete_latency_per_exec
       FROM dml_details
       order by select_count desc;
\else
    \if yes
        \qecho 'This is not Aurora instance'
    \endif
\endif
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
-- +----------------------------------------------------------------------------+
-- |      - process_memory_context_usage                              -         |
-- +----------------------------------------------------------------------------+
\qecho <a name="process_memory_context_usage"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Process memory context usage</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
select count(*) > 0 isaurora from pg_settings where name='rds.extensions' and setting like '%aurora_stat_utils%' \gset
\if :isaurora 
select count(*) > 0 isaurora153plus FROM aurora_version() where replace(substring(aurora_version, 1, 5),'.','')::int >= '153' \gset
\if :isaurora153plus
\qecho <br>
\qecho <h3> The allocated memory for each memory context across all the processes ordered by allocated memory: </h3>
\qecho <br>
select
name, sum(allocated) as allocated_size_bytes,
 pg_size_pretty(sum(allocated)) as allocated_size,
 pg_size_pretty(sum(used)) as used_size,
 trunc(sum(used)/sum(allocated)*100,2) as used_pct,
  sum(instances) as instances_count
 from aurora_stat_memctx_usage()
 group by name
 order by allocated_size_bytes desc;
\qecho <br>
\qecho <h3> The top 50 porcess with the highest allocated memory: </h3>
\qecho <br>
select
pid, sum(allocated) as allocated_size_bytes ,pg_size_pretty(sum(allocated)) as allocated_size , pg_size_pretty(sum(used)) as used_size,
trunc(sum(used)/sum(allocated)*100,2) as used_pct
from aurora_stat_memctx_usage()
group by pid order by allocated_size_bytes desc
limit 50;

\qecho <br>
\qecho <h3> The top 50 porcess with the highest allocated memory including process information in pg_stat_activity view: </h3>
\qecho <br>
WITH memctx  AS
  (select
pid, sum(allocated) as allocated_size_bytes ,pg_size_pretty(sum(allocated)) as allocated_size , pg_size_pretty(sum(used)) as used_size,
trunc(sum(used)/sum(allocated)*100,2) as used_pct 
from aurora_stat_memctx_usage()
group by pid order by allocated_size_bytes desc
limit 50
  )
select *
from pg_stat_activity ps
INNER JOIN memctx ON ps.pid = memctx.pid
order by memctx.allocated_size_bytes desc ;
\qecho <br>
\qecho <h3> The top 50 processes with the highest allocated memory and the breakdown of their memory usage of each memory context: </h3>
\qecho <br>
WITH memctx as
(select
pid, sum(allocated) as allocated_size_bytes
from aurora_stat_memctx_usage()
group by pid order by allocated_size_bytes desc
limit 50 )
select pid ,name , allocated as allocated_size_bytes ,pg_size_pretty(allocated) as allocated_size , pg_size_pretty(used) as used_size , instances as instances_count from aurora_stat_memctx_usage() where pid in
(select pid from memctx )
order by PID, allocated_size_bytes desc;
\else
    \if yes
        \qecho 'aurora_stat_memctx_usage function is only available staring from Aurora PostgreSQL version 15.3'
    \endif
\endif
\else
    \if yes
        \qecho 'This is not Aurora instance'
    \endif
\endif
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
-- +----------------------------------------------------------------------------+
-- |      - aurora_stat_statements                           -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="aurora_stat_statements"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Aurora_stat_statements</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
select count(*) > 0 isaurora from pg_settings where name='rds.extensions' and setting like '%aurora_stat_utils%' \gset
\if :isaurora
select count(*) > 0 isaurora154plus FROM aurora_version() where replace(substring(aurora_version, 1, 5),'.','')::int >= '154' \gset
\if :isaurora154plus
\qecho <br>
\qecho <h3> Top 50 SQL order by total_time: </h3>
\qecho <br>
\qecho <details>
select queryid,substring(query,1,60) as query , calls, 
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from aurora_stat_statements(true)
order by total_time_Msec desc limit 50;
\qecho </details>
\qecho <br>
\qecho <h3> Top 50 SQL order by avg_time: </h3>
\qecho <br>
\qecho <details>
select queryid,substring(query,1,60) as query , calls,
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from aurora_stat_statements(true)
order by avg_time_Msec desc limit 50;
\qecho </details>
\qecho <br>
\qecho <h3> Top 50 SQL order by percent of total DB time percent: </h3>
\qecho <br>
\qecho <details>
select queryid,substring(query,1,60) as query , calls, 
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from aurora_stat_statements(true) 
order by percent desc limit 50;
\qecho </details>
\qecho <br>
\qecho <h3> Top 50 SQL order by number of execution (CALLs): </h3>
\qecho <br>
\qecho <details>
select queryid,substring(query,1,60) as query , calls,
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from aurora_stat_statements(true)
order by calls desc limit 50;
\qecho </details>

\qecho <br>
\qecho <h3> Top 50 SQL order by shared blocks read (physical reads) from Aurora storage: </h3>
\qecho <br>
\qecho <details>
select queryid, substring(query,1,60) as query , calls,
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent,
shared_blks_read,orcache_blks_hit,
storage_blks_read
from aurora_stat_statements(true) 
order by storage_blks_read desc limit 50;
\qecho </details>
\else
    \if yes
        \qecho 'aurora_stat_statements function is only available staring from Aurora PostgreSQL version 15.4'
    \endif
\endif
\else
    \if yes
        \qecho 'This is not Aurora instance'
    \endif
\endif
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - aurora_stat_plans                                -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="aurora_stat_plans"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Aurora_stat_plans</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
select count(*) > 0 isaurora from pg_settings where name='rds.extensions' and setting like '%aurora_stat_utils%' \gset
select count(*) > 0 isaurora155plus FROM aurora_version() where replace(substring(aurora_version, 1, 5),'.','')::int >= '155' \gset
\if :isaurora
\if :isaurora155plus
\qecho <br>
\qecho <h3> Top 50 Plan order by total_time: </h3>
\qecho <br>
\qecho <details>
select queryid,substring(query,1,60) as query ,
planid ,plan_type, plan_captured_time,explain_plan,calls, 
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from aurora_stat_plans()
where calls !=0
order by total_time_Msec desc limit 50;
\qecho </details>

\qecho <br>
\qecho <h3> Top 50 plan order by avg_time: </h3>
\qecho <br>
\qecho <details>
select queryid,substring(query,1,60) as query ,
planid ,plan_type, plan_captured_time,explain_plan, calls,
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from aurora_stat_plans()
where calls !=0
order by avg_time_Msec desc limit 50;
\qecho </details>

\qecho <br>
\qecho <h3> Top 50 plan order by percent of total DB time percent: </h3>
\qecho <br>
\qecho <details>
select queryid,substring(query,1,60) as query ,
planid ,plan_type, plan_captured_time,explain_plan, calls, 
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from aurora_stat_plans()
where calls !=0
order by percent desc limit 50;
\qecho </details>

\qecho <br>
\qecho <h3> Top 50 plan order by number of execution (CALLs): </h3>
\qecho <br>
\qecho <details>
select queryid,substring(query,1,60) as query ,
planid ,plan_type, plan_captured_time,explain_plan, calls,
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from aurora_stat_plans()
where calls !=0
order by calls desc limit 50;
\qecho </details>

\qecho <br>
\qecho <h3> Top 50 plan by shared blocks read (physical reads) from Aurora storage: </h3>
\qecho <br>
\qecho <details>
select queryid, substring(query,1,60) as query ,
planid ,plan_type, plan_captured_time,explain_plan, calls,
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent,
shared_blks_read,orcache_blks_hit,
storage_blks_read
from aurora_stat_plans()
where calls !=0
order by storage_blks_read desc limit 50;
\qecho </details>
\qecho <br>
\qecho <h3> Listing Queries ID that have more then one plan (query id/plans_count) : </h3>
\qecho <br>
\qecho <details>
-- calls !=0 >> to filter out canceled sqls 
-- planid <> 0 >> to filter out non plannable statement (plan_type =no plan)
select dbid,queryid , count(planid) as plans_count 
from aurora_stat_plans()
where planid <> 0
group by dbid,queryid
having count(planid) > 1 
order by 3;
\qecho </details>
\qecho <br>
\qecho <h3> Listing Queries with Multiple Execution Plans : </h3>
\qecho <br>
\qecho <details>
-- calls !=0 >> to filter out canceled sqls 
-- planid <> 0 >> to filter out non plannable statement (plan_type =no plan)
select dbid,queryid,substring(query,1,60) as query ,
planid ,plan_type, plan_captured_time,explain_plan, calls,
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from aurora_stat_plans() where queryid in (select queryid 
from aurora_stat_plans()
where planid <> 0
group by dbid,queryid
having count(planid) > 1
) 
and calls !=0
order by queryid,dbid,  total_time_Msec desc;
\qecho </details>
\else
    \if yes
        \qecho 'aurora_stat_plans function is only available staring from Aurora PostgreSQL version 15.5'
    \endif
\endif
\else
    \if yes
        \qecho 'This is not Aurora instance'
    \endif
\endif
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - logical_replication_write_through_cache          -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="logical_replication_write_through_cache"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Logical replication write-through cache</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
select count(*) > 0 isaurora from pg_settings where name='rds.extensions' and setting like '%aurora_stat_utils%' \gset
\if :isaurora
SELECT * FROM aurora_stat_logical_wal_cache();
\else
    \if yes
        \qecho 'This is not Aurora instance'
    \endif
\endif
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


\echo Report Generated Successfully
\echo Report name and location: /tmp/pg_collector_:filename.html
\q
