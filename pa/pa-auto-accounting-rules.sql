/*
File Name: pa-auto-accounting-rules.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- AUTOACCOUNTING RULES
-- ASSIGN AUTOACCOUNTING RULES

*/

-- ##############################################################
-- AUTOACCOUNTING RULES
-- ##############################################################

		select pr.rule_name
			 , pr.rule_id
			 , pr.rule_type
			 , pr.key_source
			 , pr.constant_value
			 , pr.select_statement sql
			 , pr.creation_date cr_dt
			 , fu1.description cr_by
			 , pr.last_update_date upd_dt
			 , fu2.description upd_by
			 , (select count(psrra.rule_id) from pa.pa_segment_rule_pairings_all psrra where psrra.rule_id = pr.rule_id) assigned_count
		  from pa.pa_rules pr
		  join applsys.fnd_user fu1 on pr.created_by = fu1.user_id
		  join applsys.fnd_user fu2 on pr.last_updated_by = fu2.user_id
		 where 1 = 1
		   -- and pr.rule_name = 'XX Cust Rule 1'
		   -- and pr.select_statement is not null
		   and lower(pr.select_statement) like '%xxcust_get_cheese_strength%'
		   -- and lower(pr.rule_name) like '%cheese%'
		   and 1 = 1;

-- ##############################################################
-- ASSIGN AUTOACCOUNTING RULES
-- ##############################################################

		select pf.function_name
			 , pfta.function_transaction_name function_transaction
			 , psrra.segment_num segment
			 , haou.name org
			 , pr.rule_name
			 , pr.constant_value
			 , decode (pr.key_source, 'S', 'SQL', 'P', 'Parameter', 'C', 'Constant') source
			 , pr.constant_value
			 , psvls.segment_value_lookup_set_name lookup_name
			 , pr.select_statement
			 -- , '###########'
			 -- , psrra.*
			 -- , pfta.*
		  from pa.pa_functions pf
		  join pa.pa_segment_rule_pairings_all psrra on pf.application_id = psrra.application_id and pf.function_code = psrra.function_code
		  join pa.pa_function_transactions_all pfta on pfta.application_id = pf.application_id and pfta.function_code = psrra.function_code and pfta.function_transaction_code = psrra.function_transaction_code and pfta.org_id = psrra.org_id
		  join pa.pa_rules pr on psrra.rule_id = pr.rule_id
		  join hr_all_organization_units haou on haou.organization_id = pfta.org_id
	 left join pa.pa_segment_value_lookup_sets psvls on pr.segment_value_lookup_set_id = psvls.segment_value_lookup_set_id
		 where 1 = 1
		   and pfta.enabled_flag = 'Y'
		   -- and pr.rule_id in (1, 2, 3, 4)
		   -- and lower(pfta.function_transaction_name) like '%cheese%'
		   and psrra.segment_num = 5
		   -- and pr.rule_name like '%Cheese%'
		   -- and pf.function_name = 'Misc Cheese Cost Account'
		   -- and pfta.function_transaction_name = 'Misc Cheese Cost Account'
		   and pr.rule_name like '%Cheese%'
		   and haou.name = 'UK Cheese Org'
		   and 1 = 1
	  order by pf.function_name
			 , pfta.function_transaction_name
			 , psrra.segment_num;
