/*
File Name: xdo-templates.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- XDO TEMPLATES 1
-- XDO TEMPLATES 2
-- XDO TEMPLATES 3

*/

-- ##################################################################
-- XDO TEMPLATES 1
-- ##################################################################

		select b.creation_date
			 , b.created_by
			 , fu.user_name
			 , b.last_update_date updated
			 , l.file_name
			 , l.xdo_file_type
			 , l.file_content_type
			 , l.application_short_name
			 , l.language
			 , t.template_name
			 -- , t.description
			 , b.ds_app_short_name
			 , b.data_source_code
			 , b.template_type_code
			 , b.template_code
			 , l.lob_type l_lob_type
			 , l.xdo_file_type l_xdo_file_type
			 , t.language app_language 
			 , b.last_update_date
		  from xdo_lobs l
			 , xdo_templates_tl t
			 , xdo_templates_b b
			 , fnd_user fu
		 where l.lob_code = t.template_code 
		   and l.application_short_name = t.application_short_name 
		   and t.application_short_name = b.application_short_name 
		   and t.template_code = b.template_code 
		   and b.created_by = fu.user_id
		   -- and fu.user_id not in (1, 2, 121, 120, 0)
		   -- and (b.end_date is null or b.end_date > sysdate)
		   -- and l.application_short_name = 'sqlgl'
		   -- and t.template_name like '%fsg%'
		   and 1 = 1;

-- ##################################################################
-- XDO TEMPLATES 2
-- ##################################################################

		select * 
		  from xdo_templates_vl
		 where 1 = 1
			   and application_short_name = 'IBY'
			   and data_source_code = 'IBY_FD_INSTRUCTION_1_0'
			   and lower(template_name) like 'XX%VAT%'
			   and lower(template_name) like '%BAC%'
			   and template_name in ('Swift MT 103 Format','Barclays .NET UK Payment Format','UK BACS 1/2 Inch Tape Format')
			   and upper(template_type_code) = 'ETEXT'
			   and upper(default_output_type) = 'ETEXT'
		   and 1 = 1;

-- ##################################################################
-- XDO TEMPLATES 3
-- ##################################################################

		select xtb.*
			 , '#####################'
			 , xtv.*
		  from xdo_templates_b xtb
		  join xdo_templates_vl xtv on xtv.template_id = xtb.template_id
		 where 1 = 1
		   and template_name in ('Swift MT 103 Format','Barclays .NET UK Payment Format','UK BACS 1/2 Inch Tape Format')
		   and 1 = 1;
