/*
File Name: pa-project-types.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- PROJECT TYPES - DETAILS
-- PROJECT TYPES - WITH BUDGETARY CONTROL OPTIONS
-- PROJECT TYPES - SUMMARY 1
-- PROJECT TYPES - SUMMARY 2

*/

-- ##################################################################
-- PROJECT TYPES - DETAILS
-- ##################################################################

		select ppta.project_type project_type
			 , ppta.*
			 , ppta.service_type_code
			 , ppta.project_type_class_code
			 , tbl_svc_type.meaning svc_type
			 , ppta.creation_date
			 , ppta.attribute1 uo_project_type
			 , fu.user_name || ' (' || fu.email_address || ')' created_by
		  from pa.pa_project_types_all ppta
	 left join (select lookup_code, meaning from apps.pa_lookups where lookup_type = 'SERVICE TYPE') tbl_svc_type on ppta.service_type_code = tbl_svc_type.lookup_code
	 left join applsys.fnd_user fu on ppta.created_by = fu.user_id
		 where 1 = 1
		   and ppta.project_type = 'Cheese Plan'
		   and 1 = 1
	  order by 1;

-- ##################################################################
-- PROJECT TYPES - WITH BUDGETARY CONTROL OPTIONS
-- ##################################################################

		select ppta.project_type
			 , ppta.creation_date
			 , ppta.start_date_active
			 , ppta.end_date_active
			 , ppta.burden_cost_flag
			 , pbco.*
		  from pa.pa_project_types_all ppta
	 left join pa.pa_budgetary_control_options pbco on ppta.project_type = pbco.project_type;


-- ##################################################################
-- PROJECT TYPES - SUMMARY 1
-- ##################################################################

		select ppta.project_type project_type
			 , count (*) ct
			 , max (ppa.creation_date) latest
		  from pa.pa_projects_all ppa
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join pa.pa_project_types_all ppta on ppa.project_type = ppta.project_type
		  join applsys.fnd_user fu on ppa.created_by = fu.user_id
		  join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
	  group by ppta.project_type
	  order by 1;

-- ##################################################################
-- PROJECT TYPES - SUMMARY 2
-- ##################################################################

		select ppta.project_type
			 , ppta.creation_date
			 , ppta.start_date_active
			 , ppta.end_date_active
			 , ppta.burden_cost_flag
			 , total_tbl.ct count_all
			 , total_tbl.latest
			 , total_tbl_open.ct count_open 
		  from pa.pa_project_types_all ppta
	 left join (select ppta.project_type
					 , count(*) ct
					 , max(ppa.creation_date) latest
				  from pa.pa_projects_all ppa
				  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
				  join pa.pa_project_types_all ppta on ppa.project_type = ppta.project_type
				  join applsys.fnd_user fu on ppa.created_by = fu.user_id
				  join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
			  group by ppta.project_type) total_tbl on ppta.project_type = total_tbl.project_type
	 left join (select ppta.project_type
					 , count (*) ct
					 , max (ppa.creation_date) latest
				  from pa.pa_projects_all ppa
				  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code and pps.project_status_name not like '%Closed%'
				  join pa.pa_project_types_all ppta on ppa.project_type = ppta.project_type
				  join applsys.fnd_user fu on ppa.created_by = fu.user_id
				  join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
			  group by ppta.project_type) total_tbl_open on ppta.project_type = total_tbl_open.project_type
	  order by 1;
