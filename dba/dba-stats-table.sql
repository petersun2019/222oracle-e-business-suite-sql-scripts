/*
File Name:		dba-stats-table.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

dba_optstat_operations contains a history of statistics operations performed at the schema and database level using the dbms_stats package.
*/

-- ##################################################################
-- DBA_OPTSTAT_OPERATIONS
-- ##################################################################

select * from dba_optstat_operations order by start_time desc;
