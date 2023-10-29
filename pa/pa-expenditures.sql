/*
File Name: pa-expenditures.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- PA EXPENDITURES - TABLE DUMPS
-- EXPENDITURE ITEMS - DETAILS
-- COUNT PER PROJECT AND EXPENDITURE TYPE
-- EXPENDITURE ITEMS LINKED TO COST ITEMS
-- ACCOUNTING SUMMARY sql
-- COUNT OF THE DIFFERENT "TRANSFER_STATUS_CODE" VALUES FROM THE PA_COST_DISTRIBUTION_LINES_ALL TABLE - VERSION 1
-- COUNT OF THE DIFFERENT "TRANSFER_STATUS_CODE" VALUES FROM THE PA_COST_DISTRIBUTION_LINES_ALL TABLE - VERSION 2
-- EXPENDITURE BATCHES
-- SUMMARY BY BATCH 1
-- SUMMARY BY BATCH 2
-- UNCOSTED BY BATCH - ALL
-- UNCOSTED BY BATCH - BY BATCH AND PROJECT
-- UNCOSTED BY BATCH - BY TRANSACTION SOURCE
-- UNCOSTED
-- SUMMARY PER PROJECT
-- FIND EXPENDITURE ITEMS WHICH HAVE NOT BEEN INCLUDED IN ANY REVENUES:
-- http://ravadaoa.blogspot.co.uk/2015/04/oracle-project-technical.html
-- EXPENDITURE ITEMS LINKED TO COST ITEMS AND AP INVOICES - 1
-- EXPENDITURE ITEMS LINKED TO COST ITEMS AND AP INVOICES - 2
-- TOTAL PER PROJECT
-- EXPENDITURE ITEMS - UNBILLED SUMMARY
-- EXPENDITURE ITEMS - UNBILLED SUMMARY - GROUPED BY TRANSACTION SOURCE
-- EXPENDITURE ITEMS LINKED TO INVENTORY TRANSACTIONS
-- EXPENDITURE BATCHES - CREATED BY USER
-- EXPENDITURE BATCHES - SUMMARY - CREATED BY USER
-- BATCH COUNT PER TRANSACTION SOURCE
-- REJECTED EXPENDITURE ITEMS
-- ATTEMPT TO MIRROR THE PSI SCREEN, COMPARE COST BUDGET WITH ACTUAL SPEND
-- REVENUE VS NON REVENUE - COUNT SUMMARY
-- EXPENDITURE ITEM VOLUMES 1
-- EXPENDITURE ITEM VOLUMES 2

*/

-- ##################################################################
-- PA EXPENDITURES - TABLE DUMPS
-- ##################################################################

select * from pa_expenditure_items_all; 
select * from pa_expenditure_items_all where expenditure_item_id in (123456, 123457); 
select * from pa_expenditure_groups_all where expenditure_group in ('Smelly Cheese Batch 123','Old Cheese Stock 456');
select * from pa_expenditures_all where expenditure_group in ('Smelly Cheese Batch 123','Old Cheese Stock 456');
select * from pa_expenditures_all;

-- ##################################################################
-- EXPENDITURE ITEMS - DETAILS
-- ##################################################################

		select peia.expenditure_item_id item_id
			 , ppa.segment1 project
			 , pt.task_number task
			 , peia.creation_date
			 , peia.last_update_date
			 , peia.transaction_source
			 , peia.expenditure_type
			 , peia.cost_distributed_flag
			 , ppa.project_id
			 , fu.user_name item_created_by
			 , peia.creation_date item_created
			 , peia.raw_cost
			 , peia.denom_raw_cost
			 , peia.quantity
			 , peia.net_zero_adjustment_flag
			 , peia.denom_currency_code
			 , peia.acct_currency_code
			 , ppa.name project_name
			 , peia.bill_rate
			 , peia.adjusted_expenditure_item_id
			 , peia.transferred_from_exp_item_id
			 , pega.expenditure_group batch
			 , haou3.name exp_batch_org
			 , pega.creation_date batch_created
			 , pega.request_id batch_request_id
			 , pea.creation_date exp_created
			 , pea.request_id exp_request_id
			 , pea.expenditure_id batch_id
			 , peia.request_id item_request_id
			 , nvl(peia.raw_cost, peia.quantity) item_value
			 , to_char (peia.expenditure_item_date, 'DD-MON-RRRR') item_date
			 , to_char (pea.expenditure_ending_date, 'DD-MON-RRRR') expenditure_ending_date
			 , pec.expenditure_comment
			 , peia.cost_dist_rejection_code
			 , rej.meaning || ' (' || rej.description || ')' rejection
			 , peia.revenue_hold_flag
			 , ppa.distribution_rule
			 , to_char(ppa.start_date, 'DD-MON-YYYY') project_start_date
			 , to_char(ppa.completion_date, 'DD-MON-YYYY') project_end_date
			 , pt.task_number task
			 , to_char(pt.start_date, 'DD-MON-YYYY') task_start_date
			 , to_char(pt.completion_date, 'DD-MON-YYYY') task_end_date
			 , case when peia.expenditure_item_date between ppa.start_date and ppa.completion_date then 'ok' else 'notokay' end pa_date_check
			 , case when (ppa.start_date is not null and ppa.completion_date is not null) then case when peia.expenditure_item_date between ppa.start_date and ppa.completion_date then 'ok' else 'notokay' end end pa_date_check
			 , case when (pt.start_date is not null and pt.completion_date is not null) then case when peia.expenditure_item_date between pt.start_date and pt.completion_date then 'ok' else 'notokay' end end task_date_check
			 , peia.billable_flag 
			 , peia.orig_transaction_reference -- perhaps for costs from ap invoices, this number is the request id for the prc: interface supplier costs job which created the expenditure item in projects
			 , haou2.name project_org
			 , haou.name task_org
			 , peia.document_header_id
			 , peia.document_distribution_id
			 , peia.adjusted_expenditure_item_id
			 , peia.transferred_from_exp_item_id
			 , peia.organization_id
		  from pa.pa_expenditure_items_all peia
		  join applsys.fnd_user fu on peia.last_updated_by = fu.user_id
	 left join pa_transaction_sources pts on peia.transaction_source = pts.transaction_source
		  join pa.pa_expenditures_all pea on peia.expenditure_id = pea.expenditure_id
		  join pa.pa_expenditure_groups_all pega on pega.expenditure_group = pea.expenditure_group
		  join pa.pa_projects_all ppa on peia.project_id = ppa.project_id
		  join pa.pa_tasks pt on peia.task_id = pt.task_id and ppa.project_id = pt.project_id
		  join pa.pa_expenditure_types pet on peia.expenditure_type = pet.expenditure_type
	 left join pa.pa_expenditure_comments pec on peia.expenditure_item_id = pec.expenditure_item_id
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join apps.hr_all_organization_units haou on pt.carrying_out_organization_id = haou.organization_id
		  join apps.hr_all_organization_units haou2 on ppa.carrying_out_organization_id = haou2.organization_id
		  join apps.hr_all_organization_units haou3 on pega.org_id = haou3.organization_id
	 left join apps.fnd_lookup_values_vl rej on peia.cost_dist_rejection_code = rej.lookup_code and rej.lookup_type = 'COST DIST REJECTION CODE' and rej.view_application_id = 275
		 where 1 = 1
		   and ppa.segment1 = 'P123456'
		   -- and pt.task_number = 'TASK.0001'
		   -- and fu.user_name = 'CHEESE_USER'
		   -- and peia.expenditure_type = 'Cheese Treats'
		   -- and peia.cost_distributed_flag = 'N'
		   and 1 = 1;

-- ##################################################################
-- COUNT PER PROJECT AND EXPENDITURE TYPE
-- ##################################################################

		select ppa.segment1
			 , peia.expenditure_type
			 , count(*)
			 , min(to_char(peia.creation_date, 'yyyy-mm-dd')) min_creation_date
			 , max(to_char(peia.creation_date, 'yyyy-mm-dd')) max_creation_date
		  from pa.pa_expenditure_items_all peia
		  join pa.pa_projects_all ppa on peia.project_id = ppa.project_id
		 where 1 = 1
		   and ppa.segment1 = 'P123456'
	  group by ppa.segment1
			 , peia.expenditure_type;

-- ##################################################################
-- EXPENDITURE ITEMS LINKED TO COST ITEMS
-- ##################################################################

		select peia.expenditure_item_id trans_id
			 , pcdla.line_num
			 , ppa.segment1 project
			 , ppa.project_id
			 , ppa.attribute2
			 , ppa.project_type
			 , haou2.name project_org
			 , haou3.name exp_batch_org
			 , peia.creation_date exp_item_created
			 , pcdla.creation_date pcdla_line_created
			 , peia.request_id exp_item_request_id
			 , pcdla.request_id pcdla_request_id
			 , pt.task_number task
			 , pt.task_id
			 , pt.task_name
			 , haou.name task_org
			 , pt.attribute2 task_attr2
			 , peia.transaction_source
			 , peia.expenditure_type
			 , pps.project_status_name status
			 , pea.expenditure_group batch
			 , pet.expenditure_category expend_type
			 , pts.gl_accounted_flag trx_source_gl_accounted_flag
			 , pcdla.transfer_status_code
			 , pl.meaning transfer_status
			 , pl.description transfer_status_description
			 , to_char (peia.expenditure_item_date, 'DD-MON-RRRR') exp_item_date
			 , to_char (peia.expenditure_item_date, 'DD-MON-RRRR') item_date
			 , to_char (pea.expenditure_ending_date, 'DD-MON-RRRR') expenditure_ending_date
			 , pec.expenditure_comment
			 , nvl(peia.raw_cost, peia.quantity) item_value
			 , peia.raw_cost
			 , peia.quantity
			 , peia.request_id exp_item_request_id
			 , gcc_cr.concatenated_segments dr
			 , gcc_dr.concatenated_segments cr
			 , pcdla.creation_date
			 , peia.document_header_id
		  from pa.pa_expenditure_items_all peia
		  join pa.pa_cost_distribution_lines_all pcdla on peia.expenditure_item_id = pcdla.expenditure_item_id
	 left join pa.pa_expenditures_all pea on peia.expenditure_id = pea.expenditure_id
		  join pa.pa_projects_all ppa on peia.project_id = ppa.project_id
		  join pa.pa_tasks pt on peia.task_id = pt.task_id and ppa.project_id = pt.project_id
		  join pa.pa_expenditure_types pet on peia.expenditure_type = pet.expenditure_type
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join apps.hr_all_organization_units haou on pt.carrying_out_organization_id = haou.organization_id
		  join apps.hr_all_organization_units haou2 on ppa.carrying_out_organization_id = haou2.organization_id
	 left join apps.hr_all_organization_units haou3 on pea.incurred_by_organization_id = haou3.organization_id
	 left join pa.pa_transaction_sources pts on peia.transaction_source = pts.transaction_source
	 left join pa.pa_expenditure_comments pec on peia.expenditure_item_id = pec.expenditure_item_id
	 left join apps.gl_code_combinations_kfv gcc_dr on pcdla.cr_code_combination_id = gcc_dr.code_combination_id
	 left join apps.gl_code_combinations_kfv gcc_cr on pcdla.dr_code_combination_id = gcc_cr.code_combination_id
	 left join apps.pa_lookups pl on pcdla.transfer_status_code = pl.lookup_code and pl.lookup_type = 'TRANSFER STATUS'
	 left join pa.pa_expenditure_comments pec on peia.expenditure_item_id = pec.expenditure_item_id
		 where 1 = 1
		   -- and peia.expenditure_item_id = 123456
		   -- and peia.expenditure_item_id in (123456,123457)
		   -- and peia.transaction_source = 'Cheese Interface'
		   and ppa.segment1 = 'P123456'
		   and peia.creation_date > '30-MAY-2022'
		   -- and to_char(peia.creation_date, 'yyyy-mm-dd') = '2021-06-02'
		   -- and peia.transaction_source = 'AP ERV'
		   -- and pts.gl_accounted_flag = 'N'
		   and 1 = 1
	  order by ppa.segment1
			 , peia.expenditure_item_id;

-- ##################################################################
-- ACCOUNTING SUMMARY sql
-- ##################################################################

/*
PA TRANSACTION SOURCE
-----------------------------
If gl_accounted_flag on transaction source has a value of "y":

EXPENDITURE ITEM ALREADY ACCOUNTED AS SOON AS IT IS CREATED (E.G. "AP INVOICE" TRANSACTION SOURCE")
MEANING PA_COST_DISTRIBUTION_LINES_ALL RECORD CREATED AT SAME TIME AS RECORD ON PA_EXPENDITURE_ITEMS_ALL
BOTH EXP ITEM AND COST LINE REQUEST_ID IS THE REQUEST_ID FOR THE "PRC: INTERFACE SUPPLIER COSTS" JOB

If gl_accounted_flag on transaction source has a value of "n":

EXPENDITURE ITEM IS NOT ACCOUNTED WHEN IT IS CREATED
MEANING PA_COST_DISTRIBUTION_LINES_ALL RECORD IS NOT CREATED AT SAME TIME AS RECORD ON PA_EXPENDITURE_ITEMS_ALL
THE EXP ITEM REQUEST ID = ID FOR "PRC: DISTRIBUTE USAGE AND MISCELLANEOUS COSTS"
THE COST LINE REQUEST ID = ID FOR "PRC: GENERATE COST ACCOUNTING EVENTS"

To determine how much "work" prc generate cost accounting events" job has to do:

LOOK AT RECORDS WHERE TRANSACTION SOURCE GL_ACCOUNTED_FLAG VALUE = "N".
COUNT DISTINCT DIFFERENT VALUES OF:
PA_COST_DISTRIBUTION_LINES_ALL.CR_CODE_COMBINATION_ID
PA_COST_DISTRIBUTION_LINES_ALL.DR_CODE_COMBINATION_ID

PA_COST_DISTRIBUTION_LINES_ALL.DR_CODE_COMBINATION_ID: POPULATED WHEN RUN "PRC: DISTRIBUTE USAGE AND MISCELLANEOUS COSTS"
PA_COST_DISTRIBUTION_LINES_ALL.CR_CODE_COMBINATION_ID: POPULATED WHEN RUN "PRC: GENERATE COST ACCOUNTING EVENTS"
*/

		select to_char(peia.creation_date, 'yyyy-mm-dd')
			 , peia.transaction_source
			 , pts.gl_accounted_flag
			 , decode(pts.gl_accounted_flag, 'Y','Pre-Accounted','N','Accounted via Jobs') accounting_check
			 , haou.name
			 , count(*) count_lines
			 , count(distinct pcdla.cr_code_combination_id) count_cr_code_combinations
			 , count(distinct pcdla.dr_code_combination_id) count_dr_code_combinations
			 , min(to_char(peia.creation_date, 'HH24')) min_creation_hour
			 , max(to_char(peia.creation_date, 'HH24')) max_creation_hour
		  from pa_projects_all ppa
		  join pa_tasks pt on pt.project_id = ppa.project_id
		  join pa_expenditure_items_all peia on peia.project_id = ppa.project_id and peia.task_id = pt.task_id
		  join pa_cost_distribution_lines_all pcdla on peia.expenditure_item_id = pcdla.expenditure_item_id
		  join pa_transaction_sources pts on peia.transaction_source = pts.transaction_source
	 left join pa.pa_expenditures_all pea on peia.expenditure_id = pea.expenditure_id
	 left join apps.hr_all_organization_units haou on pea.incurred_by_organization_id = haou.organization_id
		 where to_char(peia.creation_date, 'YYYY-MM-DD') > '2021-05-31'
		   and to_char(peia.creation_date, 'YYYY-MM-DD') < '2021-12-11'
		   -- and to_char(peia.creation_date, 'yyyy-mm-dd') = '2021-09-28'
		   and 1 = 1
	  group by to_char(peia.creation_date, 'YYYY-MM-DD')
			 , peia.transaction_source
			 , pts.gl_accounted_flag
			 , decode(pts.gl_accounted_flag, 'Y','Pre-Accounted','N','Accounted via Jobs')
			 , haou.name;

-- ##################################################################
-- COUNT OF THE DIFFERENT "TRANSFER_STATUS_CODE" VALUES FROM THE PA_COST_DISTRIBUTION_LINES_ALL TABLE - VERSION 1
-- ##################################################################

/*
VALUE OF THE TRANSFER_STATUS_CODE IS CONTROLLED BY THE SETUP OF THE TRANSACTION SOURCE FOR EACH EXPENDITURE ITEM. 
IF THE "RAW COST GL ACCOUNTED" BOX IS TICKED FOR A TRANSACTION SOURCE,
I THINK THAT MEANS THAT TRANSFER_STATUS_CODE = "V" AND NO FURTHER ACCOUNTING IS SENT TO GL FOR THE EXPENDITURE ITEM. 
I'VE CHECKED AGAINST SOME EXPENDITURE ITEMS WHERE TRANSFER_STATUS_CODE AND IN THOSE CASES, RAW COST GL ACCOUNT IS NOT TICKED.

ORACLE FEEDBACK ON SR - FOR AP ISSUE: GL / PA BALANCE MISMATCH

"ALL AP INVOICE TRANSACTIONS GET INTERFACED TO PROJECTS AS COSTED AND 
ACCOUNTED. THAT IS WHY ITS COST DISTRIBUTION LINE HAS A TRANSFER STATUS CODE 
OF V, BECAUSE ITS ACCOUNTED IN THE SOURCE MODULE, IN THIS CASE AP. PROJECTS 
DOES NOT SEND THESE COSTS BACK TO GL. THESE WOULD BE POSTED TO GL FROM AP. " 
*/

		select pcdla.transfer_status_code
			 , peia.transaction_source
			 , pts.user_transaction_source
			 , pts.gl_accounted_flag
			 , pts.skip_tc_validation_flag
			 , pts.modify_interface_flag
			 , pts.cc_process_flag
			 , count(*) ct
		  from pa.pa_cost_distribution_lines_all pcdla
		  join pa.pa_expenditure_items_all peia on pcdla.expenditure_item_id = peia.expenditure_item_id
		  join pa.pa_transaction_sources pts on pts.transaction_source = peia.transaction_source
		  join pa.pa_projects_all ppa on ppa.project_id = peia.project_id
		 where 1 = 1
		   -- and pcdla.creation_date > '01-JAN-2016'
		   -- and pts.transaction_source IN ('AP NRTAX','CHEESE')
		   and ppa.segment1 = 'P123456'
	  group by pcdla.transfer_status_code
			 , peia.transaction_source
			 , pts.user_transaction_source
			 , pts.gl_accounted_flag
			 , pts.skip_tc_validation_flag
			 , pts.modify_interface_flag
			 , pts.cc_process_flag;

-- ##################################################################
-- COUNT OF THE DIFFERENT "TRANSFER_STATUS_CODE" VALUES FROM THE PA_COST_DISTRIBUTION_LINES_ALL TABLE - VERSION 2
-- ##################################################################

		select pcdla.transfer_status_code
			 , pl.meaning
			 , pl.description
			 , peia.transaction_source
			 , sum(peia.project_raw_cost) total
			 , count(*) line_count
		  from pa.pa_cost_distribution_lines_all pcdla
		  join pa.pa_expenditure_items_all peia on pcdla.expenditure_item_id = peia.expenditure_item_id
		  join pa.pa_projects_all ppa on ppa.project_id = peia.project_id
		  join apps.pa_lookups pl on pcdla.transfer_status_code = pl.lookup_code AND pl.lookup_type = 'TRANSFER STATUS'
		   and ppa.segment1 = 'P123456'
	  group by pcdla.transfer_status_code
			 , peia.transaction_source
			 , pl.meaning
			 , pl.description;

-- ##################################################################
-- EXPENDITURE BATCHES
-- ##################################################################

		select fu.user_name
			 , hou.short_code org
			 , pea.*
		  from pa.pa_expenditures_all pea
		  join applsys.fnd_user fu on pea.created_by = fu.user_id
		  join apps.hr_operating_units hou on pea.org_id = hou.organization_id
		 where 1 = 1
		   and 1 = 1
	  order by pea.creation_date desc;

-- ##################################################################
-- SUMMARY BY BATCH 1
-- ##################################################################

		select peia.transaction_source
			 , pea.expenditure_group batch
			 , fu.user_name
			 , peia.cost_distributed_flag
			 , count (peia.expenditure_item_id)
			 , to_char(peia.creation_date, 'yyyy-mm-dd') creation_date
			 , sum(peia.denom_raw_cost) ttl
		  from pa.pa_expenditure_items_all peia
		  join pa.pa_expenditures_all pea on peia.expenditure_id = pea.expenditure_id
		  join pa.pa_projects_all ppa on peia.project_id = ppa.project_id
		  join applsys.fnd_user fu on pea.created_by = fu.user_id
		   -- and pea.expenditure_group like 'Test Journal 1PJ2573529%'
		   and fu.user_name = 'CHEESE_USER'
		   and peia.creation_date > '01-APR-2022'
	  group by peia.transaction_source
			 , pea.expenditure_group
			 , fu.user_name
			 , peia.cost_distributed_flag
			 , to_char(peia.creation_date, 'yyyy-mm-dd')
	  order by 5 desc;

-- ##################################################################
-- SUMMARY BY BATCH 2
-- ##################################################################

		select pea.expenditure_group
			 , count(peia.expenditure_item_id) exp_item_count
			 , min(peia.expenditure_item_id)
			 , max(peia.expenditure_item_id)
		  from pa_expenditures_all pea
	 left join pa_expenditure_items_all peia on peia.expenditure_id = pea.expenditure_id
		 where 1 = 1
		   and pea.expenditure_group in ('Smelly Cheese Batch 123','Old Cheese Stock 456')
		   and 1 = 1
	  group by pea.expenditure_group;

-- ##################################################################
-- UNCOSTED BY BATCH - ALL
-- ##################################################################

		select count (*)
		  from pa.pa_expenditure_items_all peia
		  join pa.pa_expenditures_all pea on peia.expenditure_id = pea.expenditure_id
		  join pa.pa_projects_all ppa on peia.project_id = ppa.project_id
		 where peia.cost_distributed_flag = 'N'
		   and peia.bill_hold_flag = 'N'
		   and peia.billable_flag = 'Y';

-- ##################################################################
-- UNCOSTED BY BATCH - BY BATCH AND PROJECT
-- ##################################################################

		select peia.transaction_source
			 , pea.expenditure_group batch
			 , ppa.segment1
			 , count(*)
			 , trunc(peia.creation_date) creation_date
			 , sum(peia.denom_raw_cost) ttl
		  from pa.pa_expenditure_items_all peia
		  join pa.pa_expenditures_all pea on peia.expenditure_id = pea.expenditure_id
		  join pa.pa_projects_all ppa on peia.project_id = ppa.project_id
		 where 1 = 1
		   and peia.cost_distributed_flag = 'N'
		   and peia.bill_hold_flag = 'N'
		   and ppa.segment1 = 'P123456'
		-- having count (*) > 1000
	  group by peia.transaction_source
			 , pea.expenditure_group
			 , ppa.segment1
			 , trunc (peia.creation_date)
	  order by 3 desc;

-- ##################################################################
-- UNCOSTED BY BATCH - BY TRANSACTION SOURCE
-- ##################################################################

		select peia.transaction_source
			 , count (*)
		  from pa.pa_expenditure_items_all peia
		  join pa.pa_expenditures_all pea on peia.expenditure_id = pea.expenditure_id
		  join pa.pa_projects_all ppa on peia.project_id = ppa.project_id
		 where peia.cost_distributed_flag = 'N'
		   and peia.bill_hold_flag = 'N'
	  group by peia.transaction_source
	  order by 2 desc;

-- ##################################################################
-- UNCOSTED
-- ##################################################################

		select sum (peia.denom_raw_cost) total
			 , peia.transaction_source
			 , count (*) ct
			 , to_char (peia.expenditure_item_date, 'MON-RRRR') month_name
		  from pa.pa_expenditure_items_all peia
		 where peia.cost_distributed_flag = 'N'
		   and peia.project_id = 123456
		   -- and peia.transaction_source = 'PAYROLL'
	  group by peia.transaction_source
			 , to_char (peia.expenditure_item_date, 'MON-RRRR');

-- ##################################################################
-- SUMMARY PER PROJECT
-- ##################################################################

		select ppa.project_id
			 , ppa.segment1 project
			 , ppa.carrying_out_organization_id
			 -- , peia.transaction_source
			 -- , peia.bill_rate
			 , sum(peia.raw_cost) sum_raw_cost
			 , sum(peia.denom_raw_cost) sum_denom_raw_cost
			 , min(peia.creation_date)
			 , max(peia.creation_date)
			 , count(*) ct
		  from pa.pa_expenditure_items_all peia
		  join pa.pa_projects_all ppa on peia.project_id = ppa.project_id
		 where ppa.segment1 in ('P123456','P123457')
	  group by ppa.project_id
			 -- , peia.transaction_source
			 -- , peia.bill_rate
			 , ppa.segment1
			 , ppa.carrying_out_organization_id;

-- ##################################################################
-- FIND EXPENDITURE ITEMS WHICH HAVE NOT BEEN INCLUDED IN ANY REVENUES:
-- http://ravadaoa.blogspot.co.uk/2015/04/oracle-project-technical.html
-- ##################################################################

		select * 
		  from pa.pa_expenditure_items_all peia 
		 where project_id = 123456
		   and peia.expenditure_item_id not in (select expenditure_item_id 
												  from pa.pa_cust_rev_dist_lines_all pcrdla 
												 where project_id = 123456);

-- ##################################################################
-- EXPENDITURE ITEMS LINKED TO COST ITEMS AND AP INVOICES - 1
-- ##################################################################

		select ppa.segment1 proj
			 , ppa.project_id
			 , peia.expenditure_item_id item_id
			 , peia.system_linkage_function
			 , peia.transaction_source
			 , aia.invoice_id inv_id 
			 , aia.creation_date inv_created
			 , '#' || aia.invoice_num inv_num
			 , aia.invoice_currency_code curr
			 , pega.expenditure_group batch
			 , pega.creation_date batch_created
			 , peia.creation_date item_created
			 , aia.doc_sequence_value
			 , aia.invoice_amount inv_amount
			 , aia.cancelled_amount inv_cancel_amt
			 , peia.raw_cost
			 , peia.quantity item_qty
			 , peia.request_id
			 , to_char(aia.invoice_date, 'DD-MON-RRRR') inv_date
			 , to_char(peia.expenditure_item_date, 'DD-MON-RRRR') exp_date
			 , to_char(pega.expenditure_ending_date, 'DD-MON-RRRR') batch_date
			 , pv.vendor_name supplier
			 , pv.segment1 supp_num
			 , peia.project_id
			 , aida.amount
			 , aida.invoice_distribution_id
			 , aia.invoice_id
			 , aia.creation_date inv_created
			 , aida.expenditure_item_date
			 , aia.last_update_date
			 , aida.creation_date aida_created
			 , aida.last_update_date aida_updated
			 , aida.pa_addition_flag
			 , pcdla.transfer_status_code
			 , pl.meaning transfer_status
			 , pcdla.transfer_rejection_reason
			 , peia.transaction_source src
			 , peia.adjusted_expenditure_item_id
			 , pcdla.creation_date pc_created
			 , pcdla.transfer_status_code
			 , peia.request_id peia_req
			 , pcdla.request_id pc_req
			 , peia.capital_event_id
			 , pcdla.cr_code_combination_id
			 , pcdla.dr_code_combination_id
			 -- , '##################'
			 -- , aida.*
		  from pa.pa_expenditure_items_all peia
		  join pa.pa_expenditures_all pea on peia.expenditure_id = pea.expenditure_id
		  join pa_expenditure_groups_all pega on pega.expenditure_group = pea.expenditure_group
		  join pa.pa_cost_distribution_lines_all pcdla on peia.expenditure_item_id = pcdla.expenditure_item_id
		  join pa.pa_expenditures_all pea on peia.expenditure_id = pea.expenditure_id
		  join pa.pa_projects_all ppa on peia.project_id = ppa.project_id
		  join pa.pa_tasks pt on peia.task_id = pt.task_id and ppa.project_id = pt.project_id
		  join ap.ap_invoices_all aia on peia.document_header_id = aia.invoice_id
		  join ap.ap_invoice_distributions_all aida on peia.document_distribution_id = aida.invoice_distribution_id and aia.invoice_id = aida.invoice_id
	 left join apps.pa_lookups pl on pcdla.transfer_status_code = pl.lookup_code and pl.lookup_type = 'TRANSFER STATUS'
		  join ap.ap_suppliers pv on aia.vendor_id = pv.vendor_id
		 where 1 = 1
		   and ppa.segment1 in ('P123456')
		   -- and peia.expenditure_item_id = 123456
		   -- and peia.expenditure_item_id in (123456, 123457)
		   -- and aia.invoice_id in (111,222,333)
		   -- and peia.creation_date > '02-FEB-2022'
		   -- and peia.request_id in (123456, 909090)
	  order by ppa.segment1
			 , '#' || aia.invoice_num;

-- ##################################################################
-- EXPENDITURE ITEMS LINKED TO COST ITEMS AND AP INVOICES - 2
-- ##################################################################

		select aia.invoice_id
			 , aia.invoice_num
			 , ppa.segment1 project
			 , aida.creation_date inv_distrib_created
			 , tbl_pa.meaning || ' (' || aida.pa_addition_flag || ')' pa_addition
			 , aida.invoice_distribution_id
			 , aida.parent_reversal_id
			 , aida.cancellation_flag
			 , aida.amount
			 , aida.total_dist_amount
			 , aida.pa_quantity
			 , aida.distribution_line_number
			 , aida.invoice_line_number
			 , aida.match_status_flag
			 , aida.posted_flag
			 , aida.line_type_lookup_code dist_line_type
			 , aida.period_name dist_period
			 , to_char(aida.accounting_date, 'DD-MON-YYYY') dist_gl_date
			 , peia.expenditure_item_id
			 , peia.transaction_source
			 , peia.creation_date exp_item_created
			 , peia.raw_cost
		  from ap.ap_invoices_all aia
		  join ap.ap_invoice_distributions_all aida on aia.invoice_id = aida.invoice_id
	 left join pa.pa_projects_all ppa on aida.project_id = ppa.project_id
		  join (select lookup_code, meaning from fnd_lookup_values_vl where lookup_type = 'PA_ADDITION_FLAG') tbl_pa on tbl_pa.lookup_code = aida.pa_addition_flag
	 left join pa.pa_expenditure_items_all peia on peia.document_distribution_id = aida.invoice_distribution_id and aia.invoice_id = aida.invoice_id
		 where 1 = 1
		   and ppa.segment1 in ('P123456')
		   -- and peia.expenditure_item_id = 123456
		   -- and peia.expenditure_item_id in (123456, 123457)
		   -- and aia.invoice_id in (111,222,333)
		   -- and peia.creation_date > '02-FEB-2022'
		   -- and peia.request_id in (123456, 909090)
		   and 1 = 1;

-- ##################################################################
-- TOTAL PER PROJECT
-- ##################################################################

		select ppa.segment1
			 , count(*) ct
			 , sum(peia.raw_cost) ttl_raw_cost
			 , sum(peia.denom_raw_cost) ttl_denom_raw_cost
		  from pa.pa_expenditure_items_all peia
		  join pa.pa_projects_all ppa on peia.project_id = ppa.project_id
		  join pa.pa_tasks pt on peia.task_id = pt.task_id and ppa.project_id = pt.project_id
		 where 1 = 1
		   and ppa.segment1 in ('P123456')
	  group by ppa.segment1;

-- ##################################################################
-- EXPENDITURE ITEMS - UNBILLED SUMMARY
-- ##################################################################

		select e.project
			 , e.task
			 , e.name
			 , sum(amt) unbilled_amount
			 , count(*) unbilled_transaction_count
		  from (select ppa.segment1 project
					 , pt.task_number task
					 , pt.task_name name
					 , peia.denom_raw_cost amt
				  from pa.pa_expenditure_items_all peia 
				  join pa.pa_expenditures_all pea on peia.expenditure_id = pea.expenditure_id
				  join pa.pa_projects_all ppa on peia.project_id = ppa.project_id
				  join pa.pa_tasks pt on peia.task_id = pt.task_id and ppa.project_id = pt.project_id
				  join pa.pa_expenditure_types pet on peia.expenditure_type = pet.expenditure_type
				  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
			 left join pa.pa_expenditure_comments pec on peia.expenditure_item_id = pec.expenditure_item_id
			 left join pa.pa_cust_rev_dist_lines_all pcrdla on peia.expenditure_item_id = pcrdla.expenditure_item_id
				 where 1 = 1
				   and ppa.segment1 in ('P123456')
				   and peia.billable_flag = 'Y'
				   and peia.bill_hold_flag = 'N'
				   and pcrdla.expenditure_item_id is null) e
	  group by e.project
			 , e.task
			 , e.name;

-- ##################################################################
-- EXPENDITURE ITEMS - UNBILLED SUMMARY - GROUPED BY TRANSACTION SOURCE
-- ##################################################################

		select e.src
			 , sum(amt) unbilled_amount
			 , count(*) unbilled_transaction_count
		  from (select peia.transaction_source src
					 , peia.denom_raw_cost amt
				  from pa.pa_expenditure_items_all peia 
				  join pa.pa_expenditures_all pea on peia.expenditure_id = pea.expenditure_id
				  join pa.pa_projects_all ppa on peia.project_id = ppa.project_id
				  join pa.pa_tasks pt on peia.task_id = pt.task_id ppa.project_id = pt.project_id
				  join pa.pa_expenditure_types pet on peia.expenditure_type = pet.expenditure_type
				  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
			 left join pa.pa_expenditure_comments pec on peia.expenditure_item_id = pec.expenditure_item_id
			 left join pa.pa_cust_rev_dist_lines_all pcrdla on peia.expenditure_item_id = pcrdla.expenditure_item_id
				 where 1 = 1
				   and ppa.segment1 in ('P123456')
				   and peia.billable_flag = 'Y'
				   and peia.bill_hold_flag = 'N'
				   and pcrdla.expenditure_item_id is null) e
	  group by e.src;

-- ##################################################################
-- EXPENDITURE ITEMS LINKED TO INVENTORY TRANSACTIONS
-- ##################################################################

		select pea.expenditure_group batch
			 , peia.transaction_source
			 , to_char (peia.expenditure_item_date, 'DD-MON-RRRR') exp_item_date
			 , peia.creation_date
			 , ppa.segment1 project_num
			 , pt.task_number
			 , pet.expenditure_category expend_type
			 , peia.unit_of_measure uom
			 , peia.quantity
			 , pec.expenditure_comment comment_
			 , fu.user_name created_by
			 , fu.description
			 , pcdla.transferred_date tx_date
			 , '-------- CHG_ACCTS ------------'
			 , gcc_dr.segment1 ||'*'|| gcc_dr.segment2 ||'*'|| gcc_dr.segment3 ||'*'|| gcc_dr.segment4 ||'*'|| gcc_dr.segment5 ||'*'|| gcc_dr.segment6 debit
			 , gcc_cr.segment1 ||'*'|| gcc_cr.segment2 ||'*'|| gcc_cr.segment3 ||'*'|| gcc_cr.segment4 ||'*'|| gcc_cr.segment5 ||'*'|| gcc_cr.segment6 credit
		  from pa.pa_expenditure_items_all peia
		  join pa.pa_expenditures_all pea on peia.expenditure_id = pea.expenditure_id
		  join pa.pa_projects_all ppa on peia.project_id = ppa.project_id
		  join pa.pa_tasks pt on peia.task_id = pt.task_id and ppa.project_id = pt.project_id
		  join pa.pa_expenditure_types pet on peia.expenditure_type = pet.expenditure_type
		  join pa.pa_cost_distribution_lines_all pcdla on peia.expenditure_item_id = pcdla.expenditure_item_id
		  join inv.mtl_material_transactions mmt on peia.project_id = mmt.source_project_id and peia.orig_transaction_reference = to_char (mmt.transaction_id) and peia.task_id = mmt.source_task_id
		  join applsys.fnd_user fu on mmt.created_by = fu.user_id
	 left join pa.pa_expenditure_comments pec on peia.expenditure_item_id = pec.expenditure_item_id
	 left join gl.gl_code_combinations gcc_dr on pcdla.dr_code_combination_id = gcc_dr.code_combination_id
	 left join gl.gl_code_combinations gcc_cr on pcdla.cr_code_combination_id = gcc_cr.code_combination_id
		 where 1 = 1
		   and ppa.segment1 = 'P123456'
		   and 1 = 1;

-- ##################################################################
-- EXPENDITURE BATCHES - CREATED BY USER
-- ##################################################################

		select fu.description cr_by
			 , pega.creation_date cr_dt
			 , pega.expenditure_group batch
			 , pega.expenditure_group_status_code status
			 , pega.expenditure_ending_date end_dt
			 , pega.system_linkage_function type_
			 , pega.transaction_source src_
		  from pa.pa_expenditure_groups_all pega
		  join applsys.fnd_user fu on pega.created_by = fu.user_id
		 where 1 = 1
		   -- and pega.creation_date between '18-APR-2016' and '22-APR-2016'
		   -- and pega.creation_date > '01-JUN-2016'
		   and fu.user_name = 'CHEESE_USER'
	  order by pega.creation_date desc;

-- ##################################################################
-- EXPENDITURE BATCHES - SUMMARY - CREATED BY USER
-- ##################################################################

		select pea.expenditure_group batch
			 , trunc(pea.creation_date) creation_date
			 , peia.transaction_source
			 , pts.batch_size
			 , fu.description
			 , count (*) ct
			 , sum (peia.raw_cost) ttl
		  from pa.pa_expenditure_items_all peia
		  join pa.pa_expenditures_all pea on peia.expenditure_id = pea.expenditure_id
		  join pa.pa_projects_all ppa on peia.project_id = ppa.project_id
		  join pa.pa_transaction_sources pts on peia.transaction_source = pts.transaction_source
		  join applsys.fnd_user fu on pea.created_by = fu.user_id
		 where 1 = 1
		   and pea.creation_date between '18-APR-2016' and '22-APR-2016'
		   and fu.user_name = 'CHEESE_USER'
	  group by pea.expenditure_group
			 , fu.description
			 , peia.transaction_source
			 , pts.batch_size
			 , trunc(pea.creation_date)
	  order by 6 desc;

-- ##################################################################
-- BATCH COUNT PER TRANSACTION SOURCE
-- ##################################################################

		select pega.transaction_source
			 , max (pega.creation_date) max_date
			 , count (*) ct
		  from pa.pa_expenditure_groups_all pega
		 where pega.transaction_source = 'PAYROLL'
	  group by transaction_source
	  order by 1;

-- ##################################################################
-- REJECTED EXPENDITURE ITEMS
-- ##################################################################

		select pei.cost_dist_rejection_code
			 , ppa.segment1
			 , ppa.name
			 , pt.task_number
			 , pei.expenditure_type
			 , to_char (pei.expenditure_item_date, 'DD-MON-RRRR') exp_item_date
			 , pei.quantity
			 , pei.raw_cost
			 , pei.denom_raw_cost
			 , pei.cost_distributed_flag
			 , pea.expenditure_group
			 , pei.transaction_source
			 , pei.attribute_category
			 , pei.attribute1
			 , pei.attribute2
			 , pei.attribute5
			 , pec.expenditure_comment
			 , pei.expenditure_item_id
			 , pei.creation_date
		  from pa.pa_expenditure_items_all pei
		  join pa.pa_projects_all ppa on pei.project_id = ppa.project_id
		  join pa.pa_tasks pt on pei.task_id = pt.task_id -- and ppa.project_id = pr.project_id
		  join pa.pa_expenditures_all pea on pei.expenditure_id = pea.expenditure_id
	 left join pa.pa_expenditure_comments pec on pei.expenditure_item_id = pec.expenditure_item_id
		 where pei.cost_dist_rejection_code is not null
		   and ppa.segment1 = 'P123456'
		   -- and pei.cost_dist_rejection_code <> 'NO_PA_DATE'
		   -- and pei.cost_dist_rejection_code <> 'PA_NO_PROJECT_CURR_RATE'
		   and 1 = 1;

-- ##################################################################
-- ATTEMPT TO MIRROR THE PSI SCREEN, COMPARE COST BUDGET WITH ACTUAL SPEND
-- ##################################################################

		select ppa.segment1 project
			 , pt.task_number task
			 , pt.task_name
			 , pt.chargeable_flag chg_flag
			 , tbl_budget.budget_type
			 , tbl_budget.burdened_cost cost
			 , tbl_budget.revenue revenue
			 , (select sum(peia.raw_cost) from pa.pa_expenditure_items_all peia where peia.project_id = ppa.project_id and peia.task_id = pt.task_id) expenditure_total
		  from pa.pa_projects_all ppa
			 , pa.pa_tasks pt
			 , (select pt.task_id
					 , pbl.burdened_cost
					 , pbl.revenue
					 , decode(pbv.budget_type_code, 'AR', 'Approved Revenue Budget', 'AC', 'Approved Cost Budget') budget_type
				  from pa.pa_budget_versions pbv
				  join pa.pa_projects_all ppa on pbv.project_id = ppa.project_id
				  join pa.pa_budget_lines pbl on pbv.budget_version_id = pbl.budget_version_id
				  join pa.pa_resource_assignments pra on pbl.resource_assignment_id = pra.resource_assignment_id
				  join pa.pa_tasks pt on pra.task_id = pt.task_id and ppa.project_id = pt.project_id
				 where 1 = 1
				   and ppa.segment1 = 'P123456'
				   and pbv.budget_status_code = 'W') tbl_budget
		 where ppa.project_id = pt.project_id
		   and pt.task_id = tbl_budget.task_id(+)
		   and ppa.segment1 = 'P123456'
	  order by pt.task_number;

-- #########################################################################################
-- REVENUE VS NON REVENUE - COUNT SUMMARY
-- #########################################################################################

		select pea.expenditure_id
			 , pea.expenditure_group batch_name
			 , pea.creation_date
			 , case when peia.orig_transaction_reference like '%REV%' then 'REV' else 'ORIG' end rev_check
			 , count(*) item_count
		  from pa.pa_expenditure_items_all peia
		  join pa.pa_expenditures_all pea on peia.expenditure_id = pea.expenditure_id
		  join pa.pa_projects_all ppa on peia.project_id = ppa.project_id
		  join pa.pa_tasks pt on peia.task_id = pt.task_id and ppa.project_id = pt.project_id
		 where 1 = 1
		   -- and pea.expenditure_id in (123456, 123457, 123458)
		   -- and pea.creation_date > '01-NOV-2018'
		   and pea.expenditure_group = 'Very Good Cheese Batch'
		   and 1 = 1
	  group by pea.expenditure_id
			 , pea.expenditure_group
			 , pea.creation_date
			 , case when peia.orig_transaction_reference like '%REV%' then 'REV' else 'ORIG' end
	  order by pea.expenditure_id
			 , pea.creation_date;

-- ##################################################################
-- EXPENDITURE ITEM VOLUMES 1
-- ##################################################################

		select to_char(creation_date, 'yyyy-mm-dd')
			 , count(*)
		  from pa_expenditure_items_all
		 where to_char(creation_date, 'yyyy-mm-dd') > '2021-07-31'
	  group by to_char(creation_date, 'yyyy-mm-dd')
	  order by to_char(creation_date, 'yyyy-mm-dd') desc;

-- ##################################################################
-- EXPENDITURE ITEM VOLUMES 2
-- ##################################################################

		select haou.organization_id
			 , haou.name org
			 , peia.cost_distributed_flag
			 -- , fu.user_name
			 , to_char(peia.creation_date, 'yyyy-mm-dd') creation_date
			 , min(peia.expenditure_type)
			 , max(peia.expenditure_type)
			 , min(peia.creation_date)
			 , max(peia.creation_date) 
			 , min(peia.expenditure_item_date)
			 , max(peia.expenditure_item_date) 
			 , count(distinct peia.expenditure_item_id) expenditure_count
			 , count(distinct pcdla.cr_code_combination_id) cr_code_combs
			 , count(distinct pcdla.dr_code_combination_id) dr_code_combs
		  from pa_expenditure_items_all peia
	 left join pa.pa_cost_distribution_lines_all pcdla on peia.expenditure_item_id = pcdla.expenditure_item_id
		  join apps.hr_all_organization_units haou on haou.organization_id = peia.org_id
		  join apps.fnd_user fu on fu.user_id = peia.created_by
		 where 1 = 1
		   and peia.creation_date > '18-MAY-2022'
	  group by haou.organization_id
			 , haou.name
			 , peia.cost_distributed_flag
			 -- , fu.user_name
			 , to_char(peia.creation_date, 'yyyy-mm-dd')
	  order by haou.organization_id
			 , haou.name
			 , to_char(peia.creation_date, 'yyyy-mm-dd') desc;
