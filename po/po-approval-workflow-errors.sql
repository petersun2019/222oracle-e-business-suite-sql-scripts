/*
File Name: po-approval-workflow-errors.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- REQUISITION ACTION HISTORY
-- PO APPROVAL HISTORY 
-- REQUISITION CANCELLATIONS
-- IDENTIFIES ALL ACTIVE ERRORS - VIA NOTIFICATIONS TABLE
-- PURCHASE ORDERS WITH IN PROCESS / PRE-APPROVED WITH NO OPEN WORKFLOWS 
-- IN-PROCESS / PRE-APPROVED POS WITH WORKFLOW ERRORS
-- IN-PROCESS / PRE-APPROVED REQS WITH WORKFLOW ERRORS

*/

-- ##################################################################
-- IDENTIFIES ALL ACTIVE ERRORS - VIA NOTIFICATIONS TABLE
-- ##################################################################

		select pha.segment1
			 , wi.item_type
			 , wi.item_key
			 , wi.begin_date
			 , wi.parent_item_type
			 , wi.parent_item_key
			 , wn.subject
		  from applsys.wf_items wi
		  join applsys.wf_items wi2 on wi.parent_item_type = wi2.item_type
		  join applsys.wf_notifications wn on substr(wn.context, 1, instr(wn.context, ':', instr(wn.context, ':', 1) + 1) - 1) = wi.item_type || ':' || wi.item_key
		  join po.po_headers_all pha on wi.parent_item_key = pha.wf_item_key
		   and wi.parent_item_key = wi2.item_key
		 where wi2.end_date is null
		   and wi.end_date is null
		   and wi.item_type in('POERROR', 'WFERROR')
	  order by 3 desc;

-- ##################################################################
-- PURCHASE ORDERS WITH IN PROCESS / PRE-APPROVED WITH NO OPEN WORKFLOWS 
-- ##################################################################

		select distinct ph.segment1
			 , ph.comments
			 , pav.agent_name buyer
			 , pv.vendor_name
			 , pcr.ref_po_num
		  from po.po_headers_all ph
		  join apps.po_agents_v pav on ph.agent_id = pav.agent_id
		  join apps.po_vendors pv on ph.vendor_id = pv.vendor_id
	 left join po.po_change_requests pcr on ph.segment1 = pcr.ref_po_num
		 where ph.authorization_status in('IN PROCESS', 'PRE-APPROVED')
		   and not exists (select 'WF EXISTS'
							 from applsys.wf_items wi
						    where wi.item_type = ph.wf_item_type
							  and wi.item_key = ph.wf_item_key
							  and wi.end_date is null)
	  order by 1;

-- ##################################################################
-- IN-PROCESS / PRE-APPROVED POS WITH WORKFLOW ERRORS
-- ##################################################################

		select ac.name activity
			 , ac.display_name "activity display name"
			 , ias.activity_result_code result
			 , ias.error_name
			 , ias.error_message
			 , ias.error_stack
			 , ias.item_type
			 , ias.begin_date
			 , pha.wf_item_key "po wf_item_key"
			 , pha.wf_item_type "po wf_item_type"
			 , pha.segment1 "po_num"
			 , pav.agent_name buyer
			 , pha.creation_date
			 , pha.authorization_status
			 , pha.revision_num
			 , pha.comments "po_description"
			 , papf.full_name hr_full_name
			 , haout.name organization_name
			 , hlat.location_code
			 , wi.end_date
			 , bus_gp.name bus_gp
		  from apps.wf_item_activity_statuses ias
		  join apps.wf_process_activities pa on ias.process_activity = pa.instance_id
		  join apps.wf_activities_vl ac on pa.activity_item_type = ac.item_type
		  join apps.wf_activities_vl ap on pa.process_item_type = ap.item_type
		  join apps.wf_items i on i.item_key = ias.item_key
		  join apps.po_headers_all pha on pha.wf_item_key = ias.item_key
		  join applsys.fnd_user us on pha.created_by = us.user_id
		  join hr.per_all_people_f papf on us.employee_id = papf.person_id 
		  join hr.per_all_assignments_f paaf on papf.person_id = paaf.person_id 
		  join hr.hr_all_organization_units_tl haout on paaf.organization_id = haout.organization_id
		  join hr.hr_locations_all_tl hlat on paaf.location_id = hlat.location_id
		  join applsys.wf_items wi on wi.item_type = pha.wf_item_type
		  join apps.po_agents_v pav on pha.agent_id = pav.agent_id
		  join hr.hr_all_organization_units_tl bus_gp on pha.org_id = bus_gp.organization_id
		   and pa.activity_name = ac.name
		   and pa.process_name = ap.name
		   and pa.process_version = ap.version
		   and wi.item_key = pha.wf_item_key
		   and i.begin_date < nvl(ac.end_date, i.begin_date + 1)
		   and sysdate between papf.effective_start_date and papf.effective_end_date
		   and sysdate between paaf.effective_start_date and paaf.effective_end_date
		 where ias.item_type = 'POAPPRV'
		   and ias.activity_status = 'ERROR'
		   and i.item_type = 'POAPPRV'
		   and paaf.primary_flag = 'Y'
		   and paaf.assignment_type = 'E'
		   and ias.error_stack is not null 
		   and pha.authorization_status in('IN PROCESS', 'PRE-APPROVED')
		   -- and ac.display_name = 'Does Approver Have Authority?'
		   and pha.creation_date > '01-SEP-2011'
	  order by pha.creation_date desc;

-- ##################################################################
-- IN-PROCESS / PRE-APPROVED REQS WITH WORKFLOW ERRORS
-- ##################################################################

		select ac.name activity
			 , ac.display_name "activity display name"
			 , ias.activity_result_code result
			 , ias.error_name
			 , ias.error_message
			 , ias.error_stack
			 , ias.item_type
			 , prha.segment1 || ' - ' || trunc(prha.creation_date) req_date
			 , ias.begin_date
			 , fu.description created_by
			 , prha.wf_item_key "req wf_item_key"
			 , prha.wf_item_type "req wf_item_type"
			 , prha.creation_date
			 , prha.authorization_status
			 , prha.description
			 , wi.end_date
		  from apps.wf_item_activity_statuses ias
		  join apps.wf_process_activities pa on ias.process_activity = pa.instance_id
		  join apps.wf_activities_vl ac on pa.activity_item_type = ac.item_type
		  join apps.wf_activities_vl ap on pa.process_item_type = ap.item_type
		  join apps.wf_items i on i.item_key = ias.item_key
		  join apps.po_requisition_headers_all prha on prha.wf_item_key = ias.item_key
		  join applsys.wf_items wi on wi.item_type = prha.wf_item_type
		  join applsys.fnd_user fu on prha.created_by = fu.user_id
		   and pa.activity_name = ac.name
		   and pa.process_name = ap.name
		   and pa.process_version = ap.version
		   and i.begin_date >= ac.begin_date
		   and i.begin_date < nvl(ac.end_date, i.begin_date + 1)
		   and wi.item_key = prha.wf_item_key
		 where ias.item_type = 'REQAPPRV'
		   and ias.error_stack is not null
		   and ias.activity_status = 'ERROR'
		   and i.item_type = 'REQAPPRV'
		   and prha.authorization_status in('IN PROCESS', 'PRE-APPROVED')
		   and prha.creation_date > '31-MAR-2009'
	  order by prha.creation_date desc;
