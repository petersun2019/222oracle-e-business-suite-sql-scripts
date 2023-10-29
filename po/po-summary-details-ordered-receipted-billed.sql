/*
File Name: po-summary-details-ordered-receipted-billed.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- PO SUMMARY - ATTEMPT 1
-- PO SUMMARY - ATTEMPT 2
-- PO SUMMARY - ATTEMPT 3
-- PO SUMMARY - ATTEMPT 4

*/

-- ##################################################################
-- PO SUMMARY - ATTEMPT 1
-- ##################################################################

		select pha.segment1 po
			 , pha.po_header_id
			 , pha.creation_date
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
			 , sum(pla.unit_price * pla.quantity) total_value
			 , sum(pla.quantity) total_ordered
			 , sum(plla.quantity_received) total_receipted
			 , sum(plla.quantity_billed) total_billed
			 , count(distinct pla.po_line_id) line_count
			 , (select count(*) from po_distributions_all where po_header_id = pha.po_header_id) dist_ct
		  from po.po_headers_all pha
		  join ap.ap_suppliers pv on pha.vendor_id = pv.vendor_id
		  join ap.ap_supplier_sites_all pvsa on pha.vendor_site_id = pvsa.vendor_site_id and pvsa.vendor_id = pv.vendor_id
		  join po.po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join po.po_line_locations_all plla on plla.po_line_id = pla.po_line_id
		 where pha.authorization_status = 'APPROVED'
		   and pha.creation_date between '01-JUN-2020' and '10-JUN-2020'
		   -- and pla.line_type_id = 1020
		   and pla.closed_code = 'OPEN' -- line not closed or cancelled
		   -- and pvsa.pay_on_code is null -- supplier is not set to pay on receipt
		   and (select distinct 'Y' from po_distributions_all where po_header_id = pha.po_header_id and project_id is null) = 'Y' -- not matched to project
		   -- and pha.segment1 = 123456
		having sum(pla.unit_price * pla.quantity) > 1
		   and count(distinct pla.closed_code) = 1 -- all lines open
		   and count(distinct pla.po_line_id) > 4 -- single line
		   and sum(plla.quantity_received) = 0 -- not receipted
		   and sum(plla.quantity_billed) = 0
	  group by pha.po_header_id
			 , pha.creation_date
			 , pha.segment1
			 , pv.vendor_name
			 , pvsa.vendor_site_code
	  order by 5 desc;

-- ##################################################################
-- PO SUMMARY - ATTEMPT 2
-- ##################################################################

		select pha.segment1 po
			 , pha.po_header_id
			 , pha.creation_date
			 , pha.closed_code
			 , pha.cancel_flag
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
			 , sum(pla.unit_price * pla.quantity) total_value
			 , sum(pla.quantity) total_ordered
			 , sum(plla.quantity_received) total_receipted
			 , sum(plla.quantity_billed) total_billed
			 , count(distinct pla.po_line_id) line_count
			 , (select count(*) from po_distributions_all where po_header_id = pha.po_header_id) dist_ct
			 , count(distinct pla.closed_code) line_closed_ct
		  from po.po_headers_all pha
		  join ap.ap_suppliers pv on pha.vendor_id = pv.vendor_id
		  join ap.ap_supplier_sites_all pvsa on pha.vendor_site_id = pvsa.vendor_site_id and pvsa.vendor_id = pv.vendor_id
		  join po.po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join po.po_line_locations_all plla on plla.po_line_id = pla.po_line_id
		  -- join po.po_distributions_all pda on pda.po_line_id = pla.po_line_id // removed 11th aug 2017 otherwise if po has multiple distributions, the total values are incorrect (values = * number of po distribs)
		 where pha.authorization_status = 'APPROVED'
		   and pha.creation_date between '01-JAN-2017' and '01-NOV-2017'
		   and pla.line_type_id = 1020
		   and pla.closed_code = 'OPEN' -- line not closed or cancelled
		   -- and pda.project_id is null -- not matched to project
		   and pvsa.pay_on_code is null -- supplier is not set to pay on receipt
		   -- and pha.segment1 = 123456
		having sum(pla.unit_price * pla.quantity) > 1
		   and count(distinct pla.closed_code) = 1 -- all lines open
		   and count(distinct pla.po_line_id) = 1 -- single line
		   and sum(plla.quantity_received) = 0 -- not receipted
		   and sum(plla.quantity_billed) = 0
	  group by pha.po_header_id
			 , pha.creation_date
			 , pha.segment1
			 , pha.closed_code
			 , pha.cancel_flag
			 , pv.vendor_name
			 , pvsa.vendor_site_code
	  order by 5 desc;

-- ##################################################################
-- PO SUMMARY - ATTEMPT 3
-- ##################################################################

		select pha.segment1 po
			 , pha.creation_date
			 , pha.closed_code po_header_closed
			 , pha.cancel_flag po_header_cancelled
			 , pla.line_num
			 , pda.distribution_num
			 , replace(replace(replace(replace(replace(pla.item_description,chr(9),''),chr(10),''),chr(11),''),chr(12),''),chr(13),' ') line_descr
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
			 , to_char(pda.gl_encumbered_date, 'DD/MM/YYYY') gl_date
			 , gcc.segment1 || '-' || gcc.segment2 || '-' || gcc.segment3 || '-' || gcc.segment4 || '-' || gcc.segment5 || '-' || gcc.segment6 chg_acct
			 , gcc.code_combination_id
			 , pda.encumbered_amount
			 , (apps.po_inq_sv.get_active_enc_amount (nvl (pda.rate, 1), pda.encumbered_amount, plla.shipment_type, pda.po_distribution_id)) active_encumb
			 , psa_ap_bc_pvt.get_po_reversed_encumb_amount( pda.po_distribution_id,to_date('01/JAN/2000'),to_date('31/DEC/2095'),null) reversal_amount
			 , pda.encumbered_amount-psa_ap_bc_pvt.get_po_reversed_encumb_amount( pda.po_distribution_id,to_date('01/JAN/2000'),to_date('31/DEC/2095'),null) main_encumbered_amount
			 , pda.quantity_ordered * (nvl (pha.rate, 1) * pla.unit_price) order_amount
			 , (pda.quantity_delivered - pda.quantity_cancelled) * (nvl(pha.rate, 1) * pla.unit_price) value_received
			 , sum(pla.unit_price * pla.quantity) line_amount
			 , sum(pla.quantity) total_ordered
			 , sum(plla.quantity_received) total_receipted
			 , sum(plla.quantity_billed) total_billed
		  from po.po_headers_all pha
		  join ap.ap_suppliers pv on pha.vendor_id = pv.vendor_id
		  join ap.ap_supplier_sites_all pvsa on pha.vendor_site_id = pvsa.vendor_site_id and pvsa.vendor_id = pv.vendor_id
		  join po.po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join po.po_line_locations_all plla on plla.po_line_id = pla.po_line_id
		  join po.po_distributions_all pda on pda.po_line_id = pla.po_line_id
		  join po.po_requisition_lines_all prla on prla.line_location_id = plla.line_location_id
		  join gl.gl_code_combinations gcc on pda.code_combination_id = gcc.code_combination_id
		 where 1 = 1
		   -- and pha.segment1 in ('PO123','PO234','PO345')
		   and gcc.code_combination_id = 123
		   -- and pha.creation_date between '01-AUG-2014' and '01-SEP-2014'
		   -- and pha.segment1 = 123456
		   and (apps.po_inq_sv.get_active_enc_amount (nvl (pda.rate, 1), pda.encumbered_amount, plla.shipment_type, pda.po_distribution_id)) <> 0
	  group by pha.segment1
			 , pha.creation_date
			 , pha.closed_code
			 , pha.cancel_flag
			 , pla.line_num
			 , pda.distribution_num
			 , replace(replace(replace(replace(replace(pla.item_description,chr(9),''),chr(10),''),chr(11),''),chr(12),''),chr(13),' ')
			 , pv.vendor_name
			 , pvsa.vendor_site_code
			 , to_char(pda.gl_encumbered_date, 'DD/MM/YYYY')
			 , gcc.segment1 || '-' || gcc.segment2 || '-' || gcc.segment3 || '-' || gcc.segment4 || '-' || gcc.segment5 || '-' || gcc.segment6
			 , gcc.code_combination_id
			 , pda.encumbered_amount
			 , pda.quantity_ordered * (nvl (pha.rate, 1) * pla.unit_price)
			 , (pda.quantity_delivered - pda.quantity_cancelled) * (nvl(pha.rate, 1) * pla.unit_price)
			 , pla.closed_by , pla.closed_code , pla.closed_date , pla.closed_flag , pla.closed_reason, pla.cancel_date , pla.cancel_flag , pla.cancel_reason , pla.cancelled_by
			 , (apps.po_inq_sv.get_active_enc_amount (nvl (pda.rate, 1), pda.encumbered_amount, plla.shipment_type, pda.po_distribution_id))
			 , psa_ap_bc_pvt.get_po_reversed_encumb_amount( pda.po_distribution_id,to_date('01/JAN/2000'),to_date('31/DEC/2095'),null)
			 , pda.encumbered_amount-psa_ap_bc_pvt.get_po_reversed_encumb_amount( pda.po_distribution_id,to_date('01/JAN/2000'),to_date('31/DEC/2095'),null)
	  order by pha.segment1
			 , pla.line_num;

-- ##################################################################
-- PO SUMMARY - ATTEMPT 4
-- ##################################################################

		select pha.segment1 po
			 , pha.creation_date
			 , pha.closed_code po_header_closed
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
			 , sum(pda.quantity_ordered * (nvl (pha.rate, 1) * pla.unit_price)) order_amount
			 , sum(apps.po_inq_sv.get_active_enc_amount (nvl (pda.rate, 1), pda.encumbered_amount, plla.shipment_type, pda.po_distribution_id)) active_encumb
			 , sum((pda.quantity_delivered - pda.quantity_cancelled) * (nvl(pha.rate, 1) * pla.unit_price)) value_received
			 , sum(plla.quantity_received) total_receipted
			 , sum(plla.quantity_billed) total_billed
		  from po.po_headers_all pha
		  join ap.ap_suppliers pv on pha.vendor_id = pv.vendor_id
		  join ap.ap_supplier_sites_all pvsa on pha.vendor_site_id = pvsa.vendor_site_id and pvsa.vendor_id = pv.vendor_id
		  join po.po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join po.po_line_locations_all plla on plla.po_line_id = pla.po_line_id
		  join po.po_distributions_all pda on pda.po_line_id = pla.po_line_id
		 where 1 = 1
		   and pha.creation_date between '01-AUG-2014' and '01-SEP-2014'
		   -- and pha.segment1 = 'PO1234'
		   and (apps.po_inq_sv.get_active_enc_amount (nvl (pda.rate, 1), pda.encumbered_amount, plla.shipment_type, pda.po_distribution_id)) <> 0
	  group by pha.segment1
			 , pha.creation_date
			 , pha.closed_code
			 , pv.vendor_name
			 , pvsa.vendor_site_code;
