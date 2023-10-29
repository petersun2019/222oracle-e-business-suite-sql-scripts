/*
File Name: gl-hierarchy.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- TABLE DUMPS
-- HIERARCHY 1
-- HIERARCHY 2
-- HIERARCHY 3

*/

-- ##################################################################
-- TABLE DUMPS
-- ##################################################################

select * from applsys.fnd_flex_value_norm_hierarchy hier;
select * from applsys.fnd_flex_value_norm_hierarchy hier where flex_value_set_id = 123456;
select * from applsys.fnd_flex_value_norm_hierarchy hier where flex_value_set_id = 123456 and '10030' between child_flex_value_low and child_flex_value_high;
select * from applsys.fnd_flex_value_norm_hierarchy hier where parent_flex_value = '704xx';
select flex_value,description,summary_flag,flex_value_set_id,parent_flex_value from fnd_flex_value_children_v where (flex_value_set_id = 123456) and (parent_flex_value='XXAAA') order by flex_value;
select * from applsys.fnd_flex_value_norm_hierarchy;
select * from applsys.fnd_flex_values fnd_value where flex_value = '10030';
select * from applsys.fnd_flex_values_tl fnd_value_tl;
select * from fnd_flex_value_norm_hierarchy where last_update_date > '10-JUN-2019' order by last_update_date desc;

-- ##################################################################
-- HIERARCHY 1
-- ##################################################################

			select ffvnm.parent_flex_value "NOMINAL - PARENT"
			 , ffvnm.child_flex_value_low "CHILD - LOW"
			 , ffvnm.child_flex_value_high "CHILD - HIGH"
			 , ffvnm.last_update_date "ADDED TO DEV"
			 , fu.user_name "ADDED TO DEV BY"
			 , '#################'
			 , fnd_value.*
		  from applsys.fnd_flex_value_norm_hierarchy ffvnm
		  join applsys.fnd_user fu on ffvnm.last_updated_by = fu.user_id
		  join fnd_flex_values fnd_value on fnd_value.flex_value = ffvnm.parent_flex_value and ffvnm.flex_value_set_id = fnd_value.flex_value_set_id 
		 where 1 = 1
		   -- and ffvnm.creation_date > '01-JAN-2010'
		   -- and ffvnm.child_flex_value_low like 'S%'
		   and '704xx' between ffvnm.child_flex_value_low and ffvnm.child_flex_value_high
		   -- and substr(ffvnm.parent_flex_value, 0, 1) not in ('3', '5')
		   and 1 = 1;

-- ##################################################################
-- HIERARCHY 2
-- ##################################################################

/*
This SQL can be used to find the FLEX_VALUE_SET_ID for the Chart of Accounts Value Set whose hierarchy you want to check.
Once you have the ID you can enter it into the "where hier.flex_value_set_id = " part of the SQL below:

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
		   -- and fnd_set.flex_value_set_id = 123456
		   -- and fifsv.id_flex_structure_code like 'XX_CUST%'
		   -- and fif.id_flex_code = 'MSTK'
		   and 1 = 1;

*/

		select level "level"
			-- PARENT
			 , lpad(' ', 10 * (level-1)) || hier.parent_flex_value parent
			 , fnd_value_tl_parent.description parent_desc
			 , fnd_value_parent.end_date_active parent_end_date
			 , fnd_value_parent.enabled_flag parent_enabled
			 , substr(replace(replace(fnd_value_parent.compiled_value_attributes,chr(10),''),chr(13),' '),1,1) parent_budg_flag
			 , substr(replace(replace(fnd_value_parent.compiled_value_attributes,chr(10),''),chr(13),' '),2,1) parent_post_flag
			-- CHILD_LOW
			 , hier.child_flex_value_low child_low
			 , fnd_value_tl_cl.description cl_desc
			 , fnd_value_cl.end_date_active cl_end_date
			 , fnd_value_cl.enabled_flag cl_enabled
			 , substr(replace(replace(fnd_value_cl.compiled_value_attributes,chr(10),''),chr(13),' '),1,1) cl_budg_flag
			 , substr(replace(replace(fnd_value_cl.compiled_value_attributes,chr(10),''),chr(13),' '),2,1) cl_post_flag
			-- CHILD_HIGH
			 , hier.child_flex_value_high child_high
			 , fnd_value_tl_cl.description ch_desc
			 , fnd_value_ch.end_date_active ch_end_date
			 , fnd_value_ch.enabled_flag ch_enabled
			 , substr(replace(replace(fnd_value_ch.compiled_value_attributes,chr(10),''),chr(13),' '),1,1) ch_budg_flag
			 , substr(replace(replace(fnd_value_ch.compiled_value_attributes,chr(10),''),chr(13),' '),2,1) ch_post_flag
		  from applsys.fnd_flex_value_norm_hierarchy hier
			-- PARENT
		  join applsys.fnd_flex_values fnd_value_parent on fnd_value_parent.flex_value = hier.parent_flex_value
		  join applsys.fnd_flex_values_tl fnd_value_tl_parent on fnd_value_tl_parent.flex_value_id = fnd_value_parent.flex_value_id
			-- CHILD_LOW
		  join applsys.fnd_flex_values fnd_value_cl on fnd_value_cl.flex_value = hier.child_flex_value_low
		  join applsys.fnd_flex_values_tl fnd_value_tl_cl on fnd_value_tl_cl.flex_value_id = fnd_value_cl.flex_value_id
			-- CHILD_HIGH
		  join applsys.fnd_flex_values fnd_value_ch on fnd_value_ch.flex_value = hier.child_flex_value_low
		  join applsys.fnd_flex_values_tl fnd_value_tl_ch on fnd_value_tl_ch.flex_value_id = fnd_value_ch.flex_value_id 
		 where hier.flex_value_set_id = 123456 -- ID FOR CHART OF ACCOUNTS SEGMENT WHOSE HIERARCHY YOU WANT TO CHECK
		   -- and hier.end_date_active is null
	connect by nocycle prior hier.child_flex_value_low = hier.parent_flex_value
	start with hier.parent_flex_value = '704xx';

-- ##################################################################
-- HIERARCHY 3
-- ##################################################################
		
		select ffvnm.parent_flex_value
			 , ffvnm.child_flex_value_low
			 , ffvnm.child_flex_value_high
			 , ffvnm.last_update_date
			 , fu.user_name last_updated_by
		  from applsys.fnd_flex_value_norm_hierarchy ffvnm
		  join applsys.fnd_user fu on ffvnm.last_updated_by = fu.user_id
		 where 1 = 1
		   and '11401' between ffvnm.child_flex_value_low and ffvnm.child_flex_value_high
		   -- and ffvnm.last_update_date > '01-JAN-2016'
		   -- and substr(ffvnm.parent_flex_value, 0, 1) not in ('3', '5')
		   and 1 = 1;
