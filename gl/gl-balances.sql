/*
File Name:		gl-balances.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- GL BALANCES 1
-- GL BALANCES 2
-- GL BALANCES 3
-- GL BALANCES 4
-- TRANSLATION TRACKING
-- R12: SCRIPTS TO CHECK INCONSISTENCIES IN GL_BALANCES (DOC ID 472159.1)

*/

-- ##################################################################
-- GL BALANCES 1
-- ##################################################################

		select gb.currency_code
			 , gb.period_name
			 , glv.name ledger
			 , gps.effective_period_num
			 , sum(gb.begin_balance_dr) begin_dr
			 , sum(gb.begin_balance_cr) begin_cr
			 , sum(gb.period_net_dr) period_dr
			 , sum(gb.period_net_cr) period_cr
			 , '#' || gcc.segment1 segment1
			 , '#' || gcc.segment2 segment2
		  from gl.gl_balances gb
		  join apps.gl_code_combinations_kfv gcc on gb.code_combination_id = gcc.code_combination_id
		  join gl.gl_period_statuses gps on gps.period_name = gb.period_name
		  join apps.gl_ledgers_v glv on gps.ledger_id = glv.ledger_id
		 where 1 = 1
		   and gcc.segment1 = '05500'
		   and gcc.segment2 = '79000'
		   and gps.application_id = 101
		   -- and gps.period_name in ('Jan-22','Feb-22')
		   and gps.effective_period_num between 20190040 and 20200007
		   and 1 = 1
	  group by gb.currency_code
			 , gb.period_name
			 , glv.name
			 , gps.effective_period_num
			 , '#' || gcc.segment1
			 , '#' || gcc.segment2
	  order by gps.effective_period_num desc;

-- ##################################################################
-- GL BALANCES 2
-- ##################################################################

		select min(to_char(gb.last_update_date, 'YYYY-MM-DD')) "BALANCES_CREATED (YYYY-MM)"
			 , count(*)
			 , gb.currency_code
			 , gb.period_name
			 , '#' || gcc.segment1 segment1
		  from gl.gl_balances gb
		  join apps.gl_code_combinations_kfv gcc on gb.code_combination_id = gcc.code_combination_id
		 where 1 = 1
		   and gb.last_update_date >= '27-JAN-2020'
		   -- and gcc.segment1 = 'AABBC'
		   and 1 = 1
	  group by gb.currency_code
			 , gb.period_name
			 , '#' || gcc.segment1
	  order by 1 desc;

-- ##################################################################
-- GL BALANCES 3
-- ##################################################################

		select '#' || gcc.segment1
			 , max(gb.last_update_date)
			 , count(*)
			 , gb.currency_code
			 , gb.period_name
			 , fu.user_name
		  from gl.gl_balances gb
		  join apps.gl_code_combinations_kfv gcc on gb.code_combination_id = gcc.code_combination_id
		  join applsys.fnd_user fu on gb.last_updated_by = fu.user_id
		 where gb.last_update_date > '24-JAN-2020'
	  group by gcc.segment1
			 , gb.currency_code
			 , gb.period_name
			 , fu.user_name;

-- ##################################################################
-- GL BALANCES 4
-- ##################################################################

		select glv.name ledger
			 , gcc.concatenated_segments
			 , fu.user_name
			 , gb.last_update_date
			 , gb.currency_code
			 , gb.period_name period
			 -- , gb.actual_flag
			 , gb.translated_flag translated
			 , gb.begin_balance_dr begin_dr
			 , gb.begin_balance_cr begin_cr
			 , gb.period_net_dr period_dr
			 , gb.period_net_cr period_cr
		  from gl.gl_balances gb
		  join apps.gl_code_combinations_kfv gcc on gb.code_combination_id = gcc.code_combination_id
		  join applsys.fnd_user fu on gb.last_updated_by = fu.user_id
		  join apps.gl_ledgers_v glv on gb.ledger_id = glv.ledger_id
		 where 1 = 1
		   -- and gb.last_update_date > '27-JAN-2020'
		   -- and gcc.segment1 = '05503'
		   and gb.code_combination_id = 123456
		   and gb.period_name = 'JAN-2022'
		   and gb.actual_flag = 'A'
	  order by gb.last_update_date desc;


-- ##################################################################
-- TRANSLATION TRACKING
-- ##################################################################

		select glv.name ledger
			 , glt.target_currency
			 , '#' || glt.bal_seg_value entity
			 , glt.earliest_ever_period_name earliest_period
			 , glt.earliest_never_period_name earliest_never_period
			 , glt.last_update_date
			 , fu.user_name last_updated_by
		  from gl.gl_translation_tracking glt
		  join apps.gl_ledgers_v glv on glt.ledger_id = glv.ledger_id
		  join applsys.fnd_user fu on glt.last_updated_by = fu.user_id
		 where 1 = 1
		   and glt.bal_seg_value = 'AABBC'
		   and glt.actual_flag = 'A'
		   and glt.average_translation_flag = 'N'
		   and glt.target_currency = 'EUR'
		   and glt.ledger_id = 2023
		   and 1 = 1;

-- ##################################################################
-- R12: SCRIPTS TO CHECK INCONSISTENCIES IN GL_BALANCES (DOC ID 472159.1)
-- ##################################################################

-- 1. TOTALS IN GL_BALANCES. 

		select translated_flag
			 , currency_code
			 , sum(begin_balance_dr) begin_dr
			 , sum(begin_balance_cr) begin_cr
			 , sum(period_net_dr) dr
			 , sum(period_net_cr) cr
			 , sum(begin_balance_dr) + sum(period_net_dr) end_dr
			 , sum(begin_balance_cr) + sum(period_net_cr) end_cr
		  from gl.gl_balances
		 where ledger_id = 123456
		   and period_name = 'JAN-2022'
		   and actual_flag = 'A' -- a actual, b budget, e encumbrance
		   and template_id is null
	  group by translated_flag
			 , currency_code;

-- 2. GL_BALANCES VS. GL_BALANCES (BY CCID AND ONE YEAR PERIODS)

		select code_combination_id ccid
			 , currency_code currency
			 , period_name
			 , actual_flag
			 , budget_version_id
			 , encumbrance_type_id
			 , translated_flag
			 , period_year
			 , period_num
			 , begin_balance_dr begin_dr
			 , begin_balance_cr begin_cr
			 , period_net_dr period_dr
			 , period_net_cr period_cr
			 , begin_balance_dr+period_net_dr end_dr
			 , begin_balance_cr+period_net_cr end_cr
			 , begin_balance_dr_beq begin_beq_dr
			 , begin_balance_cr_beq begin_beq_cr
			 , period_net_dr_beq period_beq_dr
			 , period_net_cr_beq period_beq_cr
			 , begin_balance_dr_beq + period_net_dr_beq end_beq_dr
			 , begin_balance_cr_beq + period_net_cr_beq end_beq_cr
		  from gl.gl_balances
		 where ledger_id = 123456
		   and code_combination_id in (123456)
		   and currency_code = 'GBP'
		   and actual_flag = 'A' -- A actual, B budget, E encumbrance
		   and period_year in (2019,2020)
		   and (translated_flag <> 'Y' or translated_flag is null)
	  order by code_combination_id
			 , currency_code
			 , budget_version_id
			 , encumbrance_type_id
			 , translated_flag
			 , period_year
			 , period_num;

-- 3. GL_BALANCES VS GL_BALANCES. (ACTUALS BY PERIOD)

		select a.code_combination_id ccid
			 , a.template_id
			 , a.begin_balance_dr - a.begin_balance_cr + a.period_net_dr - a.period_net_cr end_previous
			 , b.begin_balance_dr - b.begin_balance_cr begin_next
		  from gl.gl_balances a
			 , gl.gl_balances b
		 where a.ledger_id = 123456
		   and a.ledger_id = b.ledger_id
		   and a.code_combination_id = b.code_combination_id
		   and a.actual_flag = b.actual_flag
		   and a.actual_flag = 'A'
		   and nvl(a.encumbrance_type_id,-1) = nvl(b.encumbrance_type_id,-1)
		   and nvl(a.budget_version_id,-1) = nvl(b.budget_version_id,-1)
		   and a.currency_code = b.currency_code
		   and ((a.translated_flag is null and b.translated_flag is null) or (a.translated_flag = 'R' and b.translated_flag = 'R'))
		   and b.period_name = 'JAN-2022'
		   and a.period_name = 'feb-2022'
		   and (a.begin_balance_dr + a.period_net_dr != b.begin_balance_dr or a.begin_balance_cr + a.period_net_cr != b.begin_balance_cr)
	  order by 1;
