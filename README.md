# PG COLLECTOR

## Overview

PG COLLECTOR Tool/Script for [Postgresql](https://www.postgresql.org/) database, it gathers the important database and object information and presents it in a consolidated HTML file which provides a convenient way to view and navigate between different sections of the report, PG Collector will not create any objects in the Database.

## PG COLLECTOR report header 
<img src="img/pg_collector_header_V2.6.png" alt="">

## Example of PG COLLECTOR report 
[pg_collector v2.6](https://github.com/awslabs/pg-collector/blob/main/ample_reports/pg_collector_testdb-2020-10-16_021546.html )

## PG COLLECTOR report Name 
PG COLLECTOR script will generate HTML file using the following naming convention pg_colletcor_[DB Name]-[timestamp].html.

[DB Name] : is the database name that you are connected to.

```
example : pg_collector_testdb-2020-10-10_030920.html
```
## PG COLLECTOR report location 
PG COLLECTOR script will generate HTML file  under [/tmp](https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/tmp.html) directory. 

## How to run PG COLLECTOR  script ( pg_collector.sql )

1- you need [psql](https://www.postgresql.org/docs/10/app-psql.html) to be able to connect to the postgresql DB and run the pg_collector.sql script 

2- Download pg_collector.sql in your labtop or the host that want to access the database from 

3- login to the database using psql 
```
psql -h [hostname/RDS endpoint] -p [Port] -d [Database name ] -U [user name] 
```
4- run the pg_collector.sql script 

```
\i pg_collector.sql 
```

Example :

```
mohamed@mydevhost ~ % psql -h testdb-instance-1.cimdlffuw.us-west-2.rds.amazonaws.com -p 5432 -d testdb -U mohamed
psql (9.4.8, server 10.6)
WARNING: psql major version 9.4, server major version 10.6.
         Some psql features might not work.
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
Type "help" for help.

testdb=> \i pg_collector.sql
Output format is html.
Default footer is off.
testdb=> \q
mohamed@mydevhost ~ %ls -lhrt /tmp/pg_colletcor_*
-rw-r--r-- 1 mohamed mohamed 569K Oct  7 21:51 /tmp/pg_colletcor_testdb-2019-10-07_215146.html

```
5-  open the report using any internet browser

## Notes:
1- it is ok to see below errors while executing the pg_colletcor.sql script if you did not install pg_stat_statements extension

```
psql:pg_collector.sql:435: ERROR:  relation "pg_stat_statements" does not exist
LINE 10: from pg_stat_statements
              ^
psql:pg_collector.sql:449: ERROR:  relation "pg_stat_statements" does not exist
LINE 10: from pg_stat_statements
              ^
psql:pg_collector.sql:463: ERROR:  relation "pg_stat_statements" does not exist
LINE 10: from pg_stat_statements
              ^
psql:pg_collector.sql:477: ERROR:  relation "pg_stat_statements" does not exist
LINE 10: from pg_stat_statements
```

# License

This library is licensed under the MIT-0 License. See the LICENSE file.