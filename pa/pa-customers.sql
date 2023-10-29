/*
File Name:		pa-customers.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- CUSTOMERS LINKED TO A PROJECT 1
-- CUSTOMERS LINKED TO A PROJECT LINKED TO A TOP TASK
-- CUSTOMERS LINKED TO A PROJECT 2

*/

-- ##################################################################
-- CUSTOMERS LINKED TO A PROJECT 1
-- ##################################################################

		select ppa.segment1 project
			 , ppa.project_id
			 -- , ppa.name
			 -- , ppa.long_name
			 -- , ppa.description
			 , ppa.creation_date cr_dt
			 -- , pps.project_status_name project_status
			 , ppc.creation_date
			 , ppc.last_update_date up_dt
			 , fu2.description up_by
			 , ppc.customer_id
			 , haou.name org
			 , fu.description cr_by
			 , hca.account_number ac_num
			 , hca.account_name
			 -- , hca.status account_status
			 , hp.party_name
			 , hp.status party_status
			 -- , length(hca.account_name) len
			 -- , hp.party_number
			 , ppc.default_top_task_cust_flag
			 , hp.address1
			 , hp.address1 || ', ' || hp.address2 || ', ' || hp.address3 || ', ' || hp.city || ', ' || hp.postal_code address
		  from pa.pa_projects_all ppa
		  join pa.pa_project_customers ppc on ppa.project_id = ppc.project_id
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join ar.hz_cust_accounts hca on hca.cust_account_id = ppc.customer_id
		  join ar.hz_parties hp on hca.party_id = hp.party_id
		  join applsys.fnd_user fu on ppa.created_by = fu.user_id
		  join applsys.fnd_user fu2 on ppc.last_updated_by = fu2.user_id
		  join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
		 where 1 = 1
		   -- and ppa.segment1 like 'P%'
		   -- and hca.account_name like 'Blu%Cheese%'
		   and ppa.segment1 = 'P123456'
		   -- and ppc.last_update_date > '24-NOV-2015'
		   and 1 = 1;

-- ##################################################################
-- CUSTOMERS LINKED TO A PROJECT LINKED TO A TOP TASK
-- ##################################################################

		select distinct ppa.segment1 project
			 , ppa.name project_name
			 , hca.account_number
			 , hca.account_name
			 , hp.party_number
			 , pt.task_number task
			 , ppc.default_top_task_cust_flag top_task
			 , tbl_bill_to.bill_to_address
			 , tbl_ship_to.ship_to_address
		  from pa.pa_projects_all ppa
		  join pa.pa_tasks pt on ppa.project_id = pt.project_id
		  join pa.pa_project_customers ppc on pt.customer_id = ppc.customer_id and ppa.project_id = ppc.project_id
		  join ar.hz_cust_accounts hca on hca.cust_account_id = ppc.customer_id
		  join ar.hz_parties hp on hca.party_id = hp.party_id
		  join ar.hz_party_sites hps on hp.party_id = hps.party_id
		  join (select hcsua.cust_acct_site_id site_id
					 , trim(hl.address1) || ', ' || trim(hl.address2) || ', ' || trim(hl.address3) || ', ' || trim(hl.address4) || ', ' || trim(hl.city) || ', ' || trim(hl.state) || ', ' || trim(hl.postal_code) || ', ' || trim(ftt.territory_short_name) bill_to_address
				  from ar.hz_parties hp
					 , ar.hz_party_sites hps
					 , ar.hz_locations hl
					 , ar.hz_cust_accounts hca
					 , ar.hz_cust_acct_sites_all hcasa
					 , ar.hz_cust_site_uses_all hcsua
					 , applsys.fnd_territories_tl ftt 
				 where hp.party_id = hca.party_id
				   and hp.party_id = hps.party_id
				   and hps.location_id = hl.location_id
				   and hl.country = ftt.territory_code 
				   and hcasa.party_site_id = hps.party_site_id
				   and hca.cust_account_id = hcasa.cust_account_id
				   and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
				   and hcsua.site_use_code = 'BILL_TO'
				   -- and hps.status = 'A'
				   -- and hcasa.status = 'A'
				   -- and hcsua.status = 'A'
				   and 1 = 1) tbl_bill_to on ppc.bill_to_address_id = tbl_bill_to.site_id
		  join (select hcsua.cust_acct_site_id site_id
					 , trim(hl.address1) || ', ' || trim(hl.address2) || ', ' || trim(hl.address3) || ', ' || trim(hl.address4) || ', ' || trim(hl.city) || ', ' || trim(hl.state) || ', ' || trim(hl.postal_code) || ', ' || trim(ftt.territory_short_name) ship_to_address
				  from apps.hz_parties hp
					 , ar.hz_party_sites hps
					 , ar.hz_locations hl
					 , ar.hz_cust_accounts hca
					 , ar.hz_cust_acct_sites_all hcasa
					 , ar.hz_cust_site_uses_all hcsua
					 , applsys.fnd_territories_tl ftt 
				 where hp.party_id = hca.party_id
				   and hp.party_id = hps.party_id
				   and hps.location_id = hl.location_id
				   and hl.country = ftt.territory_code 
				   and hcasa.party_site_id = hps.party_site_id
				   and hca.cust_account_id = hcasa.cust_account_id
				   and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
				   and hcsua.site_use_code = 'SHIP_TO'
				   -- and hps.status = 'A'
				   -- and hcasa.status = 'A'
				   -- and hcsua.status = 'A'
				   and 1 = 1) tbl_ship_to on ppc.bill_to_address_id = tbl_ship_to.site_id
		 where 1 = 1
		   -- and pt.parent_task_id is null
		   and ppa.segment1 = 'P123456'
	  order by pt.task_number;

-- ##################################################################
-- CUSTOMERS LINKED TO A PROJECT 2
-- ##################################################################

		select ppa.segment1 proj
			 , cv1.customer_name customer
			 , length(cv1.customer_name) len_cust
			 , cv1.customer_number cust_no
			 , ppa.creation_date cr_dt
			 , fu.description cr_by
			 , pc1.default_top_task_cust_flag top_task_tick 
			 , cv1.status cust_status
			 , crv1.project_relationship_m
			 , pc1.customer_bill_split
			 , crv1.*
		  from apps.pa_customer_relationships_v crv1
		  join pa.pa_project_customers pc1 on pc1.project_relationship_code = crv1.project_relationship_code
		  join apps.pa_customers_v cv1 on pc1.customer_id = cv1.customer_id
		  join pa.pa_projects_all ppa on pc1.project_id = ppa.project_id
	 left join pa.pa_tasks pt on pc1.receiver_task_id = pt.task_id
		  join applsys.fnd_user fu on ppa.created_by = fu.user_id
		 where 1 = 1
		   -- and ppa.creation_date > '01-jul-2014'
		   -- and fu.description = 'Edible Cheese'
		   -- and ppa.created_by <> 1100
		   -- and length(cv1.customer_name) between 50 and 51
		   -- and ppa.segment1 like 'P%'
		   -- and cv1.customer_name like 'Smelly%Cheese%'
		   and ppa.segment1 = 'P123456'
		   -- and ppa.project_id in (1234,2345,3456)
		   and 1 = 1;
