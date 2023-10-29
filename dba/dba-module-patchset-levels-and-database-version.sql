/*
File Name: dba-module-patchset-levels-and-database-version.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- GET CURRENT EBS RELEASE VERSION
-- DATABASE VERSION
-- OPERATING SYSTEM
-- PATCHSET LEVEL FOR MODULES
-- APPLICATIONS
-- PRODUCT PATCH LEVEL 
-- APPLICATIONS / MODULES LIST AND WHETHER THEY ARE INSTALLED

*/

-- ##################################################################
-- GET CURRENT EBS RELEASE VERSION
-- ##################################################################

select * from fnd_product_groups;

		select substr (release_name, 1, 7) version
			 , substr (rpad (multi_org_flag, 2, ' '), 1, 2) multi_org_flag
			 , substr (rpad (multi_currency_flag, 3, ' '), 1, 3) multi_currency_flag
		  from apps.fnd_product_groups;

-- ##################################################################
-- DATABASE VERSION
-- ##################################################################

select * from v$version;
select version from v$instance;
select * from product_component_version;

-- ##################################################################
-- OPERATING SYSTEM
-- ##################################################################

select dbms_utility.port_string from dual;
select platform_id,platform_name from v$database;

-- ##################################################################
-- PATCHSET LEVEL FOR MODULES
-- ##################################################################

		select app_short_name
			 , max (patch_level)
		  from applsys.ad_patch_driver_minipks
		 where app_short_name = 'PA'
	  group by app_short_name
	  order by app_short_name;

		select *
		  from applsys.ad_patch_driver_minipks
		 where app_short_name = 'SQLAP'
	  order by app_short_name
			 , creation_date desc; 

-- ##################################################################
-- APPLICATIONS
-- ##################################################################

		select fa.application_id
			 , fa.application_short_name
			 , fa.basepath
			 , fa.product_code
			 , fa.creation_date
			 , fu1.user_name created_by
			 , fa.last_update_date
			 , fu2.user_name updated_by
			 , fat.application_name 
			 , fat.description
		  from fnd_application fa
		  join fnd_application_tl fat on fa.application_id = fat.application_id and fat.language = userenv('lang')
	 left join fnd_user fu1 on fa.created_by = fu1.user_id
	 left join fnd_user fu2 on fa.last_updated_by = fu2.user_id
		 where 1 = 1
		   and fa.application_short_name = 'PA'
		   -- and fat.application_name = 'Projects'
	  order by 1;

-- ##################################################################
-- PRODUCT PATCH LEVEL 
-- ##################################################################

		select fa.application_id
			 , fa.application_short_name app
			 , fat.application_name
			 , fat.creation_date
			 , fat.description
			 , fpi.creation_date
			 , fpi.product_version
			 , fpi.status
			 , fpi.patch_level
		  from applsys.fnd_product_installations fpi
		  join applsys.fnd_application_tl fat on fpi.application_id = fat.application_id and fat.language = userenv('lang')
		  join applsys.fnd_application fa on fa.application_id = fat.application_id
		 where 1 = 1
		   and fa.application_short_name = 'SQLGL'
		   -- and fat.application_name = 'Projects'
	  order by 1;

-- ##################################################################
-- APPLICATIONS / MODULES LIST AND WHETHER THEY ARE INSTALLED
-- ##################################################################

		select fa.application_id
			 , fa.application_short_name
			 , fa.creation_date
			 , fa.basepath
			 , fpi.patch_level
			 , fa.product_code
			 , fat.application_name
			 , decode(fpi.status,'I','Licensed','S','Shared','N','Not Licensed') status
		  from applsys.fnd_application fa
		  join applsys.fnd_application_tl fat on fa.application_id = fat.application_id
		  join applsys.fnd_product_installations fpi on fa.application_id = fpi.application_id
	  order by fat.application_name;
