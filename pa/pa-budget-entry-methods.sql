/*
File Name: pa-budget-entry-methods.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- BUDGET ENTRY METHODS - TABLE DUMPS
-- BUDGET ENTRY METHODS - SUMMARY 1
-- BUDGET ENTRY METHODS - SUMMARY 2
-- BUDGET ENTRY METHODS - DETAILS AGAINST A PROJECT

*/

-- ##################################################################
-- BUDGET ENTRY METHODS - TABLE DUMPS
-- ##################################################################

select * from pa.pa_budget_entry_methods;

-- ##################################################################
-- BUDGET ENTRY METHODS - SUMMARY 1
-- ##################################################################

		select pbem.budget_entry_method_code
			 , pbem.budget_entry_method
			 , pbem.creation_date
			 , pbem.start_date_active
			 , pbem.end_date_active
			 , tbl_ct.ct
			 , tbl_ct_open.ct ct_open
			 , tbl_ct.latest
		  from pa.pa_budget_entry_methods pbem
			 , (select pbem.budget_entry_method_code
					 , count (*) ct
					 , max(pbv.creation_date) latest
				  from pa.pa_budget_versions pbv
				  join pa.pa_budget_entry_methods pbem on pbv.budget_entry_method_code = pbem.budget_entry_method_code
				  join pa.pa_projects_all ppa on pbv.project_id = ppa.project_id
				  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
				 where budget_type_code = 'AC'
				   and budget_status_code in ('W', 'S')
				   and version_number = 1
			  group by pbem.budget_entry_method_code) tbl_ct
			 , (select pbem.budget_entry_method_code
					 , count(*) ct
					 , max(pbv.creation_date) latest
				  from pa.pa_budget_versions pbv
				  join pa.pa_budget_entry_methods pbem on pbv.budget_entry_method_code = pbem.budget_entry_method_code
				  join pa.pa_projects_all ppa on pbv.project_id = ppa.project_id
				  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
				 where budget_type_code = 'AC'
				   and budget_status_code in ('W', 'S')
				   and version_number = 1
				   and pps.project_status_name not like '%Closed%'
			  group by pbem.budget_entry_method_code) tbl_ct_open 
		 where pbem.budget_entry_method_code = tbl_ct.budget_entry_method_code(+)
		   and pbem.budget_entry_method_code = tbl_ct_open.budget_entry_method_code(+)
	  order by pbem.budget_entry_method_code;

-- ##################################################################
-- BUDGET ENTRY METHODS - SUMMARY 2
-- ##################################################################

		select pbem.budget_entry_method_code
			 , count (*) ct
		  from pa.pa_budget_versions pbv
		  join pa.pa_budget_entry_methods pbem on pbv.budget_entry_method_code = pbem.budget_entry_method_code
	  group by pbem.budget_entry_method_code;

-- ##################################################################
-- BUDGET ENTRY METHODS - DETAILS AGAINST A PROJECT
-- ##################################################################

		select ppa.segment1, ppa.project_id
			 , pbt.budget_type
			 , pps.project_status_name status
			 , pbem.budget_entry_method
			 , pbv.creation_date
			 , pbv.version_number
			 , pbv.budget_status_code
		  from pa.pa_budget_versions pbv
		  join pa.pa_budget_entry_methods pbem on pbv.budget_entry_method_code = pbem.budget_entry_method_code
		  join pa.pa_projects_all ppa on ppa.project_id = pbv.project_id
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join pa.pa_budget_types pbt on pbv.budget_type_code = pbt.budget_type_code
		 where segment1 = 'P123456'
		   -- and budget_type_code = 'AC'
		   -- and budget_status_code in ('W', 'S')
		   -- and version_number = 1
		   -- and pbv.budget_status_code = 'B'
		   -- and pbem.budget_entry_method = 'Task Level Baseline'
	  order by pbv.creation_date desc;
