/*
File Name:		hr-organizations.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- HR ORGANIZATIONS
-- ##################################################################

		select haou.organization_id id
			 , haou.name
			 , haou.type
			 , haou.creation_date 
			 , fu.description created_by
			 , fu.email_address created_by_email
			 , haou.last_update_date
			 , lu.description updated_by
			 , lu.email_address updated_by_email
			 , '####'
			 , haou.attribute_category
			 , haou.attribute1
			 , haou.attribute2
			 , haou.attribute3
			 , haou.attribute4
			 , haou.attribute5
		  from hr.hr_all_organization_units haou
		  join applsys.fnd_user fu on haou.created_by = fu.user_id
		  join applsys.fnd_user lu on haou.last_updated_by = lu.user_id
		 where 1 = 1
		   -- and haou.name like 'P%'
		   -- and haou.organization_id in (select distinct carrying_out_organization_id from pa_projects_all where carrying_out_organization_id = haou.organization_id)
		   and 1 = 1
	  order by haou.last_update_date desc;
