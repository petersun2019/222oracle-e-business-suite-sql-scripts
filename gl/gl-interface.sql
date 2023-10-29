/*
File Name: gl-interface.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- GL INTERFACE BASIC
-- DETAILS
-- SUMMARY 1
-- SUMMARY 2

*/

-- ##################################################################
-- GL INTERFACE BASIC
-- ##################################################################

		select gi.*
		  from gl_interface gi
		 where 1 = 1
		   -- and gi.period_name = 'JUL-20'
		   and gi.group_id = '1234'
		   -- and gi.accounting_date between '01-MAY-2019' AND '31-MAY-2019'
		   and 1 = 1;

		select *
		  from gl_interface
		 where 1 = 1
		   and set_of_books_id > 0
		   and 1 = 1;

-- ##################################################################
-- DETAILS
-- ##################################################################

		select gi.group_id
			 , gi.ledger_id
			 , glv.name ledger
			 , gi.set_of_books_id
			 , gi.request_id
			 , sob.short_name sob
			 , gi.request_id
			 , to_char(gi.date_created, 'DD-MON-YYYY') date_created
			 , to_char(gi.accounting_date, 'DD-MON-YYYY') gl_date
			 , glv.description
			 , gi.period_name period_name_table
			 -- , (select gps.period_name from gl.gl_period_statuses gps where gps.application_id = 101 and sysdate between gps.start_date and gps.end_date) period_name_calc
			 , gi.actual_flag
			 , gi.status
			 , gi.transaction_date
			 , fu.user_name created_by
			 , fu.email_address
			 , decode(gi.actual_flag,'A','Actual','E','Encumbrance','Other') jnl_type
			 , gety.encumbrance_type enc_type
			 , gi.user_je_category_name category
			 , gi.user_je_source_name source
			 , gcc.concatenated_segments code_combination
			 , gi.entered_dr
			 , gi.entered_cr
			 , gi.segment1 || '.' || gi.segment2 || '.' || gi.segment3 || '.' || gi.segment4 || '.' || gi.segment5 || '.' || gi.segment6 || '.' || gi.segment7 || '.' || gi.segment8 || '.' || gi.segment9 || '.' || gi.segment10 code_combination
			 , gi.accounted_dr
			 , gi.accounted_cr
		  from gl_interface gi
	 left join gl_code_combinations_kfv gcc on gi.code_combination_id = gcc.code_combination_id
	 left join gl_encumbrance_types gety on gi.encumbrance_type_id = gety.encumbrance_type_id
		  join fnd_user fu on gi.created_by = fu.user_id
	 left join gl_ledgers_v glv on gi.ledger_id = glv.ledger_id
	 left join gl_sets_of_books sob on sob.set_of_books_id = gi.set_of_books_id
		 where 1 = 1
		   -- and gi.group_id = 1234
		   -- and period_name = 'JAN-2022'
		   -- and (select gps.period_name from gl.gl_period_statuses gps where gps.application_id = 101 and sysdate between gps.start_date and gps.end_date) = 'MAY-2020'
		   -- and gi.set_of_books_id = 1234
		   -- and gi.group_id = 1234
		   -- and actual_flag = 'B'
		   -- and gi.ledger_id < 0
		   -- and gi.user_je_source_name = 'Spreadsheet'
		   -- and gi.user_je_category_name = 'Accrual'
		   and fu.user_name = 'SYSADMIN'
		   -- and gi.user_je_source_name = 'Budget - Journal'
		   -- and gi.reference1 = 'Blue Cheese'
		   -- and gi.accounting_date between '01-NOV-2018' AND '01-DEC-2018'
		   -- and gi.user_je_source_name = 'Budget - Upload'
		   -- and gi.user_je_source_name = 'Spreadsheet'
		   -- and request_id = 123456
		   -- and status = 'HOLDING'
		   and 1 = 1
	  order by gi.date_created desc;

-- ##################################################################
-- SUMMARY 1
-- ##################################################################

		select gi.user_je_source_name
			 , gi.user_je_category_name
			 , to_char(gi.accounting_date, 'YYYY-MM-DD') gl_date
			 , fu.user_name created_by
			 , fu.email_address created_by_email
			 , gi.ledger_id
			 -- , glv.name ledger
			 , gi.period_name
			 , gi.group_id
			 , gi.request_id
			 , count(*) lines
			 , max(to_char(gi.date_created, 'YYYY-MM-DD')) max_date_created
		  from gl_interface gi
		  -- join gl_ledgers_v glv on gi.ledger_id = glv.ledger_id
	 left join fnd_user fu on gi.created_by = fu.user_id
		 where 1 = 1
		   and gi.user_je_source_name = 'Spreadsheet'
		   and gi.user_je_category_name = 'Accrual'
		   -- and gi.group_id in (1234, 1235)
		   -- and gi.request_id is not null
	  group by gi.user_je_source_name
			 , gi.user_je_category_name
			 , fu.user_name
			 , fu.email_address
			 , gi.ledger_id
			 , to_char(gi.accounting_date, 'DD-MON-YYYY')
			 -- , glv.name
			 , gi.period_name
			 , gi.group_id
			 , gi.request_id;

-- ##################################################################
-- SUMMARY 2
-- ##################################################################

		select '#' || gi.group_id group_id
			 , count(*) lines
			 , gi.ledger_id
			 , glv.name ledger
			 , gi.set_of_books_id
			 , gsob.name set_of_books
			 , gi.actual_flag
			 , gi.reference4
			 , to_char(gi.date_created, 'DD-MON-YYYY') date_created
			 , gi.user_je_source_name source
			 , gi.user_je_category_name category
			 , gi.request_id
			 -- , gi.period_name period_table
			 -- , tbl_periods.period_name period_calc
			 , '#####'
			 , '#' || gic.group_id interface_control_check
			 , gic.je_source_name interface_source_name
			 , '#####'
			 , gjs.je_source_name
			 , gjs.user_je_source_name
			 , gjs.je_source_key
			 , gjs.import_using_key_flag
			 , fu.user_name
			 , fu.description
		  from gl.gl_interface gi
	 left join applsys.fnd_user fu on gi.created_by = fu.user_id
	 left join gl_ledgers_v glv on gi.ledger_id = glv.ledger_id
	 left join gl_sets_of_books gsob on gi.set_of_books_id = gsob.set_of_books_id
	 left join gl_je_sources gjs on gjs.user_je_source_name = gi.user_je_source_name
	 left join gl_interface_control gic on gic.group_id = gi.group_id
	 -- left join (select period_name, start_date, end_date from gl_period_statuses gps where gps.application_id = 101) tbl_periods on gi.accounting_date between tbl_periods.start_date and tbl_periods.end_date
		 where 1 = 1
		   -- and gi.group_id = 1234
		   -- and gi.period_name = 'May-19'
		   -- and (select gps.period_name from gl.gl_period_statuses gps where gps.application_id = 101 and gi.accounting_date between gps.start_date and gps.end_date) = 'May-19'
		   -- and gi.set_of_books_id = 2043
		   -- and gi.actual_flag = 'B'
		   -- and gi.request_id is not null
		   -- and gi.status not in ('P','NEW','IGIG-NEW','HOLDING','CORRECTED','PROCESSED')
		   -- and gi.request_id = 123456
		   -- and gi.request_id is not null
		   and gjs.user_je_source_name = 'Budget - Journal'
		   and gi.reference1 = 'Blue Cheese'
		   -- and gi.set_of_books_id = 1234
		   and 1 = 1
		   -- and gi.ledger_id > 0
	  group by '#' || gi.group_id
			 , gi.ledger_id
			 , glv.name
			 , gi.set_of_books_id
			 , gsob.name
			 , gi.actual_flag
			 , gi.reference4
			 , to_char(gi.date_created, 'DD-MON-YYYY')
			 , gi.user_je_source_name
			 , gi.user_je_category_name
			 , gi.request_id
			 -- , gi.period_name
			 -- , tbl_periods.period_name
			 , '#####'
			 , '#' || gic.group_id
			 , gic.je_source_name
			 , '#####'
			 , gjs.je_source_name
			 , gjs.user_je_source_name
			 , gjs.je_source_key
			 , gjs.import_using_key_flag
			 , fu.user_name
			 , fu.description
	  order by '#' || gi.group_id desc;
