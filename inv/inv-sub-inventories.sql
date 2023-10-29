/*
File Name: inv-sub-inventories.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- INVENTORY SUB-INVENTORIES
-- ##################################################################

		select haou.name inv_org
			 , msi.secondary_inventory_name
			 , msi.description
			 , msi.inventory_atp_code
			 , msi.availability_type
			 , msi.reservable_type
			 , msi.locator_type
			 , msi.depreciable_flag
			 , msi.creation_date
			 , fu. description cr_by
		  from inv.mtl_secondary_inventories msi
		  join applsys.fnd_user fu on msi.created_by = fu.user_id
		  join hr.hr_all_organization_units haou on msi.organization_id = haou.organization_id;
