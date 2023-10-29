/*
File Name: pa-organizations.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- PA ORGANIZATIONS
-- PROJECTS BY HR ORG
-- DETAILS
-- HR ORGS LINKED TO PROJECTS
-- COUNT OF PROJECTS BY CARRYING OUT ORG

*/

-- ##################################################################
-- PA ORGANIZATIONS
-- ##################################################################

		select haou.organization_id org_id
			 , haou.name
			 , haou.creation_date org_cr_date
			 , fu1.description org_cr_by
			 , haou.last_update_date org_upd_date
			 , fu2.description org_upd_by
			 , tbl_inv.chk "INVOICE COLLECTION ORG"
			 , tbl_proj.chk "TASK OWNING ORG"
		  from hr.hr_all_organization_units haou
		  join applsys.fnd_user fu1 on haou.created_by = fu1.user_id
		  join applsys.fnd_user fu2 on haou.last_updated_by = fu2.user_id
	 left join (select 1 chk, organization_id from apps.hr_organization_information_v where org_information1 = 'PA_INVOICE_ORG') tbl_inv on haou.organization_id = tbl_inv.organization_id
	 left join (select 1 chk, organization_id from apps.hr_organization_information_v where org_information1 = 'PA_PROJECT_ORG') tbl_proj on haou.organization_id = tbl_proj.organization_id
	  order by haou.creation_date desc;

-- ##################################################################
-- PROJECTS BY HR ORG
-- ##################################################################

		select haou.name org
			 , count(*) ct
		  from pa.pa_projects_all ppa
		  join pa.pa_projects_all ppa_template on ppa.created_from_project_id = ppa_template.project_id
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join pa.pa_project_types_all ppta on ppa.project_type = ppta.project_type
	 left join pa.pa_ind_rate_schedules_all_bg pirsa on ppa.cost_ind_rate_sch_id = pirsa.ind_rate_sch_id
		  join applsys.fnd_user fu on ppa.created_by = fu.user_id
		  join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
	  group by haou.name
	  order by 2 desc;

-- DETAILS

		select ppa.segment1
			 , haou.name
			 , ppa_template.name
			 , ppa.project_status_code
			 , ppa.description
		  from pa.pa_projects_all ppa
	 left join pa.pa_projects_all ppa_template on ppa.created_from_project_id = ppa_template.project_id
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join pa.pa_project_types_all ppta on ppa.project_type = ppta.project_type
	 left join pa.pa_ind_rate_schedules_all_bg pirsa on ppa.cost_ind_rate_sch_id = pirsa.ind_rate_sch_id
		  join applsys.fnd_user fu on ppa.created_by = fu.user_id
		  join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
		 where haou.name = 'Cheese Research Office'
	  order by 2 desc;

-- ##################################################################
-- HR ORGS LINKED TO PROJECTS
-- ##################################################################

		select *
		  from apps.pa_organizations_v
		 where exists
		(select ppa.project_id from pa.pa_projects_all ppa where ppa.carrying_out_organization_id = pa_organizations_v.organization_id);

-- ##################################################################
-- COUNT OF PROJECTS BY CARRYING OUT ORG
-- ##################################################################

		select substr(pov1.name, 1, 80)
			 , count (ppa.project_id)
		  from pa.pa_projects_all ppa
		  join apps.pa_organizations_v pov1 on ppa.carrying_out_organization_id = pov1.organization_id
		 where ppa.carrying_out_organization_id in (select pov.organization_id from apps.pa_organizations_v pov)
	  group by substr (pov1.name, 1, 80);
