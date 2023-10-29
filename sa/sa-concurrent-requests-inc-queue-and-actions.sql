/*
File Name:		sa-concurrent-requests-inc-queue-and-actions.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- CONCURRENT REQUESTS INCLUDING QUEUE AND ACTION INFO
-- ##################################################################

/* ACTION INFO INCLUDES THINGS LIKE WHETHER NOTIFY USERS ABOUT JOB COMPLETION ETC. */

		select sys_context('USERENV','DB_NAME') instance
			 , fcr.request_id id
			 , replace(fcr.parent_request_id, '-1','') parent_id
			 , fcr.request_date
			 , fcq.concurrent_queue_name queue
			 , fcr.requested_by
			 , fcr.lfile_size log
			 , fcr.ofile_size output
			 , (select count(*) from fnd_concurrent_requests where parent_request_id = fcr.request_id) child
			 -- , (select count(*)-1 from fnd_concurrent_requests fcr2 where 1 = 1 start with fcr2.request_id = fcr.request_id connect by prior fcr2.request_id = fcr2.parent_request_id) child
			 , fa.application_short_name app
			 , fcp.concurrent_program_name prog
			 , case when fcr.description = fcpt.user_concurrent_program_name then fcr.description when fcr.description is not null and fcpt.user_concurrent_program_name is not null and fcr.description <> fcpt.user_concurrent_program_name then fcr.description || ' (' || fcpt.user_concurrent_program_name || ')' when fcr.description is not null and fcpt.user_concurrent_program_name is null then fcr.description when fcr.description is null and fcpt.user_concurrent_program_name is not null then fcpt.user_concurrent_program_name end job
			 , fcpt.user_concurrent_program_name
			 , fcr.description
			 , fcr.requested_start_date
			 , fcr.actual_start_date started
			 , fcr.actual_completion_date completed
			 , fcr.phase_code || ' - ' || fcr_phase.meaning phase
			 , fcr.status_code || ' - ' || fcr_status.meaning status
			 , to_char(fcr.actual_start_date, 'Dy') day
			 , fcr.requested_start_date
			 , fcr.hold_flag
			 , to_char(fcr.actual_start_date, 'DD-MON-YYYY') run_date
			 , to_char((fcr.actual_start_date), 'HH24:MI:SS') start_
			 , to_char((fcr.actual_completion_date), 'HH24:MI:SS') end_
			 , case when fcr.phase_code = 'R' and fcr.actual_completion_date is null then trim(replace(replace(to_char(numtodsinterval((sysdate-fcr.actual_start_date),'day')),'+000000000',''),'.000000000','')) else trim(replace(replace(to_char(numtodsinterval((fcr.actual_completion_date-fcr.actual_start_date),'day')),'+000000000',''),'.000000000','')) end duration
			 , round(sysdate - fcr.actual_start_date, 0) ago
			 , frt.responsibility_name resp
			 , fu.user_name submitted_by
			 , fu.email_address
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
			 -- , fcr.*
		  from fnd_concurrent_requests fcr
		  join fnd_user fu on fcr.requested_by = fu.user_id
		  join fnd_concurrent_programs_tl fcpt on fcr.concurrent_program_id = fcpt.concurrent_program_id and fcpt.language = userenv('lang')
		  join fnd_concurrent_programs fcp on fcp.concurrent_program_id = fcpt.concurrent_program_id
		  join fnd_application fa on fcr.program_application_id = fa.application_id and fa.application_id = fcpt.application_id and fcp.application_id = fcpt.application_id
		  join fnd_responsibility_tl frt on fcr.responsibility_id = frt.responsibility_id and frt.language = userenv('lang')
		  join fnd_responsibility fr on fr.responsibility_id = frt.responsibility_id
		  join fnd_lookup_values_vl fcr_phase on fcr_phase.lookup_code = fcr.phase_code and fcr_phase.lookup_type = 'CP_PHASE_CODE' and fcr_phase.view_application_id = 0
		  join fnd_lookup_values_vl fcr_status on fcr_status.lookup_code = fcr.status_code and fcr_status.lookup_type = 'CP_STATUS_CODE' and fcr_status.view_application_id = 0
	 left join fnd_concurrent_processes fcp on fcr.controlling_manager = fcp.concurrent_process_id
	 left join fnd_concurrent_queues fcq on fcp.concurrent_queue_id = fcq.concurrent_queue_id and fcp.queue_application_id = fcq.application_id
	 left join fnd_conc_pp_actions fcpa on fcr.request_id = fcpa.concurrent_request_id
		 where 1 = 1
		   and fcr.actual_start_date is not null
		   -- and fcr.request_id in (12345678, 12345679)
		   and fu.user_name in ('USER123')
		   and fcr.request_date > sysdate - 1
		   and nvl(fcr.description, fcpt.user_concurrent_program_name) = 'PRC: Generate Cost Accounting Events'
	  order by fcr.request_id desc;
