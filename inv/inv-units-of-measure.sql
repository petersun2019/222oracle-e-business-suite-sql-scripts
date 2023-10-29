/*
File Name: inv-units-of-measure.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- INVENTORY UNITS OF MEASURE
-- INVENTORY ITEMS - COUNT PER INV ORG AND UNIT OF MEASURE

*/

-- ##################################################################
-- INVENTORY UNITS OF MEASURE
-- ##################################################################

		select moumt.unit_of_measure
			 , moumt.uom_code
			 , moumt.description
			 , moumt.base_uom_flag
			 , moumt.creation_date
			 , fu.description cr_by
			 , muc.uom_class
			 , muc.conversion_rate
		  from inv.mtl_units_of_measure_tl moumt
	 left join inv.mtl_uom_conversions muc on moumt.unit_of_measure = muc.unit_of_measure
		  join applsys.fnd_user fu on moumt.created_by = fu.user_id
		 where 1 = 1
		   -- and moumt.uom_code like 'M%'
		   and moumt.creation_date > '01-NOV-2000'
		   and 1 = 1;

-- ##################################################################
-- INVENTORY ITEMS - COUNT PER INV ORG AND UNIT OF MEASURE
-- ##################################################################

		select haou.name
			 , msib.primary_uom_code
			 , msib.primary_unit_of_measure
			 , count(*) ct
		  from inv.mtl_system_items_b msib
		  join hr.hr_all_organization_units haou on msib.organization_id = haou.organization_id
		  join applsys.fnd_user fu on msib.last_updated_by = fu.user_id
		 where 1 = 1
		   and msib.enabled_flag = 'Y'
		   and 1 = 1
	  group by haou.name
			 , msib.primary_uom_code
			 , msib.primary_unit_of_measure
	  order by haou.name
			 , msib.primary_uom_code;
