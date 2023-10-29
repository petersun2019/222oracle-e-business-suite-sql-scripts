/*
File Name: iex-customers.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- CUSTOMERS
-- COUNT BY COLLECTOR
-- CUSTOMERS LINKED TO PROFILE CLASSES - COUNT
-- CUSTOMERS LINKED TO PROFILE CLASSES - DETAILS
-- CUSTOMERS VIA COLLECTIONS ADMIN VIEW - DETAILS
-- CUSTOMERS VIA COLLECTIONS ADMIN VIEW - SUMMARY

*/

-- ##################################################################
-- CUSTOMERS
-- ##################################################################

/*
COLLECTIONS ADMIN CUSTOMERS ONLY RETURN CUSTOMERS FOR COLLECTORS LINKED TO PROMISES (PROMISE OR BROKEN PROMISES) AND / OR WORK ITEMS
SQL DERIVED FROM: HOW TO SETUP TERRITORIES/RESOURCES/COLLECTORS TO WORK WITH R12 COLLECTIONS (DOC ID 1397139.1)
*/

		select distinct hp.party_name
			 , hca.account_number
			 , ac.name collector_name
			 , ac.description
			 , hca.cust_account_id
		  from ar.hz_customer_profiles hcp
		  join ar.hz_cust_accounts hca on hcp.cust_account_id = hca.cust_account_id 
		  join ar.hz_parties hp on hcp.party_id = hp.party_id and hp.party_id = hca.party_id
		  join ar.ar_collectors ac on hcp.collector_id = ac.collector_id
		 where 1 = 1
		   and hca.status = 'A'
		   -- and hca.account_number = 123456
	  order by party_name;

-- ##################################################################
-- COUNT BY COLLECTOR
-- ##################################################################

		select ac.name collector_name
			 , count(distinct hca.cust_account_id) ct
		  from ar.hz_customer_profiles hcp
		  join ar.hz_cust_accounts hca on hcp.cust_account_id = hca.cust_account_id 
		  join ar.hz_parties hp on hcp.party_id = hp.party_id and hp.party_id = hca.party_id
		  join ar.ar_collectors ac on hcp.collector_id = ac.collector_id
		 where hca.status = 'A'
	  group by ac.name
	  order by ac.name; 

-- ##################################################################
-- CUSTOMERS LINKED TO PROFILE CLASSES - COUNT
-- ##################################################################

		select ac.name
			 -- , arcpv.profile_class_name
			 , count(distinct hca.cust_account_id) ct
		  from apps.ar_customer_profile_classes_v arcpv
		  join ar.ar_collectors ac on arcpv.collector_id = ac.collector_id
		  join ar.hz_cust_accounts hca on hca.customer_class_code = arcpv.profile_class_name
		 where hca.status = 'A'
	  group by ac.name
			 -- , arcpv.profile_class_name
	  order by 1,2;

-- ##################################################################
-- CUSTOMERS LINKED TO PROFILE CLASSES - DETAILS
-- ##################################################################

		select hca.account_number
			 , hca.account_name
			 , ac.name
			 , arcpv.profile_class_name
			 , arcpv.profile_class_description
			 , hca.customer_class_code
		  from apps.ar_customer_profile_classes_v arcpv
		  join ar.ar_collectors ac on arcpv.collector_id = ac.collector_id
		  join ar.hz_cust_accounts hca on hca.customer_class_code = arcpv.profile_class_name
		 where hca.account_number = 123456;

-- ##################################################################
-- CUSTOMERS VIA COLLECTIONS ADMIN VIEW - DETAILS
-- ##################################################################

		select hca.account_number
			 , hca.account_name
			 , hca.status
			 , acpcv.profile_class_name profile_class
			 , acpcv.profile_class_description
			 , acpcv.collector_name collector_on_cust_profile
			 , ac.name collector_on_customer
			 , iov.location bill_to_location
			 , iov.amount_due_remaining
			 , iov.promise_count
			 , iov.work_item_count
			 , ac.resource_id
		  from apps.iex_ownerships_v iov
		  join ar.ar_collectors ac on iov.resource_id = ac.resource_id
		  join ar.hz_cust_accounts hca on iov.cust_account_id = hca.cust_account_id
		  join applsys.fnd_user fu on ac.employee_id = fu.employee_id
	 left join apps.ar_customer_profile_classes_v acpcv on hca.customer_class_code = acpcv.profile_class_name
		 where nvl(fu.end_date, sysdate + 1) > sysdate
		   and 1 = 1
	  order by ac.name
			 , hca.account_name;

-- ##################################################################
-- CUSTOMERS VIA COLLECTIONS ADMIN VIEW - SUMMARY
-- ##################################################################

		select collector
			 , party_name
			 , account_number
			 , sum(flag_prom) promises
			 , sum(flag_brok) broken_promises
			 , sum(amount_due_remaining) amount_due_remaining 
		  from (select p.party_name party_name
					 , ac.name collector
					 , h.account_number account_number
					 , l.location location
					 , a.resource_id resource_id
					 , a.amount_due_remaining
					 , p.party_id party_id
					 , h.cust_account_id cust_account_id
					 , l.site_use_id customer_site_use_id
					 , case when a.state = 'PROMISE' then 1 end flag_prom
					 , case when a.state = 'BROKEN_PROMISE' then 1 end flag_brok
				  from iex.iex_promise_details a
			 left join iex.iex_delinquencies_all d on a.delinquency_id = d.delinquency_id 
				  join ar.hz_cust_accounts h on a.cust_account_id = h.cust_account_id 
				  join ar.hz_parties p on h.party_id = p.party_id 
				  join ar.ar_collectors ac on a.resource_id = ac.resource_id 
			 left join ar.hz_cust_site_uses_all l on d.customer_site_use_id = l.site_use_id 
				 where a.status = 'COLLECTABLE')
		 where 1 = 1
	  group by collector
			 , party_name
			 , account_number;
