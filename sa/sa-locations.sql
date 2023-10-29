/*
File Name:		sa-locations.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- LOCATIONS BASIC DETAILS
-- LOCATIONS - HR STAFF ASSIGNMENT LINKS
-- LOCATIONS - HR ORG LINKS

*/

-- ##################################################################
-- LOCATIONS BASIC DETAILS
-- ##################################################################

		select bus_gp.name bus_gp
			 , inv_org.name inv_org
			 , hla.location_code
			 , hla.description
			 , hla.inactive_date
			 , hla.address_line_1
			 , hla.address_line_2
			 , hla.address_line_3
			 , hla.town_or_city
			 , hla.postal_code
		  from hr.hr_locations_all hla
	 left join hr.hr_all_organization_units_tl bus_gp on hla.business_group_id = bus_gp.organization_id
	 left join hr.hr_all_organization_units_tl inv_org on hla.inventory_organization_id = inv_org.organization_id
		  join applsys.fnd_user fu on hla.created_by = fu.user_id;

-- ##################################################################
-- LOCATIONS - HR STAFF ASSIGNMENT LINKS
-- ##################################################################

-- COUNT

		select hla.location_code
			 , hla.description description
			 , count(*) assignment_count
		  from hr.hr_locations_all hla
		  join hr.per_all_assignments_f paaf on hla.location_id = paaf.location_id
		  join hr.per_all_people_f papf on paaf.person_id = papf.person_id and (sysdate between papf.effective_start_date and papf.effective_end_date) and (sysdate between paaf.effective_start_date and paaf.effective_end_date)
		 where paaf.primary_flag = 'Y'
		   and paaf.assignment_type = 'E'
	  group by hla.description
			 , hla.location_code
	  order by 3 desc;

-- DETAILS

		select papf.employee_number
			 , papf.full_name
			 , paaf.assignment_number
			 , hla.location_code
			 , hla.description description
		  from hr.hr_locations_all hla
		  join hr.per_all_assignments_f paaf on hla.location_id = paaf.location_id
		  join hr.per_all_people_f papf on paaf.person_id = papf.person_id and (sysdate between papf.effective_start_date and papf.effective_end_date) and (sysdate between paaf.effective_start_date and paaf.effective_end_date)
		 where paaf.primary_flag = 'Y'
		   and paaf.assignment_type = 'E'
	  order by 3 desc;

-- ##################################################################
-- LOCATIONS - HR ORG LINKS
-- ##################################################################

-- COUNT

		select hla.location_code
			 , hla.description description
			 , count(*) ct
		  from hr.hr_locations_all hla
		  join hr.hr_all_organization_units haou on haou.location_id = hla.location_id
	  group by hla.description
			 , hla.location_code
	  order by 3 desc;

-- DETAILS

		select haou.name hr_org
			 , hla.location_code
			 , hla.description description
		  from hr.hr_locations_all hla
		  join hr.hr_all_organization_units haou on haou.location_id = hla.location_id;