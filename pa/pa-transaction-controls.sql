/*
File Name: pa-transaction-controls.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- TRANSACTION CONTROLS
-- ##################################################################

		select ppa.segment1 project
			 , pt.task_number
			 , pt.task_id
			 , haou.name org
			 , ppta.project_type proj_type
			 , ptc.chargeable_flag
			 , ptc.expenditure_category
			 , ptc.expenditure_type
			 , to_char(ptc.start_date_active, 'DD-MON-YYYY') control_start_date
			 , to_char(ptc.end_date_active, 'DD-MON-YYYY') control_end_date
			 , ptc.creation_date
			 , fu1.user_name created_by
			 , fu1.email_address created_by_email
			 , ptc.last_update_date
			 , fu2.user_name updated_by
		  from pa_projects_all ppa
		  join pa_transaction_controls ptc on ppa.project_id = ptc.project_id
		  join fnd_user fu1 on ptc.created_by = fu1.user_id
		  join fnd_user fu2 on ptc.last_updated_by = fu2.user_id
	 left join pa.pa_project_types_all ppta on ppa.project_type = ppta.project_type and ppa.org_id = ppta.org_id
	 left join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
	 left join pa.pa_tasks pt on ppa.project_id = pt.project_id and pt.task_id = ptc.task_id
		 where 1 = 1
		   and ppa.segment1 = 'P123456'
		   -- and pt.task_number = 'Professional Services'
		   and pt.task_id = 123456
		   -- and ptc.expenditure_type = 'Contract Staff-Long Term'
		   and 1 = 1;
