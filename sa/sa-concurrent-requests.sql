/*
File Name:		sa-concurrent-requests.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- CONCURRENT REQUESTS
-- HIERARCHY
-- CONCURRENT PROGRAM DEFINITION
-- CONCURRENT REQUESTS - VOLUMES PER HOUR
-- CONCURRENT REQUESTS - VOLUMES BY DAY
-- CONCURRENT REQUESTS - VOLUMES BY MONTH
-- CONCURRENT REQUESTS - VOLUMES BY RESPONSIBILITY
-- CONCURRENT REQUESTS - VOLUMES BY USER
-- CONCURRENT REQUESTS - VOLUMES BY QUEUE
-- CONCURRENT REQUESTS - VOLUMES SPLIT INTO 30 MINUTE BLOCKS
-- EXECUTABLES INFORMATION
-- COUNT OF EXECUTABLES BY EXECUTION METHOD
-- PARAMETERS FOR A CONCURRENT PROGRAM DEFINITION

*/

-- ##################################################################
-- CONCURRENT REQUESTS
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , fcr.request_id id
			 , replace(fcr.parent_request_id, '-1','') parent_id
			 , fcr.requested_by
			 , fcr.lfile_size log
			 , fcr.ofile_size output
			 , round((fcr.lfile_size/1000000),4) log_mb
			 , round((fcr.ofile_size/1000000),4) op_mb
			 , fa.application_short_name app
			 , fcp.concurrent_program_name prog
			 , case when fcr.description = fcpt.user_concurrent_program_name then fcr.description when fcr.description is not null and fcpt.user_concurrent_program_name is not null and fcr.description <> fcpt.user_concurrent_program_name then fcr.description || ' (' || fcpt.user_concurrent_program_name || ')' when fcr.description is not null and fcpt.user_concurrent_program_name is null then fcr.description when fcr.description is null and fcpt.user_concurrent_program_name is not null then fcpt.user_concurrent_program_name end job
			 , fcpt.user_concurrent_program_name
			 , fcr.description
			 , fcr.request_date
			 , fcr.actual_start_date started
			 , fcr.actual_completion_date completed
			 , fcr.requested_start_date
			 , fcr.phase_code || ' - ' || fcr_phase.meaning phase
			 , fcr.status_code || ' - ' || fcr_status.meaning status
			 , to_char(fcr.actual_start_date, 'DD-MON-YYYY') run_date
			 , to_char((fcr.actual_start_date), 'HH24:MI:SS') start_
			 , to_char((fcr.actual_completion_date), 'HH24:MI:SS') end_
			 , case when fcr.phase_code = 'R' and fcr.actual_completion_date is null then trim(replace(replace(to_char(numtodsinterval((sysdate-fcr.actual_start_date),'day')),'+000000000',''),'.000000000','')) else trim(replace(replace(to_char(numtodsinterval((fcr.actual_completion_date-fcr.actual_start_date),'day')),'+000000000',''),'.000000000','')) end duration
			 , round(sysdate - fcr.actual_start_date, 0) ago
			 , frt.responsibility_name resp
			 , fu.user_name submitted_by
			 , fu.email_address
			 , fcr.hold_flag
			 , (replace(replace(fcr.completion_text,chr(10),''),chr(13),' ')) completion_text
			 , fcr.argument_text
			 , fcr.resub_count
			 , fcr.root_request_id
			 , '##############################'
			 , fcr.outfile_name
			 , regexp_substr(fcr.outfile_name, '[^/]+', 1, 7) output_filename
			 , substr(fcr.outfile_name, instr(fcr.outfile_name, '.'), length(fcr.outfile_name)) out_ext
			 , fcr.logfile_name
			 , regexp_substr(fcr.logfile_name, '[^/]+', 1, 7) log_filename
			 , substr(fcr.logfile_name, instr(fcr.logfile_name, '.'), length(fcr.logfile_name)) log_ext
			 , '#############################'
			 , fcr.argument1
			 , fcr.argument2
			 , fcr.argument3
			 , fcr.argument4
			 , fcr.argument5
			 , fcr.argument6
		  from fnd_concurrent_requests fcr
	 left join fnd_user fu on fcr.requested_by = fu.user_id
	 left join fnd_concurrent_programs_tl fcpt on fcr.concurrent_program_id = fcpt.concurrent_program_id and fcpt.language = userenv('lang')
	 left join fnd_concurrent_programs fcp on fcp.concurrent_program_id = fcpt.concurrent_program_id
	 left join fnd_application fa on fcr.program_application_id = fa.application_id and fa.application_id = fcpt.application_id and fcp.application_id = fcpt.application_id
	 left join fnd_responsibility_tl frt on fcr.responsibility_id = frt.responsibility_id and frt.language = userenv('lang')
	 left join fnd_responsibility fr on fr.responsibility_id = frt.responsibility_id
	 left join fnd_lookup_values_vl fcr_phase on fcr_phase.lookup_code = fcr.phase_code and fcr_phase.lookup_type = 'CP_PHASE_CODE' and fcr_phase.view_application_id = 0
	 left join fnd_lookup_values_vl fcr_status on fcr_status.lookup_code = fcr.status_code and fcr_status.lookup_type = 'CP_STATUS_CODE' and fcr_status.view_application_id = 0
		 where 1 = 1
		   -- and fcr.request_id = 12345678
		   -- and fu.user_name in ('SYSADMIN')
		   -- and fa.application_short_name = 'SQLGL'
		   -- and fcr.actual_completion_date is not null -- job has completed
		   -- and fcp.concurrent_program_name = 'XLAACCPB'
		   -- and fcp.concurrent_program_name = 'FNDRSSUB' -- request set
		   -- and fcp.concurrent_program_name != 'FNDRSSTG' -- is not a request set stage
		   -- and frt.responsibility_name = 'Projects Superuser'
		   -- and to_char(fcr.actual_start_date, 'DD-MON-YYYY') >= '25-JUL-2022'
		   and fcr.request_date > sysdate - 5 -- last 5 days
		   -- and to_date('18-OCT-2021 19:54:37', 'DD-MON-YYYY HH24:MI:SS') between fcr.actual_start_date and fcr.actual_completion_date
		   -- and to_char(fcr.actual_start_date, 'HH24') in ('12','17')
		   -- and fcr.phase_code = 'R' -- running
		   and fcr.status_code = 'E' -- error
		   -- and fcr.argument21 = '111222'
		   -- and fcr.argument_text like '%111222%'
		   -- and nvl(fcr.description, fcpt.user_concurrent_program_name) = 'Journal Import'
		   and nvl(fcr.description, fcpt.user_concurrent_program_name) = 'PRC: Generate Cost Accounting Events'
		   -- and nvl(fcr.description, fcpt.user_concurrent_program_name) = 'Purge Concurrent Request and/or Manager Data'
		   -- and nvl(fcr.description, fcpt.user_concurrent_program_name) like 'PRC%'
		   -- and nvl(fcr.description, fcpt.user_concurrent_program_name) not in ('PO Output for Communication','Receiving Transaction Processor','Import Items')
	  order by fcr.request_id desc;

-- ##################################################################
-- HIERARCHY
-- ##################################################################

		select distinct sys_context('USERENV','DB_NAME') instance
			 , fcr.request_id
			 , fcr.parent_request_id parent
			 , fcr.resub_count
			 , fcr.root_request_id
			 , trim(lpad('_', (level - 1) * 2, '_') || fcr.request_id) id
			 , level
			 , trim(lpad('_', (level - 1) * 2, '_') || nvl(fcr.description, fcpt.user_concurrent_program_name)) job
			 , fcp.concurrent_program_name prog
			 , fcpt.user_concurrent_program_name
			 , fcr.phase_code || ' - ' || fcr_phase.meaning phase
			 , fcr.status_code || ' - ' || fcr_status.meaning status
			 , to_char(fcr.actual_start_date, 'DD-MON-YYYY') run_date
			 , to_char(fcr.actual_start_date, 'HH24:MI:SS') start_
			 , to_char(fcr.actual_completion_date, 'HH24:MI:SS') end_
			 , to_char(fcr.requested_start_date, 'HH24:MI:SS') start_time
			 -- , fcr.actual_start_date start_ 
			 -- , fcr.actual_completion_date end_
			 , case when fcr.phase_code = 'R' and fcr.actual_completion_date is null then trim(replace(replace(to_char(numtodsinterval((sysdate-fcr.actual_start_date),'day')),'+000000000',''),'.000000000','')) else trim(replace(replace(to_char(numtodsinterval((fcr.actual_completion_date-fcr.actual_start_date),'day')),'+000000000',''),'.000000000','')) end dur
			 , round((fcr.actual_completion_date - fcr.actual_start_date) * 1440, 2) as dur_mins
			 -- , fcr.ofile_size output_size
			 -- , fcr.lfile_size logfile_size
			 -- , fcr.request_type
			 , fu.user_name
			 , frt.responsibility_name
			 , (replace(replace(fcr.completion_text,chr(10),''),chr(13),' ')) completion_text
			 , fcr.argument_text
		  from fnd_concurrent_requests fcr
		  join fnd_user fu on fcr.requested_by = fu.user_id
		  join fnd_concurrent_programs_tl fcpt on fcr.concurrent_program_id = fcpt.concurrent_program_id and fcr.program_application_id = fcpt.application_id and fcpt.language = userenv('lang')
		  join fnd_responsibility_tl frt on fcr.responsibility_id = frt.responsibility_id and fcpt.language = userenv('lang')
		  join fnd_concurrent_programs fcp on fcp.concurrent_program_id = fcpt.concurrent_program_id
		  join fnd_lookup_values_vl fcr_phase on fcr_phase.lookup_code = fcr.phase_code and fcr_phase.lookup_type = 'CP_PHASE_CODE' and fcr_phase.view_application_id = 0
		  join fnd_lookup_values_vl fcr_status on fcr_status.lookup_code = fcr.status_code and fcr_status.lookup_type = 'CP_STATUS_CODE' and fcr_status.view_application_id = 0
		 where 1 = 1
		   -- and fcp.concurrent_program_name not in ('FNDRSSTG')
		   -- and fcr.phase_code != 'P'
		   -- and fcr.status_code = 'E'
		   -- and to_char(fcr.actual_start_date, 'DD-MON-YYYY') = '10-AUG-2022'
	start with fcr.request_id = 12345678
	connect by prior fcr.request_id = fcr.parent_request_id
order siblings by fcr.request_id;

-- ##################################################################
-- CONCURRENT PROGRAM DEFINITION
-- ##################################################################

		select fcpt.user_concurrent_program_name
			 , fcpt.description prog_description
			 , fat.application_name application
			 , fcp.creation_date
			 , fu1.user_name created_by
			 , fcp.last_update_date
			 , fu2.user_name updated_by
			 , fcp.application_id appl_id
			 , fcp.concurrent_program_id prog_id
			 , fcp.enabled_flag
			 , fcp.concurrent_program_name
			 , fcp.output_file_type
			 , fcp.enable_trace
			 , fcp.execution_options
			 , fe.executable_name
			 , cp_exec_method.meaning execution_method_code
			 , fet.user_executable_name
			 , fet.description executable_description
			 , fe.execution_file_name
			 -- , (select count(*) from fnd_concurrent_requests fcr where fcr.concurrent_program_id = fcp.concurrent_program_id) job_count
			 -- , (select min(request_date) from apps.fnd_concurrent_requests fcr where fcr.concurrent_program_id = fcp.concurrent_program_id) first_job
			 -- , (select max(request_date) from apps.fnd_concurrent_requests fcr where fcr.concurrent_program_id = fcp.concurrent_program_id) last_job
			 -- , (select max(request_id) from apps.fnd_concurrent_requests fcr where fcr.concurrent_program_id = fcp.concurrent_program_id) last_ran_info
			 -- , (select ff.user_name from apps.fnd_user ff where ff.user_id = (select requested_by from apps.fnd_concurrent_requests fcr where fcr.concurrent_program_id = fcp.concurrent_program_id and fcr.request_id = (select max(request_id) from apps.fnd_concurrent_requests fcr where fcr.concurrent_program_id = fcp.concurrent_program_id))) last_user
			 -- , '##########################'
			 -- , fcp.*
		  from fnd_concurrent_programs fcp
		  join fnd_concurrent_programs_tl fcpt on fcp.concurrent_program_id = fcpt.concurrent_program_id and fcp.application_id = fcpt.application_id and fcpt.language = userenv('lang')
		  join fnd_application_tl fat on fcp.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_user fu1 on fcp.created_by = fu1.user_id 
		  join fnd_user fu2 on fcp.last_updated_by = fu2.user_id 
	 left join fnd_executables fe on fcp.executable_id = fe.executable_id and fe.application_id = fcp.application_id
	 left join fnd_executables_tl fet on fe.executable_id = fet.executable_id and fet.application_id = fe.application_id and fet.language = userenv('lang')
	 left join fnd_lookup_values_vl cp_exec_method on cp_exec_method.lookup_code = fe.execution_method_code and cp_exec_method.lookup_type = 'CP_EXECUTION_METHOD_CODE' and cp_exec_method.view_application_id = 0
		 where 1 = 1
		   -- and fcp.concurrent_program_name = 'PASGLT'
		   -- and fcpt.user_concurrent_program_name in ('XX_UI_AR_CUSTOMERS','XX_UI_CUSTOMER_UPDATE')
		   -- and fcp.application_id = 275
		   -- and fcpt.user_concurrent_program_name = 'Workflow Background Process'
		   and lower(fcpt.user_concurrent_program_name) like '%analyzer'
		   -- and lower(fcpt.user_concurrent_program_name) like 'prc%update%'
		   -- and fcp.concurrent_program_id = 40197
		   -- and (select count(*) from fnd_concurrent_requests fcr where fcr.concurrent_program_id = fcp.concurrent_program_id) > 0
		   and 1 = 1
	  order by fcp.creation_date desc;

		select * from ap_inv_selection_criteria_all order by creation_date desc;

-- ##################################################################
-- CONCURRENT REQUESTS - VOLUMES PER HOUR
-- ##################################################################

		select to_char(actual_start_date, 'DD-MON-YYYY') run_date
			 -- , to_char((fcr.actual_start_date), 'HH24') start_
			 , nvl(fcr.description, fcpt.user_concurrent_program_name)
			 , count(*) ct
		  from fnd_concurrent_requests fcr 
		  join fnd_concurrent_programs_tl fcpt on fcr.concurrent_program_id = fcpt.concurrent_program_id
		 where 1 = 1
		   -- and nvl(fcr.description, fcpt.user_concurrent_program_name) = 'Compile value set hierarchies'
		   -- and fcpt.concurrent_program_id = 44149
		   and to_char(actual_start_date, 'DD-MON-YYYY') in ('05-AUG-2020','04-AUG-2020')
	  group by to_char(actual_start_date, 'DD-MON-YYYY')
			 -- , to_char((fcr.actual_start_date), 'HH24')
			 , nvl(fcr.description, fcpt.user_concurrent_program_name)
	  order by 1 desc, 2;

-- ##################################################################
-- CONCURRENT REQUESTS - VOLUMES BY DAY
-- ##################################################################

		select trunc(fcr.request_date) date_
			 , to_char (trunc(fcr.request_date), 'Dy') ddd
			 , min(fcr.actual_start_date) min_start
			 , max(fcr.actual_completion_date) max_end
			 , count(*) job_ct
		  from applsys.fnd_concurrent_requests fcr
		 where fcr.requested_by = 123
	  group by trunc(fcr.request_date)
			 , to_char (trunc(fcr.request_date), 'Dy')
	  order by trunc(fcr.request_date) desc;

-- ##################################################################
-- CONCURRENT REQUESTS - VOLUMES BY MONTH
-- ##################################################################

		select to_char (trunc(fcr.request_date), 'YYYY-MM') mon
			 , min(fcr.request_date) min_start
			 , max(fcr.request_date) max_end
			 , count(*) job_ct
		  from applsys.fnd_concurrent_requests fcr
		 where 1 = 1
		   -- and fcr.requested_by = 123
	  group by to_char (trunc(fcr.request_date), 'YYYY-MM')
	  order by 1;

-- ##################################################################
-- CONCURRENT REQUESTS - VOLUMES BY RESPONSIBILITY
-- ##################################################################

		select frt.responsibility_name
			 , count(*) ct
		  from apps.fnd_concurrent_requests fcr
		  join apps.fnd_concurrent_programs_tl fcpt on fcr.concurrent_program_id = fcpt.concurrent_program_id and fcr.program_application_id = fcpt.application_id 
		  join apps.fnd_responsibility_tl frt on fcr.responsibility_id = frt.responsibility_id and frt.language = userenv('lang')
		 where fcr.actual_completion_date is not null
		   and fcr.actual_completion_date > sysdate - 2
	  group by frt.responsibility_name
	  order by 2 desc;

-- ##################################################################
-- CONCURRENT REQUESTS - VOLUMES BY USER
-- ##################################################################

		select fu.user_name
			 , fu.email_address
			 , ppx.full_name
			 , fu.employee_id
			 , count(*)
			 , min(fcr.request_date)
			 , max(fcr.request_date)
		  from fnd_concurrent_requests fcr
		  join fnd_user fu on fcr.requested_by = fu.user_id
		  join fnd_concurrent_programs_tl fcpt on fcr.concurrent_program_id = fcpt.concurrent_program_id and fcpt.language = userenv('lang')
		  join fnd_concurrent_programs fcp on fcp.concurrent_program_id = fcpt.concurrent_program_id
	 left join per_people_x ppx on fu.employee_id = ppx.person_id
		 where 1 = 1
		   and fcr.actual_completion_date is not null
	  group by fu.user_name
			 , fu.email_address
			 , ppx.full_name
			 , fu.employee_id;

-- ##################################################################
-- CONCURRENT REQUESTS - VOLUMES BY QUEUE
-- ##################################################################

		select fcq.concurrent_queue_name queue
			 , case when fcr.description = fcpt.user_concurrent_program_name then fcr.description when fcr.description is not null and fcpt.user_concurrent_program_name is not null and fcr.description <> fcpt.user_concurrent_program_name then fcr.description || ' (' || fcpt.user_concurrent_program_name || ')' when fcr.description is not null and fcpt.user_concurrent_program_name is null then fcr.description when fcr.description is null and fcpt.user_concurrent_program_name is not null then fcpt.user_concurrent_program_name end job
			 , fu.user_name
			 , count(*)
			 , min(fcr.request_id) id_min
			 , max(fcr.request_id) id_max
			 , min(fcr.request_date) date_min
			 , max(fcr.request_date) date_max
		  from apps.fnd_concurrent_requests fcr
		  join apps.fnd_user fu on fcr.requested_by = fu.user_id
		  join apps.fnd_concurrent_programs_tl fcpt on fcr.concurrent_program_id = fcpt.concurrent_program_id and fcpt.language = userenv('lang')
		  join apps.fnd_concurrent_programs fcp on fcp.concurrent_program_id = fcpt.concurrent_program_id
	 left join fnd_concurrent_processes fcp on fcr.controlling_manager = fcp.concurrent_process_id
	 left join fnd_concurrent_queues fcq on fcp.concurrent_queue_id = fcq.concurrent_queue_id and fcp.queue_application_id = fcq.application_id
		 where 1 = 1
		   and fu.user_name in ('USER123','SYSADMIN')
		   and fcr.actual_completion_date is not null
		   and fcp.concurrent_program_name != 'FNDRSSUB' -- not a request set
		   and fcp.concurrent_program_name != 'FNDRSSTG' -- not a request set stage
	  group by fcq.concurrent_queue_name
			 , case when fcr.description = fcpt.user_concurrent_program_name then fcr.description when fcr.description is not null and fcpt.user_concurrent_program_name is not null and fcr.description <> fcpt.user_concurrent_program_name then fcr.description || ' (' || fcpt.user_concurrent_program_name || ')' when fcr.description is not null and fcpt.user_concurrent_program_name is null then fcr.description when fcr.description is null and fcpt.user_concurrent_program_name is not null then fcpt.user_concurrent_program_name end
			 , fu.user_name;

-- ##################################################################
-- CONCURRENT REQUESTS - VOLUMES SPLIT INTO 30 MINUTE BLOCKS
-- ##################################################################

/*
FRANK KULASH SOLUTION
THE MAGIC NUMBER 48 IN THE QUERY ABOVE IS THE NUMBER OF PERIODS IN A DAY.
ORACLE DATE ARITHMETIC ALWAYS DEALS IN UNTIS OF 1 DAY (THAT IS, 24 HOURS), BUT WE WANT TO DEAL IN UNITS OF 1/2 HOUR (THAT IS, 1/48 OF A DAY).
*/

with limitdata as
(select fcr.request_id id
			 , fcr.actual_start_date dt
		  from applsys.fnd_concurrent_requests fcr
		  join applsys.fnd_concurrent_programs_tl fcpt on fcr.concurrent_program_id = fcpt.concurrent_program_id and fcr.program_application_id = fcpt.application_id
		 where fcr.actual_start_date between to_date('20-JUL-2021 19:45:00', 'DD-MON-YYYY HH24:MI:SS') and to_date('20-JUL-2021 21:15:00', 'DD-MON-YYYY HH24:MI:SS')
		   and 1 = 1
		   -- and fcpt.user_concurrent_program_name not in ('PO Output for Communication','Cost Manager','Workflow Background Process','OAM Applications Dashboard Collection','Actual Cost Worker')
		   and 1 = 1)
			 , range as
	   (select trunc (min (dt)) as base_dt
			 , floor((min (dt) - trunc (min (dt)))* 48) as min_period
			 , floor((max (dt) - trunc (min (dt)))* 48) as max_period
		  from limitdata)
			 , all_periods as
	   (select base_dt+((min_period + level - 1)/ 48) as this_period
			 , base_dt+((min_period + level)/ 48) as next_period
		  from range
	connect by level <= max_period + 1 - min_period) 
		select to_char(p.this_period, 'DD-MON-YYYY HH24:MI - ') || to_char ( p.this_period + interval '29' minute, 'HH24:MI') as period
			 , count (l.dt) as cnt
		  from all_periods p
left outer join limitdata l on l.dt >= p.this_period and l.dt < p.next_period
	  group by p.this_period
	  order by p.this_period;

/*
ROGERT SOLUTION
*/

with limitdata as
(select fcr.request_id id
			 , fcr.actual_start_date dt
		  from applsys.fnd_concurrent_requests fcr
		  join applsys.fnd_concurrent_programs_tl fcpt on fcr.concurrent_program_id = fcpt.concurrent_program_id and fcr.program_application_id = fcpt.application_id
		 where fcr.actual_start_date between to_date('22-JUL-2021 20:15:00', 'DD-MON-YYYY HH24:MI:SS') and to_date('22-JUL-2021 21:15:00', 'DD-MON-YYYY HH24:MI:SS')
		   and 1 = 1
		   -- and fcpt.user_concurrent_program_name not in ('PO Output for Communication','Cost Manager','Workflow Background Process','OAM Applications Dashboard Collection','Actual Cost Worker')
		   and 1 = 1)
			 , chunks as (select rownum as chnk_no
			 , 0 + (86400/24) * (rownum -1) as secs_from
			 , 0 + (86400/24) * rownum -1 as secs_to
		  from dual
	connect by rownum <= 24)
		select d
			 , tfrom
			 , tto
			 , count(id) as cntr
		  from (select to_char(x.dt,'DD.MM.YYYY') as d
			 , to_char(x.dt + c.secs_from/86400,'HH24:MI') as tfrom
			 , to_char(x.dt + c.secs_to/86400,'HH24:MI') as tto
			 , c.chnk_no
			 , l.id
		  from chunks c
cross join (select distinct trunc(dt) dt from limitdata) x
left outer join limitdata l on ( trunc(l.dt) = x.dt 
		   and to_number(to_char(l.dt,'SSSSS')) between c.secs_from and c.secs_to)) x
	  group by d, tfrom, tto, chnk_no
	  order by d, chnk_no;

-- ##################################################################
-- EXECUTABLES INFORMATION
-- ##################################################################

		select fe.executable_name
			 , fe.execution_method_code
			 , fe.creation_date
			 , decode (fe.execution_method_code , 'A', 'Spawned' , 'B', 'Request Set Stage Function' , 'E', 'Perl Concurrent Program' , 'H', 'Host' , 'I', 'PL/SQL Stored Procedure' , 'J', 'Java Stored Procedure' , 'K', 'Java Concurrent Program' , 'L', 'SQL*Loader' , 'M', 'Multi Language Function' , 'P', 'Oracle Reports' , 'Q', 'SQL*Plus' , 'S', 'Immediate' , 'Other') execution_method_code_decode
			 , fet.user_executable_name
			 , fet.description executable_description
			 , fe.execution_file_name
			 , fu.user_name
		  from applsys.fnd_executables fe
		  join applsys.fnd_executables_tl fet on fe.executable_id = fet.executable_id and fet.application_id = fe.application_id
		  join applsys.fnd_user fu on fe.created_by = fu.user_id
		 where fet.user_executable_name = 'XX Segment Values Listing';

-- ##################################################################
-- COUNT OF EXECUTABLES BY EXECUTION METHOD
-- ##################################################################

		select fe.execution_method_code
			 , decode (fe.execution_method_code , 'A', 'Spawned' , 'B', 'Request Set Stage Function' , 'E', 'Perl Concurrent Program' , 'H', 'Host' , 'I', 'PL/SQL Stored Procedure' , 'J', 'Java Stored Procedure' , 'K', 'Java Concurrent Program' , 'L', 'SQL*Loader' , 'M', 'Multi Language Function' , 'P', 'Oracle Reports' , 'Q', 'SQL*Plus' , 'S', 'Immediate' , 'Other') execution_method_code
			 , count (*) ct
		  from applsys.fnd_executables fe
		  join applsys.fnd_executables_tl fet on fe.executable_id = fet.executable_id and fet.application_id = fe.application_id
	  group by fe.execution_method_code
			 , decode (fe.execution_method_code , 'A', 'Spawned' , 'B', 'Request Set Stage Function' , 'E', 'Perl Concurrent Program' , 'H', 'Host' , 'I', 'PL/SQL Stored Procedure' , 'J', 'Java Stored Procedure' , 'K', 'Java Concurrent Program' , 'L', 'SQL*Loader' , 'M', 'Multi Language Function' , 'P', 'Oracle Reports' , 'Q', 'SQL*Plus' , 'S', 'Immediate' , 'Other')
	  order by 3 desc;

-- ##################################################################
-- PARAMETERS FOR A CONCURRENT PROGRAM DEFINITION
-- ##################################################################

		select cp.concurrent_program_name cp_name -- the concurrent program name
			 , dfcu.column_seq_num seq -- the argument sequence number 
			 , dfcu.end_user_column_name column_name -- the real argument name 
			 , dfcu.form_left_prompt prompt
			 , dfcu.enabled_flag
			 , dfcu.required_flag required -- the argument required or not
			 , dfcu.display_flag displayed -- the argument displayed or not on oracle form 
			 -- , lv.meaning data_type -- the data type of argument
			 , ffv.flex_value_set_name -- value set name
			 , ffv.description flex_description -- value set description
			 -- , ffv.maximum_size -- the length of the argument
			 , dfcu.default_value -- the default value of the argument
			 , dfcu.last_update_date
		  from apps.fnd_concurrent_programs_vl cp 
	 left join apps.fnd_descr_flex_col_usage_vl dfcu on dfcu.descriptive_flexfield_name ='$SRS$.'||cp.concurrent_program_name
	 left join apps.fnd_flex_value_sets ffv on ffv.flex_value_set_id = dfcu.flex_value_set_id
	 left join apps.fnd_lookup_values_vl lv on lv.lookup_code = ffv.format_type and lv.lookup_type = 'FIELD_TYPE' and lv.enabled_flag = 'Y' and lv.security_group_id = 0 and lv.view_application_id = 0
		 where cp.concurrent_program_name = 'GLLEZL'
	  order by cp.concurrent_program_name
			 , dfcu.column_seq_num;
