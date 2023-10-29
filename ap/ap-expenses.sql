/*
File Name: ap-expenses.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- EXPENSE REPORT HEADERS
-- EXPENSE REPORT HEADERS AND LINES
-- EXPENSE REPORT HEADERS AND LINES AND DISTS
-- OPEN EXPENSES NOTIFICATIONS
-- OPEN EXPENSES WORKFLOWS
-- ATTRIBUTE VALUES FOR EXPENSES WORKFLOW
-- APPROVAL LIMITS - COUNT PER EMPLOYEE
-- APPROVAL LIMITS - DETAILS
-- APPROVAL HISTORY
-- POLICIES
-- BASIC TABLES
-- BASIC POLICY LINES 1
-- BASIC POLICY LINES 2
-- POLICY DETAILS WITH EXPENSE REPORTS

*/

-- ##################################################################
-- EXPENSE REPORT HEADERS
-- ##################################################################

		select aerha.report_header_id
			 , hou.name org
			 , aerha.creation_date
			 , aerha.last_update_date
			 , aerha.flex_concatenated cost_centre
			 , fu.user_name created_by
			 , fu.employee_id
			 , papf.full_name created_for
			 , pax.default_code_comb_id
			 , pax.last_update_date
			 , gcc.concatenated_segments
			 , aerha.total
			 , aerha.invoice_num
			 , aerha.description
			 , aerha.expense_status_code
			 , flv.meaning report_status
			 , aerha.audit_code
			 , (select count(*) from ap_expense_report_lines_all aerla where aerla.report_header_id = aerha.report_header_id) lines
			 , '##################'
			 , aerha.expense_current_approver_id
			 , aerha.override_approver_id
			 , aerha.override_approver_name
			 , aerha.workflow_approved_flag
			 , emp.supervisor_id
			 , '###################'
			 , aerha.*
		  from ap.ap_expense_report_headers_all aerha
		  join applsys.fnd_user fu on aerha.created_by = fu.user_id
		  join hr.per_all_people_f papf on aerha.employee_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
		  join apps.per_assignments_x pax on pax.person_id = papf.person_id
		  join apps.hr_operating_units hou on aerha.org_id = hou.organization_id
	 left join per_employees_x emp on emp.employee_id = aerha.override_approver_id
	 left join fnd_lookup_values_vl flv on flv.lookup_code = aerha.expense_status_code and flv.lookup_type = 'EXPENSE REPORT STATUS'
	 left join apps.gl_code_combinations_kfv gcc on gcc.code_combination_id = pax.default_code_comb_id
		 where 1 = 1
		   and aerha.invoice_num = 'E12346'
		   and 1 = 1
	  order by aerha.creation_date desc;

-- ##################################################################
-- EXPENSE REPORT HEADERS AND LINES
-- ##################################################################

		select aerha.report_header_id
			 , aerha.creation_date
			 , fu.user_name created_by
			 , papf.full_name created_for
			 , aerha.total
			 , aerha.invoice_num
			 , flv.meaning report_status
			 , aerla.distribution_line_number line
			 , aerla.amount
			 , aerla.currency_code
			 , to_char(aerla.start_expense_date, 'DD-MON-YYYY') start_expense_date
			 , to_char(aerla.end_expense_date, 'DD-MON-YYYY') end_expense_date
			 , aerla.submitted_amount
			 , aerla.item_description
			 , aerla.attribute_category
			 , aerla.justification
			 , '############################'
			 , aerla.daily_distance
			 , aerla.distance_unit_code
			 , aerla.avg_mileage_rate
			 , aerla.destination_from
			 , aerla.destination_to
			 , aerla.trip_distance
			 , aerla.daily_amount
		  from ap.ap_expense_report_headers_all aerha
		  join ap.ap_expense_report_lines_all aerla on aerla.report_header_id = aerha.report_header_id
		  join applsys.fnd_user fu on aerha.created_by = fu.user_id
		  join hr.per_all_people_f papf on aerha.employee_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join apps.fnd_lookup_values_vl flv on flv.lookup_code = aerha.expense_status_code and flv.lookup_type = 'EXPENSE REPORT STATUS'
		 where 1 = 1
		   and aerha.invoice_num = 'E123456'
		   and 1 = 1
	  order by aerha.creation_date desc;

-- ##################################################################
-- EXPENSE REPORT HEADERS AND LINES AND DISTS
-- ##################################################################

		select aerha.report_header_id
			 , aerha.creation_date
			 , fu.user_name created_by
			 , papf.full_name created_for
			 , aerha.total
			 , aerha.invoice_num
			 , flv.meaning report_status
			 , aerla.distribution_line_number line
			 , aerla.amount
			 , aerla.currency_code
			 , to_char(aerla.start_expense_date, 'DD-MON-YYYY') start_expense_date
			 , to_char(aerla.end_expense_date, 'DD-MON-YYYY') end_expense_date
			 , aerla.submitted_amount
			 , aerla.item_description
			 , aerla.attribute_category
			 , aerla.justification
			 , '############################'
			 , aerda.creation_date
			 , aerda.code_combination_id
			 , aerda.cost_center dist_cost_centre
			 , gcc.concatenated_segments
			 , awsla.cost_center approval_cost_centre
		  from ap.ap_expense_report_headers_all aerha
	 left join ap_expense_report_lines_all aerla on aerla.report_header_id = aerha.report_header_id
	 left join ap_exp_report_dists_all aerda on aerla.report_line_id = aerda.report_line_id and aerda.report_header_id = aerha.report_header_id
	 left join applsys.fnd_user fu on aerha.created_by = fu.user_id
	 left join hr.per_all_people_f papf on aerha.employee_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join apps.per_assignments_x pax on pax.person_id = papf.person_id
	 left join fnd_lookup_values_vl flv on flv.lookup_code = aerha.expense_status_code and flv.lookup_type = 'EXPENSE REPORT STATUS'
	 left join apps.gl_code_combinations_kfv gcc on gcc.code_combination_id = pax.default_code_comb_id
	 left join ap_web_signing_limits_all awsla on awsla.employee_id = papf.person_id
		 where 1 = 1
		   and aerha.invoice_num = 'E123456'
		   and 1 = 1
	  order by aerha.creation_date desc;

		select * from ap_exp_report_dists_all where segment3 = '630';

-- ##################################################################
-- OPEN EXPENSES NOTIFICATIONS
-- ##################################################################

		select wn.notification_id
			 , wn.message_type
			 , wn.message_name
			 , wn.item_key
			 , wn.begin_date
			 , wn.end_date
			 , wn.recipient_role
			 , wn.status
			 , wn.mail_status
			 , wn.original_recipient
			 , wn.from_user
			 , wn.to_user
			 , wn.subject
			 , wn.from_role
			 , wn.user_key
		  from applsys.wf_notifications wn
		 where 1 = 1
		   and wn.message_type = 'APEXP'
		   and wn.end_date is null
	  order by wn.begin_date desc;

-- ##################################################################
-- OPEN EXPENSES WORKFLOWS
-- ##################################################################

		select wi.item_type
			 , wi.item_key
			 , wi.root_activity
			 , wi.owner_role
			 , wi.begin_date
			 , wi.user_key
		  from applsys.wf_items wi
		 where wi.item_type = 'APEXP' 
		   and wi.end_date is null;

-- ##################################################################
-- ATTRIBUTE VALUES FOR EXPENSES WORKFLOW
-- ##################################################################

		select wiav.item_type
			 , wiav.item_key
			 , wiat.display_name
			 , wia.name
			 , wiav.text_value
			 , wiav.number_value
			 , wiav.date_value
		  from applsys.wf_item_attribute_values wiav 
	 left join applsys.wf_item_attributes wia on wiav.item_type = wia.item_type and wiav.name = wia.name
	 left join applsys.wf_item_attributes_tl wiat on wia.item_type = wiat.item_type and wia.name = wiat.name 
	 left join applsys.wf_items wi on wi.item_type = wiav.item_type and wi.item_key = wiav.item_key and wi.begin_date > '13-JUL-2016'
		 where (wiav.text_value is not null or wiav.number_value is not null or wiav.date_value is not null)
		   and wiav.item_type = 'APEXP'
		   and wiav.item_key = '123456'
		   and 1 = 1;

-- ##################################################################
-- APPROVAL LIMITS - COUNT PER EMPLOYEE
-- ##################################################################

		select awsla.employee_id
			 , ppx.full_name
			 , ppx.employee_number
			 , max(awsla.last_update_date)
			 , count(*) 
		  from ap_web_signing_limits_all awsla
		  join per_people_x ppx on awsla.employee_id = ppx.person_id
		 where awsla.employee_id = 123456
	  group by awsla.employee_id 
			 , ppx.full_name
			 , ppx.employee_number
	  order by 3;

-- ##################################################################
-- APPROVAL LIMITS - DETAILS
-- ##################################################################

		select ppx.full_name
			 , ppx.employee_number
			 , ppx.person_id
			 , awsla.document_type
			 , awsla.cost_center
			 , awsla.signing_limit
			 , awsla.org_id
			 , awsla.creation_date created
			 , fu1.user_name created_by
			 , awsla.last_update_date updated
			 , fu2.user_name updated_by
		  from ap_web_signing_limits_all awsla
		  join per_people_x ppx on awsla.employee_id = ppx.person_id
		  join fnd_user fu1 on awsla.created_by = fu1.user_id
		  join fnd_user fu2 on awsla.last_updated_by = fu2.user_id
		 where 1 = 1
		   and awsla.employee_id in (123456)
		   and 1 = 1;

-- ##################################################################
-- APPROVAL HISTORY
-- ##################################################################

		select aerha.invoice_num
			 , aerha.creation_date expense_created
			 , flv.meaning report_status
			 , aerha.description
			 , an.note_type
			 , an.creation_date approval_note_created
			 , an.notes_detail
			 , an.note_type
			 , an.note_source
			 , pex.full_name
			 , pex.employee_num
			 , papf.full_name created_for
			 , (select count(*) from ap_web_signing_limits_all awsla where awsla.employee_id = pex.employee_id) apprv_limits
		  from ap_notes an
		  join fnd_user fu on an.entered_by = fu.user_id
		  join per_employees_x pex on pex.employee_id = fu.employee_id
		  join ap_expense_report_headers_all aerha on aerha.report_header_id = an.source_object_id
		  join hr.per_all_people_f papf on aerha.employee_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join fnd_lookup_values_vl flv on flv.lookup_code = aerha.expense_status_code and flv.lookup_type = 'EXPENSE REPORT STATUS'
		 where 1 = 1
		   and aerha.invoice_num = 'IEXP123456'
		   and 1 = 1
	  order by an.creation_date;

-- ##################################################################
-- POLICIES
-- ##################################################################

-- BASIC TABLES

select * from ap_pol_headers order by last_update_date desc;
select * from ap_pol_lines order by last_update_date desc;
select * from fnd_lookup_values_vl where lookup_code in ('DIESEL','PETROL','PETROLEUM');
select * from ap_pol_schedule_periods;
select avg_mileage_rate, count(*) from ap_expense_report_lines_all where avg_mileage_rate is not null group by avg_mileage_rate order by 1 desc;

-- BASIC POLICY LINES 1

		select policy_line_id,policy_id,schedule_period_id,status,currency_code,rate,vehicle_type,fuel_type,creation_date,created_by,last_update_login,last_update_date,last_updated_by,parent_line_id
		  from ap_pol_lines
		 where policy_line_id in (123,124);

-- BASIC POLICY LINES 2

		select pol.policy_line_id
			 , pol.policy_id
			 , pol.schedule_period_id
			 , pol.status
			 , pol.currency_code
			 , pol.rate
			 , pol.vehicle_type
			 , pol.fuel_type
			 , pol.creation_date
			 , pol.created_by
			 , pol.last_update_login
			 , pol.last_update_date
			 , pol.last_updated_by
			 , pol.parent_line_id
		  from ap_pol_lines pol
		  join ap_pol_schedule_periods pols on pol.schedule_period_id = pols.schedule_period_id
		 where 1 = 1
		   and pol.rate = 0.45
		   and sysdate between pols.start_date and nvl(pols.end_date, sysdate + 1);

-- POLICY DETAILS WITH EXPENSE REPORTS

		select pol.policy_line_id
			 , pol.policy_id
			 , pol.schedule_period_id
			 , pol.status
			 , pol.currency_code
			 , pol.rate
			 , pol.vehicle_type
			 , pol.fuel_type
			 , pol.creation_date
			 , pol.created_by
			 , pol.last_update_login
			 , pol.last_update_date
			 , pol.last_updated_by
			 , pol.parent_line_id
			 , '##############'
			 , pols.schedule_period_name
			 , pols.start_date
			 , pols.end_date
			 , '#############'
			 , aerla.*
		  from ap_expense_report_lines_all aerla
		  join ap_pol_lines pol on aerla.currency_code = pol.currency_code and pol.rate = aerla.avg_mileage_rate
		  join ap_pol_schedule_periods pols on pol.schedule_period_id = pols.schedule_period_id and sysdate between pols.start_date and nvl(pols.end_date, sysdate + 1)
		 where aerla.creation_date > '30-NOV-2019' and aerla.report_header_id = 123456
	  order by aerla.creation_date;
