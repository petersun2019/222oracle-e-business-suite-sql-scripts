/*
File Name:		gl-chart-of-accounts.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- GL CHART OF ACCOUNTS - HEADER
-- GL CHART OF ACCOUNTS - SEGMENTS SUMMARY

*/

-- ##################################################################
-- GL CHART OF ACCOUNTS - HEADER
-- ##################################################################

		select gl.ledger_id
			 , gl.name ledger_name
			 , gl.short_name ledger_short_name
			 , gl.description ledger_descripption
			 , fifsv.id_flex_num
			 , fifsv.id_flex_structure_code code
			 , fifsv.id_flex_structure_name title
			 , fifsv.description
			 , fifsv.structure_view_name view_name
			 , fifsv.concatenated_segment_delimiter segment_separator
			 , fifsv.freeze_flex_definition_flag freeze_flexfield_definition
			 , fifsv.cross_segment_validation_flag cross_validate_segments
			 , fifsv.enabled_flag enabled
			 , fifsv.freeze_structured_hier_flag freeze_rollup_groups
			 , fifsv.last_update_date
		  from apps.fnd_id_flex_structures_vl fifsv
	 left join gl.gl_ledgers gl on gl.chart_of_accounts_id = fifsv.id_flex_num
		 where id_flex_code = 'GL#';

-- ##################################################################
-- GL CHART OF ACCOUNTS - SEGMENTS SUMMARY
-- ##################################################################

		select fifsv.segment_num "NUMBER"
			 , fifsv.segment_name name
			 , fifsv.form_left_prompt prompt
			 , fifsv.application_column_name 
			 , fnd_set.flex_value_set_name
			 , fifsv.display_flag displayed
			 , fifsv.enabled_flag enabled
		  from apps.fnd_id_flex_segments_vl fifsv
	 left join applsys.fnd_flex_value_sets fnd_set on fifsv.flex_value_set_id = fnd_set.flex_value_set_id
		 where 1 = 1
		   -- and fifsv.id_flex_num = 50268
		   and fifsv.id_flex_code = 'GL#'
		   and fifsv.application_id = 101
		   and 1 = 1
	  order by fifsv.segment_num;
