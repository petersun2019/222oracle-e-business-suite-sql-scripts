/*
File Name:		inv-orgs.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- INVENTORY ORGANIZATIONS
-- ##################################################################

		select haou.organization_id org_id
			 , mp.organization_code org_code
			 , haou.name
			 , haou.date_from
			 , haou.creation_date
			 , hla.location_code location
			 , hla.address_line_1
			 , hla.address_line_2
			 , hla.address_line_3
			 , hla.town_or_city
			 , hla.country
			 , hla.postal_code
		  from hr.hr_all_organization_units haou
	 left join hr.hr_locations_all hla on haou.location_id = hla.location_id
		  join apps.hr_organization_information_v hoiv on haou.organization_id = hoiv.organization_id
		  join inv.mtl_parameters mp on haou.organization_id = mp.organization_id
		 where 1 = 1
		   and hoiv.org_information1 = 'INV'
	  order by 1;
