/*
File Name:		sa-concurrent-manager-queries.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

HTTPS://TECHGOEASY.COM/CONCURRENT-MANAGER-QUERIES/

Queries:

-- FND_CONCURRENT_QUEUE_CONTENT
-- QUERY TO CHECK THE SETTING OF THE ICM IN THE CONCURRENT MANAGER ENVIRONMENT
-- QUERY TO CHECK THE DETAILS FOR ALL THE ENABLED CONCURRENT MANAGERS
-- FOR EACH MANAGER GET THE NUMBER OF PENDING AND RUNNING REQUESTS IN EACH QUEUE:
-- HOW TO FIND WHICH MANAGER RUNS YOUR REQUEST ID/QUERY TO FIND CONCURRENT MANAGER FOR CONCURRENT PROGRAM
-- QUERY TO CHECK WHETHER ANY SPECIALIZATION RULE DEFINED FOR ANY CONCURRENT MANAGER THAT INCLUDES/EXCLUDES THE CONCURRENT PROGRAM IN QUESTION.

*/

-- ##################################################################
-- FND_CONCURRENT_QUEUE_CONTENT
-- ##################################################################

select * from fnd_concurrent_queue_content where concurrent_queue_id = 123456;

-- ##################################################################
-- QUERY TO CHECK THE SETTING OF THE ICM IN THE CONCURRENT MANAGER ENVIRONMENT
-- ##################################################################

		select 'PCP' "name"
			 , value
		  from apps.fnd_env_context
		 where variable_name = 'APPLDCP' 
		   and concurrent_process_id = (select max(concurrent_process_id) from apps.fnd_concurrent_processes where concurrent_queue_id = 1)
		union all
		select 'RAC' "name", decode(count(*), 0, 'N', 1, 'N', 'Y') "value" from v$thread
		union all
		select 'GSM' "name", nvl(v.profile_option_value, 'N') "value"
		  from apps.fnd_profile_options p
			 , apps.fnd_profile_option_values v
		 where p.profile_option_name = 'CONC_GSM_ENABLED'
		   and p.profile_option_id = v.profile_option_id
		union all
		select name
			 , value 
		  from apps.fnd_concurrent_queue_params
		 where queue_application_id = 0 
		   and concurrent_queue_id = 1;

-- ##################################################################
-- QUERY TO CHECK THE DETAILS FOR ALL THE ENABLED CONCURRENT MANAGERS
-- ##################################################################

		select fcq.application_id
			 , fcq.concurrent_queue_name
			 , fcq.creation_date queue_created
			 , fu.user_name queue_created_by
			 , fcq.user_concurrent_queue_name service
			 , fa.application_short_name
			 , fcq.target_node node
			 , fcq.max_processes target
			 , fcq.node_name primary
			 , fcq.node_name2 secondary
			 , fcq.cache_size
			 , fcp.concurrent_processor_name program_library
			 , sleep_seconds
		  from apps.fnd_concurrent_queues_vl fcq
		  join apps.fnd_application fa on fcq.application_id = fa.application_id
		  join apps.fnd_concurrent_processors fcp on fcq.processor_application_id = fcp.application_id and fcq.concurrent_processor_id = fcp.concurrent_processor_id
		  join apps.fnd_user fu on fcq.created_by = fu.user_id
		 where 1 = 1
		   and fcq.enabled_flag= 'Y'
		   and 1 = 1;

-- ##################################################################
-- FOR EACH MANAGER GET THE NUMBER OF PENDING AND RUNNING REQUESTS IN EACH QUEUE:
-- ##################################################################

		select a.user_concurrent_queue_name
			 , a.max_processes
			 , sum(decode(b.phase_code,'P',decode(b.status_code,'Q',1,0),0)) pending_standby
			 , sum(decode(b.phase_code,'P',decode(b.status_code,'I',1,0),0)) pending_normal
			 , sum(decode(b.phase_code,'R',decode(b.status_code,'R',1,0),0)) running_normal
		  from fnd_concurrent_queues_vl a
			 , fnd_concurrent_worker_requests b
		 where a.concurrent_queue_id = b.concurrent_queue_id
		   and b.requested_start_date <= sysdate
	  group by a.user_concurrent_queue_name
			 , a.max_processes;

-- ##################################################################
-- HOW TO FIND WHICH MANAGER RUNS YOUR REQUEST ID/QUERY TO FIND CONCURRENT MANAGER FOR CONCURRENT PROGRAM
-- ##################################################################

		select fcq.concurrent_queue_name 
			 , fcr.actual_start_date
			 , fcr.actual_completion_date
			 , fcp.logfile_name
			 , fcr.logfile_name
		  from fnd_concurrent_requests fcr
		  join fnd_concurrent_processes fcp on fcr.controlling_manager = fcp.concurrent_process_id
		  join fnd_concurrent_queues fcq on fcp.concurrent_queue_id = fcq.concurrent_queue_id and fcp.queue_application_id = fcq.application_id
		 where 1 = 1
		   and fcr.phase_code = 'C'
		   and fcr.request_id = 12345678
		   and 1 = 1;

-- ##################################################################
-- QUERY TO CHECK WHETHER ANY SPECIALIZATION RULE DEFINED FOR ANY CONCURRENT MANAGER THAT INCLUDES/EXCLUDES THE CONCURRENT PROGRAM IN QUESTION.
-- ##################################################################

		select fcp.concurrent_program_name
			 , decode(fcqc.include_flag,'I','Included','E','Excluded') include_flag
			 , fcqv.user_concurrent_queue_name
		  from fnd_concurrent_queues_vl fcqv
			 , fnd_concurrent_queue_content fcqc
			 , fnd_concurrent_programs fcp 
		 where fcqv.concurrent_queue_id = fcqc.concurrent_queue_id 
		   and fcqc.type_id = fcp.concurrent_program_id 
		   and fcp.concurrent_program_name like '%XX%'
		   and 1 = 1;
