# Changelog

All notable changes to pg collector will be documented in this file.


#  V1

```
1- V1 version created from pg-collector-for-postgresQL-17 branch.
2- Replace all psql backslash commands, such as \l+, with their corresponding SQL statements. This will enable users to run the pg collector from any psql version, even if it is older than the server version, without encountering any issues.
3- Add the tablespace size.
4- Add the schema size. 
``` 

#  V1.1

```
1- Enhanced Query Plan Management (QPM) section with additional diagnostic queries:
   - Added apg_plan_mgmt.plans table size monitoring (total size and table-only size)
   - Added query to identify SQLs with multiple execution plans
   - Added analysis of SQLs where Unapproved plans have lower cost than other plans
   - Added plan summary by status and enabled flag
   - Improved section formatting with better HTML structure and headers
   - Added "All Query Plans" section with 5 MB size limit to prevent large reports

2- Added new "Index Creation Progress" section:
   - Comprehensive monitoring for CREATE INDEX and REINDEX operations
   - Real-time visibility into all 12 phases of index creation
   - Progress tracking for block scanning, tuple loading, lockers, and partitions
   - Parallel worker monitoring with PIDs, wait events, and states
   - Blocker detection and wait event analysis
   - Support for partitioned tables with accurate size calculations

3- Fixed division by zero error in "Functions statistics" section:
   - Added NULLIF to handle functions with zero calls
   - Prevents script failure when calculating mean_time for uncalled functions

4- Added new "Materialized Views" section:
   - Count of materialized views
   - Summary with owner, tablespace, indexes status, populated status, and sizes
   - Definitions showing the SQL that defines each materialized view
   - List of unpopulated views that need to be refreshed

5- Added database count at the top of DB info section:
   - Shows count of regular databases
   - Shows count of template databases

6- Enhanced "Partition tables" section with size information:
   - Added partition tables summary with total sizes (total, table, indexes)
   - Added individual partition sizes with details including toast size
   - Added percentage breakdown showing each partition's size relative to parent table

7- Enhanced "Database size" section:
   - Added total size across all databases query showing aggregate size in bytes and human-readable format

8- Enhanced "Invalid indexes" section:
   - Added index size information (bytes and human-readable format)
   - Added index definition showing the CREATE INDEX statement
   - Results now ordered by index size descending to prioritize larger invalid indexes

9- Enhanced "Duplicate indexes" section:
   - Shows individual rows for each duplicate index instead of aggregated groups
   - Added table name and individual index size for each duplicate
   - Added is_valid status to identify invalid duplicates
   - Added duplicate_count showing how many duplicates exist in each group
   - Added total_group_size showing total size of all duplicates in the group
   - Added index_type classification (PRIMARY KEY, UNIQUE, or NOT PK OR UNIQUE)
   - Added full index definition for each duplicate
   - Results ordered by total group size, table name, validity status, and individual size

10- Added new "Parameters Access Control List (ACL)" subsection under "DB parameters":
   - Shows parameter-level permissions granted to database users
   - Displays parameter name, current value, context, role name, SET permission, ALTER SYSTEM permission, and grantor
   - Tracks permissions via pg_parameter_acl catalog

11- Enhanced "Temp Tables & Files" section:
   - Added work_mem parameter to the parameters list
   - Enhanced temp files statistics with four new detailed queries:
     * Grand Total - Overall statistics across all tablespaces
     * Per Tablespace - Statistics grouped by tablespace
     * By Process ID with Active Query Details - Shows which PIDs are using temp files with query information
     * Detailed List - All temporary files with full details
   - Enhanced temp tables statistics with three new comprehensive queries:
     * Database-Wide Summary - Grand total of all temp table usage
     * Session-Level Summary - Aggregated view per session
     * Individual Table Details - Granular view of each temp table

12- Enhanced "pg_stat_statements extension" section:
   - Added "Top SQL order by Temporary Table Activity (local_blks)" query
     * Monitors queries creating temporary tables and using local buffers
     * Includes per-call statistics and total sizes
   - Added "Top SQL order by Temporary File Activity (temp_blks)" query
     * Monitors queries that spill to disk temp files (exceeding work_mem)
     * Helps identify queries needing work_mem tuning

13- Enhanced "Schema Size" query under "Schema Info" section:
   - Changed from LEFT JOIN to INNER JOIN for accurate results
   - Added pg_toast% exclusion filter to avoid double-counting internal TOAST schemas
   - Added descriptive comments explaining pg_total_relation_size behavior
   - Results now ordered by actual size descending instead of text-based ordering

14- Added "TOAST Size per Schema" subsection under "Toast Tables Mapping" section:
   - Added Total TOAST Size query showing aggregate TOAST footprint across the database
   - Added per-schema TOAST size breakdown showing which schemas consume the most TOAST storage
   - Uses pg_total_relation_size for true footprint (includes TOAST data + TOAST indexes)

15- Added default statement_timeout of 5 minutes:
   - Prevents individual queries from hanging indefinitely on databases with tens of thousands of tables
   - Per-statement timeout: if one query is cancelled, the script continues with the next section
   - Prints timeout value to terminal at script start for user awareness

16- Added new "Foreign Servers" section:
   - Server Connection Details: Lists each foreign server with host, port, dbname in a single row
   - Usage Summary: Count of foreign tables per server
   - Foreign Tables Inventory: Maps local foreign tables to their remote schema/table
   - Security Audit: Shows user mappings with passwords masked for security

17- Enhanced "pg_stat_all_tables order by autovacuum_count" and "autoanalyze_count" queries:
   - Removed pg_catalog and pg_toast schema filter to include all tables
   - Added hours_since_last_vacuum and days_since_last_vacuum columns for quick identification of stale tables

18- Added "Parameters pending restart" observation check and subsection under "DB parameters":
   - New observation check flags when parameters have been changed but require a restart
   - New subsection lists parameter name, current value, boot value, pending value, pending_restart status, source, and source file

19- Added generic pg_stat_statements outdated check:
   - Detects when pg_stat_statements extension has a newer version available
   - Warns user in terminal and HTML report to run ALTER EXTENSION pg_stat_statements UPDATE

20- Enhanced "pg_stat_statements extension" section with parallel worker monitoring 
   - Added parallel_workers_to_launch and parallel_workers_launched columns to all 7 existing Top SQL queries
   - Added 3 new subsection queries:
     * Top SQL order by Parallel Workers Launched - heaviest parallel queries
     * Top SQL order by Parallel Workers Planned - most intended parallelism
     * Top SQL order by Parallel Workers Not Launched (Bottleneck) - identifies max_parallel_workers limits being hit

21- Added "Top SQL order by WAL Generation" subsection in pg_stat_statements:
   - Shows queries generating the most WAL (wal_records, wal_fpi, wal_bytes, wal_buffers_full)
   - Includes human-readable WAL size and WAL bytes per call
   - wal_buffers_full column available in PG 18+ (pg_stat_statements 1.12+)
   - Helps identify queries impacting replication lag, WAL archiving, and checkpoint frequency

22- Added stats_since and minmax_stats_since columns to all Top SQL queries in pg_stat_statements:
   - Shows when statistics were last reset for each statement (pg_stat_statements 1.11+, PG 17+)

23- Fixed bug in obsrv_less_remaining_sequences health check:
   - Changed count(1) to count(1) > 0 to always return a boolean
   - Previously would cause psql error when 2 or more sequences had less than 10% remaining values

24- Added configurable report output directory:
   - Default output location remains /tmp (backward compatible)
   - Users can override with -v outdir=/path/to/dir to save the report anywhere
   - Example: psql -v outdir=/home/user/reports -f pg_collector.sql

25- Added Selective Section Execution feature:
   - Run specific sections instead of the full report using -v fullmod=f -v <section>=t
   - Help mode with -v help=t lists all available section variables with descriptions
   - Terminal output lists included sections when running in selective mode
   - HTML report shows a "Partial Report" banner with clickable links to included sections
   - DB INFO header always runs regardless of mode
   - All Aurora and Limitless sub-sections individually selectable
   - Sequences and DB parameters sections are self-contained (include their own detection queries)
``` 
