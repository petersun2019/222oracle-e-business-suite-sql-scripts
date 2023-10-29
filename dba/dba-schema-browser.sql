/*
File Name: dba-performance-checking.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- OBJECTS
-- TABLES
-- TABLES
-- FIND WHAT % STATS HAVE BEEN GATHERED ON A TABLE
-- TABLE COLUMNS
-- VIEW COLUMNS
-- TRIGGERS
-- SQL FOR A VIEW
-- FULL VIEW DEFINITION E.G. "CREATE OR REPLACE FORCE VIEW...."
-- INDEXES
-- SYNONYMS

*/

-- ##################################################################
-- OBJECTS
-- ##################################################################

		select *
		  from dba_objects
		 where 1 = 1
		   and object_name = 'XXCUST_PA_PROJECTS_UTIL'
		   -- and object_name = 'PJI_PJP_SUM_CUST'
		   and 1 = 1;

-- ##################################################################
-- TABLES
-- ##################################################################

-- TABLES
		select owner
			 , num_rows
			 , table_name
		  from all_tables
		 where 1 = 1
		   -- and owner = 'GL'
		   and table_name not like '%BK%'
		   and table_name like '%FILE%'
		   and num_rows > 0
	  order by num_rows desc;

-- FIND WHAT % STATS HAVE BEEN GATHERED ON A TABLE

		select owner
			 , table_name
			 , num_rows
			 , sample_size
			 , (sample_size/num_rows)*100 stat_percent
			 , last_analyzed 
		  from all_tables
		 where table_name in ('PO_LINES_ARCHIVE_ALL','ICX_CAT_ITEMS_CTX_HDRS_TLP');

-- ##################################################################
-- TABLE COLUMNS
-- ##################################################################

		select att.table_name
			 , atc.column_id id
			 , atc.column_name
			 , atc.data_type
			 , atc.data_length
			 , att.owner
			 , att.num_rows
		  from all_tab_columns atc
			 , all_tables att
		 where atc.table_name = att.table_name
		   and atc.owner = att.owner
		   -- and att.table_name like '%IN%'
		   -- and atc.data_type != 'LONG'
		   and column_name like '%HIER%'
		   -- and atc.data_type = 'DATE'
		   -- and atc.owner = 'IBY'
		   and att.num_rows > 0
	  order by att.table_name
			 , atc.column_id;

-- ##################################################################
-- VIEW COLUMNS
-- ##################################################################

select * from all_tab_columns where table_name = 'PA_PROJECT_LISTS_V';


-- ##################################################################
-- TRIGGERS
-- ##################################################################

select * from all_triggers where table_name like 'PA%PROJ%';
select * from all_triggers where table_name like 'PA%INVOICE%';
select * from all_triggers where upper(trigger_body) like '%XXPROJ%ASSIGNMENTS%';
select * from all_source where type = 'TRIGGER' and upper(text) like '%XXPROJ%ASSIGNMENTS%';

-- ##################################################################
-- SQL FOR A VIEW
-- ##################################################################

		select text 
		  from all_views 
		 where view_name = 'PA_PROJECT_LISTS_V';

-- FULL VIEW DEFINITION E.G. "CREATE OR REPLACE FORCE VIEW...."select dbms_metadata.get_ddl('VIEW','PA_PROJECT_LISTS_V','APPS') from dual;

-- ##################################################################
-- INDEXES
-- ##################################################################

		select *
		  from dba_ind_columns
		 where table_name in ('FND_RESPONSIBILITY')
	  order by 1, 2, 3, 5;

		select *
		  from dba_ind_columns
		 where table_name in ('AP_LIABILITY_BALANCE')
	  order by 1, 2, 3, 5;

select * from all_indexes where index_name like 'GL_CODE_COMBINATIONS_N3';

-- ##################################################################
-- SYNONYMS
-- ##################################################################

select * from all_synonyms where synonym_name = 'AR_REC_TRX_LE_DETAILS';
