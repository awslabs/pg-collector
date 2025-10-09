# Changelog

All notable changes to pg collector will be documented in this file.


#  V1

```
1- V1 version created from pg-collector-for-postgresQL-16 branch. 
2- Change the supported postgresql version from 16 to 17
3- Fix "ERROR:  column p.max_dead_tuples does not exist" and "ERROR:  column p.num_dead_tuples does not exist" by changing the columns "max_dead_tuples" and "num_dead_tuples" to the newly introduced columns  "max_dead_tuple_bytes" and "dead_tuple_bytes" : https://git.postgresql.org/gitweb/?p=postgresql.git;a=commit;h=667e65aac354975c6f8090c6146fceb8d7b762d6
4- Added new columns "total_indexes_to_vacuum" and "total_indexes_processed" to "vacuum progress process" table.
5- Added new columns  to "Top SQL order by shared blocks read (physical reads)" table 
	"shared_blocks_hits"
	"shared_blocks_read_time_sec"
```

#  V1.1 

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
