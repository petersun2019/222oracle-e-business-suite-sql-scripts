/*
File Name: hr-operating-units.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- HR OPERATING UNITS
-- ##################################################################

		select haou.business_group_id
			 , haou.organization_id
			 , haoutl.name
			 , haou.date_from
			 , haou.date_to
			 , hoi_2.org_information5
			 , hoi_2.org_information3
			 , hoi_2.org_information2
			 , hoi_2.org_information6
		  from hr.hr_all_organization_units haou
		  join hr.hr_all_organization_units_tl haoutl on haou.organization_id = haoutl.organization_id
		  join hr.hr_organization_information hoi_1 on haou.organization_id = hoi_1.organization_id
		  join hr.hr_organization_information hoi_2 on haou.organization_id = hoi_2.organization_id
		 where 1 = 1
		   and hoi_1.org_information_context || '' = 'CLASS'
		   and hoi_2.org_information_context = 'Operating Unit Information'
		   and hoi_1.org_information1 = 'OPERATING_UNIT'
		   and hoi_1.org_information2 = 'Y'
		   and haoutl.language = userenv('lang')
		   and 1 = 1;
