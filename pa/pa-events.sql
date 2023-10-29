/*
File Name: pa-events.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- EVENTS - DETAILS
-- EVENTS - WITH CUSTOMER DETAILS
-- PROJECTS AND CUSTOMERS
-- COUNT PER EVENT_TYPE
-- COUNT PER USER
-- COUNT NON DISTRIBUTED, GROUP BY HR ORG
-- COUNT NON DISTRIBUTED, GROUP BY HR ORG AND CUSTOMER - VERSION 1
-- NON DISTRIBUTED EVENTS - DETAILS - VERSION 1
-- NON DISTRIBUTED EVENTS - DETAILS - VERSION 2

*/

-- ##################################################################
-- EVENTS - DETAILS
-- ##################################################################

		select ppa.segment1
			 , ppa.distribution_rule distrib_rule
			 , pe.event_id
			 , ppa.project_id
			 , pt.task_number task
			 , pps.project_system_status_code sys_stat
			 , pe.event_num num 
			 , pe.request_id
			 , pe.bill_trans_bill_amount
			 , pe.bill_trans_rev_amount
			 , pe.bill_amount
			 , pe.revenue_amount
			 , pe.billed_flag billed
			 , pe.creation_date
			 , fu.user_name created_by
			 , pe.last_update_date
			 , pe.calling_process
			 , to_char(pe.completion_date, 'DD-MON-YYYY') completion_date
			 , pe.bill_trans_currency_code bill_curr 
			 , pe.bill_hold_flag bill_hold
			 , pe.revenue_distributed_flag distrib
			 , pe.event_type
			 , pe.description
			 , pe.funding_rate_type
			 , '#######################'
			 , pe.project_id
			 , pe.task_id
			 , pe.request_id
			 , pe.event_num
			 , nvl(pe.task_id, -1)
			 , pe.calling_process
			 , pe.calling_place
			 , pe.event_type
			 , pe.billed_flag
			 , pe.revenue_distributed_flag
			 -- , '#######################'
			 -- , pe.*
		  from pa.pa_events pe
		  join pa.pa_projects_all ppa on pe.project_id = ppa.project_id
		  join pa.pa_tasks pt on pe.task_id = pt.task_id
		  join applsys.fnd_user fu on pe.created_by = fu.user_id
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		 where 1 = 1
		   and ppa.segment1 in ('P123456')
		   -- and ppa.project_id = 123456
		   -- and pe.bill_amount = -697970.64
		   and pe.creation_date >= '26-JUL-2022'
		   -- and pe.request_id = 123456
		   -- and pe.event_num = 123
		   -- and ppa.distribution_rule like 'EVENT%'
		   -- and pe.bill_amount = 0
		   -- and pe.revenue_amount = 0
		   -- and (pe.bill_trans_bill_amount <> 0 or pe.bill_trans_rev_amount <> 0)
		   -- and pt.task_number = 'B'
		   -- and pe.completion_date < sysdate
		   -- and pe.event_type = 'Installment'
		   -- and pe.revenue_distributed_flag = 'Y'
		   -- and fu.user_name = 'CHEESE_USER'
	  order by pe.creation_date desc;

-- ##################################################################
-- EVENTS - WITH CUSTOMER DETAILS
-- ##################################################################

		select ppa.segment1
			 , pt.task_number task
			 , pt.task_name
			 , pe.event_id
			 , pe.project_id
			 , pe.completion_date
			 , pe.event_num num
			 , pe.creation_date
			 , pe.bill_trans_currency_code bill_curr
			 , fu.description created_by
			 , pe.event_type
			 , pe.bill_trans_bill_amount
			 , pe.bill_trans_rev_amount
			 , tbl_cust.custno
			 , tbl_cust.customer
		  from pa.pa_events pe
		  join pa.pa_projects_all ppa on pe.project_id = ppa.project_id
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join pa.pa_tasks pt on pe.task_id = pt.task_id
		  join applsys.fnd_user fu on pe.created_by = fu.user_id
		  join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
	 left join (distinct ppa.project_id
					   , pt.task_id
					   , hca.account_number custno
					   , hp.party_name customer 
					from pa.pa_projects_all ppa
					join pa.pa_tasks pt on ppa.project_id = pt.project_id 
					join pa.pa_project_customers ppc on pt.customer_id = ppc.customer_id and ppa.project_id = ppc.project_id
					join ar.hz_cust_accounts hca on hca.cust_account_id = ppc.customer_id 
					join ar.hz_parties hp on hp.party_id = hca.party_id 
					join ar.hz_party_sites hps on hp.party_id = hps.party_id
				   where pt.parent_task_id is null) tbl_cust on ppa.project_id = tbl_cust.project_id and pe.task_id = tbl_cust.task_id
		 where 1 = 1 
		   and ppa.segment1 = 'P123456'
		   and pe.creation_date > '22-JUN-2016'
		   -- and pe.event_num > 95
	  order by ppa.segment1
			 , pe.creation_date desc;


-- ##################################################################
-- PROJECTS AND CUSTOMERS
-- ##################################################################

		select distinct ppa.project_id
			 , pt.task_id
			 , hca.account_number custno
			 , hp.party_name customer 
		  from pa.pa_projects_all ppa
			 , pa.pa_tasks pt
			 , pa.pa_project_customers ppc
			 , ar.hz_parties hp
			 , ar.hz_party_sites hps
			 , ar.hz_cust_accounts hca 
		 where ppa.project_id = pt.project_id 
		   and pt.customer_id = ppc.customer_id 
		   and ppa.project_id = ppc.project_id 
		   and hp.party_id = hca.party_id 
		   and hp.party_id = hps.party_id 
		   and hca.cust_account_id = ppc.customer_id 
		   and pt.parent_task_id is null
		   and ppa.project_id = 123456;

-- ##################################################################
-- COUNT PER EVENT_TYPE
-- ##################################################################

		select pe.event_type
			 , count (*) ct
		  from pa.pa_events pe
		  join pa.pa_projects_all ppa on pe.project_id = ppa.project_id
	  group by pe.event_type
	  order by 2 desc;

-- ##################################################################
-- COUNT PER USER
-- ##################################################################

		select fu.description
			 , count (*) ct
		  from pa.pa_events pe
		  join applsys.fnd_user fu on pe.created_by = fu.user_id
		 where pe.creation_date between '01-JAN-2012' and '31-MAR-2012'
	  group by fu.description
	  order by 2 desc;

-- ##################################################################
-- COUNT NON DISTRIBUTED, GROUP BY HR ORG
-- ##################################################################

		select haou.name hr_org
			 , count (*) ct
		  from pa.pa_events pe
		  join pa.pa_projects_all ppa on pe.project_id = ppa.project_id
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join pa.pa_tasks pt on pe.task_id = pt.task_id
		  join applsys.fnd_user fu on pe.created_by = fu.user_id
		  join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
		 where 1 = 1
		   and pe.revenue_distributed_flag = 'N'
	  group by haou.name
	  order by 2 desc;

-- ##################################################################
-- COUNT NON DISTRIBUTED, GROUP BY HR ORG AND CUSTOMER - VERSION 1
-- ##################################################################

/*
USEFUL FOR RUNNING "PRC: GENERATE DRAFT REVENUE FOR A RANGE OF PROJECTS"
FIND EVENTS TO BILL AGAINST
NEED TO INCLUDE JOIN TO PA_TASKS TABLE, SINCE THAT JOINS TO CUSTOMER (TOP TASK).
EVENTS ARE LINKED TO TOP TASKS
REVENUES CAN BE DRIVEN BY EVENTS
TO FIND ELIGIBLE EVENTS PER CUSTOMER, NEED TO LINK TASKS TO CUSTOMERS

project header
task
top task > customer
event > top task
event > customer

pa_customer_relationships_v crv1 -- funder, debtor etc
pa_customers_v cv1 -- customer_id, party_id etc.
*/

		select cv1.customer_name
			 , cv1.customer_number
			 , count (distinct pe.event_id) event_count
		  from apps.pa_project_customers pc1
		  join apps.pa_customers_v cv1 on pc1.customer_id = cv1.customer_id
		  join apps.pa_customer_relationships_v crv1 on crv1.project_relationship_code = pc1.project_relationship_code
		  join pa.pa_projects_all ppa on ppa.project_id = pc1.project_id
		  join pa.pa_tasks pt on pt.project_id = ppa.project_id and pt.customer_id = cv1.customer_id -- join task to customer
		  join pa.pa_events pe on pe.project_id = ppa.project_id and pe.task_id = pt.task_id -- join event to top task
		  join pa.pa_project_statuses pps on pps.project_status_code = ppa.project_status_code
		  join hr.hr_all_organization_units haou on haou.organization_id = ppa.carrying_out_organization_id
		 where 1 = 1 
		   -- and cv1.customer_name = 'Honourable Company of Master Cheese Makers'
		   and pps.project_system_status_code = 'APPROVED'
		   and pe.completion_date <= sysdate + 32
		   and pe.revenue_distributed_flag = 'N'
		   and pe.bill_trans_bill_amount > 0
		   and pe.bill_hold_flag = 'N' 
		   and pe.billed_flag = 'N'
		   -- and ppa.segment1 = 'P123456'
	  group by cv1.customer_name
			 , cv1.customer_number
			 -- , haou.name
	  order by 3 desc;

-- ##################################################################
-- NON DISTRIBUTED EVENTS - DETAILS - VERSION 1
-- ##################################################################

		select ppa.segment1
			 , haou.name
			 , cv1.customer_name
			 , fu.description event_created_by
			 , pe.event_num num
			 , pe.billed_flag billed 
			 , pe.completion_date
			 , pe.creation_date
			 , pe.last_update_date
			 , pe.bill_trans_currency_code bill_curr
			 , pe.bill_hold_flag bill_hold
			 , pe.revenue_distributed_flag distrib
			 , pe.event_type
			 , pe.bill_trans_bill_amount bill_amt
			 , pe.bill_trans_rev_amount rev_amt
		  from apps.pa_project_customers pc1
		  join apps.pa_customers_v cv1 on pc1.customer_id = cv1.customer_id
		  join apps.pa_customer_relationships_v crv1 on crv1.project_relationship_code = pc1.project_relationship_code
		  join pa.pa_projects_all ppa on ppa.project_id = pc1.project_id
		  join pa.pa_tasks pt on pt.project_id = ppa.project_id and pt.customer_id = cv1.customer_id -- join task to customer
		  join pa.pa_events pe on pe.project_id = ppa.project_id and pe.task_id = pt.task_id -- join event to top task
		  join pa.pa_project_statuses pps on pps.project_status_code = ppa.project_status_code
		  join hr.hr_all_organization_units haou on haou.organization_id = ppa.carrying_out_organization_id
		  join applsys.fnd_user fu on pe.created_by = fu.user_id
		 where 1 = 1 
		   -- and cv1.customer_name = 'Honourable Company of Master Cheese Makers'
		   and pps.project_system_status_code = 'APPROVED'
		   and pe.completion_date <= sysdate + 32
		   and pe.revenue_distributed_flag = 'N'
		   and pe.bill_trans_bill_amount > 0
		   and pe.bill_hold_flag = 'N' 
		   and pe.billed_flag = 'N'
	  order by 2 desc;

-- ##################################################################
-- NON DISTRIBUTED EVENTS - DETAILS - VERSION 2
-- ##################################################################

		select ppa.segment1 project
			 , pt.task_number
			 , pe.event_num
			 , pe.completion_date
			 , pe.creation_date
			 , pe.bill_amount
			 , pe.bill_trans_bill_amount
			 , pe.revenue_amount
			 , pe.bill_trans_rev_amount
			 , pe.revenue_distributed_flag
		  from pa.pa_events pe
		  join pa.pa_projects_all ppa on ppa.project_id = pe.project_id
		  join pa.pa_tasks pt on pt.task_id = pe.task_id 
		 where 1 = 1
		   -- and pt.task_id = 123456
		   -- and pe.event_num = 2
		   and pe.bill_amount <> pe.bill_trans_bill_amount
		   and pe.revenue_amount <> pe.bill_trans_rev_amount
		   and pe.bill_amount = 0
		   and pe.revenue_amount = 0
		   -- and pe.completion_date between '01-OCT-2015' and '31-OCT-2015'
		   and pe.revenue_distributed_flag = 'N'
	  order by pe.creation_date desc;
