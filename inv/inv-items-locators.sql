/*
File Name: inv-items-locators.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
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
