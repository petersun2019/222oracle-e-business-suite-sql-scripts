/*
File Name: sa-menus-and-functions.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- BASIC MENUS
-- RESPONSIBILITIES ASSIGNED TO MENUS 
-- COUNT OF RESPONSIBILITIES ASSIGNED TO A MENU
-- MENU FLAT VIEW
-- MENU TREE VIEW - VERSION 1
-- MENU TREE VIEW - VERSION 2
-- MENU TREE VIEW - VERSION 3
-- MENU TREE VIEW - VERSION 4
-- MENU TREE VIEW - VERSION 5
-- MENU TREE VIEW - VERSION 6
-- MENU TREE VIEW - VERSION 7
-- MENU TREE VIEW - VERSION 8 (INCLUDING FUNCTIONS)
-- FUNCTIONS

*/

-- ##################################################################
-- BASIC MENUS
-- ##################################################################

		select fm.menu_id
			 , fm.menu_name
			 , fm.type
			 , fmt.user_menu_name
		  from applsys.fnd_menus fm
		  join applsys.fnd_menus_tl fmt on fm.menu_id = fmt.menu_id
		 where user_menu_name = 'Supply Base: Management';

-- ##################################################################
-- RESPONSIBILITIES ASSIGNED TO MENUS 
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , fat.application_name
			 , fa.application_short_name
			 , frt.responsibility_id
			 , frt.responsibility_name
			 , fmt.user_menu_name
		  from applsys.fnd_responsibility fr
		  join applsys.fnd_responsibility_tl frt on fr.application_id = frt.application_id and frt.language = userenv('lang')
		  join applsys.fnd_menus_tl fmt on fr.responsibility_id = frt.responsibility_id and fr.menu_id = fmt.menu_id
		  join applsys.fnd_application fa on frt.application_id = fa.application_id 
		  join applsys.fnd_application_tl fat on fr.application_id = fa.application_id and fa.application_id = fat.application_id and fat.language = userenv('lang')
		 where 1 = 1
		   and nvl(fr.end_date, sysdate + 1) > sysdate -- responsibility is active
		   and fmt.user_menu_name = 'Project Financials Sub Tab'
	  order by fa.application_short_name
			 , frt.responsibility_name;

-- ##################################################################
-- COUNT OF RESPONSIBILITIES ASSIGNED TO A MENU
-- ##################################################################

		select fmt.user_menu_name
			 , count(distinct frt.responsibility_id) count
		  from applsys.fnd_responsibility fr
		  join applsys.fnd_responsibility_tl frt on fr.responsibility_id = frt.responsibility_id and fr.application_id = frt.application_id and frt.language = userenv('lang')
		  join applsys.fnd_menus_tl fmt on fr.menu_id = fmt.menu_id and fmt.language = userenv('lang')
		 where fmt.user_menu_name = 'INV_NAVIGATE'
	  group by fmt.user_menu_name;

-- ##################################################################
-- MENU FLAT VIEW
-- ##################################################################

		select fmv.menu_name
			 , fmv.menu_id
			 , fmv.user_menu_name
			 , fmev.entry_sequence seq
			 , fmev.prompt
			 , case when fmev.sub_menu_id is not null then (select user_menu_name from fnd_menus_vl where menu_id = fmev.sub_menu_id) end user_menu_name 
			 , case when fmev.sub_menu_id is not null then (select menu_name from fnd_menus where menu_id = fmev.sub_menu_id) end menu_name
			 , case when fmev.function_id is not null then (select user_function_name from fnd_form_functions_vl where function_id = fmev.function_id) end user_function_name
			 , case when fmev.function_id is not null then (select function_name from fnd_form_functions where function_id = fmev.function_id) end function_name
			 , fmev.description
			 , fmev.menu_id
			 , fmev.sub_menu_id
		  from fnd_menus_vl fmv
		  join fnd_menu_entries_vl fmev on fmev.menu_id = fmv.menu_id
		   -- and user_menu_name = 'Purchasing SuperUser GUI'
		   -- and user_menu_name = 'Project Financials Sub Tab'
		   and fmv.menu_name = 'PA_FINANCIAL_SUB_TAB'
		   and 1 = 1;

-- ##################################################################
-- MENU TREE VIEW - VERSION 1
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , fmev.entry_sequence seq
			 , level
			 , lpad (' ', (level - 1) * 3, '_') || fmv.user_menu_name menu
			 , lpad (' ', (level - 1) * 3, '_') || fmev.prompt prompt
			 , fmv.menu_name
			 , fmv.user_menu_name
			 , fmv.creation_date entry_created
			 , fu1.user_name entry_created_by
			 , fmv.last_update_date entry_updated
			 , fu2.user_name entry_updated_by
			 , case
					when fmev.function_id is not null then
					(select user_function_name
							  from apps.fnd_form_functions_vl
							 where function_id = fmev.function_id)
			   end user_function_name
			 , case
					when fmev.function_id is not null then
					(select function_id
							  from apps.fnd_menu_entries_vl
							 where function_id = fmev.function_id and menu_id = fmv.menu_id)
								   end function_id
			 , case
					when fmev.function_id is not null then
					(select function_name
							  from apps.fnd_form_functions_vl
							 where function_id = fmev.function_id)
								   end function_name
			 , case
					when fmev.function_id is not null then
					(select description
							  from apps.fnd_menu_entries_vl
							 where function_id = fmev.function_id and menu_id = fmv.menu_id)
								   end function_description
			 , fmev.description entry_description
		  from apps.fnd_menus_vl fmv
		  join apps.fnd_menu_entries_vl fmev on fmev.menu_id = fmv.menu_id
		  join apps.fnd_user fu1 on fmev.created_by = fu1.user_id
		  join apps.fnd_user fu2 on fmev.last_updated_by = fu2.user_id
		 where 1 = 1
	connect by fmev.menu_id = prior fmev.sub_menu_id
	start with fmv.user_menu_name = 'Desktop Integration Manager Menu'
order siblings by fmev.entry_sequence;

-- ##################################################################
-- MENU TREE VIEW - VERSION 2
-- ##################################################################

		select fmev.entry_sequence seq
			 , level
			 , lpad(' ', (level - 1) * 4, ' ') || fmev.prompt prompt
		  from apps.fnd_menus_vl fmv
		  join apps.fnd_menu_entries_vl fmev on fmev.menu_id = fmv.menu_id
	 left join apps.fnd_responsibility_vl frv on frv.menu_id = fmv.menu_id
	 left join apps.fnd_menus_vl fmv2 on fmv2.menu_id = fmev.sub_menu_id
	 left join apps.fnd_resp_functions frf on frf.responsibility_id = frv.responsibility_id and frf.action_id = fmev.sub_menu_id
		 where fmev.prompt is not null
		   and frf.responsibility_id is null
	connect by fmev.menu_id = prior fmev.sub_menu_id
		   and fmev.prompt is not null
		   and frf.responsibility_id is null
	start with frv.responsibility_name = 'System Administrator'
order siblings by fmev.entry_sequence;

-- ##################################################################
-- MENU TREE VIEW - VERSION 3
-- ##################################################################

		select fmev.entry_sequence seq
			 , lpad(' ', (level - 1) * 4, ' ') || fmev.prompt prompt
			 , fmev.menu_id
			 , fmev.sub_menu_id 
			 , fmev.function_id
		  from apps.fnd_menus_vl fmv
		  join applsys.fnd_menus_tl fmt on fmv.menu_id = fmt.menu_id
		  join apps.fnd_menu_entries_vl fmev on fmev.menu_id = fmv.menu_id
	 left join apps.fnd_responsibility_vl frv on fmv.menu_id = frv.menu_id
		 where fmev.prompt is not null
	connect by fmev.menu_id = prior fmev.sub_menu_id
		   and fmev.prompt is not null
	start with fmt.user_menu_name = 'INV_NAVIGATE'
order siblings by fmev.entry_sequence;

-- ##################################################################
-- MENU TREE VIEW - VERSION 4
-- ##################################################################

		select lpad(' ', (level - 1) * 3, ' ') || fmev.prompt prompt
			 , level
			 , fmev.entry_sequence
		  from apps.fnd_menus_vl fmv
		  join apps.fnd_menu_entries_vl fmev on fmev.menu_id = fmv.menu_id
		   and fmev.prompt is not null
	connect by fmev.menu_id = prior fmev.sub_menu_id 
	start with fmv.menu_name = 'INV_NAVIGATE'
order siblings by fmev.entry_sequence ;

-- ##################################################################
-- MENU TREE VIEW - VERSION 5
-- ##################################################################

		select lpad(' ', (level - 1) * 3, ' ') || fmev.prompt prompt
			 , level
			 , fmev.entry_sequence
			 , fmt.user_menu_name
			 , fmev.creation_date
			 , fu.user_name
		  from apps.fnd_menus_vl fmv
		  join apps.fnd_menu_entries_vl fmev on fmev.menu_id = fmv.menu_id
	 left join applsys.fnd_menus_tl fmt on fmv.menu_id = fmt.menu_id 
		  join applsys.fnd_user fu on fmev.created_by = fu.user_id
		 where fmev.prompt is not null
	connect by fmev.menu_id = prior fmev.sub_menu_id 
	start with fmt.user_menu_name = 'INV_NAVIGATE'
order siblings by fmev.entry_sequence;

-- ##################################################################
-- MENU TREE VIEW - VERSION 6
-- ##################################################################

		select level
			 , fm.menu_id
			 , fm.menu_name
			 , fm.user_menu_name
			 , fme.sub_menu_id
			 , fme.function_id
			 , fff.function_name
			 , fff.user_function_name
		  from apps.fnd_menus_vl fm
			 , apps.fnd_menu_entries fme
			 , apps.fnd_form_functions_vl fff
		 where fme.menu_id = fm.menu_id
		   and fff.function_id(+) = fme.function_id
	connect by fm.menu_id = prior fme.sub_menu_id
	start with fm.user_menu_name = 'INV_NAVIGATE';

-- ##################################################################
-- MENU TREE VIEW - VERSION 7
-- ##################################################################

		select m.menu_name
			 , m.user_menu_name
			 , m.sub_menu
			 , level
			 , sys_connect_by_path(m.sub_menu, '/') path
		  from (select fmv.menu_name
			 , fmv.user_menu_name
			 , fmv.user_menu_name sub_menu
			 , fmev.sub_menu_id
			 , fmv.menu_id
		  from apps.fnd_menu_entries_vl fmev
			 , apps.fnd_menus_vl fmv
		 where fmv.menu_id = fmev.menu_id) m
	connect by prior sub_menu_id = menu_id
	start with user_menu_name = 'INV_NAVIGATE';

-- ##################################################################
-- MENU TREE VIEW - VERSION 8 (INCLUDING FUNCTIONS)
-- ##################################################################

		select fmev.entry_sequence seq
			 , lpad(' ', (level - 1) * 10, ' ') || fmev.prompt prompt
			 , fmv.menu_name
			 , case
					when fmev.function_id is not null then 'Function'
					else 'Menu'
			   end m_f 
			 , case
					when fmev.function_id is not null then
					(select 'Function: ' || function_name
						  from fnd_form_functions_vl
						 where function_id = fmev.function_id)
			   else (select 'Menu: ' || menu_name
						  from fnd_menus_vl e
						 where e.menu_id = fmev.sub_menu_id)
			   end this
		  from fnd_menus_vl fmv
		  join fnd_menu_entries_vl fmev on fmev.menu_id = fmv.menu_id
	connect by fmev.menu_id = prior fmev.sub_menu_id 
	start with fmv.user_menu_name = 'Desktop Integration Manager Menu'
order siblings by fmev.entry_sequence; 

-- ##################################################################
-- FUNCTIONS
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , fff.function_id
			 , fff.function_name
			 , fffv.user_function_name
			 , fffv.description
			 , fffv.web_html_call
			 , fff.creation_date
			 , fff.created_by
			 , fff.last_update_date
			 , fff.last_updated_by
		  from fnd_form_functions fff
		  join fnd_form_functions_vl fffv on fff.function_id = fffv.function_id
		   -- and fffv.user_function_name = 'Sourcing Assignments'
		   and fff.function_name = 'PAXTTRXB'
		   and 1 = 1;
