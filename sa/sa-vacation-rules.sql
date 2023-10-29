/*
File Name: sa-vacation-rules.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- VACATION RULES
-- ##################################################################

		select wrr.rule_id
			 , wrr.role from_username
			 , fu.description from_name
			 , wrr.begin_date start_date
			 , wrr.end_date
			 , wrr.message_type
			 , decode(wrr.action, 'FORWARD', 'Delegate', 'TRANSFER', 'Transfer') action
			 , wrr.action_argument to_username
			 , fu2.description to_name
			 , wrr.rule_comment
		  from applsys.wf_routing_rules wrr
		  join applsys.fnd_user fu on wrr.role = fu.user_name 
		  join applsys.fnd_user fu2 on wrr.action_argument = fu2.user_name
		  -- join applsys.fnd_user fu3 on wrr.created_by = fu3.user_name
		 where 1 = 1
		   and wrr.role = 'USER123'
		   -- and wrr.role like 'XX%BUY%'
		   -- and wrr.end_date >= sysdate
		   and 1 = 1;
