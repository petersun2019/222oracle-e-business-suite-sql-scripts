/*
File Name: dba-patch-installs.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- PATCH INSTALLS - SIMPLE SUMMARY
-- HOW TO CHECK IF A PATCH HAS BEEN APPLIED WITH ADPATCH [ID 472820.1]
-- COUNT OF BUGS INCLUDED PER PATCH INSTALL, SINCE A PATCH CAN INCLUDE MANY BUG FIXES
-- COUNT OF BUG FIXES APPLIED PER MONTH
-- COUNT OF PATCHES APPLIED PER MONTH
-- PATCH INSTALLS - RPC LEVEL

*/

-- ##################################################################
-- PATCH INSTALLS - SIMPLE SUMMARY
-- ##################################################################

		select distinct e.patch_name || '______' || d.patch_abstract 
		  from applsys.ad_bugs a
		  join applsys.ad_patch_run_bugs b on a.bug_id = b.bug_id
		  join applsys.ad_patch_runs c on b.patch_run_id = c.patch_run_id
		  join applsys.ad_patch_drivers d on c.patch_driver_id = d.patch_driver_id
		  join applsys.ad_applied_patches e on d.applied_patch_id = e.applied_patch_id
		 where c.end_date > '20-JUL-2021';


-- ##################################################################
-- HOW TO CHECK IF A PATCH HAS BEEN APPLIED WITH ADPATCH [ID 472820.1]
-- ##################################################################

		select distinct sys_context('USERENV','DB_NAME') instance
			 -- , ab.bug_number
			 , aap.patch_name
			 -- , aap.patch_type
			 -- , aap.maint_pack_level
			 -- , aprb.applied_flag 
			 -- , aprb.application_short_name
			 -- , aprb.success_flag
			 -- , apr.end_date
			 , aap.creation_date
			 -- , to_char(aap.creation_date, 'YYYY-MM') creation_date_trim
			 , apd.patch_abstract
			 -- , '###############'
			 -- , aprb.*
		  from ad_bugs ab
		  join ad_patch_run_bugs aprb on ab.bug_id = aprb.bug_id
		  join ad_patch_runs apr on apr.patch_run_id = aprb.patch_run_id
		  join ad_patch_drivers apd on apd.patch_driver_id = apr.patch_driver_id
		  join ad_applied_patches aap on aap.applied_patch_id = apd.applied_patch_id
		 where 1 = 1
		   -- and (ab.bug_number in ('31703726') or aap.patch_name in ('31703726'))
		   and to_char(aap.creation_date, 'yyyy-mm-dd') >= '2022-08-25'
		   -- and ab.bug_number in ('10019987','10040337','10107858','10108052','10130118','10202570','13700476','13901480','14015391','14209751','16399718','16399820','17035228','17322095','17415511','17415519','17429169','17429800','17429801','17445419','18198205','18402183','18402256','18402290','18689981','18719391','18789889','19079656','19141902','19273341','19382135','19559960','19900999','19901004','19907841','19907901','21823185','21900895','21900895','21900895','21931682','21931700','21959691','21959698','22999977','23122190','28609931','29961918','30662575','30674081','30674081','31255662','3218526','6455020','6699770','6896216','7621719','8218271','9278820','9437814')
		   -- and aap.patch_name in ('257447235')
		   -- and aap.creation_date >= '10-NOV-2021'
		   -- and aap.creation_date < '21-OCT-2012'
		   -- and upper(apd.patch_abstract) like '%AFCHRCHK%'
		   -- and aap.creation_date > '01-APR-2020'
		   and 1 = 1;

-- ##################################################################
-- COUNT OF BUGS INCLUDED PER PATCH INSTALL, SINCE A PATCH CAN INCLUDE MANY BUG FIXES
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , aap.patch_name
			 , aap.creation_date
			 , count(*) bug_count
			 , nvl(apd.patch_abstract, 'N/A') patch_abstract
		  from ad_bugs ab
		  join ad_patch_run_bugs aprb on ab.bug_id = aprb.bug_id
		  join ad_patch_runs apr on apr.patch_run_id = aprb.patch_run_id
		  join ad_patch_drivers apd on apd.patch_driver_id = apr.patch_driver_id
		  join ad_applied_patches aap on aap.applied_patch_id = apd.applied_patch_id
		 where 1 = 1
		   and aap.creation_date > '20-MAY-2022'
		   -- and aap.creation_date >= '10-NOV-2021'
		   -- and aap.patch_name = '17020683'
		   and 1 = 1
	  group by sys_context('USERENV','DB_NAME')
			 , aap.patch_name
			 , aap.creation_date
			 , apd.patch_abstract
	  order by aap.creation_date;

		select e.creation_date || '___' || e.patch_name || '___' || d.patch_abstract || '___' || count(*) info
		  from ad_bugs a
		  join ad_patch_run_bugs b on a.bug_id = b.bug_id
		  join ad_patch_runs c on b.patch_run_id = c.patch_run_id
		  join ad_patch_drivers d on c.patch_driver_id = d.patch_driver_id
		  join ad_applied_patches e on d.applied_patch_id = e.applied_patch_id
		 where 1 = 1
		   -- and c.end_date > '01-feb-2019' 
		   and e.patch_name = '31703726'
		   and 1 = 1
	  group by e.patch_name
			 , e.creation_date
			 , d.patch_abstract
	  order by 1;

-- ##################################################################
-- COUNT OF BUG FIXES APPLIED PER MONTH
-- ##################################################################

		select to_char(creation_date, 'yyyy-mm-dd') dd
			 , count(*) ct 
		  from ad_bugs
		 where creation_date > '01-JAN-2022'
	  group by to_char(creation_date, 'yyyy-mm-dd')
	  order by to_char(creation_date, 'yyyy-mm-dd') desc;

-- ##################################################################
-- COUNT OF PATCHES APPLIED PER MONTH
-- ##################################################################

		select to_char(creation_date, 'YYYY-MM') dd
			 , count(*) ct 
		  from ad_applied_patches
		 where creation_date > '01-JAN-2022'
	  group by to_char(creation_date, 'YYYY-MM')
	  order by to_char(creation_date, 'YYYY-MM') desc;

-- ##################################################################
-- PATCH INSTALLS - RPC LEVEL
-- ##################################################################

		select distinct patch_name patchnum
			 , decode(patch_name, '7303029','Oracle E-Business Suite Consolidated Upgrade Patch 1 (CUP1) for R12.1.1'
								, '16791553','Oracle E-Business Suite Consolidated Upgrade Patch 2 (CUP2) for R12.1.1'
								, '20203366','Oracle E-Business Suite Release 12.1.3+ Recommended Patch Collection 3 [RPC3]'
								, '21236633','Oracle E-Business Suite Release 12.1.3+ Recommended Patch Collection 4 [RPC4]'
								, '22644544','Oracle E-Business Suite Release 12.1.3+ Recommended Patch Collection 5 [RPC5]') patchname
		  from (select patch_name from ad_applied_patches union select bug_number from ad_bugs)
		 where patch_name in ('7303029', '16791553', '20203366', '21236633', '22644544')
	  order by patchnum desc;
