/*
File Name:		sa-menu-function-exclusions.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- SIMPLE EXCLUSIONS LIST
-- MENU AND FUNCTION EXCLUSIONS ON RESPONSIBILITIES

*/

-- ##################################################################
-- SIMPLE EXCLUSIONS LIST
-- ##################################################################

		select frt.responsibility_name
			 , frf.creation_date
			 , fu.description
			 , decode (frf.rule_type, 'M', 'Menu', 'F', 'Function') type_
			 , case
					when frf.rule_type = 'M' then (select fmv.user_menu_name
												     from fnd_menus_vl fmv
												    where frf.action_id = fmv.menu_id
												      and frf.rule_type = 'M')
					when frf.rule_type = 'F' then (select ffvl.user_function_name
												     from fnd_form_functions_vl ffvl
												    where frf.action_id = ffvl.function_id
												      and frf.rule_type = 'F')
					end user_menu_or_function_name
			 , case
					when frf.rule_type = 'M' then (select fmv.menu_name
												     from fnd_menus fmv
												    where frf.action_id = fmv.menu_id
												      and frf.rule_type = 'M')
					when frf.rule_type = 'F' then (select ffvl.function_name
												     from fnd_form_functions ffvl
												    where frf.action_id = ffvl.function_id
												      and frf.rule_type = 'F')
					end system_menu_or_function_name 
		  from fnd_resp_functions frf
		  join fnd_responsibility_tl frt on frf.responsibility_id = frt.responsibility_id
		  join fnd_user fu on frf.created_by = fu.user_id 
		 where 1 = 1
		   and frt.responsibility_name in ('Projects Superuser')
		   and 1 = 1;

-- ##################################################################
-- MENU AND FUNCTION EXCLUSIONS ON RESPONSIBILITIES
-- ##################################################################

		select distinct frt.responsibility_name
			 , fmv.menu_name
			 , fmv.user_menu_name
			 , fmv.description menu_description
			 , '' function_name
			 , '' user_function_name
			 , '' function_description
		  from apps.fnd_resp_functions frf
		  join applsys.fnd_responsibility_tl frt on frf.responsibility_id = frt.responsibility_id and frt.language = userenv('lang')
		  join apps.fnd_menus_vl fmv on frf.action_id = fmv.menu_id
		 where frf.rule_type = 'M'
		   and frt.responsibility_name = 'UK Receivables User'
		union all
		select distinct frt.responsibility_name
			 , '' menu_name
			 , '' user_menu_name
			 , '' menu_description
			 , ffvl.function_name
			 , ffvl.user_function_name
			 , ffvl.description function_description
		  from apps.fnd_resp_functions frf
		  join applsys.fnd_responsibility_tl frt on frf.responsibility_id = frt.responsibility_id and frt.language = userenv('lang')
		  join apps.fnd_form_functions_vl ffvl on frf.action_id = ffvl.function_id and ffvl.application_id = frf.application_id 
		 where frf.rule_type = 'F'
		   and frt.responsibility_name = 'UK Receivables User'
	  order by responsibility_name
			 , user_menu_name
			 , user_function_name;
