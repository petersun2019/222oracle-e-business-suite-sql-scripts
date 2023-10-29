/*
File Name:		dba-file-versions.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- FILE VERSIONS 1
-- FILE VERSIONS 2
-- FILE VERSIONS 3
-- FILE VERSIONS 4
-- FILE VERSIONS 5
-- FILE VERSIONS 6
-- FILE VERSIONS 7

*/

-- ##################################################################
-- FILE VERSIONS 1
-- ##################################################################

select * from dba_source where type='PACKAGE BODY' and upper(text) like '%APXPAWKB%' and owner='APPS';
select * from dba_source where type='PACKAGE BODY' and upper(text) like '%PAFPWAPB%' and owner='APPS' and name like 'PA%' and line = 2;
select * from dba_source where name = 'PA_FP_WEBADI_PKG' and line = 2;
select * from dba_source where name = 'PO_APPRVL_ANALYZER_PKG';
select * from v$version;

-- ##################################################################
-- FILE VERSIONS 2
-- ##################################################################

-- BASIC FILE VERSION

		select f.app_short_name app
			 , f.filename
			 , afv.version
			 , afv.creation_date
			 , afv.file_version_id
			 , afv.file_id
			 , afv.version_segment1
			 , afv.version_segment2
			 , afv.version_segment3
			 , afv.version_segment4
		  from ad_file_versions afv
		  join ad_files f on afv.file_id = f.file_id
		 where 1 = 1
		   and (f.filename) like 'PAXLAIFB%'
		   and 1 = 1
	  order by afv.creation_date desc;

-- ##################################################################
-- FILE VERSIONS 3
-- ##################################################################

		select f.filename
			 , decode(f.app_short_name, 'DUMMY', null, f.app_short_name) product
			 , decode(f.subdir, 'DUMMY', null, f.subdir) directory
			 , at.name appltop
			 , afv.version file_version
			 , to_char(afv.translation_level) trans_level
			 , aap.patch_name patch_id
			 , pr.end_date run_date
			 , aap.*
		  from applsys.ad_appl_tops at
	 left join applsys.ad_patch_runs pr on at.appl_top_id = pr.appl_top_id
	 left join applsys.ad_patch_drivers pd on pr.patch_driver_id = pd.patch_driver_id
	 left join applsys.ad_applied_patches aap on pd.applied_patch_id = aap.applied_patch_id
	 left join applsys.ad_patch_run_bugs prb on prb.patch_run_id = pr.patch_run_id
	 left join applsys.ad_patch_run_bug_actions prba on prba.patch_run_bug_id = prb.patch_run_bug_id
		  join applsys.ad_file_versions afv on prba.patch_file_version_id = afv.file_version_id
		  join applsys.ad_files f on f.file_id = prba.file_id
		 where 1 = 1
		   -- and prba.executed_flag = 'Y'
		   and f.filename like 'PAXLAIFB%'
		   and 1 = 1;

-- ##################################################################
-- FILE VERSIONS 4 (HTTP://APURVA-ORACLEAPPSCRM.BLOGSPOT.COM/2013/04/CHECKING-FILE-VERSIONS-WITH-SQL-QUERY.HTML)
-- ##################################################################

		select af.app_short_name
			 , fat.application_name
			 , af.subdir
			 , af.filename
			 , afv.version
			 , afv.creation_date
		  from applsys.ad_files af
		  join applsys.ad_file_versions afv on af.file_id = afv.file_id
	 left join applsys.fnd_application fa on af.app_short_name = fa.application_short_name
	 left join applsys.fnd_application_tl fat on fa.application_id = fat.application_id and fat.language = userenv('lang')
		 where 1 = 1
		   and afv.creation_date = (select max (creation_date) from apps.ad_file_versions ver where ver.file_id = af.file_id)
		   and af.filename like 'pjmcmt%' 
		   -- and af.app_short_name = 'HZ' 
		   and 1 = 1;

-- ##################################################################
-- FILE VERSIONS 5
-- ##################################################################

		select f.filename
			 , v.version
			 , v.file_version_id
			 , v.creation_date
			 , f.subdir 
		  from applsys.ad_files f
			 , applsys.ad_file_versions v 
		 where f.file_id = v.file_id 
		   and f.filename like 'BneOAExcelViewer%' 
		   -- and version like '120.%' 
	  order by v.creation_date
			 , v.version; 

-- ##################################################################
-- FILE VERSIONS 6
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , do.status
			 , do.object_type
			 , ds.name
			 , ds.text
		  from dba_source ds
			 , dba_objects do
		 where ds.name in ('PO_LOCKS', 'PO_DOCUMENT_ACTION_PVT')
		   and ds.line=2
		   and ds.name = do.object_name
		   and ds.type = do.object_type
	  order by do.object_type
			 , ds.name;

-- ##################################################################
-- FILE VERSIONS 7
-- ##################################################################

		select instance_name instance
			 , name object
			 , type
			 , o.status
			 , last_ddl_time
			 , substr(text,13,32) "filename - version"
		  from v$instance
			 , user_source
			 , user_objects o
		 where name =o.object_name 
		   and name = 'PA_FUNDS_CONTROL_PKG1' 
		   and type = o.object_type 
		   and type like '%BODY' 
		   and line = 2;
