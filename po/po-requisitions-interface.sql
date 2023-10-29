/*
File Name: po-receipts.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- REQUISITION INTERFACE TABLE DUMPS
-- DETAILS LINKED TO INV ITEMS - VERSION 1
-- DETAILS LINKED TO INV ITEMS - VERSION 2
-- INVENTORY INTERFACE DISTRIBUTION ERRORS

*/

-- ###############################################################
-- REQUISITION INTERFACE TABLE DUMPS
-- ###############################################################

select * from po.po_requisitions_interface_all pria where creation_date > '10-MAR-2021';
select * from po_requisitions_interface_all where interface_source_code = 'CHEESE' order by creation_date desc;
select * from po_interface_errors where creation_date > '20-MAY-2021' order by creation_date desc;
select * from po_interface_errors where interface_transaction_id in (1234,2345,3456);

-- ###############################################################
-- DETAILS LINKED TO INV ITEMS - VERSION 1
-- ###############################################################

		select msib.segment1 item
			 , pria.item_description
			 , pria.interface_source_code
			 , pria.destination_type_code
			 , pria.creation_date
			 , pria.quantity
			 , pria.unit_of_measure
			 , pria.uom_code
			 , pria.request_id
			 , hla.location_code deliver_to_code
			 , hla.description deliver_to_description
			 , pria.need_by_date
			 , pria.gl_date
			 , mcb.segment1 || '.' || mcb.segment2 purchase_category
			 , gcc0.concatenated_segments po_chg_acct
			 , gcc1.concatenated_segments accrual_account
			 , gcc2.concatenated_segments variance_account
			 , gcc2.concatenated_segments budget_account
		  from po.po_requisitions_interface_all pria
	 left join inv.mtl_system_items_b msib on pria.item_id = msib.inventory_item_id and pria.destination_organization_id = msib.organization_id
		  join inv.mtl_categories_b mcb on pria.category_id = mcb.category_id
		  join apps.gl_code_combinations_kfv gcc0 on pria.charge_account_id = gcc0.code_combination_id
	 left join apps.gl_code_combinations_kfv gcc1 on pria.accrual_account_id = gcc1.code_combination_id
	 left join apps.gl_code_combinations_kfv gcc2 on pria.variance_account_id = gcc2.code_combination_id
	 left join apps.gl_code_combinations_kfv gcc3 on pria.budget_account_id = gcc3.code_combination_id
		  join hr.hr_locations_all hla on pria.deliver_to_location_id = hla.location_id
		 where 1 = 1;

-- ###############################################################
-- DETAILS LINKED TO INV ITEMS - VERSION 2
-- ###############################################################

		select pria.interface_source_code
			 , pria.transaction_id
			 , pria.creation_date
			 , mp.organization_code
			 , mif.item_number
			 , hl.location_code
			 , pria.destination_type_code
			 , pria.source_type_code
			 , pria.quantity
			 , pria.uom_code
			 , pria.need_by_date
		  from apps.po_requisitions_interface_all pria
		  join apps.mtl_item_flexfields mif on pria.destination_organization_id = mif.organization_id and pria.item_id = mif.inventory_item_id
		  join apps.mtl_parameters mp on pria.destination_organization_id = mp.organization_id
		  join apps.hr_locations hl on pria.deliver_to_location_id = hl.location_id
		 where 1 = 1;

-- ##################################################################
-- INVENTORY INTERFACE DISTRIBUTION ERRORS
-- ##################################################################

		select pria.interface_source_code
			 , pria.transaction_id
			 , mp.organization_code
			 , mif.item_number
			 , hl.location_code
			 , pria.destination_type_code
			 , pria.source_type_code
			 , pria.quantity
			 , pria.uom_code
			 , pria.need_by_date
			 , pria.item_id
			 , '############################'
			 , pria.*
		  from po.po_requisitions_interface_all pria
		  join apps.mtl_parameters mp on pria.destination_organization_id = mp.organization_id 
		  join apps.mtl_item_flexfields mif on pria.item_id = mif.inventory_item_id and pria.destination_organization_id = mif.organization_id
		  join hr.hr_locations_all hl on pria.deliver_to_location_id = hl.location_id 
		 where 1 = 1
		   and pria.process_flag = 'ERROR';
