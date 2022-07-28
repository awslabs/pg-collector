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