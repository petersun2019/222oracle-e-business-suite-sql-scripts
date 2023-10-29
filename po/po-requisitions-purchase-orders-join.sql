/*
File Name: po-requisitions-purchase-orders-join.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- REQ TO PO JOIN - RETURN REQ EVEN IF NOT LINKED TO PO
-- PO TO REQ JOIN - RETURN PO EVEN IF NOT LINKED TO REQ
-- REQUISITION HEADERS, LINES, POs AND PROJECTS
-- REQ TO PO INCLUDING PO VALUE
-- POS LINKED TO MULTIPLE REQUISITIONS

*/

-- ###################################################################
-- REQ TO PO JOIN - RETURN REQ EVEN IF NOT LINKED TO PO
-- ###################################################################

		select prha.segment1 requisition
			 , prha.requisition_header_id
			 , prha.creation_date req_created
			 , prha.org_id req_org
			 , haou.name org
			 , prla.suggested_vendor_name
			 , prla.line_num req_line
			 , (replace(replace(prla.item_description,chr(10),''),chr(13),' ')) item_description
			 , prla.vendor_id
			 , pha.segment1 po
			 , pha.type_lookup_code po_type
			 , pha.po_header_id
			 , pha.creation_date po_created
			 , pha.vendor_id
			 , pha.document_creation_method doc_method
		  from po.po_requisition_headers_all prha
		  join po.po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
	 left join po.po_line_locations_all plla on prla.line_location_id = plla.line_location_id
	 left join po.po_lines_all pla on plla.po_line_id = pla.po_line_id
	 left join po.po_headers_all pha on plla.po_header_id = pha.po_header_id
		  join hr.hr_all_organization_units haou on haou.organization_id = prha.org_id
		 where 1 = 1
		   -- and prha.segment1 = 'REQ1234'
		   and pha.segment1 = 'PO1234'
		   -- and pha.vendor_id = 123456
		   and 1 = 1
	  order by prha.creation_date desc
			 , prla.line_num;

-- ###################################################################
-- PO TO REQ JOIN - RETURN PO EVEN IF NOT LINKED TO REQ
-- ###################################################################

		select pha.segment1 po
			 , pha.creation_date po_created
			 , pha.document_creation_method doc_method
			 , pha.type_lookup_code po_type
			 , pla.line_num po_line
			 , (replace(replace(pra.item_description,chr(10),''),chr(13),' ')) item_description
			 , prha.segment1 req
			 , prha.creation_date req_created
			 , prla.suggested_vendor_name
		  from po.po_headers_all pha
		  join po.po_lines_all pla on pla.po_header_id = pha.po_header_id
	 left join po.po_line_locations_all plla on plla.po_line_id = pla.po_line_id
	 left join po.po_requisition_lines_all prla on prla.line_location_id = plla.line_location_id
	 left join po.po_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
		 where 1 = 1
		   and pha.segment1 = 'PO1234'
		   -- and pha.vendor_id = 123456
		   and 1 = 1
	  order by prha.creation_date desc;

-- ###################################################################
-- REQUISITION HEADERS, LINES, POs AND PROJECTS
-- ###################################################################

		select prha.segment1 requisition
			 , prha.requisition_header_id
			 -- , prha.org_id
			 , hou1.short_code req_org
			 -- , hou2.short_code req_line_org
			 , prha.creation_date req_created
			 , prla.creation_date req_line_created
			 , prha.created_by req_created_by
			 , prla.created_by req_line_created_by
			 , prha.approved_date req_approved
			 , pha.segment1 po
			 , pha.po_header_id
			 , hou3.short_code po_org
			 -- , pha.org_id
			 , pha.creation_date po_created
			 -- , pha.approved_date po_approved
			 -- , prha.requisition_header_id
			 -- , prla.suggested_buyer_id
			 -- , prla.vendor_id
			 , prla.suggested_vendor_name
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
			 , prla.currency_code
			 , pav1.agent_name buyer_req_line
			 , fu0.user_name po_created_by
			 , fu0.email_address po_created_by_email
			 , fu3.user_name req_created_by
			 , prha.creation_date req_created
			 , prha.last_update_date req_updated
			 , prha.authorization_status req_status
			 , prla.line_num req_line_num
			 -- , prla.vendor_id
			 , prla.created_by
			 , prla.quantity
			 , prla.unit_price
			 , prla.amount
			 , plla.line_location_id
			 , plla.approved_flag
			 , (replace(replace(prla.item_description,chr(10),''),chr(13),' ')) item_description
			 , fu.user_name req_created_by
			 , pav.agent_name buyer
			 , pha.creation_date po_creation_date
			 , fu.user_name po_created_by
			 , pha.last_update_date po_last_update_date
			 , fu2.user_name po_updated_by
			 , pha.authorization_status po_status
			 , pha.document_creation_method
			 , to_char(pav.end_date_active, 'DD-MON-YYYY') buyer_end_date
			 , hla.location_code req_loc
			 , loc_bill.location_code po_bill
			 , loc_ship.location_code po_ship
			 , ppa.segment1 project
			 , pt.task_number task
		  from po.po_requisition_headers_all prha
		  join po.po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join po.po_line_locations_all plla on prla.line_location_id = plla.line_location_id
	 left join po.po_lines_all pla on plla.po_line_id = pla.po_line_id
	 left join po.po_headers_all pha on plla.po_header_id = pha.po_header_id
	 left join apps.po_agents_v pav on pha.agent_id = pav.agent_id
		  join applsys.fnd_user fu on prha.created_by = fu.user_id
		  join apps.hr_operating_units hou1 on prha.org_id = hou1.organization_id
		  join apps.hr_operating_units hou2 on prla.org_id = hou2.organization_id
		  join apps.hr_operating_units hou3 on pha.org_id = hou3.organization_id
	 left join applsys.fnd_user fu0 on pha.created_by = fu0.user_id
	 left join applsys.fnd_user fu1 on pav.agent_id = fu1.employee_id
	 left join applsys.fnd_user fu2 on pha.last_updated_by = fu2.user_id
		  join applsys.fnd_user fu3 on prha.created_by = fu3.user_id
		  join hr.hr_locations_all hla on hla.location_id = prla.deliver_to_location_id
	 left join hr.hr_locations_all_tl loc_ship on pha.ship_to_location_id = loc_ship.location_id
	 left join hr.hr_locations_all_tl loc_bill on pha.bill_to_location_id = loc_bill.location_id
	 left join po_agents_v pav1 on pav1.agent_id = prla.suggested_buyer_id
	 left join ap_suppliers pv on pv.vendor_id = prla.vendor_id
	 left join ap_supplier_sites_all pvsa on pvsa.vendor_site_id = prla.vendor_site_id and pv.vendor_id = pvsa.vendor_id
	 left join pa_projects_all ppa on ppa.project_id = prda.project_id
	 left join pa_tasks pt on pt.task_id = prda.task_id
		 where 1 = 1
		   and prha.segment1 = 'REQ1234'
		   -- and pha.segment1 in ('PO1234')
		   -- and pav.agent_name = 'Duck, Mr Daffy'
		   -- and pha.document_creation_method = 'AUTOCREATE'
		   -- and prha.authorization_status = 'APPROVED'
		   -- and prha.creation_date > '01-SEP-2021'
		   -- and pha.creation_date > '01-MAR-2021'
		   -- and prla.currency_code is not null and prla.currency_code != 'GBP'
		   -- and pha.creation_date > '05-JAN-2021'
		   and 1 = 1;

-- ###################################################################
-- REQ TO PO INCLUDING PO VALUE
-- ###################################################################

		select prha.segment1 req
			 -- , prha.requisition_header_id
			 , prha.creation_date req_created
			 , pha.segment1 po
			 -- , pha.po_header_id
			 , pha.creation_date po_created
			 , pv.vendor_name
			 , pav.agent_name
			 , sum(pla.quantity*pla.unit_price) po_value
		  from po.po_requisition_headers_all prha
		  join po.po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join po.po_line_locations_all plla on prla.line_location_id = plla.line_location_id
		  join po.po_lines_all pla on plla.po_line_id = pla.po_line_id
		  join po.po_headers_all pha on plla.po_header_id = pha.po_header_id
		  join ap.ap_suppliers pv on pha.vendor_id = pv.vendor_id 
		  join apps.po_agents_v pav on pav.agent_id = pha.agent_id
		 where 1 = 1
		   and prha.creation_date > '01-APR-2019'
		   -- and prha.creation_date between '01-JUL-2015' and '03-JUL-2015'
		   -- and pha.creation_date between '01-JUL-2015' and '03-JUL-2015' and prha.segment1 = '1129771'
		   -- and pha.segment1 in ('1234','4567','6789')
	  group by prha.segment1
			 , pha.segment1
			 , pv.vendor_name
			 , pha.po_header_id
			 , prha.requisition_header_id
			 , pha.creation_date
			 , prha.creation_date
			 , pav.agent_name
	  order by 4;

-- ###################################################################
-- POS LINKED TO MULTIPLE REQUISITIONS
-- ###################################################################

		select pha.segment1 po
			 , pha.creation_date
			 , count(distinct prha.requisition_header_id) ct
		  from po.po_requisition_headers_all prha
		  join po.po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join po.po_line_locations_all plla on plla.line_location_id = prla.line_location_id
		  join po.po_lines_all pla on pla.po_line_id = plla.po_line_id
		  join po.po_headers_all pha on plla.po_header_id = pha.po_header_id
		 where pha.creation_date >= '01-JUN-2016'
		having count(distinct prha.requisition_header_id) > 1
	  group by pha.segment1
			 , pha.creation_date;
