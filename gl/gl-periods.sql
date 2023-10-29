/*
File Name: gl-periods.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- BASIC PERIODS TABLE
-- SUMMARY PER PERIOD_SET_NAME
-- PERIODS - R12 -- USES SETS OF BOOKS AND LEDGERS
-- PERIODS - 11I -- USES SETS OF BOOKS, NOT LEDGERS

*/

-- ##################################################################
-- BASIC PERIODS TABLE
-- ##################################################################

		select '#' || gp.entered_period_name "prefix"
			 , decode(gp.period_type, 'Quarter','Quarter','Year','Year','21','Month-Adj') "type"
			 , gp.period_year "year"
			 , gp.quarter_num "quarter"
			 , gp.period_num "num"
			 , to_char(gp.start_date, 'DD-MON-YYYY') "from"
			 , to_char(gp.end_date, 'DD-MON-YYYY') "to"
			 , '#' || gp.period_name "name"
			 , gp.adjustment_period_flag "adjusting"
			 , '----------------'
			 , gp.period_set_name
			 , gp.creation_date period_created
			 , fu1.description period_created_by
			 , gp.last_update_date period_updated
			 , fu1.email_address period_created_by_email
			 -- , gp.last_update_date period_updated
			 -- , fu2.description period_updated_by
			 -- , gp.*
		  from gl.gl_periods gp
		  join applsys.fnd_user fu1 on gp.created_by = fu1.user_id
		  join applsys.fnd_user fu2 on gp.last_updated_by = fu2.user_id
		 where 1 = 1
		   -- and gp.period_name = 'MAR-2050'
		   -- and gp.period_year = '2050'
		   and gp.period_set_name = 'MY_CUSTOMER'
		   -- and gp.adjustment_period_flag = 'Y'
		   -- and sysdate between gp.start_date and gp.end_date
		   and 1 = 1
	  order by gp.period_set_name
			 , gp.period_year desc
			 , decode(gp.period_type, 'Quarter','Quarter','Year','Year','21','Month')
			 , gp.quarter_num
			 , gp.period_num;

-- ##################################################################
-- SUMMARY PER PERIOD_SET_NAME
-- ##################################################################

		select gp.period_set_name
			 , min(gp.creation_date)
			 , max(gp.creation_date)
			 , count(*)
		  from gl.gl_periods gp
	  group by gp.period_set_name;

-- ##################################################################
-- PERIODS - R12 -- USES SETS OF BOOKS AND LEDGERS
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , gps.period_name
			 , decode(gps.closing_status, 'O','Open', 'C', 'Closed', 'F', 'Future', 'W', 'Pending Close', 'N', 'Never Opened', gps.closing_status) stat
			 , fa.application_short_name app
			 , fat.application_name app_name
			 , fat.application_id app_id
			 -- , gps.ledger_id
			 , gps.last_update_date up_dt
			 , fu.user_name updated_by
			 , to_char(gps.start_date, 'DD-MON-YYYY') start_date
			 , to_char(gps.end_date, 'DD-MON-YYYY') end_date
			 , gps.period_year
			 , gps.creation_date period_created
			 , gps.adjustment_period_flag
			 -- , glv.ledger_id
			 , glv.name ledger
		  from gl_period_statuses gps
		  join fnd_application_tl fat on gps.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_application fa on fa.application_id = fat.application_id 
		  join fnd_user fu on gps.last_updated_by = fu.user_id
		  join gl_ledgers_v glv on gps.ledger_id = glv.ledger_id
		 where 1 = 1
		   -- and gps.last_update_date > trunc(sysdate) - 5
		   -- and glv.name = 'MY_LEDGER'
		   and gps.application_id in (101)
		   -- and gps.closing_status != 'N'
		   and gps.closing_status = 'O'
		   -- and '17-SEP-2021' between gps.start_date and gps.end_date
		   -- and sysdate between gps.start_date and gps.end_date
		   -- and fa.application_short_name in ('SQLGL')
		   -- and fa.application_short_name in ('SQLGL','PO','AR','IPA')
		   -- and gps.period_name in ('OCT-2021')
		   -- and gps.ledger_id in (1, 2, 3)
		   -- and gps.period_year = '2022'
		   -- and glv.latest_opened_period_name is not null
		   -- and glv.name in ('XX LEDGER')
	  order by gps.last_update_date desc;

-- ##################################################################
-- PERIODS - 11I -- USES SETS OF BOOKS, NOT LEDGERS
-- ##################################################################

		select fa.application_short_name app
			 , fat.application_name app_name
			 , fat.application_id
			 , gps.period_name
			 , gps.period_year
			 , to_char(gps.start_date, 'DD-MON-YYYY') start_date
			 , to_char(gps.end_date, 'DD-MON-YYYY') end_date
			 -- , glv.name ledger
			 , decode(gps.closing_status, 'O','Open', 'C', 'Closed', 'F', 'Future', 'W', 'Pending Close', 'N', 'Never Opened', gps.closing_status) status
			 , gps.creation_date period_created
			 , fu2.user_name period_created_by
			 , gps.last_update_date period_updated
			 , fu.user_name period_updated_by
			 , fu.email_address
			 , sob.name set_of_books
		  from gl_period_statuses gps
		  join fnd_application_tl fat on gps.application_id = fat.application_id
		  join fnd_application fa on fa.application_id = fat.application_id 
		  join fnd_user fu on gps.last_updated_by = fu.user_id
		  join fnd_user fu2 on gps.created_by = fu2.user_id
		  join gl_sets_of_books sob on sob.set_of_books_id = gps.set_of_books_id
		 where 1 = 1
		   -- and gps.last_update_date > trunc(sysdate) - 10 -- gl closed 08-aug-2018 12:46:26
		   -- and glv.name = 'XX CUST LEDGER'
		   and gps.application_id in (101)
		   and sob.name = 'My Set Of Books'
		   -- and fu2.user_name = 'BOBHOPE'
		   -- and gps.closing_status = 'O'
		   -- and fat.application_id = 8721
		   -- and trunc(sysdate) between gps.start_date and gps.end_date
		   -- and gps.period_name = 'MAR-2022'
		   -- and gps.period_year = '2022'
	  order by gps.period_year desc, period_num desc;
