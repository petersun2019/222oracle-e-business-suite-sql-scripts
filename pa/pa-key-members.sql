/*
File Name:		pa-key-members.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- KEY MEMBERS
-- BASIC LIST OF ROLES

*/

-- ##################################################################
-- KEY MEMBERS
-- ##################################################################

		select ppa.segment1
			 , ppa.name
			 , ppa.creation_date
			 , haou.name hr_org
			 , bus_gp.name hr_org_bus_group
			 , papf.full_name key_member
			 , papf.first_name
			 , papf.last_name
			 , papf.employee_number emp_num
			 , pj.name job_title
			 , fu.employee_id
			 , to_char(ppp.start_date_active, 'DD-MON-YYYY') member_start
			 , to_char(ppa.start_date, 'DD-MON-YYYY') project_start
			 , ppp.end_date_active member_end
			 , ppp.creation_date km_cr_date
			 , ppp.last_update_date km_up_date
			 , ppa.creation_date pr_cr_date
			 , pprtt.meaning role_
			 , ppp.project_role_id
			 , pprtt.creation_date role_ct_date
			 , fu.user_name key_member_user_name
			 , fu.end_date key_member_user_end
			 , fu2.user_name km_created_by
			 , fu3.user_name km_updated_by
		  from pa.pa_project_parties ppp
		  join pa.pa_project_role_types_b pprt on ppp.project_role_id = pprt.project_role_id
		  join pa.pa_project_role_types_tl pprtt on pprtt.project_role_id = pprt.project_role_id and pprtt.language = userenv('lang')
		  join pa.pa_projects_all ppa on ppp.object_id = ppa.project_id
		  join applsys.fnd_user fu2 on ppp.created_by = fu2.user_id
		  join applsys.fnd_user fu3 on ppp.last_updated_by = fu3.user_id
	 left join hr.per_all_people_f papf on ppp.resource_source_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join hr.per_all_assignments_f paaf on paaf.person_id = papf.person_id and sysdate between paaf.effective_start_date and paaf.effective_end_date and paaf.primary_flag = 'Y'
	 left join apps.per_jobs pj on pj.job_id = paaf.job_id
	 left join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
	 left join hr.hr_all_organization_units bus_gp on bus_gp.organization_id = haou.business_group_id
	 left join applsys.fnd_user fu on fu.employee_id = papf.person_id
		 where 1 = 1
		   -- and ppa.segment1 in ('P123456')
		   -- and fu.user_name = 'CHEESE_USER'
		   and fu.employee_id = 123456
		   -- and ppa.project_id = 123456
		   and 1 = 1;

-- ##################################################################
-- BASIC LIST OF KEY MEMBER ROLES
-- ##################################################################

		select pprtb.project_role_type
			 , pprtt.meaning oracle_meaning
			 , pprtb.creation_date
			 , fu.user_name created_by
		  from pa.pa_project_role_types_b pprtb
			 , pa.pa_project_role_types_tl pprtt
			 , applsys.fnd_user fu
		 where pprtb.project_role_id = pprtt.project_role_id
		   and pprtb.created_by = fu.user_id;
