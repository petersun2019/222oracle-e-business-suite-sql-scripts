/*
File Name: iex-strategies.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- BASIC STRATEGY
-- STRATEGY STATUS COUNT
-- MORE DETAILED STRATEGY INFO

*/

-- ##################################################################
-- BASIC STRATEGY
-- ##################################################################

		select * 
		  from iex.iex_strategies istrat
		 where 1 = 1
		   -- and strategy_id = 123456
		   -- and strategy_template_id = 123456
		   and creation_date > '12-JUL-2016'
		   and 1 = 1
		   and 1 = 1;

-- ##################################################################
-- STRATEGY STATUS COUNT
-- ##################################################################

		select status_code
			 , count(*) ct
		  from iex.iex_strategies istrat
		 where istrat.strategy_template_id = 123456
	  group by status_code;

-- ##################################################################
-- MORE DETAILED STRATEGY INFO
-- ##################################################################

		select hca.account_number
			 , hp.party_name
			 , hp.party_type
			 , istrat.creation_date
			 , istrat.customer_site_use_id
			 , str_temp.strategy_name
			 , hp.party_name account
			 , hca.created_by_module customer_creation_method
			 , hca.creation_date customer_created
			 , fu.description customer_created_by
			 , (select classes.name 
		  from ar.hz_cust_profile_classes classes
			 , ar.hz_customer_profiles profiles 
		 where profiles.profile_class_id = classes.profile_class_id
		   and profiles.cust_account_id = hca.cust_account_id 
		   and profiles.site_use_id = istrat.customer_site_use_id) site_profile_class 
			 , acpcv.customer_profile_class_id
			 , acpcv.profile_class_name account_profile
			 , acpcv.collector_name account_collector
			 , (select sum(amount_due_remaining) from ar.ar_payment_schedules_all apsa where apsa.customer_id = hca.cust_account_id and apsa.amount_due_remaining > 0) balance_due
			 -- , istrat.*
		  from iex.iex_strategies istrat
		  join ar.hz_cust_accounts hca on istrat.cust_account_id = hca.cust_account_id
		  join ar.hz_parties hp on hca.party_id = hp.party_id
		  join apps.ar_customer_profile_classes_v acpcv on acpcv.profile_class_name = hca.customer_class_code
		  join applsys.fnd_user fu on hca.created_by = fu.user_id
		  join iex.iex_strategy_templates_tl str_temp on istrat.strategy_template_id = str_temp.strategy_temp_id
		  join ar.hz_parties hp on hca.party_id = hp.party_id
		 where 1 = 1
		   -- and strategy_id = 123456
		   and istrat.strategy_template_id = 123456
		   -- and istrat.customer_site_use_id = 123456
		   -- and istrat.creation_date > '22-JAN-2016'
		   and istrat.status_code = 'OPEN'
		   and (select sum(amount_due_remaining) from ar.ar_payment_schedules_all apsa where apsa.customer_id = hca.cust_account_id and apsa.amount_due_remaining > 0) > 0
		   -- and hca.account_number in ('123456')
		   and 1 = 1;
