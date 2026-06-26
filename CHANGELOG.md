# Changelog

All notable changes to pg collector will be documented in this file.


#  V1

```
1- V1 version created from pg-collector-for-postgresQL-18 branch.

2- Add generic_plan_calls and custom_plan_calls columns to all Top SQL queries in pg_stat_statements.

3- Added Selective Section Execution feature:
   - Run specific sections instead of the full report using -v fullmod=f -v <section>=t
   - Help mode with -v help=t lists all available section variables with descriptions
   - Terminal output lists included sections when running in selective mode
   - HTML report shows a "Partial Report" banner with clickable links to included sections
   - DB INFO header always runs regardless of mode
   - All Aurora and Limitless sub-sections individually selectable

4- Added configurable report output directory:
   - Default output location remains /tmp (backward compatible)
   - Users can override with -v outdir=/path/to/dir to save the report anywhere
   - Example: psql -v outdir=/home/user/reports -f pg_collector.sql

5- Fixed bug in obsrv_less_remaining_sequences health check:
   - Changed count(1) to count(1) > 0 to always return a boolean
   - Previously would cause psql error when 2 or more sequences had less than 10% remaining values

```

