# Changelog

All notable changes to pg collector will be documented in this file.


#  V1

```
1- V1 version Created from pg-collector-for-postgresQL-13 branch 
2- Change the supported postgresql version from 13 to 14
```

#  V1.1

```
1- Add new section for COPY command progress
2- Add pg_stat_statements_info View to  pg_stat_statements_extension section
3- Add vacuum_failsafe_age and vacuum_multixact_failsafe_age parameters to vacuum and Statistics section
4- Add pg_stat_wal veiw to DB load section inder pg_stat_* views
5- Add pg_stat_replication_slots View to Replication section 
6- Add logical_decoding_work_mem parameter to Replication Parameters 
7- Add n_ins_since_vacuum  and n_tup_ins columns to pg_stat_all_tables's queries in vacuum and Statistics section 
8- Add Sessions statistics ( session_time,active_time,idle_in_transaction_time,sessions,sessions_abandoned,sessions_fatal,sessions_killed ) to Sessions/Connections Info section 
9- Add Replication Slot wal status to Replication section
```

#  V1.2

```
1- Enhance the where condition in the following sections “current running vacuum process“and ”current running autovacuum process“.
2- Fix typos, Thanks to Vikas Gupta for highlighting them .
3- Upade percent_towards_wraparound's query with 2^31-3000000 as in 14 the wraparound safety margin increased from 1 million to 3 million.
4- Add reserved connections parameters info to the Connections Info section .
5- Add DB/username/status/Connections count to the Connections Info section .
6- Add objects list and count in each schema to the schema info section .
7- Update the Toast Tables Mapping's sql to order the toast by the size and add note about toast OID wraparound
```