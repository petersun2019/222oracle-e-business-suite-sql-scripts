/*
File Name:		sa-core-apps-top-ten-linked-to-resps.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- CORE APPS TOP TEN LIST LINKED TO RESPS
-- ##################################################################

		select fu.description
			 , fu.user_name
			 , frt.responsibility_name resp
			 , fudo.sequence seq
			 , fffv.user_function_name
		  from applsys.fnd_user_desktop_objects fudo
		  join applsys.fnd_user fu on fudo.user_id = fu.user_id 
		  join applsys.fnd_responsibility_tl frt on fudo.responsibility_id = frt.responsibility_id
		  join apps.fnd_form_functions_vl fffv on fudo.function_name = fffv.function_name 
		 where fu.user_name = 'USER123'
	  order by 1, 2, 3, 4;
