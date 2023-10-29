/*
File Name: iex-work-items-strategies.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- WORK ITEMS AND STRATEGIES PER COLLECTOR - DETAILS
-- WORK ITEMS PER COLLECTOR - SUMMARY
-- WORK ITEMS PER COLLECTOR
-- WORK ITEM DETAILS FOR A COLLECTOR

*/

-- ##################################################################
-- WORK ITEMS AND STRATEGIES PER COLLECTOR - DETAILS
-- ##################################################################

		select idus.party_name account
			 , hca.account_number account
			 , idus.location
			 , idus.past_due_inv_value overdue
			 , idus.last_payment_amount
			 , idus.last_payment_date
			 , acpcv.profile_class_name profile_class
			 , acpcv.profile_class_description
			 , acpcv.collector_name collector_on_profile
			 , ac.name collector_on_work_item
			 , stry_templates.strategy_name
			 , lk1.meaning work_item_status
			 , lk2.meaning work_type
			 , lk3.meaning category_type
			 , '############'
			 , iswi.*
		  from iex.iex_strategy_work_items iswi
		  join iex.iex_dln_uwq_summary idus on iswi.strategy_id = idus.strategy_id
		  join ar.ar_collectors ac on iswi.resource_id = ac.resource_id
		  join iex.iex_strategies istrat on iswi.strategy_id = istrat.strategy_id
		  join ar.hz_cust_accounts hca on istrat.cust_account_id = hca.cust_account_id
		  join ar.hz_parties hp on hca.party_id = hp.party_id
		  join apps.ar_customer_profile_classes_v acpcv on hca.customer_class_code = acpcv.profile_class_name
		  join iex.iex_stry_temp_work_items_b stry_temp_wkitem_b on iswi.work_item_template_id = stry_temp_wkitem_b.work_item_temp_id
		  join iex.iex_stry_temp_work_items_tl stry_temp_wkitem_tl on stry_temp_wkitem_b.work_item_temp_id = stry_temp_wkitem_tl.work_item_temp_id
		  join apps.iex_strategy_templates_vl stry_templates on stry_templates.strategy_temp_id = iswi.strategy_temp_id
		  join apps.iex_lookups_v lk1 on lk1.lookup_code = iswi.status_code and lk1.lookup_type = 'IEX_STRATEGY_WORK_STATUS'
		  join apps.iex_lookups_v lk2 on lk2.lookup_code = stry_temp_wkitem_b.work_type and lk2.lookup_type = 'IEX_STRATEGY_WORK_TYPE'
		  join apps.iex_lookups_v lk3 on lk3.lookup_code = stry_temp_wkitem_b.category_type and lk3.lookup_type = 'IEX_STRATEGY_WORK_CATEGORY'
		 where 1 = 1
		   -- and iswi.status_code = 'OPEN'
		   -- and idus.past_due_inv_value is not null
		   -- and lk2.meaning != 'Automatic'
		   and hca.account_number = 123456
		   and iswi.creation_date > '22-JAN-2016'
		   and 1 = 1;

-- ##################################################################
-- WORK ITEMS PER COLLECTOR - SUMMARY
-- ##################################################################

		select ac.name collector_on_work_item
			 , count(*) ct 
		  from iex.iex_strategy_work_items iswi
		  join iex.iex_dln_uwq_summary idus on iswi.strategy_id = idus.strategy_id
		  join ar.ar_collectors ac on iswi.resource_id = ac.resource_id
		  join iex.iex_strategies istrat on iswi.strategy_id = istrat.strategy_id
		  join ar.hz_cust_accounts hca on istrat.cust_account_id = hca.cust_account_id
		  join ar.hz_parties hp on hca.party_id = hp.party_id
		  join apps.ar_customer_profile_classes_v acpcv on hca.customer_class_code = acpcv.profile_class_name
		  join iex.iex_stry_temp_work_items_b stry_temp_wkitem_b on iswi.work_item_template_id = stry_temp_wkitem_b.work_item_temp_id
		  join iex.iex_stry_temp_work_items_tl stry_temp_wkitem_tl on stry_temp_wkitem_b.work_item_temp_id = stry_temp_wkitem_tl.work_item_temp_id
		  join apps.iex_strategy_templates_vl stry_templates on stry_templates.strategy_temp_id = iswi.strategy_temp_id
		  join apps.iex_lookups_v lk1 on lk1.lookup_code = iswi.status_code and lk1.lookup_type = 'IEX_STRATEGY_WORK_STATUS'
		  join apps.iex_lookups_v lk2 on lk2.lookup_code = stry_temp_wkitem_b.work_type and lk2.lookup_type = 'IEX_STRATEGY_WORK_TYPE'
		  join apps.iex_lookups_v lk3 on lk3.lookup_code = stry_temp_wkitem_b.category_type and lk3.lookup_type = 'IEX_STRATEGY_WORK_CATEGORY'
		 where iswi.status_code = 'OPEN'
		   and idus.past_due_inv_value is not null
		   and lk2.meaning != 'Automatic'
		   and 1 = 1
	  group by ac.name; 

-- ##################################################################
-- WORK ITEMS PER COLLECTOR
-- ##################################################################

		select ac.name
			 , iswi.resource_id
			 , iswi.status_code
			 , count(*) ct
		  from iex.iex_strategy_work_items iswi
		  join ar.ar_collectors ac on iswi.resource_id = ac.resource_id
		 where status_code = 'OPEN'
		   and iswi.resource_id = 123456
	  group by ac.name
			 , iswi.resource_id
			 , iswi.status_code
	  order by ac.name;

-- ##################################################################
-- WORK ITEM DETAILS FOR A COLLECTOR
-- ##################################################################

		select * 
		  from iex.iex_strategy_work_items iswi 
		 where 1 = 1
		   and resource_id = 123456
		   -- and iswi.strategy_id = 123456
		   -- and iswi.strategy_temp_id = 123456
		   -- and creation_date > '22-JAN-2016'
		   and 1 = 1;
