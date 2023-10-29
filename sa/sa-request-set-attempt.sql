/*
File Name: sa-request-set-attempt.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- REQUEST SET WITHOUT STAGES
-- REQUEST SET WITH STAGES

*/

-- ##################################################################
-- REQUEST SET WITHOUT STAGES
-- ##################################################################

		select frs.request_set_name
			 , frst.user_request_set_name
			 , frs.creation_date request_set_created
			 , fu2.user_name created_by
			 , fat.application_name application
			 -- , frst.description
			 , fu.user_name owner
			 , to_char(frs.start_date_active, 'DD-MON-YYYY') start_date
			 , to_char(frs.end_date_active, 'DD-MON-YYYY') end_date
			 , (select max(to_char(fcr.request_date, 'yyyy-mm-dd')) max_date from fnd_concurrent_requests fcr join fnd_concurrent_programs_tl fcpt on fcr.concurrent_program_id = fcpt.concurrent_program_id and fcpt.language = userenv('lang') join fnd_concurrent_programs fcp on fcp.concurrent_program_id = fcpt.concurrent_program_id where fcp.concurrent_program_name = 'FNDRSSUB' and fcr.actual_completion_date is not null and fcr.description = frst.user_request_set_name) max_date
			 , (select count(*) from fnd_concurrent_requests fcr join fnd_concurrent_programs_tl fcpt on fcr.concurrent_program_id = fcpt.concurrent_program_id and fcpt.language = userenv('lang') join fnd_concurrent_programs fcp on fcp.concurrent_program_id = fcpt.concurrent_program_id where fcp.concurrent_program_name = 'FNDRSSUB' and fcr.actual_completion_date is not null and fcr.description = frst.user_request_set_name) usage_count
		  from fnd_request_sets frs
		  join fnd_request_sets_tl frst on frs.request_set_id = frst.request_set_id and frs.application_id = frst.application_id and frst.language = userenv('lang')
		  join fnd_application_tl fat on frs.application_id = fat.application_id and fat.language = userenv('lang')
	 left join fnd_user fu on frs.owner = fu.user_id
		  join fnd_user fu2 on frs.created_by = fu2.user_idx
		 where 1 = 1
		   and 1 = 1
		   and frst.user_request_set_name like 'XX%'
		   and nvl(frs.end_date_active, sysdate + 1) > sysdate
		   -- and fat.application_name = 'Projects'
		   and 1 = 1;

-- ##################################################################
-- REQUEST SET WITH STAGES
-- ##################################################################

		select frs.request_set_name
			 , frs.creation_date request_set_created
			 , frst.user_request_set_name
			 , frst.description
			 , frssfv.request_set_stage_id
			 , frssfv.stage_name
			 , fat.application_name
			 , frssfv.display_sequence
			 , frssfv.user_stage_name
			 , fcpt.user_concurrent_program_name
			 , fat2.application_name
			 , fu.user_name owner
			 , fe.executable_name
			 -- , cp_exec_method.meaning execution_method_code
			 , fet.user_executable_name
			 , fet.description executable_description
			 , fe.execution_file_name
		  from apps.fnd_request_sets frs
		  join apps.fnd_request_sets_tl frst on frs.request_set_id = frst.request_set_id and frs.application_id = frst.application_id and frst.language = userenv('lang')
		  join apps.fnd_req_set_stages_form_v frssfv on frs.request_set_id = frssfv.request_set_id
		  join apps.fnd_application_tl fat on frssfv.set_application_id = fat.application_id and fat.language = userenv('lang')
		  join apps.fnd_request_set_programs frsp on frsp.set_application_id = frssfv.set_application_id and frssfv.request_set_id = frsp.request_set_id
		  join apps.fnd_concurrent_programs_tl fcpt on frsp.concurrent_program_id = fcpt.concurrent_program_id and fcpt.language = userenv('lang')
		  join apps.fnd_concurrent_programs fcp on fcp.concurrent_program_id = fcpt.concurrent_program_id
	 left join apps.fnd_executables fe on fcp.executable_id = fe.executable_id and fe.application_id = fcp.application_id
	 left join apps.fnd_executables_tl fet on fe.executable_id = fet.executable_id and fet.application_id = fe.application_id and fet.language = userenv('lang')
		  join apps.fnd_application_tl fat2 on frsp.program_application_id = fat2.application_id and fat2.language = userenv('lang')
	 left join apps.fnd_user fu on frs.owner = fu.user_id
		 where 1 = 1
		   and 1 = 1
		   and frst.user_request_set_name = 'XX Projects Performance Data Load'
		   and 1 = 1;
