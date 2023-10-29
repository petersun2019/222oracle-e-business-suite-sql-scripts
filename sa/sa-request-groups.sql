/*
File Name:		sa-request-groups.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- REQUEST GROUPS AND RESPONSIBILITIES - CONCURRENT REQUESTS
-- REQUEST GROUPS AND RESPONSIBILITIES - REQUEST SETS
-- REQUEST GROUPS AND RESPONSIBILITIES - LINKED TO APPLICATIONS
-- JOBS AND REQUEST SETS LINKED TO RESPS
-- REQUEST GROUP DETAILS
-- CONCURRENT REQUESTS AND WHETHER ASSIGNED TO A REQUEST GROUP
-- REQUEST SETS AND WHETHER ASSIGNED TO A REQUEST GROUP
-- REQUEST GROUPS AGAINST RESPS - BASIC LIST
-- REQUEST SETS
-- COMPARING TWO REQUEST GROUPS - IN ONE AND NOT IN THE OTHER

*/

-- ##################################################################
-- REQUEST GROUPS AND RESPONSIBILITIES - CONCURRENT REQUESTS
-- ##################################################################

/*
THIS IS USEFUL IF YOU WANT TO WORK OUT WHICH RESPONSIBILITIES HAVE ACCESS TO
SPECIFIC CONCURRENT REQUESTS, REQUEST SETS OR APPLICATIONS
*/

		select frg.request_group_name
			 , frg.request_group_id
			 , fat.application_name
			 , frt.responsibility_name
			 -- , (select distinct count(*) from fnd_user fu, fnd_user_resp_groups_direct furg where furg.user_id = fu.user_id and frt.responsibility_id = furg.responsibility_id and nvl(furg.end_date, sysdate + 1) > sysdate and nvl(fu.end_date, sysdate + 1) > sysdate and fr.end_date is null) user_count
			 , frt.creation_date
			 , frgu.creation_date resp_group_line_added
			 , fu.user_name resp_group_line_added_by
			 , frt.created_by
			 , to_char(fr.end_date, 'DD-MON-YYYY') "end date"
			 , fcpt.user_concurrent_program_name job_name
			 , decode(frgu.request_unit_type,'S','Request Set','P','Program') job_type
			 , fat2.application_name job_app
		  from fnd_request_groups frg
		  join fnd_request_group_units frgu on frg.application_id = frgu.application_id and frg.request_group_id = frgu.request_group_id and frgu.request_unit_type = 'P'
		  join fnd_concurrent_programs_tl fcpt on frgu.request_unit_id = fcpt.concurrent_program_id and fcpt.language = userenv('lang')
		  join fnd_responsibility fr on fr.request_group_id = frg.request_group_id
		  join fnd_responsibility_tl frt on fr.responsibility_id = frt.responsibility_id and frt.language = userenv('lang')
		  join fnd_application_tl fat on frgu.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_application_tl fat2 on frgu.unit_application_id = fat2.application_id and fat2.language = userenv('lang')
		  join fnd_user fu on frgu.created_by = fu.user_id
		 where 1 = 1
		   and fcpt.user_concurrent_program_name = 'PRC: Refresh Project and Resource Base Summaries'
		   and 1 = 1;

-- ##################################################################
-- REQUEST GROUPS AND RESPONSIBILITIES - REQUEST SETS
-- ##################################################################

		select frg.request_group_name
			 , fat.application_name
			 , frt.responsibility_name
			 , fat2.application_name resp_app
			 , frst.user_request_set_name job_name
			 , decode(frgu.request_unit_type,'S','Request Set','P','Program') job_type
			 , fat2.application_name job_app
			 , frg.zd_edition_name
			 , frgu.zd_edition_name
		  from applsys.fnd_request_groups frg
		  join applsys.fnd_request_group_units frgu on frg.application_id = frgu.application_id and frg.request_group_id = frgu.request_group_id and frgu.request_unit_type = 'S' and frg.zd_edition_name = frgu.zd_edition_name
		  join applsys.fnd_responsibility fr on fr.request_group_id = frg.request_group_id
		  join applsys.fnd_responsibility_tl frt on fr.responsibility_id = frt.responsibility_id and frt.language = userenv('lang')
		  join applsys.fnd_request_sets_tl frst on frgu.request_unit_id = frst.request_set_id and frst.language = userenv('lang')
		  join applsys.fnd_application_tl fat on frgu.application_id = fat.application_id and fat.language = userenv('lang')
		  join applsys.fnd_application_tl fat2 on frgu.unit_application_id = fat2.application_id and fat2.language = userenv('lang')
		  join applsys.fnd_application_tl fat3 on fr.application_id = fat3.application_id and fat3.language = userenv('lang')
		 where 1 = 1 
		   and frt.responsibility_name = 'Receivables Manager'
		   and frgu.zd_edition_name = 'SET2'
	  order by 1, 2, 4;

-- ##################################################################
-- REQUEST GROUPS AND RESPONSIBILITIES - LINKED TO APPLICATIONS
-- ##################################################################

		select distinct frg.request_group_name
			 , fat.application_name
			 , frt.responsibility_name
			 , fat2.application_name assigned_application_name
		  from applsys.fnd_request_groups frg 
		  join applsys.fnd_request_group_units frgu on frg.application_id = frgu.application_id and frg.request_group_id = frgu.request_group_id
		  join applsys.fnd_responsibility fr on fr.request_group_id = frg.request_group_id
		  join applsys.fnd_responsibility_tl frt on fr.responsibility_id = frt.responsibility_id and frt.language = userenv('lang')
		  join applsys.fnd_application_tl fat on frgu.application_id = fat.application_id and fat.language = userenv('lang')
		  join applsys.fnd_application_tl fat2 on frgu.unit_application_id = fat2.application_id and fat2.language = userenv('lang')
		 where frt.responsibility_name = 'UK Receivables Superuser'
	  order by 1, 2;

-- ##################################################################
-- JOBS AND REQUEST SETS LINKED TO RESPS
-- ##################################################################

		select frg.request_group_id
			 , frgu.request_unit_id, frt.responsibility_name
			 , case when frgu.request_unit_type = 'P' then
				   (select '[' || fcp.enabled_flag || '] ' || fcpt.user_concurrent_program_name job
					  from fnd_concurrent_programs fcp
						 , fnd_concurrent_programs_tl fcpt
					 where fcp.concurrent_program_id = fcpt.concurrent_program_id
					   and frgu.request_unit_id = fcpt.concurrent_program_id
					   and frgu.request_unit_type = 'P'
					   and frgu.request_group_id = frg.request_group_id
					   and frgu.unit_application_id = fcpt.application_id
					   and frgu.unit_application_id = fcp.application_id
					   -- and fcp.enabled_flag = 'Y'
					   and fcpt.language = userenv('lang')
					   and 1 = 1)
					when frgu.request_unit_type = 'S' then
				   (select frst.user_request_set_name 
					  from fnd_request_sets_tl frst 
					  join fnd_request_sets frs on frst.request_set_id = frs.request_set_id 
					 where frst.request_set_id = frgu.request_unit_id 
					   and frgu.unit_application_id = frs.application_id
					   and frgu.unit_application_id = frst.application_id
					   and nvl(frs.end_date_active, sysdate + 1) > sysdate
					   and frst.language = userenv('lang')
					   and 1 = 1)
					when frgu.request_unit_type = 'A' then
				   (select fat.application_name from fnd_application_tl fat where fat.application_id = frgu.request_unit_id and fat.language = userenv('lang'))
			   end name
			 , decode(frgu.request_unit_type, 'P', 'Program', 'S', 'Request Set', 'A', 'Application') type
			 , frgu.request_unit_type
		  from fnd_request_groups frg
		  join fnd_request_group_units frgu on frg.request_group_id = frgu.request_group_id
		  join fnd_responsibility fr on fr.request_group_id = frg.request_group_id
		  join fnd_responsibility_tl frt on fr.responsibility_id = frt.responsibility_id and frt.language = userenv('lang')
		 where 1 = 1
		   -- and frg.request_group_name = 'Receivables All'
		   and frt.responsibility_name = 'UK Receivables Superuser'
		   -- and frgu.request_unit_type = 'P'
		   and 1 = 1
	  order by frt.responsibility_name;

-- ##################################################################
-- REQUEST GROUP DETAILS
-- ##################################################################

		select frg.request_group_name
			 , frg.creation_date
			 , fu1.user_name created_by
			 , fat1.application_name group_application
			 , frgu.creation_date
			 , decode(frgu.request_unit_type, 'P', 'Program', 'S', 'Request Set', 'A', 'Application') type
			 , case when frgu.request_unit_type = 'P' then
						(select fcp.user_concurrent_program_name from fnd_concurrent_programs_tl fcp where fcp.concurrent_program_id = frgu.request_unit_id and fcp.application_id = fat2.application_id)
					when frgu.request_unit_type = 'S' then
						(select frst.user_request_set_name from fnd_request_sets_tl frst where frst.request_set_id = frgu.request_unit_id and frst.application_id = fat2.application_id)
					when frgu.request_unit_type = 'A' then
						(select fat.application_name from fnd_application_tl fat where fat.application_id = frgu.request_unit_id)
			   end name
			 , case when frgu.request_unit_type = 'P' then
						(select fcpt.enabled_flag from fnd_concurrent_programs fcpt where fcpt.concurrent_program_id = frgu.request_unit_id and fcpt.application_id = fat2.application_id)
			   end job_enabled
			 , case when frgu.request_unit_type = 'P' then
						(select fcpt.concurrent_program_id from fnd_concurrent_programs fcpt where fcpt.concurrent_program_id = frgu.request_unit_id and fcpt.application_id = fat2.application_id)
			   end job_id
			 , case when frgu.request_unit_type = 'S' then
						(select frs.end_date_active from fnd_request_sets frs where frs.request_set_id = frgu.request_unit_id and frs.application_id = fat2.application_id)
			   end request_set_end_date
			 , case when frgu.request_unit_type = 'S' then
						(select frs.request_set_id from fnd_request_sets frs where frs.request_set_id = frgu.request_unit_id and frs.application_id = fat2.application_id)
			   end request_set_id
			 , fat2.application_name application
			 , frgu.last_update_date line_updated
			 , fu1.user_name line_updated_by 
		  from fnd_request_groups frg
		  join fnd_request_group_units frgu on frg.application_id = frgu.application_id and frg.request_group_id = frgu.request_group_id
	 left join fnd_application_tl fat1 on frg.application_id = fat1.application_id
	 left join fnd_application_tl fat2 on frgu.unit_application_id = fat2.application_id
	 left join fnd_user fu1 on frg.created_by = fu1.user_id
	 left join fnd_user fu2 on frgu.last_updated_by = fu2.user_id
		 where 1 = 1
		   -- and frg.request_group_name = 'All Reports'
		   -- and fat1.application_name = 'Payables'
		   and frg.request_group_name like 'Receivables All'
		   and frgu.request_unit_type = 'S'
		   and 1 = 1;

-- ##################################################################
-- CONCURRENT REQUESTS AND WHETHER ASSIGNED TO A REQUEST GROUP
-- ##################################################################

		select fcpt.user_concurrent_program_name request_name
			 , fat.application_name
			 , fcpt.creation_date
			 , fu.user_name created_by
			 , (select count(*)
		  from fnd_request_group_units frgu
		 where frgu.request_unit_type = 'P'
		   and frgu.request_unit_id = fcpt.concurrent_program_id) request_group_count
		  from fnd_concurrent_programs_tl fcpt
		  join fnd_application_tl fat on fcpt.application_id = fat.application_id
		  join fnd_user fu on fcpt.created_by = fu.user_id
		 where 1 = 1
		   and fcpt.user_concurrent_program_name = 'Mask External Bank Account Data'
	  order by fcpt.user_concurrent_program_name;

-- ##################################################################
-- REQUEST SETS AND WHETHER ASSIGNED TO A REQUEST GROUP
-- ##################################################################

		select frst.user_request_set_name
			 , fat.application_name
			 , frst.creation_date
			 , fu.description created_by
			 , (select count(*)
		  from applsys.fnd_request_group_units frgu
		 where frgu.request_unit_type = 'S'
		   and frgu.request_unit_id = frst.request_set_id) request_group_count
		  from applsys.fnd_request_sets_tl frst
		  join applsys.fnd_application_tl fat on frst.application_id = fat.application_id
		  join applsys.fnd_user fu on frst.created_by = fu.user_id
		 where frst.user_request_set_name = 'Purge Transaction Objects Diagnostics'
	  order by frst.user_request_set_name;

-- ##################################################################
-- REQUEST GROUPS AGAINST RESPS - BASIC LIST
-- ##################################################################

		select rtl.responsibility_name
			 , rg.request_group_name
			 , rg.description
			 , fat.application_name
		  from applsys.fnd_responsibility_tl rtl
		  join applsys.fnd_responsibility r on rtl.responsibility_id = r.responsibility_id
		  join applsys.fnd_request_groups rg on r.request_group_id = rg.request_group_id and r.group_application_id = rg.application_id
		  join applsys.fnd_application_tl fat on r.application_id = fat.application_id
		 where rtl.responsibility_name like 'XX%Payables%';

-- ##################################################################
-- REQUEST SETS
-- ##################################################################

select * from applsys.fnd_request_sets_tl frst;

-- ##################################################################
-- COMPARING TWO REQUEST GROUPS - IN ONE AND NOT IN THE OTHER
-- ##################################################################

		select case when frgu.request_unit_type = 'P' then
						(select fcp.user_concurrent_program_name from fnd_concurrent_programs_tl fcp where fcp.concurrent_program_id = frgu.request_unit_id and fcp.application_id = fat2.application_id)
					when frgu.request_unit_type = 'S' then
						(select frst.user_request_set_name from fnd_request_sets_tl frst where frst.request_set_id = frgu.request_unit_id and frst.application_id = fat2.application_id)
					when frgu.request_unit_type = 'A' then
						(select fat.application_name from fnd_application_tl fat where fat.application_id = frgu.request_unit_id)
			   end name
			 , decode(frgu.request_unit_type, 'P', 'Program', 'S', 'Request Set', 'A', 'Application') type
			 , case when frgu.request_unit_type = 'P' then
						(select fcp.creation_date from fnd_concurrent_programs_tl fcp where fcp.concurrent_program_id = frgu.request_unit_id and fcp.application_id = fat2.application_id)
			   end job_created
			 , case when frgu.request_unit_type = 'P' then
						(select fcp.last_update_date from fnd_concurrent_programs_tl fcp where fcp.concurrent_program_id = frgu.request_unit_id and fcp.application_id = fat2.application_id)
			   end job_updated
			 , case when frgu.request_unit_type = 'P' then
						(select fcpt.enabled_flag from fnd_concurrent_programs fcpt where fcpt.concurrent_program_id = frgu.request_unit_id and fcpt.application_id = fat2.application_id)
			   end job_enabled
			 , case when frgu.request_unit_type = 'P' then
						(select fcpt.concurrent_program_id from fnd_concurrent_programs fcpt where fcpt.concurrent_program_id = frgu.request_unit_id and fcpt.application_id = fat2.application_id)
			   end job_id
			 , case when frgu.request_unit_type = 'S' then
						(select frs.end_date_active from fnd_request_sets frs where frs.request_set_id = frgu.request_unit_id and frs.application_id = fat2.application_id)
			   end request_set_end_date
			 , case when frgu.request_unit_type = 'S' then
						(select frs.request_set_id from fnd_request_sets frs where frs.request_set_id = frgu.request_unit_id and frs.application_id = fat2.application_id)
			   end request_set_id
			 , fat2.application_name application
		  from fnd_request_groups frg
		  join fnd_request_group_units frgu on frg.application_id = frgu.application_id and frg.request_group_id = frgu.request_group_id
		  join fnd_application_tl fat1 on frg.application_id = fat1.application_id
		  join fnd_application_tl fat2 on frgu.unit_application_id = fat2.application_id
		 where 1 = 1
		   and frg.request_group_name = 'XX Payables Super User Request Group'
		   and 1 = 1
		 minus
		select case when frgu.request_unit_type = 'P' then
						(select fcp.user_concurrent_program_name from fnd_concurrent_programs_tl fcp where fcp.concurrent_program_id = frgu.request_unit_id and fcp.application_id = fat2.application_id)
					when frgu.request_unit_type = 'S' then
						(select frst.user_request_set_name from fnd_request_sets_tl frst where frst.request_set_id = frgu.request_unit_id and frst.application_id = fat2.application_id)
					when frgu.request_unit_type = 'A' then
						(select fat.application_name from fnd_application_tl fat where fat.application_id = frgu.request_unit_id)
			   end name
			 , decode(frgu.request_unit_type, 'P', 'Program', 'S', 'Request Set', 'A', 'Application') type
			 , case when frgu.request_unit_type = 'P' then
						(select fcp.creation_date from fnd_concurrent_programs_tl fcp where fcp.concurrent_program_id = frgu.request_unit_id and fcp.application_id = fat2.application_id)
			   end job_created
			 , case when frgu.request_unit_type = 'P' then
						(select fcp.last_update_date from fnd_concurrent_programs_tl fcp where fcp.concurrent_program_id = frgu.request_unit_id and fcp.application_id = fat2.application_id)
			   end job_updated
			 , case when frgu.request_unit_type = 'P' then
						(select fcpt.enabled_flag from fnd_concurrent_programs fcpt where fcpt.concurrent_program_id = frgu.request_unit_id and fcpt.application_id = fat2.application_id)
			   end job_enabled
			 , case when frgu.request_unit_type = 'P' then
						(select fcpt.concurrent_program_id from fnd_concurrent_programs fcpt where fcpt.concurrent_program_id = frgu.request_unit_id and fcpt.application_id = fat2.application_id)
			   end job_id
			 , case when frgu.request_unit_type = 'S' then
						(select frs.end_date_active from fnd_request_sets frs where frs.request_set_id = frgu.request_unit_id and frs.application_id = fat2.application_id)
			   end request_set_end_date
			 , case when frgu.request_unit_type = 'S' then
						(select frs.request_set_id from fnd_request_sets frs where frs.request_set_id = frgu.request_unit_id and frs.application_id = fat2.application_id)
			   end request_set_id
			 , fat2.application_name application
		  from fnd_request_groups frg
		  join fnd_request_group_units frgu on frg.application_id = frgu.application_id and frg.request_group_id = frgu.request_group_id
		  join fnd_application_tl fat1 on frg.application_id = fat1.application_id
		  join fnd_application_tl fat2 on frgu.unit_application_id = fat2.application_id
		 where 1 = 1
		   and frg.request_group_name = 'XX Payables Manager Request Group'
		   and 1 = 1;
