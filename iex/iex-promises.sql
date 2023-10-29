/*
File Name:		iex-promises.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- PROMISES INCLUDING TRANSACTION NUMBER
-- THIS IS THE VIEW USERS SEE IN UWQ (UNIVERSAL WORK QUEUE)
-- PROMISES PER COLLECOR
-- VIEW FROM COLLECTIONS ADMIN > OWNERSHIP > PROMISES
-- COLLECTOR SUMMARY

*/

-- ##################################################################
-- PROMISES INCLUDING TRANSACTION NUMBER
-- ##################################################################

		select ac.name collector_on_promise
			 , acpcv.collector_name collector_profile
			 , (select distinct ac.name collector_name from ar.hz_customer_profiles hcp join ar.hz_cust_accounts hca1 on hcp.cust_account_id = hca1.cust_account_id join ar.hz_parties hp on hcp.party_id = hp.party_id and hp.party_id = hca1.party_id join ar.ar_collectors ac on hcp.collector_id = ac.collector_id where hca1.cust_account_id = hca.cust_account_id) collector_on_cust
			 , hp.party_name
			 , acpcv.profile_class_name profile_class
			 , hca.account_number account
			 , ipd.promise_detail_id
			 , ipd.creation_date
			 , ipd.promise_date
			 , ipd.promise_amount
			 , ipd.amount_due_remaining
			 , ipd.status
			 , ipd.broken_on_date
			 , ipd.state
			 , ipd.resource_id
			 , ida.transaction_id
			 , fu.user_name promise_collector_username
			 , fu.end_date promise_collector_end_date
			 , rcta.trx_number
		  from iex.iex_promise_details ipd
		  join iex.iex_delinquencies_all ida on ipd.delinquency_id = ida.delinquency_id 
		  join ar.ar_collectors ac on ipd.resource_id = ac.resource_id
		  join ar.hz_cust_accounts hca on ipd.cust_account_id = hca.cust_account_id
		  join ar.hz_parties hp on hp.party_id = hca.party_id 
		  join applsys.fnd_user fu on ac.employee_id = fu.employee_id
		  join apps.ar_customer_profile_classes_v acpcv on hca.customer_class_code = acpcv.profile_class_name
		  join ar.ra_customer_trx_all rcta on ida.transaction_id = rcta.customer_trx_id
		 where 1 = 1
		   -- and fu.user_name like 'M%'
		   -- and length(hp.party_number) > 7
		   and hca.account_number = 123456
		   -- and fu.end_date is not null
		   -- and ac.name = 'Bugs Bunny'
		   -- and ipd.status = 'COLLECTABLE'
		   -- and hca.account_number = 123456
		   -- and ipd.state = 'BROKEN_PROMISE'
		   and 1 = 1;

-- ##################################################################
-- THIS IS THE VIEW USERS SEE IN UWQ (UNIVERSAL WORK QUEUE) - THEY CAN ONLY SEE PROMISES AGAINST CUSTOMERS WHICH THEY HAVE ACCESS TO
-- ##################################################################

		select ac.name collector
			 , acpcv.collector_name collector_profile
			 , (select distinct ac.name collector_name from ar.hz_customer_profiles hcp join ar.hz_cust_accounts hca1 on hcp.cust_account_id = hca1.cust_account_id join ar.hz_parties hp on hcp.party_id = hp.party_id and hp.party_id = hca1.party_id join ar.ar_collectors ac on hcp.collector_id = ac.collector_id where hca1.cust_account_id = hca.cust_account_id) collector_on_cust
			 , idus.party_name
			 , hca.customer_class_code profile_class
			 , idus.account_number account
			 , idus.location bill_to_loc
			 , idus.number_of_promises promise_count
			 , idus.promise_amount
			 , idus.broken_promise_amount
			 , idus.last_payment_amount
			 , idus.last_payment_date
		  from iex.iex_dln_uwq_summary idus
		  join ar.ar_collectors ac on idus.collector_resource_id = ac.resource_id 
		  join ar.hz_cust_accounts hca on idus.cust_account_id = hca.cust_account_id 
		  join apps.ar_customer_profile_classes_v acpcv on acpcv.profile_class_name = hca.customer_class_code
		 where 1 = 1
		   and idus.number_of_promises > 0
		   -- and ac.name like '%Bunny%'
	  order by 3;

-- ##################################################################
-- PROMISES PER COLLECOR
-- ##################################################################

		select ac.name collector
			 , count(*) ct
		  from iex.iex_dln_uwq_summary idus
		  join ar.ar_collectors ac on idus.collector_resource_id = ac.resource_id 
		 where 1 = 1
		   and idus.number_of_promises > 0
	  group by ac.name
	  order by ac.name;

-- ##################################################################
-- VIEW FROM COLLECTIONS ADMIN > OWNERSHIP > PROMISES
-- ##################################################################

		select ac.name collector_on_promise
			 , acpcv.collector_name collector_profile
			 , (select distinct ac.name collector_name from ar.hz_customer_profiles hcp join ar.hz_cust_accounts hca1 on hcp.cust_account_id = hca1.cust_account_id join ar.hz_parties hp on hcp.party_id = hp.party_id and hp.party_id = hca1.party_id join ar.ar_collectors ac on hcp.collector_id = ac.collector_id where hca1.cust_account_id = hca.cust_account_id) collector_on_cust
			 , hp.party_name
			 , acpcv.profile_class_name profile_class
			 , hca.account_number account
			 , ipd.promise_detail_id
			 , ipd.creation_date
			 , ipd.promise_date
			 , ipd.promise_amount
			 , ipd.amount_due_remaining
			 , ipd.status
			 , ipd.broken_on_date
			 , ipd.state
			 , ipd.resource_id
			 , fu.user_name promise_collector_username
			 , fu.end_date promise_collector_end_date
		  from iex.iex_promise_details ipd
		  join iex.iex_delinquencies_all ida on ipd.delinquency_id = ida.delinquency_id 
		  join ar.ar_collectors ac on ipd.resource_id = ac.resource_id
		  join ar.hz_cust_accounts hca on ipd.cust_account_id = hca.cust_account_id
		  join ar.hz_parties hp on hp.party_id = hca.party_id 
		  join applsys.fnd_user fu on ac.employee_id = fu.employee_id
		  join apps.ar_customer_profile_classes_v acpcv on hca.customer_class_code = acpcv.profile_class_name 
		 where 1 = 1
		   -- and fu.user_name like 'M%'
		   -- and length(hp.party_number) > 7
		   -- and fu.end_date is not null
		   -- and ac.name = 'Bugs Bunny'
		   -- and ipd.status = 'COLLECTABLE'
		   and hca.account_number = 123456
		   -- and ipd.state = 'BROKEN_PROMISE'
		   and 1 = 1;

-- ##################################################################
-- COLLECTOR SUMMARY
-- ##################################################################

with tbl_coll as
	   (select ac.name collector
			 , case when ipd.state = 'BROKEN_PROMISE' then 1 end promise_broken
			 , case when ipd.state = 'PROMISE' then 1 end promise
		  from iex.iex_promise_details ipd
		  join iex.iex_delinquencies_all ida on ipd.delinquency_id = ida.delinquency_id
		  join ar.ar_collectors ac on ipd.resource_id = ac.resource_id
		  join ar.hz_cust_accounts hca on ipd.cust_account_id = hca.cust_account_id
		  join ar.hz_parties hp on hca.party_id = hp.party_id
		  join applsys.fnd_user fu on ac.employee_id = fu.employee_id
		  join apps.ar_customer_profile_classes_v acpcv on hca.customer_class_code = acpcv.profile_class_name
		 where 1 = 1
		   and ipd.status = 'COLLECTABLE'
		   -- and fu.end_date is not null
		   -- and fu.user_name like 'M%'
		   and 1 = 1)
		select collector
			 , sum(promise) promise
			 , sum(promise_broken) broken_promise
		  from tbl_coll
	  group by collector
	  order by collector;
