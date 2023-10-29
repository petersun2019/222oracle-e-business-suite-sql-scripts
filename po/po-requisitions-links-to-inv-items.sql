/*
File Name: po-requisitions-links-to-inv-items.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

		select prha.segment1
			 , prha.creation_date 
			 , prla.item_description
			 , prha.type_lookup_code
			 , prha.interface_source_code
			 , hla.location_code
			 , prla.destination_organization_id || ' ' || haou.name inv_org
			 , prha.request_id
			 , '###############################'
			 , prla.catalog_type
			 , prla.catalog_source
			 , prla.source_type_code
		  from po.po_requisition_headers_all prha 
		  join po.po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join hr.hr_locations_all hla on prla.deliver_to_location_id = hla.location_id
		  join hr.hr_all_organization_units haou on prla.destination_organization_id = haou.organization_id
		 where prha.creation_date > '01-JUL-2015'
		   and prla.item_id is not null
		   and prla.destination_organization_id = 123
		   -- and prha.segment1 in ('REQ123456','REQ987654')
		   -- and prha.interface_source_code <> 'INV'
		   and 1 = 1;
