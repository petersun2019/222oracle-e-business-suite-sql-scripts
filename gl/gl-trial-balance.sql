/*
File Name: gl-trial-balance.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- PER PERIOD
-- PER CODE COMBINATION

*/

-- ##################################################################
-- PER PERIOD
-- ##################################################################

		select gb.period_name
			 , cc.concatenated_segments account_code
			 , sum((gb.begin_balance_dr_beq-gb.begin_balance_cr_beq+gb.period_net_dr_beq-gb.period_net_cr_beq)) - sum(nvl(gb.period_net_dr_beq,0)-nvl(gb.period_net_cr_beq,0)) beginning_balance
			 , sum(nvl(gb.period_net_dr_beq,0)-nvl(gb.period_net_cr_beq,0)) ptd_balance
			 , sum((gb.begin_balance_dr_beq-gb.begin_balance_cr_beq+gb.period_net_dr_beq-gb.period_net_cr_beq)) ytd_balance
		  from gl_balances gb
			 , gl_code_combinations_kfv cc
		 where cc.code_combination_id=gb.code_combination_id
		   -- and actual_flag = 'A'
		   and gb.period_name = 'Apr-19'
		   and gb.code_combination_id = 123456
		   -- and cc.concatenated_segments in ('01.AAA.BBBB.CCCC.DDDD.EEEE.FFFF.GGGG')
		   -- and cc.summary_flag = 'N'
		   -- and gb.period_year = 2019
		   -- and gb.code_combination_id in (1234,5678)
	  group by gb.period_name
			 , cc.concatenated_segments;

-- ##################################################################
-- PER CODE COMBINATION
-- ##################################################################

		select cc.concatenated_segments account_code
			 , sum((gb.begin_balance_dr_beq-gb.begin_balance_cr_beq+gb.period_net_dr_beq-gb.period_net_cr_beq)) - sum(nvl(gb.period_net_dr_beq,0)-nvl(gb.period_net_cr_beq,0)) beginning_balance
			 , sum(nvl(gb.period_net_dr_beq,0)-nvl(gb.period_net_cr_beq,0)) ptd_balance
			 , sum((gb.begin_balance_dr_beq-gb.begin_balance_cr_beq+gb.period_net_dr_beq-gb.period_net_cr_beq)) ytd_balance
		  from gl_balances gb
		  join gl_code_combinations_kfv cc on cc.code_combination_id=gb.code_combination_id
		 where 1 = 1
		   -- and actual_flag = 'A'
		   -- and gb.period_name = 'Apr-18'
		   -- and gb.code_combination_id = 123456
		   -- and cc.concatenated_segments in (1234,2345,3456)
		   -- and cc.concatenated_segments in (1234,2345,3456)
		   -- and cc.summary_flag = 'N'
		   and gb.period_year = 2019
		   and gb.code_combination_id in (1234,5678)
		   -- and gb.code_combination_id in (6907)
	  group by cc.concatenated_segments;
