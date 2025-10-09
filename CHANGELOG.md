# Changelog

All notable changes to pg collector will be documented in this file.


#  V1

```
1- V1 version Created from pg-collector-for-postgresQL-15 branch. 
2- Change the supported postgresql version from 15 to 16.
3- Add reserved_connections parameter to Reserved connections settings.
```

#  V1.1

```
1- The script should display the message "Report Generated Successfully" upon successful completion and relocate the report file name and location information to the end of the script..
2- Add a new section for Amazon Aurora PostgreSQL.
3- Add a new section for Invalid databases.
4- Implement a check for the pg_stat_statements extension. If the extension is not installed, the script should print the message "pg_stat_statements extension is not installed" in the report, instead of displaying the errors "ERROR: relation "pg_stat_statements_info" does not exist" or "ERROR: relation "pg_stat_statements" does not exist".
5- Add a new section "List of role grants" under "Users & Roles Info".
```


#  V1.2

```
1- Add a new section for Amazon Aurora Limitless Database.
2- Starting from this version, the pg collector will not include Amazon Aurora PostgreSQL or Amazon Aurora Limitless Database sections automatically in the pg collector report if the instance is not an Amazon Aurora.

```

#  V1.3

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
