/*
File Name: inv-requisitions.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- INVENTORY REQUISITIONS
-- ##################################################################

		select prha.segment1 req
			 , prha.creation_date req_ct_dt
			 , prla.creation_date line_cr_dt
			 , numtodsinterval((prla.creation_date-prha.creation_date),'day') diff
			 , fu.description cr_by 
			 , prha.authorization_status
			 , haou.name inv_org
			 , msib.segment1 item_code
			 , msib.inventory_item_id item_id
			 , prla.line_num line
			 , prla.unit_meas_lookup_code uom
			 , prla.unit_price price
			 , prla.quantity qty
			 , hla.location_code deliver_to
		  from po.po_requisition_headers_all prha
		  join po.po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join inv.mtl_system_items_b msib on  prla.item_id = msib.inventory_item_id and msib.organization_id = prla.destination_organization_id
		  join hr.hr_all_organization_units haou on prla.destination_organization_id = haou.organization_id
		  join hr.hr_locations_all hla on prla.deliver_to_location_id = hla.location_id
		  join applsys.fnd_user fu on prha.created_by = fu.user_id
		 where 1 = 1
		   and prla.destination_type_code = 'INVENTORY'
		   and haou.name = 'Blue Cheese UK Store'
		   and prha.creation_date > '24-MAY-2016'
		   -- and msib.segment1 = 'A:123'
	  order by prha.segment1 desc
			 , prla.line_num;
