/*
File Name:		po-purchase-orders-call-off-orders.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- CALL OFF ORDERS SUMMARY
-- ##################################################################

		select po_head.segment1 po_number
			 , po_head.comments po_description
			 , sum(po_line.unit_price*po_line.quantity) po_value
			 , pv.vendor_name
			 , po_head.creation_date
			 , sum(case when upper(comments) like '%CALL%OFF%' then 1 else 0 end) header_call_off
			 , sum(case when po_line.line_type_id = 1020 then 1 else 0 end) num_service_lines -- line type: 'Goods or services billed by amount'
			 , sum(case when upper(po_line.item_description) like '%CALL%OFF%' then 1 else 0 end) num_call_off_lines
		  from po.po_headers_all po_head
		  join po.po_lines_all po_line on po_line.po_header_id = po_head.po_header_id
		  join ap.ap_suppliers pv on pv.vendor_id = po_head.vendor_id
		 where po_head.creation_date > sysdate - (365*3) -- last 3 years
		   and po_head.authorization_status = 'APPROVED'
		   and po_head.closed_code = 'OPEN'
		   -- and upper(comments) like '%CALL%OFF%'
	  group by po_head.segment1
			 , po_head.comments
			 , po_head.vendor_id
			 , po_head.creation_date
	having sum (case when upper (comments) like '%CALL%OFF%' then 1 else 0 end) > 0
		or sum (case when po_line.line_type_id = 1020 then 1 else 0 end) > 0
		or sum (case when upper (po_line.item_description) like '%CALL%OFF%' then 1 else 0 end) > 0
