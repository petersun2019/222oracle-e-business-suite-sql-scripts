/*
File Name:		gl-cross-validation-rules.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- CROSS VALIDATION RULES HEADERS
-- CROSS VALIDATION RULES LINES

*/

-- ##################################################################
-- CROSS VALIDATION RULES HEADERS
-- ##################################################################

		select ffvrv.flex_validation_rule_name rule_name
			 , ffvrv.enabled_flag enabled
			 , ffvrv.creation_date created
			 , cr_by.user_name created_by
			 , ffvrv.last_update_date updated
			 , up_by.user_name updated_by
			 , ffvrv.error_segment_column_name
			 , ffvrv.error_segment_column_name
			 , ffvrv.error_message_text error_message
			 , ffvrv.description
		  from apps.fnd_flex_vdation_rules_vl ffvrv
			 , applsys.fnd_user cr_by
			 , applsys.fnd_user up_by
		 where ffvrv.created_by = cr_by.user_id
		   and ffvrv.last_updated_by = up_by.user_id
		   -- and lower(ffvrv.error_message_text) like '%cost%cent%'
		   -- and ffvrv.error_message_text = 'This Cost Centre cannot be used with this Company'
		   and ffvrv.flex_validation_rule_name = 'XX_CC_0001'
		   -- and cr_by.user_name not in ('AUTOINSTALL', 'INITIAL SETUP', 'SYSADMIN')
		   and 1 = 1;

-- ##################################################################
-- CROSS VALIDATION RULES LINES
-- ##################################################################

		select ffvrv.flex_validation_rule_name rule_name
			 , '#### HEADER DETAILS ####' header_details
			 , ffvrv.enabled_flag enabled
			 , ffvrv.creation_date header_created
			 , cr_by.user_name header_created_by
			 , ffvrv.last_update_date header_updated
			 , up_by.user_name header_updated_by
			 , ffvrv.error_segment_column_name error_segment_basic
			 , ffvrv.error_segment_column_name
			 , ffvrv.error_message_text error_message
			 , ffvrv.description
			 , '#### LINE DETAILS ####' line_details
			 , ffvrl.creation_date line_created
			 , cr_line_by.user_name line_created_by
			 , ffvrl.last_update_date line_updated
			 , up_line_by.user_name line_updated_by
			 , ffvrl.enabled_flag line_enabled
			 , ffvrl.concatenated_segments_low from_
			 , ffvrl.concatenated_segments_high to_
			 , decode (ffvrl.include_exclude_indicator, 'E', 'Exclude', 'I', 'Include') include_exclude
			 , '#########################'
			 , ffvrl.*
		  from apps.fnd_flex_vdation_rules_vl ffvrv
			 , apps.fnd_flex_validation_rule_lines ffvrl
			 , applsys.fnd_user cr_by
			 , applsys.fnd_user up_by
			 , applsys.fnd_user cr_line_by
			 , applsys.fnd_user up_line_by
		 where ffvrv.flex_validation_rule_name = ffvrl.flex_validation_rule_name
		   and ffvrv.created_by = cr_by.user_id
		   and ffvrv.last_updated_by = up_by.user_id
		   and ffvrl.created_by = cr_line_by.user_id
		   and ffvrl.last_updated_by = up_line_by.user_id
		   -- and ffvrv.error_message_text = 'This Cost Centre cannot be used with this Company'
		   -- and ffvrl.include_exclude_indicator = 'E'
		   -- and '01.AAA.BBBB.CCCC.DDDD.EEEE.FFFF.GGGG' between ffvrl.concatenated_segments_low and ffvrl.concatenated_segments_high
		   -- and cr_by.user_name not in ('AUTOINSTALL', 'INITIAL SETUP', 'SYSADMIN')
		   -- and ffvrl.flex_validation_rule_name in ('Rule 00001','Rule 00002')
		   -- and ffvrl.flex_validation_rule_name like '%630%'
		   and ffvrv.flex_validation_rule_name = 'Rule 00006'
		   -- and ffvrl.rule_line_id in (1234,2345)
		   -- and ffvrl.last_update_date > '01-MAY-2019'
	  order by ffvrl.last_update_date desc;
