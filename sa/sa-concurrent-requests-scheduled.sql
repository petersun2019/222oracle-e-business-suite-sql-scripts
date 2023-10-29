/*
File Name: sa-concurrent-requests-scheduled.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
This script was useful when I worked at an organisation where we were upgrading from 11i to R12
We could use it to extract a list of scheduled requests, returning also when they ran, how often, at which times and one which dates / days of the month etc.
*/

-- ##################################################################
-- SCHEDULED CONCURRENT REQUESTS
-- ##################################################################
		select fcr.request_id
			 , fcp.concurrent_program_name prog_name
			 , fcpt.user_concurrent_program_name|| nvl2(fcr.description, ' (' || fcr.description || ')', null) conc_prog
			 , fcr.description
			 , fcr.request_date
			 , fcr.requested_start_date requested_start
			 , to_char(fcr.requested_start_date, 'DD-MON-YYYY') requested_start_trim
			 , to_char(fcr.requested_start_date, 'HH24:MI:SS') start_time
			 , fcr.phase_code || ' - ' || fcr_phase.meaning phase
			 , fcr.status_code || ' - ' || fcr_status.meaning status
			 , fat.application_short_name application
			 , fu.user_name requester
			 , fu.description requested_by
			 , frt.responsibility_name requested_by_resp
			 , fcr.argument_text "parameters"
			 , case when to_char(fcr.requested_start_date, 'D') = 1 then 'Monday' when to_char(fcr.requested_start_date, 'D') = 2 then 'Tuesday' when to_char(fcr.requested_start_date, 'D') = 3 then 'Wednesday' when to_char(fcr.requested_start_date, 'D') = 4 then 'Thursday' when to_char(fcr.requested_start_date, 'D') = 5 then 'Friday' when to_char(fcr.requested_start_date, 'D') = 6 then 'Saturday' when to_char(fcr.requested_start_date, 'D') = 7 then 'Sunday' end requested_start_day
			 , to_char((fcr.requested_start_date), 'HH24:MI:SS') start_time
			 , '------>' holds
			 , fcr.hold_flag
			 , decode(fcr.hold_flag, 'Y', 'Yes', 'N', 'No') on_hold
			 , fcr.last_update_date
			 , '------>' prints
			 , fcr.number_of_copies print_count
			 , fcr.printer
			 , fcr.print_style
			 , '------>' schedule
			 , decode (fcrc.class_type, 
				'P', 'Periodic',
				'S', 'On Specific Days',
				'X', 'Advanced',
				fcrc.class_type
				) schedule_type
			 , decode(fcr.increment_dates, 'N', '', 'Y', 'Yes') increment_dates
			 , case when fcrc.class_info is null then
					to_char(fcr.requested_start_date, 'DD-MON-YYYY HH24:MI:SS')
			   end run_once
			 , case when fcrc.class_type = 'P' then
					substr(fcrc.class_info, 1, instr(fcrc.class_info, ':') - 1)
			   end repeat_interval
			 , case when fcrc.class_type = 'P' then
					decode(substr(fcrc.class_info, instr(fcrc.class_info, ':', 1, 1) + 1, 1),
					'N', 'minutes',
					'M', 'months',
					'H', 'hours',
					'D', 'days') end repeat_interval_unit
			 , case when fcrc.class_type = 'P' then
					decode(substr(fcrc.class_info, instr(fcrc.class_info, ':', 1, 2) + 1, 1),
					'S', ' from the start of the prior run',
					'C', ' from the completion of the prior run')
			   end from_the 
			 , case when fcrc.class_type = 'S' and instr(substr(fcrc.class_info, 33),'1',1) > 0 then
					decode(substr(fcrc.class_info, 34, 1), '1', 'Mon, ') ||
					decode(substr(fcrc.class_info, 35, 1), '1', 'Tue, ') ||
					decode(substr(fcrc.class_info, 36, 1), '1', 'Wed, ') ||
					decode(substr(fcrc.class_info, 37, 1), '1', 'Thu, ') ||
					decode(substr(fcrc.class_info, 38, 1), '1', 'Fri, ') ||
					decode(substr(fcrc.class_info, 39, 1), '1', 'Sat, ') ||
					decode(substr(fcrc.class_info, 33, 1), '1', 'Sun ')
			   end days_of_week 
			 , case when fcrc.class_type = 'S' and instr(substr(fcrc.class_info, 1, 31),'1',1) > 0 then
					decode(substr(fcrc.class_info, 1, 1), '1', '1st, ') ||
					decode(substr(fcrc.class_info, 2, 1), '1', '2nd, ') ||
					decode(substr(fcrc.class_info, 3, 1), '1', '3rd, ') ||
					decode(substr(fcrc.class_info, 4, 1), '1', '4th, ') ||
					decode(substr(fcrc.class_info, 5, 1), '1', '5th, ') ||
					decode(substr(fcrc.class_info, 6, 1), '1', '6th, ') ||
					decode(substr(fcrc.class_info, 7, 1), '1', '7th, ') ||
					decode(substr(fcrc.class_info, 8, 1), '1', '8th, ') ||
					decode(substr(fcrc.class_info, 9, 1), '1', '9th, ') ||
					decode(substr(fcrc.class_info, 10, 1), '1', '10th, ') ||
					decode(substr(fcrc.class_info, 11, 1), '1', '11th, ') ||
					decode(substr(fcrc.class_info, 12, 1), '1', '12th, ') ||
					decode(substr(fcrc.class_info, 13, 1), '1', '13th, ') ||
					decode(substr(fcrc.class_info, 14, 1), '1', '14th, ') ||
					decode(substr(fcrc.class_info, 15, 1), '1', '15th, ') ||
					decode(substr(fcrc.class_info, 16, 1), '1', '16th, ') ||
					decode(substr(fcrc.class_info, 17, 1), '1', '17th, ') ||
					decode(substr(fcrc.class_info, 18, 1), '1', '18th, ') ||
					decode(substr(fcrc.class_info, 19, 1), '1', '19th, ') ||
					decode(substr(fcrc.class_info, 20, 1), '1', '20th, ') ||
					decode(substr(fcrc.class_info, 21, 1), '1', '21st, ') ||
					decode(substr(fcrc.class_info, 22, 1), '1', '22nd, ') ||
					decode(substr(fcrc.class_info, 23, 1), '1', '23rd,' ) ||
					decode(substr(fcrc.class_info, 24, 1), '1', '24th, ') ||
					decode(substr(fcrc.class_info, 25, 1), '1', '25th, ') ||
					decode(substr(fcrc.class_info, 26, 1), '1', '26th, ') ||
					decode(substr(fcrc.class_info, 27, 1), '1', '27th, ') ||
					decode(substr(fcrc.class_info, 28, 1), '1', '28th, ') ||
					decode(substr(fcrc.class_info, 29, 1), '1', '29th, ') ||
					decode(substr(fcrc.class_info, 30, 1), '1', '30th, ') ||
					decode(substr(fcrc.class_info, 31, 1), '1', '31st. ')
			   end days_of_month
			 , case when fcrc.class_type = 'S' and substr(fcrc.class_info, 32, 1) = '1' then
					'Yes'
			   end last_day_of_month_ticked
			 , fcrc.class_info
		  from fnd_concurrent_requests fcr
		  join fnd_user fu on fcr.requested_by = fu.user_id
		  join fnd_user u2 on fcr.last_updated_by = u2.user_id
		  join fnd_concurrent_programs fcp on fcr.concurrent_program_id = fcp.concurrent_program_id and fcr.program_application_id = fcp.application_id
		  join fnd_concurrent_programs_tl fcpt on fcp.concurrent_program_id = fcpt.concurrent_program_id and fcp.application_id = fcpt.application_id and fcpt.language = userenv('lang')
		  join fnd_printer_styles_tl fpst on fcr.print_style = fpst.printer_style_name and fpst.language = userenv('lang')
	 left join fnd_conc_release_classes fcrc on fcr.release_class_id = fcrc.release_class_id
		  join fnd_responsibility_tl frt on fcr.responsibility_id = frt.responsibility_id and frt.language = userenv('lang')
		  join fnd_application fat on fcr.program_application_id = fat.application_id and fat.application_id = fcpt.application_id and fcp.application_id = fcpt.application_id
		  join fnd_lookup_values_vl fcr_phase on fcr_phase.lookup_code = fcr.phase_code and fcr_phase.lookup_type = 'CP_PHASE_CODE' and fcr_phase.view_application_id = 0
		  join fnd_lookup_values_vl fcr_status on fcr_status.lookup_code = fcr.status_code and fcr_status.lookup_type = 'CP_STATUS_CODE' and fcr_status.view_application_id = 0
		 where 1 = 1
		   and phase_code = 'P'
		   and hold_flag = 'N' -- not on hold
		   -- and fu.user_name in ('USER123')
		   -- and fu.user_name not like 'M%'
		   -- and fcr.argument_text like '%PORCPT%'
		   -- and (nvl(fcr.description, fcpt.user_concurrent_program_name)) in ('Purge Concurrent Request and/or Manager Data')
		   -- and nvl(fcr.description, fcpt.user_concurrent_program_name) = 'PRC: Distribute Usage and Miscellaneous Costs'
		   -- and fcr.argument5 = 'SYSADMIN'
		   -- and fcp.concurrent_program_name = 'PAGCAE'
		   and 1 = 1;
