# Changelog

All notable changes to pg collector will be documented in this file.

#  V1

```
1- V1 version Created from mian branch
2- fix for https://github.com/awslabs/pg-collector/issues/2 and https://github.com/awslabs/pg-collector/issues/4 

following pg_stat_statements columns renamed:
   total_time → total_exec_time
   min_time → min_exec_time
   max_time → max_exec_time
   mean_time → mean_exec_time
   stddev_time →s tddev_exec_time
```

#  V1.1 

```
1- Add logical_decoding_work_mem parameter to Replication Parameters
2- Add Replication Slot wal status to Replication section    
```
#  V1.2 
```
1- Enhance the where condition in the following sections “current running vacuum process“and ”current running autovacuum process“.
2- Fix typos, Thanks to Vikas Gupta for highlighting them .
3- Upade percent_towards_wraparound's query with 2^31-1000000 .
4- Add reserved connections parameters info to the Connections Info section .
5- Add DB/username/status/Connections count to the Connections Info section .
6- Add objects list and count in each schema to the schema info section .
7- Update the Toast Tables Mapping's sql to order the toast by the size and add note about toast OID wraparound
```

#  V1.3

```
1- The script should display the message "Report Generated Successfully" upon successful completion and relocate the report file name and location information to the end of the script..
2- Add a new section for Amazon Aurora PostgreSQL.
3- Add a new section for Invalid databases.
4- Implement a check for the pg_stat_statements extension. If the extension is not installed, the script should print the message "pg_stat_statements extension is not installed" in the report, instead of displaying the errors "ERROR: relation "pg_stat_statements_info" does not exist" or "ERROR: relation "pg_stat_statements" does not exist".
```

#  V1.4
```
1- Implement PG Collector's Automated Database Health check (Observations section)
    Database Health check list :
      1- Duplicate indexes
      2- Invalid indexes
      3- Unused Indexes
      4- Autovacuum parameter
      5- Sequences with less than 10% of the remain values
      6- Orphaned prepared transactions
      7- Connections without SSL
      8- Enable_indexonlyscan parameter
      9- Excessive logging parameters
      10- Track_counts parameter
      11- Enable_indexscan parameter
      12- Synchronous_commit parameter
      13- Invalid databases
      14- Tables with more than 20% dead rows
      15- Transaction ID TXID (Wraparound)
      16- Tables that have autovacuum_enabled=off on table level
      17- Inactive replication slots
      18- Logical replication spill files
      19- Outdated Extensions

2- Fix a bug that allow the report output not be html 
3- Fix the toast oid wraparound SQL and use 2^32 instead of 2^31
```

Note: Thanks to Baji Shaik and Krishna Sarabu for their contributions to the development of the Database Health check feature and the Health checks.

#  V1.5

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

10- Added "Schema Size" subsection under "Schema Info" section:
   - Shows total on-disk size per schema using pg_total_relation_size (includes table data, indexes, TOAST tables, and TOAST indexes)
   - Excludes pg_toast% internal schemas to avoid double-counting (already included in parent table sizes)
   - Results ordered by size descending for quick identification of largest schemas

11- Added "TOAST Size per Schema" subsection under "Toast Tables Mapping" section:
   - Added Total TOAST Size query showing aggregate TOAST footprint across the database
   - Added per-schema TOAST size breakdown showing which schemas consume the most TOAST storage
   - Uses pg_total_relation_size for true footprint (includes TOAST data + TOAST indexes)

12- Added default statement_timeout of 5 minutes:
   - Prevents individual queries from hanging indefinitely on databases with tens of thousands of tables
   - Per-statement timeout: if one query is cancelled, the script continues with the next section
   - Prints timeout value to terminal at script start for user awareness

13- Added new "Foreign Servers" section:
   - Server Connection Details: Lists each foreign server with host, port, dbname in a single row
   - Usage Summary: Count of foreign tables per server
   - Foreign Tables Inventory: Maps local foreign tables to their remote schema/table
   - Security Audit: Shows user mappings with passwords masked for security

14- Enhanced "pg_stat_all_tables order by autovacuum_count" and "autoanalyze_count" queries:
   - Removed pg_catalog and pg_toast schema filter to include all tables
   - Added hours_since_last_vacuum and days_since_last_vacuum columns for quick identification of stale tables

15- Added "Parameters pending restart" observation check and subsection under "DB parameters":
   - New observation check flags when parameters have been changed but require a restart
   - New subsection lists parameter name, current value, boot value, pending value, pending_restart status, source, and source file

16- Added generic pg_stat_statements outdated check:
   - Detects when pg_stat_statements extension has a newer version available
   - Warns user in terminal and HTML report to run ALTER EXTENSION pg_stat_statements UPDATE

17- Added "Top SQL order by WAL Generation" subsection in pg_stat_statements:
   - Shows queries generating the most WAL (wal_records, wal_fpi, wal_bytes)
   - Includes human-readable WAL size and WAL bytes per call
   - Helps identify queries impacting replication lag, WAL archiving, and checkpoint frequency

18- Fixed bug in obsrv_less_remaining_sequences health check:
   - Changed count(1) to count(1) > 0 to always return a boolean
   - Previously would cause psql error when 2 or more sequences had less than 10% remaining values

19- Added configurable report output directory:
   - Default output location remains /tmp (backward compatible)
   - Users can override with -v outdir=/path/to/dir to save the report anywhere
   - Example: psql -v outdir=/home/user/reports -f pg_collector.sql

20- Added Selective Section Execution feature:
   - Run specific sections instead of the full report using -v fullmod=f -v <section>=t
   - Help mode with -v help=t lists all available section variables with descriptions
   - Terminal output lists included sections when running in selective mode
   - HTML report shows a "Partial Report" banner with clickable links to included sections
   - DB INFO header always runs regardless of mode
   - All Aurora sub-sections individually selectable (except aurora_stat_stmt and aurora_stat_plans not available in PG 13)
   - Sequences and DB parameters sections are self-contained (include their own detection queries)
```
