/*
File Name:		sa-concurrent-requests-params.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- PARAMETER NAMES AND VALUES FOR A REQUEST ID
-- DUMMY DATA PARAMETERS ATTEMPT

*/

-- ##################################################################
-- PARAMETER NAMES AND VALUES FOR A REQUEST ID
-- ##################################################################

with tbl_job_data as (
		select fcr.argument1
			 , fcr.argument2
			 , fcr.argument3
			 , fcr.argument4
			 , fcr.argument5
			 , fcr.argument6
			 , fcr.argument7
			 , fcr.argument8
			 , fcr.argument9 
			 , fcr.argument10
			 , fcr.argument11
			 , fcr.argument12
			 , fcr.argument13
			 , fcr.argument14
			 , fcr.argument15
			 , fcr.argument16
			 , fcr.argument17
			 , fcr.argument18
			 , fcr.argument19
			 , fcr.argument20
			 , fcr.argument21
			 , fcr.argument22
			 , fcr.argument23
			 , fcr.argument24
			 , fcr.argument25
		  from fnd_concurrent_requests fcr 
		 where fcr.request_id = :reqid)
			 , tbl_params as (select dfcu.column_seq_num col_seq
			 , dfcu.end_user_column_name col_prompt
			 , dfcu.enabled_flag
			 , fcr.request_id
			 , fcr.request_date
			 , fcr.completion_text
			 , cp.user_concurrent_program_name job_name
			 , dfcu.display_flag
			 , fcr.number_of_arguments args
			 , '' col_data
			 , '' col_attrib 
		  from fnd_concurrent_programs_vl cp 
		  join fnd_descr_flex_col_usage_vl dfcu on dfcu.descriptive_flexfield_name ='$SRS$.' || cp.concurrent_program_name and cp.application_id = dfcu.application_id
		  join fnd_flex_value_sets ffv on ffv.flex_value_set_id = dfcu.flex_value_set_id
		  join fnd_lookup_values_vl lv on lv.lookup_code = ffv.format_type
		  join fnd_concurrent_requests fcr on fcr.concurrent_program_id = cp.concurrent_program_id
		   and lv.lookup_type = 'FIELD_TYPE' 
		   and lv.enabled_flag = 'Y'
		   and dfcu.enabled_flag = 'Y'
		   -- and dfcu.display_flag = 'Y'
		   and lv.security_group_id = 0 
		   and lv.view_application_id = 0
		 where fcr.request_id = :reqid
	  order by dfcu.column_seq_num)
		select y.request_id
			 , y.request_date
			 , y.args
			 , y.job_name
			 , y.col_seq seq
			 , y.col_prompt param
			 , y.enabled_flag
			 , y.display_flag
			 -- , x.col_data conc_job_arg
			 , x.col_attrib job_value
			 , y.completion_text
		  from (select row_number() over (order by lpad (regexp_substr (d.col_data, '\d+'), 3, '0')) as r_num 
			 , null as col_prompt 
			 , d.col_data 
			 , d.col_attrib 
		  from tbl_job_data 
	unpivot include nulls 
			(col_attrib
		  for col_data in 
			  (argument1
			 , argument2
			 , argument3
			 , argument4
			 , argument5
			 , argument6
			 , argument7
			 , argument8
			 , argument9
			 , argument10
			 , argument11
			 , argument12
			 , argument13
			 , argument14
			 , argument15
			 , argument16
			 , argument17
			 , argument18
			 , argument19
			 , argument20
			 , argument21
			 , argument22
			 , argument23
			 , argument24
			 , argument25)) d
			   ) x
			 , (select request_id
			 , request_date
			 , args
			 , job_name
			 , completion_text
			 , col_seq 
			 , col_prompt
			 , enabled_flag
			 , display_flag
			 , row_number () over (order by col_seq) as r_num
		  from tbl_params
			   ) y
		 where x.r_num = y.r_num
		   -- and x.col_attrib is not null
		   -- and y.display_flag = 'Y'
	  order by x.r_num;

-- ##################################################################
-- DUMMY DATA PARAMETERS ATTEMPT
-- ##################################################################

set linesize 500 

with tbl_job_data as (select 'N' argument1 
			 , 'Y' argument2 
			 , null argument3 
			 , 'Y' argument4 
			 , null argument5 
			 , 'Y' argument6 
			 , 'Y' argument7 
			 , null argument8 
			 , 'Y' argument9 
			 , 'N' argument10 
			 , 'REGULAR' argument11 
			 , null argument12 
			 , 'N' argument13 
			 , null argument14 
			 , 'I' argument15 
			 , 'N' argument16 
			 , '100' argument17 
			 , '10' argument18 
		  from dual) 
			 , tbl_params as ( select 01 col_seq, 'From Project Number' col_prompt, null col_data, null col_attrib from dual union all 
		select 02 col_seq, 'To Project Number' col_prompt, null col_data, null col_attrib from dual union all 
		select 03 col_seq, 'Through Date' col_prompt, null col_data, null col_attrib from dual union all 
		select 04 col_seq, 'Summarize Cost' col_prompt, null col_data, null col_attrib from dual union all 
		select 05 col_seq, 'Expenditure Type Class' col_prompt, null col_data, null col_attrib from dual union all 
		select 06 col_seq, 'Summarize Revenue' col_prompt, null col_data, null col_attrib from dual union all 
		select 07 col_seq, 'Summarize Budgets' col_prompt, null col_data, null col_attrib from dual union all 
		select 08 col_seq, 'Budget Type' col_prompt, null col_data, null col_attrib from dual union all 
		select 09 col_seq, 'Summarize Commitments' col_prompt, null col_data, null col_attrib from dual union all 
		select 10 col_seq, 'Debug Mode' col_prompt, null col_data, null col_attrib from dual union all 
		select 11 col_seq, 'Summarization Context' col_prompt, null col_data, null col_attrib from dual union all 
		select 12 col_seq, 'Grouping Id' col_prompt, null col_data, null col_attrib from dual union all 
		select 13 col_seq, 'Delete Temp Table' col_prompt, null col_data, null col_attrib from dual union all 
		select 14 col_seq, 'Project Type' col_prompt, null col_data, null col_attrib from dual union all 
		select 20 col_seq, 'Mode' col_prompt, null col_data, null col_attrib from dual union all 
		select 30 col_seq, 'Generate Report Output' col_prompt, null col_data, null col_attrib from dual union all 
		select 40 col_seq, 'Batch Size' col_prompt, null col_data, null col_attrib from dual union all 
		select 50 col_seq, 'Number of Parallel Runs' col_prompt, null col_data, null col_attrib from dual) 
		select y.*,x.*
		  from (select row_number()
			over (order by lpad ( regexp_substr ( d.col_data
			 , '\d+')
			 , 3 -- max didgits
			 , '0')
			 ) as r_num 
			 , null as col_prompt 
			 , d.col_data 
			 , d.col_attrib 
		  from tbl_job_data 
		unpivot include nulls 
			(col_attrib
			for col_data in 
			  (argument1 
			 , argument2 
			 , argument3 
			 , argument4
			 , argument5
			 , argument6
			 , argument7
			 , argument8
			 , argument9
			 , argument10
			 , argument11
			 , argument12
			 , argument13
			 , argument14
			 , argument15
			 , argument16
			 , argument17
			 , argument18)) d 
			 ) x,
	   (select col_seq 
			 , col_prompt 
			 , col_data 
			 , col_attrib
			 , row_number () over (order by col_seq) as r_num
		  from tbl_params
			 ) y
		 where x.r_num = y.r_num
	  order by x.r_num;
