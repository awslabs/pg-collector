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
