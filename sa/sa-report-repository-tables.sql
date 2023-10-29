/*
File Name: sa-report-repository-tables.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- FRM_USER_VALUE_MAPPINGS
-- FRM_MENU_USER_MAPPINGS 1
-- FRM_MENU_USER_MAPPINGS 2
-- FRM_USER_PUB_OPTIONS
-- FRM_DOCUMENTS_VL
-- DOCUMENTS 1
-- DOCUMENTS 2
-- DOCUMENTS 3
-- DOCUMENTS 4
-- DOCUMENTS 5
-- DOCUMENTS 6

*/

-- ##################################################################
-- FRM_USER_VALUE_MAPPINGS
-- ##################################################################

		select fu.user_name
			 , fuvm.*
		  from frm_user_value_mappings fuvm
		  join fnd_user fu on fuvm.user_id = fu.user_id
		 where 1 = 1
		   -- and fuvm.user_id = 123
		   -- and fu.user_name like 'USER12%'
		   and 1 = 1;

-- ##################################################################
-- FRM_MENU_USER_MAPPINGS 1
-- ##################################################################

		select fu.user_name
			 , fu.last_logon_date
			 , fu2.user_name access_added_by
			 , fu2.email_address accessed_added_by_email
			 , fdt.user_name folder
			 , fmum.creation_date
			 , fmum.last_update_date
			 , fmum.*
		  from frm_menu_user_mappings fmum
		  join fnd_user fu on fmum.user_id = fu.user_id
		  join fnd_user fu2 on fmum.created_by = fu2.user_id
	 left join frm_directory_tl fdt on fmum.node_id = fdt.directory_id
		 where 1 = 1
		   and fu.user_name in ('USER123')
		   -- and fu.user_id not in (select user_id from frm_user_pub_options)
		   and 1 = 1;

-- ##################################################################
-- FRM_MENU_USER_MAPPINGS 2
-- ##################################################################

		select fu.user_name
			 , count(*)
		  from frm_menu_user_mappings fmum
		  join fnd_user fu on fmum.user_id = fu.user_id
		 where 1 = 1
		   and fu.user_name like 'USER%'
		   and 1 = 1
	  group by fu.user_name
	  order by 2;

-- ##################################################################
-- FRM_USER_PUB_OPTIONS
-- ##################################################################

		select fu.user_name
			 , fupo.*
		  from frm_user_pub_options fupo
		  join fnd_user fu on fupo.user_id = fu.user_id
		 where 1 = 1
		   -- and user_id = 32238 -- nothing
		   and fu.user_name like 'USER%'
		   and 1 = 1;

-- ##################################################################
-- FRM_DOCUMENTS_VL
-- ##################################################################

		select *
		  from frm_documents_vl
		 where 1 = 1
		   and 1 = 1;

-- ##################################################################
-- DOCUMENTS 1
-- ##################################################################

		select frb.directory_id
			 , frb.parent_id
			 , frb.sequence_number
			 , frt.user_name directory
		  from frm_directory_b frb
		  join frm_directory_tl frt on frb.directory_id = frt.directory_id
		 where 1 = 1
		   and 1 = 1;

-- ##################################################################
-- DOCUMENTS 2
-- ##################################################################

		select *
		  from frm_directory_b;

-- ##################################################################
-- DOCUMENTS 3
-- ##################################################################

		select *
		  from frm_directory_tl;

-- ##################################################################
-- DOCUMENTS 4
-- ##################################################################

		select b.rowid row_id
			 , b.document_id document_id
			 , b.directory_id directory_id
			 , b.sequence_number sequence_number
			 , b.expanded_flag expanded_flag
			 , b.ds_app_short_name ds_app_short_name
			 , b.data_source_code data_source_code
			 , b.object_version_number object_version_number
			 , t.user_name user_name
			 , b.creation_date creation_date
			 , b.created_by created_by
			 , b.last_updated_by last_updated_by
			 , b.last_update_login last_update_login
			 , b.last_update_date last_update_date
			 , b.end_date end_date
			 , b.archived_flag archived_flag
		  from frm_documents_b b
		     , frm_documents_tl t 
		 where b.document_id = t.document_id 
		   and t.language=userenv('LANG');

-- ##################################################################
-- DOCUMENTS 5
-- ##################################################################

		select frb.directory_id
			 , frb.parent_id
			 , frb.sequence_number
			 , frt.user_name directory
			 , level
			 , sys_connect_by_path(frb.directory_id, '/') path
		  from frm_directory_b frb
		  join frm_directory_tl frt on frb.directory_id = frt.directory_id
	connect by prior frb.parent_id = frb.directory_id
	start with frb.directory_id = 0;

-- ##################################################################
-- DOCUMENTS 6
-- ##################################################################

		select lpad('_', (level - 1) * 2, '_') || frt.user_name folder
			 , frb.directory_id
			 , frb.parent_id
			 , frb.sequence_number
			 , frt.user_name directory
			 , level
			 , sys_connect_by_path(frb.directory_id, '/') path
		  from frm_directory_b frb
		  join frm_directory_tl frt on frb.directory_id = frt.directory_id
-- connect by prior frb.directory_id = frb.directory_id
	start with frb.directory_id = 106
	connect by nocycle prior frb.directory_id = frb.parent_id;
