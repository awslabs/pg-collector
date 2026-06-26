-- +-------------------------------------------------------------------------------------------------------------+
-- |  -- Script Name: pg_collector.sql                                                                           |
-- |  -- Author : Mohamed Ali                                                                                    |
-- |  -- Create Date : 16 SEPT 2019                                                                              |
-- |  -- Description : Script to collect PostgreSQL Database Information and generate HTML Report                |
-- |  -- version : V1 for PostgreSQL 19                                                                          |
-- |  -- Changelog : https://github.com/awslabs/pg-collector/blob/pg-collector-for-postgresql-19/CHANGELOG.md    | 
-- | Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.                                          |
-- | SPDX-License-Identifier: MIT-0                                                                              |
-- +-------------------------------------------------------------------------------------------------------------+
-- +-------------------------------------------------------------------------------------------------------------+
-- | Selective Section Execution                                                                                 |
-- | Usage: psql -v fullmod=f -v vacuum=t -v replication=t -f pg_collector.sql                                   |
-- | Help:  psql -v help=t -f pg_collector.sql                                                                   |
-- +-------------------------------------------------------------------------------------------------------------+
\set help :help
SELECT CASE WHEN :'help' = ':help' THEN 'f' ELSE :'help' END AS "help" \gset
\if :help
\echo ''
\echo 'PG Collector - Available Sections:'
\echo ''
\echo '  Variable Name     Description'
\echo '  -------------     -----------'  
\echo '  observations    - Observations (Health checks)'
\echo '  db_size         - Database size'
\echo '  txid            - Transaction ID TXID (Wraparound)'
\echo '  table_size      - Table Size'
\echo '  index_size      - Index Size'
\echo '  vacuum          - Vacuum & Statistics'
\echo '  extensions      - Extensions'
\echo '  memory          - Memory setting'
\echo '  pgss            - pg_stat_statements extension'
\echo '  users           - Users & Roles Info'
\echo '  schema          - Schema Info'
\echo '  tablespaces     - Tablespaces Info'
\echo '  table_access    - Table Access Profile'
\echo '  unused_idx      - Unused Indexes'
\echo '  index_access    - Index Access Profile'
\echo '  bloat           - Fragmentation (Bloat)'
\echo '  toast           - Toast Tables Mapping'
\echo '  replication     - Replication'
\echo '  sessions        - Sessions/Connections Info'
\echo '  prepared_txn    - Orphaned prepared transactions'
\echo '  pk_fk           - PK or FK using numeric/integer'
\echo '  public_schema   - public Schema'
\echo '  invalid_idx     - Invalid indexes'
\echo '  privileges      - Access privileges'
\echo '  default_privileges - Default access privileges'
\echo '  pgaudit         - pgaudit extension'
\echo '  unlogged_tables - Unlogged Tables'
\echo '  ssl             - SSL'
\echo '  bg_processes    - Background processes'
\echo '  mxid            - Multixact ID MXID'
\echo '  temp            - Temp Tables & Files'
\echo '  large_objects   - Large objects'
\echo '  partitions      - Partition tables'
\echo '  sequences       - Sequences'
\echo '  pg_hba          - pg_hba.conf'
\echo '  dup_idx         - Duplicate indexes'
\echo '  functions       - Functions statistics'
\echo '  db_load         - DB Load'
\echo '  triggers        - Triggers'
\echo '  pg_config       - pg_config'
\echo '  db_params       - DB parameters'
\echo '  copy_progress   - COPY command progress'
\echo '  idx_progress    - Index Creation Progress'
\echo '  invalid_db      - Invalid databases'
\echo '  mat_views       - Materialized Views'
\echo '  foreign_servers - Foreign Servers'
\echo '  pg_shdepend     - pg_shdepend (shared object dependencies)'
\echo '  fk_no_index     - FK without index'
\echo ''
\echo '  ---------- Aurora PostgreSQL ----------'
\echo '  aurora_version          - Aurora version'
\echo '  aurora_builtins         - Aurora built-in functions'
\echo '  aurora_instance_id      - Aurora db instance identifier'
\echo '  aurora_cluster          - Aurora cluster instances'
\echo '  aurora_replica_lag      - Aurora reader instances - Replica Lag'
\echo '  aurora_ccm              - Aurora cluster cache management (CCM)'
\echo '  aurora_global_db        - Aurora global db status'
\echo '  aurora_wait_events      - Aurora wait event stat'
\echo '  aurora_qpm              - Query Plan Management (QPM)'
\echo '  aurora_dml              - Aurora DML activity'
\echo '  aurora_memctx           - Process memory context usage'
\echo '  aurora_stat_stmt        - Aurora_stat_statements'
\echo '  aurora_stat_plans       - Aurora_stat_plans'
\echo '  aurora_wal_cache        - Logical replication write-through cache'
\echo ''
\echo '  ---------- Aurora Limitless ----------'
\echo '  limitless_routers       - Routers & Shards Info'
\echo '  limitless_params        - Limitless parameters'
\echo '  limitless_databases     - Limitless databases'
\echo '  limitless_extensions    - Limitless Extensions'
\echo '  limitless_txid          - Limitless Transaction ID TXID'
\echo '  limitless_tables        - Limitless Tables'
\echo '  limitless_stat_stmt     - limitless_stat_statements'
\echo '  limitless_msq           - Multi shard queries (MSQ)'
\echo '  limitless_sso           - Single Shard Optimized (SSO)'
\echo '  limitless_sessions      - Limitless Sessions/Connections'
\echo '  limitless_dist_sess     - Distributed sessions info'
\echo '  limitless_wait_events   - Limitless Database Load (Wait events)'
\echo ''
\echo 'Usage:'
\echo '  psql -v fullmod=f -v vacuum=t -v replication=t -f pg_collector.sql'
\echo '  psql -f pg_collector.sql   (runs all sections - default)'
\echo ''
\quit
\endif
SET statement_timeout = '5min';
\echo 'statement_timeout set to 5 minutes. To change, edit the SET statement_timeout line in the script.'
-- Resolve fullmod: default 't' (full mode) if not passed
\set fullmod :fullmod
SELECT CASE WHEN :'fullmod' = ':fullmod' THEN 't' ELSE :'fullmod' END AS "fullmod" \gset
-- Resolve section variables
\set observations :observations
SELECT CASE WHEN :'observations' = ':observations' THEN 'f' ELSE :'observations' END AS "observations" \gset
\set db_size :db_size
SELECT CASE WHEN :'db_size' = ':db_size' THEN 'f' ELSE :'db_size' END AS "db_size" \gset
\set txid :txid
SELECT CASE WHEN :'txid' = ':txid' THEN 'f' ELSE :'txid' END AS "txid" \gset
\set table_size :table_size
SELECT CASE WHEN :'table_size' = ':table_size' THEN 'f' ELSE :'table_size' END AS "table_size" \gset
\set index_size :index_size
SELECT CASE WHEN :'index_size' = ':index_size' THEN 'f' ELSE :'index_size' END AS "index_size" \gset
\set vacuum :vacuum
SELECT CASE WHEN :'vacuum' = ':vacuum' THEN 'f' ELSE :'vacuum' END AS "vacuum" \gset
\set extensions :extensions
SELECT CASE WHEN :'extensions' = ':extensions' THEN 'f' ELSE :'extensions' END AS "extensions" \gset
\set memory :memory
SELECT CASE WHEN :'memory' = ':memory' THEN 'f' ELSE :'memory' END AS "memory" \gset
\set pgss :pgss
SELECT CASE WHEN :'pgss' = ':pgss' THEN 'f' ELSE :'pgss' END AS "pgss" \gset
\set users :users
SELECT CASE WHEN :'users' = ':users' THEN 'f' ELSE :'users' END AS "users" \gset
\set schema :schema
SELECT CASE WHEN :'schema' = ':schema' THEN 'f' ELSE :'schema' END AS "schema" \gset
\set tablespaces :tablespaces
SELECT CASE WHEN :'tablespaces' = ':tablespaces' THEN 'f' ELSE :'tablespaces' END AS "tablespaces" \gset
\set table_access :table_access
SELECT CASE WHEN :'table_access' = ':table_access' THEN 'f' ELSE :'table_access' END AS "table_access" \gset
\set unused_idx :unused_idx
SELECT CASE WHEN :'unused_idx' = ':unused_idx' THEN 'f' ELSE :'unused_idx' END AS "unused_idx" \gset
\set index_access :index_access
SELECT CASE WHEN :'index_access' = ':index_access' THEN 'f' ELSE :'index_access' END AS "index_access" \gset
\set bloat :bloat
SELECT CASE WHEN :'bloat' = ':bloat' THEN 'f' ELSE :'bloat' END AS "bloat" \gset
\set toast :toast
SELECT CASE WHEN :'toast' = ':toast' THEN 'f' ELSE :'toast' END AS "toast" \gset
\set replication :replication
SELECT CASE WHEN :'replication' = ':replication' THEN 'f' ELSE :'replication' END AS "replication" \gset
\set sessions :sessions
SELECT CASE WHEN :'sessions' = ':sessions' THEN 'f' ELSE :'sessions' END AS "sessions" \gset
\set prepared_txn :prepared_txn
SELECT CASE WHEN :'prepared_txn' = ':prepared_txn' THEN 'f' ELSE :'prepared_txn' END AS "prepared_txn" \gset
\set pk_fk :pk_fk
SELECT CASE WHEN :'pk_fk' = ':pk_fk' THEN 'f' ELSE :'pk_fk' END AS "pk_fk" \gset
\set public_schema :public_schema
SELECT CASE WHEN :'public_schema' = ':public_schema' THEN 'f' ELSE :'public_schema' END AS "public_schema" \gset
\set invalid_idx :invalid_idx
SELECT CASE WHEN :'invalid_idx' = ':invalid_idx' THEN 'f' ELSE :'invalid_idx' END AS "invalid_idx" \gset
\set privileges :privileges
SELECT CASE WHEN :'privileges' = ':privileges' THEN 'f' ELSE :'privileges' END AS "privileges" \gset
\set default_privileges :default_privileges
SELECT CASE WHEN :'default_privileges' = ':default_privileges' THEN 'f' ELSE :'default_privileges' END AS "default_privileges" \gset
\set pgaudit :pgaudit
SELECT CASE WHEN :'pgaudit' = ':pgaudit' THEN 'f' ELSE :'pgaudit' END AS "pgaudit" \gset
\set unlogged_tables :unlogged_tables
SELECT CASE WHEN :'unlogged_tables' = ':unlogged_tables' THEN 'f' ELSE :'unlogged_tables' END AS "unlogged_tables" \gset
\set ssl :ssl
SELECT CASE WHEN :'ssl' = ':ssl' THEN 'f' ELSE :'ssl' END AS "ssl" \gset
\set bg_processes :bg_processes
SELECT CASE WHEN :'bg_processes' = ':bg_processes' THEN 'f' ELSE :'bg_processes' END AS "bg_processes" \gset
\set mxid :mxid
SELECT CASE WHEN :'mxid' = ':mxid' THEN 'f' ELSE :'mxid' END AS "mxid" \gset
\set temp :temp
SELECT CASE WHEN :'temp' = ':temp' THEN 'f' ELSE :'temp' END AS "temp" \gset
\set large_objects :large_objects
SELECT CASE WHEN :'large_objects' = ':large_objects' THEN 'f' ELSE :'large_objects' END AS "large_objects" \gset
\set partitions :partitions
SELECT CASE WHEN :'partitions' = ':partitions' THEN 'f' ELSE :'partitions' END AS "partitions" \gset
\set pg_shdepend :pg_shdepend
SELECT CASE WHEN :'pg_shdepend' = ':pg_shdepend' THEN 'f' ELSE :'pg_shdepend' END AS "pg_shdepend" \gset
\set fk_no_index :fk_no_index
SELECT CASE WHEN :'fk_no_index' = ':fk_no_index' THEN 'f' ELSE :'fk_no_index' END AS "fk_no_index" \gset
\set sequences :sequences
SELECT CASE WHEN :'sequences' = ':sequences' THEN 'f' ELSE :'sequences' END AS "sequences" \gset
\set pg_hba :pg_hba
SELECT CASE WHEN :'pg_hba' = ':pg_hba' THEN 'f' ELSE :'pg_hba' END AS "pg_hba" \gset
\set dup_idx :dup_idx
SELECT CASE WHEN :'dup_idx' = ':dup_idx' THEN 'f' ELSE :'dup_idx' END AS "dup_idx" \gset
\set functions :functions
SELECT CASE WHEN :'functions' = ':functions' THEN 'f' ELSE :'functions' END AS "functions" \gset
\set db_load :db_load
SELECT CASE WHEN :'db_load' = ':db_load' THEN 'f' ELSE :'db_load' END AS "db_load" \gset
\set triggers :triggers
SELECT CASE WHEN :'triggers' = ':triggers' THEN 'f' ELSE :'triggers' END AS "triggers" \gset
\set pg_config :pg_config
SELECT CASE WHEN :'pg_config' = ':pg_config' THEN 'f' ELSE :'pg_config' END AS "pg_config" \gset
\set db_params :db_params
SELECT CASE WHEN :'db_params' = ':db_params' THEN 'f' ELSE :'db_params' END AS "db_params" \gset
\set copy_progress :copy_progress
SELECT CASE WHEN :'copy_progress' = ':copy_progress' THEN 'f' ELSE :'copy_progress' END AS "copy_progress" \gset
\set idx_progress :idx_progress
SELECT CASE WHEN :'idx_progress' = ':idx_progress' THEN 'f' ELSE :'idx_progress' END AS "idx_progress" \gset
\set invalid_db :invalid_db
SELECT CASE WHEN :'invalid_db' = ':invalid_db' THEN 'f' ELSE :'invalid_db' END AS "invalid_db" \gset
\set mat_views :mat_views
SELECT CASE WHEN :'mat_views' = ':mat_views' THEN 'f' ELSE :'mat_views' END AS "mat_views" \gset
\set foreign_servers :foreign_servers
SELECT CASE WHEN :'foreign_servers' = ':foreign_servers' THEN 'f' ELSE :'foreign_servers' END AS "foreign_servers" \gset
-- Compute do_ flags
SELECT CASE WHEN :'fullmod' = 't' OR :'observations' = 't' THEN 't' ELSE 'f' END AS "do_observations" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'db_size' = 't' THEN 't' ELSE 'f' END AS "do_db_size" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'txid' = 't' THEN 't' ELSE 'f' END AS "do_txid" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'table_size' = 't' THEN 't' ELSE 'f' END AS "do_table_size" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'index_size' = 't' THEN 't' ELSE 'f' END AS "do_index_size" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'vacuum' = 't' THEN 't' ELSE 'f' END AS "do_vacuum" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'extensions' = 't' THEN 't' ELSE 'f' END AS "do_extensions" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'memory' = 't' THEN 't' ELSE 'f' END AS "do_memory" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'pgss' = 't' THEN 't' ELSE 'f' END AS "do_pgss" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'users' = 't' THEN 't' ELSE 'f' END AS "do_users" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'schema' = 't' THEN 't' ELSE 'f' END AS "do_schema" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'tablespaces' = 't' THEN 't' ELSE 'f' END AS "do_tablespaces" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'table_access' = 't' THEN 't' ELSE 'f' END AS "do_table_access" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'unused_idx' = 't' THEN 't' ELSE 'f' END AS "do_unused_idx" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'index_access' = 't' THEN 't' ELSE 'f' END AS "do_index_access" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'bloat' = 't' THEN 't' ELSE 'f' END AS "do_bloat" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'toast' = 't' THEN 't' ELSE 'f' END AS "do_toast" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'replication' = 't' THEN 't' ELSE 'f' END AS "do_replication" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'sessions' = 't' THEN 't' ELSE 'f' END AS "do_sessions" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'prepared_txn' = 't' THEN 't' ELSE 'f' END AS "do_prepared_txn" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'pk_fk' = 't' THEN 't' ELSE 'f' END AS "do_pk_fk" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'public_schema' = 't' THEN 't' ELSE 'f' END AS "do_public_schema" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'invalid_idx' = 't' THEN 't' ELSE 'f' END AS "do_invalid_idx" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'privileges' = 't' THEN 't' ELSE 'f' END AS "do_privileges" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'default_privileges' = 't' THEN 't' ELSE 'f' END AS "do_default_privileges" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'pgaudit' = 't' THEN 't' ELSE 'f' END AS "do_pgaudit" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'unlogged_tables' = 't' THEN 't' ELSE 'f' END AS "do_unlogged_tables" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'ssl' = 't' THEN 't' ELSE 'f' END AS "do_ssl" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'bg_processes' = 't' THEN 't' ELSE 'f' END AS "do_bg_processes" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'mxid' = 't' THEN 't' ELSE 'f' END AS "do_mxid" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'temp' = 't' THEN 't' ELSE 'f' END AS "do_temp" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'large_objects' = 't' THEN 't' ELSE 'f' END AS "do_large_objects" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'partitions' = 't' THEN 't' ELSE 'f' END AS "do_partitions" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'pg_shdepend' = 't' THEN 't' ELSE 'f' END AS "do_pg_shdepend" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'fk_no_index' = 't' THEN 't' ELSE 'f' END AS "do_fk_no_index" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'sequences' = 't' THEN 't' ELSE 'f' END AS "do_sequences" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'pg_hba' = 't' THEN 't' ELSE 'f' END AS "do_pg_hba" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'dup_idx' = 't' THEN 't' ELSE 'f' END AS "do_dup_idx" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'functions' = 't' THEN 't' ELSE 'f' END AS "do_functions" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'db_load' = 't' THEN 't' ELSE 'f' END AS "do_db_load" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'triggers' = 't' THEN 't' ELSE 'f' END AS "do_triggers" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'pg_config' = 't' THEN 't' ELSE 'f' END AS "do_pg_config" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'db_params' = 't' THEN 't' ELSE 'f' END AS "do_db_params" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'copy_progress' = 't' THEN 't' ELSE 'f' END AS "do_copy_progress" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'idx_progress' = 't' THEN 't' ELSE 'f' END AS "do_idx_progress" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'invalid_db' = 't' THEN 't' ELSE 'f' END AS "do_invalid_db" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'mat_views' = 't' THEN 't' ELSE 'f' END AS "do_mat_views" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'foreign_servers' = 't' THEN 't' ELSE 'f' END AS "do_foreign_servers" \gset
-- Resolve Aurora sub-section variables
\set aurora_version :aurora_version
SELECT CASE WHEN :'aurora_version' = ':aurora_version' THEN 'f' ELSE :'aurora_version' END AS "aurora_version" \gset
\set aurora_builtins :aurora_builtins
SELECT CASE WHEN :'aurora_builtins' = ':aurora_builtins' THEN 'f' ELSE :'aurora_builtins' END AS "aurora_builtins" \gset
\set aurora_instance_id :aurora_instance_id
SELECT CASE WHEN :'aurora_instance_id' = ':aurora_instance_id' THEN 'f' ELSE :'aurora_instance_id' END AS "aurora_instance_id" \gset
\set aurora_cluster :aurora_cluster
SELECT CASE WHEN :'aurora_cluster' = ':aurora_cluster' THEN 'f' ELSE :'aurora_cluster' END AS "aurora_cluster" \gset
\set aurora_replica_lag :aurora_replica_lag
SELECT CASE WHEN :'aurora_replica_lag' = ':aurora_replica_lag' THEN 'f' ELSE :'aurora_replica_lag' END AS "aurora_replica_lag" \gset
\set aurora_ccm :aurora_ccm
SELECT CASE WHEN :'aurora_ccm' = ':aurora_ccm' THEN 'f' ELSE :'aurora_ccm' END AS "aurora_ccm" \gset
\set aurora_global_db :aurora_global_db
SELECT CASE WHEN :'aurora_global_db' = ':aurora_global_db' THEN 'f' ELSE :'aurora_global_db' END AS "aurora_global_db" \gset
\set aurora_wait_events :aurora_wait_events
SELECT CASE WHEN :'aurora_wait_events' = ':aurora_wait_events' THEN 'f' ELSE :'aurora_wait_events' END AS "aurora_wait_events" \gset
\set aurora_qpm :aurora_qpm
SELECT CASE WHEN :'aurora_qpm' = ':aurora_qpm' THEN 'f' ELSE :'aurora_qpm' END AS "aurora_qpm" \gset
\set aurora_dml :aurora_dml
SELECT CASE WHEN :'aurora_dml' = ':aurora_dml' THEN 'f' ELSE :'aurora_dml' END AS "aurora_dml" \gset
\set aurora_memctx :aurora_memctx
SELECT CASE WHEN :'aurora_memctx' = ':aurora_memctx' THEN 'f' ELSE :'aurora_memctx' END AS "aurora_memctx" \gset
\set aurora_stat_stmt :aurora_stat_stmt
SELECT CASE WHEN :'aurora_stat_stmt' = ':aurora_stat_stmt' THEN 'f' ELSE :'aurora_stat_stmt' END AS "aurora_stat_stmt" \gset
\set aurora_stat_plans :aurora_stat_plans
SELECT CASE WHEN :'aurora_stat_plans' = ':aurora_stat_plans' THEN 'f' ELSE :'aurora_stat_plans' END AS "aurora_stat_plans" \gset
\set aurora_wal_cache :aurora_wal_cache
SELECT CASE WHEN :'aurora_wal_cache' = ':aurora_wal_cache' THEN 'f' ELSE :'aurora_wal_cache' END AS "aurora_wal_cache" \gset
-- Resolve Limitless sub-section variables
\set limitless_routers :limitless_routers
SELECT CASE WHEN :'limitless_routers' = ':limitless_routers' THEN 'f' ELSE :'limitless_routers' END AS "limitless_routers" \gset
\set limitless_params :limitless_params
SELECT CASE WHEN :'limitless_params' = ':limitless_params' THEN 'f' ELSE :'limitless_params' END AS "limitless_params" \gset
\set limitless_databases :limitless_databases
SELECT CASE WHEN :'limitless_databases' = ':limitless_databases' THEN 'f' ELSE :'limitless_databases' END AS "limitless_databases" \gset
\set limitless_extensions :limitless_extensions
SELECT CASE WHEN :'limitless_extensions' = ':limitless_extensions' THEN 'f' ELSE :'limitless_extensions' END AS "limitless_extensions" \gset
\set limitless_txid :limitless_txid
SELECT CASE WHEN :'limitless_txid' = ':limitless_txid' THEN 'f' ELSE :'limitless_txid' END AS "limitless_txid" \gset
\set limitless_tables :limitless_tables
SELECT CASE WHEN :'limitless_tables' = ':limitless_tables' THEN 'f' ELSE :'limitless_tables' END AS "limitless_tables" \gset
\set limitless_stat_stmt :limitless_stat_stmt
SELECT CASE WHEN :'limitless_stat_stmt' = ':limitless_stat_stmt' THEN 'f' ELSE :'limitless_stat_stmt' END AS "limitless_stat_stmt" \gset
\set limitless_msq :limitless_msq
SELECT CASE WHEN :'limitless_msq' = ':limitless_msq' THEN 'f' ELSE :'limitless_msq' END AS "limitless_msq" \gset
\set limitless_sso :limitless_sso
SELECT CASE WHEN :'limitless_sso' = ':limitless_sso' THEN 'f' ELSE :'limitless_sso' END AS "limitless_sso" \gset
\set limitless_sessions :limitless_sessions
SELECT CASE WHEN :'limitless_sessions' = ':limitless_sessions' THEN 'f' ELSE :'limitless_sessions' END AS "limitless_sessions" \gset
\set limitless_dist_sess :limitless_dist_sess
SELECT CASE WHEN :'limitless_dist_sess' = ':limitless_dist_sess' THEN 'f' ELSE :'limitless_dist_sess' END AS "limitless_dist_sess" \gset
\set limitless_wait_events :limitless_wait_events
SELECT CASE WHEN :'limitless_wait_events' = ':limitless_wait_events' THEN 'f' ELSE :'limitless_wait_events' END AS "limitless_wait_events" \gset
-- Compute do_ flags for Aurora sub-sections
SELECT CASE WHEN :'fullmod' = 't' OR :'aurora_version' = 't' THEN 't' ELSE 'f' END AS "do_aurora_version" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'aurora_builtins' = 't' THEN 't' ELSE 'f' END AS "do_aurora_builtins" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'aurora_instance_id' = 't' THEN 't' ELSE 'f' END AS "do_aurora_instance_id" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'aurora_cluster' = 't' THEN 't' ELSE 'f' END AS "do_aurora_cluster" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'aurora_replica_lag' = 't' THEN 't' ELSE 'f' END AS "do_aurora_replica_lag" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'aurora_ccm' = 't' THEN 't' ELSE 'f' END AS "do_aurora_ccm" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'aurora_global_db' = 't' THEN 't' ELSE 'f' END AS "do_aurora_global_db" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'aurora_wait_events' = 't' THEN 't' ELSE 'f' END AS "do_aurora_wait_events" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'aurora_qpm' = 't' THEN 't' ELSE 'f' END AS "do_aurora_qpm" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'aurora_dml' = 't' THEN 't' ELSE 'f' END AS "do_aurora_dml" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'aurora_memctx' = 't' THEN 't' ELSE 'f' END AS "do_aurora_memctx" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'aurora_stat_stmt' = 't' THEN 't' ELSE 'f' END AS "do_aurora_stat_stmt" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'aurora_stat_plans' = 't' THEN 't' ELSE 'f' END AS "do_aurora_stat_plans" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'aurora_wal_cache' = 't' THEN 't' ELSE 'f' END AS "do_aurora_wal_cache" \gset
-- Compute do_ flags for Limitless sub-sections
SELECT CASE WHEN :'fullmod' = 't' OR :'limitless_routers' = 't' THEN 't' ELSE 'f' END AS "do_limitless_routers" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'limitless_params' = 't' THEN 't' ELSE 'f' END AS "do_limitless_params" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'limitless_databases' = 't' THEN 't' ELSE 'f' END AS "do_limitless_databases" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'limitless_extensions' = 't' THEN 't' ELSE 'f' END AS "do_limitless_extensions" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'limitless_txid' = 't' THEN 't' ELSE 'f' END AS "do_limitless_txid" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'limitless_tables' = 't' THEN 't' ELSE 'f' END AS "do_limitless_tables" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'limitless_stat_stmt' = 't' THEN 't' ELSE 'f' END AS "do_limitless_stat_stmt" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'limitless_msq' = 't' THEN 't' ELSE 'f' END AS "do_limitless_msq" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'limitless_sso' = 't' THEN 't' ELSE 'f' END AS "do_limitless_sso" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'limitless_sessions' = 't' THEN 't' ELSE 'f' END AS "do_limitless_sessions" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'limitless_dist_sess' = 't' THEN 't' ELSE 'f' END AS "do_limitless_dist_sess" \gset
SELECT CASE WHEN :'fullmod' = 't' OR :'limitless_wait_events' = 't' THEN 't' ELSE 'f' END AS "do_limitless_wait_events" \gset

-- Resolve output directory: use -v outdir=/path to override, default is /tmp
\set outdir :outdir
SELECT CASE WHEN :'outdir' = ':outdir' THEN '/tmp' ELSE :'outdir' END AS "outdir" \gset

\pset format html
\set filename :DBNAME-`date +%Y-%m-%d_%H%M%S`
\o :outdir/pg_collector_:filename.html
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
\qecho <h1 align="center" style="background-color:#e59003" >PG COLLECTOR  V1 for PostgreSQL 19</h1>
\qecho <font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><a href="https://github.com/awslabs/pg-collector/tree/pg-collector-for-postgresql-19" target="_blank">For more information about PG Collector, visit the project github repository</a></font><hr align="left" >
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
\if :fullmod
\echo 'Generating all sections in the Report'
\else
\echo 'Generating specific sections in the Report:'
\qecho <br>
\qecho <p><b>&#9888;&#65039; Partial Report - Only selected sections are included:</b></p>
\qecho <ul>
\if :do_observations
\echo '  - Observations (Health checks)'
\qecho <li><a href="#observations">Observations (Health checks)</a></li>
\endif
\if :do_db_size
\echo '  - Database size'
\qecho <li><a href="#Database_size">Database size</a></li>
\endif
\if :do_txid
\echo '  - Transaction ID TXID (Wraparound)'
\qecho <li><a href="#Transaction_ID_TXID">Transaction ID TXID (Wraparound)</a></li>
\endif
\if :do_vacuum
\echo '  - Vacuum & Statistics'
\qecho <li><a href="#vacuum_Statistics">Vacuum & Statistics</a></li>
\endif
\if :do_table_size
\echo '  - Table Size'
\qecho <li><a href="#Table_Size">Table Size</a></li>
\endif
\if :do_index_size
\echo '  - Index Size'
\qecho <li><a href="#index_Size">Index Size</a></li>
\endif
\if :do_extensions
\echo '  - Extensions'
\qecho <li><a href="#Extensions">Extensions</a></li>
\endif
\if :do_memory
\echo '  - Memory setting'
\qecho <li><a href="#Memory_setting">Memory setting</a></li>
\endif
\if :do_pgss
\echo '  - pg_stat_statements extension'
\qecho <li><a href="#pg_stat_statements_extension">pg_stat_statements extension</a></li>
\endif
\if :do_users
\echo '  - Users & Roles Info'
\qecho <li><a href="#Users_Roles_Info">Users & Roles Info</a></li>
\endif
\if :do_schema
\echo '  - Schema Info'
\qecho <li><a href="#Schema_Info">Schema Info</a></li>
\endif
\if :do_tablespaces
\echo '  - Tablespaces Info'
\qecho <li><a href="#Tablespaces_Info">Tablespaces Info</a></li>
\endif
\if :do_table_access
\echo '  - Table Access Profile'
\qecho <li><a href="#table_Access_Profile">Table Access Profile</a></li>
\endif
\if :do_unused_idx
\echo '  - Unused Indexes'
\qecho <li><a href="#Unused Indexes">Unused Indexes</a></li>
\endif
\if :do_index_access
\echo '  - Index Access Profile'
\qecho <li><a href="#Index_Access_Profile">Index Access Profile</a></li>
\endif
\if :do_bloat
\echo '  - Fragmentation (Bloat)'
\qecho <li><a href="#Fragmentation">Fragmentation (Bloat)</a></li>
\endif
\if :do_toast
\echo '  - Toast Tables Mapping'
\qecho <li><a href="#Toast_Tables_Mapping">Toast Tables Mapping</a></li>
\endif
\if :do_replication
\echo '  - Replication'
\qecho <li><a href="#Replication">Replication</a></li>
\endif
\if :do_sessions
\echo '  - Sessions/Connections Info'
\qecho <li><a href="#sessions_info">Sessions/Connections Info</a></li>
\endif
\if :do_prepared_txn
\echo '  - Orphaned prepared transactions'
\qecho <li><a href="#Orphaned_prepared_transactions">Orphaned prepared transactions</a></li>
\endif
\if :do_pk_fk
\echo '  - PK or FK using numeric/integer'
\qecho <li><a href="#PK_FK_using_numeric_or_integer_data_type">PK or FK using numeric/integer</a></li>
\endif
\if :do_public_schema
\echo '  - public Schema'
\qecho <li><a href="#public_Schema">public Schema</a></li>
\endif
\if :do_invalid_idx
\echo '  - Invalid indexes'
\qecho <li><a href="#invalid_indexes">Invalid indexes</a></li>
\endif
\if :do_privileges
\echo '  - Access privileges'
\qecho <li><a href="#access_privileges">Access privileges</a></li>
\endif
\if :do_default_privileges
\echo '  - Default access privileges'
\qecho <li><a href="#default_access_privileges">Default access privileges</a></li>
\endif
\if :do_pgaudit
\echo '  - pgaudit extension'
\qecho <li><a href="#pgaudit_extension">pgaudit extension</a></li>
\endif
\if :do_unlogged_tables
\echo '  - Unlogged Tables'
\qecho <li><a href="#unlogged_tables">Unlogged Tables</a></li>
\endif
\if :do_ssl
\echo '  - SSL'
\qecho <li><a href="#ssl">SSL</a></li>
\endif
\if :do_bg_processes
\echo '  - Background processes'
\qecho <li><a href="#background_processes">Background processes</a></li>
\endif
\if :do_mxid
\echo '  - Multixact ID MXID'
\qecho <li><a href="#Multixact_ID_MXID">Multixact ID MXID</a></li>
\endif
\if :do_temp
\echo '  - Temp Tables & Files'
\qecho <li><a href="#Temp_tables_files">Temp Tables & Files</a></li>
\endif
\if :do_large_objects
\echo '  - Large objects'
\qecho <li><a href="#Large_objects">Large objects</a></li>
\endif
\if :do_partitions
\echo '  - Partition tables'
\qecho <li><a href="#Partition_tables">Partition tables</a></li>
\endif
\if :do_sequences
\echo '  - Sequences'
\qecho <li><a href="#sequences">Sequences</a></li>
\endif
\if :do_pg_hba
\echo '  - pg_hba.conf'
\qecho <li><a href="#pg_hba.conf">pg_hba.conf</a></li>
\endif
\if :do_dup_idx
\echo '  - Duplicate indexes'
\qecho <li><a href="#Duplicate_indexes">Duplicate indexes</a></li>
\endif
\if :do_functions
\echo '  - Functions statistics'
\qecho <li><a href="#functions_statistics">Functions statistics</a></li>
\endif
\if :do_db_load
\echo '  - DB Load'
\qecho <li><a href="#DB_Load">DB Load</a></li>
\endif
\if :do_triggers
\echo '  - Triggers'
\qecho <li><a href="#triggers">Triggers</a></li>
\endif
\if :do_pg_config
\echo '  - pg_config'
\qecho <li><a href="#pg_config">pg_config</a></li>
\endif
\if :do_db_params
\echo '  - DB parameters'
\qecho <li><a href="#DB_parameters">DB parameters</a></li>
\endif
\if :do_copy_progress
\echo '  - COPY command progress'
\qecho <li><a href="#COPY_command_progress">COPY command progress</a></li>
\endif
\if :do_idx_progress
\echo '  - Index Creation Progress'
\qecho <li><a href="#Index_Creation_Progress">Index Creation Progress</a></li>
\endif
\if :do_invalid_db
\echo '  - Invalid databases'
\qecho <li><a href="#Invalid_databases">Invalid databases</a></li>
\endif
\if :do_mat_views
\echo '  - Materialized Views'
\qecho <li><a href="#Materialized_Views">Materialized Views</a></li>
\endif
\if :do_foreign_servers
\echo '  - Foreign Servers'
\qecho <li><a href="#Foreign_Servers">Foreign Servers</a></li>
\endif
\if :do_pg_shdepend
\echo '  - pg_shdepend (shared object dependencies)'
\qecho <li><a href="#pg_shdepend">pg_shdepend</a></li>
\endif
\if :do_fk_no_index
\echo '  - FK without index'
\qecho <li><a href="#FK_without_index">FK without index</a></li>
\endif
\if :do_aurora_version
\echo '  - Aurora version'
\qecho <li><a href="#Aurora_version">Aurora version</a></li>
\endif
\if :do_aurora_builtins
\echo '  - Aurora built-in functions'
\qecho <li><a href="#Aurora_PostgreSQL_built-in_functions">Aurora built-in functions</a></li>
\endif
\if :do_aurora_instance_id
\echo '  - Aurora db instance identifier'
\qecho <li><a href="#Aurora_db_instance_identifier">Aurora db instance identifier</a></li>
\endif
\if :do_aurora_cluster
\echo '  - Aurora cluster instances'
\qecho <li><a href="#Aurora_cluster_instances">Aurora cluster instances</a></li>
\endif
\if :do_aurora_replica_lag
\echo '  - Aurora reader instances - Replica Lag'
\qecho <li><a href="#Aurora_reader_instances-Replica_Lag">Aurora reader instances - Replica Lag</a></li>
\endif
\if :do_aurora_ccm
\echo '  - Aurora cluster cache management (CCM)'
\qecho <li><a href="#Aurora_cluster_cache_management_(CCM)">Aurora cluster cache management (CCM)</a></li>
\endif
\if :do_aurora_global_db
\echo '  - Aurora global db status'
\qecho <li><a href="#Aurora_global_db_status">Aurora global db status</a></li>
\endif
\if :do_aurora_wait_events
\echo '  - Aurora wait event stat'
\qecho <li><a href="#Aurora_wait_event_stat">Aurora wait event stat</a></li>
\endif
\if :do_aurora_qpm
\echo '  - Query Plan Management (QPM)'
\qecho <li><a href="#query_plan_management">Query Plan Management (QPM)</a></li>
\endif
\if :do_aurora_dml
\echo '  - Aurora DML activity'
\qecho <li><a href="#Aurora_dml_activity">Aurora DML activity</a></li>
\endif
\if :do_aurora_memctx
\echo '  - Process memory context usage'
\qecho <li><a href="#process_memory_context_usage">Process memory context usage</a></li>
\endif
\if :do_aurora_stat_stmt
\echo '  - Aurora_stat_statements'
\qecho <li><a href="#aurora_stat_statements">Aurora_stat_statements</a></li>
\endif
\if :do_aurora_stat_plans
\echo '  - Aurora_stat_plans'
\qecho <li><a href="#aurora_stat_plans">Aurora_stat_plans</a></li>
\endif
\if :do_aurora_wal_cache
\echo '  - Logical replication write-through cache'
\qecho <li><a href="#logical_replication_write_through_cache">Logical replication write-through cache</a></li>
\endif
\if :do_limitless_routers
\echo '  - Limitless Routers & Shards Info'
\qecho <li><a href="#Routers_Shards_Info">Limitless Routers & Shards Info</a></li>
\endif
\if :do_limitless_params
\echo '  - Limitless parameters'
\qecho <li><a href="#limitless_parameters">Limitless parameters</a></li>
\endif
\if :do_limitless_databases
\echo '  - Limitless databases'
\qecho <li><a href="#Limitless_databases">Limitless databases</a></li>
\endif
\if :do_limitless_extensions
\echo '  - Limitless Extensions'
\qecho <li><a href="#Limitless_Extensions">Limitless Extensions</a></li>
\endif
\if :do_limitless_txid
\echo '  - Limitless Transaction ID TXID'
\qecho <li><a href="#Limitless_Transaction_ID_TXID">Limitless Transaction ID TXID</a></li>
\endif
\if :do_limitless_tables
\echo '  - Limitless Tables'
\qecho <li><a href="#Limitless_Tables">Limitless Tables</a></li>
\endif
\if :do_limitless_stat_stmt
\echo '  - limitless_stat_statements'
\qecho <li><a href="#limitless_stat_statements">limitless_stat_statements</a></li>
\endif
\if :do_limitless_msq
\echo '  - Multi shard queries (MSQ)'
\qecho <li><a href="#Multi_shard_queries_(MSQ)">Multi shard queries (MSQ)</a></li>
\endif
\if :do_limitless_sso
\echo '  - Single Shard Optimized (SSO)'
\qecho <li><a href="#Single_Shard_Optimized_(SSO)">Single Shard Optimized (SSO)</a></li>
\endif
\if :do_limitless_sessions
\echo '  - Limitless Sessions/Connections'
\qecho <li><a href="#limitless_sessions_info">Limitless Sessions/Connections</a></li>
\endif
\if :do_limitless_dist_sess
\echo '  - Distributed sessions info'
\qecho <li><a href="#Distributed_sessions_info">Distributed sessions info</a></li>
\endif
\if :do_limitless_wait_events
\echo '  - Limitless Database Load (Wait events)'
\qecho <li><a href="#Limitless_Database_Load_Wait_events">Limitless Database Load (Wait events)</a></li>
\endif
\qecho </ul>
\endif
\qecho <br>
\qecho <br>
select  now () as "Date" ,pg_postmaster_start_time() as "DB_START_DATE", current_timestamp - pg_postmaster_start_time() as "UP_TIME"  ,current_database() as "DB_connected" ,current_user USER_NAME,inet_server_port() as "DB_PORT ",version()  as "DB_Version" , setting AS block_size FROM pg_settings WHERE name = 'block_size';
\qecho <br>
\qecho <br>
SELECT 
    count(*) FILTER (WHERE NOT datistemplate) AS databases_count,
    count(*) FILTER (WHERE datistemplate) AS template_databases_count
FROM pg_database;
\qecho <br>
\qecho <br>
SELECT
  d.datname as "Name",
  pg_catalog.pg_get_userbyid(d.datdba) as "Owner",
  pg_catalog.pg_encoding_to_char(d.encoding) as "Encoding",
  CASE d.datlocprovider WHEN 'b' THEN 'builtin' WHEN 'c' THEN 'libc' WHEN 'i' THEN 'icu' END AS "Locale Provider",
  d.datcollate as "Collate",
  d.datctype as "Ctype",
  d.datlocale as "Locale",
  d.daticurules as "ICU Rules",
  CASE WHEN pg_catalog.array_length(d.datacl, 1) = 0 THEN '(none)' ELSE pg_catalog.array_to_string(d.datacl, E'\n') END AS "Access privileges",
  CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
       THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(d.datname))
       ELSE 'No Access'
  END as "Size",
  t.spcname as "Tablespace",
  pg_catalog.shobj_description(d.oid, 'pg_database') as "Description"
FROM pg_catalog.pg_database d
  JOIN pg_catalog.pg_tablespace t on d.dattablespace = t.oid
ORDER BY 1;
\qecho <br>
select * from pg_database; 
\qecho <br>
\qecho <br>
\if :fullmod
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
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Unused Indexes">Unused Indexes</a></td> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Index_Access_Profile">Index Access Profile</a></td> 
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Fragmentation">Fragmentation (Bloat)</a></td> 
\qecho </tr>
\qecho <tr>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Toast_Tables_Mapping">Toast Tables Mapping</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Replication">Replication</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#sessions_info">Sessions/Connections Info</a></td>
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
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Temp_tables_files">Temp Tables & Files</a></td>
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
\qecho <tr>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Index_Creation_Progress">Index Creation Progress</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Materialized_Views">Materialized Views</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Foreign_Servers">Foreign Servers</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#******">******</a></td>
\qecho </tr>
\qecho </table>
\endif
\qecho <br>
\qecho <br>
\qecho <br>
select count(*) > 0 isaurora from pg_settings where name='rds.extensions' and setting like '%aurora_stat_utils%' \gset
\if :isaurora
\if :fullmod
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
\endif
\endif
select count(*) > 0 isauroralimitless from pg_catalog.pg_extension where extname = 'aurora_limitless_fdw' \gset
\if :isauroralimitless
\if :fullmod
\qecho <table width="90%" border="1">
\qecho <tr><th colspan="4"><div align="center"><font color="#16191f"><b>Amazon Aurora Limitless Database</b></font></div></th></tr>
\qecho <tr>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Routers_Shards_Info">Routers & Shards Info</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#limitless_parameters">limitless parameters</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Limitless_Extensions">Limitless Extensions</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Limitless_databases">Limitless databases</a></td>
\qecho </tr>
\qecho <tr>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Limitless_Transaction_ID_TXID">Limitless Transaction ID TXID (Wraparound)</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Limitless_Tables">Limitless Tables</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#limitless_stat_statements">limitless_stat_statements</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#limitless_sessions_info">Limitless Sessions/Connections Info</a></td>
\qecho </tr>
\qecho <tr>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#******">******</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#******">******</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Multi_shard_queries_(MSQ)">Multi shard queries (MSQ)</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Distributed_sessions_info">Distributed sessions info</a></td>
\qecho </tr>
\qecho <tr>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#******">******</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#******">******</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Single_Shard_Optimized_(SSO)">Single Shard Optimized (SSO)</a></td>
\qecho <td nowrap align="center" width="25%"><a class="link" href="#Limitless_Database_Load_Wait_events">Limitless Database Load (Wait events)</a></td>
\qecho </tr>
\qecho </table>
\endif
\endif
\qecho <br>
\qecho <br>
\qecho <br>
\qecho <br>
\qecho <br>
\qecho <br>
\if :do_observations
-- +----------------------------------------------------------------------------+
-- |      - observations                                                     -  |
-- +----------------------------------------------------------------------------+
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Observations</b></font><hr align="left" width="460">
---------------------------------
-- Check for duplicate indexes --
---------------------------------
select count(*) > 0 obsrv_duplicate_indexes
from
(
SELECT pg_size_pretty(sum(pg_relation_size(idx))::bigint) as size,
       (array_agg(idx))[1] as idx1, (array_agg(idx))[2] as idx2,
       (array_agg(idx))[3] as idx3, (array_agg(idx))[4] as idx4
FROM (
    SELECT indexrelid::regclass as idx, (indrelid::text ||E'\n'|| indclass::text ||E'\n'|| indkey::text ||E'\n'||
                                         coalesce(indexprs::text,'')||E'\n' || coalesce(indpred::text,'')) as key
    FROM pg_index) sub
GROUP BY key HAVING count(*)>1
ORDER BY sum(pg_relation_size(idx)) DESC) AS t \gset

\if :obsrv_duplicate_indexes
    \qecho '&#8594; The database has duplicate indexes, please check the following section <a class="link" href="#Duplicate_indexes">Duplicate indexes</a> .'
\else
\endif
--------------------------------------------------
-- Check for database connections not using SSL --
--------------------------------------------------
SELECT count(*) > 0 obsrv_unsecured_conn_count
FROM pg_stat_activity a JOIN pg_stat_ssl s ON a.pid = s.pid and s.ssl = false \gset

\if :obsrv_unsecured_conn_count
    \qecho <br>
    \qecho '&#8594; The database has connections operating without SSL encryption, potentially exposing sensitive data to security risks. Please check the following section <a class="link" href="#ssl">SSL</a> .'
\else
\endif
--------------------------------------------------
-- Check for Orphaned prepared transactions     --
--------------------------------------------------
SELECT count(*) > 0 obsrv_orphaned_preptxn_count
FROM pg_prepared_xacts WHERE now()-prepared >= interval '5' minute \gset

\if :obsrv_orphaned_preptxn_count
    \qecho <br>
    \qecho '&#8594; The database has orphaned prepared transactions. Please check the following section <a class="link" href="#Orphaned_prepared_transactions">Orphaned prepared transactions</a> .'
\else
\endif
-------------------------------
-- Check for Invalid Indexes --
-------------------------------

select count(*) > 0  obsrv_invalid_indxes_count from pg_index WHERE pg_index.indisvalid = false \gset

\if :obsrv_invalid_indxes_count
    \qecho <br>
    \qecho '&#8594; The database has Invalid Indexes, Please check the following section <a class="link" href="#invalid_indexes">Invalid indexes</a> .'
\else
\endif
------------------------------------
-- Check for autovacuum parameter --
------------------------------------
select count(*) > 0 obsrv_autovacuum_parameter_disabled
FROM pg_settings WHERE name = 'autovacuum' and setting != 'on'   \gset


 \if :obsrv_autovacuum_parameter_disabled
     \qecho <br>
     \qecho '&#8594; The autovacuum parameter is disabled, Please check the following section <a class="link" href="#DB_parameters">DB parameters</a> .'
 \else
 \endif
 
 
 
--------------------------------------
-- Check for track_counts parameter --
--------------------------------------
select count(*) > 0 obsrv_track_counts_parameter_disabled
FROM pg_settings WHERE name = 'track_counts' and setting != 'on'   \gset


 \if :obsrv_track_counts_parameter_disabled
     \qecho <br>
     \qecho '&#8594; The track_counts parameter is disabled, Please check the following section <a class="link" href="#DB_parameters">DB parameters</a> .'
 \else
 \endif
 
 
----------------------------------------------
-- Check for enable_indexonlyscan parameter --
----------------------------------------------
select count(*) > 0 obsrv_enable_indexonlyscan_parameter_disabled
FROM pg_settings WHERE name = 'enable_indexonlyscan' and setting != 'on'   \gset


 \if :obsrv_enable_indexonlyscan_parameter_disabled
     \qecho <br>
     \qecho '&#8594; The enable_indexonlyscan parameter is disabled, Please check the following section <a class="link" href="#DB_parameters">DB parameters</a> .'
 \else
 \endif
 
 
 
------------------------------------------
-- Check for enable_indexscan parameter --
------------------------------------------
select count(*) > 0 obsrv_enable_indexscan_parameter_disabled
FROM pg_settings WHERE name = 'enable_indexscan' and setting != 'on'   \gset


 \if :obsrv_enable_indexscan_parameter_disabled
     \qecho <br>
     \qecho '&#8594; The enable_indexscan parameter is disabled, Please check the following section <a class="link" href="#DB_parameters">DB parameters</a> .'
 \else
 \endif

------------------------------------------
-- Check for Unused_Indexes --
------------------------------------------
select count(*) > 0 obsrv_unused_indexes
FROM pg_catalog.pg_stat_all_indexes ai , pg_index i
WHERE ai.indexrelid=i.indexrelid
and ai.idx_scan = 0 
and ai.schemaname not in ('pg_catalog','pg_toast') \gset

 \if :obsrv_unused_indexes
     \qecho <br>
     \qecho '&#8594; The database has unused indexes, Please check the following section <a class="link" href="#Unused Indexes">Unused Indexes</a> .'
 \else
 \endif

------------------------------------------
-- Check for Inactive Replication Slots --
------------------------------------------
SELECT count(*) > 0 obsrv_inactive_rep_slots
FROM pg_replication_slots WHERE active='f' \gset


 \if :obsrv_inactive_rep_slots
     \qecho <br>
     \qecho '&#8594; The database has inactive replication slots, Please check the following section <a class="link" href="#Replication">Replication</a> .'
 \else
 \endif

------------------------------------------
-- Check for Low remaining sequences --
------------------------------------------
SELECT count(1) > 0 as obsrv_less_remaining_sequences FROM (SELECT 
    schemaname as Schema,
    sequencename as Sequence_Name,
    data_type::regtype as Data_Type,
    last_value as Current_Value,
    max_value as Max_Value,
    min_value as Min_Value,
    increment_by as Increment_By,
    CASE 
        WHEN max_value = 9223372036854775807 THEN 'No Limit'
        ELSE round(((max_value - last_value)::numeric / (max_value - min_value)::numeric * 100), 2)::text || '%'
    END as Remaining_Percentage,
    CASE 
        WHEN max_value = 9223372036854775807 THEN 'No Action Needed'
        WHEN ((max_value - last_value)::numeric / (max_value - min_value)::numeric * 100) < 1 
        THEN 'CRITICAL: Less than 1% remaining'
        WHEN ((max_value - last_value)::numeric / (max_value - min_value)::numeric * 100) < 5 
        THEN 'WARNING: Less than 5% remaining'
        WHEN ((max_value - last_value)::numeric / (max_value - min_value)::numeric * 100) < 10 
        THEN 'NOTICE: Less than 10% remaining'
        ELSE 'OK'
    END as Status
FROM pg_sequences) seq WHERE status not in ('OK', 'No Action Needed') \gset

 \if :obsrv_less_remaining_sequences
     \qecho <br>
     \qecho '&#8594; The database has sequences with less than 10% remaining values, Please check the following section <a class="link" href="#sequences">sequences</a> .'
 \else
 \endif

-----------------------------------------------
-- Check for log_statement Excessive Logging --
-----------------------------------------------
SELECT count(*) > 0 obsrv_excessive_logging_logstatement 
FROM pg_settings
WHERE name = 'log_statement' and setting IN ('all', 'mod') \gset

\if :obsrv_excessive_logging_logstatement
     \qecho <br>
     \qecho '&#8594; The log_statement parameter is set to all or mod. Please check the following section <a class="link" href="#DB_parameters">DB parameters</a> .'
\else
\endif

------------------------------------------------------------
-- Check for log_min_duration_statement Excessive Logging --
------------------------------------------------------------
SELECT count(*) > 0 obsrv_excessive_logging_logsmindurstmt
FROM pg_settings
WHERE name = 'log_min_duration_statement' and setting IN ('0') \gset

\if :obsrv_excessive_logging_logsmindurstmt
     \qecho <br>
     \qecho '&#8594; The log_min_duration_statement parameter is set to 0. Please check the following section <a class="link" href="#DB_parameters">DB parameters</a> .'
\else
\endif

------------------------------------------------------------
-- Check for log_min_messages Excessive Logging           --
------------------------------------------------------------
SELECT count(*) > 0 obsrv_excessive_logging_logsminmsgs
FROM pg_settings
WHERE name = 'log_min_messages' and setting IN ('debug5', 'debug4', 'debug3', 'debug2', 'debug1') \gset

\if :obsrv_excessive_logging_logsminmsgs
     \qecho <br>
     \qecho '&#8594; The log_min_messages parameter is set to DEBUG[n]. Please check the following section <a class="link" href="#DB_parameters">DB parameters</a> .'
\else
\endif

------------------------------------------------------------
-- Check for log_statement_stats Excessive Logging        --
------------------------------------------------------------
SELECT count(*) > 0 obsrv_excessive_log_stmt_stats
FROM pg_settings
WHERE name = 'log_statement_stats' and setting IN ('on') \gset

\if :obsrv_excessive_log_stmt_stats
     \qecho <br>
     \qecho '&#8594; The log_statement_stats parameter is set to on. Please check the following section <a class="link" href="#DB_parameters">DB parameters</a> .'
\else
\endif

------------------------------------------------------------
-- Check for log_parser_stats Excessive Logging           --
------------------------------------------------------------
SELECT count(*) > 0 obsrv_excessive_log_parser_stats
FROM pg_settings
WHERE name = 'log_parser_stats' and setting IN ('on') \gset

\if :obsrv_excessive_log_parser_stats
     \qecho <br>
     \qecho '&#8594; The log_parser_stats parameter is set to on. Please check the following section <a class="link" href="#DB_parameters">DB parameters</a> .'
\else
\endif

------------------------------------------------------------
-- Check for log_planner_stats Excessive Logging           --
------------------------------------------------------------
SELECT count(*) > 0 obsrv_excessive_log_planner_stats
FROM pg_settings
WHERE name = 'log_planner_stats' and setting IN ('on') \gset

\if :obsrv_excessive_log_planner_stats
     \qecho <br>
     \qecho '&#8594; The log_planner_stats parameter is set to on. Please check the following section <a class="link" href="#DB_parameters">DB parameters</a> .'
\else
\endif

------------------------------------------------------------
-- Check for log_executor_stats Excessive Logging           --
------------------------------------------------------------
SELECT count(*) > 0 obsrv_excessive_log_executor_stats
FROM pg_settings
WHERE name = 'log_executor_stats' and setting IN ('on') \gset

\if :obsrv_excessive_log_executor_stats
     \qecho <br>
     \qecho '&#8594; The log_executor_stats parameter is set to on. Please check the following section <a class="link" href="#DB_parameters">DB parameters</a> .'
\else
\endif

------------------------------------------------------------
-- Check for debug_print_parse Excessive Logging           --
------------------------------------------------------------
SELECT count(*) > 0 obsrv_excessive_debug_print_parse
FROM pg_settings
WHERE name = 'debug_print_parse' and setting IN ('on') \gset

\if :obsrv_excessive_debug_print_parse
     \qecho <br>
     \qecho '&#8594; The debug_print_parse parameter is set to on. Please check the following section <a class="link" href="#DB_parameters">DB parameters</a> .'
\else
\endif

------------------------------------------------------------
-- Check for debug_print_rewritten Excessive Logging           --
------------------------------------------------------------
SELECT count(*) > 0 obsrv_excessive_debug_print_rewritten
FROM pg_settings
WHERE name = 'debug_print_rewritten' and setting IN ('on') \gset

\if :obsrv_excessive_debug_print_rewritten
     \qecho <br>
     \qecho '&#8594; The debug_print_rewritten parameter is set to on. Please check the following section <a class="link" href="#DB_parameters">DB parameters</a> .'
\else
\endif

------------------------------------------------------------
-- Check for debug_print_plan Excessive Logging           --
------------------------------------------------------------
SELECT count(*) > 0 obsrv_excessive_debug_print_plan
FROM pg_settings
WHERE name = 'debug_print_plan' and setting IN ('on') \gset

\if :obsrv_excessive_debug_print_plan
     \qecho <br>
     \qecho '&#8594; The debug_print_plan parameter is set to on. Please check the following section <a class="link" href="#DB_parameters">DB parameters</a> .'
\else
\endif

--------------------------------------------
-- Check for synchronous_commit parameter --
--------------------------------------------
select count(*) > 0 obsrv_synchronous_commit_parameter_disabled
FROM pg_settings WHERE name = 'synchronous_commit' and setting = 'off'   \gset


 \if :obsrv_synchronous_commit_parameter_disabled
     \qecho <br>
     \qecho '&#8594; The synchronous_commit parameter is disabled, Please check the following section <a class="link" href="#DB_parameters">DB parameters</a> .'
\else
\endif

---------------------------------
-- Check for Invalid databases --
---------------------------------
select count(*) > 0 obsrv_invalid_databases
FROM pg_database WHERE datconnlimit = '-2'  \gset


\if :obsrv_invalid_databases
     \qecho <br>
     \qecho '&#8594; The database has Invalid Database, Please check the following section <a class="link" href="#Invalid_databases">Invalid databases</a> .'
\else
\endif

------------------------------------------------------------------------------------------------------
-- Check for tables that have more than 20% dead rows and (n_live_tup > 1000 or n_dead_tup > 1000)  --
------------------------------------------------------------------------------------------------------
select count(*) > 0 obsrv_tables_more_than_20pct_dead_rows from pg_stat_all_tables where n_dead_tup::float/nullif(n_live_tup+n_dead_tup,0) >.2 and (n_live_tup > 1000 or n_dead_tup > 1000)    \gset
\if :obsrv_tables_more_than_20pct_dead_rows
     \qecho <br>
     \qecho '&#8594; The database has tables that have more than 20% dead rows, Please check the following section <a class="link" href="#vacuum_Statistics">Vacuum & Statistics</a> .'
\else
\endif

---------------------------------------------------------------------------------
-- Check for tables that have autovacuum_enabled=off|false on the table level  --
---------------------------------------------------------------------------------
select count(*) > 0 obsrv_tables_autovacuum_enabled_off from pg_class where reloptions::text like '%autovacuum_enabled=off%' or pg_class.reloptions::text like '%autovacuum_enabled=false%'    \gset
\if :obsrv_tables_autovacuum_enabled_off
     \qecho <br>
     \qecho '&#8594; The database has tables that have autovacuum disabled (autovacuum_enabled=off|false) on the table level, Please check the following section <a class="link" href="#vacuum_Statistics">Vacuum & Statistics</a> .'
\else
\endif

------------------------------------------
-- Check for Critical XID Age --
------------------------------------------
SELECT count(*) > 0 obsrv_critical_xid_age
FROM (
    SELECT max(age(datfrozenxid)) as oldest_xid 
    FROM pg_database
    HAVING max(age(datfrozenxid)) >= 300000000
) AS t \gset

\if :obsrv_critical_xid_age
     \qecho <br>
     \qecho '&#8594; Critical Transaction ID (XID) age detected. Please check the following section <a class="link" href="#Transaction_ID_TXID">Transaction ID TXID (Wraparound)</a>'
 \endif

---------------------------------------------------------------------------------
-- Check for autovacuum freeze max age                                         --
---------------------------------------------------------------------------------
select count(*) > 0 obsrv_autovacuum_freeze_max_age FROM pg_settings WHERE name = 'autovacuum_freeze_max_age' and setting::bigint > 200000000   \gset

\if :obsrv_autovacuum_freeze_max_age
  \qecho <br>
  \qecho '&#8594; The autovacuum_freeze_max_age parameter is set to a value bigger than 200 millions , Please check the following section <a class="link" href="#Transaction_ID_TXID">Transaction ID TXID (Wraparound)</a>'
\else
\endif

---------------------------------------------------------------------------------
-- Check for logical replication spills                                        --
---------------------------------------------------------------------------------
select count(*) > 0 obsrv_logical_replication_spills from pg_stat_replication_slots where spill_count > 0 and spill_bytes > 0 \gset

\if :obsrv_logical_replication_spills
     \qecho <br>
     \qecho '&#8594; The database has logical replication spills, Please check the following section <a class="link" href="#Replication">Replication</a> .'
\else
\endif

---------------------------------------------------------------------------------
-- Check for Installed Extensions that require update                          --
---------------------------------------------------------------------------------
with recursive version_parts as (
    select name, extversion, version, installed,
           (string_to_array(regexp_replace(regexp_replace(extversion, '[a-zA-Z]', '', 'g'), '-', '.', 'g'), '.'))::int[] as ext_ver_parts,
           (string_to_array(regexp_replace(regexp_replace(version, '[a-zA-Z]', '', 'g'), '-', '.', 'g'), '.'))::int[] as ver_parts
    from 
        (select extname, extversion from pg_extension) a,
        (select name, version, installed 
         from pg_available_extension_versions 
         where name in (select extname from pg_extension)) b
    where a.extname = b.name
)
select count(*) > 0 obsrv_extensions_update_available
from (
select 
    name as extension_name, 
    extversion as installed_version, 
    version as latest_available_version
from (
    select 
        name, 
        extversion, 
        version,
        rank() over (partition by name order by 
            ver_parts[1] desc nulls last,
            ver_parts[2] desc nulls last,
            ver_parts[3] desc nulls last) as myrank
    from version_parts
    where ver_parts[1] > ext_ver_parts[1]
       or (ver_parts[1] = ext_ver_parts[1] and ver_parts[2] > ext_ver_parts[2])
       or (ver_parts[1] = ext_ver_parts[1] and ver_parts[2] = ext_ver_parts[2] and ver_parts[3] > ext_ver_parts[3])
) e
where myrank = 1 
) as t \gset

\if :obsrv_extensions_update_available
     \qecho <br>
     \qecho '&#8594; The database has installed extensions that require updates, Please check the following section <a class="link" href="#Extensions">Extensions</a> .'
\else
\endif

---------------------------------
-- Check for pending restart   --
---------------------------------
SELECT count(*) > 0 obsrv_pending_restart
FROM pg_settings WHERE pending_restart = true \gset

\if :obsrv_pending_restart
    \qecho <br>
    \qecho '&#8594; The database has parameters that have been changed but require a restart to take effect. Please check the following section <a class="link" href="#DB_parameters">DB parameters</a> .'
\else
\endif

\qecho <br>
\qecho <br>
\qecho <br>
\qecho <br>
\endif
\if :do_db_size
-- +----------------------------------------------------------------------------+
-- |      - Database_size                                    -                  |
-- +----------------------------------------------------------------------------+

\qecho <a name="Database_size"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Database size</b></font><hr align="left" width="460">
SELECT pg_database.datname Database_Name , pg_size_pretty(pg_database_size(pg_database.datname)) AS Database_Size FROM pg_database;

\qecho <br>
\qecho <h3>Total size across all databases</h3>
SELECT 
    sum(pg_database_size(pg_database.datname)) AS Total_size_bytes,
    pg_size_pretty(sum(pg_database_size(pg_database.datname))) AS Total_size_pretty
FROM pg_database;

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif

\if :do_txid
-- +----------------------------------------------------------------------------+
-- |      - Transaction ID TXID                                   -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Transaction_ID_TXID"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Transaction ID TXID (Wraparound)</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
-- +----------------------------------------------------------------------------+
-- |      - Vacuum Blockers                                  -                  |
-- +----------------------------------------------------------------------------+
\qecho <h3>Vacuum Blockers :</h3>
\qecho 'NOTE: the vacuum blocker will check if the XID age is above 300 million'
\qecho <br>
------------------------------------------
-- 1. Check for Inactive Replication Slots --
------------------------------------------
SELECT count(*) > 0 obsrv_inactive_rep_slots
FROM pg_replication_slots WHERE active='f' \gset

 \if :obsrv_inactive_rep_slots
     \qecho <br>
     \qecho <h4>'The database has inactive replication slots, Please check the following section <a class="link" href="#Replication">Replication</a> .'</h4>
 \else
     \qecho 'No inactive replication slot found'
 \endif

\qecho <br>
--------------------------------------------------
-- 2. Check for Orphaned prepared transactions     --
--------------------------------------------------
SELECT count(*) > 0 obsrv_orphaned_preptxn_count
FROM pg_prepared_xacts WHERE age(transaction) > 300000000 \gset

\if :obsrv_orphaned_preptxn_count
    \qecho <br>
    \qecho <h4>'The database has orphaned prepared transactions. Please check the following section <a class="link" href="#Orphaned_prepared_transactions">Orphaned prepared transactions</a> .'</h4>
\else
    \qecho 'No orphaned prepared transactions found'
\endif
\qecho <br>
------------------------------------------
--  3. Check for Active Logical Replication Slots with Lag --
------------------------------------------
SELECT count(*) > 0 as obsrv_active_logical_slots_lag
FROM pg_replication_slots
WHERE active = true 
  AND slot_type = 'logical'
  AND age(catalog_xmin) >= 300000000 \gset

\if :obsrv_active_logical_slots_lag
    \qecho <h4>Active Logical Replication Slots with High XID Age (Potential Lag):</h4>
    SELECT slot_name, 
           age(catalog_xmin) as xid_age,
           restart_lsn,
           confirmed_flush_lsn
    FROM pg_replication_slots  
    WHERE active = true 
      AND slot_type = 'logical'
      AND age(catalog_xmin) >= 300000000
    ORDER BY age(catalog_xmin) DESC;

    \qecho <h5>Recommendations:</h5>
    \qecho <ul>
    \qecho <li>Check the status of subscriber and ensure it is consuming data</li>
    \qecho <li>Investigate potential network issues between publisher and subscriber</li>
    \qecho <li>Consider increasing resources on the subscriber if it is lagging behind</li>
    \qecho <li>Monitor replication lag regularly and set up alerts for excessive lag</li>
    \qecho </ul>
\else
    \qecho 'No active Logical Replication Slots with high XID age found'
\endif
\qecho <br>
------------------------------------------
--  4. Check for Long-Running Active Transactions --
------------------------------------------
SELECT count(*) > 0 as obsrv_long_running_txn
FROM pg_stat_activity
WHERE state != 'idle'
  AND age(coalesce(backend_xmin, backend_xid)) >= 300000000 \gset

\if :obsrv_long_running_txn
    \qecho <h4>Long-Running Active Transactions:</h4>
    SELECT pid,
           datname,
           usename,
           state,
           age(coalesce(backend_xmin, backend_xid)) as xid_age,
           query_start,
           xact_start,
           now() - xact_start AS xact_duration,
           now() -query_start AS query_duration,
           query
    FROM pg_stat_activity
    WHERE state != 'idle' AND query not ilike 'autovacuum %'
      AND age(coalesce(backend_xmin, backend_xid)) >= 300000000
    ORDER BY age(coalesce(backend_xmin, backend_xid)) DESC;

    \qecho <h5>Recommendations:</h5>
    \qecho <ul>
    \qecho <li>Investigate why these transactions are running for so long</li>
    \qecho <li>Consider optimizing or terminating long-running queries</li>
    \qecho <li>Implement transaction timeout mechanisms in your application</li>
    \qecho <li>Set up monitoring and alerts for long-running transactions</li>
    \qecho </ul>
\else
    \qecho 'No long running queries found'
\endif
\qecho <br>
------------------------------------------
-- 5. Check for Physical Replication with Hot Standby Feedback --
------------------------------------------
WITH hsf_xid_age AS (
    SELECT coalesce(greatest(
        (SELECT max(nullif(age(backend_xmin),2147483647)) FROM pg_stat_replication),
        (SELECT max(nullif(age(xmin),2147483647)) FROM pg_replication_slots where slot_type = 'physical'),
        (SELECT max(nullif(age(catalog_xmin),2147483647)) FROM pg_replication_slots where slot_type = 'physical')
    ),0) as oldest_hot_standby_feedback_xid_age
)
SELECT (oldest_hot_standby_feedback_xid_age >= 300000000) as obsrv_hsf_critical
FROM hsf_xid_age \gset

\if :obsrv_hsf_critical
    \qecho <h4>Active Physical Replication Slots with High XID Age</h4>
    
    -- Check physical replication slots
    \qecho <h4>Physical Replication Slots:</h4>
    SELECT slot_name,
           active,
           age(xmin) as xid_age,
           restart_lsn,
           confirmed_flush_lsn
    FROM pg_replication_slots
    WHERE slot_type = 'physical'
      AND age(xmin) >= 300000000
    ORDER BY age(xmin) DESC;

    \qecho <h5>Current XID Age Status:</h5>
    SELECT coalesce(greatest(
        (SELECT max(nullif(age(backend_xmin),2147483647)) FROM pg_stat_replication),
        (SELECT max(nullif(age(xmin),2147483647)) FROM pg_replication_slots where slot_type = 'physical'),
        (SELECT max(nullif(age(catalog_xmin),2147483647)) FROM pg_replication_slots where slot_type = 'physical')
    ),0) as oldest_hot_standby_feedback_xid_age;

\qecho <h5>Recommendations:</h5>
\qecho <ul>
\qecho <li>High XID age in physical replication indicates:</li>
\qecho <ul>
\qecho <li>Long-running queries on replica</li>
\qecho <li>Inactive logical replication slots on replica</li>
\qecho </ul>
\qecho <li>To address long-running queries on replica:</li>
\qecho <ul>
\qecho <li>Identify long-running queries:</li>
\qecho 'SELECT pid, query, now()-query_start as running_since'
\qecho 'FROM pg_stat_activity'
\qecho 'WHERE state != ''idle'' AND now()-query_start > interval ''1 hour'''
\qecho 'ORDER BY running_since DESC;'
\qecho <li>Terminate problematic queries if necessary:</li>
\qecho 'SELECT pg_terminate_backend(pid);'
\qecho <li>Review and optimize queries causing long-running transactions</li>
\qecho <li>Consider implementing statement_timeout on the replica</li>
\qecho </ul>
\qecho <li>To clear inactive replication slots on replica:</li>
\qecho <ul>
\qecho <li>Identify inactive replication slots:</li>
\qecho 'SELECT slot_name, slot_type, active'
\qecho 'FROM pg_replication_slots'
\qecho 'WHERE NOT active;'
\qecho <li>Drop inactive slots that are no longer needed:</li>
\qecho 'SELECT pg_drop_replication_slot(''slot_name'');'
\qecho <li>If slot is needed, investigate why it became inactive and reactivate if necessary</li>
\qecho </ul>
\qecho </ul>
\else
    \qecho 'No Physical Replication Slots with high XID age found'
\endif

------------------------------------------
-- 6. Check for Aurora Reader XID Age --
------------------------------------------
select count(*) > 0 isaurora from pg_settings where name='rds.extensions' and setting like '%aurora_stat_utils%' \gset
\if :isaurora
WITH aurora_reader_age AS (
    SELECT coalesce(greatest(
        (SELECT max(nullif(age(feedback_xmin::text::xid),2147483647)) FROM aurora_replica_status()),
        (SELECT max(nullif(age(feedback_xmin::text::xid),2147483647)) FROM aurora_global_db_status())
    ),0) as oldest_reader_feedback_xid_age
)
SELECT (oldest_reader_feedback_xid_age >= 300000000) as obsrv_aurora_reader_critical 
FROM aurora_reader_age \gset

\if :obsrv_aurora_reader_critical
    \qecho <h4>Aurora Global Database Status:</h4>
    SELECT aws_region,
           highest_lsn_written,
           durability_lag_in_msec,
           rpo_lag_in_msec,
           last_lag_calculation_time,
           feedback_epoch,
           age(feedback_xmin::text::xid) as xid_age
    FROM aurora_global_db_status()
    WHERE age(feedback_xmin::text::xid) >= 300000000
    ORDER BY age(feedback_xmin::text::xid) DESC;

    \qecho <h5>Recommendations:</h5>
    \qecho <ul>
    \qecho <li>Review Aurora global database replicas for long running queries and inactive replication slots</li>
    \qecho </ul>
\endif
\endif

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
  p.max_dead_tuple_bytes as dead_tuple_data_per_cycle,
  s.n_dead_tup as total_num_dead_tuples ,
  indexes_total as total_indexes_to_vacuum,
  indexes_processed as total_indexes_processed,
  ceil(p.dead_tuple_bytes::float/p.max_dead_tuple_bytes::float) index_cycles_required
FROM pg_stat_progress_vacuum p JOIN pg_stat_activity a using (pid) 
     join pg_stat_all_tables s on s.relid = p.relid
ORDER BY now() - a.xact_start DESC;



\if :isauroralimitless
\qecho <h3>Inactive replication slots order by age_catalog_xmin:</h3>
select *, age(catalog_xmin) age_catalog_xmin 
from pg_replication_slots 
where active = false 
order by age(catalog_xmin) desc;
\else
\qecho <h3>Inactive replication slots order by age_xmin:</h3>
select *,age(xmin) age_xmin,age(catalog_xmin) age_catalog_xmin 
from pg_replication_slots where active = false order by age(xmin) desc;
\endif

\if :isauroralimitless
\qecho <h3>Active replication slots order by age_catalog_xmin:</h3>
select *, age(catalog_xmin) age_catalog_xmin 
from pg_replication_slots 
where active = true 
order by age(catalog_xmin) desc;
\else
\qecho <h3>Active replication slots order by age_xmin:</h3>
select *,age(xmin) age_xmin,age(catalog_xmin) age_catalog_xmin 
from pg_replication_slots 
where active = true 
order by age(xmin) desc;
\endif

\qecho <h3>Invalid databases count:</h3> 
select count(*) FROM pg_database WHERE datconnlimit = '-2' ;


\qecho <h3>Invalid databases list:</h3> 
SELECT * FROM pg_database WHERE datconnlimit = '-2' ;


\qecho <h3>Orphaned prepared transactions:</h3>

SELECT gid, prepared, owner, database, age(transaction) AS ag_xmin 
FROM pg_prepared_xacts
ORDER BY age(transaction) DESC;

\qecho <h3>MAX XID held:</h3>
\if :isauroralimitless
SELECT
(SELECT max(age(backend_xmin)) FROM pg_stat_activity) as oldest_running_xact,
(SELECT max(age(transaction)) FROM pg_prepared_xacts) as oldest_prepared_xact,
--(SELECT max(age(xmin)) FROM pg_replication_slots) as oldest_replication_slot,
(SELECT max(age(backend_xmin))FROM pg_stat_replication)as oldest_replica_xact;
\else
SELECT
(SELECT max(age(backend_xmin)) FROM pg_stat_activity) as oldest_running_xact,
(SELECT max(age(transaction)) FROM pg_prepared_xacts) as oldest_prepared_xact,
(SELECT max(age(xmin)) FROM pg_replication_slots) as oldest_replication_slot,
(SELECT max(age(backend_xmin))FROM pg_stat_replication)as oldest_replica_xact;

\endif

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
\endif

\if :do_table_size
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
\endif


\if :do_index_size
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
\endif

\if :do_vacuum
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
  p.max_dead_tuple_bytes as dead_tuple_data_per_cycle,
  s.n_dead_tup as total_num_dead_tuples ,
  indexes_total as total_indexes_to_vacuum,
  indexes_processed as total_indexes_processed,
  ceil(p.dead_tuple_bytes::float/p.max_dead_tuple_bytes::float) index_cycles_required
FROM pg_stat_progress_vacuum p JOIN pg_stat_activity a using (pid) 
     join pg_stat_all_tables s on s.relid = p.relid
ORDER BY now() - a.xact_start DESC;
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
select schemaname,relname , last_vacuum,last_autovacuum,n_live_tup,n_dead_tup , trunc((n_dead_tup::numeric/nullif(n_live_tup+n_dead_tup,0))* 100,2) as "n_dead_tup_%" from pg_stat_all_tables  where n_dead_tup::float/nullif(n_live_tup+n_dead_tup,0) >.2 order by n_live_tup desc ;
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
select relname,schemaname,last_vacuum,last_autovacuum,last_analyze,last_autoanalyze,vacuum_count,autovacuum_count,analyze_count,autoanalyze_count,trunc(extract(epoch from (now() - coalesce(last_vacuum, last_autovacuum)))/3600,2) as hours_since_last_vacuum,trunc(extract(epoch from (now() - coalesce(last_vacuum, last_autovacuum)))/86400,2) as days_since_last_vacuum from pg_stat_all_tables order by autovacuum_count desc;
\qecho </details>
\qecho <br>
\qecho <h3>pg_stat_all_tables order by autoanalyze_count: </h3>
\qecho <br>
\qecho <details>
select relname,schemaname,last_vacuum,last_autovacuum,last_analyze,last_autoanalyze,vacuum_count,autovacuum_count,analyze_count,autoanalyze_count,trunc(extract(epoch from (now() - coalesce(last_vacuum, last_autovacuum)))/3600,2) as hours_since_last_vacuum,trunc(extract(epoch from (now() - coalesce(last_vacuum, last_autovacuum)))/86400,2) as days_since_last_vacuum from pg_stat_all_tables order by autoanalyze_count desc;
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
\qecho <h3>Tables that have autovacuum disabled (autovacuum_enabled=off|false) on the table level : </h3>
\qecho <br>
\qecho <details>
select relname as table_name , pg_namespace.nspname as schema_name ,reloptions from pg_class  ,pg_namespace  where (pg_class.reloptions::text like '%autovacuum_enabled=off%'  or  pg_class.reloptions::text like '%autovacuum_enabled=false%' ) and pg_class.relnamespace = pg_namespace.oid ;
\qecho </details>
\qecho <br>
\qecho <h3>Tables that have specific table-level parameters set : </h3>
\qecho <br>
\qecho <details>
select relname as table_name , pg_namespace.nspname as schema_name ,reloptions from pg_class ,pg_namespace  where pg_class.reloptions is not null and pg_class.relnamespace = pg_namespace.oid ;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif


\if :do_extensions
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
\qecho <h3>Available Extension Updates - Latest Versions: </h3>
with recursive version_parts as (
    select name, extversion, version, installed,
           (string_to_array(regexp_replace(regexp_replace(extversion, '[a-zA-Z]', '', 'g'), '-', '.', 'g'), '.'))::int[] as ext_ver_parts,
           (string_to_array(regexp_replace(regexp_replace(version, '[a-zA-Z]', '', 'g'), '-', '.', 'g'), '.'))::int[] as ver_parts
    from 
        (select extname, extversion from pg_extension) a,
        (select name, version, installed 
         from pg_available_extension_versions 
         where name in (select extname from pg_extension)) b
    where a.extname = b.name
)
select 
    name as extension_name, 
    extversion as installed_version, 
    version as latest_available_version
from (
    select 
        name, 
        extversion, 
        version,
        rank() over (partition by name order by 
            ver_parts[1] desc nulls last,
            ver_parts[2] desc nulls last,
            ver_parts[3] desc nulls last) as myrank
    from version_parts
    where ver_parts[1] > ext_ver_parts[1]
       or (ver_parts[1] = ext_ver_parts[1] and ver_parts[2] > ext_ver_parts[2])
       or (ver_parts[1] = ext_ver_parts[1] and ver_parts[2] = ext_ver_parts[2] and ver_parts[3] > ext_ver_parts[3])
) e
where myrank = 1 order by name;
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
\endif

\if :do_memory
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
\qecho cache read hit for the whole instance
select 
round((sum(blks_hit)::numeric / (sum(blks_hit) + sum(blks_read)::numeric))*100,2) as cache_read_hit_percentage
from pg_stat_database ;
\qecho <br>
\qecho cache read hit per Database 
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
\endif

\if :do_pgss
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
-- Check if pg_stat_statements is outdated and inform user
SELECT count(*) > 0 AS v_pgss_outdated
FROM pg_available_extension_versions av
JOIN pg_extension e ON e.extname = av.name
WHERE av.name = 'pg_stat_statements'
  AND av.installed = false
  AND (string_to_array(av.version, '.')::int[] > string_to_array(e.extversion, '.')::int[]) \gset
\if :v_pgss_outdated
\echo 'WARNING: pg_stat_statements is outdated. Run: ALTER EXTENSION pg_stat_statements UPDATE;'
\qecho <br>
\qecho <h4 style="color:red;">&#9888; pg_stat_statements is outdated. Run "ALTER EXTENSION pg_stat_statements UPDATE;" .</h4>
\qecho <br>
\endif
SELECT e.extname AS "Extension Name", e.extversion AS "Version", n.nspname AS "Schema",pg_get_userbyid(e.extowner)  as Owner, c.description AS "Description" , e.extrelocatable as "relocatable to another schema", e.extconfig ,e.extcondition
FROM pg_catalog.pg_extension e LEFT JOIN pg_catalog.pg_namespace n ON n.oid = e.extnamespace LEFT JOIN pg_catalog.pg_description c ON c.objoid = e.oid AND c.classoid = 'pg_catalog.pg_extension'::pg_catalog.regclass
where e.extname = 'pg_stat_statements';
\qecho <br>
\qecho <h3>Parameters values: </h3>
-- pg_stat_statements extension configuration 
select name as parameter_name, setting  from pg_settings where name in ('pg_stat_statements.track','pg_stat_statements.track_utility','pg_stat_statements.save'
,'pg_stat_statements.max','shared_preload_libraries');
\qecho <br>
\qecho <h3>Latest pg_stat_statements Extension version that is available to upgrade: </h3>
with recursive version_parts as (
    select name, extversion, version, installed,
           (string_to_array(regexp_replace(regexp_replace(extversion, '[a-zA-Z]', '', 'g'), '-', '.', 'g'), '.'))::int[] as ext_ver_parts,
           (string_to_array(regexp_replace(regexp_replace(version, '[a-zA-Z]', '', 'g'), '-', '.', 'g'), '.'))::int[] as ver_parts
    from 
        (select extname, extversion from pg_extension) a,
        (select name, version, installed 
         from pg_available_extension_versions 
         where name in (select extname from pg_extension)) b
    where a.extname = b.name
)
select 
    name as extension_name, 
    extversion as installed_version, 
    version as latest_available_version,
    upgrade_status as extension_upgrade_status 
from (
    select 
        name, 
        extversion, 
        version,
        rank() over (partition by name order by 
            ver_parts[1] desc nulls last,
            ver_parts[2] desc nulls last,
            ver_parts[3] desc nulls last) as myrank,
        case when ver_parts[1] > ext_ver_parts[1]
          or (ver_parts[1] = ext_ver_parts[1] and ver_parts[2] > ext_ver_parts[2])
          or (ver_parts[1] = ext_ver_parts[1] and ver_parts[2] = ext_ver_parts[2] and ver_parts[3] > ext_ver_parts[3])
          then 'extension upgrade available' else 'up-to-date' end as upgrade_status
    from version_parts
    where name = 'pg_stat_statements'
) e
where myrank = 1
order by name;
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
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent,
parallel_workers_to_launch,
parallel_workers_launched,
generic_plan_calls,
custom_plan_calls,
stats_since,
minmax_stats_since
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
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent,
parallel_workers_to_launch,
parallel_workers_launched,
generic_plan_calls,
custom_plan_calls,
stats_since,
minmax_stats_since
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
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent,
parallel_workers_to_launch,
parallel_workers_launched,
generic_plan_calls,
custom_plan_calls,
stats_since,
minmax_stats_since
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
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent,
parallel_workers_to_launch,
parallel_workers_launched,
generic_plan_calls,
custom_plan_calls,
stats_since,
minmax_stats_since
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
shared_blks_read,
parallel_workers_to_launch,
parallel_workers_launched,
generic_plan_calls,
custom_plan_calls,
stats_since,
minmax_stats_since
from pg_stat_statements 
order by shared_blks_read desc limit 20;

\qecho </details>

\qecho <br>
\qecho <h3> Top SQL order by Temporary Table Activity (local_blks): </h3>
\qecho <br>
\qecho <details>
\qecho <h4>Note: Monitor queries that create temporary tables and use local buffers</h4>
-- Top SQL order by Temporary Table Activity (local_blks)

SELECT
    queryid,
    substring(query, 1, 150) AS query,
    calls,
    round(total_exec_time::numeric, 2) AS total_time_Msec,
    round((total_exec_time::numeric / 1000), 2) AS total_time_sec,
    round(mean_exec_time::numeric, 2) AS avg_time_Msec,
    round((mean_exec_time::numeric / 1000), 2) AS avg_time_sec,
    round(stddev_exec_time::numeric, 2) AS standard_deviation_time_Msec,
    round((stddev_exec_time::numeric / 1000), 2) AS standard_deviation_time_sec,
    round(ROWS::numeric / calls, 2) rows_per_exec,
    round((100 * total_exec_time / sum(total_exec_time) OVER ())::numeric, 4) AS DB_time_percent,
    local_blks_written,
    pg_size_pretty(local_blks_written * 8 * 1024) AS local_blks_written_size,
    local_blks_read,
    pg_size_pretty(local_blks_read * 8 * 1024) AS local_blks_read_size,
    pg_size_pretty((local_blks_read * current_setting('block_size')::int) / calls) local_blks_read_per_call,
    pg_size_pretty((local_blks_written * current_setting('block_size')::int) / calls) local_blks_written_per_call,
    (local_blks_read + local_blks_written) * 8 * 1024 AS total_local_blks_bytes,
    pg_size_pretty((local_blks_read + local_blks_written) * 8 * 1024) AS total_local_blks_size,
    parallel_workers_to_launch,
    parallel_workers_launched,
    generic_plan_calls,
    custom_plan_calls,
    stats_since,
    minmax_stats_since
FROM
    pg_stat_statements
WHERE
    (local_blks_read + local_blks_written) > 0
ORDER BY total_local_blks_bytes DESC
LIMIT 20;

\qecho </details>

\qecho <br>
\qecho <h3> Top SQL order by Temporary File Activity (temp_blks): </h3>
\qecho <br>
\qecho <details>
\qecho <h4>Note: Monitor queries that spill to disk temp files (operations that exceed work_mem)</h4>
-- Top SQL order by Temporary File Activity (temp_blks)

SELECT
    queryid,
    substring(query, 1, 150) AS query,
    calls,
    round(total_exec_time::numeric, 2) AS total_time_Msec,
    round((total_exec_time::numeric / 1000), 2) AS total_time_sec,
    round(mean_exec_time::numeric, 2) AS avg_time_Msec,
    round((mean_exec_time::numeric / 1000), 2) AS avg_time_sec,
    round(stddev_exec_time::numeric, 2) AS standard_deviation_time_Msec,
    round((stddev_exec_time::numeric / 1000), 2) AS standard_deviation_time_sec,
    round(ROWS::numeric / calls, 2) rows_per_exec,
    round((100 * total_exec_time / sum(total_exec_time) OVER ())::numeric, 4) AS DB_time_percent,
    temp_blks_written,
    pg_size_pretty(temp_blks_written * 8 * 1024) AS temp_blks_written_size,
    temp_blk_write_time,
    temp_blks_read,
    pg_size_pretty(temp_blks_read * 8 * 1024) AS temp_blks_read_size,
    temp_blk_read_time,
    pg_size_pretty((temp_blks_read * current_setting('block_size')::int) / calls) temp_blks_read_per_call,
    pg_size_pretty((temp_blks_written * current_setting('block_size')::int) / calls) temp_blks_written_per_call,
    (temp_blks_read + temp_blks_written) * 8 * 1024 AS total_temp_blks_bytes,
    pg_size_pretty((temp_blks_read + temp_blks_written) * 8 * 1024) AS total_temp_blks_size,
    parallel_workers_to_launch,
    parallel_workers_launched,
    generic_plan_calls,
    custom_plan_calls,
    stats_since,
    minmax_stats_since
FROM
    pg_stat_statements
WHERE
    (temp_blks_read + temp_blks_written) > 0
ORDER BY total_temp_blks_bytes DESC
LIMIT 20;

\qecho </details>

\qecho <br>
\qecho <h3> Top SQL order by Parallel Workers Launched: </h3>
\qecho <br>
\qecho <details>
\qecho <h4>Note: Shows queries that use the most parallel workers</h4>
SELECT
    queryid,
    substring(query, 1, 150) AS query,
    calls,
    round(total_exec_time::numeric, 2) AS total_time_Msec,
    round(mean_exec_time::numeric, 2) AS avg_time_Msec,
    round(rows::numeric / calls, 2) rows_per_exec,
    parallel_workers_to_launch,
    parallel_workers_launched,
    (parallel_workers_to_launch - parallel_workers_launched) AS workers_not_launched,
    generic_plan_calls,
    custom_plan_calls,
    stats_since,
    minmax_stats_since
FROM
    pg_stat_statements
WHERE
    parallel_workers_to_launch > 0
ORDER BY parallel_workers_launched DESC
LIMIT 20;
\qecho </details>

\qecho <br>
\qecho <h3> Top SQL order by Parallel Workers Planned: </h3>
\qecho <br>
\qecho <details>
\qecho <h4>Note: Shows queries where the planner intended the most parallelism</h4>
SELECT
    queryid,
    substring(query, 1, 150) AS query,
    calls,
    round(total_exec_time::numeric, 2) AS total_time_Msec,
    round(mean_exec_time::numeric, 2) AS avg_time_Msec,
    round(rows::numeric / calls, 2) rows_per_exec,
    parallel_workers_to_launch,
    parallel_workers_launched,
    (parallel_workers_to_launch - parallel_workers_launched) AS workers_not_launched,
    generic_plan_calls,
    custom_plan_calls,
    stats_since,
    minmax_stats_since
FROM
    pg_stat_statements
WHERE
    parallel_workers_to_launch > 0
ORDER BY parallel_workers_to_launch DESC
LIMIT 20;
\qecho </details>

\qecho <br>
\qecho <h3> Top SQL order by Parallel Workers Not Launched (Bottleneck): </h3>
\qecho <br>
\qecho <details>
\qecho <h4>Note: Shows queries where parallel workers were planned but NOT launched - indicates max_parallel_workers or max_parallel_workers_per_gather limits being hit</h4>
SELECT
    queryid,
    substring(query, 1, 150) AS query,
    calls,
    round(total_exec_time::numeric, 2) AS total_time_Msec,
    round(mean_exec_time::numeric, 2) AS avg_time_Msec,
    round(rows::numeric / calls, 2) rows_per_exec,
    parallel_workers_to_launch,
    parallel_workers_launched,
    (parallel_workers_to_launch - parallel_workers_launched) AS workers_not_launched,
    generic_plan_calls,
    custom_plan_calls,
    stats_since,
    minmax_stats_since
FROM
    pg_stat_statements
WHERE
    (parallel_workers_to_launch - parallel_workers_launched) > 0
ORDER BY (parallel_workers_to_launch - parallel_workers_launched) DESC
LIMIT 20;
\qecho </details>

\qecho <br>
\qecho <h3> Top SQL order by WAL Generation: </h3>
\qecho <br>
\qecho <details>
\qecho <h4>Note: Identifies queries generating the most WAL - impacts replication lag, WAL archiving, and checkpoint frequency. wal_fpi (full page images) indicates heavy writes to cold pages after checkpoints.</h4>
SELECT
    queryid,
    substring(query, 1, 150) AS query,
    calls,
    round(total_exec_time::numeric, 2) AS total_time_Msec,
    round(mean_exec_time::numeric, 2) AS avg_time_Msec,
    rows,
    wal_records,
    wal_fpi,
    wal_bytes,
    pg_size_pretty(wal_bytes::bigint) AS wal_bytes_pretty,
    round((wal_bytes / NULLIF(calls, 0))::numeric, 2) AS wal_bytes_per_call,
    wal_buffers_full,
    generic_plan_calls,
    custom_plan_calls,
    stats_since,
    minmax_stats_since
FROM
    pg_stat_statements
WHERE
    wal_bytes > 0
ORDER BY wal_bytes DESC
LIMIT 20;
\qecho </details>
\else
    \if yes
        \qecho 'pg_stat_statements extension is not installed'
    \endif
\endif



\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif

\if :do_users
-- +----------------------------------------------------------------------------+
-- |      - Users_Roles_Info                                  -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Users_Roles_Info"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Users & Roles Info</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
SELECT r.oid,r.rolname, r.rolsuper, r.rolinherit,
  r.rolcreaterole, r.rolcreatedb, r.rolcanlogin,
  r.rolconnlimit, r.rolvaliduntil
, r.rolreplication
, r.rolbypassrls
, r.rolconfig 
FROM pg_catalog.pg_roles r
WHERE r.rolname !~ '^pg_'
ORDER BY 1;
\qecho <br>
-- list of per database role settings (settings set at the role level)
SELECT rolname AS "Role", datname AS "Database",
pg_catalog.array_to_string(setconfig, E'\n') AS "Settings"
FROM pg_catalog.pg_db_role_setting s
LEFT JOIN pg_catalog.pg_database d ON d.oid = setdatabase
LEFT JOIN pg_catalog.pg_roles r ON r.oid = setrole
ORDER BY 1, 2;
\qecho <br>
select * FROM pg_user;
\qecho <br>
\qecho <h3> List of role grants: </h3>
SELECT m.rolname AS "Role name", r.rolname AS "Member of",
  pg_catalog.concat_ws(', ',
    CASE WHEN pam.admin_option THEN 'ADMIN' END,
    CASE WHEN pam.inherit_option THEN 'INHERIT' END,
    CASE WHEN pam.set_option THEN 'SET' END
  ) AS "Options",
  g.rolname AS "Grantor"
FROM pg_catalog.pg_roles m
     JOIN pg_catalog.pg_auth_members pam ON (pam.member = m.oid)
     LEFT JOIN pg_catalog.pg_roles r ON (pam.roleid = r.oid)
     LEFT JOIN pg_catalog.pg_roles g ON (pam.grantor = g.oid)
WHERE m.rolname !~ '^pg_'
ORDER BY 1, 2, 4;
\qecho </details>


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif

\if :do_schema
-- +----------------------------------------------------------------------------+
-- |      - Schema_Info                                    -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Schema_Info"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Schema Info</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h3>List of schemas:</h3>
\qecho <br>
\qecho <details>
SELECT n.nspname AS "Name",
  pg_catalog.pg_get_userbyid(n.nspowner) AS "Owner",
  CASE WHEN pg_catalog.array_length(n.nspacl, 1) = 0 THEN '(none)' ELSE pg_catalog.array_to_string(n.nspacl, E'\n') END AS "Access privileges",
  pg_catalog.obj_description(n.oid, 'pg_namespace') AS "Description"
FROM pg_catalog.pg_namespace n
WHERE n.nspname !~ '^pg_' AND n.nspname <> 'information_schema'
ORDER BY 1;
\qecho </details>
\qecho <br>
\qecho <h3>Schema size:</h3>
\qecho <br>
\qecho <details>
-- pg_total_relation_size is a built-in PostgreSQL system function that returns the total on-disk space
-- used by a specific relation (like a table). It includes the base table data, all associated indexes,
-- TOAST tables (used for oversized attributes), and TOAST indexes
SELECT
    n.nspname AS "Schema",
    pg_size_pretty(SUM(pg_total_relation_size(c.oid))) AS "Total Size"
FROM
    pg_class c
INNER JOIN
    pg_namespace n ON n.oid = c.relnamespace
WHERE
-- pg_toast% Internal schemas for TOAST (The Oversized-Attribute Storage Technique)
-- already counted in pg_total_relation_size() of parent tables
    n.nspname NOT LIKE 'pg_toast%'
GROUP BY
    n.nspname
ORDER BY
    SUM(pg_total_relation_size(c.oid)) DESC;
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
\endif

\if :do_tablespaces
-- +----------------------------------------------------------------------------+
-- |      - Tablespaces_Info                                   -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Tablespaces_Info"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Tablespaces Info</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
SELECT spcname as Tablespace_Name,pg_size_pretty(pg_tablespace_size (spcname )) as Tablespace_size,
pg_catalog.pg_get_userbyid(spcowner) as Owner,
CASE
WHEN
pg_tablespace_location(oid)=''
AND spcname='pg_default'
THEN
current_setting('data_directory')||'/base/'
WHEN
pg_tablespace_location(oid)=''
AND spcname='pg_global'
THEN
current_setting('data_directory')||'/global/'
ELSE
pg_tablespace_location(oid)
END
AS location ,
spcacl,spcoptions
FROM pg_catalog.pg_tablespace
ORDER BY 1;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif

\if :do_table_access
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
\endif

\if :do_unused_idx
-- +----------------------------------------------------------------------------+
-- |      - Unused_Indexes                                   -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Unused Indexes"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Unused Indexes</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h4> Unused indexes are indexes that exist in the database but have not been used for queries over a period of time. </h4>
\qecho <h4> While they consume disk space and impact write performance, they provide no benefit to query performance. </h4>
\qecho <h4> They increase backup time, storage requirements and add overhead to database maintenance tasks such as VACUUM hence it is recommended to remove the unused indexes. </h4>
\qecho <h4> Before removing unused indexes, consider the following factors:</h4>
\qecho <ul>
\qecho <li> Indexes enforcing uniqueness constraints must not be removed as they ensure data integrity.  </li>
\qecho <li> In a database setup with read replicas, indexes used only on the replicas will appear unused if this report is generated on the primary (writer) instance. Consider checking index usage on all replicas before deciding to remove an index. </li>
\qecho <li> Check when statistics were last reset. Long periods ensure more accurate stats: </li>
\qecho <code>SELECT datname as "Database",</code>
\qecho <code>       pg_stat_get_db_stat_reset_time(oid) as "Last Reset Time",</code>
\qecho <code>       now() - pg_stat_get_db_stat_reset_time(oid) as "Time Since Reset"</code>
\qecho <code>FROM pg_database</code>
\qecho <code>WHERE datname = current_database();</code>
\qecho </ul>
\qecho <details>
SELECT ai.schemaname,ai.relname AS tablename,ai.indexrelid  as index_oid ,
ai.indexrelname AS indexname,i.indisunique ,
ai.idx_scan ,
pg_relation_size(ai.indexrelid) as index_size,
pg_size_pretty(pg_relation_size(ai.indexrelid)) AS pretty_index_size
FROM pg_catalog.pg_stat_all_indexes ai , pg_index i
WHERE ai.indexrelid=i.indexrelid
and ai.idx_scan = 0 
and ai.schemaname not in ('pg_catalog','pg_toast')
order by index_size desc;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif


\if :do_index_access
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
\endif

\if :do_bloat
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
\endif

\if :do_toast
-- +----------------------------------------------------------------------------+
-- |      - Toast_Tables_Mapping                                  -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Toast_Tables_Mapping"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Toast Tables Mapping</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h3> Note:</h3>
\qecho <h4> When a column is written to the toast table, an OID is used to identify the chunk to be toasted. When a toast table grows very large, and contains chunk_ids that are nearing the value of 2^32 (4 billion), it can lead to performance degredation when writing to toast. This is because PostgreSQL must check if an OID is available for assignment by scanning the table </h4>
\qecho <h4> A large Toast table can be a good indication that your toast can face OID wraparound </h4>
\qecho <h4> over time the insert statement will be slower as the Database will be searching for an unused OID and it will have to read from the disk , you will see the insert statements is waiting on IPC:BufferiO or IO:DataFileRead  </h4>
\qecho <h4> you can use below SQL to check the toast table  </h4>
\qecho <h4> select COUNT(DISTINCT chunk_id),2^32 - COUNT(DISTINCT chunk_id) as remaining_OID ,ROUND(100*((2^32 - COUNT(DISTINCT chunk_id)))/2^32::float) AS remaining_OID_PCT ,ROUND(100*(COUNT(DISTINCT chunk_id)/2^32::float)) as percent_towards_Toast_oid_wraparound from pg_toast.pg_toast_{number};</h4> 
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
\qecho <br>
\qecho <h3>Total TOAST Size:</h3>
\qecho <br>
-- pg_total_relation_size includes both the TOAST table data and its associated indexes
SELECT
    pg_size_pretty(SUM(pg_total_relation_size(reltoastrelid))) AS "Actual Total TOAST Size"
FROM pg_class
WHERE reltoastrelid != 0;
\qecho <br>
\qecho <h3>TOAST Size per Schema:</h3>
\qecho <br>
-- Shows TOAST storage consumed by each schema (based on parent table ownership)
-- pg_total_relation_size includes both the TOAST table data and its associated indexes
SELECT
    n.nspname AS "Schema",
    COUNT(t.reltoastrelid) AS "Tables with TOAST",
    pg_size_pretty(SUM(pg_total_relation_size(t.reltoastrelid))) AS "Total TOAST Size"
FROM pg_class t
INNER JOIN pg_namespace n ON n.oid = t.relnamespace
WHERE t.reltoastrelid != 0
  AND n.nspname NOT LIKE 'pg_toast%'
GROUP BY n.nspname
ORDER BY SUM(pg_total_relation_size(t.reltoastrelid)) DESC;

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif

\if :do_replication
-- +----------------------------------------------------------------------------+
-- |      - Replication                                   -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Replication"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Replication</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
\if :isauroralimitless
\qecho <h3> Active replication slots order by age_catalog_xmin:</h3> 
select *, age(catalog_xmin) age_catalog_xmin 
from pg_replication_slots 
where active = true 
order by age(catalog_xmin) desc;
\else
\qecho <h3> Active replication slots order by age_xmin:</h3> 
select *,age(xmin) age_xmin,age(catalog_xmin) age_catalog_xmin 
from pg_replication_slots 
where active = true 
order by age(xmin) desc;
\endif
\qecho <br>
\qecho <h3> Replication Slot Lag:</h3> 
select slot_name,slot_type,database,active,
coalesce(round(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn) / 1024 / 1024 , 2),0) AS Lag_MB_behind ,
coalesce(round(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn) / 1024 / 1024 / 1024, 2),0) AS Lag_GB_behind
from pg_replication_slots 
order by Lag_MB_behind desc;
\qecho <br>
\if :isauroralimitless
\qecho <h3> Inactive replication slots order by age_catalog_xmin::</h3> 
select *,age(catalog_xmin) age_catalog_xmin 
from pg_replication_slots where active = false order by age(catalog_xmin) desc;
\else
\qecho <h3> Inactive replication slots order by age_xmin::</h3> 
select *,age(xmin) age_xmin,age(catalog_xmin) age_catalog_xmin 
from pg_replication_slots where active = false order by age(xmin) desc;
\endif
\qecho <br>
\qecho <h3> Note:</h3>
\qecho <h4> Inactive replication slots can cause following issues if left unmonitored: </h4>
\qecho <ul>
\qecho <li> They prevent WAL removal, which can fill up disk space on primary server </li>
\qecho <li> They might indicate failed replicas or stopped replication processes </li>
\qecho <li> They prevent VACUUM from removing dead rows that might be needed by the replication slot, leading to: </li>
\qecho <ul>
\qecho <li> - Table bloat </li>
\qecho <li> - Degraded query performance </li>
\qecho <li> - Increased disk space usage </li>
\qecho <li> - Transaction ID wraparound risks </li>
\qecho </ul>
\qecho </ul>
\qecho <h4> If replication slot is created and it becomes in-active, then transaction logs wont recycle from master instance. So eventually storage gets full </h4> 
\qecho <h4> These replication slots can be cleaned as below </h4>
\qecho <br>
\qecho <h4> Drop inactive replication slot : </h4>
\qecho <h4> Use the below SQL to Generate SQL to drop the inactive slots </h4>
\qecho <h4>  select '''select pg_drop_replication_slot('''||slot_name||''');''' from pg_replication_slots where active = false; </h4>
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
\qecho <h4> logical_decoding_work_mem parameter is per replication slot , the total logical decoding work memory that can be consumed is the product of the replication slot count and the logical_decoding_work_mem value. </h4>
\qecho <p>Important considerations:</p>
\qecho <ul>
\qecho <li><strong>Performance Impact:</strong> Logical spill files can significantly impact replication lag and system performance:
\qecho   <ul>
\qecho     <li>Increased I/O operations due to disk writes/reads of spill files</li>
\qecho     <li>Higher CPU usage for managing spilled transactions</li>
\qecho     <li>Potential increase in replication lag due to additional I/O operations</li>
\qecho   </ul>
\qecho </li>
\qecho <li><strong>Monitoring:</strong>
\qecho   <ul>
\qecho     <li>For Amazon RDS/Aurora PostgreSQL: Monitor the ReplicationSlotDiskUsage metric in CloudWatch to track spill files usage</li>
\qecho   </ul>
\qecho </li>
\qecho <li><strong>Documentation:</strong>
\qecho   <ul>
\qecho     <li>Aurora PostgreSQL tuning guidance: <a href="https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.BestPractices.Tuning-memory-parameters.html#AuroraPostgreSQL.BestPractices.Tuning-memory-parameters.logical-decoding-work-mem">Aurora PostgreSQL Memory Parameters</a></li>
\qecho     <li>logical_decoding_work_mem tuning guidance: <a href="https://www.postgresql.org/docs/current/runtime-config-resource.html#GUC-LOGICAL-DECODING-WORK-MEM">PostgreSQL Documentation</a></li>
\qecho   </ul>
\qecho </li>
\qecho </ul>
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
\endif


\if :do_sessions
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
select  name as parameter_name , setting , short_desc from pg_settings WHERE name in ('superuser_reserved_connections', 'reserved_connections');
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
\endif


\if :do_prepared_txn
-- +----------------------------------------------------------------------------+
-- |      - Orphaned_prepared_transactions                   -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Orphaned_prepared_transactions"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Orphaned prepared transactions</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
SELECT gid, prepared, now()-prepared duration, owner, database, transaction AS xmin
FROM pg_prepared_xacts
ORDER BY age(transaction) DESC; 

\qecho <br>
\qecho <h3> Note:</h3>
\qecho <h4>The orphaned prepared transactions are likely due to failed two-phase commits. These retain transaction IDs, preventing autovacuum from freezing tuples and increasing the risk of transaction ID wraparound. They also hold locks indefinitely, blocking other sessions and persisting even after a server restart, leading to performance degradation and potential deadlocks. Resolve them using "COMMIT PREPARED <gid>;" or "ROLLBACK PREPARED <gid>;" as needed. </h4>
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif


\if :do_pk_fk
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
\endif

\if :do_public_schema
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
\endif

\if :do_invalid_idx
-- +----------------------------------------------------------------------------+
-- |      - invalid_indexes                                 -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="invalid_indexes"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Invalid indexes</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h4> Invalid indexes are indexes that are not currently valid for queries, though they will still be updated. </h4>
\qecho <h4> Invalid indexes take up disk space but cannot be used for queries. </h4>
\qecho <h4> Invalid indexes typically occur when using CREATE INDEX CONCURRENTLY and the command fails or is aborted. </h4>
\qecho <h4> To fix invalid indexes, you can drop and re-create the index or use REINDEX command </h4>
\qecho <details>
select count (*) as count_of_invalid_indxes from pg_index WHERE pg_index.indisvalid = false ;
WITH table_info AS (
  SELECT
    pg_index.indrelid,
    pg_class.oid,
    pg_class.relname AS table_name
  FROM pg_class, pg_index
  WHERE pg_index.indrelid = pg_class.oid
)
SELECT DISTINCT
  pg_index.indexrelid AS index_oid,
  pg_class.relname AS index_name,
  table_info.table_name,
  pg_namespace.nspname AS schema_name,
  pg_class.relowner AS owner_oid,
  pg_index.indisvalid AS is_valid,
  pg_relation_size(pg_class.oid) AS index_size_bytes,
  pg_size_pretty(pg_relation_size(pg_class.oid)) AS index_size_pretty,
  pg_get_indexdef(pg_index.indexrelid) AS index_def
FROM pg_class, pg_index, pg_namespace, table_info
WHERE pg_index.indisvalid = false
  AND pg_index.indexrelid = pg_class.oid
  AND pg_class.relnamespace = pg_namespace.oid
  AND pg_index.indrelid = table_info.oid
ORDER BY pg_relation_size(pg_class.oid) DESC;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif

\if :do_default_privileges
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
\endif

\if :do_pgaudit
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
\endif

\if :do_unlogged_tables
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
\endif

\if :do_privileges
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
\endif

\if :do_ssl
-- +----------------------------------------------------------------------------+
-- |      - ssl   -                                                             |
-- +----------------------------------------------------------------------------+


\qecho <a name="ssl"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>SSL</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h4> Note: The database connections operating without SSL encryption, potentially exposes sensitive data to security risks. Non-SSL (ssl=[f]alse) connections can be vulnerable to man-in-the-middle attacks, unauthroized data access, and credential theft during transmission. It is strongly recommended to enable SSL/TLS encryption for all database connections in production environments to ensure data security and compliance with security best practices. </h4>
\qecho <h4> Please check <a href="https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL.Concepts.General.SSL.html">Using SSL with a PostgreSQL DB instance</a> documentation for additional details. </h4>
\qecho <br>
\qecho <details>
\qecho <h3>SSL Configuration Parameters and Settings</h3>
select name as "Parameter_Name" , setting as value,short_desc  from pg_settings where name like '%ssl%';
\qecho <br>
\qecho <h3>SSL Version: Connection Count by Protocol Version</h3>
\qecho <h4> Note: ssl version 'NULL' indicates connections that are not using SSL encryption. </h4>
select version as ssl_version , count (*) as "Connection_count" FROM pg_stat_ssl group by version ;
\qecho <br>
\qecho <h3>SSL Connection Summary: Total Count by SSL Status</h3>
\qecho <h4> Note: ssl=f indicates the total number of connections that are not using SSL encryption. </h4>
select ssl , count (*) as "Connection_count" FROM pg_stat_ssl group by ssl ;
\qecho <br>
\qecho <h3>SSL Usage by Connection: Database, User, and Client Details</h3>
\qecho <h4> Note: ssl=f indicates connections that are not using SSL encryption. </h4>
SELECT datname as "Database_Name" ,usename as "User_Name", ssl, backend_start, client_addr , application_name, backend_type
FROM pg_stat_ssl
JOIN pg_stat_activity AS psa
ON pg_stat_ssl.pid = psa.pid
WHERE psa.backend_type = 'client backend' and psa.usename != 'rdsadmin'
order by ssl ;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif


\if :do_bg_processes
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
\endif

\if :do_mxid
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
\endif


\if :do_temp
-- +----------------------------------------------------------------------------+
-- |      - Temp Tables & Files                              -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Temp_tables_files"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Temp Tables & Files</b></font><hr align="left" width="460">

\qecho <br>
\qecho <details>
\qecho <h3>Parameters:</h3>

select 
name as parameter_name,setting,unit,short_desc  
FROM pg_catalog.pg_settings 
WHERE name in ('temp_tablespaces','temp_file_limit','log_temp_files' , 'work_mem') ;
\qecho <br>
select name as parameter_name, setting , unit,   (((setting::BIGINT)*8)/1024)::BIGINT  as "size_MB" ,(((setting::BIGINT)*8)/1024/1024)::BIGINT  as "size_GB", pg_size_pretty((((setting::BIGINT)*8)*1024)::BIGINT),short_desc  
from pg_settings where name in ('temp_buffers') ;
\qecho <br>
\qecho <h3>Temp files statistics:</h3>
\qecho <h4>Note: Number of temporary files created by queries in every Database and total amount of data written to temporary files by queries in every Database </h4>
\qecho <br>
select datname as database_name, temp_bytes/1024/1024 temp_size_MB,
temp_bytes/1024/1024/1024 temp_size_GB ,temp_files  from  pg_stat_database
where  temp_bytes + temp_files > 0
and datname is not null  
order by 2  desc;

\qecho <br>
\qecho <h4>Grand Total - Overall statistics across all tablespaces:</h4>
\qecho <h4>Note: Total count and size of all temporary files across all tablespaces in the database</h4>
\qecho <br>
SELECT 
    SUM(file_count) AS total_files,
    SUM(total_size_bytes) AS total_size_bytes,
    pg_size_pretty(SUM(total_size_bytes)) AS total_size_formatted
FROM (
    SELECT 
        ts.spcname AS tablespace_name,
        COUNT(*) AS file_count,
        SUM(tmp.size) AS total_size_bytes,
        pg_size_pretty(SUM(tmp.size)) AS total_size_formatted,
        MIN(tmp.modification) AS oldest_file,
        MAX(tmp.modification) AS newest_file
    FROM pg_tablespace ts
    CROSS JOIN LATERAL pg_ls_tmpdir(ts.oid) AS tmp
    GROUP BY ts.spcname
    ORDER BY SUM(tmp.size) DESC
) AS tablespace_stats;

\qecho <br>
\qecho <h4>Per Tablespace - Statistics grouped by tablespace:</h4>
\qecho <h4>Note: Temporary file statistics for each tablespace individually</h4>
\qecho <br>
SELECT 
    ts.spcname AS tablespace_name,
    COUNT(*) AS file_count,
    SUM(tmp.size) AS total_size_bytes,
    pg_size_pretty(SUM(tmp.size)) AS total_size_formatted,
    MIN(tmp.modification) AS oldest_file,
    MAX(tmp.modification) AS newest_file
FROM pg_tablespace ts
CROSS JOIN LATERAL pg_ls_tmpdir(ts.oid) AS tmp
GROUP BY ts.spcname
ORDER BY SUM(tmp.size) DESC;

\qecho <br>
\qecho <h4>By Process ID with Active Query Details:</h4>
\qecho <h4>Note: Shows which PostgreSQL backend processes (PIDs) are using temp files across all tablespaces</h4>
\qecho <br>
SELECT
    a.database_name,
    a.user_name,
    a.application_name,
    a.pid,
    a.state,
    a.wait_event,
    a.query_id,
    t.temp_files_count,
    t.total_temp_size_bytes,
    t.total_temp_size_formatted,
    t.tablespaces_used,
    a.query
FROM (
    SELECT
        REPLACE(LEFT(tmp.name, STRPOS(tmp.name, '.') - 1), 'pgsql_tmp', '')::integer AS pid,
        COUNT(*) AS temp_files_count,
        SUM(tmp.size) AS total_temp_size_bytes,
        pg_size_pretty(SUM(tmp.size)) AS total_temp_size_formatted,
        STRING_AGG(DISTINCT ts.spcname, ', ') AS tablespaces_used
    FROM
        pg_tablespace ts
    CROSS JOIN LATERAL
        pg_ls_tmpdir(ts.oid) AS tmp
    GROUP BY
        pid
) t
JOIN (
    SELECT
        datname AS database_name,
        pid,
        state,
        wait_event,
        usename AS user_name,
        application_name,
        query_id,
        query
    FROM
        pg_stat_activity
) a ON t.pid = a.pid
ORDER BY
    t.total_temp_size_bytes DESC;

\qecho <br>
\qecho <h4>Detailed List - All temporary files with full details:</h4>
\qecho <h4>Note: Lists every individual temporary file across all tablespaces</h4>
\qecho <br>
SELECT
    ts.spcname AS tablespace_name,
    tmp.name AS filename,
    tmp.size AS size_bytes,
    pg_size_pretty(tmp.size) AS size_formatted,
    tmp.modification AS last_modified
FROM
    pg_tablespace ts
CROSS JOIN LATERAL
    pg_ls_tmpdir(ts.oid) AS tmp
ORDER BY
    ts.spcname, tmp.modification;

\qecho <br>
\qecho <h3>Temp tables statistics:</h3>

\qecho <h4>Database-Wide Summary (Grand Total):</h4>
\qecho <h4>Note: Single-row summary of all temporary table usage across the entire database</h4>
\qecho <br>
SELECT
    COUNT(DISTINCT a.pid) AS active_sessions_with_temp_tables,
    COUNT(c.relname) AS total_temp_tables,
    pg_size_pretty(SUM(pg_total_relation_size(c.oid))) AS total_size,
    SUM(pg_total_relation_size(c.oid)) AS total_size_bytes
FROM pg_stat_get_backend_idset() AS b(id)
JOIN pg_namespace n ON n.nspname = 'pg_temp_' || b.id
JOIN pg_class c ON n.oid = c.relnamespace
JOIN pg_stat_activity a ON a.pid = pg_stat_get_backend_pid(b.id)
WHERE c.relkind = 'r';

\qecho <br>
\qecho <h4>Session-Level Summary:</h4>
\qecho <h4>Note: Aggregated view of temporary table usage per session</h4>
\qecho <br>
SELECT
    a.pid AS session_pid,
    a.usename AS user_name,
    b.id AS backend_id,
    COUNT(c.relname) AS table_count,
    pg_size_pretty(SUM(pg_total_relation_size(c.oid))) AS total_size,
    SUM(pg_total_relation_size(c.oid)) AS total_size_bytes
FROM pg_stat_get_backend_idset() AS b(id)
JOIN pg_namespace n ON n.nspname = 'pg_temp_' || b.id
JOIN pg_class c ON n.oid = c.relnamespace
JOIN pg_stat_activity a ON a.pid = pg_stat_get_backend_pid(b.id)
WHERE c.relkind = 'r'
GROUP BY a.pid, a.usename, b.id
ORDER BY total_size_bytes DESC;

\qecho <br>
\qecho <h4>Individual Table Details:</h4>
\qecho <h4>Note: Detailed, granular view of each individual temporary table</h4>
\qecho <br>
SELECT
    b.id AS backend_id,
    n.nspname AS schema_name,
    c.relname AS table_name,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size,
    a.pid AS session_pid,
    a.usename AS user_name
FROM pg_stat_get_backend_idset() AS b(id)
JOIN pg_namespace n ON n.nspname = 'pg_temp_' || b.id
JOIN pg_class c ON n.oid = c.relnamespace
JOIN pg_stat_activity a ON a.pid = pg_stat_get_backend_pid(b.id)
WHERE c.relkind = 'r'
ORDER BY pg_total_relation_size(c.oid) DESC;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif

\if :do_large_objects
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
SELECT n.nspname as "Schema",
  c.relname as "Name",
  CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'm' THEN 'materialized view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 't' THEN 'TOAST table' WHEN 'f' THEN 'foreign table' WHEN 'p' THEN 'partitioned table' WHEN 'I' THEN 'partitioned index' END as "Type",
  pg_catalog.pg_get_userbyid(c.relowner) as "Owner",
  CASE c.relpersistence WHEN 'p' THEN 'permanent' WHEN 't' THEN 'temporary' WHEN 'u' THEN 'unlogged' END as "Persistence",
  am.amname as "Access method",
  pg_catalog.pg_size_pretty(pg_catalog.pg_table_size(c.oid)) as "Size",
  pg_catalog.obj_description(c.oid, 'pg_class') as "Description"
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
     LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam
WHERE c.relkind IN ('r','p','t','s','')
  AND c.relname OPERATOR(pg_catalog.~) '^(pg_largeobject_metadata)$' COLLATE pg_catalog.default
  AND pg_catalog.pg_table_is_visible(c.oid)
ORDER BY 1,2;
\qecho <br>
--select count(*)  from pg_largeobject;
-- in RDS PG : ERROR:  permission denied for table pg_largeobject

\qecho <br>
\qecho <h3>pg_largeobject table size: </h3>
\qecho <h4>Each large object is broken into segments or pages small enough to be conveniently stored as rows in pg_largeobject. </h4>
\qecho <h4>The amount of data per page is defined to be LOBLKSIZE (which is currently BLCKSZ/4, or typically 2 kB)</h4>
\qecho <br>
SELECT n.nspname as "Schema",
  c.relname as "Name",
  CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'm' THEN 'materialized view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 't' THEN 'TOAST table' WHEN 'f' THEN 'foreign table' WHEN 'p' THEN 'partitioned table' WHEN 'I' THEN 'partitioned index' END as "Type",
  pg_catalog.pg_get_userbyid(c.relowner) as "Owner",
  CASE c.relpersistence WHEN 'p' THEN 'permanent' WHEN 't' THEN 'temporary' WHEN 'u' THEN 'unlogged' END as "Persistence",
  am.amname as "Access method",
  pg_catalog.pg_size_pretty(pg_catalog.pg_table_size(c.oid)) as "Size",
  pg_catalog.obj_description(c.oid, 'pg_class') as "Description"
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
     LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam
WHERE c.relkind IN ('r','p','t','s','')
  AND c.relname OPERATOR(pg_catalog.~) '^(pg_largeobject)$' COLLATE pg_catalog.default
  AND pg_catalog.pg_table_is_visible(c.oid)
ORDER BY 1,2;
\qecho </details>


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif


\if :do_partitions
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

\qecho <br>
\qecho <h3>Partition tables summary with total sizes</h3>

SELECT
    parent.relnamespace::regnamespace AS parent_schema,
    parent.relname                    AS parent_table_name,
    count(child.oid)                  AS partition_count,
    pg_size_pretty(sum(pg_total_relation_size(child.oid))) AS total_size,
    pg_size_pretty(sum(pg_relation_size(child.oid))) AS table_size,
    pg_size_pretty(sum(pg_total_relation_size(child.oid)) - sum(pg_relation_size(child.oid))) AS indexes_size,
    sum(pg_total_relation_size(child.oid)) AS total_size_bytes
FROM pg_inherits
    JOIN pg_class parent ON pg_inherits.inhparent = parent.oid
    JOIN pg_class child ON pg_inherits.inhrelid = child.oid
    JOIN pg_namespace pn ON parent.relnamespace = pn.oid
WHERE pn.nspname NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
  AND parent.relkind = 'p'
GROUP BY parent.relnamespace, parent.relname
ORDER BY sum(pg_total_relation_size(child.oid)) DESC;

\qecho <br>
\qecho <h3>Individual partition sizes with details</h3>

SELECT
    parent.relnamespace::regnamespace AS parent_schema,
    parent.relname                    AS parent_table_name,
    child.relname                     AS partition_name,
    pg_size_pretty(pg_total_relation_size(child.oid)) AS total_size,
    pg_size_pretty(pg_relation_size(child.oid)) AS table_size,
    pg_size_pretty(pg_indexes_size(child.oid)) AS indexes_size,
    pg_size_pretty(pg_total_relation_size(child.oid) - pg_relation_size(child.oid) - pg_indexes_size(child.oid)) AS toast_size,
    round(100.0 * pg_total_relation_size(child.oid) / 
          NULLIF(sum(pg_total_relation_size(child.oid)) OVER (PARTITION BY parent.oid), 0), 2) AS pct_of_parent,
    pg_total_relation_size(child.oid) AS total_size_bytes
FROM pg_inherits
    JOIN pg_class parent ON pg_inherits.inhparent = parent.oid
    JOIN pg_class child ON pg_inherits.inhrelid = child.oid
    JOIN pg_namespace pn ON parent.relnamespace = pn.oid
WHERE pn.nspname NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
ORDER BY parent.relnamespace, parent.relname, pg_total_relation_size(child.oid) DESC;

\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif


\if :do_pg_shdepend
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
\endif

\if :do_fk_no_index
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
\endif


\if :do_sequences
-- +----------------------------------------------------------------------------+
-- |      - sequences                                    -                      |
-- +----------------------------------------------------------------------------+


\qecho <a name="sequences"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Sequences</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
-- Detection query for sequences section (self-contained for selective mode)
SELECT count(1) > 0 as obsrv_less_remaining_sequences FROM (SELECT 
    schemaname as Schema,
    sequencename as Sequence_Name,
    data_type::regtype as Data_Type,
    last_value as Current_Value,
    max_value as Max_Value,
    min_value as Min_Value,
    increment_by as Increment_By,
    CASE 
        WHEN max_value = 9223372036854775807 THEN 'No Limit'
        ELSE round(((max_value - last_value)::numeric / (max_value - min_value)::numeric * 100), 2)::text || '%'
    END as Remaining_Percentage,
    CASE 
        WHEN max_value = 9223372036854775807 THEN 'No Action Needed'
        WHEN ((max_value - last_value)::numeric / (max_value - min_value)::numeric * 100) < 1 
        THEN 'CRITICAL: Less than 1% remaining'
        WHEN ((max_value - last_value)::numeric / (max_value - min_value)::numeric * 100) < 5 
        THEN 'WARNING: Less than 5% remaining'
        WHEN ((max_value - last_value)::numeric / (max_value - min_value)::numeric * 100) < 10 
        THEN 'NOTICE: Less than 10% remaining'
        ELSE 'OK'
    END as Status
FROM pg_sequences) seq WHERE status not in ('OK', 'No Action Needed') \gset
\if :obsrv_less_remaining_sequences
\qecho <h4> Sequences that have less than 10% remaining values need attention to prevent potential issues: </h4>
\qecho <ul>
\qecho <li> Running out of sequence values can cause application failures </li>
\qecho <li> Some sequences might need to be altered to use larger ranges </li>
\qecho </ul>
\qecho <h4> The following sequences are identified with less than 10% remaining values: </h4>
\qecho <details>

SELECT * FROM (SELECT 
    schemaname as Schema,
    sequencename as Sequence_Name,
    data_type::regtype as Data_Type,
    last_value as Current_Value,
    max_value as Max_Value,
    min_value as Min_Value,
    increment_by as Increment_By,
    cycle,
    cache_size,
    max_value - last_value as remaining_values,
    CASE 
        WHEN max_value = 9223372036854775807 THEN 'No Limit'
        ELSE round(((max_value - last_value)::numeric / (max_value - min_value)::numeric * 100), 2)::text || '%'
    END as Remaining_Percentage,
    CASE 
        WHEN max_value = 9223372036854775807 THEN 'No Action Needed'
        WHEN ((max_value - last_value)::numeric / (max_value - min_value)::numeric * 100) < 1 
        THEN '1-CRITICAL: Less than 1% remaining'
        WHEN ((max_value - last_value)::numeric / (max_value - min_value)::numeric * 100) < 5 
        THEN '2-WARNING: Less than 5% remaining'
        WHEN ((max_value - last_value)::numeric / (max_value - min_value)::numeric * 100) < 10 
        THEN '3-NOTICE: Less than 10% remaining'
        ELSE 'OK'
    END as Status
FROM pg_sequences) seq WHERE status not in ('OK', 'No Action Needed') Order by status;

\qecho </details>

\qecho <h4>Recommendations for managing low-value sequences:</h4>
\qecho <ul>
\qecho <li> For sequences nearing exhaustion, consider: </li>
\qecho <ul>
\qecho <li> - Altering the sequence to use a larger range: </li>
\qecho <code>ALTER SEQUENCE sequence_name AS bigint;</code>
\qecho <li> - Setting a new starting value if values are available in the negative range: </li>
\qecho <code>ALTER SEQUENCE sequence_name RESTART WITH [new_value];</code>
\qecho <li> - Enabling cycling if appropriate for your application: </li>
\qecho <code>ALTER SEQUENCE sequence_name CYCLE;</code>
\qecho </ul>
 \else
 \endif
\qecho <br>
\qecho <h3>All sequences:</h3>
select * ,(sec.max_value - coalesce(sec.last_value,0)) as remain_values ,round((((sec.max_value - coalesce(sec.last_value,0)::float)/sec.max_value::float) *100)::int,2) remain_values_pct from pg_sequences sec order by remain_values_pct;

\qecho </details>


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif

\if :do_pg_hba
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
\endif



\if :do_dup_idx
-- +----------------------------------------------------------------------------+
-- |      - Duplicate_indexes                                   -               |
-- +----------------------------------------------------------------------------+


\qecho <a name="Duplicate_indexes"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Duplicate indexes</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h3> Note:</h3>
\qecho <h4> Duplicate indexes can have an impact on database performance in multiple ways. Firstly, they consume additional disk space, which can lead to higher storage costs and it can lead to high numbers of LWLock:buffer_content (BufferContent) wait events . Secondly, the presence of duplicate indexes can slow down write operations, as the database must update all relevant indexes when inserting, updating, or deleting records. This "write amplification" effect can degrade overall performance. Additionally, duplicate indexes can complicate query optimization, as the query planner may need to evaluate multiple indexes that serve the same purpose, potentially resulting in suboptimal query plans. Finally, maintaining duplicate indexes adds overhead to database maintenance tasks such as VACUUM.  </h4>
\qecho <h4> Before dropping any duplicate indexes, it is recommended to review the Index definition (DDL) of the duplicate indexes to confirm . This can be done by executing the following SQL query: </h4>
\qecho <h4> SELECT * FROM pg_indexes WHERE indexname in  ('\''Index Name'\'','\''Index Name'\''); </h4>
\qecho <h4> Additionally, it is advisable to check index scans for the duplicate indexes using the following query: </h4>
\qecho <h4> SELECT * FROM pg_catalog.pg_stat_all_indexes WHERE indexrelname in ('\''Index Name'\'','\''Index Name'\''); </h4>
\qecho <br>
\qecho <details>
WITH duplicate_indexes AS (
  SELECT
    indexrelid::regclass as index_name,
    indrelid::regclass as table_name,
    pg_relation_size(indexrelid) as index_size_bytes,
    pg_size_pretty(pg_relation_size(indexrelid)) as index_size,
    pg_get_indexdef(indexrelid) as index_definition,
    (indrelid::text || E'\n' ||
     indclass::text || E'\n' ||
     indkey::text || E'\n' ||
     coalesce(indexprs::text, '') || E'\n' ||
     coalesce(indpred::text, '')) as duplicate_key,
    indisunique as is_unique,
    indisprimary as is_primary,
    indisvalid as is_valid
  FROM pg_index
),
duplicate_groups AS (
  SELECT
    duplicate_key,
    count(*) as duplicate_count,
    sum(index_size_bytes) as total_size_bytes
  FROM duplicate_indexes
  GROUP BY duplicate_key
  HAVING count(*) > 1
)
SELECT
  di.table_name,
  di.index_name,
  di.index_size,
  di.is_valid,
  dg.duplicate_count,
  pg_size_pretty(dg.total_size_bytes) as total_group_size,
  CASE
    WHEN di.is_primary THEN 'PRIMARY KEY'
    WHEN di.is_unique THEN 'UNIQUE'
    ELSE 'NOT PK OR UNIQUE'
  END as index_type,
  di.index_definition
FROM duplicate_indexes di
JOIN duplicate_groups dg ON di.duplicate_key = dg.duplicate_key
ORDER BY
  dg.total_size_bytes DESC,
  di.table_name,
  di.is_valid ASC,  -- Invalid indexes first (false < true)
  di.index_size_bytes DESC;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif


\if :do_functions
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
round((total_time/NULLIF(calls,0))::numeric,2) as mean_time, self_time
from pg_catalog.pg_stat_user_functions
order by total_time desc;

\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif


\if :do_db_load
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
\endif

\if :do_triggers
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
\endif

\if :do_pg_config
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
\endif


\if :do_db_params
-- +----------------------------------------------------------------------------+
-- |      - DB_parameters                                    -                  |
-- +----------------------------------------------------------------------------+

\qecho <a name="DB_parameters"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>DB parameters</b></font><hr align="left" width="460">
\qecho <br>
-- Detection queries for DB parameters warnings (self-contained for selective mode)
select count(*) > 0 obsrv_autovacuum_parameter_disabled FROM pg_settings WHERE name = 'autovacuum' and setting != 'on' \gset
select count(*) > 0 obsrv_track_counts_parameter_disabled FROM pg_settings WHERE name = 'track_counts' and setting != 'on' \gset
select count(*) > 0 obsrv_enable_indexonlyscan_parameter_disabled FROM pg_settings WHERE name = 'enable_indexonlyscan' and setting != 'on' \gset
select count(*) > 0 obsrv_enable_indexscan_parameter_disabled FROM pg_settings WHERE name = 'enable_indexscan' and setting != 'on' \gset
SELECT count(*) > 0 obsrv_excessive_logging_logstatement FROM pg_settings WHERE name = 'log_statement' and setting IN ('all', 'mod') \gset
SELECT count(*) > 0 obsrv_excessive_logging_logsmindurstmt FROM pg_settings WHERE name = 'log_min_duration_statement' and setting IN ('0') \gset
SELECT count(*) > 0 obsrv_excessive_logging_logsminmsgs FROM pg_settings WHERE name = 'log_min_messages' and setting IN ('debug5', 'debug4', 'debug3', 'debug2', 'debug1') \gset
SELECT count(*) > 0 obsrv_excessive_log_stmt_stats FROM pg_settings WHERE name = 'log_statement_stats' and setting IN ('on') \gset
SELECT count(*) > 0 obsrv_excessive_log_parser_stats FROM pg_settings WHERE name = 'log_parser_stats' and setting IN ('on') \gset
SELECT count(*) > 0 obsrv_excessive_log_planner_stats FROM pg_settings WHERE name = 'log_planner_stats' and setting IN ('on') \gset
SELECT count(*) > 0 obsrv_excessive_log_executor_stats FROM pg_settings WHERE name = 'log_executor_stats' and setting IN ('on') \gset
SELECT count(*) > 0 obsrv_excessive_debug_print_parse FROM pg_settings WHERE name = 'debug_print_parse' and setting IN ('on') \gset
SELECT count(*) > 0 obsrv_excessive_debug_print_rewritten FROM pg_settings WHERE name = 'debug_print_rewritten' and setting IN ('on') \gset
SELECT count(*) > 0 obsrv_excessive_debug_print_plan FROM pg_settings WHERE name = 'debug_print_plan' and setting IN ('on') \gset
select count(*) > 0 obsrv_synchronous_commit_parameter_disabled FROM pg_settings WHERE name = 'synchronous_commit' and setting = 'off' \gset
 \if :obsrv_autovacuum_parameter_disabled
     \qecho <br>
     \qecho '&#8594; The autovacuum parameter is disabled, Turning autovacuum off increases the table and index bloat and impacts the performance.'
 \else
 \endif

 \if :obsrv_track_counts_parameter_disabled
     \qecho <br>
     \qecho '&#8594; The track_counts parameter is disabled, When the track_counts parameter is turned off, the database does not collect the database activity statistics. Autovacuum requires these statistics to work correctly.'
 \else
 \endif


 \if :obsrv_enable_indexonlyscan_parameter_disabled
     \qecho <br>
     \qecho '&#8594; The enable_indexonlyscan parameter is disabled, The query planner or optimizer can not use the index-only scan plan type when it is turned off.'
 \else
 \endif

\if :obsrv_enable_indexscan_parameter_disabled
     \qecho <br>
     \qecho '&#8594; The enable_indexscan parameter is disabled, The query planner or optimizer can not use the index scan plan type when it is turned off.'
 \else
 \endif

\if :obsrv_excessive_logging_logstatement
     \qecho <br>
     \qecho '&#8594; The current log_statement parameter is configured to either all or mod, which generates excessive log entries. This extensive logging can negatively impact database performance. It is recommended to set the parameter to none unless detailed logging is specifically required for troubleshooting or audit purposes.'
\else
\endif

\if :obsrv_excessive_logging_logsmindurstmt
     \qecho <br>
     \qecho '&#8594; The log_min_duration_statement is set to 0, causing all query durations to be logged and impacting performance. Consider setting it to -1 (disabled) or a higher value based on your monitoring requirements.'
\else
\endif

\if :obsrv_excessive_logging_logsminmsgs
     \qecho <br>
     \qecho '&#8594; The log_min_messages parameter is set to a DEBUG[n] level, resulting in excessive logging that may degrade database performance. Consider changing it to the default WARNING level.'
\else
\endif

\if :obsrv_excessive_log_stmt_stats
     \qecho <br>
     \qecho '&#8594; The log_statement_stats parameter is currently enabled (set to on), which generates detailed statement statistics logs. This comprehensive logging can negatively impact database performance. Consider disabling it by setting the parameter to off'
\else
\endif

\if :obsrv_excessive_log_parser_stats
     \qecho <br>
     \qecho '&#8594; The log_parser_stats parameter is currently enabled, which generates detailed parser statistics for each SQL statement. This verbose logging creates unnecessary overhead and can degrade database performance. Consider disabling it by setting the parameter to off'
\else
\endif

\if :obsrv_excessive_log_planner_stats
     \qecho <br>
     \qecho '&#8594; "The log_planner_stats parameter is currently enabled, which writes query planner performance statistics to the server log. This detailed logging creates additional overhead and can negatively impact database performance. Consider setting it to off'
\else
\endif

\if :obsrv_excessive_log_executor_stats
     \qecho <br>
     \qecho '&#8594; The log_executor_stats parameter is currently enabled, which writes executor performance statistics to the server log. This detailed logging creates additional overhead and can significantly impact database performance. Consider disabling it by setting the parameter to off'
\else
\endif

\if :obsrv_excessive_debug_print_parse
     \qecho <br>
     \qecho '&#8594; The debug_print_parse parameter is currently enabled, which logs the parse tree for each query. This verbose logging can generate excessive output and significantly degrade database performance. Consider disabling it by setting the parameter to off'
\else
\endif

\if :obsrv_excessive_debug_print_rewritten
     \qecho <br>
     \qecho '&#8594; The debug_print_rewritten parameter is currently enabled, which logs the output of the query rewriter for each query. This detailed logging can produce excessive output and negatively impact database performance. Consider disabling it by setting the parameter to off'
\else
\endif

\if :obsrv_excessive_debug_print_plan
     \qecho <br>
     \qecho '&#8594; The debug_print_plan parameter is currently enabled, which logs the execution plan for each query. This detailed logging can generate excessive output and significantly impact database performance. Consider disabling it by setting the parameter to off'
\else
\endif

\if :obsrv_synchronous_commit_parameter_disabled
    \qecho <br>
    \qecho '&#8594; The synchronous_commit parameter is disabled. This introduces the risk of data loss, as asynchronous commit may be lost if the database crashes before the transaction is truly committed, meaning it is flushed to the transaction log (WAL). Please check <a href="https://www.postgresql.org/docs/current/wal-async-commit.html">Asynchronous Commit</a> documentation for additional details.'
\else
\endif

\qecho <br>
\qecho <br>
\qecho <details>
SELECT *  FROM pg_settings where name not in ('rds.extensions') order by category;
SELECT *  FROM pg_settings where name in ('rds.extensions') order by category;
\qecho </details>

\qecho <br>
\qecho <br>
\qecho <h3>Parameters pending restart:</h3>
\qecho <h4>Note: These parameters have been changed in the configuration file or via ALTER SYSTEM but require a database restart to take effect.</h4>
\qecho <br>
\qecho <details>
SELECT name AS parameter_name,
    setting AS current_value,
    unit,
    boot_val AS boot_value,
    reset_val AS pending_value,
    pending_restart,
    source,
    sourcefile
FROM pg_settings
WHERE pending_restart = true
ORDER BY name;
\qecho </details>

\qecho <br>
\qecho <br>
\qecho <h3>Parameters Access Control List (ACL)</h3>
\qecho <br>
\qecho <b>Note:</b> From PostgreSQL 15, permissions on individual configuration parameters can be explicitly granted to individual database users, using the syntax GRANT SET ON PARAMETER or GRANT ALTER SYSTEM ON PARAMETER (and correspondingly removed with REVOKE). These permissions are tracked via pg_parameter_acl.
\qecho <br>
\qecho <br>
\qecho <details>
SELECT 
    p.parname AS parameter_name,
    s.setting AS current_value,
    s.context,
    split_part(acl_entry::text, '=', 1) AS role_name,
    CASE 
        WHEN split_part(split_part(acl_entry::text, '=', 2), '/', 1) LIKE '%s%' THEN 'Yes'
        ELSE 'No'
    END AS can_set,
    CASE 
        WHEN split_part(split_part(acl_entry::text, '=', 2), '/', 1) LIKE '%A%' THEN 'Yes'
        ELSE 'No'
    END AS can_alter_system,
    split_part(split_part(acl_entry::text, '=', 2), '/', 2) AS granted_by
FROM pg_catalog.pg_parameter_acl p
LEFT JOIN pg_catalog.pg_settings s ON p.parname = s.name
CROSS JOIN LATERAL unnest(p.paracl) AS acl_entry
ORDER BY p.parname, split_part(acl_entry::text, '=', 1);
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif

\if :do_copy_progress
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
\endif



\if :do_idx_progress
-- +----------------------------------------------------------------------------+
-- |      - Index_Creation_Progress                          -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Index_Creation_Progress"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Index Creation Progress</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
WITH parallel_workers AS (
    SELECT
        w.leader_pid,
        count(*) AS worker_count,
        array_agg(w.pid ORDER BY w.pid) AS worker_pids,
        array_agg(coalesce(w.wait_event_type ||'.'|| w.wait_event, 'CPU') ORDER BY w.pid) AS worker_wait_events,
        array_agg(w.state ORDER BY w.pid) AS worker_states
    FROM pg_stat_activity w
    WHERE w.backend_type = 'parallel worker'
      AND w.leader_pid IS NOT NULL
    GROUP BY w.leader_pid
)
SELECT 
    p.datname                                                 AS database_name,
    p.pid,
    clock_timestamp() - a.xact_start                          AS duration_so_far,
    a.application_name,
    a.client_addr,
    a.usename,
    coalesce(a.wait_event_type ||'.'|| a.wait_event, 'CPU')  AS waiting,
    p.command,
    trim(trailing ';' from a.query)                           AS query,
    a.state,
    p.relid::regclass                                         AS table_name,
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_inherits WHERE inhparent = p.relid)
        THEN pg_size_pretty((SELECT coalesce(sum(pg_relation_size(inhrelid)), 0) 
                             FROM pg_inherits WHERE inhparent = p.relid))
        ELSE pg_size_pretty(pg_relation_size(p.relid))
    END AS table_size,
    p.phase,
    CASE p.phase
        WHEN 'initializing' THEN '1 of 12'
        WHEN 'waiting for writers before build' THEN '2 of 12'
        WHEN 'building index: scanning table' THEN '3 of 12'
        WHEN 'building index: sorting live tuples' THEN '4 of 12'
        WHEN 'building index: loading tuples in tree' THEN '5 of 12'
        WHEN 'waiting for writers before validation' THEN '6 of 12'
        WHEN 'index validation: scanning index' THEN '7 of 12'
        WHEN 'index validation: sorting tuples' THEN '8 of 12'
        WHEN 'index validation: scanning table' THEN '9 of 12'
        WHEN 'waiting for old snapshots' THEN '10 of 12'
        WHEN 'waiting for readers before marking dead' THEN '11 of 12'
        WHEN 'waiting for readers before dropping' THEN '12 of 12'
    END AS phase_progress,
    format('%s (%s of %s)',
           coalesce(round(100.0 * p.blocks_done / nullif(p.blocks_total, 0), 2)::text || '%', 'not applicable'),
           p.blocks_done::text,
           p.blocks_total::text) AS scan_progress,
    format('%s (%s of %s)',
           coalesce(round(100.0 * p.tuples_done / nullif(p.tuples_total, 0), 2)::text || '%', 'not applicable'),
           p.tuples_done::text,
           p.tuples_total::text) AS tuples_loading_progress,
    format('%s (%s of %s)',
           coalesce((100 * p.lockers_done / nullif(p.lockers_total, 0))::text || '%', 'not applicable'),
           p.lockers_done::text,
           p.lockers_total::text) AS lockers_progress,
    format('%s (%s of %s)',
           coalesce((100 * p.partitions_done / nullif(p.partitions_total, 0))::text || '%', 'not applicable'),
           p.partitions_done::text,
           p.partitions_total::text) AS partitions_progress,
    p.current_locker_pid,
    trim(trailing ';' from l.query)                           AS current_locker_query,
    coalesce(pw.worker_count, 0)                              AS parallel_workers_count,
    pw.worker_pids                                            AS parallel_worker_pids,
    pw.worker_wait_events                                     AS parallel_worker_wait_events,
    pw.worker_states                                          AS parallel_worker_states
FROM pg_stat_progress_create_index   AS p
JOIN pg_stat_activity                AS a ON a.pid = p.pid
LEFT JOIN pg_stat_activity           AS l ON l.pid = p.current_locker_pid
LEFT JOIN parallel_workers           AS pw ON pw.leader_pid = p.pid
ORDER BY clock_timestamp() - a.xact_start DESC;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif



\if :do_invalid_db
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
\endif

\if :do_mat_views
-- +----------------------------------------------------------------------------+
-- |      - Materialized_Views                               -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Materialized_Views"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Materialized Views</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>

\qecho <h3>Materialized views count:</h3>
SELECT count(*) AS materialized_views_count FROM pg_matviews;

\qecho <br>
\qecho <h3>Materialized views summary:</h3>
SELECT 
    schemaname,
    matviewname,
    matviewowner,
    tablespace,
    hasindexes,
    ispopulated,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||matviewname)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||matviewname)) AS matview_size,
    pg_size_pretty(pg_indexes_size(schemaname||'.'||matviewname)) AS indexes_size
FROM pg_matviews
ORDER BY pg_total_relation_size(schemaname||'.'||matviewname) DESC;

\qecho <br>
\qecho <h3>Materialized views definitions:</h3>
SELECT 
    schemaname,
    matviewname,
    definition
FROM pg_matviews
ORDER BY schemaname, matviewname;

\qecho <br>
\qecho <h3>Unpopulated materialized views (need REFRESH):</h3>
SELECT 
    schemaname,
    matviewname,
    matviewowner,
    ispopulated
FROM pg_matviews
WHERE ispopulated = false
ORDER BY schemaname, matviewname;

\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif

\if :do_foreign_servers
-- +----------------------------------------------------------------------------+
-- |      - Foreign_Servers                                  -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Foreign_Servers"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Foreign Servers</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
\qecho <h3>Server Connection Details:</h3>
\qecho <h4>Note: Lists each foreign server with its network connection settings</h4>
\qecho <br>
SELECT
    fs.foreign_server_name AS server,
    fs.foreign_data_wrapper_name AS wrapper,
    MAX(CASE WHEN fso.option_name = 'host' THEN fso.option_value END) AS host,
    MAX(CASE WHEN fso.option_name = 'port' THEN fso.option_value END) AS port,
    MAX(CASE WHEN fso.option_name = 'dbname' THEN fso.option_value END) AS dbname
FROM information_schema.foreign_servers fs
LEFT JOIN information_schema.foreign_server_options fso
    ON fs.foreign_server_name = fso.foreign_server_name
GROUP BY fs.foreign_server_name, fs.foreign_data_wrapper_name
ORDER BY fs.foreign_server_name;
\qecho <br>
\qecho <h3>Usage Summary:</h3>
\qecho <h4>Note: Count of foreign tables mapped to each server</h4>
\qecho <br>
SELECT
    foreign_server_name,
    COUNT(*) AS total_foreign_tables
FROM information_schema.foreign_tables
GROUP BY foreign_server_name
ORDER BY total_foreign_tables DESC;
\qecho <br>
\qecho <h3>Foreign Tables Inventory:</h3>
\qecho <h4>Note: Shows every foreign table with its local and remote schema/table mapping</h4>
\qecho <br>
SELECT
    fs.foreign_server_name AS server,
    fs.foreign_data_wrapper_name AS wrapper,
    ft.foreign_table_schema AS local_schema,
    ft.foreign_table_name AS local_table,
    MAX(CASE WHEN fto.option_name = 'schema_name' THEN fto.option_value END) AS remote_schema,
    MAX(CASE WHEN fto.option_name = 'table_name' THEN fto.option_value END) AS remote_table
FROM information_schema.foreign_servers fs
JOIN information_schema.foreign_tables ft
    ON fs.foreign_server_name = ft.foreign_server_name
LEFT JOIN information_schema.foreign_table_options fto
    ON ft.foreign_table_schema = fto.foreign_table_schema
    AND ft.foreign_table_name = fto.foreign_table_name
GROUP BY fs.foreign_server_name, fs.foreign_data_wrapper_name,
         ft.foreign_table_schema, ft.foreign_table_name
ORDER BY server, local_table;
\qecho <br>
\qecho <h3>Security Audit - User Mappings:</h3>
\qecho <h4>Note: Shows which local users have credentials for remote servers. Passwords are masked.</h4>
\qecho <br>
SELECT
    um.authorization_identifier AS local_user,
    um.foreign_server_name AS server,
    MAX(CASE WHEN umo.option_name = 'user' THEN umo.option_value END) AS remote_user,
    MAX(CASE WHEN umo.option_name = 'password' THEN '********' END) AS password
FROM information_schema.user_mappings um
LEFT JOIN information_schema.user_mapping_options umo
    ON um.authorization_identifier = umo.authorization_identifier
    AND um.foreign_server_name = umo.foreign_server_name
GROUP BY um.authorization_identifier, um.foreign_server_name
ORDER BY server, local_user;
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif

----- Amazon Aurora PostgreSQL  -----
\if :isaurora
\if :do_aurora_version
-- +----------------------------------------------------------------------------+
-- |      - Aurora_version                                   -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Aurora_version"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Aurora version</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
SELECT * FROM aurora_version();
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif




\if :do_aurora_builtins
-- +----------------------------------------------------------------------------+
-- |      - Aurora_PostgreSQL_built-in_functions             -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Aurora_PostgreSQL_built-in_functions"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Aurora PostgreSQL built-in functions</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
SELECT * FROM aurora_list_builtins();
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif


\if :do_aurora_instance_id
-- +----------------------------------------------------------------------------+
-- |      - Aurora_db_instance_identifier             -                         |
-- +----------------------------------------------------------------------------+


\qecho <a name="Aurora_db_instance_identifier"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Aurora db instance identifier</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
SELECT server_id,
    CASE
        WHEN 'MASTER_SESSION_ID' = session_id THEN 'writer'
        ELSE 'reader'
    END AS instance_role
FROM aurora_replica_status() rt,
         aurora_db_instance_identifier() di
    WHERE rt.server_id = di;
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif

\if :do_aurora_cluster
-- +----------------------------------------------------------------------------+
-- |      - Aurora_cluster_instances                  -                         |
-- +----------------------------------------------------------------------------+


\qecho <a name="Aurora_cluster_instances"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Aurora cluster instances</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
 SELECT server_id,
    CASE
        WHEN 'MASTER_SESSION_ID' = session_id THEN 'writer'
        ELSE 'reader'
    END AS instance_role
FROM aurora_replica_status() ;
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif

\if :do_aurora_replica_lag
-- +----------------------------------------------------------------------------+
-- |      - Aurora_reader_instances-Replica_Lag              -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Aurora_reader_instances-Replica_Lag"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Aurora reader instances - Replica Lag</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
SELECT server_id, 
    CASE 
        WHEN 'MASTER_SESSION_ID' = session_id THEN 'writer'
        ELSE 'reader' 
    END AS instance_role,
    replica_lag_in_msec AS replica_lag_ms,
    round(extract (epoch FROM (SELECT age(clock_timestamp(), last_update_timestamp))) * 1000) AS last_update_age_ms
FROM aurora_replica_status()
ORDER BY replica_lag_in_msec NULLS FIRST;
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif



\if :do_aurora_ccm
-- +----------------------------------------------------------------------------+
-- |      - Aurora_cluster_cache_management_(CCM)            -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Aurora_cluster_cache_management_(CCM)"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Aurora cluster cache management (CCM)</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
SELECT *  FROM aurora_ccm_status();
SELECT buffers_sent_last_minute * 8/60 AS warm_rate_kbps,
100 * (1.0-buffers_sent_last_scan/buffers_found_last_scan) AS warm_percent 
FROM aurora_ccm_status ();
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif



\if :do_aurora_global_db
-- +----------------------------------------------------------------------------+
-- |      - Aurora_global_db_status                          -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="Aurora_global_db_status"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Aurora global db status</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
\if :isauroralimitless
  \qecho 'Aurora Global Database is not supported in Amazon Aurora Limitless Database'
  \else
  SELECT CASE 
          WHEN '-1' = durability_lag_in_msec THEN 'Primary'
          ELSE 'Secondary'
       END AS global_role,
       *
  FROM aurora_global_db_status();
\endif
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif

\if :do_aurora_wait_events
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
SELECT type_name as wait_event_type,
             event_name as wait_event_name,
             waits,
             wait_time
        FROM aurora_stat_system_waits()
NATURAL JOIN aurora_stat_wait_event()
NATURAL JOIN aurora_stat_wait_type() order by wait_time desc;
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif


\if :do_aurora_qpm
-- +----------------------------------------------------------------------------+
-- |      - query_plan_management                            -                  |
-- +----------------------------------------------------------------------------+

\qecho <a name="query_plan_management"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Query Plan Management (QPM)</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
select count(*) > 0 is_apg_plan_mgmt_enabled FROM pg_catalog.pg_extension where extname = 'apg_plan_mgmt' \gset
select count(*) = 0 is_apg_plan_mgmt_not_enabled FROM pg_catalog.pg_extension where extname = 'apg_plan_mgmt' \gset
\if :is_apg_plan_mgmt_not_enabled
  \qecho 'Query Plan Management (QPM) is not enabled'
\else
  \if :is_apg_plan_mgmt_enabled
   show rds.enable_plan_management ;
   \qecho <br>
   \qecho <h3>apg_plan_mgmt installed extension info :</h3>
   \qecho <br>
   SELECT e.extname AS "Extension Name", e.extversion AS "Version", n.nspname AS "Schema",pg_get_userbyid(e.extowner)  as Owner, c.description AS "Description" , e.extrelocatable as "relocatable to another schema", e.extconfig ,e.extcondition
   FROM pg_catalog.pg_extension e LEFT JOIN pg_catalog.pg_namespace n ON n.oid = e.extnamespace LEFT JOIN pg_catalog.pg_description c ON c.objoid = e.oid AND c.classoid = 'pg_catalog.pg_extension'::pg_catalog.regclass
   where e.extname = 'apg_plan_mgmt';
   \qecho <br>
   select * from pg_available_extensions where name='apg_plan_mgmt';
   \qecho <br>
   \qecho <h3>apg_plan_mgmt available extension version :</h3> 
   \qecho <br>
   SELECT name ,version ,installed FROM pg_available_extension_versions where  name='apg_plan_mgmt' order by version;
   \qecho <br>
   \qecho <h3>Query Plan Management parameters  :</h3>
   \qecho <br>
   select name,setting from pg_settings  where name like 'apg_plan_mgmt%';
   \qecho <br>
   \qecho <h3>apg_plan_mgmt.max_plans utilization :</h3> 
   \qecho <br>
   with plans_stored_count as (select count(*) as cnt from apg_plan_mgmt.dba_plans) 
   select s.setting as max_plans, p.cnt as plans_stored_count, (p.cnt/s.setting::int)*100 as plans_stored_PCT_from_max_plans from pg_settings s, plans_stored_count p where s.name ='apg_plan_mgmt.max_plans';
   \qecho <br>
   \qecho <h3>apg_plan_mgmt.plans table size :</h3> 
   \qecho <br>
   SELECT pg_size_pretty(pg_total_relation_size('apg_plan_mgmt.plans')) as "apg_plan_mgmt.plans total table size (table+indexes)";
   \qecho <br>
   SELECT pg_size_pretty(pg_relation_size('apg_plan_mgmt.plans')) as "apg_plan_mgmt.plans table size";
   \qecho <br>
   \qecho <h3>sqls (sql_hash) that have multiple plans  :</h3>
   \qecho <br>
   SELECT sql_hash,plan_hash,status,enabled,origin,estimated_total_cost,plan_created,queryid ,sql_text,stmt_name,                 param_types,               param_list,               plan_outline,                               environment_variables,last_verified,             last_validated,           last_used,                 created_by,               compatibility_level,       has_side_effects,         planning_time_ms,         execution_time_ms,         cardinality_error,         estimated_startup_cost,    estimated_total_cost,      total_time_benefit_ms,     execution_time_benefit_ms
   FROM apg_plan_mgmt.dba_plans
   WHERE sql_hash IN (SELECT sql_hash
   FROM apg_plan_mgmt.dba_plans
   GROUP BY sql_hash
   HAVING COUNT(DISTINCT plan_hash) > 1)
   ORDER BY sql_hash, estimated_total_cost;
   \qecho <br>
   \qecho <h3>sqls (sql_hash) that have multiple plans where an Unapproved plan has lower cost than other plans :</h3>
   \qecho <br>
   WITH plan_costs AS (SELECT
   sql_hash,
   plan_hash,
   status,
   estimated_total_cost,
   MIN(CASE WHEN status != 'Unapproved' THEN estimated_total_cost END)
   OVER (PARTITION BY sql_hash) AS min_non_unapproved_cost
   FROM
   apg_plan_mgmt.dba_plans
   WHERE
   sql_hash IN (SELECT sql_hash
   FROM apg_plan_mgmt.dba_plans
   GROUP BY sql_hash
   HAVING COUNT(DISTINCT plan_hash) > 1)),
   filtered_plans AS (SELECT DISTINCT
   sql_hash,
   MAX(CASE WHEN status = 'Unapproved' THEN estimated_total_cost END)
   OVER (PARTITION BY sql_hash) AS unapproved_cost,
   MAX(min_non_unapproved_cost) OVER (PARTITION BY sql_hash) AS other_plan_cost
   FROM
   plan_costs
   WHERE
   status = 'Unapproved'
   AND estimated_total_cost < min_non_unapproved_cost)
   SELECT
   fp.sql_hash,
   COUNT(DISTINCT pc.plan_hash) AS total_plans,
   fp.unapproved_cost,
   fp.other_plan_cost,
   fp.other_plan_cost - fp.unapproved_cost AS cost_savings
   FROM
   filtered_plans fp
   JOIN
   plan_costs pc ON fp.sql_hash = pc.sql_hash
   GROUP BY
   fp.sql_hash, fp.unapproved_cost, fp.other_plan_cost
   ORDER BY
   cost_savings DESC;
   \qecho <br>
   WITH eligible_sql_hashes AS (SELECT DISTINCT p1.sql_hash
   FROM apg_plan_mgmt.dba_plans p1
   JOIN apg_plan_mgmt.dba_plans p2
   ON p1.sql_hash = p2.sql_hash
   AND p1.plan_hash != p2.plan_hash
   WHERE
   p1.status = 'Unapproved'
   AND p2.status != 'Unapproved'
   AND p1.estimated_total_cost < p2.estimated_total_cost)
   SELECT
   dp.sql_hash,
   dp.plan_hash,
   dp.status,
   dp.enabled,
   dp.origin,
   dp.estimated_total_cost,
   dp.plan_created,
   dp.queryid ,
   dp.sql_text,
   dp.stmt_name,                 
   dp.param_types,               
   dp.param_list,               
   dp.plan_outline,                               
   dp.environment_variables,
   dp.last_verified,             
   dp.last_validated,           
   dp.last_used,                 
   dp.created_by,               
   dp.compatibility_level,       
   dp.has_side_effects,         
   dp.planning_time_ms,         
   dp.execution_time_ms,         
   dp.cardinality_error,         
   dp.estimated_startup_cost,    
   dp.total_time_benefit_ms,     
   dp.execution_time_benefit_ms
   FROM
   apg_plan_mgmt.dba_plans dp
   WHERE
   dp.sql_hash IN (SELECT sql_hash FROM eligible_sql_hashes)
   ORDER BY
   dp.sql_hash,
   dp.estimated_total_cost ASC,
   dp.status DESC;
   \qecho <br>
   \qecho <h3>Plan summary by status :</h3>
   \qecho <br>
   SELECT status, enabled, COUNT(*) AS plan_count FROM apg_plan_mgmt.dba_plans GROUP BY status, enabled ORDER BY status, enabled;
   \qecho <br>
   \qecho <h3>All Query Plans :</h3>
   \qecho <br>
   -- Check table size against 5 MB threshold
   SELECT 
     COUNT(*) as plan_count,
     pg_total_relation_size('apg_plan_mgmt.plans') as table_size_bytes,
     pg_size_pretty(pg_total_relation_size('apg_plan_mgmt.plans')) as table_size_pretty,
     pg_total_relation_size('apg_plan_mgmt.plans') > (5 * 1024 * 1024) as exceeds_size_limit
   FROM apg_plan_mgmt.dba_plans \gset
   \if :exceeds_size_limit
     \qecho <div style="border:1px solid orange; padding:10px; background-color:#fff3cd;">
     \qecho <p><b>⚠️ All Plans Section: Display Limited</b></p>
     \qecho <p><b>Reason:</b> The apg_plan_mgmt.plans table size (:table_size_pretty) exceeds the 5 MB threshold.</p>
     \qecho <p>Displaying all :plan_count plans would significantly increase the report size.</p>
     \qecho <p><b>Alternatives:</b></p>
     \qecho <ul>
     \qecho <li>Use the diagnostic sections above to view specific plans (multiple plans, unapproved plans, etc.)</li>
     \qecho <li>Query specific plans: <code>SELECT * FROM apg_plan_mgmt.dba_plans WHERE sql_hash = 'your_hash';</code></li>
     \qecho <li>Export to file: <code>COPY (SELECT * FROM apg_plan_mgmt.dba_plans) TO '/tmp/qpm_all_plans.csv' CSV HEADER</code></li>
     \qecho </ul>
     \qecho </div>
   \else
     \qecho <p><i>Displaying all :plan_count plans (table size: :table_size_pretty)</i></p>
     SELECT * FROM apg_plan_mgmt.dba_plans ORDER BY sql_hash, plan_hash, status;
   \endif
  \endif
\endif

\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif

\if :do_aurora_dml
-- +----------------------------------------------------------------------------+
-- |      - Aurora_dml_activity                              -                  |
-- +----------------------------------------------------------------------------+
\qecho <a name="Aurora_dml_activity"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Aurora dml activity</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
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
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif
\if :do_aurora_memctx
-- +----------------------------------------------------------------------------+
-- |      - process_memory_context_usage                              -         |
-- +----------------------------------------------------------------------------+
\qecho <a name="process_memory_context_usage"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Process memory context usage</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
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
\qecho <h3> The top 50 process  with the highest allocated memory: </h3>
\qecho <br>
select
pid, sum(allocated) as allocated_size_bytes ,pg_size_pretty(sum(allocated)) as allocated_size , pg_size_pretty(sum(used)) as used_size,
trunc(sum(used)/sum(allocated)*100,2) as used_pct
from aurora_stat_memctx_usage()
group by pid order by allocated_size_bytes desc
limit 50;

\qecho <br>
\qecho <h3> The top 50 process with the highest allocated memory including process information in pg_stat_activity view: </h3>
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
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif
\if :do_aurora_stat_stmt
-- +----------------------------------------------------------------------------+
-- |      - aurora_stat_statements                           -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="aurora_stat_statements"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Aurora_stat_statements</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
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
from aurora_stat_statements()
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
from aurora_stat_statements() 
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
from aurora_stat_statements() 
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
from aurora_stat_statements()
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
from aurora_stat_statements() 
order by storage_blks_read desc limit 50;
\qecho </details>
\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif


\if :do_aurora_stat_plans
-- +----------------------------------------------------------------------------+
-- |      - aurora_stat_plans                                -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="aurora_stat_plans"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Aurora_stat_plans</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
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

\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif

\if :do_aurora_wal_cache
-- +----------------------------------------------------------------------------+
-- |      - logical_replication_write_through_cache          -                  |
-- +----------------------------------------------------------------------------+


\qecho <a name="logical_replication_write_through_cache"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Logical replication write-through cache</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
SELECT * FROM aurora_stat_logical_wal_cache();
\qecho </details>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif
\endif
--------------------------------------------
----- Amazon Aurora Limitless Database -----
\if :isauroralimitless
\if :do_limitless_routers
-- +----------------------------------------------------------------------------+
-- |      - Routers_Shards_Info                       -                         |
-- +----------------------------------------------------------------------------+


\qecho <a name="Routers_Shards_Info"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Limitless Routers & Shards Info</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
\qecho <br>
\qecho <h3>Which router are you connected to ?</h3>
SELECT router_subcluster_id,
server_id as router_instance_identifier , 
CASE WHEN 'MASTER_SESSION_ID' = session_id 
THEN 'writer' ELSE 'reader' END AS instance_role ,
Availability_Zone 
FROM aurora_replica_status() rt, aurora_db_instance_identifier() di , rds_aurora.limitless_subcluster_id() router_subcluster_id , rds_aurora.limitless_instance_az() as Availability_Zone 
WHERE rt.server_id = di;
\qecho <br>
\qecho <h3>Routers endpoints:</h3>
select * from aurora_limitless_router_endpoints()  ;

\qecho <br>
\qecho <h3>Routers & Shards ID:</h3>
select * from rds_aurora.limitless_subclusters() order by 1 ;
\qecho <br>
\qecho <h3>Routers & Shards counts</h3>
select subcluster_type , count (*) from rds_aurora.limitless_subclusters()
group by  subcluster_type 
order by 2 desc ;
\qecho <br>
\qecho <h3>Routers & Shards Statistics</h3>
select * from  rds_aurora.limitless_stat_subclusters;


\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif


\if :do_limitless_params
-- +----------------------------------------------------------------------------+
-- |      - limitless_parameters                      -                         |
-- +----------------------------------------------------------------------------+


\qecho <a name="limitless_parameters"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Limitless parameters</b></font><hr align="left" width="460">
\qecho <br>

\qecho <details>
\qecho <br>
select *  from pg_settings where name like '%limitless%'  order by name;
\qecho <br>
SELECT *  FROM pg_settings where name in ('max_worker_processes','max_prepared_transactions','enable_partitionwise_aggregate','venable_partitionwise_join','default_transaction_isolation') order by category;

\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif

\if :do_limitless_databases
-- +----------------------------------------------------------------------------+
-- |      - Limitless_databases                       -                         |
-- +----------------------------------------------------------------------------+


\qecho <a name="Limitless_databases"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Limitless Databases</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
\qecho <br>
\qecho <h3>Limitless Databases:  </h3>
select * FROM rds_aurora.limitless_database order by datname , subcluster_id;

\qecho <br>
\qecho <h3>The total size for all limitless databases accross all Routers and Shards:  </h3>
-- Total_limitless_Databases_Size 
with dbs_details as (
select 
datname as database_name ,
BTRIM(SPLIT_PART(lsds::TEXT, ',', 1), '()') AS subcluster_id,
BTRIM(SPLIT_PART(lsds::TEXT, ',', 2), '()') AS subcluster_type,
BTRIM(SPLIT_PART(lsds::TEXT, ',', 3), '()') AS db_size_bytes
from (SELECT distinct datname, rds_aurora.limitless_stat_database_size(ld.datname) AS lsds FROM rds_aurora.limitless_database as ld ) dbs 
order by database_name)
select pg_size_pretty(sum(db_size_bytes::numeric)) AS Total_limitless_Databases_Size 
FROM dbs_details ;


\qecho <br>
\qecho <h3>The total size for each limitless database accross all Routers and Shards:  </h3>
-- per DB
with dbs_details as (
select 
datname as database_name ,
BTRIM(SPLIT_PART(lsds::TEXT, ',', 1), '()') AS subcluster_id,
BTRIM(SPLIT_PART(lsds::TEXT, ',', 2), '()') AS subcluster_type,
BTRIM(SPLIT_PART(lsds::TEXT, ',', 3), '()') AS db_size_bytes
from (SELECT distinct datname, rds_aurora.limitless_stat_database_size(ld.datname) AS lsds FROM rds_aurora.limitless_database as ld ) dbs 
order by database_name)
select database_name ,pg_size_pretty(sum(db_size_bytes::numeric)) AS Total_Database_Size 
FROM dbs_details 
group by database_name
order by 2 desc;

\qecho <br>
\qecho <h3>The limitless databases size in each Router and Shard:  </h3>

-- per DB per subcluster 
with dbs_details as (
select 
datname as database_name ,
BTRIM(SPLIT_PART(lsds::TEXT, ',', 1), '()') AS subcluster_id,
BTRIM(SPLIT_PART(lsds::TEXT, ',', 2), '()') AS subcluster_type,
BTRIM(SPLIT_PART(lsds::TEXT, ',', 3), '()') AS db_size_bytes
from (SELECT distinct datname, rds_aurora.limitless_stat_database_size(ld.datname) AS lsds FROM rds_aurora.limitless_database as ld ) dbs 
order by database_name)
select * ,pg_size_pretty(db_size_bytes::numeric) as db_size
FROM dbs_details 
order by database_name;


\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif




\if :do_limitless_extensions
-- +----------------------------------------------------------------------------+
-- |      - Limitless_Extensions                      -                         |
-- +----------------------------------------------------------------------------+


\qecho <a name="Limitless_Extensions"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Limitless Extensions</b></font><hr align="left" width="460">
\qecho <br>
\qecho <details>
\qecho <br>
\qecho <h3>shared_preload_libraries parameter: </h3>
show shared_preload_libraries;
\qecho <br>
\qecho <h3>Installed extension :  </h3>
SELECT e.extname AS "Extension Name", e.extversion AS "Version", n.nspname AS "Schema",pg_get_userbyid(e.extowner)  as Owner,  c.description AS "Description" , e.extrelocatable as "relocatable to another schema", e.extconfig ,e.extcondition
FROM pg_catalog.pg_extension e LEFT JOIN pg_catalog.pg_namespace n ON n.oid = e.extnamespace LEFT JOIN pg_catalog.pg_description c ON c.objoid = e.oid AND c.classoid = 'pg_catalog.pg_extension'::pg_catalog.regclass
ORDER BY 1;
\qecho <br>
\qecho <h3>limitless supported extensions :  </h3>
SHOW rds_aurora.limitless_supported_extensions;
\qecho <h3>Available extensions: </h3>
\qecho <br>
\qecho <h4> pg_available_extension_versions : </h4>
select * from pg_available_extension_versions order by name,version;
\qecho <br>
\qecho <h4> pg_available_extensions : </h4>
select * from pg_available_extensions order by installed_version;


\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif


\if :do_limitless_txid
-- +----------------------------------------------------------------------------+
-- |      - Limitless_Transaction_ID_TXID                       -               |
-- +----------------------------------------------------------------------------+


\qecho <a name="Limitless_Transaction_ID_TXID"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Limitless Transaction ID TXID (Wraparound)</b></font><hr align="left" width="460">
\qecho <br> 
\qecho <details>
\qecho <br>
\qecho <h3>Oldest xid accross all Routers and Shards:</h3>
SELECT 
max(age(datfrozenxid)) oldest_xid_age 
FROM 
rds_aurora.limitless_database ;

\qecho <br>
\qecho <h3>Oldest xid for each Router and Shard:  </h3>
SELECT 
subcluster_id ,subcluster_type, max(age(datfrozenxid)) oldest_xid_age
FROM 
rds_aurora.limitless_database
group by 1,2 
order by 3 desc;

\qecho <br>
\qecho <h3>Oldest xid for each limitless database in all Routers and Shards:</h3>
SELECT 
subcluster_id,subcluster_type,datname database_name ,age(datfrozenxid) oldest_xid_age
FROM
 rds_aurora.limitless_database order by 4 desc ;


\qecho <h3>Orphaned prepared transactions:</h3>

SELECT * from rds_aurora.limitless_stat_prepared_xacts ORDER BY age(transaction_id) DESC;


\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif

\if :do_limitless_tables
-- +----------------------------------------------------------------------------+
-- |      - Limitless_Tables                          -                         |
-- +----------------------------------------------------------------------------+


\qecho <a name="Limitless_Tables"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Limitless Tables</b></font><hr align="left" width="460">
\qecho <br> 
\qecho <details>
\qecho <br>
\qecho <h3>Tables list :  </h3>
select * from rds_aurora.limitless_tables;
\qecho <br>
\qecho <h3>Collocated sharded tables info:  </h3>
SELECT * FROM rds_aurora.limitless_table_collocations order by collocation_id;
\qecho <br>
\qecho <h3>Tables size accross all Routers and Shards:  </h3>
with lt_details as (
select 
table_name ,schema_name,
BTRIM(SPLIT_PART(lsrs::TEXT, ',', 1), '()') AS subcluster_id,
BTRIM(SPLIT_PART(lsrs::TEXT, ',', 2), '()') AS subcluster_type,
BTRIM(SPLIT_PART(lsrs::TEXT, ',', 8), '()') AS table_size_bytes,
BTRIM(SPLIT_PART(lsrs::TEXT, ',', 9), '()') AS indexes_size_bytes,
BTRIM(SPLIT_PART(lsrs::TEXT, ',', 7), '()') AS toast_size_bytes,
BTRIM(SPLIT_PART(lsrs::TEXT, ',', 10), '()') AS total_size_bytes
from (SELECT  schema_name,table_name, rds_aurora.limitless_stat_relation_sizes(lt.schema_name,lt.table_name) AS lsrs FROM rds_aurora.limitless_tables as lt) lts )
select table_name ,schema_name , pg_size_pretty(sum(table_size_bytes::numeric)) as table_size , pg_size_pretty(sum(indexes_size_bytes::numeric)) as indexes_size , pg_size_pretty(sum(toast_size_bytes::numeric)) as toast_size, pg_size_pretty(sum(total_size_bytes::numeric)) as total_size , sum(total_size_bytes::numeric) as total_size_bytes
FROM lt_details 
group by table_name,schema_name
order by total_size_bytes desc ;
\qecho <br>
\qecho <h3>Tables size in each Router and Shard:  </h3>
\qecho <br>
\qecho <h4> the size of the reference tables is consistent across all the shards in the DB shard group</h4>
with lt_details as (
select 
table_name ,schema_name,
BTRIM(SPLIT_PART(lsrs::TEXT, ',', 1), '()') AS subcluster_id,
BTRIM(SPLIT_PART(lsrs::TEXT, ',', 2), '()') AS subcluster_type,
BTRIM(SPLIT_PART(lsrs::TEXT, ',', 8), '()') AS table_size_bytes,
BTRIM(SPLIT_PART(lsrs::TEXT, ',', 9), '()') AS indexes_size_bytes,
BTRIM(SPLIT_PART(lsrs::TEXT, ',', 7), '()') AS toast_size_bytes,
BTRIM(SPLIT_PART(lsrs::TEXT, ',', 10), '()') AS total_size_bytes
from (SELECT  schema_name,table_name, rds_aurora.limitless_stat_relation_sizes(lt.schema_name,lt.table_name) AS lsrs FROM rds_aurora.limitless_tables as lt) lts )
select table_name ,schema_name, subcluster_id , subcluster_type , pg_size_pretty(table_size_bytes::numeric) as table_size , pg_size_pretty(indexes_size_bytes::numeric) as indexes_size , pg_size_pretty(toast_size_bytes::numeric) as toast_size, pg_size_pretty(total_size_bytes::numeric) as total_size
FROM lt_details order by table_name,schema_name;

\qecho <br>
\qecho <h3>Indexes:  </h3>
\qecho <br>
SELECT * FROM pg_catalog.pg_indexes WHERE tablename in (SELECT table_name from rds_aurora.limitless_tables) order by tablename ;


\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif


\if :do_limitless_stat_stmt
-- +----------------------------------------------------------------------------+
-- |      - limitless_stat_statements                 -                         |
-- +----------------------------------------------------------------------------+


\qecho <a name="limitless_stat_statements"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>limitless_stat_statements</b></font><hr align="left" width="460">
\qecho <br>
select count(*) > 0 is_pg_stat_statements_enabled FROM pg_catalog.pg_extension where extname = 'pg_stat_statements' \gset
\if :is_pg_stat_statements_enabled
\qecho <details>
\qecho <br>
\qecho <h3> pg_stat_statements installed version: </h3>
\qecho <br>
SELECT e.extname AS "Extension Name", e.extversion AS "Version", n.nspname AS "Schema",pg_get_userbyid(e.extowner)  as Owner, c.description AS "Description" , e.extrelocatable as "relocatable to another schema", e.extconfig ,e.extcondition
FROM pg_catalog.pg_extension e LEFT JOIN pg_catalog.pg_namespace n ON n.oid = e.extnamespace LEFT JOIN pg_catalog.pg_description c ON c.objoid = e.oid AND c.classoid = 'pg_catalog.pg_extension'::pg_catalog.regclass
where e.extname = 'pg_stat_statements';
\qecho <br>
\qecho <h3>pg_stat_statements parameters values: </h3>
-- pg_stat_statements extension configuration 
select name as parameter_name, setting  from pg_settings where name in ('pg_stat_statements.track','pg_stat_statements.track_utility','pg_stat_statements.save'
,'pg_stat_statements.max','shared_preload_libraries');
\qecho <br>    
\qecho <h3> limitless_stat_statements_info view: </h3>       
\qecho <h4> The statistics of the pg_stat_statements module itself are tracked and made available via a view named limitless_stat_statements_info for all Routers and Shards </h4>
\qecho <h4> dealloc column show the Total number of times pg_stat_statements entries about the least-executed statements were deallocated because more distinct statements than pg_stat_statements.max were observed </h4> 
select * from rds_aurora.limitless_stat_statements_info order by 3 desc;
\qecho <br>
\qecho <h3>Top 50 SQL order by total_time:</h3>
\qecho <br>
select subcluster_id,subcluster_type,queryid,sso_calls,trunc ((sso_calls/calls) * 100 ,2) as "sso_calls_%",distributedqueryid,substring(query,1,60) as query , calls, 
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from rds_aurora.limitless_stat_statements
order by total_time_Msec desc limit 50;
\qecho <br>
\qecho <h3> Top 50 SQL order by avg_time:</h3>
\qecho <br>
select subcluster_id,subcluster_type,queryid,sso_calls,trunc ((sso_calls/calls) * 100 ,2) as "sso_calls_%",distributedqueryid,substring(query,1,60) as query , calls,
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from rds_aurora.limitless_stat_statements 
order by avg_time_Msec desc limit 50;
\qecho <br>
\qecho <h3>Top 50 SQL order by percent of total DB time percent:</h3>
\qecho <br>
select subcluster_id,subcluster_type,queryid,sso_calls,trunc ((sso_calls/calls) * 100 ,2) as "sso_calls_%",distributedqueryid,substring(query,1,60) as query , calls, 
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from rds_aurora.limitless_stat_statements 
order by percent desc limit 50;

\qecho <br>
\qecho <h3>Top 50 SQL order by number of execution (CALLs):</h3>
\qecho <br>
select subcluster_id,subcluster_type,queryid,sso_calls,trunc ((sso_calls/calls) * 100 ,2) as "sso_calls_%",distributedqueryid,substring(query,1,60) as query , calls,
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from rds_aurora.limitless_stat_statements
order by calls desc limit 50;

\qecho <br>
\qecho <h3>Top 50 SQL order by shared blocks read (physical reads) from Aurora storage:</h3>
\qecho <br>
select subcluster_id,subcluster_type,queryid,sso_calls,trunc ((sso_calls/calls) * 100 ,2) as "sso_calls_%",distributedqueryid, substring(query,1,60) as query , calls,
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent,
shared_blks_read
storage_blks_read
from rds_aurora.limitless_stat_statements
order by storage_blks_read desc limit 50;
\qecho </details>
\else
    \if yes
        \qecho 'pg_stat_statements extension is not installed'
    \endif
\endif
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif


\if :do_limitless_msq
-- +----------------------------------------------------------------------------+
-- |      - Multi_shard_queries_(MSQ)                 -                         |
-- +----------------------------------------------------------------------------+
\qecho <br>
\qecho <a name="Multi_shard_queries_(MSQ)"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Multi shard queries (MSQ)</b></font><hr align="left" width="460">
\qecho <br>
select count(*) > 0 is_pg_stat_statements_enabled FROM pg_catalog.pg_extension where extname = 'pg_stat_statements' \gset
\if :is_pg_stat_statements_enabled
\qecho <details>
\qecho <br>
\qecho <h4>Note : This section is listing both Multi-shard query (MSQ) and Single-shard query (SSQ) that is not Single-shard optimization (SSO)</h4>
\qecho <br>
\qecho <h3>Top 50 multi shard queries (MSQ) order by total_time:</h3>
\qecho <br>
select subcluster_id,subcluster_type,queryid,sso_calls,trunc ((sso_calls/calls) * 100 ,2) as "sso_calls_%",distributedqueryid,substring(query,1,60) as query , calls, 
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from rds_aurora.limitless_stat_statements
where sso_calls = 0 
and subcluster_type ='router'
order by total_time_Msec desc limit 50;
\qecho <br>
\qecho <h3>Top 50 multi shard queries (MSQ) order by avg_time:</h3>
\qecho <br>
select subcluster_id,subcluster_type,queryid,sso_calls,trunc ((sso_calls/calls) * 100 ,2) as "sso_calls_%",distributedqueryid,substring(query,1,60) as query , calls,
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from rds_aurora.limitless_stat_statements 
where sso_calls = 0 
and subcluster_type ='router'
order by avg_time_Msec desc limit 50;

\qecho <br>
\qecho <h3>Top 50 multi shard queries (MSQ) order by percent of total DB time percent:</h3>
\qecho <br>


select subcluster_id,subcluster_type,queryid,sso_calls,trunc ((sso_calls/calls) * 100 ,2) as "sso_calls_%",distributedqueryid,substring(query,1,60) as query , calls, 
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from rds_aurora.limitless_stat_statements 
where sso_calls = 0 
and subcluster_type ='router'
order by percent desc limit 50;
\qecho <br>
\qecho <h3>Top 50 multi shard queries (MSQ) order by number of execution (CALLs):</h3>
\qecho <br>
select subcluster_id,subcluster_type,queryid,sso_calls,trunc ((sso_calls/calls) * 100 ,2) as "sso_calls_%",distributedqueryid,substring(query,1,60) as query , calls,
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from rds_aurora.limitless_stat_statements
where sso_calls = 0 
and subcluster_type ='router'
order by calls desc limit 50;
\qecho <br>
\qecho <h3>Top 50 multi shard queries (MSQ) order by shared blocks read (physical reads) from Aurora storage:</h3>
\qecho <br>
select subcluster_id,subcluster_type,queryid,sso_calls,trunc ((sso_calls/calls) * 100 ,2) as "sso_calls_%",distributedqueryid, substring(query,1,60) as query , calls,
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent,
shared_blks_read
storage_blks_read
from rds_aurora.limitless_stat_statements
where sso_calls = 0 
and subcluster_type ='router'
order by storage_blks_read desc limit 50;
\qecho </details>
\else
    \if yes
        \qecho 'pg_stat_statements extension is not installed'
    \endif
\endif

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif


\if :do_limitless_sso
-- +----------------------------------------------------------------------------+
-- |      - Single_Shard_Optimized (SSO)                -                       |
-- +----------------------------------------------------------------------------+

\qecho <br>
\qecho <a name="Single_Shard_Optimized_(SSO)"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Single Shard Optimized (SSO)</b></font><hr align="left" width="460">
\qecho <br>
select count(*) > 0 is_pg_stat_statements_enabled FROM pg_catalog.pg_extension where extname = 'pg_stat_statements' \gset
\if :is_pg_stat_statements_enabled
\qecho <details>
\qecho <br>
\qecho <h3>Single Shard Optimized (SSO) Percentage:</h3>
\qecho <br>
select sum(calls) as count_calls, sum (sso_calls) as count_sso_calls ,trunc ((sum (sso_calls) /sum(calls) ) * 100 ,2)as "sso_calls_%" from rds_aurora.limitless_stat_statements where subcluster_type ='router' ;
\qecho <br>
\qecho <h3>Top 50 Single Shard Optimized (SSO) order by total_time:</h3>
\qecho <br>
select subcluster_id,subcluster_type,queryid,sso_calls,trunc ((sso_calls/calls) * 100 ,2) as "sso_calls_%",distributedqueryid,substring(query,1,60) as query , calls, 
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from rds_aurora.limitless_stat_statements
where sso_calls > 0 
and subcluster_type ='router'
order by total_time_Msec desc limit 50;

\qecho <br>
\qecho <h3>Top 50 Single Shard Optimized (SSO) order by avg_time:</h3>
\qecho <br>
select subcluster_id,subcluster_type,queryid,sso_calls,trunc ((sso_calls/calls) * 100 ,2) as "sso_calls_%",distributedqueryid,substring(query,1,60) as query , calls,
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from rds_aurora.limitless_stat_statements 
where sso_calls > 0 
and subcluster_type ='router'
order by avg_time_Msec desc limit 50;


\qecho <br>
\qecho <h3>Top 50 Single Shard Optimized (SSO) order by percent of total DB time percent:</h3>
\qecho <br>


select subcluster_id,subcluster_type,queryid,sso_calls,trunc ((sso_calls/calls) * 100 ,2) as "sso_calls_%",distributedqueryid,substring(query,1,60) as query , calls, 
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from rds_aurora.limitless_stat_statements 
where sso_calls > 0 
and subcluster_type ='router'
order by percent desc limit 50;

\qecho <br>
\qecho <h3>Top 50 Single Shard Optimized (SSO) order by number of execution (CALLs):</h3>
\qecho <br>
select subcluster_id,subcluster_type,queryid,sso_calls,trunc ((sso_calls/calls) * 100 ,2) as "sso_calls_%",distributedqueryid,substring(query,1,60) as query , calls,
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent
from rds_aurora.limitless_stat_statements
where sso_calls > 0 
and subcluster_type ='router'
order by calls desc limit 50;

\qecho <br>
\qecho <h3> Top 50 Single Shard Optimized (SSO) order by shared blocks read (physical reads) from Aurora storage: </h3>
\qecho <br>
select subcluster_id,subcluster_type,queryid,sso_calls,trunc ((sso_calls/calls) * 100 ,2) as "sso_calls_%",distributedqueryid, substring(query,1,60) as query , calls,
round(total_exec_time::numeric, 2) as total_time_Msec, 
round((total_exec_time::numeric/1000), 2) as total_time_sec,
round(mean_exec_time::numeric,2) as avg_time_Msec,
round((mean_exec_time::numeric/1000),2) as avg_time_sec,
round(stddev_exec_time::numeric, 2) as standard_deviation_time_Msec, 
round((stddev_exec_time::numeric/1000), 2) as standard_deviation_time_sec, 
round(rows::numeric/calls,2) rows_per_exec,
round((100 * total_exec_time / sum(total_exec_time) over ())::numeric, 4) as percent,
shared_blks_read
storage_blks_read
from rds_aurora.limitless_stat_statements
where sso_calls > 0 
and subcluster_type ='router'
order by storage_blks_read desc limit 50;
\qecho </details>
\else
    \if yes
        \qecho 'pg_stat_statements extension is not installed'
    \endif
\endif


\qecho </details>
\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif
\if :do_limitless_sessions
-- +----------------------------------------------------------------------------+
-- |      - limitless_sessions_info                                           - |
-- +----------------------------------------------------------------------------+

\qecho <a name="limitless_sessions_info"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Limitless Sessions/Connections Info</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h3>Routers & Shards connections utilization:</h3>
\qecho <br>
\qecho <details>
with
settings as (SELECT setting::float AS "max_connections" FROM pg_settings WHERE name = 'max_connections'),
connections as ( select subcluster_id, subcluster_type  ,sum (numbackends)::float total_connections 
from rds_aurora.limitless_stat_database
group by 1,2 )
select subcluster_id, subcluster_type,total_connections ,settings.max_connections, ROUND((100*(connections.Total_connections/settings.max_connections))::numeric,2) as "Connections utilization %" from  settings, connections
order by 5 desc;
\qecho </details>
\qecho <br>
\qecho <h3>Reserved connections settings:</h3>
\qecho <br>
\qecho <details>
select  name as parameter_name , setting , short_desc from pg_settings WHERE name in ('superuser_reserved_connections', 'reserved_connections');
\qecho </details>
\qecho <br>
\qecho <h3>Sessions statistics:</h3>
\qecho <br>
\qecho <details>
select 
subcluster_id,subcluster_type
,trunc((sum(session_time) / (60*60*1000))::numeric,2) as session_time_hours
,trunc((sum(active_time) / (60*60*1000))::numeric,2) as session_active_time_hours
,trunc((sum(idle_in_transaction_time) / (60*60*1000))::numeric,2) as session_idle_in_transaction_time_hours
,sum(sessions) as  sessions_established_count
,sum(sessions_abandoned) as sessions_abandoned_count
,sum(sessions_fatal) as sessions_fatal_count
,sum(sessions_killed) as sessions_killed_count
from rds_aurora.limitless_stat_database 
where datname is not null 
group by subcluster_id,subcluster_type order by 2;
\qecho <br>
select 
subcluster_id,subcluster_type,datname as Database_name
,trunc((session_time / (60*60*1000))::numeric,2) as session_time_hours
,trunc((active_time / (60*60*1000))::numeric,2) as session_active_time_hours
,trunc((idle_in_transaction_time / (60*60*1000))::numeric,2) as session_idle_in_transaction_time_hours
,sessions as  sessions_established_count
,sessions_abandoned as sessions_abandoned_count
,sessions_fatal as sessions_fatal_count
,sessions_killed as sessions_killed_count
from rds_aurora.limitless_stat_database 
where datname not in ('rdsadmin','template1','rdsadmin_limitless','template0')
order by subcluster_id,subcluster_type ;
\qecho </details>
\qecho <br>
\qecho <h3> DB/Connections count :</h3>
\qecho <br>
\qecho <details>


SELECT datname as "Database_Name" ,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
group by 1
order by 2 desc ;

\qecho <br>
SELECT subcluster_id, subcluster_type ,datname as "Database_Name" ,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
and subcluster_type ='router'
group by 1,2,3
order by 4 desc ;

\qecho <br>
SELECT subcluster_id, subcluster_type ,datname as "Database_Name" ,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
and subcluster_type ='shard'
group by 1,2,3
order by 4 desc ;



\qecho </details>
\qecho <br>
\qecho <h3> DB/username/Connections count :</h3>
\qecho <br>
\qecho <details>
SELECT datname as "Database_Name",usename as "User_Name" ,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
group by 1,2
order by 3 desc ;

\qecho <br>
SELECT subcluster_id, subcluster_type ,datname as "Database_Name",usename as "User_Name" ,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
and subcluster_type ='router'
group by 1,2,3,4
order by 5 desc ;

\qecho <br>
SELECT subcluster_id, subcluster_type ,datname as "Database_Name",usename as "User_Name" ,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
and subcluster_type ='shard'
group by 1,2,3,4
order by 5 desc ;



\qecho </details>
\qecho <br>
\qecho <h3> username/Connections count :</h3>
\qecho <br>
\qecho <details>
SELECT usename as "User_Name" ,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
group by 1
order by 2 desc ;

\qecho <br>
SELECT subcluster_id, subcluster_type ,usename as "User_Name" ,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
and subcluster_type ='router'
group by 1,2,3
order by 4 desc ;

\qecho <br>
SELECT subcluster_id, subcluster_type ,usename as "User_Name" ,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
and subcluster_type ='shard'
group by 1,2,3
order by 4 desc ;



\qecho </details>
\qecho <br>
\qecho <h3> username/status/Connections count :</h3>
\qecho <br>
\qecho <details>
SELECT usename as "User_Name" ,state as status,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
group by 1,2
order by 3 desc ;

\qecho <br>
SELECT subcluster_id, subcluster_type ,usename as "User_Name" ,state as status,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
and subcluster_type ='router'
group by 1,2,3,4
order by 5 desc ;

\qecho <br>
SELECT subcluster_id, subcluster_type ,usename as "User_Name",state as status ,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
and subcluster_type ='shard'
group by 1,2,3,4
order by 5 desc ;



\qecho </details>
\qecho <br>
\qecho <h3> DB/username/status/Connections count :</h3>
\qecho <br>
\qecho <details>
SELECT datname as "Database_Name",usename as "User_Name" ,state as status,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
group by 1,2,3
order by 4 desc ;

\qecho <br>
SELECT subcluster_id, subcluster_type ,datname as "Database_Name",usename as "User_Name" ,state as status,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
and subcluster_type ='router'
group by 1,2,3,4,5
order by 6 desc ;

\qecho <br>
SELECT subcluster_id, subcluster_type ,datname as "Database_Name",usename as "User_Name",state as status ,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
and subcluster_type ='shard'
group by 1,2,3,4,5
order by 6 desc ;
\qecho </details>
\qecho <br>
\qecho <h3> status/Connections count :</h3>
\qecho <br>
\qecho <details>
SELECT state as status,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
group by 1
order by 2 desc ;

\qecho <br>
SELECT subcluster_id, subcluster_type ,state as status,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
and subcluster_type ='router'
group by 1,2,3
order by 4 desc ;

\qecho <br>
SELECT subcluster_id, subcluster_type ,state as status ,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
and subcluster_type ='shard'
group by 1,2,3
order by 4 desc ;
\qecho </details>
\qecho <br>
\qecho <h3> SQL/status/Connections count : </h3>
\qecho <br>
\qecho <details>
SELECT query,state as status,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
group by 1,2
order by 3 desc ;

\qecho <br>
SELECT subcluster_id, subcluster_type ,query,state as status,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
and subcluster_type ='router'
group by 1,2,3,4
order by 5 desc ;

\qecho <br>
SELECT subcluster_id, subcluster_type, query,state as status,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
and subcluster_type ='shard'
group by 1,2,3,4
order by 5 desc ;

\qecho </details>
\qecho <br>
\qecho <h3> query_id & distributed_query_id/status/Connections count : </h3>
\qecho <br>
\qecho <details>
SELECT query_id,state as status , count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null and query_id is not null
group by 1,2
order by 3 desc ;
\qecho <br>
SELECT  distributed_query_id,state as status , count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null and distributed_query_id is not null
group by 1,2
order by 3 desc ;
\qecho <br>
SELECT subcluster_id, subcluster_type ,query_id, state as status , count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null and  query_id is not null
and subcluster_type ='router'
group by 1,2,3,4
order by 5 desc ;
\qecho <br>
SELECT subcluster_id, subcluster_type , distributed_query_id, state as status ,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
and subcluster_type ='router' and distributed_query_id is not null
group by 1,2,3,4
order by 5 desc ;
\qecho <br>
SELECT subcluster_id, subcluster_type , query_id , state as status  ,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null and  query_id is not null
and subcluster_type ='shard'
group by 1,2,3,4
order by 5 desc ;
\qecho <br>
SELECT subcluster_id, subcluster_type  , distributed_query_id, state as status  ,count(*) as "Connections_count"
FROM rds_aurora.limitless_stat_activity 
where datname is not null 
and subcluster_type ='shard' and distributed_query_id is not null
group by 1,2,3,4
order by 5 desc ;
\qecho </details>
\qecho <br>
\qecho <h3>Active sessions:</h3>
\qecho <br>
\qecho <details>
/* active_session_monitor*/ select
subcluster_id,subcluster_type,distributed_session_id,pid ,distributed_query_id,query_id,usename,datname as DB_name, 
coalesce(wait_event,'CPU') as wait_event,state,is_sso_query,distributed_session_state, 
substr(query, 1, 50)||' ... '||right(query, 50) as query, 
now()-state_change  as state_change_duration , now()-xact_start as xact_duration 
from rds_aurora.limitless_stat_activity 
where state != 'idle' and subcluster_type='router'  and query not like '%active_session_monitor%' order by state_change_duration desc;
\qecho </details>


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif

\if :do_limitless_dist_sess
-- +----------------------------------------------------------------------------+
-- |      - Distributed_sessions_info                                         - |
-- +----------------------------------------------------------------------------+

\qecho <a name="Distributed_sessions_info"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Distributed sessions info</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h4>Distributed session is a session started on the router and executing a query on or more shard (and in some cases the other routers ) and this case the query will be called Distributed query .</h4>
\qecho <h4>Single-shard query (SSQ): a query where all of the data needed for the query is on one shard, if the entire operation can be performed on one shard, including any result set generated. the planner will send the entire SQL query to the corresponding shard and query planning is skipped on the router layer and completely pushed down to the shard for planning and execution This optimization will reduce the number of network round trips from the router to the shard, improving the performance and this case the query will be called Single Shard Optimized (SSO) .  not all single-shard queries (SSQ) are Single Shard Optimized (SSO). Please review the restrictions for SSO listed below.</h4>
\qecho <h4>Multi-shard query (MSQ) : a query is a query where the data needed for the query is on more than one shard </h4>
\qecho <h4>When a session starts on the router, the distributed session state will be null, as indicated by the distributed_session_state column in the rds_aurora.limitless_stat_activity view being NULL. </h4>
\qecho <h4>The distributed session state will be set to "coordinator" once the router session executes a query that needs to run on one or more shards or routers. The sessions that run on the other shards or routers will be called "participant" sessions.</h4>
\qecho <h4>The distributed_query_id for the participant sessions will be the same as the SQL ID of the coordinator session if the session status is active .</h4>
\qecho <br>
\qecho <h3>How many participant sessions for each Coordinator session:</h3>
\qecho <br>
\qecho <details>
with router as 
(
Select
distributed_session_id,distributed_session_state,subcluster_type
from  rds_aurora.limitless_stat_activity
 where state != 'idle' and subcluster_type ='router' and distributed_session_state ='coordinator'
)
,
shard as 
(
Select
distributed_session_id,distributed_session_state,subcluster_type, distributed_query_id  ,
count(*) as participant_count
 from  rds_aurora.limitless_stat_activity
 where state != 'idle' and distributed_session_state is not null and subcluster_type ='shard'
 group by 1,2,3,4
)
select 
router.distributed_session_id ,router.distributed_session_state ,router.subcluster_type , shard.participant_count
from router
left OUTER JOIN shard on router.distributed_session_id=shard.distributed_session_id 
order by shard.participant_count desc;
\qecho </details>

\qecho <br>
\qecho <h3>Active distributed sessions  ordered by state change duration (coordinator sessions only):</h3>
\qecho <br>
\qecho <details>
Select
distributed_session_id,distributed_session_state,subcluster_id,subcluster_type,pid,state,is_sso_query,
CONCAT_WS (':',wait_event_type,coalesce(wait_event,'CPU')) AS "wait_event" ,
query_id , distributed_query_id ,substr(query, 1, 50) query,usename,datname as DB_name, 
now()-state_change  as state_change_duration , now()-xact_start as xact_duration  
 from  rds_aurora.limitless_stat_activity
 where state != 'idle' and distributed_session_state ='coordinator' and subcluster_type='router'
order by state_change_duration desc; 
\qecho </details>

\qecho <br>
\qecho <h3>Active distributed sessions that are executing Single Shard Optimized Query (SSO) ordered by state change duration (coordinator sessions only):</h3>
\qecho <br>
\qecho <details>
Select
distributed_session_id,distributed_session_state,subcluster_id,subcluster_type,pid,state,is_sso_query,
CONCAT_WS (':',wait_event_type,coalesce(wait_event,'CPU')) AS "wait_event" ,
query_id , distributed_query_id ,substr(query, 1, 50) query, usename,datname as DB_name, 
now()-state_change  as state_change_duration , now()-xact_start as xact_duration 
 from  rds_aurora.limitless_stat_activity
 where state != 'idle' and distributed_session_state is not null  and is_sso_query is true
order by state_change_duration desc; 
\qecho </details>


\qecho <br>
\qecho <h3>Active distributed sessions that are executing Multi Shard Query (MSQ) ordered by state change duration (coordinator sessions only) :</h3>
\qecho <br>
\qecho <details>
Select
distributed_session_id,distributed_session_state,subcluster_id,subcluster_type,pid,state,is_sso_query,
CONCAT_WS (':',wait_event_type,coalesce(wait_event,'CPU')) AS "wait_event" ,
query_id , distributed_query_id ,substr(query, 1, 50) query, usename,datname as DB_name, 
now()-state_change  as state_change_duration , now()-xact_start as xact_duration 
 from  rds_aurora.limitless_stat_activity
 where state != 'idle' and distributed_session_state is not null  and is_sso_query is false
order by state_change_duration desc; 
\qecho </details>


\qecho <br>
\qecho <h3>Active distributed sessions (coordinator sessions and Their Participant Sessions on Shards/routers ):</h3>
\qecho <br>
\qecho <details>
Select
distributed_session_id,distributed_session_state,subcluster_id,subcluster_type,pid,state,is_sso_query,
CONCAT_WS (':',wait_event_type,coalesce(wait_event,'CPU')) AS "wait_event" ,
query_id , distributed_query_id ,substr(query, 1, 50) query, usename,datname as DB_name, 
now()-state_change  as state_change_duration , now()-xact_start as xact_duration 
 from  rds_aurora.limitless_stat_activity
 where state != 'idle' and distributed_session_state is not null 
order by 1,2 ;
\qecho </details>


\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif

\if :do_limitless_wait_events
-- +----------------------------------------------------------------------------+
-- |      - Limitless_Database_Load_Wait_events                               - |
-- +----------------------------------------------------------------------------+

\qecho <a name="Limitless_Database_Load_Wait_events"></a>
\qecho <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#16191f"><b>Limitless Database Load (Wait events)</b></font><hr align="left" width="460">
\qecho <br>
\qecho <h3>Wait events / Active sessions count across all routers and shards:</h3>
\qecho <br>
\qecho <details>

--- wait events / active sessions count ---
-- wait events / active sessions count across all routers and shards --

Select CONCAT_WS (':',wait_event_type,coalesce(wait_event,'CPU')) AS "wait_event", count(*)
 from  rds_aurora.limitless_stat_activity
 where state != 'idle' 
 group by 1
 order by 2 desc;
\qecho </details>
\qecho <br>

 
\qecho <h3>Wait events / Active sessions count across all routers only :</h3>
\qecho <br>
\qecho <details>
-- wait events / active sessions count across all routers only --
 Select CONCAT_WS (':',wait_event_type,coalesce(wait_event,'CPU')) AS "wait_event", count(*)
 from  rds_aurora.limitless_stat_activity
 where state != 'idle' and subcluster_type='router'
 group by 1
 order by 2 desc;
\qecho </details>
\qecho <br>
\qecho <h3>Wait events / Active sessions count across all shards only:</h3>
\qecho <br>
\qecho <details>
-- wait events / active sessions count across all shards only --
 Select CONCAT_WS (':',wait_event_type,coalesce(wait_event,'CPU')) AS "wait_event", count(*)
 from  rds_aurora.limitless_stat_activity
 where state != 'idle' and subcluster_type='shard'
 group by 1
 order by 2 desc;
\qecho </details>
\qecho <br>
\qecho <h3>Wait events / Active sessions count per router:</h3>
\qecho <br>
\qecho <details>
-- wait events / active sessions count per router --
 Select subcluster_id,subcluster_type,CONCAT_WS (':',wait_event_type,coalesce(wait_event,'CPU')) AS "wait_event", count(*)
 from  rds_aurora.limitless_stat_activity
 where state != 'idle' and subcluster_type='router'
 group by 1,2,3
 order by 4 desc;

\qecho </details>
\qecho <br>


\qecho <h3>Wait events / Active sessions count per shard:</h3>
\qecho <br>
\qecho <details>
-- wait events / active sessions count per shard --
 Select subcluster_id,subcluster_type,CONCAT_WS (':',wait_event_type,coalesce(wait_event,'CPU')) AS "wait_event", count(*)
 from  rds_aurora.limitless_stat_activity
 where state != 'idle' and subcluster_type='shard'
 group by 1,2,3
 order by 4 desc;

\qecho </details>
\qecho <br>

\qecho <h3>Wait events / Distributed query id / Active sessions count :</h3>
\qecho <br>
\qecho <details>
--- wait events / distributed_query_id / active sessions count ---
-- wait events / distributed_query_id / active sessions count across all routers and shards --
Select
CONCAT_WS (':',wait_event_type,coalesce(wait_event,'CPU')) AS "wait_event",
distributed_query_id ,
count(*)
 from  rds_aurora.limitless_stat_activity
 where state != 'idle' and distributed_query_id is not null
 group by 1,2
 order by 3 desc;
\qecho </details>
\qecho <br>
\qecho <h3>Wait events / Distributed query id / Active sessions count per router and shard:</h3>
\qecho <br>
\qecho <details>
-- wait events / distributed_query_id / active sessions count per router and shard --
Select
subcluster_id,
subcluster_type,CONCAT_WS (':',wait_event_type,coalesce(wait_event,'CPU')) AS "wait_event",
distributed_query_id ,
count(*)
 from  rds_aurora.limitless_stat_activity
 where state != 'idle' and distributed_query_id is not null
 group by 1,2,3,4
 order by 1,5 desc;
\qecho </details>
\qecho <br>

\qecho <center>[<a class="noLink" href="#top">Top</a>]</center><p>
\endif
\endif
--------------------------------------------
\pset format aligned
\r
\o
\echo Report Generated Successfully
\echo Report name and location: :outdir/pg_collector_:filename.html
\q
