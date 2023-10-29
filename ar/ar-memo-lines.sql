/*
File Name:		ar-memo-lines.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- AR MEMO LINES - DETAILS
-- AR MEMO LINES - COUNTING

*/

-- ##################################################################
-- AR MEMO LINES - DETAILS
-- ##################################################################

		select amlat.name
			 , amlat.creation_date
			 , amlat.last_update_date
			 , amlab.org_id
			 , hou.short_code org
			 , gcc.concatenated_segments income_code
			 , tbl_gl.flex_value dept
			 , tbl_gl.description dept_name
			 -- , '###############'
			 -- , amlab.*
		  from ar_memo_lines_all_tl amlat
		  join ar_memo_lines_all_b amlab on amlat.memo_line_id = amlab.memo_line_id
		  join gl_code_combinations_kfv gcc on amlab.gl_id_rev = gcc.code_combination_id
		  join hr_operating_units hou on hou.organization_id = amlab.org_id
	 left join (select fnd_value.flex_value
					 , fnd_value_tl.description
				  from fnd_flex_values fnd_value
				  join fnd_flex_value_sets fnd_set on fnd_value.flex_value_set_id = fnd_set.flex_value_set_id
				  join fnd_flex_values_tl fnd_value_tl on fnd_value.flex_value_id = fnd_value_tl.flex_value_id
				 where fnd_set.flex_value_set_name = 'XX_DEPARTMENT'
				   and fnd_value.enabled_flag = 'Y') tbl_gl on gcc.segment4 = tbl_gl.flex_value
		 where 1 = 1
		   -- and amlab.end_date is null
		   -- and gcc.segment4 = '1234'
		   and amlat.name = 'XX_MEMO_LINE_1'
		   and 1 = 1;

-- ##################################################################
-- AR MEMO LINES - COUNTING
-- ##################################################################

		select tbl_gl.flex_value dept
			 , tbl_gl.description dept_name
			 , count(*)
		  from ar_memo_lines_all_tl amlat
		  join ar_memo_lines_all_b amlab on amlat.memo_line_id = amlab.memo_line_id
		  join gl_code_combinations_kfv gcc on amlab.gl_id_rev = gcc.code_combination_id
		  join hr_operating_units hou on hou.organization_id = amlab.org_id
	 left join (select fnd_value.flex_value
					 , fnd_value_tl.description
				  from fnd_flex_values fnd_value
				  join fnd_flex_value_sets fnd_set on fnd_value.flex_value_set_id = fnd_set.flex_value_set_id
				  join fnd_flex_values_tl fnd_value_tl on fnd_value.flex_value_id = fnd_value_tl.flex_value_id
				 where fnd_set.flex_value_set_name = 'XX_DEPARTMENT'
				   and fnd_value.enabled_flag = 'Y') tbl_gl on gcc.segment4 = tbl_gl.flex_value
		 where 1 = 1
		   and 1 = 1
	  group by tbl_gl.flex_value
			 , tbl_gl.description
	  order by 2;
