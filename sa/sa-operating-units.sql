/*
File Name: sa-operating-units.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- OPERATING UNITS
-- ##################################################################

		select o.business_group_id bg_id
			 , o.organization_id org_id
			 , otl.name
			 , o3.org_information3 sob_id
			 , gsob.name sob
			 , hla.description location
			 , hla.country
			 , hla.business_group_id loc_bus_gp
			 , o.creation_date
			 , fu.description created_by
			 , o.last_update_date
			 , o2.creation_date o2_cr_date
			 , o3.creation_date o3_cr_date
		  from hr.hr_all_organization_units o
		  join hr.hr_all_organization_units_tl otl on o.organization_id = otl.organization_id
		  join hr.hr_organization_information o2 on o.organization_id = o2.organization_id
		  join hr.hr_organization_information o3 on o.organization_id = o3.organization_id
		  join hr.hr_locations_all hla on o.location_id = hla.location_id
		  join applsys.fnd_user fu on o.created_by = fu.user_id
		  join gl.gl_ledgers gsob on gsob.ledger_id = o3.org_information3
		 where o2.org_information_context || '' = 'CLASS'
		   and o3.org_information_context = 'Operating Unit Information'
		   and o2.org_information1 = 'OPERATING_UNIT'
		   and o2.org_information2 = 'Y'
	  order by o.creation_date;
