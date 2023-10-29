/*
File Name:		inv-items.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- INVENTORY ITEMS - COUNT PER INV ORG
-- INVENTORY ITEMS - DETAILS
-- APPROVED SUPPLIER LIST AND UNITS OF MEASURE
-- INVENTORY ITEMS INTERFACE - TABLE DUMPS
-- INVENTORY ITEMS INTERFACE - DETAILS
-- INVENTORY ITEMS INTERFACE - SUMMARY

*/

-- ##################################################################
-- INVENTORY ITEMS - COUNT PER INV ORG
-- ##################################################################

		select haou.name
			 , haou.organization_id org_id
			 -- , to_char(msib.creation_date, 'yyyy-mm-dd') created
			 , count (*) ct
			 , min(msib.creation_date) min_created
			 , max(msib.creation_date) max_created
			 , min(msib.segment1) start_item
			 , max(msib.segment1) end_item
		  from inv.mtl_system_items_b msib
		  join hr.hr_all_organization_units haou on msib.organization_id = haou.organization_id 
		 where 1 = 1
		   and msib.enabled_flag = 'Y'
		   and msib.inventory_item_status_code = 'Active'
		   -- and haou.name = 'Blue Cheese UK Inventory'
		   -- and msib.creation_date >= '04-OCT-2021'
	  group by haou.name
			 , haou.organization_id
			 , to_char(msib.creation_date, 'yyyy-mm-dd')
	  order by 3 desc;

		select haou.name
			 , count(*) ct
		  from inv.mtl_system_items_b msib
		  join hr.hr_all_organization_units haou on msib.organization_id = haou.organization_id
		 where msib.unit_of_issue is not null
	  group by haou.name
	  order by 2 desc;

-- ##################################################################
-- INVENTORY ITEMS - DETAILS
-- ##################################################################

		select haou.name inv_org
			 , msib.inventory_item_id
			 , msib.segment1 item_number
			 , msib.list_price_per_unit
			 , msib.purchasing_enabled_flag
			 , msib.creation_date
			 , fu.user_name created_by
			 , msib.primary_uom_code
			 , msib.primary_unit_of_measure
			 , msib.unit_of_issue
			 , msib.enabled_flag
			 , msib.inventory_item_status_code
			 , msib.description item_description
			 , (select count(*) from inv.mtl_material_transactions mmt where mmt.inventory_item_id = msib.inventory_item_id) tx_ct
			 , (select max(creation_date) from inv.mtl_material_transactions mmt where mmt.inventory_item_id = msib.inventory_item_id) last_tx
			 , gcc1.concatenated_segments sales_account
			 , gcc2.concatenated_segments expense_account
			 , gcc3.concatenated_segments cost_of_sales_account
			 , micv.category_concat_segs category
			 , micv.segment1 cat_seg1
			 , micv.segment2 cat_seg2
		  from inv.mtl_system_items_b msib
		  join hr.hr_all_organization_units haou on msib.organization_id = haou.organization_id
		  join applsys.fnd_user fu on msib.created_by = fu.user_id
		  join gl_code_combinations_kfv gcc1 on msib.sales_account = gcc1.code_combination_id
		  join gl_code_combinations_kfv gcc2 on msib.expense_account = gcc2.code_combination_id
		  join gl_code_combinations_kfv gcc3 on msib.cost_of_sales_account = gcc3.code_combination_id
	 left join mtl_item_categories_v micv on micv.inventory_item_id = msib.inventory_item_id and micv.organization_id = msib.organization_id
		 where 1 = 1
		   and msib.enabled_flag = 'Y'
		   and msib.inventory_item_status_code = 'Active'
		   and haou.name = 'Blue Cheese UK Inventory'
		   -- and msib.segment1 = 'A:123'
		   -- and to_char(msib.creation_date, 'yyyy-mm-dd') = '2021-10-07'
		   -- and msib.inventory_item_id in (123456, 123457)
		   -- and msib.organization_id = 123
		   -- and 1 = 1
	  order by msib.creation_date desc;

-- ##################################################################
-- APPROVED SUPPLIER LIST AND UNITS OF MEASURE
-- ##################################################################

		select haou.name
			 , msib.segment1
			 , msib.last_update_date
			 , msib.primary_uom_code
			 , msib.primary_unit_of_measure
			 , msib.unit_of_issue
			 , paa.purchasing_unit_of_measure asl_uom
			 , pv.vendor_name asl_supplier
			 , pvsa.vendor_site_code asl_site
			 , msib.enabled_flag
			 , msib.inventory_item_status_code
			 , msib.description
			 , (select count(*) from inv.mtl_material_transactions mmt where mmt.inventory_item_id = msib.inventory_item_id) tx_ct
			 , (select max(creation_date) from inv.mtl_material_transactions mmt where mmt.inventory_item_id = msib.inventory_item_id) last_tx
		  from inv.mtl_system_items_b msib
		  join hr.hr_all_organization_units haou on msib.organization_id = haou.organization_id 
		  join po.po_asl_attributes paa on msib.inventory_item_id = paa.item_id 
		  join po.po_approved_supplier_list pasl on paa.asl_id = pasl.asl_id
		  join ap.ap_suppliers pv on pasl.vendor_id = pv.vendor_id 
		  join ap.ap_supplier_sites_all pvsa on pasl.vendor_site_id = pvsa.vendor_site_id
		   and pv.vendor_id = pvsa.vendor_id
		 where pasl.disable_flag is null -- ignore disabled asl details
		   -- and msib.unit_of_issue is not null
		   and haou.name = 'Blue Cheese UK Store'
		   -- and msib.segment1 = 'A:123'
		   and msib.enabled_flag = 'Y'
		   and msib.inventory_item_status_code = 'Active'
		   and 1 = 1;

-- ##################################################################
-- INVENTORY ITEMS INTERFACE - TABLE DUMPS
-- ##################################################################

select * from mtl_system_items_interface;
select * from mtl_system_items_interface where creation_date >= '04-OCT-2021';
select * from mtl_interface_errors where message_name = 'INV_IOI_ERR_IN_PROCESS_ITEM' order by creation_date desc;

-- ##################################################################
-- INVENTORY ITEMS INTERFACE - DETAILS
-- ##################################################################

		select haou.name inv_org
			 , msii.inventory_item_id
			 , msii.segment1 item_number
			 , msii.creation_date
			 , msii.primary_uom_code
			 , msii.primary_unit_of_measure
			 , msii.enabled_flag
			 , msii.inventory_item_status_code
			 , msii.description item_description
			 , msii.transaction_id
			 , mie.message_name
			 , mie.error_message
		  from inv.mtl_system_items_interface msii
		  join hr.hr_all_organization_units haou on msii.organization_id = haou.organization_id
	 left join mtl_interface_errors mie on msii.transaction_id = mie.transaction_id
		 where 1 = 1
		   and haou.name = 'Blue Cheese UK Store'
		   and msii.creation_date >= '04-OCT-2021'
	  order by msii.creation_date desc;

-- ##################################################################
-- INVENTORY ITEMS INTERFACE - SUMMARY
-- ##################################################################

		select haou.name
			 , haou.organization_id org_id
			 , mie.message_name
			 , count (*) ct
			 , min(msib.creation_date) min_created
			 , max(msib.creation_date) max_created
			 , min(msib.segment1) start_item
			 , max(msib.segment1) end_item
		  from inv.mtl_system_items_interface msib
		  join hr.hr_all_organization_units haou on msib.organization_id = haou.organization_id 
	 left join mtl_interface_errors mie on msib.transaction_id = mie.transaction_id
		 where 1 = 1
		   -- and msib.enabled_flag = 'Y'
		   -- and msib.inventory_item_status_code = 'Active'
		   and haou.name = 'Blue Cheese UK Store'
		   and msib.creation_date >= '04-OCT-2021'
	  group by haou.name
			 , haou.organization_id
			 , mie.message_name
	  order by 3 desc;
