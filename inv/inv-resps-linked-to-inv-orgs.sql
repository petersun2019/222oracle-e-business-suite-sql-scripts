/*
File Name:		inv-resps-linked-to-inv-orgs.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- INVENTORY RESPONSIBILITIES LINKED TO INVENTORY ORGS
-- ##################################################################

-- INVENTORY > SETUP > ORGANIZATIONS > ORGANIZATION ACCESS

-- RESPS LINKED TO INV ORGS

		select oa.creation_date
			 , haou.name org
			 , fat.application_name application
			 , frt.responsibility_name resp
			 , oa.creation_date access_created_on
			 , fu.description created_by
		  from inv.org_access oa
		  join hr.hr_all_organization_units haou on oa.organization_id = haou.organization_id
		  join applsys.fnd_application_tl fat on oa.resp_application_id = fat.application_id
		  join applsys.fnd_responsibility_tl frt on oa.responsibility_id = frt.responsibility_id
		  join applsys.fnd_user fu on oa.created_by = fu.user_id
		 where 1 = 1;

-- COUNT OF INV ORGS PER RESP

		select frt.responsibility_name resp
			 , count (*) ct
		  from inv.org_access oa
		  join hr.hr_all_organization_units haou on oa.organization_id = haou.organization_id
		  join applsys.fnd_responsibility_tl frt on oa.responsibility_id = frt.responsibility_id
		  join applsys.fnd_application_tl fat on oa.resp_application_id = fat.application_id
		 where 1 = 1
	  group by frt.responsibility_name
	  order by frt.responsibility_name;
