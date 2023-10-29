/*
File Name: dba-sqlarea.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- TABLE DUMPS
-- SQLAREA DETAILS

*/

-- ##################################################################
-- TABLE DUMPS
-- ##################################################################

/*
V$SQLAREA lists statistics on shared SQL area and contains one row per SQL string.
It provides statistics on SQL statements that are in memory, parsed, and ready for execution.
*/

select * from v$sqlarea where module = 'e:CE:frm:CEXCABMR' and last_active_time > to_date('24-MAY-2016 11:00:50', 'DD-MON-YYYY HH24:MI:SS') and action = 'CE/AR_DIRECT_CREDIT_CASHIER.';
select * from v$sqlarea where last_active_time > to_date('26-MAY-2016 14:01:50', 'DD-MON-YYYY HH24:MI:SS') and sql_text like '%xx_ar_trx_interface%' and sql_text not like '%sqlarea%';
select * from v$sqlarea where last_active_time > to_date('2020-07-01 14:00:00', 'yyyy-mm-dd hh24:mi:ss');
select * from v$sqlarea where last_active_time > to_date('2021-08-13 13:00:00', 'yyyy-mm-dd hh24:mi:ss') and module like 'e:SYSADMIN%';
select * from v$sqlarea where last_active_time > to_date('2021-01-19 14:00:00', 'yyyy-mm-dd hh24:mi:ss') and lower(sql_text) like 'select%document_id%' and sql_text not like '%sqlarea%';
select * from v$sqlarea where last_active_time > to_date('2021-06-11 17:00:00', 'yyyy-mm-dd hh24:mi:ss') and module like 'e:PA%';
select sysdate from dual;

-- ##################################################################
-- SQLAREA DETAILS
-- ##################################################################

		select sql_id
			 , first_load_time
			 , last_load_time
			 , last_active_time
			 , module
			 , action
			 , sql_text
			 , sql_fulltext 
		  from v$sqlarea
		 where 1 = 1
		   and last_active_time > to_date('2022-04-13 09:30:00', 'YYYY-MM-DD HH24:MI:SS')
		   and module is not null
		   -- and module not in ('MMON_SLAVE','Disco10','SQL*Plus','SQL Developer')
		   -- and module not like '%SYSADMIN%'
		   -- and module like 'e:PA%'
		   and action = 'AR/GHC_AR_SUPERUSER'
		   and lower(module) like 'e:ar%'
		   -- and lower(sql_fulltext) like '%wf%'
		   -- and sql_id = '8n16955kuxyu9'
		   and 1 = 1
	  order by last_active_time desc;
