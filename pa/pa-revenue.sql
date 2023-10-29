/*
File Name: pa-revenue.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- PA REVENUE - TABLE DUMPS
-- DRAFT REVENUES AGAINST PROJECT
-- DRAFT REVENUES AND REVENUE ITEMS AGAINST PROJECT
-- EXPENDITURE REVENUE TABLE (PA_CUST_REV_DIST_LINES_ALL)
-- EXPENDITURE ITEMS AND EXPENDITURE REVENUE TABLE

*/

-- ###################################################################
-- PA REVENUE - TABLE DUMPS
-- ###################################################################

select * from pa_draft_revenues_all;
select * from pa_draft_revenue_items;
select * from pa_cust_rev_dist_lines_all;

-- ##################################################################
-- DRAFT REVENUES AGAINST PROJECT
-- ##################################################################

		select ppa.segment1 proj
			 , ppa.project_id
			 , ppa.distribution_rule
			 , fu.user_name created_by
			 , pdra.draft_revenue_num rev_num
			 , (select count(*) from pa.pa_draft_revenue_items pdri where pdra.draft_revenue_num = pdri.draft_revenue_num and pdra.project_id = pdri.project_id) item_ct
			 , pdra.creation_date
			 , pdra.transfer_status_code trx_status
			 , pdra.generation_error_flag gen_error_flag
			 , pdra.event_id
			 , pdra.pa_date
			 , pdra.accrue_through_date
			 , pdra.released_date
			 , pdra.transferred_date
			 , pdra.unbilled_receivable_dr
			 , pdra.unearned_revenue_cr
			 , pdra.event_id
			 , paa.agreement_num
			 , hp.party_name
			 , hca.account_number
			 , gcc_rx.concatenated_segments unbilled_receivable
			 , gcc_rev.concatenated_segments unearned_revenue
			 -- , '######################'
			 -- , pdra.*
		  from pa.pa_draft_revenues_all pdra
	 left join pa.pa_projects_all ppa on pdra.project_id = ppa.project_id
	 left join applsys.fnd_user fu on pdra.created_by = fu.user_id
	 left join pa.pa_agreements_all paa on paa.agreement_id = pdra.agreement_id
	 left join ar.hz_cust_accounts hca on paa.customer_id = hca.cust_account_id
	 left join ar.hz_parties hp on hp.party_id = hca.party_id
	 left join apps.gl_code_combinations_kfv gcc_rx on gcc_rx.code_combination_id = pdra.unbilled_code_combination_id
	 left join apps.gl_code_combinations_kfv gcc_rev on gcc_rev.code_combination_id = pdra.unearned_code_combination_id
		 where 1 = 1
		   -- and ppa.segment1 in ('P123456')
		   -- and ppa.project_id = 123456
		   -- and pdra.draft_revenue_num = 123
		   -- and pdra.event_id is null
		   -- and pdra.event_id = 123456
		   and pdra.creation_date >= '26-JUL-2022'
		   -- and hp.party_name = 'CHEESE CORP'
	  order by pdra.creation_date desc;

-- ##################################################################
-- DRAFT REVENUES AND REVENUE ITEMS AGAINST PROJECT
-- ##################################################################

		select ppa.segment1
			 , ppa.name
			 , ppa.project_id
			 , pdra.event_id
			 , pdra.draft_revenue_num
			 , pdra.creation_date cr_dt
			 , pdra.transfer_status_code
			 , pdra.transfer_status_code
			 , pdra.transferred_date
			 , pdra.transfer_rejection_reason
			 , fu.description cr_by
			 , pt.task_id
			 , pt.task_number
			 , pt.task_name
			 , pt.ready_to_bill_flag
			 , pt.ready_to_distribute_flag 
			 , pt.parent_task_id
			 , '###############################################'
			 , pdri.*
		  from pa.pa_draft_revenue_items pdri
		  join pa.pa_draft_revenues_all pdra on pdra.draft_revenue_num = pdri.draft_revenue_num and pdra.project_id = pdri.project_id
		  join pa.pa_projects_all ppa on pdri.project_id = ppa.project_id
	 left join pa.pa_tasks pt on pdri.task_id = pt.task_id and pt.project_id = ppa.project_id
		  join applsys.fnd_user fu on pdra.created_by = fu.user_id 
		 where 1 = 1
		   -- and ppa.segment1 in ('P123456')
		   -- and ppa.project_id = 123456
		   -- and pdra.draft_revenue_num = 123
		   -- and pdra.event_id is null
		   -- and pdra.event_id = 123456
		   and pdra.creation_date >= '26-JUL-2022'
		   -- and hp.party_name = 'CHEESE CORP'
		   and pdri.revenue_source = 'Cheese'
		   and pdra.transfer_status_code = 'P'
	  order by pdri.creation_date desc;

-- ##################################################################
-- EXPENDITURE REVENUE TABLE (PA_CUST_REV_DIST_LINES_ALL)
-- ##################################################################

		select ppa.segment1
			 , ppa.name
			 , ppa.project_id
			 , pdra.event_id
			 , pdra.draft_revenue_num
			 , pdra.creation_date cr_dt
			 , pdra.transfer_status_code
			 , pdra.transfer_status_code
			 , pdra.transferred_date
			 , pdra.transfer_rejection_reason
			 , fu.description cr_by
			 , pt.task_id
			 , pt.task_number
			 , pt.task_name
			 , pt.ready_to_bill_flag , pt.ready_to_distribute_flag 
			 , pt.parent_task_id
			 , '###############################################'
			 , pcrdla.*
			 , '###############################################'
		  from pa.pa_draft_revenue_items pdri
		  join pa.pa_draft_revenues_all pdra on pdra.draft_revenue_num = pdri.draft_revenue_num and pdra.project_id = pdri.project_id
		  join pa.pa_projects_all ppa on pdri.project_id = ppa.project_id
		  join pa.pa_tasks pt on pdri.task_id = pt.task_id and pt.project_id = ppa.project_id
		  join applsys.fnd_user fu on pdra.created_by = fu.user_id
		  join pa.pa_cust_rev_dist_lines_all pcrdla on pcrdla.draft_revenue_num = pdri.draft_revenue_num and pcrdla.draft_revenue_item_line_num = pdri.line_num and pcrdla.project_id = ppa.project_id and pcrdla.project_id = pdra.project_id
		 where 1 = 1
		   and ppa.segment1 in ('P123456')
		   -- and ppa.project_id = 123456
		   and pdra.draft_revenue_num = 123
		   -- and pdra.event_id is null
		   -- and pdra.event_id = 123456
	  order by pdri.creation_date desc;

-- ##################################################################
-- EXPENDITURE ITEMS AND EXPENDITURE REVENUE TABLE
-- ##################################################################

		select ppa.segment1 project
			 , pt.task_number task
			 , ppa.project_id
			 , peia.creation_date item_created
			 , peia.expenditure_item_id item_id
			 , pega.expenditure_group batch
			 , pega.creation_date batch_created
			 , pea.creation_date exp_created
			 , pea.request_id exp_request_id
			 , peia.request_id item_request_id
			 , nvl(peia.raw_cost, peia.quantity) item_value
			 , to_char (peia.expenditure_item_date, 'DD-MON-RRRR') item_date
			 , to_char (pea.expenditure_ending_date, 'DD-MON-RRRR') expenditure_ending_date
			 , peia.transaction_source
			 , peia.expenditure_type
			 , pt.task_number task
			 , peia.orig_transaction_reference
		  from pa.pa_expenditure_items_all peia
		  join pa.pa_expenditures_all pea on peia.expenditure_id = pea.expenditure_id
		  join pa.pa_expenditure_groups_all pega on pega.expenditure_group = pea.expenditure_group
		  join pa.pa_projects_all ppa on peia.project_id = ppa.project_id
		  join pa.pa_tasks pt on peia.task_id = pt.task_id and ppa.project_id = pt.project_id
		  join pa.pa_expenditure_types pet on peia.expenditure_type = pet.expenditure_type
		  join pa.pa_cust_rev_dist_lines_all pcrdla on pcrdla.expenditure_item_id = peia.expenditure_item_id
		 where 1 = 1
		   and ppa.segment1 in ('P123456')
		   -- and ppa.project_id = 123456
		   and pdra.draft_revenue_num = 123
		   -- and pdra.event_id is null
		   -- and pdra.event_id = 123456
		   and 1 = 1
	  order by peia.creation_date desc;
