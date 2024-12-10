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
