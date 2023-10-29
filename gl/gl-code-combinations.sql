/*
File Name: gl-code-combinations.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- GL CODE COMBINATIONS
-- COUNTING
-- COUNT DISTINCT VALUES PER SEGMENT
-- CODE COMBINATIONS - SEGMENT DESCRIPTIONS 1
-- CODE COMBINATIONS - SEGMENT DESCRIPTIONS 2

*/

-- ##################################################################
-- GL CODE COMBINATIONS
-- ##################################################################

		select gcc.code_combination_id ccid
			 , gcck.concatenated_segments chg_acct
			 , decode(gcc.account_type, 'R', 'Revenue', 'E', 'Expense', 'A', 'Asset', 'L', 'Liability', 'O', 'Owners'' equity') acct_type
			 , gcc.last_update_date
			 , gcc.start_date_active
			 , gcc.end_date_active
			 , fu.description updated_by
			 , gcc.enabled_flag active
			 , gcc.detail_posting_allowed_flag post
			 , gcc.detail_budgeting_allowed_flag bdgt
			 , gcc.summary_flag
			 , fu.user_name
		  from gl_code_combinations gcc
			 , gl_code_combinations_kfv gcck
			 , fnd_user fu
		 where gcc.last_updated_by = fu.user_id
		   and gcc.code_combination_id = gcck.code_combination_id
		   and gcck.code_combination_id in (123456)
		   -- and gcck.concatenated_segments = '01.AAA.BBBB.CCCC.DDDD.EEEE.FFFF.GGGG'
		   -- and gcc.segment1 in ('01')
		   -- and gcc.segment2 in ('AAA')
		   -- and gcc.segment3 in ('BBBB')
		   -- and gcc.segment4 in ('CCCC')
		   -- and gcc.segment5 in ('DDDD')
		   -- and gcc.segment6 in ('EEEE')
		   -- and gcc.segment7 in ('FFFF')
		   -- and gcc.segment8 in ('GGGG')
		   -- and fu.user_name = 'SYSADMIN'
		   -- and gcc.last_update_date > '26-JUL-2021'
	  order by gcc.last_update_date desc;

		select fu.description
			 , gcc.*
		  from gl.gl_code_combinations gcc
		  join applsys.fnd_user fu on gcc.last_updated_by = fu.user_id
		 where gcc.segment1 in ('R105143')
		   and gcc.segment2 in ('4150', '4337');

-- ##################################################################
-- COUNTING
-- ##################################################################

-- COUNT DISTINCT VALUES PER SEGMENT

		select count(distinct segment1) seg1
			 , count(distinct segment2) seg2
			 , count(distinct segment3) seg3
			 , count(distinct segment4) seg4
			 , count(distinct segment5) seg5
			 , count(distinct segment6) seg6
			 , count(distinct segment7) seg7
			 , count(distinct segment8) seg8
		  from gl_code_combinations;

-- ##################################################################
-- CODE COMBINATIONS - SEGMENT DESCRIPTIONS 1
-- ##################################################################

		select gcc.concatenated_segments code_combination
			 , gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id,1,gcc.segment1) || ' / ' ||
			   gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id,2,gcc.segment2) || ' / ' ||
			   gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id,3,gcc.segment3) || ' / ' ||
			   gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id,4,gcc.segment4) || ' / ' ||
			   gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id,5,gcc.segment5) || ' / ' ||
			   gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id,6,gcc.segment6) || ' / ' ||
			   gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id,7,gcc.segment7) || ' / ' ||
			   gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id,8,gcc.segment8) descr
		  from gl_code_combinations_kfv gcc
		 where gcc.concatenated_segments = '01.AAA.BBBB.CCCC.DDDD.EEEE.FFFF.GGGG'

-- ##################################################################
-- CODE COMBINATIONS - SEGMENT DESCRIPTIONS 2
-- ##################################################################

/*
HTTP://ORACLEAPPSTECHGUIDE.BLOGSPOT.COM/2017/11/QUERY-TO-GET-GL-CODE-COMBINATIONS.HTML
*/

		select gcc.concatenated_segments code_combination
			 , '#' || gcc.segment1 segment1
			 , gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id, 1, gcc.segment1) segment1_desc
			 , '#' || gcc.segment2 segment2
			 , gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id, 2, gcc.segment2) segment2_desc
			 , '#' || gcc.segment3 segment3
			 , gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id, 3, gcc.segment3) segment3_desc
			 , '#' || gcc.segment4 segment4
			 , gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id, 4, gcc.segment4) segment4_desc
			 , '#' || gcc.segment5 segment5
			 , gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id, 5, gcc.segment5) segment5_desc
			 , '#' || gcc.segment6 segment6
			 , gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id, 6, gcc.segment6) segment6_desc
			 , '#' || gcc.segment7 segment7
			 , gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id, 7, gcc.segment7) segment7_desc
			 , '#' || gcc.segment8 segment8
			 , gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id, 8, gcc.segment8) segment8_desc
		  from gl_code_combinations_kfv gcc
		 where gcc.concatenated_segments = '01.AAA.BBBB.CCCC.DDDD.EEEE.FFFF.GGGG';
