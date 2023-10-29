/*
File Name: dba-sql-bind-capture.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- SQL TO GET BIND VALUE FROM SQL_ID
-- ##################################################################

select * from v$sql_bind_capture;
select * from v$sql_bind_capture where sql_id = 'bqq0nzcuz6wfy'; -- check value_string to get bind variable value
select * from v$sql_bind_capture where last_captured > '22-JUL-2019' and value_string = '3398';
select * from dba_hist_sqltext;
