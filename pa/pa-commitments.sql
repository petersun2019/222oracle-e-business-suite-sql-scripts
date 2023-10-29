/*
File Name:		pa-commitments.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- MULTI ORG
-- PA COMMITMENTS TABLE DUMP
-- PA COMMITMENTS DETAILS

*/

-- ##################################################################
-- MULTI ORG
-- ##################################################################

/*
Some views return no data unless you run some initial commands
e.g. for some Multi-Org views, that is the case, such as "pa_status_commitments_v"
If you run "FND_GLOBAL.APPS_INITIALIZE" you have to provide:

- user_id
- responsibility_id
- application_id

For the user and responsibility that user would in theory be using to access that data.

You can get those IDs via this SQL - e.g. find all Projects (PA) responsities assigned to user "CHEESE_USER":
*/

		select fu.user_id
			 , fr.responsibility_id
			 , fa.application_id
			 , frt.responsibility_name
		  from fnd_user_resp_groups_direct furg
		  join fnd_user fu on furg.user_id = fu.user_id 
		  join fnd_responsibility_tl frt on furg.responsibility_id = frt.responsibility_id and frt.language = userenv('lang')
		  join fnd_responsibility fr on fr.responsibility_id = frt.responsibility_id and fr.application_id = frt.application_id
		  join fnd_application fa on fr.application_id = fa.application_id
		 where nvl(fu.end_date, sysdate + 1) > sysdate
		   and nvl(fr.end_date, sysdate + 1) > sysdate
		   and nvl(furg.end_date, sysdate + 1) > sysdate
		   and fu.user_name in ('CHEESE_USER')
		   and fa.application_short_name = 'PA'
		   and 1 = 1;

/*
You can then use those IDs for FND_GLOBAL.APPS_INITIALIZE":
*/

BEGIN 
	MO_GLOBAL.INIT('PA');
	MO_GLOBAL.SET_POLICY_CONTEXT('S',123); -- where 123 is the Org ID for the Org you want to retrieve data for
	fnd_global.apps_initialize(1234, 5678, 275); -- user_id / responsibility_id / application_id
END;

-- ##################################################################
-- PA COMMITMENTS TABLE DUMP
-- ##################################################################

select * from pa_commitment_txns pct where project_id = 68321;
select * from pa_status_commitments_v; -- might need to followed "MULTI ORG" advice above to see data here

-- ##################################################################
-- PA COMMITMENTS DETAILS
-- ##################################################################

		select ppa.segment1 project
			 , ppa.project_id
			 , pt.task_number
			 , pct.cmt_number
			 , pct.transaction_source
			 , decode(pct.line_type, 'P','PO','R','REQ','I','INVOICE') line_type
			 , pct.expenditure_type
			 , pct.expenditure_category
			 , pct.system_linkage_function
			 , pct.creation_date commt_created
			 , fu.user_name commt_created_by
			 , fu.email_address commt_created_by_email
			 , pct.request_id
			 , fcpt.user_concurrent_program_name job
			 , to_char(pct.expenditure_item_date, 'yyyy-mm-dd') expenditure_item_date
			 , pct.vendor_name
			 , pct.tot_cmt_raw_cost
			 , pct.tot_cmt_burdened_cost
			 , pct.tot_cmt_quantity
			 , pct.denom_currency_code
		  from pa_projects_all ppa
		  join pa_tasks pt on ppa.project_id = pt.project_id
		  join pa_commitment_txns pct on pct.project_id = ppa.project_id and pct.task_id = pt.task_id
	 left join fnd_user fu on fu.user_id = pct.created_by
	 left join fnd_concurrent_requests fcr on fcr.request_id = pct.request_id
	 left join fnd_concurrent_programs_tl fcpt on fcr.concurrent_program_id = fcpt.concurrent_program_id and fcpt.language = userenv('lang')
		 where 1 = 1
		   and ppa.segment1 = 'P123456'
		   -- and ppa.project_id = 123456
		   and pct.creation_date > '01-FEB-2022'
		   -- and pct.project_id = 123456 and pct.line_type = 'O'
		   and 1 = 1;
