/*
File Name: po-purchase-orders-no-workflow.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ###################################################################
-- PURCHASE ORDERS WITH NO WORKFLOW (USE POXRESPO.SQL TO RESET?)
-- ###################################################################

		select distinct prha.segment1 req
			 , fu_req.user_name || ' (' || fu_req.email_address || ')' req_created_by
			 , prha.creation_date req_created
			 , prha.approved_date req_approved
			 , prha.authorization_status req_status
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
			 , pha.segment1 po
			 , fu_po.user_name || ' (' || fu_po.email_address || ')' po_created_by
			 , pha.creation_date po_created
			 , pha.approved_date po_approved
			 , pha.authorization_status po_status
		  from po.po_requisition_headers_all prha
		  join po.po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join po.po_line_locations_all plla on prla.line_location_id = plla.line_location_id
		  join po.po_lines_all pla on plla.po_line_id = pla.po_line_id
		  join po.po_headers_all pha on plla.po_header_id = pha.po_header_id
		  join ap.ap_suppliers pv on pv.vendor_id = pha.vendor_id
		  join ap.ap_supplier_sites_all pvsa on pvsa.vendor_site_id = pha.vendor_site_id and pv.vendor_id = pvsa.vendor_id
		  join applsys.fnd_user fu_req on prha.created_by = fu_req.user_id
		  join applsys.fnd_user fu_po on pha.created_by = fu_po.user_id
	 left join wf_items wi on pha.wf_item_key = wi.item_key
		 where 1 = 1
		   -- and pha.segment1 = 'PO123456'
		   -- and pha.creation_date > '01-MAY-2018'
		   and wi.item_key is null
		   and (pha.authorization_status is not null and pha.authorization_status != 'APPROVED')
		   and pha.authorization_status = 'IN PROCESS'
	  order by prha.creation_date desc;
