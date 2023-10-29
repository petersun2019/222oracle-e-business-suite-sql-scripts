/*
File Name:		sa-staff-approval-limits.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

-- STANDARD APPROVAL LIMITS
-- COUNT OF VALUES PER JOB TITLE
-- BIG TALLY LIST
-- JOB TITLES WITH LIMITS WHICH ARE ATTACHED TO STAFF
-- SIMPLE VIEW OF APPROVAL LIMITS / DOC TYPES AGAINST JOB TITLE
-- SIMPLE VIEW OF APPROVAL LIMITS / DOC TYPES AGAINST POSITION
-- VIEWING THE VALUE LIMITS AGAINST JOB TITLES
-- VIEWING THE VALUE LIMITS AGAINST POSITIONS

*/

-- ##################################################################
-- STANDARD APPROVAL LIMITS
-- ##################################################################

		select distinct ppca.org_id
			 , papf.full_name
			 , papf.employee_number empno
			 , nvl(fu.user_name, '###') login
			 , fu.description login_name
			 , pcga.control_group_name app_gp
			 , pcr.amount_limit lim
			 , pcr.segment1_low co
			 , nvl(pcr.segment2_low, 'All') lo
			 , case when pcr.segment2_high <> pcr.segment2_low then pcr.segment2_high else '' end hi
			 , trunc(ppca.last_update_date) updated_date
			 , pj.name job_title
			 , pcak.segment1 || '/' || pcak.segment2 || '/' || pcak.segment4 ch_acct
			 , hlat.location_code user_location
			 , haou.name hr_org
			 , papf.email_address
			 , papf2.full_name manager_full_name
			 , papf2.employee_number manager_empno
			 , trim(fu2.description) manager_desc
			 , fu2.user_name manager_user_name
			 , papf2.email_address manager_email
			 , gal.authorization_limit gl_limit
		  from applsys.fnd_user fu
		  join hr.per_all_people_f papf on papf.person_id = fu.employee_id
		  join hr.per_all_assignments_f paaf on paaf.person_id = papf.person_id
		  join hr.per_jobs pj on paaf.job_id = pj.job_id
		  join hr.hr_all_organization_units haou on haou.organization_id = paaf.organization_id
	 left join hr.hr_locations_all_tl hlat on paaf.location_id = hlat.location_id
		  join hr.per_assignment_status_types past on paaf.assignment_status_type_id = past.assignment_status_type_id and past.per_system_status in('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
	 left join hr.per_person_type_usages_f pptu on papf.person_id = pptu.person_id
	 left join hr.pay_cost_allocation_keyflex pcak on haou.cost_allocation_keyflex_id = pcak.cost_allocation_keyflex_id
		  join po.po_position_controls_all ppca on ppca.job_id = paaf.job_id
	 left join hr.per_all_people_f papf2 on paaf.supervisor_id = papf2.person_id and sysdate between papf2.effective_start_date and papf2.effective_end_date
	 left join applsys.fnd_user fu2 on papf2.person_id = fu2.employee_id
		  join po.po_control_groups_all pcga on pcga.control_group_id = ppca.control_group_id
		  join po.po_control_functions pcf on pcf.control_function_id = ppca.control_function_id
		  join po.po_control_rules pcr on pcr.control_group_id = ppca.control_group_id and pcr.object_code = 'ACCOUNT_RANGE'
	 left join gl.gl_authorization_limits gal on papf.person_id = gal.employee_id
		 where sysdate between papf.effective_start_date and papf.effective_end_date
		   and sysdate between paaf.effective_start_date and paaf.effective_end_date
		   and sysdate between pptu.effective_start_date and pptu.effective_end_date
		   -- and nvl(papf2.current_employee_flag, 'Y') = 'Y'
		   -- and nvl(fu.end_date, sysdate + 1) > sysdate
		   and papf.current_employee_flag = 'Y'
		   and paaf.assignment_type = 'E'
		   and paaf.primary_flag = 'Y'
		   and papf.full_name = 'Duck, Mr Daffy'
		   -- and papf.employee_number = '8919116'
	  order by 4
			 , 1;

-- ##################################################################
-- COUNT OF VALUES PER JOB TITLE
-- ##################################################################

/*
Looks for duplicate ones which can cause errors.
If returns nothing, then that is ok.
If returns records then need to edit the approval on the job title to remove duplicates.
i.e. ensure all values of approval limits against job titles are equal.
*/

		select distinct pj.name job
			 , count(distinct pcr.amount_limit) ct
		  from po.po_position_controls_all ppca
			 , po.po_control_rules pcr
			 , hr.per_jobs pj
			 , hr.hr_all_organization_units_tl bus_gp
		 where pcr.control_group_id = ppca.control_group_id
		   and pj.business_group_id = bus_gp.organization_id
		   and ppca.end_date is null
		   and ppca.job_id = pj.job_id
	    having count(distinct pcr.amount_limit) > 1
	  group by pj.name
	  order by 2 desc;

-- ##################################################################
-- BIG TALLY LIST
-- ##################################################################

		select distinct pj.business_group_id org
			 , pj.name job_title
			 , (select count(*)
				  from hr.per_all_people_f papf
					 , hr.per_all_assignments_f paaf
				 where papf.person_id = paaf.person_id
				   and paaf.job_id = pj.job_id
				   and paaf.assignment_number is not null
				   and sysdate between papf.effective_start_date and papf.effective_end_date
				   and sysdate between paaf.effective_start_date and paaf.effective_end_date
				   and paaf.primary_flag = 'Y'
				   and paaf.assignment_type = 'E'
				   and papf.current_employee_flag = 'Y') primary_people
			 , (select count(*)
				  from hr.per_all_people_f papf
					 , hr.per_all_assignments_f paaf
				 where papf.person_id = paaf.person_id
				   and paaf.job_id = pj.job_id
				   and paaf.assignment_number is not null
				   and sysdate between papf.effective_start_date and papf.effective_end_date
				   and sysdate between paaf.effective_start_date and paaf.effective_end_date) all_people
			 , (select distinct pcr.amount_limit
				  from po.po_position_controls_all ppca
					 , po.po_control_rules pcr
				 where pcr.control_group_id = ppca.control_group_id
				   and ppca.job_id = pj.job_id
				   and ppca.end_date is null
				   and pcr.object_code = 'DOCUMENT_TOTAL') limit_
		  from hr.per_jobs pj
			 , hr.hr_all_organization_units_tl bus_gp
			 , po.po_position_controls_all ppca
			 , po.po_control_rules pcr
		 where ppca.job_id = pj.job_id
		   and pj.business_group_id = bus_gp.organization_id
		   and pcr.control_group_id = ppca.control_group_id
		   and ppca.end_date is null
	  order by pj.name;

-- ##################################################################
-- JOB TITLES WITH LIMITS WHICH ARE ATTACHED TO STAFF
-- ##################################################################

		select distinct pj.name job_title
			 , pj.business_group_id bg
			 , (select count(*)
				  from hr.per_all_people_f papf
					 , hr.per_all_assignments_f paaf
					 , applsys.fnd_user fu
				 where papf.person_id = paaf.person_id
				   and fu.employee_id = papf.person_id
				   and paaf.job_id = pj.job_id
				   and paaf.primary_flag = 'Y'
				   and paaf.assignment_type = 'E'
				   and papf.current_employee_flag = 'Y'
				   and sysdate between papf.effective_start_date and papf.effective_end_date
				   and sysdate between paaf.effective_start_date and paaf.effective_end_date) ct
		  from hr.per_jobs pj
			 , hr.hr_all_organization_units_tl bus_gp
			 , po.po_position_controls_all ppca
		 where ppca.job_id = pj.job_id
		   and pj.business_group_id = bus_gp.organization_id
		   and ppca.end_date is null
		   and pj.date_to is null
		   and pj.job_id in (select pj.job_id
							   from hr.per_all_people_f papf
								  , hr.per_all_assignments_f paaf
							  where papf.person_id = paaf.person_id
							    and paaf.job_id = pj.job_id
							    and paaf.primary_flag = 'Y'
							    and paaf.assignment_type = 'E'
							    and sysdate between papf.effective_start_date and papf.effective_end_date
							    and sysdate between paaf.effective_start_date and paaf.effective_end_date)
	  order by pj.name
			 , pj.business_group_id;

-- ##################################################################
-- SIMPLE VIEW OF APPROVAL LIMITS / DOC TYPES AGAINST JOB TITLE
-- ##################################################################

		select distinct pj.name
			 , pcf.control_function_name
			 , pcga.control_group_name control_group
			 , pcr.amount_limit
			 , pj.business_group_id org_id
		  from po.po_position_controls_all ppca
			 , po.po_control_groups_all pcga
			 , po.po_control_functions pcf
			 , po.po_control_rules pcr
			 , hr.per_jobs pj
			 , hr.hr_all_organization_units_tl bus_gp
		 where ppca.job_id = pj.job_id
		   and pcga.control_group_id = ppca.control_group_id
		   and pcga.control_group_id = pcr.control_group_id
		   and pcf.control_function_id = ppca.control_function_id
		   and pj.business_group_id = bus_gp.organization_id
		   and pcr.object_code = 'DOCUMENT_TOTAL'
		   and sysdate between ppca.start_date and nvl(ppca.end_date, sysdate + 1)
		   and pj.name = 'Anon Buyer'
		   and pj.job_id in (select pj.job_id
							   from hr.per_all_people_f papf
								  , hr.per_all_assignments_f paaf
							  where papf.person_id = paaf.person_id
							    and paaf.job_id = pj.job_id
							    and paaf.primary_flag = 'Y'
							    and paaf.assignment_type = 'E'
							    and sysdate between papf.effective_start_date and papf.effective_end_date
							    and sysdate between paaf.effective_start_date and paaf.effective_end_date)
	  order by pj.name;

-- ##################################################################
-- SIMPLE VIEW OF APPROVAL LIMITS / DOC TYPES AGAINST POSITION
-- ##################################################################

		select pp.name position
			 , pcf.control_function_name
			 , pcga.control_group_name control_group
			 , pcr.amount_limit
			 , ppca.creation_date
		  from po.po_position_controls_all ppca
			 , po.po_control_groups_all pcga
			 , po.po_control_functions pcf
			 , po.po_control_rules pcr
			 , apps.per_positions pp
		 where ppca.position_id = pp.position_id
		   and pcga.control_group_id = ppca.control_group_id
		   and pcga.control_group_id = pcr.control_group_id
		   and pcf.control_function_id = ppca.control_function_id
		   and pcr.object_code = 'DOCUMENT_TOTAL'
		   and sysdate between ppca.start_date and nvl(ppca.end_date, sysdate + 1)
		   and pp.name in ('Buyer 1', 'Buyer 2','Cheese Buyer')
	  order by pp.name;

-- ##################################################################
-- VIEWING THE VALUE LIMITS AGAINST JOB TITLES
-- ##################################################################

		select distinct pj.name job
			 , pcr.amount_limit
		  from po.po_position_controls_all ppca
			 , po.po_control_rules pcr
			 , hr.per_jobs pj
			 , hr.hr_all_organization_units_tl bus_gp
		 where pcr.control_group_id = ppca.control_group_id
		   and pj.business_group_id = bus_gp.organization_id
		   and ppca.end_date is null
		   and ppca.job_id = pj.job_id
	  order by pj.name;

-- ##################################################################
-- VIEWING THE VALUE LIMITS AGAINST POSITIONS
-- ##################################################################

		select pp.name position
			 , pcr.amount_limit
			 , pcr.*
		  from po.po_position_controls_all ppca
			 , po.po_control_rules pcr
			 , apps.per_positions pp
			 , hr.hr_all_organization_units_tl bus_gp
		 where pcr.control_group_id = ppca.control_group_id
		   and pp.business_group_id = bus_gp.organization_id
		   and ppca.end_date is null
		   and ppca.position_id = pp.position_id
		   and pp.name in ('Buyer 1', 'Buyer 2','Cheese Buyer')
	  order by pp.name;
