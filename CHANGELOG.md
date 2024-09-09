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