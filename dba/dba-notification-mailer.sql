/*
File Name: dba-notification-mailer.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- OVERRIDE EMAIL ADDRESS
-- WAITING TO BE SENT OUT ON THE QUEUE
-- CHECK STATUS OF COMPONENTS
-- WORKFLOW PARAMETERS
-- CHECKING WORKFLOW COMPONENTS STATUS WHETHER ARE THEY RUNNING OR STOPPED.
-- LOG FILE LOCATIONS

*/

-- ##################################################################
-- OVERRIDE EMAIL ADDRESS
-- ##################################################################

/*
HTTPS://WWW.FUNORACLEAPPS.COM/2018/06/CHANGE-WORKFLOW-OVERRIDE-ADDRESS-IN.HTML
*/

		select fscpv.parameter_value
		  from fnd_svc_comp_params_tl fscpt
			 , fnd_svc_comp_param_vals fscpv
		 where fscpt.display_name = 'Test Address'
		   and fscpt.parameter_id = fscpv.parameter_id;

-- ##################################################################
-- WAITING TO BE SENT OUT ON THE QUEUE
-- ##################################################################

/*
HTTP://ORACLE4RYOU.BLOGSPOT.COM/2013/03/WORKFLOW-MAILER-TROUBLESHOOTING.HTML
*/

		select corr_id, retry_count, msg_state, count(*)
		  from applsys.aq$wf_notification_out
	  group by corr_id, msg_state, retry_count
		having msg_state = 'READY'
	  order by count(*) desc;

select * from wf_notification_out;

-- ##################################################################
-- CHECK STATUS OF COMPONENTS
-- ##################################################################

		select fsc.component_name
			 , fsc.startup_mode
			 , fsc.component_status
			 , fsc.component_status_info error
			 , fnd_svc_component.get_component_status(sc.component_name) component_status2
			 , '###############'
			 , fsc.*
		  from apps.fnd_concurrent_queues_vl fcq
		  join fnd_svc_components fsc on fsc.concurrent_queue_id = fcq.concurrent_queue_id
		 where 1 = 1
		   -- and fsc.component_name = 'Workflow Notification Mailer'
		   -- and fsc.component_type like 'WF%'
	  order by component_status
			 , startup_mode
			 , component_name;

-- ##################################################################
-- WORKFLOW PARAMETERS
-- ##################################################################

		select p.parameter_id
			 , p.parameter_name
			 , v.parameter_value value
		  from apps.fnd_svc_comp_param_vals_v v
		  join apps.fnd_svc_comp_params_b p on v.parameter_id = p.parameter_id
		  join apps.fnd_svc_components c on v.component_id = c.component_id
		 where 1 = 1
		   and c.component_type = 'WF_MAILER'
		   and p.parameter_name in ('OUTBOUND_SERVER', 'INBOUND_SERVER','ACCOUNT', 'FROM', 'NODENAME', 'REPLYTO','DISCARD' ,'PROCESS','INBOX')
	  order by p.parameter_name;

-- ##################################################################
-- CHECKING WORKFLOW COMPONENTS STATUS WHETHER ARE THEY RUNNING OR STOPPED.
-- ##################################################################

		select component_type
			 , component_name
			 , component_status
			 , component_status_info error
		  from fnd_svc_components
		 where component_type like 'WF%'
	  order by 1 desc,2,3;

-- ##################################################################
-- LOG FILE LOCATIONS
-- ##################################################################

		select fl.meaning
			 , fcp.process_status_code
			 , decode(fcq.concurrent_queue_name,'WFMLRSVC', 'mailer container','WFALSNRSVC','listener container',fcq.concurrent_queue_name)
			 , fcp.concurrent_process_id
			 , os_process_id
			 , fcp.logfile_name
		  from fnd_concurrent_queues fcq
		  join fnd_concurrent_processes fcp on fcq.concurrent_queue_id = fcp.concurrent_queue_id and fcp.process_status_code='A'
		  join fnd_lookups fl on fl.lookup_type = 'CP_PROCESS_STATUS_CODE' and fl.lookup_code = fcp.process_status_code
		 where 1 = 1
		   and concurrent_queue_name in('WFMLRSVC','WFALSNRSVC')
		   and 1 = 1
	  order by fcp.logfile_name;
