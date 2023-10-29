/*
File Name: sa-user-accounts-hr-records.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- BASIC USER LIST
-- BASIC HR RECORDS 
-- BASIC USER ACCOUNTS 1
-- BASIC USER ACCOUNTS 2
-- HR RECORD - BASIC
-- HR RECORD - BASIC, INCLUDING LINE MANAGER DETAILS
-- STAFF LIST WITH SUPERVISOR CHECKING - VERSION 1
-- STAFF LIST WITH SUPERVISOR CHECKING - VERSION 2
-- SQL TO FIND SUPERVISOR INFINITE LOOPS

*/

-- ##################################################################
-- BASIC USER LIST
-- ##################################################################

		select fu.user_name
			 , fu.description
			 , fu.employee_id
			 , to_char(fu.start_date, 'DD-MON-YYYY') user_start_date
			 , to_char(fu.end_date, 'DD-MON-YYYY') user_end_date
			 , fu.user_id
			 , fu.email_address
			 , papf.full_name
			 , papf.employee_number
			 , bg.name business_group
			 , fu.creation_date user_created
			 , fu3.user_name user_created_by
			 , fu.last_update_date user_updated
			 , fu2.user_name user_updated_by
			 , fu.last_logon_date
			 -- , (select count(*) from applsys.fnd_logins fl where fl.user_id = fu.user_id and trunc(sysdate) - trunc(fl.start_time) <= 30) login_count_30_days
			 -- , (select count(*) from applsys.fnd_logins fl where fl.user_id = fu.user_id) login_count_total
			 -- , (select max(fl.start_time) from applsys.fnd_logins fl where fl.user_id = fu.user_id) last_logon
			 , round(sysdate - fu.last_logon_date, 0) logon_gap
		  from fnd_user fu
		  join fnd_user fu2 on fu2.user_id = fu.last_updated_by
		  join fnd_user fu3 on fu3.user_id = fu.created_by
	 left join per_all_people_f papf on fu.employee_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join hr_all_organization_units bg on papf.business_group_id = bg.organization_id
		 where 1 = 1
		   -- and nvl(fu.end_date, sysdate + 1) > sysdate
		   -- and bg.name in ('XX Business Group','YY Business Group')
		   -- and papf.full_name like '%Daffy%'
		   -- and fu.user_name = 'USER123'
		   and papf.full_name = 'Duck, Mr Daffy'
		   -- and papf.last_name like 'Duck%'
		   and 1 = 1;

-- ##################################################################
-- BASIC HR RECORDS 
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , bg.name bus_grp
			 , papf.person_id
			 , papf.employee_number
			 , papf.full_name
			 , fu_account.user_name
			 , fu_account.user_id
			 , fu_account.email_address
			 , pptt.user_person_type person_type
			 , to_char(papf.effective_start_date, 'DD-MON-YYYY') person_start
			 , to_char(papf.effective_end_date, 'DD-MON-YYYY') person_end
			 , '##################'
			 , papf.creation_date hr_record_created
			 , pf.user_name hr_record_created_by
			 , papf.last_update_date hr_record_updated
			 , pfu.user_name hr_record_updated_by
			 , '##################'
			 , paaf.creation_date hr_assg_created
			 , pfac.user_name hr_assg_created_by
			 , paaf.last_update_date hr_assg_updated
			 , pfacu.user_name hr_assg_updated_by
			 , '##################'
			 , fu.user_name linked_username
			 , fu.last_logon_date
			 , to_char(fu.start_date, 'DD-MON-YYYY') linked_user_start
			 , to_char(fu.end_date, 'DD-MON-YYYY') linked_user_end
			 , paaf.assignment_number
			 , paaf.assignment_type
			 , to_char(paaf.effective_start_date, 'DD-MON-YYYY') assignment_start
			 , to_char(paaf.effective_end_date, 'DD-MON-YYYY') assignment_end
			 , he.full_name supervisor
			 , papf.current_employee_flag
			 , look_asg_status.meaning assign_status
			 , gcc.concatenated_segments code_combs
			 , paaf.last_update_date assig_updated
			 , fu_assig.user_name assig_updated_by
			 , hla.location_code
			 , hla.description
			 , pj.name job_title
			 , pj.creation_date job_created
			 , pp.name position
			 , papf2.full_name manager
		  from per_all_people_f papf
	 left join per_all_assignments_f paaf on papf.person_id = paaf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date and sysdate between paaf.effective_start_date and paaf.effective_end_date
	 left join hr_employees he on paaf.supervisor_id = he.employee_id
	 left join fnd_user pf on papf.created_by = pf.user_id
	 left join fnd_user pfu on papf.last_updated_by = pfu.user_id
	 left join fnd_user pfac on paaf.created_by = pfac.user_id
	 left join fnd_user pfacu on paaf.last_updated_by = pfacu.user_id
	 left join fnd_user fu on papf.person_id = fu.employee_id
	 left join per_assignment_status_types past on paaf.assignment_status_type_id = past.assignment_status_type_id
	 left join fnd_lookup_values_vl look_asg_status on look_asg_status.lookup_code = past.per_system_status and look_asg_status.lookup_type = 'PER_ASS_SYS_STATUS'
	 left join gl_code_combinations_kfv gcc on gcc.code_combination_id = paaf.default_code_comb_id
	 left join hr_locations_all hla on hla.location_id = paaf.location_id
	 left join per_person_types_tl pptt on papf.person_type_id = pptt.person_type_id and pptt.language = userenv('lang')
	 left join apps.per_jobs pj on pj.job_id = paaf.job_id
	 left join apps.per_positions pp on paaf.position_id = pp.position_id and sysdate between pp.date_effective and pp.date_end
	 left join hr.hr_all_organization_units bg on bg.organization_id = papf.business_group_id
	 left join fnd_user fu_account on fu_account.employee_id = papf.person_id
	 left join fnd_user fu_assig on fu_assig.user_id = paaf.last_updated_by
	 left join hr.per_all_people_f papf2 on paaf.supervisor_id = papf2.person_id and sysdate between papf2.effective_start_date and papf2.effective_end_date
		 where 1 = 1
		   and paaf.assignment_type = 'E'
		   and papf.current_employee_flag = 'Y'
		   and paaf.primary_flag = 'Y'
		   -- and papf.person_id in (123456)
		   -- and papf.employee_number in ('123456')
		   and fu.user_name in ('USER123') 
		   -- and fu.user_name in ('USER123','USER124')
		   and 1 = 1;

-- ##################################################################
-- BASIC USER ACCOUNTS 1
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , fu.user_id
			 , fu.user_name
			 , fu.description
			 , fu.employee_id
			 , fu.start_date
			 , fu.email_address
			 , fu.creation_date
			 , fu.last_logon_date
			 , (select count(*) from fnd_user_resp_groups_direct furg where furg.user_id = fu.user_id and nvl(furg.end_date, sysdate + 1) > sysdate) resp_count
			 , round(sysdate - fu.last_logon_date, 0) logon_gap
			 , (select count(*) from applsys.fnd_logins fl where fl.user_id = fu.user_id and trunc(sysdate) - trunc(fl.start_time) <= 30) login_count_30_days
			 , (select count(*) from applsys.fnd_logins fl where fl.user_id = fu.user_id) login_count_total
			 , (select max(prha.segment1) from po_requisition_headers_all prha where prha.created_by = fu.user_id and prha.authorization_status = 'APPROVED') latest_req
			 , (select max(fl.start_time) from applsys.fnd_logins fl where fl.user_id = fu.user_id) last_logon
		  from fnd_user fu
		 where 1 = 1
		   -- and nvl(end_date, sysdate + 1) > sysdate
		   -- and fu.employee_id is not null
		   -- and fu.employee_id is null
		   -- and papf.person_id in (123456)
		   -- and papf.employee_number in ('123456')
		   and fu.user_name in ('USER123') 
		   -- and fu.user_name in ('USER123','USER124')
		   and 1 = 1
	  order by 1 desc;

-- ##################################################################
-- BASIC USER ACCOUNTS 2
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , fu.user_name
			 , fu.user_id
			 , fu.employee_id
			 , fu.description
			 , fu.start_date
			 , fu.end_date 
			 , fu.creation_date
			 , fu_created.user_name created_by
			 , fu.last_update_date
			 , fu_updated.user_name updated_by
			 , fu.email_address
			 , (select count(*) from fnd_user_resp_groups_direct furg where furg.user_id = fu.user_id and nvl(furg.end_date, sysdate + 1) > sysdate) resp_count
		  from applsys.fnd_user fu
		  join applsys.fnd_user fu_created on fu.created_by = fu_created.user_id
		  join applsys.fnd_user fu_updated on fu.last_updated_by = fu_updated.user_id
		 where 1 = 1
		   and fu.employee_id is not null
		   and fu.description like :fnd_name
		   and nvl(fu.end_date, sysdate + 1) > sysdate
		   and (select count(*) from fnd_user_resp_groups_direct furg where furg.user_id = fu.user_id and nvl(furg.end_date, sysdate + 1) > sysdate) > 1
		   and fu.user_name = 'USER123'
		   and fu.last_update_date > '12-FEB-2016'
		   and 2 = 2;

-- ##################################################################
-- HR RECORD - BASIC
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , papf.person_id
			 , papf.employee_number
			 , fu.user_name
			 , papf.business_group_id
			 , papf.full_name
			 , papf.effective_start_date
			 , papf.effective_end_date
			 , bg.name business_group
			 , pj.name job_title
			 , pg.name grade
			 , pp.name position
			 , hla.location_code location
			 , haou.name hr_org
			 , papf.last_update_date
			 , paaf.assignment_id
			 , paaf.last_update_date
			 , paaf.effective_start_date
			 , paaf.effective_end_date
			 , paaf.last_updated_by
		  from hr.per_all_people_f papf
		  join hr.per_all_assignments_f paaf on papf.person_id = paaf.person_id
	 left join hr.per_jobs pj on paaf.job_id = pj.job_id
	 left join hr.per_grades pg on paaf.grade_id = pg.grade_id
	 left join hr.hr_locations_all hla on paaf.location_id = hla.location_id
	 left join hr.hr_all_organization_units haou on haou.organization_id = paaf.location_id
	 left join hr.hr_all_organization_units bg on bg.organization_id = papf.business_group_id
	 left join hr.per_jobs pj on paaf.job_id = pj.job_id
	 left join apps.per_positions pp on paaf.position_id = pp.position_id
	 left join fnd_user fu on fu.employee_id = papf.person_id
		 where 1 = 1
		   -- and sysdate between papf.effective_start_date and papf.effective_end_date
		   -- and sysdate between paaf.effective_start_date and paaf.effective_end_date
		   and papf.employee_number = '123456'
		   and 1 = 1; 

-- ##################################################################
-- HR RECORD - BASIC, INCLUDING LINE MANAGER DETAILS
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , fu.user_name
			 , fu.description
			 , fu.start_date
			 , fu.end_date 
			 , fu.creation_date cr_dt
			 , fu_created.user_name cr_by
			 , fu.last_update_date up_dt
			 , fu_updated.user_name up_by
			 , fu.email_address
			 , hp.party_number pnum
			 , papf.employee_number empno
			 , hp.party_name
			 , papf.person_id
			 , papf.full_name
			 , papf.email_address hr_email
			 , gcc.segment1 || '*' || gcc.segment2 || '*' || gcc.segment3 || '*' || gcc.segment4 || '*' || gcc.segment5 || '*' || gcc.segment6 code
			 , paaf.creation_date paaf_cr_dt
			 , fu_paaf.user_name paaf_cr_by
			 , paaf.last_update_date paaf_up_dt
			 , fu_paaf2.user_name paaf_up_by
			 , pj.name job_title
			 , pp.phone_number telno
			 , papf2.full_name manager
			 , papf2.person_id manager_id
			 , papf2.employee_number manager_employee_number
			 , pj2.name manager_job_title
		  from applsys.fnd_user fu
		  join applsys.fnd_user fu_created on fu.created_by = fu_created.user_id
		  join applsys.fnd_user fu_updated on fu.last_updated_by = fu_updated.user_id
	 left join ar.hz_parties hp on fu.person_party_id = hp.party_id
	 left join hr.per_all_people_f papf on fu.employee_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join hr.per_all_assignments_f paaf on papf.person_id = paaf.person_id and sysdate between paaf.effective_start_date and paaf.effective_end_date
	 left join applsys.fnd_user fu_paaf on paaf.created_by = fu_paaf.user_id
	 left join applsys.fnd_user fu_paaf2 on paaf.last_updated_by = fu_paaf2.user_id
	 left join hr.per_jobs pj on paaf.job_id = pj.job_id
	 left join gl.gl_code_combinations gcc on paaf.default_code_comb_id = gcc.code_combination_id
	 left join hr.per_phones pp on papf.person_id = pp.parent_id and pp.phone_type = 'W1'
	 -- SUPERVISOR TABLES HERE:
	 left join hr.per_all_people_f papf2 on paaf.supervisor_id = papf2.person_id and sysdate between papf2.effective_start_date and papf2.effective_end_date
	 left join hr.per_all_assignments_f paaf2 on papf2.person_id = paaf2.person_id and sysdate between paaf2.effective_start_date and paaf2.effective_end_date
	 left join hr.per_jobs pj2 on paaf2.job_id = pj2.job_id
		 where 1 = 1
		   -- and fu.description like :fnd_name
		   -- and papf.full_name like :full_name
		   -- and papf.creation_date > '15-FEB-2016'
		   and fu.user_name in ('USER123')
		   -- and papf.employee_number in ('123456')
		   -- and papf.person_id = 123456
		   and 2 = 2;

-- ##################################################################
-- STAFF LIST WITH SUPERVISOR CHECKING - VERSION 1
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , e.bus_gp
			 , e.full_name
			 , e.employee_number empno
			 , level
			 , sys_connect_by_path(e.last_name, '/') path
			 , e.limit_req_min
			 , e.limit_req_max
			 , e.limit_po_min
			 , e.limit_po_max
			 , e.limit_cpa_min
			 , e.limit_cpa_max
			 , e.job
			 , e.user_name
			 , e.end_date
			 , e.email_address
			 , e.user_location
			 , e.hr_org
			 , e.default_charge_account
			 , e.personid
		  from (select ppf.person_id
					 , ppf.employee_number
					 , ppf.full_name
					 , ppf.last_name
					 , ppf.person_id personid
					 , hlat.location_code user_location
					 , haou.name hr_org
					 , paf.supervisor_id
					 , pj.name job
					 , ppf.email_address
					 , fu.user_name
					 , fu.end_date
					 , pg.name grade
					 , bus_gp.name bus_gp
					 , gcc.concatenated_segments default_charge_account
					 , (select min(pcr.amount_limit) from po.po_position_controls_all ppca , po.po_control_rules pcr, po.po_control_functions pcf where pcr.control_group_id = ppca.control_group_id and pcf.control_function_id = ppca.control_function_id and ppca.job_id = pj.job_id and ppca.end_date is null and pcr.object_code = 'DOCUMENT_TOTAL' and pcf.document_type_code = 'REQUISITION') limit_req_min
					 , (select max(pcr.amount_limit) from po.po_position_controls_all ppca , po.po_control_rules pcr, po.po_control_functions pcf where pcr.control_group_id = ppca.control_group_id and pcf.control_function_id = ppca.control_function_id and ppca.job_id = pj.job_id and ppca.end_date is null and pcr.object_code = 'DOCUMENT_TOTAL' and pcf.document_type_code = 'REQUISITION') limit_req_max
					 , (select min(pcr.amount_limit) from po.po_position_controls_all ppca , po.po_control_rules pcr, po.po_control_functions pcf where pcr.control_group_id = ppca.control_group_id and pcf.control_function_id = ppca.control_function_id and ppca.job_id = pj.job_id and ppca.end_date is null and pcr.object_code = 'DOCUMENT_TOTAL' and pcf.document_type_code = 'PO') limit_po_min
					 , (select max(pcr.amount_limit) from po.po_position_controls_all ppca , po.po_control_rules pcr, po.po_control_functions pcf where pcr.control_group_id = ppca.control_group_id and pcf.control_function_id = ppca.control_function_id and ppca.job_id = pj.job_id and ppca.end_date is null and pcr.object_code = 'DOCUMENT_TOTAL' and pcf.document_type_code = 'PO') limit_po_max
					 , (select min(pcr.amount_limit) from po.po_position_controls_all ppca , po.po_control_rules pcr, po.po_control_functions pcf where pcr.control_group_id = ppca.control_group_id and pcf.control_function_id = ppca.control_function_id and ppca.job_id = pj.job_id and ppca.end_date is null and pcr.object_code = 'DOCUMENT_TOTAL' and pcf.document_type_code = 'PA') limit_cpa_min
					 , (select max(pcr.amount_limit) from po.po_position_controls_all ppca , po.po_control_rules pcr, po.po_control_functions pcf where pcr.control_group_id = ppca.control_group_id and pcf.control_function_id = ppca.control_function_id and ppca.job_id = pj.job_id and ppca.end_date is null and pcr.object_code = 'DOCUMENT_TOTAL' and pcf.document_type_code = 'PA') limit_cpa_max
				  from hr.per_all_people_f ppf
				  join hr.per_all_assignments_f paf on ppf.person_id = paf.person_id
			 left join hr.per_jobs pj on paf.job_id = pj.job_id
			 left join hr.per_grades pg on paf.grade_id = pg.grade_id
			 left join hr.hr_all_organization_units haou on paf.organization_id = haou.organization_id
			 left join hr.hr_locations_all_tl hlat on paf.location_id = hlat.location_id
			 left join applsys.fnd_user fu on paf.person_id = fu.employee_id
			 left join hr.hr_all_organization_units_tl bus_gp on paf.business_group_id = bus_gp.organization_id
			 left join apps.gl_code_combinations_kfv gcc on paf.default_code_comb_id = gcc.code_combination_id
				 where 1 = 1
				   and sysdate between ppf.effective_start_date and ppf.effective_end_date
				   and sysdate between paf.effective_start_date and paf.effective_end_date
				   and paf.primary_flag = 'Y'
				   and paf.assignment_type = 'E'
				   and 1 = 1) e
	connect by prior supervisor_id = person_id
	start with employee_number = 'BIG_BOSS_USER';

-- ##################################################################
-- STAFF LIST WITH SUPERVISOR CHECKING - VERSION 2
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , lpad(' ', (level - 1) * 10, ' ') || h.person_id person_id
			 , sys_connect_by_path((f.full_name || ' - ' || f.employee_number), '____') as path
			 , level
			 , f.full_name
			 , pg.name gd
			 , f.employee_number empno
			 , u.user_name user_name
			 , replace(u.description, ' - 6 months inactive', '') descr
			 , pj.name job_title
			 , haou.name hr_org
			 , connect_by_iscycle
		  from hr.per_all_people_f f
			 , hr.per_all_assignments_f h
			 , hr.hr_all_organization_units haou
			 , hr.per_jobs pj
			 , hr.per_grades pg
			 , applsys.fnd_user u
		 where h.person_id = u.employee_id(+)
		   and f.person_id = h.person_id
		   and h.job_id = pj.job_id
		   and h.organization_id = haou.organization_id
		   and h.grade_id = pg.grade_id(+)
		   -- and f.business_group_id = 7042
		   and connect_by_iscycle = 1
	start with f.person_id = 123456 -- person_id of manager
		   and sysdate between h.effective_start_date and h.effective_end_date
		   and sysdate between f.effective_start_date and f.effective_end_date
	connect by nocycle prior h.person_id = supervisor_id
		   and sysdate between f.effective_start_date and f.effective_end_date
		   and sysdate between h.effective_start_date and h.effective_end_date;

-- ##################################################################
-- SQL TO FIND SUPERVISOR INFINITE LOOPS
-- ##################################################################

		select distinct sys_connect_by_path((papf.full_name || ' - ' || papf.employee_number), '____') as path
			 , connect_by_iscycle
		  from hr.per_all_assignments_f h
			 , hr.per_all_people_f papf
		 where h.person_id = papf.person_id
		   and sysdate between h.effective_start_date and h.effective_end_date
		   and sysdate between papf.effective_start_date and papf.effective_end_date
		   and connect_by_iscycle = 1
	start with sysdate between h.effective_start_date and h.effective_end_date
		   and sysdate between papf.effective_start_date and papf.effective_end_date
		   and h.person_id = :personid
	connect by nocycle prior h.person_id = supervisor_id
		   and sysdate between h.effective_start_date and h.effective_end_date
		   and sysdate between papf.effective_start_date and papf.effective_end_date;
