-- +-----------------------------------------------------------------------------------+
-- |  -- Script Name: pg_collector.sql                                                 |
-- |  -- Author : Mohamed Ali                                                          |
-- |  -- Create Date : 16 SEPT 2019                                                    |
-- |  -- Description : Script to Collect PostgreSQL Database Informations              |
-- |                   and generate HTML Report                                        |
-- |  -- version : V 2.7                                                               |
-- |  -- Changelog : https://github.com/awslabs/pg-collector/blob/main/CHANGELOG.md    |                                                                |
-- | Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.                |
-- | SPDX-License-Identifier: MIT-0                                                    |
-- +-----------------------------------------------------------------------------------+
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
\qecho <h1 align="center" style="background-color:#e59003" > PG COLLECTOR  V2.7 </h1>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>DB INFO</b></font><hr align="left" width="460">
\qecho <br>
\qecho 'PG Hostname / PG RDS ENDPOINT: ':HOST
\qecho <br>
\qecho <br>
select  now () as "Date" ,pg_postmaster_start_time() as "DB_START_DATE", current_timestamp - pg_postmaster_start_time() as "UP_TIME"  ,current_database() as "DB_connected" ,current_user USER_NAME,inet_server_port() as "DB_PORT ",version()  as "DB_Version" , setting AS block_size FROM pg_settings WHERE name = 'block_size';
\qecho <br>
\qecho <br>
\l+
\qecho <br>
select datname as Database_name , datistemplate as database_is_template ,datallowconn as database_allow_connections, datconnlimit as database_connection_limit , datlastsysoid ,datfrozenxid ,datminmxid   from pg_database; 
\qecho <br>
\qecho <br>
\qecho <table width="90%" border="1"> 
\qecho <tr><th colspan="4"><div align="center"><font color="#16191f"><b>INFO</b></font></div></th></tr> 
\qecho <tr> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Database_size">Database size</a></td> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#DB_parameters">DB parameters</a></td> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Transaction_ID_TXID">Transaction ID TXID</a></td> 
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
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Tabel_Access_Profile">Tabel Access Profile</a></td> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Unused_Indexes">Unused Indexes</a></td> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Index_Access_Profile">Index Access Profile</a></td> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Fragmentation">Fragmentation (Bloat)</a></td> 
\qecho </tr>
\qecho <tr>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Toast_Tables_Mapping">Toast Tables Mapping</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Replication_slot">Replication slot</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#active_session_monitor">active sessions monitor</a></td>
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
\qecho <td nowrap align="center" width="25%"><a class="link" href="#******">******</a></td>
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
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Transaction ID TXID</b></font><hr align="left" width="460">
SELECT max(age(datfrozenxid)) oldest_current_xid FROM pg_database;
\qecho <br>
SELECT datname database_name ,age(datfrozenxid) oldest_current_xid_per_DB FROM pg_database;
\qecho <br>
WITH max_age AS ( SELECT 2000000000 as max_old_xid , setting AS autovacuum_freeze_max_age FROM pg_catalog.pg_settings WHERE name = 'autovacuum_freeze_max_age' ) , per_database_stats AS ( SELECT datname , m.max_old_xid::int , m.autovacuum_freeze_max_age::int , age(d.datfrozenxid) AS oldest_current_xid FROM pg_catalog.pg_database d JOIN max_age m ON (true) WHERE d.datallowconn ) SELECT max(oldest_current_xid) AS oldest_current_xid , max(ROUND(100*(oldest_current_xid/max_old_xid::float))) AS percent_towards_wraparound , max(ROUND(100*(oldest_current_xid/autovacuum_freeze_max_age::float))) AS percent_towards_emergency_autovac FROM per_database_stats ;
--To find out which tables are aging
\qecho <h3>which tables are aging : </h3>
SELECT c.oid::regclass as relation_name,     
        greatest(age(c.relfrozenxid),age(t.relfrozenxid)) as age,
        pg_size_pretty(pg_table_size(c.oid)) as table_size,
        c.relkind
FROM pg_class c
LEFT JOIN pg_class t ON c.reltoastrelid = t.oid
WHERE c.relkind in ('r', 't','m')
order by 2 desc limit 20;

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Table_Size                                   -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Table_Size"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Table Size</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h3>Table Size order by schema name and table name:</h3>
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
order by 2,3 ;
\qecho <br>
\qecho <h3>biggest 50 tables in the DB: </h3>
\qecho <br>
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

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - index_Size                                    -                  |
-- +----------------------------------------------------------------------------+

\qecho <a name="index_Size"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Index_Size</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h3>Index Size order by schema name :</h3>
SELECT
schemaname,relname as "Table",
indexrelname AS indexname,
pg_relation_size(indexrelid),
pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_catalog.pg_statio_all_indexes  ORDER BY 1,4 desc ;
\qecho <br>
\qecho <h3>biggest 50 Index in the DB :</h3>
\qecho <br>
SELECT
schemaname,relname as "Table",
indexrelname AS indexname,
pg_relation_size(indexrelid),
pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_catalog.pg_statio_all_indexes  ORDER BY 4 desc limit 50;


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - vacuum and Statistics           -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="vacuum_Statistics"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Vacuum & Statistics</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h3>Autovacuum Parameters :</h3>
SELECT * from pg_settings where category like 'Autovacuum';
\qecho <br>
SELECT *  FROM pg_settings where name in ('rds.force_autovacuum_logging_level','log_autovacuum_min_duration') order by category;
\qecho <br>
-- currnt running  vacuum porecess
\qecho <h3>currnt running autovacuum porecess:</h3>
SELECT datname,usename,state,query,now() - pg_stat_activity.query_start AS duration, wait_event from pg_stat_activity where query like 'autovacuum:%' order by 4;
\qecho <br>
--  Whenever VACUUM is running, the pg_stat_progress_vacuum view will contain one row for each backend (including autovacuum worker processes) that is currently vacuuming (vacuum porgress)
\qecho <h3>Vacuum porgress:</h3>
SELECT p.pid, now() - a.xact_start AS duration, coalesce(wait_event_type ||'.'|| wait_event, 'f') AS waiting, CASE WHEN a.query ~ '^autovacuum.*to prevent wraparound' THEN 'wraparound' WHEN a.query ~ '^vacuum' THEN 'user' ELSE 'regular' END AS mode, p.datname AS database, p.relid::regclass AS table, p.phase, pg_size_pretty(p.heap_blks_total * current_setting('block_size')::int) AS table_size, pg_size_pretty(pg_total_relation_size(relid)) AS total_size, pg_size_pretty(p.heap_blks_scanned * current_setting('block_size')::int) AS scanned, pg_size_pretty(p.heap_blks_vacuumed * current_setting('block_size')::int) AS vacuumed, round(100.0 * p.heap_blks_scanned / p.heap_blks_total, 1) AS scanned_pct, round(100.0 * p.heap_blks_vacuumed / p.heap_blks_total, 1) AS vacuumed_pct, p.index_vacuum_count, round(100.0 * p.num_dead_tuples / p.max_dead_tuples,1) AS dead_pct FROM pg_stat_progress_vacuum p JOIN pg_stat_activity a using (pid) ORDER BY now() - a.xact_start DESC;
\qecho <br>
\qecho <h3>Autovacuum progress per day : </h3>
select to_char(last_autovacuum, 'YYYY-MM-DD') , count(*) from pg_stat_all_tables   group by to_char(last_autovacuum, 'YYYY-MM-DD') order by 1;
\qecho <br>
\qecho <h3>Autoanalyze progress per day : </h3>
select to_char(last_autoanalyze, 'YYYY-MM-DD') , count(*) from pg_stat_all_tables   group by to_char(last_autoanalyze, 'YYYY-MM-DD') order by 1;

--Which tables are currently eligible for autovacuum based on curret parameters
\qecho <h3>Which tables are currently eligible for autovacuum based on curret parameters : </h3>
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
\qecho <br>
-- check if the statistics collector is enabled (track_counts is on)
\qecho <h3>Check if the statistics collector is enabled (track_counts is on) : </h3>
SELECT name, setting FROM pg_settings WHERE name='track_counts';
\qecho <br>
-- to check the number of dead rows for the top 50 table
\qecho <h3>Number of dead rows for the top 50 table : </h3>
select relname,n_live_tup, n_tup_upd, n_tup_del, n_dead_tup, last_vacuum, last_autovacuum, last_analyze, last_autoanalyze  from pg_stat_all_tables order by n_dead_tup desc limit 50;
\qecho <br>
\qecho <h3>Tables have more than 20% dead rows :</h3>
select schemaname,relname , last_vacuum,last_autovacuum,n_live_tup,n_dead_tup , trunc((n_dead_tup::numeric/nullif(n_live_tup+n_dead_tup,0))* 100,2) as "n_dead_tup_%" from pg_stat_user_tables where n_dead_tup::float/nullif(n_live_tup+n_dead_tup,0) >.2 order by n_live_tup desc ;
\qecho <br>
\qecho <h3>pg_stat_all_tables : </h3>
select relname,schemaname,last_vacuum,last_autovacuum,last_analyze,last_autoanalyze,vacuum_count,autovacuum_count,analyze_count,autoanalyze_count from pg_stat_all_tables  where schemaname not in ('pg_catalog','pg_toast') order by 2;
\qecho <br>
\qecho <h3>pg_stat_all_tables order by autovacuum_count : </h3>
select relname,schemaname,last_vacuum,last_autovacuum,last_analyze,last_autoanalyze,vacuum_count,autovacuum_count,analyze_count,autoanalyze_count from pg_stat_all_tables  where schemaname not in ('pg_catalog','pg_toast') order by autovacuum_count desc;
\qecho <br>
\qecho <h3>pg_stat_all_tables order by autoanalyze_count: </h3>
select relname,schemaname,last_vacuum,last_autovacuum,last_analyze,last_autoanalyze,vacuum_count,autovacuum_count,analyze_count,autoanalyze_count from pg_stat_all_tables  where schemaname not in ('pg_catalog','pg_toast') order by autoanalyze_count desc;
\qecho <br>
\qecho <h3>tables without auto analyze : </h3>
select relname,schemaname,last_vacuum,last_autovacuum,last_analyze,last_autoanalyze from pg_stat_all_tables  where  last_autoanalyze is null order by 2;
\qecho <br>
\qecho <h3>tables without auto vacuum : </h3>
select relname,schemaname,last_vacuum,last_autovacuum,last_analyze,last_autoanalyze from pg_stat_all_tables  where  last_autovacuum is null order by 2;
\qecho <br>
\qecho <h3>tables without auto analyze,auto vacuum,vacuum and analyze : </h3>
select relname,schemaname,last_vacuum,last_autovacuum,last_analyze,last_autoanalyze from pg_stat_all_tables  where  last_autovacuum is null and last_autoanalyze is null and last_analyze is null and last_vacuum is null ;
\qecho <br>
-- to show tables that have specific table-level parameters set
\qecho <h3>Tables that have specific table-level parameters set : </h3>
select relname, reloptions from pg_class where reloptions is not null;


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - Extensions                                     -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Extensions"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Extensions</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h3>shared_preload_libraries parameter: </h3>
show shared_preload_libraries;
\qecho <br>
\qecho <h3>Installed extension :  </h3>
SELECT e.extname AS "Extension Name", e.extversion AS "Version", n.nspname AS "Schema",pg_get_userbyid(e.extowner)  as Owner,  c.description AS "Description" , e.extrelocatable as "relocatable to another schema", e.extconfig ,e.extcondition
FROM pg_catalog.pg_extension e LEFT JOIN pg_catalog.pg_namespace n ON n.oid = e.extnamespace LEFT JOIN pg_catalog.pg_description c ON c.objoid = e.oid AND c.classoid = 'pg_catalog.pg_extension'::pg_catalog.regclass
ORDER BY 1;
\qecho <br>
\qecho <h3>Available Extension versions that are available to upgarde the instaelled Extension: </h3>
select b.name as extension_name , b.version as version ,b.installed as installed
from
(SELECT extname ,extversion FROM pg_extension) a ,
(SELECT name ,version ,installed FROM pg_available_extension_versions where name in (SELECT extname FROM pg_extension)) b
where a.extname = b.name
and b.version > a.extversion
order by b.name , b.version;
\qecho <br>
\qecho <h3>Latest Extension version that is available to upgarde the instaelled Extension: </h3>
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
\qecho <br>
\qecho <h3>Available extensions: </h3>
select * from pg_available_extension_versions order by name,version;
select * from pg_available_extensions order by installed_version;

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Memory setting                                   -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Memory_setting"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Memory setting</b></font><hr align="left" width="460">
(
select name as parameter_name , setting , unit, (setting::BIGINT/1024)::BIGINT  as "size_MB" ,(setting::BIGINT/1024/1024)::BIGINT  as "size_GB" ,  pg_size_pretty((setting::BIGINT*1024)::BIGINT)   
from pg_settings where name in ('work_mem','maintenance_work_mem')
)
UNION ALL
(
select name as parameter_name, setting , unit , (((setting::BIGINT)*8)/1024)::BIGINT  as "size_MB" ,(((setting::BIGINT)*8)/1024/1024)::BIGINT  as "size_GB", pg_size_pretty((((setting::BIGINT)*8)*1024)::BIGINT)  
from pg_settings where name in ('shared_buffers','wal_buffers','effective_cache_size')
) order by 4  desc;


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - pg_stat_statements extension                                    -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="pg_stat_statements_extension"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>pg_stat_statements extension</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h3> pg_stat_statements installed version: </h3>
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
\qecho <br>
\qecho <h3> Top SQL order by total_time: </h3>
--Top SQL order by total_time
select substring(query,1,60) as query , calls, 
round(total_time::numeric, 2) as total_time_Msec, 
round((total_time::numeric/1000), 2) as total_time_sec,
round(mean_time::numeric,2) as avg_time_Msec,
round((mean_time::numeric/1000),2) as avg_time_sec,
round(stddev_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_time / sum(total_time) over ())::numeric, 4) as percent
from pg_stat_statements 
order by total_time_Msec desc limit 20;
\qecho <br>
\qecho <h3> Top SQL order by avg_time: </h3>
--Top SQL order by avg_time
select substring(query,1,60) as query , calls,
round(total_time::numeric, 2) as total_time_Msec, 
round((total_time::numeric/1000), 2) as total_time_sec,
round(mean_time::numeric,2) as avg_time_Msec,
round((mean_time::numeric/1000),2) as avg_time_sec,
round(stddev_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_time / sum(total_time) over ())::numeric, 4) as percent
from pg_stat_statements 
order by avg_time_Msec desc limit 20;
\qecho <br>
\qecho <h3> Top SQL order by percent of total DB time percent: </h3>
--Top SQL order by percent of total DB time
select substring(query,1,60) as query , calls, 
round(total_time::numeric, 2) as total_time_Msec, 
round((total_time::numeric/1000), 2) as total_time_sec,
round(mean_time::numeric,2) as avg_time_Msec,
round((mean_time::numeric/1000),2) as avg_time_sec,
round(stddev_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_time / sum(total_time) over ())::numeric, 4) as percent
from pg_stat_statements 
order by percent desc limit 20;
\qecho <br>
\qecho <h3> Top SQL order by number of execution (CALLs): </h3>
--Top SQL order by number of execution (CALLs)  
select substring(query,1,60) as query , calls,
round(total_time::numeric, 2) as total_time_Msec, 
round((total_time::numeric/1000), 2) as total_time_sec,
round(mean_time::numeric,2) as avg_time,
round((mean_time::numeric/1000),2) as avg_time,
round(stddev_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_time / sum(total_time) over ())::numeric, 4) as percent
from pg_stat_statements 
order by calls desc limit 20;


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Users_Roles_Info                                  -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Users_Roles_Info"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Users & Roles Info</b></font><hr align="left" width="460">
\qecho <br>
\du
\qecho <br>
-- list of per database role settings (settings set at the role level)
\drds
\qecho <br>
select * FROM pg_user;


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Schema_Info                                    -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Schema_Info"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Schema Info</b></font><hr align="left" width="460">
\qecho <br>
-- List of schema
\dn+


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Tablespaces_Info                                   -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Tablespaces_Info"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Tablespaces Info</b></font><hr align="left" width="460">
\qecho <br>
\db
\qecho <br>
\qecho <h3> Tablsapces Location : </h3>
--tablsapces location 
SELECT 
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
AS      spclocation,               
spcname 
FROM 
pg_tablespace;


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      -Tabel_Access_Profile                                    -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Tabel_Access_Profile"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Tabel Access Profile</b></font><hr align="left" width="460">
\qecho <br> 
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
\qecho <br>
\qecho <h3> Tables have more full table scan than index scan : </h3>
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
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Unused_Indexes                                   -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Unused_Indexes"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Unused Indexes</b></font><hr align="left" width="460">
\qecho <br>
SELECT schemaname,relname AS tablename,
indexrelname AS indexname,
idx_scan ,
pg_relation_size(indexrelid) as index_size,
pg_size_pretty(pg_relation_size(indexrelid)) AS pretty_index_size
FROM pg_catalog.pg_stat_all_indexes
WHERE idx_scan = 0 
and schemaname not in ('pg_catalog')
order by index_size desc;

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - Index_Access_Profile                                    -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Index_Access_Profile"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Index Access Profile</b></font><hr align="left" width="460">
\qecho <br>
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

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Fragmentation                                    -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Fragmentation"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Fragmentation (Bloat)</b></font><hr align="left" width="460">
-- Show database bloat
\qecho <br>
\qecho <h3>Tables and indexes Bloat [Fragmentation] order by table wasted size :</h3>
SELECT
  current_database(), schemaname, tablename, /*reltuples::bigint, relpages::bigint, otta,*/
  ROUND((CASE WHEN otta=0 THEN 0.0 ELSE sml.relpages::FLOAT/otta END)::NUMERIC,1) AS "table_bloat_%",
  CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::BIGINT END AS wastedbytes,
  pg_size_pretty(CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::BIGINT END) AS table_wasted_size,
  iname AS Index_nam, /*ituples::bigint, ipages::bigint, iotta,*/
  ROUND((CASE WHEN iotta=0 OR ipages=0 THEN 0.0 ELSE ipages::FLOAT/iotta END)::NUMERIC,1) AS "Index_bloat_%",
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
\qecho <h3>Tables and indexes Bloat [Fragmentation] order by table wasted % :</h3>
SELECT
  current_database(), schemaname, tablename, /*reltuples::bigint, relpages::bigint, otta,*/
  ROUND((CASE WHEN otta=0 THEN 0.0 ELSE sml.relpages::FLOAT/otta END)::NUMERIC,1) AS "table_bloat_%",
  CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::BIGINT END AS wastedbytes,
  pg_size_pretty(CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::BIGINT END) AS table_wasted_size,
  iname AS Index_nam, /*ituples::bigint, ipages::bigint, iotta,*/
  ROUND((CASE WHEN iotta=0 OR ipages=0 THEN 0.0 ELSE ipages::FLOAT/iotta END)::NUMERIC,1) AS "Index_bloat_%",
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

\qecho <br>
\qecho <h3>Tables and indexes Bloat [Fragmentation] order by index wasted % :</h3>
SELECT
  current_database(), schemaname, tablename, /*reltuples::bigint, relpages::bigint, otta,*/
  ROUND((CASE WHEN otta=0 THEN 0.0 ELSE sml.relpages::FLOAT/otta END)::NUMERIC,1) AS "table_bloat_%",
  CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::BIGINT END AS wastedbytes,
  pg_size_pretty(CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::BIGINT END) AS table_wasted_size,
  iname AS Index_nam, /*ituples::bigint, ipages::bigint, iotta,*/
  ROUND((CASE WHEN iotta=0 OR ipages=0 THEN 0.0 ELSE ipages::FLOAT/iotta END)::NUMERIC,1) AS "Index_bloat_%",
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



\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Toast_Tables_Mapping                                  -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Toast_Tables_Mapping"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Toast Tables Mapping</b></font><hr align="left" width="460">
select t.relname table_name, r.relname toast_name, pg_size_pretty(pg_relation_size(t.reltoastrelid)) as toast_size
FROM
    pg_class r
INNER JOIN pg_class t ON r.oid = t.reltoastrelid
order by r.relname ;


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - Replication_slot                                   -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Replication_slot"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Replication slot</b></font><hr align="left" width="460">
\qecho <h3> Active replication slots :</h3> 
select * from pg_replication_slots where active = true;
\qecho <h3> Inactive replication slots :</h3> 
select * from pg_replication_slots where active = false;
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


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - active_session_monitor                                            - |
-- +----------------------------------------------------------------------------+

\qecho <a name="active_session_monitor"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>active sessions monitor</b></font><hr align="left" width="460">

/* active_session_monitor_watch5sec.sql */ select * from
(
    SELECT
usename,pid, now() - pg_stat_activity.xact_start AS xact_duration ,now() - pg_stat_activity.query_start AS query_duration,
substr(query,1,50) as query,state,wait_event
FROM pg_stat_activity
) as s where (xact_duration is not null  or query_duration is not null ) and state!='idle' and query not like '%active_session_monitor_watch5sec.sql%'
order by xact_duration desc, query_duration desc;

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - Orphaned_prepared_transactions                   -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Orphaned_prepared_transactions"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Orphaned prepared transactions</b></font><hr align="left" width="460">
SELECT gid, prepared, owner, database, transaction AS xmin
FROM pg_prepared_xacts
ORDER BY age(transaction) DESC; 

\qecho <br>
\qecho <h3> Note:</h3>
\qecho <h4> During two-phase commit, a distributed transaction is first prepared with the PREPARE statement and then committed with the COMMIT PREPARED statement </h4>
\qecho <h4> Once a transaction has been prepared, it is kept “hanging around” until it is committed or aborted. It </h4> 
\qecho <h4> even has to survive a server restart! Normally, transactions don’t remain in the prepared state for long,  </h4>
\qecho <h4> but sometimes things go wrong and a prepared transaction has to be removed manually by an administrator.  </h4>
\qecho <h4> any Orphaned prepared transactions will prevent the VACUUM to remove the dead rows   </h4>               
\qecho <h4>  EXAMPLE: DETAIL:  50000 dead row versions cannot be removed yet,oldest xmin: 22300 </h4>
\qecho <br>
\qecho <h4>  Use the ROLLBACK PREPARED transaction_id SQL statement to  remove prepared transactions    </h4>


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - PK_FK_using_numeric_or_integer_data_type         -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="PK_FK_using_numeric_or_integer_data_type"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>PK or FK using numeric or integer data type</b></font><hr align="left" width="460">
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


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - public_Schema                                  -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="public_Schema"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>public Schema</b></font><hr align="left" width="460">
-- object / count
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

-- list of object

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

-- list of function

select nsp.nspname as schema,
       rol.rolname as owner, 
       f.proname as function_name       
from pg_proc f
  join pg_roles rol on rol.oid = f.proowner
  join pg_namespace nsp on nsp.oid = f.pronamespace
where nsp.nspname ='public'
order by 1,2;


-- list of triggers

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


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - invalid_indexes                                 -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="invalid_indexes"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>invalid indexes</b></font><hr align="left" width="460">
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


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - default_access_privileges                                    -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="default_access_privileges"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Default access privileges</b></font><hr align="left" width="460">
SELECT pg_catalog.pg_get_userbyid(d.defaclrole) AS "Owner",
  n.nspname AS "Schema",
  CASE d.defaclobjtype WHEN 'r' THEN 'table' WHEN 'S' THEN 'sequence' WHEN 'f' THEN 'function' WHEN 'T' THEN 'type' WHEN 'n' THEN 'schema' ELSE 'unknown' END AS "Type", 
pg_catalog.array_to_string(d.defaclacl, E'\n') AS "Access privileges"
FROM pg_catalog.pg_default_acl d
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = d.defaclnamespace
ORDER BY 1, 2, 3;

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - pgaudit_extension                                  -                |
-- +----------------------------------------------------------------------------+


\qecho <a name="pgaudit_extension"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>pgaudit extension</b></font><hr align="left" width="460">
SELECT e.extname AS "Extension Name", e.extversion AS "Version", n.nspname AS "Schema",pg_get_userbyid(e.extowner)  as Owner, c.description AS "Description" , e.extrelocatable as "relocatable to another schema", e.extconfig ,e.extcondition
 FROM pg_catalog.pg_extension e LEFT JOIN pg_catalog.pg_namespace n ON n.oid = e.extnamespace LEFT JOIN pg_catalog.pg_description c ON c.objoid = e.oid AND c.classoid = 'pg_catalog.pg_extension'::pg_catalog.regclass
 where e.extname = 'pgaudit';
\qecho <br>
SELECT name as "parameter_name", setting from pg_settings where name like 'pgaudit.%' or name = 'shared_preload_libraries';
\qecho <br>
\qecho <h3>pgaudit user level configuration : </h3>
select usename as user_name,useconfig as user_config FROM pg_user where useconfig::text like '%pgaudit.%';



\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - unlogged_tables                                    -                |
-- +----------------------------------------------------------------------------+


\qecho <a name="unlogged_tables"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Unlogged Tables</b></font><hr align="left" width="460">
\qecho <h3>Number of Unlogged Tables : </h3>
select count (*) FROM pg_class WHERE relpersistence = 'u';
\qecho <br>
select relname as table_name, relpersistence FROM pg_class WHERE relpersistence = 'u';


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - access_privileges                                    -              |
-- +----------------------------------------------------------------------------+


\qecho <a name="access_privileges"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Access privileges</b></font><hr align="left" width="460">

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

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - ssl   -                                                             |
-- +----------------------------------------------------------------------------+


\qecho <a name="ssl"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>ssl</b></font><hr align="left" width="460">
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

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |      - background_processes                                   -            |
-- +----------------------------------------------------------------------------+


\qecho <a name="background_processes"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Background processes</b></font><hr align="left" width="460">
\qecho <h3>Count of Postgres background processess : </h3>
select count (*) as "Background processes count" FROM pg_stat_activity where datname is null ;
\qecho <br>
SELECT  pid , backend_type as  "Background processes Type" , backend_start as "start time" FROM pg_stat_activity where datname is null order by 3 ;

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - DB_parameters                                    -                  |
-- +----------------------------------------------------------------------------+

\qecho <a name="DB_parameters"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>DB parameters</b></font><hr align="left" width="460">

SELECT *  FROM pg_settings where name not in ('rds.extensions') order by category;
SELECT *  FROM pg_settings where name in ('rds.extensions') order by category;

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |      - *************                                    -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="-----"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>*****</b></font><hr align="left" width="460">
-- sql

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>


\q
