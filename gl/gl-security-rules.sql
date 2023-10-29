/*
File Name:		gl-security-rules.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- RESP PLUS RULE BASICS
-- RULES ONLY
-- RESP PLUS RULE NAME ONLY
-- COUNT PER RESPONSIBILITY

*/

-- ##################################################################
-- RESP PLUS RULE BASICS
-- ##################################################################

		select rtl.responsibility_name
			 , fvr.flex_value_rule_name rule
			 , ffvs.flex_value_set_name segment
		  from applsys.fnd_flex_value_rules fvr
			 , applsys.fnd_flex_value_rules_tl fvrtl
			 , applsys.fnd_flex_value_rule_usages fvru
			 , applsys.fnd_responsibility_tl rtl
			 , applsys.fnd_responsibility fr
			 , applsys.fnd_application_tl fatl
			 , applsys.fnd_flex_value_sets ffvs
		 where fvr.flex_value_rule_id = fvrtl.flex_value_rule_id
		   and fvrtl.flex_value_rule_id = fvru.flex_value_rule_id
		   and fvru.responsibility_id = rtl.responsibility_id
		   and fatl.application_id = rtl.application_id
		   and rtl.responsibility_id = fr.responsibility_id
		   and ffvs.flex_value_set_id = fvru.flex_value_set_id
		   -- and rtl.responsibility_name = 'Capital Request (XX FORM)'
		   -- and rtl.responsibility_name like '%XX FORM%'
		   and ffvs.zd_edition_name = 'SET2' -- 12.2 (set1 = 12.1)
		   and fvr.flex_value_rule_name like 'D%'
	  order by rtl.responsibility_name;

-- ##################################################################
-- RULES ONLY
-- ##################################################################

		select fvr.flex_value_rule_name rule
			 , fvrtl.error_message
			 , decode(ffvrl.include_exclude_indicator,'E','Exclude','I','Include') inc_exc
			 , ffvrl.flex_value_low
			 , ffvrl.flex_value_high
			 , ffvrl.creation_date
			 , fu.user_name
		  from applsys.fnd_flex_value_rules fvr
			 , applsys.fnd_flex_value_rules_tl fvrtl
			 , applsys.fnd_flex_value_rule_lines ffvrl
			 , applsys.fnd_flex_value_sets ffvs
			 , applsys.fnd_user fu
		 where fvr.flex_value_rule_id = fvrtl.flex_value_rule_id
		   and ffvrl.flex_value_rule_id = fvrtl.flex_value_rule_id
		   and ffvs.flex_value_set_id = ffvrl.flex_value_set_id
		   and ffvrl.last_updated_by = fu.user_id
		   -- and ffvrl.flex_value_high = '1234'
		   -- and ffvrl.creation_date > '23-NOV-2018'
		   -- and fvrtl.error_message like '%Only%balance%'
		   and fvr.flex_value_rule_name like 'D%'
		   and ffvs.zd_edition_name = 'SET2' -- 12.2 (set1 = 12.1)
		   and 1 = 1;

-- ##################################################################
-- RESP PLUS RULE NAME ONLY
-- ##################################################################

		select distinct rtl.responsibility_name
			 , fvr.flex_value_rule_name rule
		  from applsys.fnd_flex_value_rules fvr
			 , applsys.fnd_flex_value_rules_tl fvrtl
			 , applsys.fnd_flex_value_rule_usages fvru
			 , applsys.fnd_responsibility_tl rtl
			 , applsys.fnd_responsibility fr
			 , applsys.fnd_application_tl fatl
			 , applsys.fnd_flex_value_rule_lines ffvrl
			 , applsys.fnd_flex_value_sets ffvs
		 where fvr.flex_value_rule_id = fvrtl.flex_value_rule_id
		   and fvrtl.flex_value_rule_id = fvru.flex_value_rule_id
		   and fvru.responsibility_id = rtl.responsibility_id
		   and fatl.application_id = rtl.application_id
		   and ffvrl.flex_value_rule_id = fvrtl.flex_value_rule_id
		   and ffvs.flex_value_set_id = ffvrl.flex_value_set_id
		   and rtl.responsibility_id = fr.responsibility_id
		   -- and rtl.responsibility_name like 'PO Internet%'
		   and fvr.flex_value_rule_name like 'D%'
		   -- and ffvs.zd_edition_name = 'SET2' -- 12.2 (set1 = 12.1)
		   -- and rtl.responsibility_name = 'No Cheese Rule'
	  order by rtl.responsibility_name
			 , fvr.flex_value_rule_name;


-- ##################################################################
-- COUNT PER RESPONSIBILITY
-- ##################################################################

		select rtl.responsibility_name
			 , count (*) ct
		  from applsys.fnd_flex_value_rules fvr
			 , applsys.fnd_flex_value_rules_tl fvrtl
			 , applsys.fnd_flex_value_rule_usages fvru
			 , applsys.fnd_responsibility_tl rtl
			 , applsys.fnd_responsibility fr
			 , applsys.fnd_application_tl fatl
			 , applsys.fnd_flex_value_rule_lines ffvrl
			 , applsys.fnd_flex_value_sets ffvs
		 where fvr.flex_value_rule_id = fvrtl.flex_value_rule_id
		   and fvrtl.flex_value_rule_id = fvru.flex_value_rule_id
		   and fvru.responsibility_id = rtl.responsibility_id
		   and fatl.application_id = rtl.application_id
		   and ffvrl.flex_value_rule_id = fvrtl.flex_value_rule_id
		   and ffvs.flex_value_set_id = ffvrl.flex_value_set_id
		   and rtl.responsibility_id = fr.responsibility_id
		   and rtl.responsibility_name like 'GL%'
	  group by rtl.responsibility_name
	  order by rtl.responsibility_name;
