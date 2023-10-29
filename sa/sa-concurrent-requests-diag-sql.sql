/*
File Name: sa-concurrent-requests-diag-sql.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- SQL ID AND CURRENT SQL FOR RUNNING REQUESTS
-- RECENT V$SQLAREA ACTIVITY
-- GET SQL DETAILS FOR A CONCURRENT REQUEST ID - VERSION 1
-- GET SQL DETAILS FOR A CONCURRENT REQUEST ID - VERSION 2
-- GET SQL DETAILS FOR AN SQL ID

*/

-- ##################################################################
-- SQL ID AND CURRENT SQL FOR RUNNING REQUESTS
-- ##################################################################

		select distinct fcr.request_id id
			 , fcr.oracle_process_id
			 , fcp.concurrent_program_name job
			 , nvl(fcr.description, fcpt.user_concurrent_program_name) job
			 , fcr.phase_code || ' - ' || fcr_phase.meaning phase
			 , fcr.status_code || ' - ' || fcr_status.meaning status
			 , to_char(fcr.actual_start_date, 'Dy') day
			 , fcr.actual_start_date run_date
			 , to_char((fcr.actual_start_date), 'HH24:MI:SS') start_
			 , to_char((fcr.actual_completion_date), 'HH24:MI:SS') end_
			 , case when fcr.phase_code = 'R' and fcr.actual_completion_date is null then trim(replace(replace(to_char(numtodsinterval((sysdate-fcr.actual_start_date),'day')),'+000000000',''),'.000000000','')) else trim(replace(replace(to_char(numtodsinterval((fcr.actual_completion_date-fcr.actual_start_date),'day')),'+000000000',''),'.000000000','')) end duration
			 , (select b.sql_id from v$process a, v$session b where a.addr = b.paddr and a.spid = (select oracle_process_id from applsys.fnd_concurrent_requests where request_id = fcr.request_id)) sql_id
			 , (select b.sid from v$process a, v$session b where a.addr = b.paddr and a.spid = (select oracle_process_id from applsys.fnd_concurrent_requests where request_id = fcr.request_id)) sid
			 -- , (select sql_id || '____' || sql_text from v$sqlarea where sql_id = (select b.sql_id from v$process a, v$session b where a.addr = b.paddr and a.spid = (select oracle_process_id from applsys.fnd_concurrent_requests where request_id = fcr.request_id))) sql_info
			 -- , regexp_replace((select sql_text from v$sqlarea where sql_id = (select b.sql_id from v$process a, v$session b where a.addr = b.paddr and a.spid = (select oracle_process_id from applsys.fnd_concurrent_requests where request_id = fcr.request_id))), '\s{2,}', ' ') sql_info -- regex replaces multiple spaces in a column with a single space 20-jul-2021
		  from applsys.fnd_concurrent_requests fcr 
		  join applsys.fnd_concurrent_programs_tl fcpt on fcr.concurrent_program_id = fcpt.concurrent_program_id and fcpt.language = userenv('lang')
		  join fnd_concurrent_programs_tl fcp on fcr.concurrent_program_id = fcp.concurrent_program_id and fcp.language = userenv('lang')
		  join applsys.fnd_concurrent_programs fcp on fcp.concurrent_program_id = fcpt.concurrent_program_id
		  join fnd_lookup_values_vl fcr_phase on fcr_phase.lookup_code = fcr.phase_code and fcr_phase.lookup_type = 'CP_PHASE_CODE' and fcr_phase.view_application_id = 0
		  join fnd_lookup_values_vl fcr_status on fcr_status.lookup_code = fcr.status_code and fcr_status.lookup_type = 'CP_STATUS_CODE' and fcr_status.view_application_id = 0
		 where 1 = 1
		   and fcr.phase_code = 'R' -- running
		   and fcr.request_id = 12345678
		   and 1 = 1;

-- ##################################################################
-- RECENT V$SQLAREA ACTIVITY
-- ##################################################################

		select * 
		  from v$sqlarea 
		 where last_active_time between to_date('09-MAY-2016 08:21:50', 'DD-MON-YYYY HH24:MI:SS') and to_date('09-MAY-2016 08:22:54', 'DD-MON-YYYY HH24:MI:SS')
		   and sql_text like '%GL_BALANC%'
	  order by last_active_time desc;

-- ##################################################################
-- GET SQL DETAILS FOR A CONCURRENT REQUEST ID - VERSION 1
-- ##################################################################

		select *
		  from v$sqlarea
		 where sql_id = (select ses.sql_id 
		  from v$session ses
			 , v$process pro 
		 where ses.paddr = pro.addr 
		   and pro.spid in (select oracle_process_id 
		  from applsys.fnd_concurrent_requests 
		 where request_id in (12345678)));

-- ##################################################################
-- GET SQL DETAILS FOR A CONCURRENT REQUEST ID - VERSION 2
-- ##################################################################

		select ses.*
			 , '#####################'
			 , pro.*
		  from v$session ses
			 , v$process pro 
		 where ses.paddr = pro.addr 
		   and pro.spid in (select oracle_process_id 
		  from applsys.fnd_concurrent_requests 
		 where request_id in (:id));

-- ##################################################################
-- GET SQL DETAILS FOR AN SQL ID
-- ##################################################################

		select *
		  from v$sqlarea
		 where sql_id = '2bz1v9fajvxmp';
