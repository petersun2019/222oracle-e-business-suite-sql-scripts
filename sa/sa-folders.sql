/*
File Name: sa-folders.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- FOLDERS
-- FOLDERS AND COLUMNS
-- COLUMN COUNT PER FOLDER
-- SHARED WITH...
-- FOLDERS SHARED WITH RESPONSIBILITIES - ADMINISTER FOLDERS sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- FOLDERS
-- ##################################################################

		select distinct ff.object folder_set
			 , ff.name folder_name
			 , ff.public_flag public_
			 , nvl2 (fdf.object, 'Y', '') default_folder
			 , decode (ff.autoquery_flag, 'A', 'Ask', 'N', 'Never', 'Y', 'Always') autoqry
			 , ff.creation_date cr_date
			 , fu.description || ' (' || fu.user_name || ')' cr_by
		  from applsys.fnd_folders ff
	 left join applsys.fnd_default_folders fdf on ff.folder_id = fdf.folder_id 
		  join applsys.fnd_user fu on ff.created_by = fu.user_id
		 where ff.name like 'Misc%'
	  order by ff.object, ff.name;

-- ##################################################################
-- FOLDERS AND COLUMNS
-- ##################################################################

		select ff.object folder_set
			 , ff.folder_id
			 , ff.creation_date cr_date
			 , ff.name folder
			 , ffc.item_name
			 , ffc.item_prompt
			 , ffc.sequence
			 , ff.public_flag public_
			 , decode (ff.autoquery_flag, 'A', 'Ask', 'N', 'Never', 'Y', 'Always') autoqry 
		  from applsys.fnd_folders ff
		  join applsys.fnd_folder_columns ffc on ff.folder_id = ffc.folder_id
		 where 1 = 1
		   and ff.name = 'My Projects Folder'
		   and 1 = 1
	  order by ff.object
			 , ff.name
			 , ff.folder_id
			 , ffc.sequence;

-- ##################################################################
-- COLUMN COUNT PER FOLDER
-- ##################################################################

		select ff.object folder_set
			 , ff.folder_id
			 , ff.name folder
			 , count(*) ct 
		  from applsys.fnd_folders ff
		  join applsys.fnd_folder_columns ffc on ff.folder_id = ffc.folder_id 
	  group by ff.object
			 , ff.folder_id
			 , ff.name
	  order by ff.object
			 , ff.name;

-- ##################################################################
-- SHARED WITH...
-- ##################################################################

		select distinct b.application_short_name appl
			 , c.name folder_name
			 , c.object folder_set
			 , a.creation_date share_date
			 , case
					when a.user_id like '-%' then 'Resp'
					when a.user_id not like '-%' then 'User'
			   end shared_with 
			 , case
					when a.user_id like '-%' then (select responsibility_name from applsys.fnd_responsibility_tl frt where frt.responsibility_id = - (a.user_id))
					when a.user_id not like '-%' then (select description from applsys.fnd_user fu where fu.user_id = a.user_id)
			   end shared_with_details
		  from apps.fnd_default_folders a
		  join apps.fnd_application b on a.application_id = b.application_id
		  join apps.fnd_folders c on a.folder_id = c.folder_id 
		 where b.application_short_name = 'PA'
	  order by 1,2,6;

-- ##################################################################
-- FOLDERS SHARED WITH RESPONSIBILITIES - ADMINISTER FOLDERS sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts-- ##################################################################

		select b.application_short_name
			 , d.responsibility_name
			 , a.object
			 , c.name folder_name
			 , a.creation_date share_date
		  from apps.fnd_default_folders a
		  join apps.fnd_application b on a.application_id = b.application_id
		  join apps.fnd_folders c on a.folder_id = c.folder_id
		  join apps.fnd_responsibility_vl d on d.responsibility_id = -(a.user_id) 
		 where 1 = 1
	  order by b.application_short_name
			 , d.responsibility_name;
