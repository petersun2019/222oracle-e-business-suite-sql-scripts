/*
File Name:		pa-agreements.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- PA - BUDGETS - TABLE DUMPS
-- PA - BUDGET HEADERS - VERSION 1
-- PA - BUDGET HEADERS - VERSION 2
-- PA - BUDGET HEADERS - VERSION 3
-- PA - BUDGET HEADER AND LINES - SUMMARY 1
-- PA - BUDGET HEADER AND LINES - SUMMARY 2
-- PA - BUDGET HEADER AND LINES - SUMMARY 3 - FROM SR (PRE-APPROVED - THE TRANSACTION FAILED FUNDS CHECK AT THE PROJECT LEVEL)
-- PA - BUDGET HEADER AND LINES - SUMMARY 4
-- PA - BUDGET HEADER AND LINES - SUMMARY 5
-- PA - BUDGET LINES 1
-- PA - BUDGET LINES 2
-- PA - BUDGET LINES 3
-- PA - BUDGETS AND BALANCES - SUMMARY 1 (SQL FROM ORACLE SR)
-- PA - BUDGETS AND BALANCES - SUMMARY 2 (SQL FROM ORACLE SR)
-- PA - BUDGETS AND BALANCES - SUMMARY 3 (SQL FROM ORACLE SR)
-- PA - BUDGETS AND BALANCES - SUMMARY 4 (SQL FROM ORACLE SR)
-- PA - RESOURCE ASSIGNMENTS
-- PA - BUDGET WITH RESOURCE ASSIGNMENTS

*/

-- ##################################################################
-- PA - BUDGETS - TABLE DUMPS
-- ##################################################################

select * from pa_budget_versions where version_name = '2022 Cheese Budget' and raw_cost = 123.45;
select * from pa_budget_versions where project_id = 123456;
select * from pa_budget_lines where to_date('10-SEP-2017', 'DD-MON-YYYY') between start_date and end_date;
select * from pa_budget_lines where resource_assignment_id in (select resource_assignment_id from pa_resource_assignments where project_id = 123456) and to_date('10-SEP-2017', 'DD-MON-YYYY') between start_date and end_date;
select * from pa_resource_assignments where project_id = 123456 and task_id = 987654;
select * from pa_resource_list_members;
select * from pa_trx_funds_chk_det_v where bc_packet_id = 123456 and (packet_id='18380999');
select * from pa_trx_funds_chk_det_v where project_id = 123456;

-- ##################################################################
-- PA - BUDGET HEADERS - VERSION 1
-- ##################################################################

		select ppa.segment1 
			 , ppa.name
			 , fu.user_name
			 , fu.email_address
			 , pbv.budget_version_id
			 , pbv.version_number
			 , pbv.current_flag
			 , pbv.budget_status_code
			 , pbv.creation_date
		  from pa_projects_all ppa
		  join pa_budget_versions pbv on pbv.project_id = ppa.project_id
		  join fnd_user fu on fu.user_id = pbv.created_by
		 where 1 = 1
		   and ppa.segment1 = 'P123456'
		   -- and pbv.current_flag = 'Y'
		   -- and pbv.budget_status_code = 'B'
		   -- and pbv.creation_date > '01-JAN-2022' 
		   -- and fu.user_name = 'CHEESE_USER'
		   and 1 = 1
	  order by pbv.creation_date desc;

-- ##################################################################
-- PA - BUDGET HEADERS - VERSION 2
-- ##################################################################

		select ppa.segment1
			 , ppa.project_id
			 , decode(pbv.budget_type_code, 'AR', 'Approved Revenue Budget', 'AC', 'Approved Cost Budget') budget_type
			 , fu.user_name || ' (' || fu.email_address || ')' created_by
			 , pbv.*
		  from pa.pa_budget_lines pbl
		  join pa.pa_resource_assignments pra on pbl.resource_assignment_id = pra.resource_assignment_id
		  join pa.pa_budget_versions pbv on pbl.budget_version_id = pbv.budget_version_id
		  join pa.pa_projects_all ppa on pbl.resource_assignment_id = pra.resource_assignment_id and ppa.project_id = pbv.project_id and ppa.project_id = pra.project_id
		  join applsys.fnd_user fu on pbv.created_by = fu.user_id
		 where 1 = 1 
		   and ppa.segment1 = 'P123456'
		   and pbv.budget_status_code = 'W'
		   -- and pbv.creation_date between '01-sep-2018' and '09-oct-2018'
		   -- and budget_type_code = 'AR'
		   and 1 = 1;

-- ##################################################################
-- PA - BUDGET HEADERS - VERSION 3
-- ##################################################################

		select hou.short_code "operating unit"
			 , ppa.segment1 project
			 , ppa.project_id
			 , ppa.name project_name
			 , pbv.budget_version_id
			 , pbv.version_number budget_version
			 , pbv.budget_status_code
			 , to_char(pbv.creation_date, 'DD-MM-YYYY HH24:MI:SS') budget_created
			 , fu.user_name budget_created_by
			 , pbv.current_flag
			 , pbv.current_original_flag
			 , to_char(pbv.baselined_date, 'DD-MM-YYYY HH24:MI:SS') budget_baselinedy
			 , pbv.change_reason_code
			 , pbv.raw_cost
			 , pbv.wf_status_code
			 , pbv.pm_product_code
			 , pbv.burdened_cost
			 , pbv.description
			 , pbv.created_by
		  from pa_projects_all ppa
		  join pa_budget_versions pbv on ppa.project_id = pbv.project_id
		  join fnd_user fu on pbv.created_by = fu.user_id
	 left join apps.hr_operating_units hou on ppa.org_id = hou.organization_id
		 where 1 = 1
		   -- and pbv.budget_type_code = 'AC'
		   -- and ppa.segment1 = '123456'
		   and (pbv.current_flag = 'Y' or pbv.current_original_flag = 'Y')
		   -- and to_char(pbv.creation_date, 'DD-MM-YYYY') = '27-11-2020'
		   -- and ppa.project_id in (123456,123457)
		   and ppa.segment1 in ('P123456')
		   -- and fu.user_name = 'CHEESE_USER'
		   -- and ppa.project_id in (select project_id from pa_budget_versions pbv2 where created_by = 123456 and to_char(creation_date, 'DD-MM-YYYY') = '27-11-2020')
		   and 1 = 1;

-- ##################################################################
-- PA - BUDGET HEADER AND LINES - SUMMARY 1
-- ##################################################################

/*
Revenue budgets are held against top task level only
Cost budgets are held against lower task levels
*/

		select ppa.segment1
			 , ppa.project_id
			 , decode(pbv.budget_type_code, 'AR', 'Approved Revenue Budget', 'AC', 'Approved Cost Budget') budget_type
			 , pbv.version_name
			 , pbv.description
			 , pbv.budget_type_code
			 , pbv.last_update_date
			 , pbv.creation_date
			 , fu.user_name || ' (' || fu.email_address || ')' created_by
			 , sum(pbl.revenue) revenue_total
			 , sum(pbl.burdened_cost) cost_total
			 , count(*) budget_lines
		  from pa.pa_budget_lines pbl
		  join pa.pa_resource_assignments pra on pbl.resource_assignment_id = pra.resource_assignment_id
		  join pa.pa_budget_versions pbv on pbl.budget_version_id = pbv.budget_version_id
		  join pa.pa_projects_all ppa on pbl.resource_assignment_id = pra.resource_assignment_id and ppa.project_id = pbv.project_id and ppa.project_id = pra.project_id
		  join applsys.fnd_user fu on pbv.created_by = fu.user_id
		 where 1 = 1 
		   and ppa.segment1 in ('P123456')
		   -- and ppa.segment1 in ('P123456','P123457')
		   and pbv.budget_status_code = 'W'
		   -- and pbv.creation_date between '01-sep-2018' and '09-oct-2018'
		   -- and budget_type_code = 'AR'
	  group by ppa.segment1
			 , ppa.project_id
			 , pbv.version_name
			 , pbv.description
			 , pbv.budget_type_code
			 , pbv.last_update_date
			 , decode(pbv.budget_type_code, 'AR', 'Approved Revenue Budget', 'AC', 'Approved Cost Budget')
			 , pbv.creation_date
			 , fu.user_name || ' (' || fu.email_address || ')';

-- ##################################################################
-- PA - BUDGET HEADER AND LINES - SUMMARY 2
-- ##################################################################

		select ppa.segment1
			 , ppa.project_id
			 , ppa.project_status_code
			 , to_char(ppa.start_date, 'DD-MON-YYYY') start_date
			 , to_char(ppa.completion_date, 'DD-MON-YYYY') end_date
			 , sum(pbl.burdened_cost) cost_total
		  from pa_projects_all ppa
		  join pa_budget_versions pbv on pbv.project_id = ppa.project_id
		  join pa_budget_lines pbl on pbl.budget_version_id = pbv.budget_version_id
		 where 1 = 1
		   and ppa.segment1 = 'P123456'
		   and pbv.current_flag = 'Y'
		   and pbv.budget_status_code = 'B'
		   -- and sysdate between ppa.start_date and ppa.completion_date
		   and 1 = 1
	  group by ppa.segment1
			 , ppa.project_id
			 , ppa.project_status_code
			 , to_char(ppa.start_date, 'DD-MON-YYYY')
			 , to_char(ppa.completion_date, 'DD-MON-YYYY');

-- ##################################################################
-- PA - BUDGET HEADER AND LINES - SUMMARY 3 - FROM SR (PRE-APPROVED - THE TRANSACTION FAILED FUNDS CHECK AT THE PROJECT LEVEL)
-- ##################################################################

		select prj.segment1 project_number
			 , prj.name
			 , prj.project_id
			 , prj.project_status_code
			 , hou.short_code org
			 , ppta.project_type proj_type
			 , flv_amount_type.meaning amount_type
			 , flv_boundary_code.meaning boundary_code
			 , flv_fnd_proj.meaning level_project
			 , flv_fnd_task.meaning level_task
			 , flv_fnd_resr.meaning level_resource
			 , flv_fnd_resg.meaning level_res_group
			 , (select max(creation_date) from pa_expenditure_items_all peia where peia.project_id = prj.project_id) latest_exp_item
			 , sum(bal.budget_period_to_date) budget
			 , sum(bal.actual_period_to_date) actuals
			 , sum(bal.encumb_period_to_date) encumbrances
			 , (sum(bal.budget_period_to_date) - sum(bal.actual_period_to_date) - sum(bal.encumb_period_to_date)) availablefunds
		  from pa.pa_bc_balances bal
			 , pa.pa_projects_all prj
			 , pa.pa_budget_versions bv
			 , hr_operating_units hou
			 , pa_budgetary_control_options pbco
			 , pa_project_types_all ppta
			 , fnd_lookup_values_vl flv_amount_type
			 , fnd_lookup_values_vl flv_boundary_code
			 , fnd_lookup_values_vl flv_fnd_proj
			 , fnd_lookup_values_vl flv_fnd_task
			 , fnd_lookup_values_vl flv_fnd_resr
			 , fnd_lookup_values_vl flv_fnd_resg
		 where bal.project_id = prj.project_id
		   and bal.budget_version_id = bv.budget_version_id
		   and bv.project_id = bal.project_id
		   and hou.organization_id = prj.carrying_out_organization_id
		   and prj.project_id = pbco.project_id
		   and prj.project_type = ppta.project_type
		   and prj.org_id = ppta.org_id
		   and pbco.amount_type = flv_amount_type.lookup_code and flv_amount_type.lookup_type = 'FUNDS_CONTROL_AMOUNT_TYPE' and flv_amount_type.view_application_id = 275
		   and pbco.boundary_code = flv_boundary_code.lookup_code and flv_boundary_code.lookup_type = 'BOUNDARY_CODE' and flv_boundary_code.view_application_id = 275
		   and pbco.fund_control_level_project = flv_fnd_proj.lookup_code and flv_fnd_proj.lookup_type = 'FUNDS_CONTROL_LEVEL_CODE' and flv_fnd_proj.view_application_id = 275
		   and pbco.fund_control_level_task = flv_fnd_task.lookup_code and flv_fnd_task.lookup_type = 'FUNDS_CONTROL_LEVEL_CODE' and flv_fnd_task.view_application_id = 275
		   and pbco.fund_control_level_res = flv_fnd_resr.lookup_code and flv_fnd_resr.lookup_type = 'FUNDS_CONTROL_LEVEL_CODE' and flv_fnd_resr.view_application_id = 275
		   and pbco.fund_control_level_res_grp = flv_fnd_resg.lookup_code and flv_fnd_resg.lookup_type = 'FUNDS_CONTROL_LEVEL_CODE' and flv_fnd_resg.view_application_id = 275
		   -- and bv.budget_status_code = 'W'
		   -- and bv.current_flag = 'Y'
		   and prj.segment1 in ('P123456')
		   -- and prj.project_id = 123456
		   -- and bv.budget_version_id = 123456
		   -- and bv.budget_version_id = (select max(pra2.budget_version_id) from pa_resource_assignments pra2 where pra2.project_id = prj.project_id)
	  group by prj.segment1
			 , prj.name
			 , prj.project_id
			 , prj.project_status_code
			 , hou.short_code
			 , ppta.project_type
			 , flv_amount_type.meaning
			 , flv_boundary_code.meaning
			 , flv_fnd_proj.meaning
			 , flv_fnd_task.meaning
			 , flv_fnd_resr.meaning
			 , flv_fnd_resg.meaning
		having (sum(bal.budget_period_to_date) - sum(bal.actual_period_to_date) - sum(bal.encumb_period_to_date)) < 0 and sum(bal.budget_period_to_date) > 0;

-- ##################################################################
-- PA - BUDGET HEADER AND LINES - SUMMARY 4
-- ##################################################################

		select ppa.segment1 project
			 , ppa.project_id
			 , pt.task_number task
			 , to_char(pbl.start_date, 'DD-MON-YYYY') budget_start_date
			 , to_char(pbl.end_date, 'DD-MON-YYYY') budget_end_date
			 , pbl.burdened_cost
			 , sum(bal.budget_period_to_date) budget
			 , sum(bal.actual_period_to_date) actuals
			 , sum(bal.encumb_period_to_date) encumbrances
			 , (sum(bal.budget_period_to_date) - sum(bal.actual_period_to_date) - sum(bal.encumb_period_to_date)) availablefunds
		  from pa_resource_assignments pra
		  join pa_budget_lines pbl on pbl.resource_assignment_id = pra.resource_assignment_id
		  join pa_projects_all ppa on ppa.project_id = pra.project_id
		  join pa_tasks pt on pt.task_id = pra.task_id
		  join hr_operating_units hou on hou.organization_id = ppa.carrying_out_organization_id
		  join pa.pa_bc_balances bal on bal.project_id = ppa.project_id and bal.budget_version_id = (select max(pra2.budget_version_id) from pa_resource_assignments pra2 where pra2.task_id = pra.task_id and pra2.project_id = pra.project_id)
		 where 1 = 1
		   and pra.budget_version_id = (select max(pra2.budget_version_id) from pa_resource_assignments pra2 where pra2.task_id = pra.task_id and pra2.project_id = pra.project_id)
		   -- and pra.project_id = 123456
		   and ppa.segment1 in ('P123456')
		   -- and pbl.budget_version_id = 123456
		   -- and pbl.burdened_cost <> 0
	  group by ppa.segment1
			 , ppa.project_id
			 , pt.task_number
			 , to_char(pbl.start_date, 'DD-MON-YYYY')
			 , to_char(pbl.end_date, 'DD-MON-YYYY')
			 , pbl.burdened_cost;

-- ##################################################################
-- PA - BUDGET HEADER AND LINES - SUMMARY 5
-- ##################################################################

		select ppa.segment1 project
			 , pt.task_number task
			 , pt.task_name
			 , pbv.raw_cost
			 , pbv.version_number
			 , pbv.current_flag
			 , sum(pbl.burdened_cost) cost_total
			 , '#########'
			 , pt.creation_date task_created
			 , pt.last_update_date task_updated
			 , pbv.creation_date budget_created
		  from pa_resource_assignments pra
		  join pa_resource_list_members prlm on pra.resource_list_member_id = prlm.resource_list_member_id
		  join pa_projects_all ppa on pra.project_id = ppa.project_id
		  join pa_tasks pt on pra.task_id = pt.task_id
		  join pa_budget_versions pbv on pra.budget_version_id = pbv.budget_version_id
		  join pa_budget_lines pbl on pbl.budget_version_id = pbv.budget_version_id
		 where 1 = 1
		   -- and pra.project_id = 123456
		   and ppa.segment1 = 'P123456'
		   -- and pbv.budget_version_id = 123456
		   and 1 = 1
	  group by ppa.segment1
			 , pt.task_number
			 , pt.task_name
			 , pt.creation_date
			 , pt.last_update_date
			 , pbv.creation_date
			 , pbv.raw_cost
			 , pbv.version_number
			 , pbv.current_flag;

-- ##################################################################
-- PA - BUDGET LINES 1
-- ##################################################################

		select ppa.segment1 project
			 -- , pbv.*
			 , bl.burden_cost_rate
			 , bl.burden_cost_rate_override
			 , bl.project_cost_exchange_rate
			 , bl.project_cost_rate_date
			 , bl.project_cost_rate_date_type
			 , bl.project_cost_rate_type
			 , bl.project_rev_exchange_rate
			 , bl.project_rev_rate_date
			 , bl.project_rev_rate_date_type
			 , bl.project_rev_rate_type
			 , bl.projfunc_cost_exchange_rate
			 , bl.projfunc_cost_rate_date
			 , bl.projfunc_cost_rate_date_type
			 , bl.projfunc_cost_rate_type
			 , bl.projfunc_rev_exchange_rate
			 , bl.projfunc_rev_rate_date
			 , bl.projfunc_rev_rate_date_type
			 , bl.projfunc_rev_rate_type
			 , bl.transfer_price_rate
			 , bl.txn_bill_rate_override
			 , bl.txn_cost_rate_override
			 , bl.txn_standard_bill_rate
			 , bl.txn_standard_cost_rate
		  from pa_budget_lines bl
		  join pa_budget_versions pbv on pbv.budget_version_id = bl.budget_version_id
		  join pa_projects_all ppa on pbv.project_id = ppa.project_id
		 where 1 = 1
		   and ppa.segment1 = 'P123456'
		   and bl.budget_version_id in (select bv.budget_version_id 
										  from pa_budget_versions bv
										 where bv.project_id = ppa.project_id
										   and bv.budget_type_code in (select budget_type_code
																		 from pa_budgetary_control_options
																		where project_id = ppa.project_id))
	  order by bl.budget_version_id
			 , bl.resource_assignment_id
			 , bl.start_date;

-- ##################################################################
-- PA - BUDGET LINES 2
-- ##################################################################

		select ppa.segment1 project
			 , ppa.project_id
			 , decode(pbv.budget_type_code, 'AR', 'Approved Revenue Budget', 'AC', 'Approved Cost Budget') budget_type
			 , pt.task_number task
			 , pt.task_name
			 , pbl.creation_date
			 , pbl.last_update_date
			 , to_char(pbl.start_date, 'DD-MON-YYYY') start_date
			 , to_char(pbl.end_date, 'DD-MON-YYYY') end_date
			 , pbl.period_name
			 , pbl.raw_cost
			 , pbl.revenue
			 , pbl.burdened_cost
			 , pbl.pm_product_code
			 , '##########################'
			 , pbl.*
		  from pa.pa_budget_versions pbv
		  join pa.pa_projects_all ppa on pbv.project_id = ppa.project_id
		  join pa.pa_budget_lines pbl on pbv.budget_version_id = pbl.budget_version_id
		  join pa.pa_resource_assignments pra on pra.resource_assignment_id = pbl.resource_assignment_id
		  join pa.pa_tasks pt on pt.task_id = pra.task_id and ppa.project_id = pt.project_id
		 where 1 = 1
		   and ppa.segment1 = 'P123456'
		   -- and pbv.budget_type_code = 'AR'
		   -- and pbv.budget_status_code = 'W'
		   and pbv.budget_status_code = 'B'
		   and pbv.current_flag = 'Y'
	  order by task_number;

-- ##################################################################
-- PA - BUDGET LINES 3
-- ##################################################################

		select ppa.segment1 project
			 , ppa.project_id
			 , pt.task_number task
			 , pra.task_id
			 , to_char(pbl.start_date, 'DD-MON-YYYY') budget_start_date
			 , to_char(pbl.end_date, 'DD-MON-YYYY') budget_end_date
			 , pbl.burdened_cost
		  from pa_resource_assignments pra
		  join pa_budget_lines pbl on pbl.resource_assignment_id = pra.resource_assignment_id
		  join pa_projects_all ppa on ppa.project_id = pra.project_id
		  join pa_tasks pt on pt.task_id = pra.task_id
		 where pra.budget_version_id = (select max(pra2.budget_version_id) from pa_resource_assignments pra2 where pra2.task_id = pra.task_id and pra2.project_id = pra.project_id)
		   and ppa.segment1 in ('P123456')
		   and pbl.burdened_cost <> 0;

-- ##################################################################
-- PA - BUDGETS AND BALANCES - SUMMARY 1 (SQL FROM ORACLE SR)
-- ##################################################################

		select prj.segment1 project_number
			 , sum(bal.actual_period_to_date) actuals
			 , sum(bal.encumb_period_to_date) encumbrances
			 , sum(bal.budget_period_to_date) budget
			 , (sum(bal.budget_period_to_date) - sum(bal.actual_period_to_date) - sum(bal.encumb_period_to_date)) availablefunds
		  from apps.pa_bc_balances bal
			 , apps.pa_projects_all prj
			 , apps.pa_budget_versions bv
		 where bal.project_id = prj.project_id
		   and bal.budget_version_id = bv.budget_version_id
		   and bv.project_id = bal.project_id
		   and bv.budget_status_code = 'B'
		   and bv.current_flag = 'Y'
		   and prj.project_id = 123456
	  group by prj.segment1;

-- ##################################################################
-- PA - BUDGETS AND BALANCES - SUMMARY 2 (SQL FROM ORACLE SR)
-- ##################################################################

		select prj.segment1 project_number
			 , prj.start_date
			 , prj.completion_date
			 , prj.project_id
			 , task.task_number
			 , task.task_name
			 , bal.task_id task_id
			 , sum(bal.actual_period_to_date) actuals
			 , sum(bal.encumb_period_to_date) encumbrances
			 , sum(bal.budget_period_to_date) budget
			 , (sum(bal.budget_period_to_date) - sum(bal.actual_period_to_date) - sum(bal.encumb_period_to_date)) availablefunds
		  from apps.pa_bc_balances bal
			 , apps.pa_tasks task
			 , apps.pa_projects_all prj
			 , apps.pa_budget_versions bv
		 where bal.project_id = prj.project_id
		   and task.task_id = bal.task_id
		   and bal.budget_version_id = bv.budget_version_id
		   and bv.project_id = bal.project_id
		   and bv.budget_status_code = 'B'
		   and bv.current_flag = 'Y'
		   and prj.project_id = 123456
	  group by prj.segment1
			 , prj.project_id
			 , bal.task_id
			 , task.task_number
			 , task.task_name
			 , prj.start_date
			 , prj.completion_date
	  order by prj.segment1
			 , bal.task_id; 

-- ##################################################################
-- PA - BUDGETS AND BALANCES - SUMMARY 3 (SQL FROM ORACLE SR)
-- ##################################################################

		select prj.segment1 project_number
			 , prj.project_id
			 , bal.resource_list_member_id
			 , rl.alias
			 , sum(bal.actual_period_to_date) actuals
			 , sum(bal.encumb_period_to_date) encumbrances
			 , sum(bal.budget_period_to_date) budget
			 , (sum(bal.budget_period_to_date) - sum(bal.actual_period_to_date) - sum(bal.encumb_period_to_date)) availablefunds
		  from apps.pa_bc_balances bal
			 , apps.pa_tasks task
			 , apps.pa_projects_all prj
			 , apps.pa_budget_versions bv
			 , apps.pa_resource_list_members rl
		 where bal.project_id = prj.project_id
		   and task.task_id = bal.task_id
		   and bal.budget_version_id = bv.budget_version_id
		   and bv.project_id = bal.project_id
		   and bv.budget_status_code = 'B'
		   and bv.current_flag = 'Y'
		   and prj.project_id = 123456
		   and bal.resource_list_member_id=rl.resource_list_member_id
	  group by prj.segment1
			 , prj.project_id
			 , bal.resource_list_member_id
			 , rl.alias
	  order by prj.segment1
			 , bal.resource_list_member_id; 

-- ##################################################################
-- PA - BUDGETS AND BALANCES - SUMMARY 4 (SQL FROM ORACLE SR)
-- ##################################################################

		select prj.segment1 project_number
			 , prj.project_id
			 , rl.parent_member_id
			 , sum(bal.actual_period_to_date) actuals
			 , sum(bal.encumb_period_to_date) encumbrances
			 , sum(bal.budget_period_to_date) budget
			 , (sum(bal.budget_period_to_date) - sum(bal.actual_period_to_date) - sum(bal.encumb_period_to_date)) availablefunds
		  from apps.pa_bc_balances bal
			 , apps.pa_tasks task
			 , apps.pa_projects_all prj
			 , apps.pa_budget_versions bv
			 , apps.pa_resource_list_members rl
		 where bal.project_id = prj.project_id
		   and task.task_id = bal.task_id
		   and bal.budget_version_id = bv.budget_version_id
		   and bv.project_id = bal.project_id
		   and bv.budget_status_code = 'B'
		   and bv.current_flag = 'Y'
		   and prj.project_id = 123456
		   and bal.resource_list_member_id=rl.resource_list_member_id
	  group by prj.segment1
			 , prj.project_id
			 , rl.parent_member_id
	  order by prj.segment1
			 , rl.parent_member_id;

-- ##################################################################
-- PA - RESOURCE ASSIGNMENTS
-- ##################################################################

		select ppa.segment1
			 , pt.task_number
			 , pt.task_id
			 , count(resource_assignment_id)
		  from pa_resource_assignments pra
		  join pa_projects_all ppa on pra.project_id = ppa.project_id
		  join pa_tasks pt on ppa.project_id = pt.project_id and pra.task_id = pt.task_id
		 where ppa.segment1 = '123456'
	  group by ppa.segment1
			 , pt.task_number
			 , pt.task_id;

-- ##################################################################
-- PA - BUDGET WITH RESOURCE ASSIGNMENTS
-- ##################################################################

		select ppa.segment1 project
			 , pt.task_number task
			 , pt.task_name
			 , '##############'
			 , pbv.version_number
			 , pbv.budget_status_code
			 , pbv.original_flag
			 , pbv.current_flag
			 , pbv.current_original_flag
			 , pbv.baselined_date
			 , pbv.raw_cost
			 , pbv.first_budget_period
			 , '##############'
			 , prlm.alias resource_member_name
			 , '##############'
		  from pa_resource_assignments pra
		  join pa_resource_list_members prlm on pra.resource_list_member_id = prlm.resource_list_member_id
		  join pa_projects_all ppa on pra.project_id = ppa.project_id
		  join pa_tasks pt on pra.task_id = pt.task_id
		  join pa_budget_versions pbv on pra.budget_version_id = pbv.budget_version_id
		 where 1 = 1
		   -- and pra.project_id = 123456
		   and ppa.segment1 = 'P123456'
		   -- and pbv.budget_version_id = 123456
		   and 1 = 1;
