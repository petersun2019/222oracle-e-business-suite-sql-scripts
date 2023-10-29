/*
File Name: sa-notifications.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- RESPONSIBILITY ACCESS LIST
-- UNION DIRECT AND INDIRECT ACCESSES
-- DIFFERENCES - RESPS ASSIGNED TO ONE USER BUT NOT OTHER
-- CHECK FOR A RESPONSIBILITY NAME WITH MENUS, ETC.
-- DIRECT / INDIRECT
-- SECURING ATTRIBUTES AGAINST A RESPONSIBILITY 1
-- SECURING ATTRIBUTES AGAINST A RESPONSIBILITY 2
-- FULL USER ACCESS LIST LINKED TO HR TABLES
-- COUNT BY RESPONSIBILITY AND APPLICATION
-- COUNT PER APPLICATION
-- IN USE APPLICATIONS
-- USER COUNT PER RESP
-- SIMPLE COUNT PER USER
-- SIMPLE COUNT PER RESP
-- SIMPLE COUNT PER BUSINESS GROUP
-- UMX ROLES AGAINST A USER
-- CHECK TO SEE IF USERS OF ONE RESP. HAVE ACCESS TO ANOTHER ONE

*/

-- ##################################################################
-- RESPONSIBILITY ACCESS LIST
-- ##################################################################

/*
Some resps are assigned directly - if so, use "fnd_user_resp_groups_direct"
If resps are assigned indirectly, use "fnd_user_resp_groups_indirect"
*/

		select fu.user_name
			 , fu.description
			 , fu.employee_id
			 , to_char(fu.start_date, 'DD-MON-YYYY') user_start_date
			 , to_char(fu.end_date, 'DD-MON-YYYY') user_end_date
			 , fu.user_id
			 , fu.email_address
			 , papf.full_name
			 , '#' || 0 || papf.employee_number employee_number
			 , bg.name business_group
			 , fr.responsibility_id
			 , fr.responsibility_key
			 , frt.responsibility_name
			 , decode(fr.version, '4', 'Oracle Applications', 'W', 'Oracle Self Service Web Applications','M', 'Mobile') "available from"
			 , fat.application_id
			 , fat.application_name
			 , fa.application_short_name
			 , furg.creation_date resp_added_date
			 , fu3.user_name resp_added_by
			 , fu3.email_address resp_added_by_email
			 , to_char(furg.start_date, 'DD-MON-YYYY') resp_start_date
			 , to_char(furg.end_date, 'DD-MON-YYYY') resp_end_date
			 , furg.creation_date resp_access_added
			 , furg.last_update_date resp_access_updated
			 , fu2.user_name resp_access_upd_by
			 , furg.description resp_added_notes
			 , fu.last_logon_date
			 , round(sysdate - fu.last_logon_date, 0) logon_gap
		  from fnd_user_resp_groups_direct furg
		  join fnd_user fu on furg.user_id = fu.user_id 
		  join fnd_responsibility_tl frt on furg.responsibility_id = frt.responsibility_id and frt.language = userenv('lang')
		  join fnd_responsibility fr on fr.responsibility_id = frt.responsibility_id and fr.application_id = frt.application_id
		  join fnd_application fa on fr.application_id = fa.application_id
		  join fnd_application_tl fat on fa.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_user fu2 on fu2.user_id = furg.last_updated_by
		  join fnd_user fu3 on fu3.user_id = furg.created_by
	 left join per_all_people_f papf on fu.employee_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join hr_all_organization_units bg on papf.business_group_id = bg.organization_id
		 where 1 = 1
		   and nvl(fu.end_date, sysdate + 1) > sysdate
		   and nvl(fr.end_date, sysdate + 1) > sysdate
		   -- and nvl(furg.end_date, sysdate + 1) > sysdate
		   -- ##################### RESP ##################### 
		   and frt.responsibility_name in ('XX Projects Setup')
		   -- and lower(frt.responsibility_name) like 'xx%proj%acc%set%'
		   -- ##################### USERS ##################### 
		   -- and fu.user_id = 1600
		   -- and fu.user_id = furg.created_by
		   -- and fu.user_name in ('USER123')
		   -- and fu.employee_id is null
		   -- and to_char(furg.creation_date, 'DD-MON-YYYY') = '18-MAR-2021'
		   -- and bg.name in ('UK Business Group','XX Business Group')
		   -- and fu.user_id = furg.created_by -- user assigned their own access
		   -- and papf.full_name = 'Duck, Mr Daffy'
		   -- ##################### LOGINS ##################### 
		   -- and (fu.last_logon_date is null or fu.last_logon_date < '01-JAN-2021')
		   -- and logins.user_id is null
		   -- ##################### OTHER ##################### 
		   -- and fa.application_short_name = 'AR'
		   and (select count(distinct furg.user_id) from fnd_user_resp_groups_direct furg where furg.user_id = fu.user_id and nvl(furg.end_date, sysdate + 1) > sysdate) > 0 -- assigned to users
		   and 1 = 1
	  order by fu.user_name
			 , frt.responsibility_name;

-- ##################################################################
-- UNION DIRECT AND INDIRECT ACCESSES
-- ##################################################################

		select fa.application_id
			 , fu.user_name
			 , fu.user_id
			 , fr.responsibility_id
			 , frt.responsibility_name
			 , 'Y' direct
			 , null indirect
		  from fnd_user_resp_groups_direct furg
		  join fnd_user fu on furg.user_id = fu.user_id 
		  join fnd_responsibility_tl frt on furg.responsibility_id = frt.responsibility_id and frt.language = userenv('lang')
		  join fnd_responsibility fr on fr.responsibility_id = frt.responsibility_id and fr.application_id = frt.application_id
		  join fnd_application fa on fr.application_id = fa.application_id
		 where nvl(fu.end_date, sysdate + 1) > sysdate
		   and nvl(fr.end_date, sysdate + 1) > sysdate
		   and nvl(furg.end_date, sysdate + 1) > sysdate
		   and fu.user_name in ('USER123')
		   and fa.application_short_name = 'PA'
		   and 1 = 1
		union
		select fa.application_id
			 , fu.user_name
			 , fu.user_id
			 , fr.responsibility_id
			 , frt.responsibility_name
			 , null direct
			 , 'Y' indirect
		  from fnd_user_resp_groups_indirect furg
		  join fnd_user fu on furg.user_id = fu.user_id 
		  join fnd_responsibility_tl frt on furg.responsibility_id = frt.responsibility_id and frt.language = userenv('lang')
		  join fnd_responsibility fr on fr.responsibility_id = frt.responsibility_id and fr.application_id = frt.application_id
		  join fnd_application fa on fr.application_id = fa.application_id
		 where nvl(fu.end_date, sysdate + 1) > sysdate
		   and nvl(fr.end_date, sysdate + 1) > sysdate
		   and nvl(furg.end_date, sysdate + 1) > sysdate
		   and fu.user_name in ('USER123')
		   and fa.application_short_name = 'PA'
		   and 1 = 1;

-- ##################################################################
-- DIFFERENCES - RESPS ASSIGNED TO ONE USER BUT NOT OTHER
-- ##################################################################

		select fr.responsibility_id
			 , fr.responsibility_key
			 , frt.responsibility_name
		  from fnd_user_resp_groups_direct furg
		  join fnd_user fu on furg.user_id = fu.user_id 
		  join fnd_responsibility_tl frt on furg.responsibility_id = frt.responsibility_id and frt.language = userenv('lang')
		  join fnd_responsibility fr on fr.responsibility_id = frt.responsibility_id and fr.application_id = frt.application_id
		 where 1 = 1
		   and nvl(furg.end_date, sysdate + 1) > sysdate
		   and nvl(fu.end_date, sysdate + 1) > sysdate
		   and nvl(fr.end_date, sysdate + 1) > sysdate
		   and fu.user_name = 'USER123'
		minus
		select fr.responsibility_id
			 , fr.responsibility_key
			 , frt.responsibility_name
		  from fnd_user_resp_groups_direct furg
		  join fnd_user fu on furg.user_id = fu.user_id 
		  join fnd_responsibility_tl frt on furg.responsibility_id = frt.responsibility_id and frt.language = userenv('lang')
		  join fnd_responsibility fr on fr.responsibility_id = frt.responsibility_id and fr.application_id = frt.application_id
		 where 1 = 1
		   and nvl(furg.end_date, sysdate + 1) > sysdate
		   and nvl(fu.end_date, sysdate + 1) > sysdate
		   and nvl(fr.end_date, sysdate + 1) > sysdate
		   and fu.user_name = 'USER999';

-- ##################################################################
-- CHECK FOR A RESPONSIBILITY NAME WITH MENUS, ETC.
-- ##################################################################

/*
Index on fnd_responsibility is made up of:

fnd_responsibility_u1 (application_id + responsibility_id)
fnd_responsibility_u2 (application_id + responsibility_key)

Therefore it is possible to have more than 1 resp with the same responsibility_id on fnd_responsibility
*/

		select fr.responsibility_id "id"
			 , frt.responsibility_name "responsibility name"
			 , frt.description "responsibility description"
			 , fr.last_update_date
			 , fr.creation_date
			 , (select count(distinct fu.user_id) from fnd_user fu, fnd_user_resp_groups_direct furg where furg.user_id = fu.user_id and frt.responsibility_id = furg.responsibility_id and nvl(furg.end_date, sysdate + 1) > sysdate and nvl(fu.end_date, sysdate + 1) > sysdate and nvl(fr.end_date, sysdate + 1) > sysdate) direct_user_ct
			 , (select count(distinct fu.user_id) from fnd_user fu, fnd_user_resp_groups_indirect furg where furg.user_id = fu.user_id and frt.responsibility_id = furg.responsibility_id and nvl(furg.end_date, sysdate + 1) > sysdate and nvl(fu.end_date, sysdate + 1) > sysdate and nvl(fr.end_date, sysdate + 1) > sysdate) indirect_user_ct
			 , fa.application_id
			 , fa.application_short_name "application"
			 , fat.application_name "application name"
			 , fr.responsibility_key "responsibility key"
			 , fr.menu_id
			 , frt.description "responsibility description"
			 , to_char(fr.start_date, 'DD-MON-YYYY') "start date"
			 , to_char(fr.end_date, 'DD-MON-YYYY') "end date"
			 , decode(fr.version, '4', 'Oracle Applications', 'W', 'Oracle Self Service Web Applications','M', 'Mobile') "available from"
			 , fdg.data_group_name "data group name"
			 , fat2.application_name "data group application"
			 , fmt.user_menu_name "menu name"
			 , frg.request_group_name "request group name"
			 , fat3.application_name "request group application"
			 , fr.creation_date "responsibility creation date"
			 , fu.description "responsibility created by"
			 , fu.user_name "responsibility created by user"
		  from fnd_responsibility fr
		  join fnd_responsibility_tl frt on fr.responsibility_id = frt.responsibility_id and fr.application_id = frt.application_id and frt.language = userenv('lang')
		  join fnd_application fa on fr.application_id = fa.application_id
		  join fnd_application_tl fat on fa.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_application_tl fat2 on fr.data_group_application_id = fat2.application_id and fat2.language = userenv('lang')
		  join fnd_data_groups fdg on fr.data_group_id = fdg.data_group_id
		  join fnd_user fu on fr.created_by = fu.user_id
	 left join fnd_application_tl fat3 on fr.group_application_id = fat3.application_id and fat3.language = userenv('lang') -- responsibilities are not always linked to a request group
	 left join fnd_request_groups frg on fr.request_group_id = frg.request_group_id and fr.application_id = frg.application_id -- responsibilities are not always linked to a request group
	 left join fnd_menus_tl fmt on fr.menu_id = fmt.menu_id and fmt.language = userenv('lang') -- responsibilities are not always linked to a menu
		 where 1 = 1
		   -- and frt.responsibility_name = 'Desktop Integration Manager'
		   -- and fa.application_short_name = 'OFA'
		   -- and frt.responsibility_name like 'XX Projects%Finance%'
		   -- and fat.application_name = 'Assets'
		   -- and fmt.user_menu_name = 'AP_NAVIGATE_GUI12'
		   -- and fr.responsibility_id = 1234
		   and (select count(distinct fu.user_id) from fnd_user fu, fnd_user_resp_groups_direct furg where furg.user_id = fu.user_id and frt.responsibility_id = furg.responsibility_id and nvl(furg.end_date, sysdate + 1) > sysdate and nvl(fu.end_date, sysdate + 1) > sysdate and fr.end_date is null) > 0
		   and lower(frt.responsibility_name) like '%gen%ledger%'
		   -- and fr.responsibility_key like 'XX%PA%'
		   -- and frt.responsibility_name in ('XX Projects Super User', 'XX Projects Manager')
		   -- and frg.request_group_name = 'XX Projects Super User'
		   -- and not regexp_like(fr.responsibility_key, '[0-9]')
		   -- and fr.creation_date > '01-OCT-2018'
	  order by 2;

-- ##################################################################
-- DIRECT / INDIRECT
-- ##################################################################

with my_data as
	   (select fa.application_short_name
			 , fat.application_name
			 , (select count(distinct fu.user_id) from fnd_user fu, fnd_user_resp_groups_direct furg where furg.user_id = fu.user_id and frt.responsibility_id = furg.responsibility_id and nvl(furg.end_date, sysdate + 1) > sysdate and nvl(fu.end_date, sysdate + 1) > sysdate and nvl(fr.end_date, sysdate + 1) > sysdate) direct_user_ct
			 , (select count(distinct fu.user_id) from fnd_user fu, fnd_user_resp_groups_indirect furg where furg.user_id = fu.user_id and frt.responsibility_id = furg.responsibility_id and nvl(furg.end_date, sysdate + 1) > sysdate and nvl(fu.end_date, sysdate + 1) > sysdate and nvl(fr.end_date, sysdate + 1) > sysdate) indirect_user_ct
		  from fnd_responsibility fr
		  join fnd_responsibility_tl frt on fr.responsibility_id = frt.responsibility_id and fr.application_id = frt.application_id
		  join fnd_application fa on fr.application_id = fa.application_id
		  join fnd_application_tl fat on fa.application_id = fat.application_id
		   and fa.application_short_name in ('PER')
		   and ((select count(distinct fu.user_id) from fnd_user fu, fnd_user_resp_groups_direct furg where furg.user_id = fu.user_id and frt.responsibility_id = furg.responsibility_id and nvl(furg.end_date, sysdate + 1) > sysdate and nvl(fu.end_date, sysdate + 1) > sysdate and fr.end_date is null) > 0 or (select count(distinct fu.user_id) from fnd_user fu, fnd_user_resp_groups_indirect furg where furg.user_id = fu.user_id and frt.responsibility_id = furg.responsibility_id and nvl(furg.end_date, sysdate + 1) > sysdate and nvl(fu.end_date, sysdate + 1) > sysdate and fr.end_date is null) > 0)
	  order by 2)
		select application_short_name
			 , application_name
			 , sum(direct_user_ct + indirect_user_ct) user_count
		  from my_data
	  group by application_short_name
			 , application_name;

-- ##################################################################
-- SECURING ATTRIBUTES AGAINST A RESPONSIBILITY 1
-- ##################################################################

		select frt.responsibility_name
			 , frt.responsibility_id
			 , arsa.attribute_code
			 , arsav.number_value
		  from applsys.fnd_responsibility fr
		  join applsys.fnd_responsibility_tl frt on fr.responsibility_id = frt.responsibility_id 
		  join ak.ak_resp_security_attributes arsa on fr.responsibility_id = arsa.responsibility_id and fr.application_id = arsa.resp_application_id 
	 left join ak.ak_resp_security_attr_values arsav on arsa.responsibility_id = arsav.responsibility_id and arsa.attribute_code = arsav.attribute_code 
		 where sysdate between fr.start_date and nvl(fr.end_date, sysdate + 1)
		   and arsa.attribute_code in ('ICX_SUPPLIER_SITE_ID', 'ICX_SUPPLIER_ORG_ID', 'ICX_SUPPLIER_CONTACT_ID')
		   and 1 = 1;

-- ##################################################################
-- SECURING ATTRIBUTES AGAINST A RESPONSIBILITY 2
-- ##################################################################

		select frt.responsibility_name
			 , arsa.attribute_code
			 , (select count(distinct fu.user_id) 
				  from fnd_user fu
					 , fnd_user_resp_groups_direct furg 
				 where furg.user_id = fu.user_id 
				   and frt.responsibility_id = furg.responsibility_id 
				   and nvl(furg.end_date, sysdate + 1) > sysdate 
				   and nvl(fu.end_date, sysdate + 1) > sysdate) user_count
		  from ak_resp_security_attributes arsa
		  join fnd_responsibility_tl frt on frt.responsibility_id = arsa.responsibility_id
		 where 1 = 1
		   and arsa.attribute_code in ('TO_PERSON_ID','ICX_CUSTOMER_CONTACT_ID','ICX_HR_PERSON_ID')
		   and 1 = 1;

-- ##################################################################
-- FULL USER ACCESS LIST LINKED TO HR TABLES
-- ##################################################################

		select papf.full_name
			 , papf.employee_number empno
			 , fu.user_name un
			 , fu.description
			 , haout.name hr_org 
			 , frt.responsibility_name
			 , papf.email_address
			 , hlat.description user_location
			 , hlat.location_code user_location_code
			 , fat.application_name application
			 , to_char(furg.start_date, 'DD-MON-YYYY') resp_start
			 , fu.email_address
			 , fu3.description granted_by
		  from applsys.fnd_user fu
		  join hr.per_all_people_f papf on fu.employee_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
		  join hr.per_all_assignments_f paaf on paaf.person_id = papf.person_id and sysdate between paaf.effective_start_date and paaf.effective_end_date
		  join apps.fnd_user_resp_groups_direct furg on furg.user_id = fu.user_id 
		  join applsys.fnd_responsibility fr on fr.responsibility_id = furg.responsibility_id
		  join applsys.fnd_responsibility_tl frt on frt.responsibility_id = fr.responsibility_id and fr.application_id = frt.application_id
		  join applsys.fnd_application fa on fa.application_id = fr.application_id
		  join applsys.fnd_application_tl fat on fat.application_id = fa.application_id 
		  join applsys.fnd_user fu3 on fu3.user_id = furg.created_by 
		  join applsys.fnd_user fu2 on fu2.user_id = furg.last_updated_by
		  join hr.hr_all_organization_units_tl haout on haout.organization_id = paaf.organization_id
		  join hr.hr_locations_all_tl hlat on hlat.location_id = paaf.location_id
		 where 1 = 1
		   -- and nvl(furg.end_date, sysdate + 1) > sysdate
		   -- and nvl(fu.end_date, sysdate + 1) > sysdate
		   -- and papf.current_employee_flag = 'Y'
		   -- and paaf.assignment_type = 'E'
		   -- and paaf.primary_flag = 'Y'
		   -- and fa.application_short_name = 'PA'
		   and furg.creation_date > '04-mar-2019'
		   -- and frt.responsibility_name = 'Collections Administrator'
		   -- and fu.user_name in ('USER123','USER321')
	  order by papf.full_name
			 , frt.responsibility_name;

-- ##################################################################
-- COUNT BY RESPONSIBILITY AND APPLICATION
-- ##################################################################

		select frt.responsibility_name
			 , fat.application_name app
			 , fa.application_short_name app2
			 , count(*) user_count
		  from fnd_user_resp_groups_direct furg
		  join fnd_user fu on furg.user_id = fu.user_id 
		  join fnd_responsibility_tl frt on furg.responsibility_id = frt.responsibility_id
		  join fnd_responsibility fr on fr.responsibility_id = frt.responsibility_id and fr.application_id = frt.application_id
		  join fnd_application fa on fr.application_id = fa.application_id
		  join fnd_application_tl fat on fa.application_id = fat.application_id
		  join fnd_menus_tl fmt on fr.menu_id = fmt.menu_id
		  join fnd_user fu2 on fu2.user_id = furg.last_updated_by
		  join fnd_user fu3 on fu3.user_id = furg.created_by
		 where 1 = 1
		   and nvl(furg.end_date, sysdate + 1) > sysdate
		   and nvl(fu.end_date, sysdate + 1) > sysdate
		   and fu.employee_id is not null
		   and (select distinct count(*) from fnd_user fu, fnd_user_resp_groups_direct furg where furg.user_id = fu.user_id and frt.responsibility_id = furg.responsibility_id and nvl(furg.end_date, sysdate + 1) > sysdate and nvl(fu.end_date, sysdate + 1) > sysdate and fr.end_date is null) > 0
		   and 1 = 1
	  group by frt.responsibility_name
			 , fat.application_name
			 , fa.application_short_name;

-- ##################################################################
-- COUNT PER APPLICATION
-- ##################################################################

		select fat.application_name application
			 , fa.application_short_name
			 , count(*) user_count
		  from fnd_user fu
		  join fnd_user_resp_groups_indirect furg on fu.user_id = furg.user_id 
		  join fnd_responsibility fr on fr.responsibility_id = furg.responsibility_id
		  join fnd_responsibility_tl frt on frt.responsibility_id = fr.responsibility_id and fr.application_id = frt.application_id
		  join fnd_application fa on fr.application_id = fa.application_id
		  join fnd_application_tl fat on fat.application_id = fa.application_id 
		 where 1 = 1
		   -- and fu.user_name = :un
		   -- and furg.creation_date >= '01-JAN-2007'
		   -- and frt.responsibility_name = 'ABM Manager'
		   -- and fa.application_short_name = 'PER' -- HR
		   and nvl(furg.end_date, sysdate + 1) > sysdate
		   and nvl(fu.end_date, sysdate + 1) > sysdate
		   -- and (select distinct count(*) from fnd_user fu, fnd_user_resp_groups_direct furg where furg.user_id = fu.user_id and frt.responsibility_id = furg.responsibility_id and nvl(furg.end_date, sysdate + 1) > sysdate and nvl(fu.end_date, sysdate + 1) > sysdate and fr.end_date is null) > 0
	  group by fat.application_name
			 , fa.application_short_name
	  order by 2 desc;

-- ##################################################################
-- IN USE APPLICATIONS
-- ##################################################################

		select fat.application_name || ' (' || fa.application_short_name || ')' module
			 , count(*)
		  from applsys.fnd_user fu
		  join apps.fnd_user_resp_groups_indirect furg on fu.user_id = furg.user_id 
		  join applsys.fnd_responsibility fr on fr.responsibility_id = furg.responsibility_id
		  join applsys.fnd_responsibility_tl frt on frt.responsibility_id = fr.responsibility_id and fr.application_id = frt.application_id
		  join applsys.fnd_application fa on fr.application_id = fa.application_id
		  join applsys.fnd_application_tl fat on fat.application_id = fa.application_id
		 where nvl(furg.end_date, sysdate + 1) > sysdate
		   and nvl(fu.end_date, sysdate + 1) > sysdate
		   and nvl(fr.end_date, sysdate + 1) > sysdate
		   and fa.application_short_name = 'JTF'
	  group by fat.application_name || ' (' || fa.application_short_name || ')'
	  order by 1;

-- ##################################################################
-- USER COUNT PER RESP
-- ##################################################################

		select fat.application_name module
			 , frt.responsibility_name
			 , fr.responsibility_key
			 , (select distinct count(*)
				  from applsys.fnd_user fu
					 , apps.fnd_user_resp_groups_indirect furg
				 where furg.user_id = fu.user_id
				   and frt.responsibility_id = furg.responsibility_id
				   and nvl(furg.end_date, sysdate + 1) > sysdate) user_ct
			 , (select count(*)
				  from applsys.fnd_concurrent_requests fcr
				 where fcr.responsibility_id = fr.responsibility_id) job_ct
		  from applsys.fnd_responsibility fr
		  join applsys.fnd_responsibility_tl frt on fr.responsibility_id = frt.responsibility_id and fr.application_id = frt.application_id
		  join applsys.fnd_application_tl fat on fat.application_id = frt.application_id 
		  join applsys.fnd_request_groups frg on frg.request_group_id = fr.request_group_id 
		 where fat.application_name = 'Receivables'
		   and (select count(*)
		  from applsys.fnd_user fu
		  join apps.fnd_user_resp_groups_indirect furg on furg.user_id = fu.user_id
		 where frt.responsibility_id = furg.responsibility_id
		   and nvl(furg.end_date, sysdate + 1) > sysdate) > 1
		   and nvl(fr.end_date, sysdate + 1) > sysdate;

-- ##################################################################
-- SIMPLE COUNT PER USER
-- ##################################################################

		select fu.user_name
			 , fu.description
			 , count(*) ct
		  from applsys.fnd_user fu
		  join apps.fnd_user_resp_groups_direct furg on fu.user_id = furg.user_id
		  join applsys.fnd_responsibility_tl frt on frt.responsibility_id = furg.responsibility_id 
		 where nvl(furg.end_date, sysdate + 1) > sysdate
		   and nvl(fu.end_date, sysdate + 1) > sysdate
	  group by fu.user_name
			 , fu.description
	  order by 3 desc;

-- ##################################################################
-- SIMPLE COUNT PER RESP
-- ##################################################################

		select frt.responsibility_name
			 , count(*)
		  from applsys.fnd_user fu
		  join apps.fnd_user_resp_groups_direct furg on fu.user_id = furg.user_id 
		  join applsys.fnd_responsibility_tl frt on frt.responsibility_id = furg.responsibility_id
		 where nvl(furg.end_date, sysdate + 1) > sysdate
		   and nvl(fu.end_date, sysdate + 1) > sysdate
	  group by frt.responsibility_name
	  order by 2 desc;

-- ##################################################################
-- SIMPLE COUNT PER BUSINESS GROUP
-- ##################################################################

		select bg.name business_group
			 , count(*)
		  from fnd_user fu
		  join per_all_people_f papf on fu.employee_id = papf.person_id
		  join hr_all_organization_units bg on papf.business_group_id = bg.organization_id
		 where 1 = 1
		   and nvl(fu.end_date, sysdate + 1) > sysdate
		   and sysdate between papf.effective_start_date and papf.effective_end_date
		   and 1 = 1
	  group by bg.name;

-- ##################################################################
-- UMX ROLES AGAINST A USER
-- ##################################################################

alter session set nls_language = 'AMERICAN';
exec dbms_application_info.set_client_info(82);

		select fu.user_name
			 , fu.description
			 , urav.display_name
			 , urav.*
		  from apps.umx_role_assignments_v urav
		  join applsys.fnd_user fu on urav.user_id = fu.user_id
		   and urav.user_name = 'NOBLE0'
		   and role_name like '%UMX%'
		   and status_code = 'APPROVED'
		   -- and urav.display_name = 'XX Concurrent Request Output'
	  order by fu.description
			 , urav.display_name;

-- ##################################################################
-- CHECK TO SEE IF USERS OF ONE RESP. HAVE ACCESS TO ANOTHER ONE
-- ##################################################################

		select distinct fu.user_name
			 , fu.description
			 , fu.email_address
			 , furg.start_date
			 , (select furg.start_date
				  from apps.fnd_user_resp_groups_direct furg
				  join apps.fnd_responsibility_tl frt on furg.responsibility_id = frt.responsibility_id 
				  join apps.fnd_responsibility fr on fr.responsibility_id = frt.responsibility_id 
				 where furg.user_id = fu.user_id -- link to table outside this sub-selected
				   and frt.responsibility_name = 'XX Projects Manager'
				   and nvl (furg.end_date, sysdate + 1) > sysdate
				   and nvl (fu.end_date, sysdate + 1) > sysdate) gl_jnls_check
		  from applsys.fnd_user fu
		  join apps.fnd_user_resp_groups_direct furg on fu.user_id = furg.user_id 
		  join applsys.fnd_responsibility fr on fr.responsibility_id = furg.responsibility_id
		  join applsys.fnd_application fa on fa.application_id = fr.application_id
		  join applsys.fnd_responsibility_tl frt on frt.responsibility_id = fr.responsibility_id and fr.application_id = frt.application_id
		  join applsys.fnd_menus_tl fmt on fmt.menu_id = fr.menu_id
		 where frt.responsibility_name = 'XX Project Super User'
		   and nvl (furg.end_date, sysdate + 1) > sysdate
		   and nvl (fu.end_date, sysdate + 1) > sysdate
		   and 1 = 1;
