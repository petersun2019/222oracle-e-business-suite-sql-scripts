/*
File Name:		dba-performance-checking.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- FINDS THE TOP SQL STATEMENTS THAT ARE CURRENTLY STORED IN THE SQL CACHE ORDERED BY ELAPSED TIME
-- FIND DISK INTENSIVE FULL TABLE SCANS
-- TAKE THE AVERAGE BUFFER GETS PER EXECUTION DURING A PERIOD OF ACTIVITY OF THE INSTANCE
-- RETURNS SQL STATEMENTS THAT PERFORM LARGE NUMBERS OF DISK READS

*/

-- ##################################################################
-- FINDS THE TOP SQL STATEMENTS THAT ARE CURRENTLY STORED IN THE SQL CACHE ORDERED BY ELAPSED TIME (HTTP://STACKOVERFLOW.COM/QUESTIONS/316812/TOP-5-TIME-CONSUMING-SQL-QUERIES-IN-ORACLE)
-- ##################################################################

		select *
		  from (select sql_fulltext
					 , sql_id
					 , elapsed_time
					 , child_number
					 , disk_reads
					 , executions
					 , first_load_time
					 , last_load_time
					 , sql_text
				  from v$sql
			  order by elapsed_time desc)
		 where rownum < 10;

-- ##################################################################
-- FIND DISK INTENSIVE FULL TABLE SCANS
-- ##################################################################*/

		select disk_reads diskreads
			 , executions
			 , sql_id
			 , sql_text sqltext
			 , sql_fulltext sqlfulltext 
		  from (select disk_reads
					 , executions
					 , sql_id
					 , ltrim(sql_text) sql_text
					 , sql_fulltext
					 , operation
					 , options
					 , row_number() over (partition by sql_text order by disk_reads * executions desc) keephighsql
				from (select avg(disk_reads) over (partition by sql_text) disk_reads
						   , max(executions) over (partition by sql_text) executions
						   , t.sql_id
						   , sql_text
						   , sql_fulltext
						   , p.operation,p.options
						from v$sql t
						join v$sql_plan p on t.hash_value = p.hash_value
					   where 1 = 1
					     and p.operation = 'TABLE ACCESS'
						 and p.options = 'FULL'
						 and p.object_owner not in ('SYS','SYSTEM')
						 and t.executions > 1) 
					order by disk_reads * executions desc)
		 where keephighsql = 1
		   and rownum < = 5;

-- ##################################################################
-- TAKE THE AVERAGE BUFFER GETS PER EXECUTION DURING A PERIOD OF ACTIVITY OF THE INSTANCE
-- ##################################################################*/

		select username
			 , buffer_gets
			 , disk_reads
			 , sql_id
			 , executions
			 -- , buffer_get_per_exec
			 , parse_calls
			 , sorts
			 , rows_processed
			 , hit_ratio
			 , module
			 , sql_text,
			 -- , elapsed_time
			 -- , cpu_time
			 -- , user_io_wait_time
		  from (select sql_text
					 , b.username
					 , a.disk_reads
					 , a.sql_id
					 , a.buffer_gets
					 -- , trunc(a.buffer_gets / a.executions) buffer_get_per_exec
					 , a.parse_calls
					 , a.sorts
					 , a.executions
					 , a.rows_processed
					 , 100 - round (100 * a.disk_reads / a.buffer_gets, 2) hit_ratio
					 , module
					 -- , cpu_time
					 -- , elapsed_time
					 -- , user_io_wait_time
				  from v$sqlarea a
				  join dba_users b on a.parsing_user_id = b.user_id
				 where 1 = 1
				   and b.username not in ('SYS', 'SYSTEM', 'RMAN','SYSMAN')
				   and a.buffer_gets > 10000
			  order by buffer_gets desc)
		 where rownum <= 20;

-- ##################################################################
-- RETURNS SQL STATEMENTS THAT PERFORM LARGE NUMBERS OF DISK READS
-- ##################################################################*/

		select t2.username
			 , t1.disk_reads
			 , t1.executions
			 , t1.sql_id
			 , t1.disk_reads / decode(t1.executions, 0, 1, t1.executions) as exec_ratio
			 , t1.command_type
			 , t1.sql_text
		  from v$sqlarea t1
		  join dba_users t2 on t1.parsing_user_id = t2.user_id
		 where 1 = 1
		   and t1.disk_reads > 100000
	  order by t1.disk_reads desc;
