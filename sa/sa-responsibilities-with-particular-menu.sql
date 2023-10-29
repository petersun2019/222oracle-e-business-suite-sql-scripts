/*
File Name:		sa-responsibilities-with-particular-menu.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- RESPS ATTACHED TO A MENU
-- WITHOUT LINKING TO RESPONSIBILITIES

*/

-- ##################################################################
-- RESPS ATTACHED TO A MENU 
-- ##################################################################

/*
RETURN RESPS WITH ACCESS TO A PARTICULAR MENU, ANY LEVEL DOWN, NOT JUST TOP LEVEL
ENTER USER MENU NAME - .E.G "AR_INTERFACE_GUI"
*/

		select distinct frt.responsibility_name
			 , fr.responsibility_key
			 , fr.responsibility_id
			 , (select distinct count (*) from applsys.fnd_user fu, apps.fnd_user_resp_groups_indirect furg where furg.user_id = fu.user_id and frt.responsibility_id = furg.responsibility_id and nvl(furg.end_date, sysdate + 1) > sysdate and nvl(fu.end_date, sysdate + 1) > sysdate) user_count_indirect
			 , (select distinct count (*) from applsys.fnd_user fu, apps.fnd_user_resp_groups_direct furg where furg.user_id = fu.user_id and frt.responsibility_id = furg.responsibility_id and nvl(furg.end_date, sysdate + 1) > sysdate and nvl(fu.end_date, sysdate + 1) > sysdate) user_count_direct
			 , fat.application_name app
			 , fm.menu_name
			 , fmt.user_menu_name
		  from applsys.fnd_responsibility fr
		  join applsys.fnd_responsibility_tl frt on fr.application_id = frt.application_id and fr.responsibility_id = frt.responsibility_id
		  join applsys.fnd_application_tl fat on fr.application_id = fat.application_id 
		  join applsys.wf_local_user_roles wlur on fr.responsibility_id = wlur.role_orig_system_id 
		  join applsys.fnd_menus_tl fmt on fr.menu_id = fmt.menu_id 
		  join applsys.fnd_menus fm on fm.menu_id = fmt.menu_id
		 where fr.menu_id in (select menu_id
							    from applsys.fnd_menu_entries fme
					connect by prior fme.menu_id = fme.sub_menu_id
						  start with fme.menu_id = (select fmv.menu_id
													  from apps.fnd_menus_vl fmv
													 where fmv.user_menu_name = 'Project Financial Sub Tab'))
	  order by 2;

-- ##################################################################
-- WITHOUT LINKING TO RESPONSIBILITIES
-- ##################################################################

/*
SINCE SOME MENUS ARE NOT LINKED TO RESPONSIBILITIES, BUT MIGHT BE A PARENT MENU CONTAINING A SUB MENU YOU WANT TO DELETE
*/

		select distinct fm.menu_name
			 , fmt.user_menu_name
		  from applsys.fnd_menus_tl fmt
			 , applsys.fnd_menus fm
		 where fm.menu_id = fmt.menu_id
		   -- and fmt.user_menu_name != :menu
		   and fmt.menu_id in (select menu_id
							    from applsys.fnd_menu_entries fme
					connect by prior fme.menu_id = fme.sub_menu_id
						  start with fme.menu_id = (select fmv.menu_id
													  from apps.fnd_menus_vl fmv
													 where fmv.user_menu_name = :menu))
	  order by 2;
