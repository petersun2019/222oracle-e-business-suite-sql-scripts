/*
File Name: dba-tablespace.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- TABLESPACE - VERSION 1
-- TABLESPACE - VERSION 2
-- TABLESPACE - VERSION 3
-- TABLESPACE - VERSION 4
-- TABLESPACE - VERSION 4
-- DBA_FREE_SPACE
-- DBA_DATA_FILES
-- DBA_SEGMENTS 1
-- DBA_SEGMENTS 2

*/

-- ##################################################################
-- TABLESPACE - VERSION 1
-- ##################################################################

select tablespace_name from dba_tables where table_name = 'FND_LOG_MESSAGES';

-- ##################################################################
-- TABLESPACE - VERSION 2
-- ##################################################################

/*
https://gist.github.com/rakeshsingh/6e6b05c8c7672e6a294f
*/

		select /* + rule */
			   df.tablespace_name as "tablespace"
			 , df.bytes / (1024 * 1024 * 1024) as "size (gb)"
			 , trunc(fs.bytes / (1024 * 1024 * 1024)) as "free (gb)"
		  from (select tablespace_name
					 , sum(bytes) as bytes
				  from dba_free_space
			  group by tablespace_name) fs
			 , (select tablespace_name
					 , sum(bytes) as bytes
				  from dba_data_files
			  group by tablespace_name) df
		 where 1 = 1
		   and fs.tablespace_name = df.tablespace_name
		   and df.tablespace_name = 'TEMP1'
	  order by 3 desc;

-- ##################################################################
-- TABLESPACE - VERSION 3
-- ##################################################################

		select df.tablespace_name "tablespace"
			 , totalusedspace "used mb"
			 , (df.totalspace - tu.totalusedspace) "free mb"
			 , df.totalspace "total mb"
			 , round(100 * ( (df.totalspace - tu.totalusedspace)/ df.totalspace)) "pct. free"
		  from (select tablespace_name
					 , round(sum(bytes) / 1048576) totalspace
				  from dba_data_files
			  group by tablespace_name) df
			 , (select round(sum(bytes)/(1024*1024)) totalusedspace
					 , tablespace_name
				  from dba_segments
			  group by tablespace_name) tu
		 where df.tablespace_name = tu.tablespace_name; 

-- ##################################################################
-- TABLESPACE - VERSION 4
-- ##################################################################

		select tablespace_name
			 , to_char ((sum(bytes ) / 1024 / 1024), '999,999,999.99' ) as size_in_megs
			 , count(*) number_of_files
		  from dba_data_files
		 where tablespace_name = 'APPS_TS_TX_DATA'
	  group by tablespace_name
	  order by 3
			 , sum (bytes )
			 , 1;

-- ##################################################################
-- TABLESPACE - VERSION 4
-- ##################################################################

		select ts.tablespace_name
			 , to_char ((nvl( ts.total_bytes , 0) - nvl(used_bytes, 0) ) / 1024 / 1024 , '999,999' ) as free_megs
			 , to_char (nvl(used_bytes , 0) / 1024 / 1024, '999,999') as used_megs
			 , to_char (nvl(ts.total_bytes, 0) / 1024 / 1024, '999,999' ) as total_megs
			 , to_char (((nvl(used_bytes, 0) / (nvl(ts.total_bytes,0) )) * 100), '999.99') as percent_full
		  from (select tablespace_name
					 , sum(nvl(bytes,0)) as total_bytes
				  from dba_data_files
			  group by tablespace_name) ts
			 , (select tablespace_name
					 , nvl(sum(bytes), 0) used_bytes
				  from dba_extents
			  group by tablespace_name) used_space
		 where ts.tablespace_name = used_space.tablespace_name (+)
		   and ts.tablespace_name = 'APPS_TS_TX_DATA'
	  order by 5;

-- ##################################################################
-- DBA_FREE_SPACE
-- ##################################################################

		select tablespace_name
			 , count(*)
		  from dba_free_space
	  group by tablespace_name;

-- ##################################################################
-- DBA_DATA_FILES
-- ##################################################################

		select tablespace_name
			 , count(*)
		  from dba_data_files
	  group by tablespace_name;

-- ##################################################################
-- DBA_SEGMENTS 1
-- ##################################################################

		select tablespace_name
			 , count(*)
		  from dba_segments
	  group by tablespace_name;

-- ##################################################################
-- DBA_SEGMENTS 2
-- ##################################################################

		select * 
		  from dba_segments 
		 where tablespace_name = 'APPS_TS_TX_DATA'
		   and segment_name = 'BNE_ASYNC_UPLOAD_JOBS_H';
