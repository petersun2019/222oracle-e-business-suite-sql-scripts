/*
File Name: po-change-requests.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- CHANGE REQUESTS TABLE DUMPS
-- CHANGE REQUESTS DETAILS 1
-- CHANGE REQUESTS DETAILS 2
-- CHANGE REQUESTS COUNTING

*/

-- ##################################################################
-- CHANGE REQUESTS TABLE DUMPS
-- ##################################################################

select * from po_change_requests pcr where pcr.ref_po_num = 'PO123456';

-- ##################################################################
-- CHANGE REQUESTS DETAILS 1
-- ##################################################################

		select pcr.creation_date
			 , prha.segment1 req
			 , hou.short_code org
			 , pcr.initiator
			 , pcr.action_type
			 , pcr.request_level
			 , pcr.request_status
			 , pcr.response_date
			 , pcr.change_active_flag
			 , pcr.wf_item_type
			 , pcr.wf_item_key
			 , wi.end_date wf_end_date
			 , ppa.segment1 project
			 , ppa.project_id 
			 , pha.segment1 po
			 , pav.agent_name buyer
			 , pav.agent_id
			 , haou2.name buyer_org
			 , pax.person_id
			 , pax.assignment_id
			 , haou.name project_org
		  from po_change_requests pcr
	 left join apps.po_requisition_headers_all prha on pcr.document_header_id = prha.requisition_header_id
	 left join po_requisition_lines_all prla on pcr.document_line_id = prla.requisition_line_id and prla.requisition_header_id = prha.requisition_header_id
	 left join po_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
	 left join pa_projects_all ppa on ppa.project_id = prda.project_id
	 left join hr_all_organization_units haou on haou.organization_id = ppa.carrying_out_organization_id
	 left join po_headers_all pha on pha.po_header_id = pcr.ref_po_header_id
	 left join po_agents_v pav on pha.agent_id = pav.agent_id
	 left join per_assignments_x pax on pax.person_id = pav.agent_id
	 left join hr_all_organization_units haou2 on haou2.organization_id = pax.organization_id
	 left join wf_items wi on wi.item_type = pcr.wf_item_type and wi.item_key = pcr.wf_item_key
	 left join hr_operating_units hou on prha.org_id = hou.organization_id
		 where 1 = 1
		   and prha.segment1 = '123456'
		   -- and pcr.change_active_flag = 'N'
		   -- and prha.change_pending_flag = 'N'
		   -- and pcr.creation_date > '28-JUN-2019'
		   -- and hou.short_code = 'MAIN ORG'
		   -- and to_char(pcr.response_date, 'HH24') = '04'
		   -- and pcr.creation_date < '11-SEP-2018'
		   -- and wi.end_date is not null
		   -- and pcr.creation_date > '01-SEP-2018'
		   -- and pcr.creation_date < '11-SEP-2018'
		   -- and wi.end_date is not null
		   and 1 = 1;

-- ##################################################################
-- CHANGE REQUESTS DETAILS 2
-- ##################################################################

		select pcr.creation_date
			 , prha.segment1 req 
			 , pcr.initiator
			 , pcr.action_type
			 , pcr.request_level
			 , pcr.change_active_flag
			 , pcr.wf_item_type
			 , pcr.wf_item_key
			 , wi.end_date wf_end_date
			 , ppa.segment1 project
			 , ppa.project_id
			 , pha.segment1 po
			 , pav.agent_name buyer
			 , pav.agent_id
			 , pax.person_id
			 , pax.assignment_id
			 , pda.po_distribution_id
			 , prda.distribution_id
			 , pla.po_line_id
			 , haou5.name || ' (' || haou5.organization_id || ')' po_org
			 , haou2.name || ' (' || haou2.organization_id || ')' buyer_org
			 , haou1.name || ' (' || haou1.organization_id || ')' project_org
			 , haou3.name || ' (' || haou3.organization_id || ')' task_org
			 , haou4.name || ' (' || haou4.organization_id || ')' top_task_org
		  from po_change_requests pcr
		  join po_requisition_headers_all prha on pcr.document_header_id = prha.requisition_header_id
		  join po_requisition_lines_all prla on pcr.document_line_id = prla.requisition_line_id and prla.requisition_header_id = prha.requisition_header_id
		  join po_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
		  join po_headers_all pha on pha.po_header_id = pcr.ref_po_header_id
		  join po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join po_distributions_all pda on pla.po_line_id = pda.po_line_id
		  join pa_projects_all ppa on ppa.project_id = pda.project_id
		  join pa_tasks pt on ppa.project_id = pt.project_id and pda.task_id = pt.task_id and pt.project_id = ppa.project_id
		  join po_agents_v pav on pha.agent_id = pav.agent_id
		  join per_assignments_x pax on pax.person_id = pav.agent_id
		  join wf_items wi on wi.item_type = pcr.wf_item_type and wi.item_key = pcr.wf_item_key
		  join pa_tasks pt2 on pt.top_task_id = pt2.task_id
		  join hr_all_organization_units haou1 on haou1.organization_id = ppa.carrying_out_organization_id
		  join hr_all_organization_units haou2 on haou2.organization_id = pax.organization_id
		  join hr_all_organization_units haou3 on haou3.organization_id = pt.carrying_out_organization_id
		  join hr_all_organization_units haou4 on haou4.organization_id = pt2.carrying_out_organization_id
		  join hr_all_organization_units haou5 on haou5.organization_id = pda.expenditure_organization_id
		 where 1 = 1
		   -- and pcr.document_num = '123456'
		   and pcr.creation_date > '01-MAR-2019'
		   -- and pcr.creation_date < '11-SEP-2018'
		   -- and wi.end_date is not null
		   and 1 = 1;

-- ##################################################################
-- CHANGE REQUESTS COUNTING
-- ##################################################################

		select to_char(pcr.creation_date, 'YYYY-MM') change_date
			 , hou.name
			 , hou.short_code
			 , count(distinct pcr.document_header_id) ct
		  from po_change_requests pcr
		  join po_requisition_headers_all prha on pcr.document_header_id = prha.requisition_header_id
		  join po_headers_all pha on pha.po_header_id = pcr.ref_po_header_id
		  join hr_operating_units hou on prha.org_id = hou.organization_id
		 where 1 = 1
		   and pcr.creation_date > '01-APR-2018'
		   and pcr.creation_date < '01-APR-2019'
		   and 1 = 1
	  group by to_char(pcr.creation_date, 'YYYY-MM')
			 , hou.name
			 , hou.short_code
	  order by to_char(pcr.creation_date, 'YYYY-MM')
			 , hou.name
			 , hou.short_code;
