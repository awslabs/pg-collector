# Changelog

All notable changes to pg collector will be documented in this file.


#  V1

```
1- V1 version Created from pg-collector-for-postgresQL-14 branch 
2- Change the supported postgresql version from 14 to 15
3- Fix "104: ERROR: column "datlastsysoid" does not exist " by doing "select * from pg_database;" to show all columns in pg_database view without showing specific columns
```

