/*
File Name:		po-receipts.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- RECEIPT HEADERS
-- BASIC RECEIPT DETAILS LINKED TO POS AND REQS
-- REQ AND PO FIRST RECIEPT DATE
-- RECEIPT COUNTS PER REQ AND PO
-- RECEIPT COUNTS PER PO
-- RECEIPT COUNTS
-- REQ TO PO TO RECEIPT TO INVOICE
-- REQ TO PO TO RECEIPT - NO AP INVOICE JOIN

*/

-- ###################################################################
-- RECEIPT HEADERS
-- ###################################################################

		select fu.description
			 , rsh.creation_date
			 , rsh.receipt_num
		  from po.rcv_shipment_headers rsh
		  join applsys.fnd_user fu on rsh.created_by = fu.user_id
		 where rsh.creation_date > '20-JUN-2016';

-- ###################################################################
-- BASIC RECEIPT DETAILS LINKED TO POS AND REQS
-- ###################################################################

		select mp.organization_code org
			 , prha.segment1 req_num
			 , prha.creation_date req_date
			 , pla.line_num po_line_num
			 , pla.po_line_id
			 , pla.item_id
			 , pla.line_num
			 , msib.segment1
			 , msib.description
			 , pha.segment1 po
			 , pha.authorization_status po_status
			 , pha.po_header_id
			 , pha.creation_date po_date
			 , rsh.receipt_num receipt
			 , rsh.creation_date rcpt_create_date
			 , rt.quantity qty_received
			 , rt.transaction_type
			 , rt.destination_type_code
			 , pda.quantity_billed qty_billed
			 , pda.accrue_on_receipt_flag
			 , (pda.quantity_billed * prla.unit_price) amt_billed
			 , fu.user_name
			 , ppa.segment1 project
			 , '########' rsl
			 , rt.shipment_header_id
			 , rt.shipment_line_id
			 , rsl.shipment_line_status_code
			 , rsl.shipment_line_id
		  from po.po_requisition_headers_all prha
		  join po.po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join po.po_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
		  join po.po_line_locations_all plla on plla.line_location_id = prla.line_location_id
		  join po.po_lines_all pla on pla.po_line_id = plla.po_line_id
		  join po.po_headers_all pha on pha.po_header_id = plla.po_header_id
		  join po.po_distributions_all pda on pla.po_line_id = pda.po_line_id
		  join po.rcv_transactions rt on pda.po_distribution_id = rt.po_distribution_id
		  join po.rcv_shipment_headers rsh on rt.shipment_header_id = rsh.shipment_header_id
		  join po.rcv_shipment_lines rsl on rt.shipment_line_id = rsl.shipment_line_id
		  join applsys.fnd_user fu on rsh.created_by = fu.user_id
		  join hr.hr_all_organization_units haou on plla.ship_to_organization_id = haou.organization_id
		  join inv.mtl_parameters mp on mp.organization_id = rt.organization_id
	 left join inv.mtl_system_items_b msib on pla.item_id = msib.inventory_item_id and msib.organization_id = mp.organization_id
	 left join pa.pa_projects_all ppa on pda.project_id = ppa.project_id
		 where 1 = 1
		   -- and pha.creation_date < '12-MAR-2021'
		   -- and rsh.creation_date > '25-MAY-2016'
		   -- and pha.segment1 = 'PO123456'
		   -- and pla.line_num = 10
		   -- and pla.item_id is not null
		   -- and mp.organization_id = 1234
		   -- and rsh.receipt_num is null
		   -- and rsh.receipt_num in ('123',456','789')
		   -- and rt.transaction_type = 'RECEIVE'
		   -- and rt.destination_type_code = 'EXPENSE'
		   -- and fu.description = 'Cheese Machine'
		   and fu.user_name in ('CHEESE_USER')
		   and 1 = 1;

-- ###################################################################
-- REQ AND PO FIRST RECIEPT DATE
-- ###################################################################

		select prha.segment1 req
			 , prha.creation_date req_date
			 , plla.need_by_date need_by
			 , pla.line_num po_line
			 , pha.segment1 po_num
			 , pha.creation_date po_date
			 , iio.organization_code inv_org
			 , tbl_rx.rcpt_date first_receipt_date
			 , pv.vendor_name supplier
			 , pv.segment1 supp_number
			 , pvsa.vendor_site_code site
		  from po.po_requisition_headers_all prha
		  join po.po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join po.po_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
		  join po.po_line_locations_all plla on plla.line_location_id = prla.line_location_id
		  join po.po_lines_all pla on pla.po_line_id = plla.po_line_id
		  join po.po_headers_all pha on pha.po_header_id = plla.po_header_id
		  join po.po_distributions_all pda on pla.po_line_id = pda.po_line_id
		  join apps.po_vendors pv on pha.vendor_id = pv.vendor_id
		  join apps.po_vendor_sites_all pvsa on pha.vendor_site_id = pvsa.vendor_site_id and pv.vendor_id = pvsa.vendor_id
		  join apps.invbv_inventory_organizations iio on plla.ship_to_organization_id = iio.organization_id
	 left join (select rt.po_distribution_id
					 , min(rsh.creation_date) rcpt_date
				  from po.rcv_transactions rt
			 left join po.rcv_shipment_headers rsh on rt.shipment_header_id = rsh.shipment_header_id
			 left join po.rcv_shipment_lines rsl on rt.shipment_line_id = rsl.shipment_line_id
				 where nvl (rt.transaction_type, 'RECEIVE') = 'RECEIVE'
				   -- and rt.creation_date between '01-JUL-2012' and '10-JUL-2012'
			  group by rt.po_distribution_id) tbl_rx on pda.po_distribution_id = tbl_rx.po_distribution_id
		 where 1 = 1
		   -- and pha.segment1 = 'PO123456'
		   and pha.creation_date between '15-JUL-2012' and '20-JUL-2012'
		   and 1 = 1;

-- ##################################################################-- 
-- RECEIPT COUNTS PER REQ AND PO
-- ###################################################################

		select prha.segment1 req_num
			 , prha.creation_date req_date
			 , pla.line_num po_line_num
			 , pha.segment1 po_num
			 , pha.creation_date po_date
			 , pda.quantity_billed qty_billed
			 , (select count(*) from po.rcv_transactions rt where pda.po_distribution_id = rt.po_distribution_id and rt.transaction_type = 'RECEIVE') rcpt_ct
		  from po.po_requisition_headers_all prha
			 , po.po_requisition_lines_all prla
			 , po.po_req_distributions_all prda
			 , po.po_line_locations_all plla
			 , po.po_lines_all pla
			 , po.po_headers_all pha
			 , po.po_distributions_all pda
		 where prha.requisition_header_id = prla.requisition_header_id
		   and plla.line_location_id = prla.line_location_id
		   and pla.po_line_id = plla.po_line_id
		   and pha.po_header_id = plla.po_header_id
		   and pla.po_line_id = pda.po_line_id
		   and prla.requisition_line_id = prda.requisition_line_id
		   and prha.creation_date > '01-OCT-2014'
		   and prha.creation_date < '02-OCT-2014'
		   and 1 = 1;

-- ###################################################################
-- RECEIPT COUNTS PER PO
-- ###################################################################

		select pha.segment1 po_num
			 , pha.creation_date po_date
			 , count (distinct pla.po_line_id) line_ct
			 , count (distinct rt.transaction_id) rx_ct
		  from po.po_lines_all pla
			 , po.po_headers_all pha
			 , po.po_distributions_all pda
			 , po.rcv_transactions rt
		 where pha.po_header_id = pla.po_header_id
		   and pla.po_line_id = pda.po_line_id
		   and pda.po_distribution_id = rt.po_distribution_id
		   and rt.transaction_type = 'RECEIVE'
		   and pha.creation_date > '01-MAR-2014'
		   and pha.creation_date < '10-MAR-2014'
		   and 1 = 1
	  group by pha.segment1
			 , pha.creation_date;

-- ###################################################################
-- RECEIPT COUNTS
-- ###################################################################

/* per day */

		select count(*) tally
			 , to_char(creation_date, 'RRRR-MM-DD') the_date
		  from po.rcv_shipment_headers rsh
		 where creation_date >= sysdate - 400
	  group by to_char(creation_date, 'RRRR-MM-DD')
	  order by to_char(creation_date, 'RRRR-MM-DD') desc;

/* receipts created today */

		select * 
		  from po.rcv_shipment_headers rsh
		 where rsh.creation_date > trunc(sysdate) - 0
	  order by rsh.creation_date desc;

-- ##################################################################
-- REQ TO PO TO RECEIPT TO INVOICE
-- ##################################################################

		select prha.segment1 req
			 , pha.segment1 po
			 , aia.invoice_num
			 , aia.doc_sequence_value inv_voucher
			 , rsh.receipt_num receipt 
			 , pha.document_creation_method
			 , fu.description requisitioner
			 , hla.location_code req_location
			 , pv.segment1 supp_no
			 , pv.vendor_name supp_name
			 , pvsa.vendor_site_code supp_site
			 , pv.vendor_type_lookup_code vendor_classification
			 , pha.creation_date po_creation_date
			 , aia.invoice_date
			 , '-----> AP INV DISTRIBUTIONS'
			 , aida.distribution_line_number
			 , aida.invoice_distribution_id
			 , aida.line_type_lookup_code
			 , aida.quantity_invoiced
			 , aida.amount
		  from po.po_headers_all pha
			 , po.po_lines_all pla
			 , po.po_distributions_all pda
			 , ap.ap_suppliers pv
			 , ap.ap_supplier_sites_all pvsa
			 , applsys.fnd_user fu
			 , po.po_requisition_lines_all prla
			 , po.po_requisition_headers_all prha
			 , po.po_req_distributions_all prda
			 , po.po_line_locations_all plla
			 , hr.hr_locations_all hla
			 , po.rcv_transactions rt
			 , po.rcv_shipment_headers rsh
			 , ap.ap_invoices_all aia
			 , ap.ap_invoice_distributions_all aida
		 where pha.po_header_id = pla.po_header_id
		   and pla.po_line_id = pda.po_line_id
		   and pha.vendor_id = pv.vendor_id
		   and pha.vendor_site_id = pvsa.vendor_site_id
		   and pv.vendor_id = pvsa.vendor_id
		   and prha.created_by = fu.user_id
		   and prha.requisition_header_id = prla.requisition_header_id
		   and prla.line_location_id = plla.line_location_id
		   and prla.requisition_line_id = prda.requisition_line_id
		   and prla.deliver_to_location_id = hla.location_id
		   and prda.distribution_id = pda.req_distribution_id
		   and pda.line_location_id = plla.line_location_id
		   and pda.po_distribution_id = aida.po_distribution_id
		   and aia.invoice_id = aida.invoice_id 
		   and pda.po_distribution_id = rt.po_distribution_id
		   and rt.shipment_header_id = rsh.shipment_header_id
		   and rt.transaction_type = 'RECEIVE'
		   and prha.creation_date > '01-JUN-2016';

-- ##################################################################
-- REQ TO PO TO RECEIPT - NO AP INVOICE JOIN
-- ##################################################################

		select ppa.segment1 project
			 , prha.segment1 req_num
			 , prha.creation_date req_date
			 , prha.authorization_status req_approval_status
			 , prha.closed_code req_closed_status
			 , pha.segment1 po_num
			 , pha.creation_date po_date
			 , pha.authorization_status po_approval_status
			 , pha.closed_code po_closed_status
			 , prla.closed_code line_status
			 , pav.agent_name po_buyer
			 , prla.line_num line
			 , prda.distribution_num req_dist_num
			 , prda.req_line_quantity
			 , prla.unit_meas_lookup_code uom
			 , prla.unit_price price
			 , prla.quantity qty
			 , rsh.receipt_num
			 , rt.transaction_type
			 , rsh.creation_date rcpt_date
			 , rt.quantity qty_received
			 , pda.quantity_billed qty_billed
			 , (pda.quantity_billed * prla.unit_price) amt_billed
			 , mcb.segment1 || '.' || mcb.segment2 purchase_category
			 , prla.suggested_vendor_product_code catalogue_code
			 , to_char(prla.need_by_date, 'DD-MON-RRRR') need_by_date
			 , prla.note_to_agent note_to_buyer
			 , prla.note_to_vendor note_to_supplier
			 , prla.suggested_vendor_name supplier
			 , prla.suggested_vendor_location site
		  from po.po_requisition_headers_all prha
			 , po.po_requisition_lines_all prla
			 , po.po_req_distributions_all prda
			 , po.po_line_locations_all plla
			 , po.po_lines_all pla
			 , po.po_headers_all pha
			 , po.po_distributions_all pda
			 , hr.hr_locations_all_tl hlat
			 , inv.mtl_categories_b mcb
			 , gl.gl_code_combinations gcc
			 , pa.pa_projects_all ppa
			 , apps.po_agents_v pav
			 , po.rcv_transactions rt
			 , po.rcv_shipment_headers rsh
			 , po.rcv_shipment_lines rsl
		 where prha.requisition_header_id = prla.requisition_header_id
		   and plla.line_location_id = prla.line_location_id
		   and pla.po_line_id = plla.po_line_id
		   and pha.po_header_id = plla.po_header_id
		   and pla.po_line_id = pda.po_line_id
		   and pda.line_location_id = plla.line_location_id
		   and prla.deliver_to_location_id = hlat.location_id
		   and prla.requisition_line_id = prda.requisition_line_id
		   and gcc.code_combination_id = prda.code_combination_id
		   and mcb.category_id = prla.category_id
		   and prda.project_id = ppa.project_id(+)
		   and pha.agent_id = pav.agent_id
		   and pda.po_distribution_id = rt.po_distribution_id
		   and rt.shipment_header_id = rsh.shipment_header_id
		   and rt.shipment_line_id = rsl.shipment_line_id
		   and rt.transaction_type = 'RECEIVE'
		   and prha.creation_date > '01-JUN-2016'
	  order by prha.segment1 desc
			 , prla.line_num;
