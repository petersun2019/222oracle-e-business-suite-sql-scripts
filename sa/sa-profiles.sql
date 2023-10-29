/*
File Name:		sa-profiles.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- PROFILE VALUES
-- PROFILE DEFINITION
-- GET PROFILE VALUE (WHILE LOGGED IN AS APPS)

*/

-- ##################################################################
-- PROFILE VALUES
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , decode(fpov.level_id, 10001, 'Site', 10002, 'Application', 10003, 'Resp', 10004, 'User', 10006, 'Organization', null, 'Not Set') "level"
			 , fpov.last_update_date updated
			 , sa_level_values.sa_set_against set_against
			 , nvl(fu.user_name, 'n/a') person
			 , fpot.user_profile_option_name profile
			 , fpo.profile_option_name profile_name
			 , fpov.profile_option_value value
			 , fpov.last_update_date profile_value_updated
			 , fu2.user_name || ' (' || fu2.email_address || ')' updated_by
		  from apps.fnd_profile_option_values fpov 
		  join apps.fnd_profile_options fpo on fpov.profile_option_id = fpo.profile_option_id
		  join apps.fnd_profile_options_tl fpot on fpot.profile_option_name = fpo.profile_option_name and fpot.language = userenv('lang')
		  join (select '10001 0' sa_level_id, 'Site' sa_set_against, '' key from dual union -- site
		select '10002' || ' ' || fat.application_id, fat.application_name, '' key from apps.fnd_application_tl fat where fat.language = userenv('lang') union -- app
		select '10003' || ' ' || frt.responsibility_id , frt.responsibility_name, fr.responsibility_key key from apps.fnd_responsibility_tl frt join fnd_responsibility fr on fr.responsibility_id = frt.responsibility_id and frt.language = userenv('lang') union -- resp
		select '10004' || ' ' || fu.user_id, fu.user_name, '' key from fnd_user fu union -- user
		select '10006' || ' ' || hou.organization_id, hou.name, '' key from apps.hr_operating_units hou) sa_level_values on fpov.level_id || ' ' || fpov.level_value = sa_level_values.sa_level_id
	 left join fnd_user fu on sa_level_values.sa_set_against = fu.user_name
		  join fnd_user fu2 on fpov.last_updated_by = fu2.user_id
		 where 1 = 1
		   -- ######################## PROFILE NAME
		   -- and fpot.user_profile_option_name = 'Applications SSO Login Types'
		   -- and fpot.user_profile_option_name = 'Disable Self-Service Personal'
		   -- and fpot.user_profile_option_name = 'FND: Diagnostics'
		   -- and fpot.user_profile_option_name = 'FND: Debug Log Enabled'
		   -- and fpot.user_profile_option_name = 'GL Journal Import: Separate Journals by Accounting Date'
		   -- and fpot.user_profile_option_name = 'HR : Image Data Migration Mode'
		   -- and fpot.user_profile_option_name = 'Initialization SQL Statement - Oracle'
		   -- and fpot.user_profile_option_name = 'MO: Operating Unit'
		   -- and fpot.user_profile_option_name = 'PA: Cost Distribution Lines Per Set'
		   -- and fpot.user_profile_option_name = 'PA: Debug Mode'
		   and fpot.user_profile_option_name = 'Site Name'
		   -- and fpot.user_profile_option_name = 'Sign-On:Audit Level'
		   -- and fpot.user_profile_option_name = 'GL: Launch AutoReverse After Open Period'
		   -- and fpot.user_profile_option_name = 'PA: Selective Flexfield Segment for AutoAccounting'
		   -- and fpot.user_profile_option_name = 'Initialization SQL Statement - Custom'
		   -- and fpot.user_profile_option_name like 'PA%'
		   -- and fpo.profile_option_name like '%3%'
		   -- and upper(fpot.user_profile_option_name) like '%ENDECA%'
		   -- and fpot.user_profile_option_name in ('Initialization SQL Statement - Custom','Initialization SQL Statement - Oracle')
		   -- and fpot.user_profile_option_name in ('Utilities:Diagnostics','Hide Diagnostics menu entry')
		   -- and fpot.user_profile_option_name in ('Hide Diagnostics menu entry','Utilities:Diagnostics')
		   -- and lower(fpot.user_profile_option_name) like 'gl%validate%period%'
		   -- ######################## VALUE 
		   -- and upper(fpov.profile_option_value) like '%@%'
		   -- ######################## LEVEL
		   and fpov.level_id = 10001 -- site
		   -- and fpov.level_id = 10002 -- application
		   -- and fpov.level_id = 10003 -- responsibility
		   -- and fpov.level_id = 10004 -- user
		   -- ######################## SET AGAINST
		   -- and sa_level_values.sa_set_against like 'Barr%'
		   -- and sa_level_values.sa_set_against in ('XX PO Administrator')
		   -- and sa_level_values.sa_set_against in ('XX Projects Setup','ZZ Projects Setup')
		   -- and sa_level_values.sa_set_against = 'USER123'
		   -- ######################## UPDATED
		   -- and fpov.last_update_date > '20-JUL-2021'
		   -- and fpov.last_update_date > sysdate - 2
		   -- and fu2.user_name = 'USER123'
		   and 1 = 1
	  order by fpov.last_update_date desc;

-- ##################################################################
-- PROFILE DEFINITION
-- ##################################################################

		select fpot.user_profile_option_name profile
			 , fpo.profile_option_name profile_name
			 , fpo.sql_validation
		  from apps.fnd_profile_options fpo
		  join apps.fnd_profile_options_tl fpot on fpot.profile_option_name = fpo.profile_option_name and fpot.language = userenv('lang')
		 where 1 = 1
		   -- and fpot.user_profile_option_name = 'Applications SSO Login Types'
		   -- and fpot.user_profile_option_name = 'FND: Debug Log Enabled'
		   -- and fpot.user_profile_option_name = 'GL Journal Import: Separate Journals by Accounting Date'
		   -- and fpot.user_profile_option_name = 'PA: Cost Distribution Lines Per Set'
		   -- and fpot.user_profile_option_name = 'PA: Debug Mode'
		   -- and fpot.user_profile_option_name = 'Signon Password Case'
		   -- and fpot.user_profile_option_name = 'Site Name'
		   -- and fpot.user_profile_option_name like 'MO%'
		   -- and fpot.user_profile_option_name like 'Disab%Self%'
		   -- and fpot.user_profile_option_name like 'PA%Selective%Flex%'
		   -- and fpot.user_profile_option_name = 'Signon Password Failure Limit'
		   and fpo.profile_option_name = 'SIGNONAUDIT:LEVEL'
		   -- and fpot.user_profile_option_name like 'FND%Debug%'
		   -- and fpot.user_profile_option_name like 'Server%Time%'
		   -- and lower(fpot.user_profile_option_name) like '%order%'
		   and 1 = 1;

-- ##################################################################
-- GET PROFILE VALUE (WHILE LOGGED IN AS APPS)
-- ##################################################################

select apps.fnd_profile.value('AR_CMGT_ALLOW_SUMMARY_TABLE_REFRESH') from dual;
