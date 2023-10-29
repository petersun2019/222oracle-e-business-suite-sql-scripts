/*
File Name:		pa-revenue.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- PA SERVICE TYPES GROUPED BY SERVICE TYPE CODE
-- PA SERVICE TYPES - DETAILS AGAINST A PROJECT
-- COUNTS AGAINST SERVICE TYPES
-- COUNT OF DISTINCT SERVICE TYPES PER PROJECT, HIGHEST FIRST

*/

-- ##################################################################
-- PA SERVICE TYPES GROUPED BY SERVICE TYPE CODE
-- ##################################################################

/*
PROJECT SERVICE TYPES (HELD AT TASK LEVEL > TASK OPTIONS > TASK DETAILS)
*/

		select pt.service_type_code
			 , count (distinct pt.task_id) task_ct
			 , count (distinct ppa.project_id) project_ct
		  from pa.pa_projects_all ppa
		  join pa.pa_projects_all ppa_template on ppa.created_from_project_id = ppa_template.project_id
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join pa.pa_project_types_all ppta on ppa.project_type = ppta.project_type
		  join pa.pa_tasks pt on ppa.project_id = pt.project_id
		  join applsys.fnd_user fu on ppa.created_by = fu.user_id
		  join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
	 left join pa.pa_ind_rate_schedules_all_bg pirsa on pt.cost_ind_rate_sch_id = pirsa.ind_rate_sch_id
		 where ppa.segment1 = 'P123456'
	  group by pt.service_type_code
	  order by pt.service_type_code;

-- ##################################################################
-- PA SERVICE TYPES - DETAILS AGAINST A PROJECT
-- ##################################################################

		select pt.task_number
			 , pt.service_type_code
			 , pt.billable_flag
			 , pt.chargeable_flag
		  from pa.pa_projects_all ppa
		  join pa.pa_projects_all ppa_template on ppa.created_from_project_id = ppa_template.project_id
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join pa.pa_project_types_all ppta on ppa.project_type = ppta.project_type
		  join pa.pa_tasks pt on ppa.project_id = pt.project_id
		  join applsys.fnd_user fu on ppa.created_by = fu.user_id
		  join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
	 left join pa.pa_ind_rate_schedules_all_bg pirsa on pt.cost_ind_rate_sch_id = pirsa.ind_rate_sch_id
		 where ppa.segment1 = 'P123456'
	  order by pt.service_type_code;

-- ##################################################################
-- COUNTS AGAINST SERVICE TYPES
-- ##################################################################

		select distinct pt.service_type_code
			 , total_tbl.latest last_used
			 , total_tbl.cta count_tasks_all
			 , total_tbl.cpa count_projects_all
			 , total_tbl_open.cto count_tasks_open
			 , total_tbl_open.cpo count_projects_open
		  from pa.pa_projects_all ppa
		  join pa.pa_tasks pt on ppa.project_id = pt.project_id
		  join ( select pt.service_type_code
			 , count (distinct pt.task_id) cta
			 , count (distinct ppa.project_id) cpa
			 , max (ppa.creation_date) latest
		  from pa.pa_projects_all ppa
			 , pa.pa_tasks pt
			 , pa.pa_project_statuses pps
		 where ppa.project_id = pt.project_id
		   and ppa.project_status_code = pps.project_status_code
	  group by pt.service_type_code) total_tbl on pt.service_type_code = total_tbl.service_type_code
		  join ( select pt.service_type_code
			 , count (distinct pt.task_id) cto
			 , count (distinct ppa.project_id) cpo
		  from pa.pa_projects_all ppa
			 , pa.pa_tasks pt
			 , pa.pa_project_statuses pps
		 where ppa.project_id = pt.project_id
		   and ppa.project_status_code = pps.project_status_code
		   and pps.project_status_name not like '%Closed%'
	  group by pt.service_type_code) total_tbl_open on pt.service_type_code = total_tbl_open.service_type_code
	  order by pt.service_type_code;

-- ##################################################################
-- COUNT OF DISTINCT SERVICE TYPES PER PROJECT, HIGHEST FIRST
-- ##################################################################

		select ppa.segment1
			 , count (distinct pt.task_id) task_ct
			 , count (distinct pt.service_type_code) svc_type_ct
		  from pa.pa_projects_all ppa
		  join pa.pa_projects_all ppa_template on ppa.created_from_project_id = ppa_template.project_id
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join pa.pa_project_types_all ppta on ppa.project_type = ppta.project_type
		  join pa.pa_tasks pt on ppa.project_id = pt.project_id
		  join applsys.fnd_user fu on ppa.created_by = fu.user_id
		  join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
		  join pa.pa_ind_rate_schedules_all_bg pirsa on pt.cost_ind_rate_sch_id = pirsa.ind_rate_sch_id
	  group by ppa.segment1
	  order by 3 desc;
