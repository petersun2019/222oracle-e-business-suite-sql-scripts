/*
File Name:		sa-spool-example.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

spool c:\temp\oracle\test.txt
set trimspool on
set trimout on
set linesize 700

column cp_name format a12
column column_name format a30
column data_type format a15
column maximum_size format a15
column required_flag format a15
column display_flag format a15
column default_value format a15
column column_seq_num format a15

		select cp.concurrent_program_name cp_name -- the concurrent program name
			 , dfcu.end_user_column_name column_name -- the real argument name 
			 , lv.meaning data_type -- the data type of argument
			 , ffv.maximum_size -- the length of the argument
			 , dfcu.required_flag -- the argument required or not
			 , dfcu.display_flag -- the argument displayed or not on oracle form 
			 , dfcu.default_value -- the default value of the argument
			 , dfcu.column_seq_num -- the argument sequence number 
		  from apps.fnd_concurrent_programs_vl cp 
		  join apps.fnd_descr_flex_col_usage_vl dfcu on dfcu.descriptive_flexfield_name ='$SRS$.'||cp.concurrent_program_name
		  join apps.fnd_flex_value_sets ffv on ffv.flex_value_set_id = dfcu.flex_value_set_id
		  join apps.fnd_lookup_values_vl lv on lv.lookup_code = ffv.format_type and lv.lookup_type = 'FIELD_TYPE' and lv.enabled_flag = 'Y' and lv.security_group_id = 0 and lv.view_application_id = 0
		 where cp.concurrent_program_name = 'FNDGSCST'
	  order by cp.concurrent_program_name
			 , dfcu.column_seq_num;

spool off