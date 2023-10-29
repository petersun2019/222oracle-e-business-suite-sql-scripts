/*
File Name: sa-r12-navigator-favourites.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- R12 NAVIGATOR FAVORITES
-- ##################################################################

		select fu.user_name
			 , fu.description
			 , iccme.display_sequence seq
			 , iccme.prompt
			 , iccme.function_type type
			 , frt.responsibility_name
		  from icx.icx_custom_menu_entries iccme
		  join applsys.fnd_user fu on iccme.user_id = fu.user_id
		  join applsys.fnd_responsibility_tl frt on iccme.responsibility_id = frt.responsibility_id
		  join applsys.fnd_form_functions_tl ffft on iccme.function_id = ffft.function_id 
		 where fu.user_name = 'USER123'
	  order by 1,2,3;
