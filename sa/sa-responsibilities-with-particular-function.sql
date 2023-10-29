/*
File Name:		sa-responsibilities-with-particular-function.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- RESPS ATTACHED TO A FUNCTION 
-- ##################################################################

/*
RETURN RESPS WITH ACCESS TO A PARTICULAR FUNCTION, ANY LEVEL DOWN, NOT JUST TOP LEVEL
ENTER FUNCTION NAME - .E.G AR_ARXCWMAI_QIT
*/

		select distinct frt.responsibility_id
			 , frt.responsibility_name
			 , fr.responsibility_key
			 , fr.creation_date
			 , fa.application_short_name
			 , fmt.user_menu_name menu
			 , (select distinct count(*) from fnd_user fu, fnd_user_resp_groups_direct furg where furg.user_id = fu.user_id and frt.responsibility_id = furg.responsibility_id and nvl(furg.end_date, sysdate + 1) > sysdate and nvl(fu.end_date, sysdate + 1) > sysdate and fr.end_date is null) user_ct
		  from fnd_responsibility fr
		  join fnd_responsibility_tl frt on fr.application_id = frt.application_id and fr.responsibility_id = frt.responsibility_id 
		  join fnd_application fa on fa.application_id = fr.application_id 
		  join wf_local_user_roles wlur on fr.responsibility_id = wlur.role_orig_system_id 
	 left join fnd_menus_tl fmt on fr.menu_id = fmt.menu_id -- responsibilities are not always linked to a menu
		 where wlur.role_orig_system = 'FND_RESP'
		   and sysdate between fr.start_date and nvl(fr.end_date , sysdate + 1)
		   and sysdate between wlur.start_date and nvl(wlur.expiration_date, sysdate + 1)
		   and fr.menu_id in ( select menu_id
								 from fnd_menu_entries fme
					 connect by prior fme.menu_id = fme.sub_menu_id
						   start with fme.function_id = (select function_id
														   from fnd_form_functions fff
														  where fff.function_name = :function_name));
