/*
File Name: po-requisitions-created-by-requisition-import.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ###################################################################
-- REQUISITIONS CREATED VIA REQUISITION IMPORT
-- ###################################################################

		select distinct prha.segment1
			 , prha.creation_date
			 , prha.interface_source_code src
			 , fu.user_name cr_by_uname
			 , fu.description cr_by_name
			 , papf.full_name
		  from po.po_requisition_headers_all prha
		  join po.po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join po.po_action_history pah on pah.object_id = prha.requisition_header_id
		  join inv.mtl_system_items_b msib on prla.item_id = msib.inventory_item_id
		  join applsys.fnd_user fu on prha.created_by = fu.user_id
		  join hr.per_all_people_f papf on pah.employee_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
		 where msib.organization_id = 123
		   and pah.object_type_code = 'REQUISITION'
		   and prha.interface_source_code = 'INV'
		   and pah.action_code = 'IMPORT'
		   and prha.creation_date > '01-JUN-2016'
	  order by prha.creation_date desc;
