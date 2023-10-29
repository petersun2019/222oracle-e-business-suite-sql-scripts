/*
File Name:		gl-segment-values.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- BASIC COA SEGMENT VALUES AND DESCRIPTIONS
-- BASIC CODES AND DESCRIPTIONS
-- COUNT OF CODES PER ACCOUNTING FLEXFIELD
-- BASIC COUNT PER FLEX_VALUE_SET_NAME

*/

-- ##################################################################
-- BASIC COA SEGMENT VALUES AND DESCRIPTIONS
-- ##################################################################

/*
SETUP > FINANCIALS > FLEXFIELDS > KEY > VALUES

To use this query you need to know the name of the List of Values set up agaist the each of the Chart of Accounts (COA) Segments

Then you can include them in your query - e.g. one of these:

and fnd_set.flex_value_set_name = 'XXCUST_GL_DEPARTMENT'
and fnd_set.flex_value_set_name in ('XXCUST_GL_ACCOUNT','XXCUST_GL_DEPARTMENT','XXCUST_GL_COST_CENTRE','XXCUST_GL_ACTIVITY')

You can use this SQL to see the Chart of Accounts Segments definitions if you don't know them:

		select '------> KEY FLEXFIELD'
			 , fat.application_name
			 , fif.id_flex_name flexfield_title
			 , fif.id_flex_code
			 , '------> STRUCTURE'
			 , fifsv.id_flex_structure_code segment_code
			 , fifsv.id_flex_structure_name segment_title
			 , '------> SEGMENTS'
			 , fnd_set.flex_value_set_id
			 , fifsvl.id_flex_num
			 , fifsvl.segment_num "number"
			 , fifsvl.segment_name name
			 , fifsvl.form_left_prompt prompt
			 , fifsvl.description
			 , fifsvl.application_column_name 
			 , fnd_set.flex_value_set_name
			 , fifsvl.display_flag displayed
			 , fifsvl.enabled_flag enabled
			 , fifsvl.display_size
			 , '#' || fifsvl.default_value default_value
		  from fnd_id_flexs fif
		  join fnd_application_tl fat on fif.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_id_flex_structures_vl fifsv on fif.id_flex_code = fifsv.id_flex_code
		  join fnd_id_flex_segments_vl fifsvl on fifsvl.id_flex_code = fifsv.id_flex_code and fifsvl.id_flex_num = fifsv.id_flex_num
	 left join fnd_flex_value_sets fnd_set on fifsvl.flex_value_set_id = fnd_set.flex_value_set_id
		 where 1 = 1
		   and fif.id_flex_code = 'GL#'
		   and 1 = 1;

*/

		select '#' || fnd_value.flex_value flex_value
			 , '#' || fnd_value_tl.flex_value_meaning
			 , (select count(*) from gl_code_combinations where segment2 = fnd_value.flex_value) cc_count
			 , fnd_set.flex_value_set_name
			 , fnd_value_tl.description
			 , fnd_value.enabled_flag
			 , decode(substr(replace(fnd_value.compiled_value_attributes, chr(10), ''),1,1),'Y', 'Yes', 'No') allow_budgeting
			 , decode(substr(replace(fnd_value.compiled_value_attributes, chr(10), ''),2,1),'Y', 'Yes', 'No') allow_posting
			 , decode(substr(replace(fnd_value.compiled_value_attributes, chr(10), ''),3,1),'A', 'Asset', 'E', 'Expense', 'L', 'Liability', 'O', 'Ownership/Stockholders Equity', 'R', 'Revenue', 'Other') account_type
			 , decode(substr(replace(fnd_value.compiled_value_attributes, chr(10), ''),4,1),'Y', 'Yes', 'No') reconcile
			 , decode(substr(replace(fnd_value.compiled_value_attributes, chr(10), ''),5,1),'Y', 'Yes', 'No') third_party
			 -- , '###########'
			 -- , replace(fnd_value.compiled_value_attributes, chr(10), '') compiled_value_attributes
			 , fnd_value.creation_date created
			 , fnd_value.last_update_date updated
			 , fnd_value.end_date_active
			 , fu.user_name created_by
			 , fu.email_address created_by_email
			 , fu2.user_name updated_by
			 , fu2.email_address updated_by_email
			 , fnd_set.flex_value_set_id
			 , fnd_value.value_category
		  from fnd_flex_values fnd_value
	 left join fnd_flex_value_sets fnd_set on fnd_value.flex_value_set_id = fnd_set.flex_value_set_id
		  join fnd_flex_values_tl fnd_value_tl on fnd_value.flex_value_id = fnd_value_tl.flex_value_id and fnd_value_tl.language = userenv('lang')
		  join fnd_user fu on fnd_value.created_by = fu.user_id
		  join fnd_user fu2 on fnd_value.last_updated_by = fu2.user_id 
		 where 1 = 1 
		   -- SEGMENT DEFINITIONS:
		   and fnd_set.flex_value_set_name = 'XXCUST_GL_DEPARTMENT'
		   -- and fnd_set.flex_value_set_name in ('XXCUST_GL_ACCOUNT','XXCUST_GL_DEPARTMENT','XXCUST_GL_COST_CENTRE','XXCUST_GL_ACTIVITY')
		   -- and fnd_set.flex_value_set_id = 123456
		   -- and fnd_set.flex_value_set_id in (1007944)
		   -- and fnd_set.flex_value_set_name = 'XX Cost Centre Code'
		   -- SEGMENT VALUE SEARCHING:
		   and fnd_value.flex_value = '00001'
		   -- and fnd_value_tl.description like '%CONSULTANCY%'
		   -- and fu.user_name = 'SYSADMIN'
		   -- and fnd_value.flex_value like '%21%'
		   -- and lower(fnd_value_tl.description) like '%accrual%'
		   -- and length(fnd_value.flex_value) = 7
		   -- and fnd_value_tl.description like '%CHEESE%'
		   -- and fnd_value.creation_date > '27-SEP-2009' and fnd_value.creation_date < '01-OCT-2009'
		   -- and fnd_value.creation_date > '01-DEC-2018' and fnd_value.creation_date < '01-JAN-2019'
		   -- and fnd_value.last_update_date > '01-JUN-2021'
		   and 1 = 1
	  order by fnd_value.creation_date desc;

-- ##################################################################
-- BASIC CODES AND DESCRIPTIONS
-- ##################################################################

		select fnd_set.flex_value_set_name
			 , fnd_value.flex_value value
			 , fnd_value.end_date_active
			 , fnd_value_tl.description
			 , fnd_value.enabled_flag
			 , fnd_value.summary_flag parent 
			 , substr(replace(replace(fnd_value.compiled_value_attributes,chr(10),''),chr(13),' '),1,1) budg_flag
			 , substr(replace(replace(fnd_value.compiled_value_attributes,chr(10),''),chr(13),' '),2,1) post_flag
			 -- , (select count(*) from apps.fnd_flex_value_children_v ffvcv where ffvcv.flex_value = fnd_value.flex_value) child_count
			 , fnd_value.creation_date
			 , fu2.description created_by
			 , fnd_value.last_update_date
			 , fu2.description updated_by
			 , '############'
			 , fnd_value.attribute18
			 , fnd_value.attribute19
			 , fnd_value.attribute26
			 , fnd_value.attribute27
			 , fnd_value.attribute28
			 , fnd_value.attribute29
			 , fnd_value.attribute30
			 , fnd_value.attribute31
			 , fnd_value.attribute32
			 , fnd_value.attribute33
			 , fnd_value.attribute34
			 , fnd_value.attribute35
			 , fnd_value.attribute36
			 , fnd_value.attribute37
			 , fnd_value.attribute38
			 , fnd_value.attribute39
			 , fnd_value.attribute40
			 , fnd_value.attribute41
			 , fnd_value.attribute42
			 , fnd_value.attribute43
			 , fnd_value.attribute44
		  from applsys.fnd_flex_values fnd_value 
		  join applsys.fnd_flex_value_sets fnd_set on fnd_value.flex_value_set_id = fnd_set.flex_value_set_id
		  join applsys.fnd_flex_values_tl fnd_value_tl on fnd_value.flex_value_id = fnd_value_tl.flex_value_id
		  join applsys.fnd_user fu on fnd_value.last_updated_by = fu.user_id
		  join applsys.fnd_user fu2 on fnd_value.created_by = fu2.user_id
		 where 1 = 1
		   and fnd_value.flex_value in ('00001')
		   -- and fnd_set.flex_value_set_name = 'XXCUST_GL_ACCOUNT'
		   -- and fnd_value.attribute29 like 'Blue%Cheese%'
		   -- and fnd_value.attribute26 > 0
		   -- and fnd_value.enabled_flag = 'Y'
		   -- and fnd_value.creation_date >= '01-NOV-2015'
		   -- and fnd_value.last_update_date > '19-MAY-2016'
		   -- and fnd_value.last_update_date > '08-JAN-2016'
		   -- and fnd_value_tl.description = 'A:CZZ Core'
		   -- and fnd_value.attribute38 is not null
		   -- and fnd_value_tl.description like '%~%'
		   -- and fnd_value.last_update_date between '17-DEC-2013' and '20-DEC-2013'
		   -- and fnd_value.last_update_date between to_date('17-DEC-2013 17:00:00', 'DD-MON-YYYY HH24:MI:SS') and to_date('18-DEC-2013 17:00:00', 'DD-MON-YYYY HH24:MI:SS')
	  order by fnd_value.last_update_date;

-- ##################################################################
-- COUNT OF CODES PER ACCOUNTING FLEXFIELD
-- ##################################################################

		select fat.application_name
			 , fif.id_flex_name flexfield_title
			 , fifsv.id_flex_structure_code segment_code
			 , fifsv.id_flex_structure_name segment_title
			 , fifsvl.segment_num "number"
			 , fifsvl.segment_name name
			 , fifsvl.application_column_name 
			 , fnd_set.flex_value_set_name
			 , fifsvl.display_flag displayed
			 , fifsvl.enabled_flag enabled
			 , fifsvl.display_size segment_length
			 , count(*) ct
		  from applsys.fnd_id_flexs fif
		  join applsys.fnd_application_tl fat on fif.application_id = fat.application_id
		  join apps.fnd_id_flex_structures_vl fifsv on fif.id_flex_code = fifsv.id_flex_code
		  join apps.fnd_id_flex_segments_vl fifsvl on fifsvl.id_flex_code = fifsv.id_flex_code and fifsvl.id_flex_num = fifsv.id_flex_num
	 left join applsys.fnd_flex_value_sets fnd_set on fifsvl.flex_value_set_id = fnd_set.flex_value_set_id
		  join applsys.fnd_flex_values fnd_value on fnd_value.flex_value_set_id = fnd_set.flex_value_set_id
		 where 1 = 1
		   and fif.id_flex_code = 'GL#'
		   and fifsv.id_flex_structure_name = 'XXCUST_GL_ACCOUNT'
		   and 1 = 1
	  group by fat.application_name
			 , fif.id_flex_name
			 , fifsv.id_flex_structure_code
			 , fifsv.id_flex_structure_name
			 , fifsvl.segment_num
			 , fifsvl.segment_name
			 , fifsvl.application_column_name 
			 , fnd_set.flex_value_set_name
			 , fifsvl.display_flag
			 , fifsvl.enabled_flag
			 , fifsvl.display_size;

-- ##################################################################
-- BASIC COUNT PER FLEX_VALUE_SET_NAME
-- ##################################################################
		select flex_value_set_name
			 , count(*) ct
		  from applsys.fnd_flex_values fnd_value
		  join applsys.fnd_flex_value_sets fnd_set on fnd_value.flex_value_set_id = fnd_set.flex_value_set_id
		  join applsys.fnd_flex_values_tl fnd_value_tl on fnd_value.flex_value_id = fnd_value_tl.flex_value_id
		 where 1 = 1
		   and flex_value_set_name like 'CHEESE%'
	  group by flex_value_set_name
	  order by 2 desc;
