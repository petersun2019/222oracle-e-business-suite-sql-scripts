/*
File Name:		sa-workflows-errors.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- SUMMARISES ALL BUSINESS EVENT ERRORS 
-- REQUISTION AND POERRORS
-- WORKFLOW ERRORS
-- PORPOCHA CHANGES - ERRORED AND STUCK
-- ERRORS - FROM WORKFLOW ANALYZER CONCURRENT PROGRAM OUTPUT
-- ERRORS - ERRORS PER DAY
-- ERROR DETAILS

*/

-- ##################################################################
-- SUMMARISES ALL BUSINESS EVENT ERRORS 
-- ##################################################################

		select substr(subject
			 , instr(wn.subject, ' : ', 1) + 3
			 , instr(wn.subject, ' / ', 1) -(instr(wn.subject, ' : ', 1) + 3)) business_event
			 , count(1) error_count
			 , round(sysdate - max(begin_date), 0) days_since_last_error
			 , to_char(min(begin_date), 'DD-MM-RRRR hh24:mi:ss') first_raised
			 , to_char(max(begin_date), 'DD-MM-RRRR hh24:mi:ss') last_raised
			 , round(max(begin_date) - min(begin_date), 0) date_difference
		  from applsys.wf_notifications wn
		 where 1 = 1
		   and wn.status = 'OPEN'
		   and wn.message_type = 'WFERROR'
		   and wn.message_name = 'DEFAULT_EVENT_ERROR'
	  group by substr(subject
			 , instr(wn.subject, ' : ', 1) + 3
			 , instr(wn.subject, ' / ', 1) -(instr(wn.subject, ' : ', 1) + 3))
	  order by max(begin_date)
			 , min(begin_date);

-- ##################################################################
-- REQUISTION AND POERRORS
-- ##################################################################

		select wiav.item_key
			 , wiav.item_type
			 , wiav.name
			 , wiav.text_value
			 , prha.authorization_status
			 , wi.begin_date
		  from applsys.wf_items wi
		  join applsys.wf_item_attribute_values wiav on wi.item_type = wiav.item_type and wi.item_key = wiav.item_key
		  join po.po_requisition_headers_all prha on to_number(wiav.text_value) = prha.segment1
		 where wiav.item_type in('REQAPPRV', 'POERROR')
		   and wiav.name = 'DOCUMENT_NUMBER'
		   and wi.end_date is null
		   and prha.authorization_status not in('IN PROCESS', 'PRE-APPROVED')
		   and trunc(wi.begin_date) < trunc(sysdate);

-- ##################################################################
-- WORKFLOW ERRORS
-- ##################################################################

		select distinct wi.item_type
			 , wi.item_key
			 , wi.root_activity
			 , wi.owner_role
			 , wi.begin_date
			 , wi.end_date
			 , wias.process_activity
			 , wpa.process_name
			 , wpa.process_version
			 , wpa.activity_name
			 , wias.activity_status
			 , wpa.instance_label
			 , wias.assigned_user
			 , wias.notification_id
			 , wias.error_name
			 , wias.error_message
			 , wias.error_stack
			 , wias.due_date
		  from applsys.wf_items wi
		  join applsys.wf_item_activity_statuses wias on wi.item_type = wias.item_type and wi.item_key = wias.item_key
		  join applsys.wf_activity_transitions wat on wias.process_activity = wat.from_process_activity
		  join applsys.wf_process_activities wpa on wpa.process_item_type = wias.item_type and wpa.instance_id = wias.process_activity
	 left join applsys.wf_item_activity_statuses wias2 on wat.to_process_activity = wias2.process_activity
		 where wi.end_date is null
		   and wias.end_date is null
		   and (wias2.process_activity is null or wias.activity_status = 'ERROR') -- for active and errored workflows
		   and wi.root_activity <> wpa.process_name
		   and wi.item_type = :wf_item_type;

-- ##################################################################
-- PORPOCHA CHANGES - ERRORED AND STUCK
-- ##################################################################

		select distinct wfi.begin_date
			 , pcr.document_type doctype
			 , pcr.document_header_id req_header_id
			 , pcr.document_num req
			 , pcr.ref_po_header_id po_header_id
			 , pcr.ref_po_num po
			 , prha.change_pending_flag
			 , pcr.change_active_flag
			 , wfi.parent_item_type parent_item_type
			 , wfi.parent_item_key parent_item_key
			 , wfi.end_date
			 , wfi.item_type
			 , wfi.item_key
		  from po.po_change_requests pcr
			 , po.po_headers_all pha
			 , po.po_requisition_headers_all prha
			 , applsys.wf_items wfi
			 , applsys.wf_item_activity_statuses wfias
		 where wfi.item_type = wfias.item_type
		   and wfi.item_key = wfias.item_key
		   and wfias.item_type = 'PORPOCHA'
		   and prha.change_pending_flag = 'Y'
		   -- and wfias.error_stack like '%PO_REQCHANGEREQUEST%'
		   and wfias.error_stack is not null
		   and pcr.wf_item_type = wfi.parent_item_type
		   and pcr.wf_item_key = wfi.parent_item_key
		   and pcr.ref_po_num = pha.segment1
		   and pcr.document_header_id = prha.requisition_header_id
		   and wfi.end_date is null
		   -- and pha.segment1 = 'PO1234'
		   -- and pcr.change_active_flag = 'Y'
		   and 1 = 1;

-- ##################################################################
-- ERRORS - FROM WORKFLOW ANALYZER CONCURRENT PROGRAM OUTPUT
-- ##################################################################

		select sta.item_type "item_type"
			 , sta.activity_result_code "result"
			 , pra.process_name "process_label"
			 , pra.instance_label "activity_label"
			 , to_char(count(*),'999,999,999,999') "rows"
		  from wf_item_activity_statuses sta
			 , wf_process_activities pra
		 where sta.activity_status = 'ERROR'
		   and sta.process_activity = pra.instance_id
		   and sta.item_type in ('POAPPRV','REQAPPRV','POXML','POWFRQAG','PORCPT','APVRMDER','PONPBLSH','POSPOACK','PONAUCT','PORPOCHA','PODSNOTF','POSREGV2','POREQCHA','POWFPOAG','POSCHORD','POSASNNB','PONAPPRV','POSCHPDT','POAUTH','POWFDS','POERROR','POSBPR','CREATEPO')
		   and sta.begin_date > '22-may-2018'
	  group by sta.item_type
			 , sta.activity_result_code
			 , pra.process_name
			 , pra.instance_label
	  order by sta.item_type
			 , to_char(count(*)) desc;

		select *
		  from wf_item_activity_statuses sta
			 , wf_process_activities pra
		 where sta.activity_status = 'ERROR'
		   and sta.process_activity = pra.instance_id
		   and sta.begin_date > '01-JUN-2018'
	  order by sta.begin_date desc;

-- ##################################################################
-- ERRORS - ERRORS PER DAY
-- ##################################################################

		select sta.item_type "item_type"
			 , to_char(sta.begin_date, 'yyyy-mm-dd') dt
			 , to_char(count(*),'999,999,999,999') "rows"
		  from wf_item_activity_statuses sta
			 , wf_process_activities pra
		 where sta.activity_status = 'ERROR'
		   and sta.process_activity = pra.instance_id
		   and sta.item_type in ('POAPPRV','REQAPPRV','POXML','POWFRQAG','PORCPT','APVRMDER','PONPBLSH','POSPOACK','PONAUCT','PORPOCHA','PODSNOTF','POSREGV2','POREQCHA','POWFPOAG','POSCHORD','POSASNNB','PONAPPRV','POSCHPDT','POAUTH','POWFDS','POERROR','POSBPR','CREATEPO')
		   and sta.begin_date > '22-may-2018'
	  group by sta.item_type
			 , to_char(sta.begin_date, 'yyyy-mm-dd')
	  order by 2 desc;

-- ##################################################################
-- ERROR DETAILS
-- ##################################################################

		select wi.item_type item_type
			 , wi.item_key item_key
			 , wi.begin_date begin_date
			 , wi.parent_item_type parent_item_type
			 , wi.parent_item_key parent_item_key
			 , wn.subject
		  from applsys.wf_items wi
		  join applsys.wf_items wi2 on wi.parent_item_type = wi2.item_type and wi.parent_item_key = wi2.item_key 
		  join applsys.wf_notifications wn on substr(wn.context, 1, instr(wn.context, ':', instr(wn.context, ':', 1) + 1) - 1) = wi.item_type || ':' || wi.item_key
		 where wi2.end_date is not null
		   and wi.end_date is null
		   and wi.begin_date < sysdate - 1
		   and substr(wn.context, 1, instr(wn.context, ':', instr(wn.context, ':', 1) + 1) - 1) = wi.item_type || ':' || wi.item_key
		   and wi.item_type in('POERROR', 'WFERROR', 'OMERROR', 'ECXERROR')
		   -- and rownum < 10
	  order by 3 desc;
