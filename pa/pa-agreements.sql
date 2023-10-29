/*
File Name:		pa-agreements.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- PA - PROJECT AGREEMENTS
-- PA - PROJECT AGREEMENT AND FUNDING (PA_PROJECT_FUNDINGS)
-- PA - PROJECT AGREEMENTS - COUNTING

*/

-- ##################################################################
-- PA - PROJECT AGREEMENTS
-- ##################################################################

		select paa.agreement_id
			 , paa.customer_id
			 , paa.agreement_num
			 , paa.amount agreement_amount 
			 , paa.creation_date agreement_created
			 , paa.last_update_date
			 , hp.party_name
			 , hp.creation_date hp_created
			 , hp.last_update_date hp_updated
			 , hca.account_number
			 , hca.creation_date hca_created
			 , hca.last_update_date hca_updated
			 , paa.invoice_limit_flag
			 , paa.revenue_limit_flag
			 , paa.agreement_id
		  from pa.pa_agreements_all paa
		  join ar.hz_cust_accounts hca on paa.customer_id = hca.cust_account_id
		  join ar.hz_parties hp on hp.party_id = hca.party_id
		 where 1 = 1
		   and paa.agreement_num in ('AG-1234','AG-1235')
	  order by paa.creation_date desc;

-- ##################################################################
-- PA - PROJECT AGREEMENT AND FUNDING (PA_PROJECT_FUNDINGS)
-- ##################################################################

		select ppa.segment1 project
			 , ppa.creation_date
			 , ppa.name
			 , paa.agreement_id
			 , paa.customer_id
			 , paa.agreement_num
			 , paa.amount agreement_amount 
			 , paa.creation_date agreement_created
			 , paa.last_update_date
			 , hp.party_name
			 , hp.creation_date hp_created
			 , hp.last_update_date hp_updated
			 , hca.account_number
			 , hca.creation_date hca_created
			 , hca.last_update_date hca_updated
			 , pt.task_number task
			 , to_char(ppf.date_allocated, 'DD-MON-YYYY') funding_allocated
			 , ppf.allocated_amount funding_amount 
			 , fu.description funding_added_by
			 , ppf.funding_category
			 , paa.invoice_limit_flag
			 , paa.revenue_limit_flag
			 , paa.agreement_id
		  from pa_agreements_all paa
		  join pa_project_fundings ppf on ppf.agreement_id = paa.agreement_id
		  join pa_projects_all ppa on ppa.project_id = ppf.project_id
	 left join pa_tasks pt on ppa.project_id = pt.project_id and ppf.task_id = pt.task_id
		  join hz_cust_accounts hca on paa.customer_id = hca.cust_account_id
		  join hz_parties hp on hp.party_id = hca.party_id
		  join fnd_user fu on ppf.created_by = fu.user_id
		 where 1 = 1
		   -- and paa.invoice_limit_flag = 'Y'
		   and ppa.segment1 in ('P123456')
		   -- and paa.creation_date > '01-MAR-2021'
		   -- and paa.agreement_num in ('AG-1234','AG-1235')
	  order by paa.creation_date desc;

-- ##################################################################
-- PA - PROJECT AGREEMENTS - COUNTING
-- ##################################################################

		select ppa.segment1 project
			 , ppa.creation_date
			 , haou.name org
			 , count(distinct paa.agreement_id) agreement_count
		  from pa.pa_projects_all ppa
		  join pa.pa_tasks pt on ppa.project_id = pt.project_id
		  join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
	 left join pa.pa_project_fundings ppf on ppa.project_id = ppf.project_id and ppf.task_id = pt.task_id
	 left join pa.pa_agreements_all paa on ppf.agreement_id = paa.agreement_id
		 where 1 = 1
		   and ppa.project_status_code = 'APPROVED'
		   and sysdate between ppa.start_date and ppa.completion_date
		   and 1 = 1
		   -- and ppa.segment1 in ('P123456')
		having count(distinct paa.agreement_id) = 0
	  group by ppa.segment1
			 , ppa.creation_date
			 , haou.name
	  order by ppa.creation_date desc;

