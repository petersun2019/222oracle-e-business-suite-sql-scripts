/*
File Name:		po-buyers.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- BASIC BUYERS VIEW
-- BUYERS WITH USAGE DATA

*/

-- ##################################################################
-- BASIC BUYERS VIEW
-- ##################################################################

		select ppx.full_name
			 , ppx.business_group_id
			 , ppx.creation_date
			 , ppx.person_id
			 , '#' || ppx.employee_number employee_number
			 , haou.name hr_org
			 , haou.organization_id
			 , pptt.user_person_type person_type
			 , pax.assignment_number
			 , pax.supervisor_id
			 , pax.assignment_type
			 , look_asg_status.meaning assign_status
			 , fu.user_name
			 , fu.email_address
			 , fu.start_date
			 , fu.end_date
			 , pj.name job_title
			 , pj.creation_date job_created
			 , pp.name position
			 , pp.creation_date position_created
			 , pg.name grade
			 , gcc.concatenated_segments default_expense_account
		  from per_people_x ppx -- per_people_x only returns records where the data is date-tracked to sysdate
		  join po_agents_v pav on ppx.person_id = pav.agent_id
		  join per_assignments_x pax on ppx.person_id = pax.person_id -- per_assignments_x only returns records where the data is date-tracked to sysdate
	 left join per_assignment_status_types past on pax.assignment_status_type_id = past.assignment_status_type_id
	 left join hr_all_organization_units haou on pax.organization_id = haou.organization_id
	 left join fnd_user fu on fu.employee_id = ppx.person_id
	 left join per_jobs pj on pj.job_id = pax.job_id
	 left join per_positions pp on pax.position_id = pp.position_id
	 left join per_grades pg on pax.grade_id = pg.grade_id
	 left join gl_code_combinations_kfv gcc on pax.default_code_comb_id = gcc.code_combination_id
	 left join fnd_lookup_values_vl look_asg_status on look_asg_status.lookup_code = past.per_system_status and look_asg_status.lookup_type = 'PER_ASS_SYS_STATUS'
	 left join per_person_types_tl pptt on ppx.person_type_id = pptt.person_type_id
	 left join fnd_user fu on fu.employee_id = ppx.person_id
		 where 1 = 1
		   -- and pav.agent_id in (123, 456, 789)
		   -- and pj.name = 'Anon Buyer'
		   -- and ppx.full_name in ('Cheese, Mr Cheddar','Bread, Mrs Rye')
		   -- and pp.name in ('Senior Buyer')
		   -- and fu.user_name in ('CHEESE_USER')
		   and 1 = 1;

-- ##################################################################
-- BUYERS WITH USAGE DATA
-- ##################################################################

		select papf.full_name
			 , pa.start_date_active buyer_start
			 , pa.end_date_active buyer_end
			 , pa.attribute1 telno
			 , pa.last_update_date
			 , fu.user_name
			 , fu.description
			 , fu.end_date ibs_end
			 , haout.name hr_org
			 , hlat.location_code
			 , hlat.description location
			 , (select count(*) from po.po_headers_all pha, apps.po_agents pa where pa.agent_id = pha.agent_id and pa.agent_id = papf.person_id) po_count
			 , (select min(pha.creation_date) from po.po_headers_all pha, apps.po_agents pa where pa.agent_id = pha.agent_id and pa.agent_id = papf.person_id) first_po_raised
			 , (select max(pha.creation_date) from po.po_headers_all pha, apps.po_agents pa where pa.agent_id = pha.agent_id and pa.agent_id = papf.person_id) last_po_raised
			 , trim(to_char(months_between(sysdate, (select max(pha.creation_date) from po.po_headers_all pha, apps.po_agents pa where pa.agent_id = pha.agent_id and pa.agent_id = papf.person_id)), 9999.99)) months_since_last_po
			 , trim(to_char(months_between(sysdate, pa.start_date_active), 9999.99)) months_as_buyer
		  from po.po_agents pa
		  join hr.per_all_people_f papf on pa.agent_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
		  join hr.per_all_assignments_f paaf on papf.person_id = paaf.person_id and sysdate between paaf.effective_start_date and paaf.effective_end_date
		  join hr.hr_all_organization_units_tl haout on paaf.organization_id = haout.organization_id
		  join hr.hr_locations_all_tl hlat on paaf.location_id = hlat.location_id
		  join applsys.fnd_user fu on fu.employee_id = papf.person_id
		 where paaf.assignment_type = 'E'
		   and paaf.primary_flag = 'Y'
		   and pa.end_date_active is null
		   and fu.end_date is null
		   and papf.full_name = 'Cheese, Mr Cheddar'
	  order by 1;
