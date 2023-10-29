/*
File Name: po-autocreate-report.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
Query I used to use to list all requisitions which were eligible to be converted to POs

*/

-- ##################################################################
-- PO AUTOCREATE REPORT
-- ##################################################################

		select prha.segment1 req_num
			 , fu.user_name || ' (' || fu.description || ')' created_by
			 , trim(to_char((prla.quantity * prla.unit_price), '999,999,999.99')) line_value
			 , prla.line_num
			 , pav.agent_name buyer
			 , prha.creation_date
			 , prha.interface_source_code
			 , prla.creation_date line_creation_date
			 , mcb.segment1 || '.' || mcb.segment2 purchase_category
			 , case
			 -- ----------------------------------------------- PUNCHOUT
					when prla.catalog_type = 'EXTERNAL'
					     and prla.catalog_source = 'EXTERNAL'
					     and prla.source_type_code = 'VENDOR' then 'PUNCHOUT'
			 -- -----------------------------------------------INTERNAL CATALOGUE
					when prla.catalog_type = 'CATALOG'
					     and prla.catalog_source = 'INTERNAL'
					     and prla.source_type_code = 'VENDOR' then 'LOCAL_CATALOGUE'
			 -- ----------------------------------------------- NON CATALOGUE
					when prla.catalog_type = 'NONCATALOG'
					     and prla.catalog_source = 'INTERNAL'
					     and prla.source_type_code = 'VENDOR' then 'NONCAT'
					else 'Other'
			   end order_type
			 , prla.suggested_vendor_product_code catalogue_code
			 , prha.emergency_po_num
			 , to_char(prla.need_by_date, 'DD-MON-RRRR') need_by_date
			 , prla.item_description
			 , hlat.description deliver_to
			 , prla.quantity
			 , prla.unit_price
			 , prla.quantity * prla.unit_price line_value
			 , prla.unit_meas_lookup_code uom
			 , prla.note_to_agent note_to_buyer
			 , prla.note_to_vendor note_to_supplier
			 , prla.suggested_vendor_name supplier
			 , prla.suggested_vendor_location site
			 , prha.description req_description
			 , prda.gl_encumbered_date req_line_gl_date
		  from po.po_requisition_headers_all prha
		  join po.po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join po.po_req_distributions_all prda on prda.requisition_line_id = prla.requisition_line_id
	 left join po.po_line_locations_all plla on plla.line_location_id = prla.line_location_id
		  join hr.hr_locations_all_tl hlat on prla.deliver_to_location_id = hlat.location_id
		  join inv.mtl_categories_b mcb on mcb.category_id = prla.category_id
		  join applsys.fnd_user fu on prha.created_by = fu.user_id
	 left join po_agents_v pav on pav.agent_id = prla.suggested_buyer_id
		 where 1 = 1
		   and prha.authorization_status = 'APPROVED'
		   and (prla.cancel_flag is null or prla.cancel_flag = 'N')
		   and prla.closed_date is null
		   and plla.po_header_id is null -- not converted to po yet
		   -- and prha.creation_date > '01-JAN-2021'
		   -- and prla.suggested_buyer_id is not null
	  order by prha.creation_date desc
			 , prla.line_num;
