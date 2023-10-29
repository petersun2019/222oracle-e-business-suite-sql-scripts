/*
File Name:		pa-bc-balances.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- PA BALANCES
-- PA BALANCES - SUMMARY
-- PA BALANCES - SQL FROM SR

*/

-- ##################################################################
-- PA BALANCES
-- ##################################################################

		select ppa.segment1 project
			 , ppa.project_id
			 , pt.task_number task
			 , pbc.*
		  from pa_bc_balances pbc 
		  join pa.pa_projects_all ppa on pbc.project_id = ppa.project_id
		  join pa.pa_tasks pt on pbc.task_id = pt.task_id and ppa.project_id = pt.project_id
		  join pa_budget_versions pbv on ppa.project_id = pbv.project_id and pbv.budget_version_id = pbc.budget_version_id
		 where 1 = 1
		   and ppa.project_id in (123456)
		   -- and ppa.project_id in (123456,123457)
		   and pbv.current_flag = 'Y'
		   and 1 = 1;

-- ##################################################################
-- PA BALANCES - SUMMARY
-- ##################################################################

		select ppa.segment1 project
			 , ppa.project_id
			 , sum(pbc.actual_period_to_date)
		  from pa_bc_balances pbc 
		  join pa.pa_projects_all ppa on pbc.project_id = ppa.project_id
		  join pa_budget_versions pbv on ppa.project_id = pbv.project_id and pbv.budget_version_id = pbc.budget_version_id
		 where 1 = 1
		   and ppa.project_id in (123456)
		   -- and ppa.project_id in (123456,123457)
		   and pbv.current_flag = 'Y'
		   and 1 = 1
	  group by ppa.segment1
			 , ppa.project_id;

-- ##################################################################
-- PA BALANCES - SQL FROM SR
-- ##################################################################

/* ####################################################################
PA BALANCES - SR
BUDGETARY FUND CHECK RESULTS: FUNDS CONSUMED AMOUNT IS TOO LOW AT HEADER (ACTUALS ARE TOO LOW) - DETAILS ARE FINE (DOC ID 2057115.1)
ORACLE SUPPORT SEARCH: PAXBLRSL ACTUAL INCORRECT
DATE: 05-JAN-2022
-- ##################################################################*/

		select ppa.project_id
			 , ppa.segment1 project
			 , tbl_pa_bc.sum_exp_items
			 , tbl_pa_bc.count_exp_items
			 , tbl_pa_exp_items.sum_balances
			 , tbl_pa_exp_items.count_balance_lines
		  from pa.pa_projects_all ppa
		  join (select project_id
					 , sum(raw_cost) sum_exp_items
					 , count(*) count_exp_items
				  from pa.pa_expenditure_items_all
			  group by project_id) tbl_pa_bc on tbl_pa_bc.project_id = ppa.project_id
		  join (select pbc.project_id
					 , sum(pbc.actual_period_to_date) sum_balances
					 , count(*) count_balance_lines
				  from pa_bc_balances pbc 
				  join pa_budget_versions pbv on pbc.project_id = pbv.project_id and pbv.budget_version_id = pbc.budget_version_id
				 where pbv.current_flag = 'Y'
			  group by pbc.project_id) tbl_pa_exp_items on tbl_pa_exp_items.project_id = ppa.project_id
		 where 1 = 1
		   and ppa.project_id in (123456,123457)
		   and 1 = 1;
