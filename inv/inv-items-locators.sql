/*
File Name:		inv-items-locators.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- INVENTORY ITEM LOCATORS
-- ##################################################################

		select msib.segment1
			 , msib.description
			 , mslav.*
		  from apps.mtl_secondary_locators_all_v mslav
		  join inv.mtl_system_items_b msib on mslav.inventory_item_id = msib.inventory_item_id 
		 where msib.organization_id = 123;
