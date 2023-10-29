/*
File Name: dba-source.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- DDL -- GET MAKE UP OF OBJECT E.G. TABLE, PACKAGE ETC.
-- DBA_SOURCE 1
-- DBA_SOURCE 2 - PACKAGE BODY
-- DBA_SOURCE 3 - SOURCE AND OBJECTS JOINED
-- TABLE DUMPS

*/

-- ##################################################################
-- DDL -- GET MAKE UP OF OBJECT E.G. TABLE, PACKAGE ETC.
-- ##################################################################

select dbms_metadata.get_ddl('TABLE','PO_REQUISITION_HEADERS_ALL','PO') from dual;
select dbms_metadata.get_dependent_ddl('TABLE','PO_REQUISITION_HEADERS_ALL','PO') from dual;
select dbms_metadata.get_xml('TABLE','PO_REQUISITION_HEADERS_ALL','PO') from dual;

-- ##################################################################
-- DBA_SOURCE 1
-- ##################################################################

		select owner
             , name
			 , (replace(replace(text,chr(10),''),chr(13),' ')) text
		  from dba_source
		 where name = 'XXCUST_BILL_PKG'
		   -- and text like '%$ID%'
		   and 1 = 1;

		select owner
			 , name
			 , type
			 , line
			 , trim((replace(replace(text,chr(10),''),chr(13),' '))) text 
		  from dba_source 
		 where (substrb(name,1,3) = 'PA_' or dubstrb(name,1,4) = 'PJI_')
		   and line=2 and type in ('PACKAGE','PACKAGE BODY')
	  order by name; 

-- ##################################################################
-- DBA_SOURCE 2 - PACKAGE BODY
-- ##################################################################

		select owner
			 , name
			 , line
			 , trim((replace(replace(text,chr(10),''),chr(13),' '))) text
		  from dba_source
		 where 1 = 1
		   and type = 'PACKAGE BODY'
		   and owner like 'XX%'
		   -- and name like 'P%'
		   and upper(text) like '%EI_GL_JOURNAL_PKG%'
	  order by line;

-- ##################################################################
-- DBA_SOURCE 3 - SOURCE AND OBJECTS JOINED
-- ##################################################################

		select b.data_object_id
			 , trim((replace(replace(text,chr(10),''),chr(13),' '))) text
		  from all_objects b
		  join all_source d on b.object_name = d.name 
		 where 1 = 1
		   and b.object_name = 'XXCUST_BILL_PKG' 
	  order by b.last_ddl_time desc;

-- ##################################################################
-- TABLE DUMPS
-- ##################################################################

select * from all_objects where object_name = 'DBMS_ADR';
select object_type,owner||'.'||object_name from dba_objects where status='INVALID';
select text from dba_source where name = 'AP_INVOICES_UTILITY_PKG' and line = 2;
select line, trim((replace(replace(text,chr(10),''),chr(13),' '))) text from dba_errors where name = 'AP_INVOICES_UTILITY_PKG';
select * from dba_objects where object_name like 'DBMS%' and object_name not like '%ALERT%';
