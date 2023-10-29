/*
File Name: po-basic-housekeeping-report.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- PURCHASE ORDER HOUSEKEEPING REPORT - VERSION 1
-- PURCHASE ORDER HOUSEKEEPING REPORT - VERSION 2
-- PURCHASE ORDER HOUSEKEEPING REPORT - VERSION 3
-- PURCHASE ORDER HOUSEKEEPING REPORT - VERSION 4 - INCLUDE SUPPLIER DETAILS

*/

-- ##################################################################
-- PURCHASE ORDER HOUSEKEEPING REPORT - VERSION 1
-- ##################################################################

/*
SUMMARY DOCUMENT, NOT BY LINE
I USED TO USE THIS TO GET A SUMMARY VIEW OF ACTIVITY AGAINST POS
FOR EXAMPLE - TO GET A LIST OF RECEIPTED, UNBILLED POS TO MATCH AP INVOICES AGAINST
*/

		select my_data.label
			 , my_data.po
			 , to_char(my_data.po_created, 'DD-MM-YYYY HH24:MI:SS') po_created
			 , my_data.po_status
			 , my_data.closed_code
			 , my_data.supplier
			 , my_data.req
			 , my_data.req_header_id
			 , my_data.req_status
			 , to_char(my_data.req_created, 'DD-MM-YYYY HH24:MI:SS') req_created
			 , my_data.project
			 , my_data.task
			 , sum(my_data.line_value) doc_value
			 , sum(my_data.received) received
			 , sum(my_data.billed) billed
			 , count(*) lines
		  from (select pha.segment1 po
					 , pha.creation_date po_created
					 , pha.authorization_status po_status
					 , pha.created_by po_created_by
					 , pha.closed_code
					 , pv.vendor_name supplier
					 , prha.segment1 req
					 , prha.creation_date req_created
					 , prha.authorization_status req_status
					 , prha.requisition_header_id req_header_id
					 , prha.created_by req_created_by
					 , pla.matching_basis
					 , ppa.segment1 project
					 , pt.task_number task
					 , nvl(case when (plla.quantity is null and pla.unit_price is null) then 'AMOUNT'
								when (plla.amount is null) then 'QUANTITY'
					   end, 0) label
					 , nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount
								when (plla.amount is null) then pla.unit_price * plla.quantity
					   end, 0) line_value
					 , nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount_received
								when (plla.amount is null) then pla.unit_price * plla.quantity_received
					   end, 0) received
					 , nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount_billed
								when (plla.amount is null) then pla.unit_price * plla.quantity_billed
					   end, 0) billed
				  from po_headers_all pha
				  join po_lines_all pla on pha.po_header_id = pla.po_header_id
				  join po_distributions_all pda on pla.po_line_id = pda.po_line_id
				  join ap_suppliers pv on pha.vendor_id = pv.vendor_id
				  join po_req_distributions_all prda on prda.distribution_id = pda.req_distribution_id
				  join po_requisition_lines_all prla on prla.requisition_line_id = prda.requisition_line_id
				  join po_line_locations_all plla on prla.line_location_id = plla.line_location_id
				  join po_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
				  join pa_projects_all ppa on prda.project_id = ppa.project_id
				  join pa_tasks pt on prda.task_id = pt.task_id
				 where 1 = 1
				   and (pha.closed_code = 'OPEN' or pha.closed_code is null)
				   and pha.authorization_status = 'APPROVED'
				   and pla.item_id is not null -- not linked to an inventory item
				   -- and pha.creation_date between '01-JAN-2012' and '15-JAN-2012'
				   -- and pha.creation_date > '01-NOV-2019'
				   -- and pha.po_header_id in (123, 456)
				   -- and pha.segment1 = 'PO123456'
				   and 1 = 1) my_data
	  group by my_data.label
			 , my_data.po
			 , my_data.po_created
			 , my_data.po_status
			 , my_data.closed_code
			 , my_data.supplier
			 , my_data.req
			 , my_data.req_header_id
			 , my_data.req_status
			 , my_data.req_created
			 , my_data.project
			 , my_data.task;
		having sum(line_value) > 0
		   and sum(received) > 0
		   and sum(billed) = 0;

-- ##################################################################
-- PURCHASE ORDER HOUSEKEEPING REPORT - VERSION 2
-- ##################################################################

		select pha.segment1 "po no."
			 , pla.po_line_id
			 , pha.creation_date "po creation date"
			 , pha.authorization_status "po status"
			 , pha.closed_code "po closure status"
			 , pav.agent_name "buyer name"
			 , pv.vendor_name "supplier name"
			 , pla.line_num "po line no"
			 , pla.cancel_flag "po line cancel flag"
			 , pla.closed_code "po line closure status"
			 , sum (pla.quantity * pla.unit_price) "po line value"
			 -- , pla.item_description "line description"
			 , pla.unit_price "unit price"
			 , plla.quantity "quantity ordered"
			 , plla.quantity_received "quantity received"
			 , plla.quantity_billed "quantity billed"
			 , ppa.segment1 project
			 , sum ( (plla.quantity - plla.quantity_billed) * pla.unit_price) "amount outstanding"
		  from po_headers_all pha
		  join po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join po_distributions_all pda on pla.po_line_id = pda.po_line_id
		  join po_vendors pv on pha.vendor_id = pv.vendor_id
		  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id
		  join po_agents_v pav on pav.agent_id = pha.agent_id
		  join pa_projects_all ppa on pda.project_id = ppa.project_id
		 where 1 = 1
		   and (pha.closed_code = 'OPEN' or pha.closed_code is null)
		   and pha.authorization_status = 'APPROVED'
		   and pla.item_id is not null -- not linked to an inventory item
		   -- and pha.creation_date between '01-JAN-2012' and '15-JAN-2012'
		   -- and pha.creation_date > '01-NOV-2019'
		   -- and pha.po_header_id in (123, 456)
		   -- and pha.segment1 = 'PO123456'
	  group by pha.segment1
			 , pha.creation_date
			 , pla.po_line_id
			 , pha.authorization_status
			 , pav.agent_name
			 , pv.vendor_name
			 , pla.line_num
			 , plla.quantity
			 , plla.quantity_received
			 , plla.quantity_billed
			 , pla.unit_price
			 , pha.closed_code
			 , pha.cancel_flag
			 , pla.cancel_flag
			 , pla.closed_code
			 , pla.item_description
			 , ppa.segment1
	  order by pha.creation_date
			 , pha.segment1
			 , pla.line_num;

-- ##################################################################
-- PURCHASE ORDER HOUSEKEEPING REPORT - VERSION 3
-- ##################################################################

		select po
			 , creation_date
			 , authorization_status
			 , pha_closed_code
			 , pha_cancel_flag
			 , pa_project
			 , sum(qty_ordered) ordered
			 , sum(quantity_received) received
			 , sum(quantity_billed) billed
		  from (select pha.segment1 po
					 , pha.creation_date
					 , pha.authorization_status
					 , pha.closed_code pha_closed_code
					 , pha.cancel_flag pha_cancel_flag
					 , pav.agent_name
					 , pv.vendor_name
					 , pla.line_num
					 , pla.cancel_flag
					 , pla.closed_code
					 , sum(pla.quantity * pla.unit_price)
					 , pla.item_description
					 , pla.unit_price
					 , plla.quantity qty_ordered
					 , plla.quantity_received
					 , plla.quantity_billed
					 , ppa.segment1 pa_project
				  from po_headers_all pha
				  join po_lines_all pla on pha.po_header_id = pla.po_header_id
				  join po_distributions_all pda on pla.po_line_id = pda.po_line_id
				  join po_vendors pv on pha.vendor_id = pv.vendor_id
				  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id
				  join po_agents_v pav on pav.agent_id = pha.agent_id
				  join pa_projects_all ppa on pda.project_id = ppa.project_id
				 where pha.creation_date > '10-NOV-2019'
				   and (pha.closed_code = 'OPEN' or pha.closed_code is null)
				   and pha.authorization_status = 'APPROVED'
			  group by pha.segment1
					 , pha.creation_date
					 , pha.authorization_status
					 , pav.agent_name
					 , pv.vendor_name
					 , pla.line_num
					 , plla.quantity
					 , plla.quantity_received
					 , plla.quantity_billed
					 , pla.unit_price
					 , pha.closed_code
					 , pha.cancel_flag
					 , pla.cancel_flag
					 , pla.closed_code
					 , pla.item_description
					 , ppa.segment1)
	  group by po
			 , creation_date
			 , authorization_status
			 , pha_closed_code
			 , pha_cancel_flag
			 , pa_project;

-- ##################################################################
-- PURCHASE ORDER HOUSEKEEPING REPORT - VERSION 4 - INCLUDE SUPPLIER DETAILS
-- ##################################################################

		select po
			 , creation_date
			 , authorization_status
			 , pha_closed_code
			 , pha_cancel_flag
			 , supplier
			 , sup_num
			 , sum(qty_ordered) ordered
			 , sum(quantity_received) received
			 , sum(quantity_billed) billed
		  from (select pha.segment1 po
					 , pha.creation_date
					 , pha.authorization_status
					 , pha.closed_code pha_closed_code
					 , pha.cancel_flag pha_cancel_flag
					 , pav.agent_name
					 , pv.vendor_name
					 , pla.line_num
					 , pla.cancel_flag
					 , pla.closed_code
					 , sum (pla.quantity * pla.unit_price)
					 , pla.item_description
					 , pla.unit_price
					 , plla.quantity qty_ordered
					 , plla.quantity_received
					 , plla.quantity_billed
					 , pv.vendor_name supplier
					 , pv.segment1 sup_num
				  from po_headers_all pha
				  join po_lines_all pla on pha.po_header_id = pla.po_header_id
				  join po_distributions_all pda on pla.po_line_id = pda.po_line_id
				  join po_vendors pv on pha.vendor_id = pv.vendor_id
				  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id
				  join po_agents_v pav on pav.agent_id = pha.agent_id
				  join ap_suppliers pv on pha.vendor_id = pv.vendor_id
				 where 1 = 1
				   -- and pha.creation_date between '01-JUL-2018' and '05-JUL-2018'
				   and pha.creation_date > '01-JAN-2021'
				   and (pha.closed_code = 'OPEN' or pha.closed_code is null)
				   and pha.authorization_status = 'APPROVED'
			  group by pha.segment1
					 , pha.creation_date
					 , pha.authorization_status
					 , pav.agent_name
					 , pv.vendor_name
					 , pla.line_num
					 , plla.quantity
					 , plla.quantity_received
					 , plla.quantity_billed
					 , pla.unit_price
					 , pha.closed_code
					 , pha.cancel_flag
					 , pla.cancel_flag
					 , pla.closed_code
					 , pla.item_description
					 , pv.vendor_name
					 , pv.segment1)
		having sum (qty_ordered) = sum (quantity_received)
	  group by po
			 , creation_date
			 , authorization_status
			 , pha_closed_code
			 , pha_cancel_flag
			 , supplier
			 , sup_num;
