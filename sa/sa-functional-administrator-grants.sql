/*
File Name:		sa-functional-administrator-grants.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- AME ACCESS / GRANTS
-- ##################################################################

		select granteo.grant_guid
			 , granteo.grantee_type
			 , granteo.grantee_key
			 , granteo.menu_id
			 , granteo.object_id
			 , granteo.instance_type
			 , to_char(granteo.start_date, 'DD-MM-YYYY') start_date
			 , to_char(granteo.end_date, 'DD-MM-YYYY') end_date
			 , decode(granteo.grantee_key, null, null,(select display_name from wf_all_roles_vl where name = granteo.grantee_key)) as grantee_name
			 , decode(granteo.object_id, -1, null, (select display_name from fnd_objects_vl where object_id = granteo.object_id)) as object_name
			 , mn.user_menu_name as menu_name
			 , decode ((select type from fnd_menus where menu_id = granteo.menu_id), 'SECURITY','PSET', 'MENU') as set_type
			 , granteo.name
			 , granteo.creation_date
			 , granteo.last_update_date
			 , fu.user_name created_by
			 -- , granteo.program_tag
			 -- , substr(trim(',' from trim(' ' from (decode(granteo.instance_pk1_value, null, null, '*NULL*', null, '' || granteo.instance_pk1_value || ', ') ||decode(granteo.instance_pk2_value, null, null, '*NULL*', null, '' || granteo.instance_pk2_value || ', ') ||decode(granteo.instance_pk3_value, null, null, '*NULL*', null, '' || granteo.instance_pk3_value || ', ') ||decode(granteo.instance_pk4_value, null, null, '*NULL*', null, '' || granteo.instance_pk4_value || ', ') ||decode(granteo.instance_pk5_value, null, null, '*NULL*', null, '' || granteo.instance_pk5_value || ', ') ||decode(granteo.instance_set_id, null, null, '*NULL*', null, '' || granteo.instance_set_id || ', ') ))), 0, 80) as access_policy
			 -- , nvl2(granteo.instance_set_id,(select display_name from fnd_object_instance_sets_vl where instance_set_id = granteo.instance_set_id and object_id = granteo.object_id), null) as instance_set_name
			 -- , granteo.instance_set_id 
		  from fnd_grants granteo
		  join fnd_menus_vl mn on granteo.menu_id = mn.menu_id
		  join fnd_user fu on granteo.created_by = fu.user_id
		 where 1 = 1
		   -- and granteo.start_date > '01-NOV-2021'
		   and decode(granteo.object_id, -1, null, (select display_name from fnd_objects_vl where object_id = granteo.object_id)) = 'AME Transaction Types'
		   and 1 = 1;
