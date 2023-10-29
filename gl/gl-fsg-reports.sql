/*
File Name: gl-fsg-reports.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- DATA DUMPS
-- ##################################################################

-- COLUMN SET
select * from rg_report_axis_sets_v where axis_set_type = 'C' order by creation_date desc;

-- ROW SET, 
select * from rg_report_axis_sets_v where axis_set_type = 'R' order by creation_date desc;

-- REPORTS
select * from rg_reports_v order by creation_date desc;

-- TABLES

		select table_name, num_rows
		  from all_tables
		 where table_name like 'RG%'
		   and num_rows > 0
	  order by 2 desc;

/*
TABLE_NAME 						NUM_ROWS
------------------------------- ----------
RG_REPORT_REQUEST_LOBS 			40683
RG_REPORT_PARAMETERS 			32508
RG_REPORT_REQUESTS 				25447
RG_REPORT_AXIS_CONTENTS 		20310
RG_REPORT_AXES					16829
RG_REPORTS 						5435
RG_REPORT_CALCULATIONS 			4797
RG_REPORT_SET_REQ_DETAILS 		2963
RG_REPORT_SET_REQUESTS 			1026
RG_REPORT_CONTENT_OVERRIDES 	926
RG_REPORT_AXIS_SETS 			586
RG_ROW_SEGMENT_SEQUENCES 		119
RG_REPORT_CONTENT_SETS 			108
RG_LOOKUPS_OLD 					104
RG_REPORT_STANDARD_AXES_B 		67
RG_REPORT_STANDARD_AXES_TL 		67
RG_REPORT_STANDARD_AXES_11I 	45
RG_ROW_ORDERS 					42
RG_REPORT_SETS 					21
RG_SIMPLE_WHERE_CLAUSES 		5
RG_DSS_REQUESTS 				3
RG_TABLE_SIZES 					2
RG_DSS_DIMENSIONS 				1
RG_DATABASE_LINKS 				1
RG_REPORT_DISPLAY_SETS 			1

25 rows selected. 
*/