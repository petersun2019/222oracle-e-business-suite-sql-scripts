/*
File Name:		gl-journals.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- GL JOURNAL HEADERS
-- GL JOURNAL LINES - BASIC
-- GL JOURNAL LINES - SLA
-- GL JOURNAL LINES - COUNTING - SOURCE AND CATEGORY 
-- GL JOURNAL HEADERS - COUNTING - SOURCE AND CATEGORY
-- GL JOURNAL LINES - COUNTING - SUM
-- COUNT BY CATEGORY
-- COUNT BY SOURCE
-- JOURNAL HEADER AND LINE COUNT PER USER
-- SUMMARY OF JOURNAL VOLUMES
-- SOURCE_ID_INT_1 MAPPINGS
-- BALANCE PER PERIOD ATTEMPTS
-- GL RECONCILIATION STUFF ATTEMPTS
-- POSTED UNPOSTED SUMMARY
-- ACTUALS ATTEMPT
-- JOURNALS CREATED IN ADJ PERIOD

*/

-- ##################################################################
-- GL JOURNAL HEADERS
-- ##################################################################

		select gjb.je_batch_id
			 , gjb.name batch_name
			 , gjh.je_header_id
			 , gjh.name journal_name
			 , gjh.description jnl_description
			 , gjh.doc_sequence_value
			 , gjb.approval_status_code
			 , gjb.status
			 , gjb.status || ' (' || v1.meaning || ' - ' || v1.description || ')' batch_status
			 , gjb.posted_date batch_posted_date
			 , gjh.status || ' (' || v2.meaning || ' - ' || v2.description || ')' jnl_status
			 , glv.name ledger
			 , gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , gjh.je_category
			 , gjh.period_name period
			 , to_char(gjh.default_effective_date, 'DD-MON-YYYY') gl_date
			 , gjh.creation_date
			 , fu.user_name created_by
			 , fu.user_id
			 , fu.email_address created_by_email
			 , fu.description
			 , fu.employee_id
			 , gjh.set_of_books_id
			 , gjh.last_update_date
			 , fu2.user_name updated_by
			 , gety.encumbrance_type encumbrance_type
			 , decode(gjh.actual_flag,'A','Actual','E','Encumbrance','Other') balance_type
			 , decode(gjh.status,'U','Unposted','P','Posted','Other') posting_status
			 , gjh.status
			 , gjh.running_total_dr
			 , gjh.running_total_cr
			 , (select count(*) from gl_je_lines gjl where gjh.je_header_id = gjl.je_header_id) lines
			 , to_char (gjh.creation_date, 'Dy') cr_day
			 , gjb.request_id
			 , (select to_char(fcr.request_date, 'DD-MON-YYYY') || '____' || case when fcr.description = fcpt.user_concurrent_program_name then fcr.description when fcr.description is not null and fcpt.user_concurrent_program_name is not null and fcr.description <> fcpt.user_concurrent_program_name then fcr.description || ' (' || fcpt.user_concurrent_program_name || ')' when fcr.description is not null and fcpt.user_concurrent_program_name is null then fcr.description when fcr.description is null and fcpt.user_concurrent_program_name is not null then fcpt.user_concurrent_program_name end || '____' || fu.user_name || ' (' || substr(fu.email_address, 0, 30) || ')' job_info from fnd_concurrent_requests fcr join fnd_user fu on fcr.requested_by = fu.user_id join fnd_concurrent_programs_tl fcpt on fcr.concurrent_program_id = fcpt.concurrent_program_id join fnd_concurrent_programs fcp on fcp.concurrent_program_id = fcpt.concurrent_program_id where fcr.request_id = gjb.request_id) job_info
			 , '----- REVERSAL INFO ----'
			 , gjh.accrual_rev_period_name rev_period
			 , gp.adjustment_period_flag adj_period
			 , gjh.accrual_rev_status rev
			 , gjhrev.je_header_id
			 , gjhrev.doc_sequence_value reversal_docnum
			 , gjhrev.creation_date reversal_cr_dt
			 , furev.description reversal_cr_by
			 , gjhrev.name reversal_name
			 , gjhrev.description reversal_description
			 , gjbrev.request_id
		  from gl_je_headers gjh
		  join gl_je_batches gjb on gjh.je_batch_id = gjb.je_batch_id
		  join gl_ledgers_v glv on glv.ledger_id = gjh.ledger_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
		  join fnd_user fu on gjh.created_by = fu.user_id
		  join fnd_user fu2 on gjh.last_updated_by = fu2.user_id
		  join gl_periods gp on gp.period_name = gjh.accrual_rev_period_name
	 left join fnd_lookup_values_vl v1 on gjb.status = v1.lookup_code and v1.lookup_type = 'MJE_BATCH_STATUS' and v1.view_application_id = 101
	 left join fnd_lookup_values_vl v2 on gjh.status = v2.lookup_code and v2.lookup_type = 'MJE_BATCH_STATUS' and v2.view_application_id = 101
	 left join gl_encumbrance_types gety on gjh.encumbrance_type_id = gety.encumbrance_type_id
	 left join gl_je_headers gjhrev on gjh.accrual_rev_je_header_id = gjhrev.je_header_id
	 left join gl_je_batches gjbrev on gjhrev.je_batch_id = gjbrev.je_batch_id
	 left join fnd_user furev on gjhrev.created_by = furev.user_id
		 where 1 = 1
		   -- and gjh.period_name in ('JAN-2022')
		   and gjh.creation_date > sysdate - 5
		   and gjst.user_je_source_name = 'Spreadsheet'
		   and gjct.user_je_category_name = 'Auto Reversing Accrual'
		   and fu.user_name = 'SYSADMIN'
		   -- and to_char(gjh.creation_date, 'MM') = '03'
		   -- and gjh.name = 'BLUE CHEESE 0001'
		   and 1 = 1
	  order by gjh.creation_date desc;

-- ##################################################################
-- GL JOURNAL LINES - BASIC
-- ##################################################################

		select gjb.name batch
			 , gjb.je_batch_id
			 , gjh.name journal
			 , gjh.je_header_id
			 , gjh.description
			 , gjh.period_name period
			 , decode(gjh.actual_flag,'A','Actual','E','Encumbrance','Other') balance_type
			 , decode(gjh.status,'U','Unposted','P','Posted','Other') posting_status
			 , gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , to_char(gjh.default_effective_date, 'dd-MON-yyyy') effective_date
			 , gjh.currency_code currency
			 , gjh.currency_conversion_rate
			 , gjh.currency_conversion_type
			 , to_char(gjh.currency_conversion_date, 'dd-MON-yyyy') currency_conversion_date
			 , gjh.external_reference reference
			 , abs(gjh.running_total_dr) journal_total
			 , gps.period_name reversal_period
			 , gety.encumbrance_type
			 , gjb.request_id
			 , gjh.date_created header_created
			 , fu.user_name || ' (' || fu.email_address || ')' journal_created_by
			 , gjl.je_line_num journal_line_number
			 , gjh.je_header_id
			 , '*** lines ***'
			 , to_char(gjl.effective_date, 'dd-MON-yyyy') gl_date_line
			 , (replace(replace(gjl.description,chr(10),''),chr(13),' ')) line_descr
			 , gjl.creation_date line_created
			 , gjl.accounted_dr
			 , gjl.accounted_cr
			 , gjl.entered_dr
			 , gjl.entered_cr
			 , gcc.concatenated_segments gl_code_combination
			 -- , gcc.segment1
			 -- , gcc.segment2
			 -- , gcc.segment3
			 -- , gcc.segment4
			 -- , gcc.segment5
			 -- , gcc.segment6
			 -- , gcc.segment7
			 -- , gcc.segment8
			 -- , gcc.segment9
			 -- , gcc.segment10
		  from gl_je_headers gjh
		  join gl_je_batches gjb on gjh.je_batch_id = gjb.je_batch_id
		  join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
		  join gl_code_combinations_kfv gcc on gjl.code_combination_id = gcc.code_combination_id
	 left join gl_period_statuses gps on gps.period_name = gjh.accrual_rev_period_name and gps.application_id = 101
	 left join gl_import_references gir on gjh.je_header_id = gir.je_header_id and gir.je_line_num = gjl.je_line_num
	 left join gl_encumbrance_types gety on gjh.encumbrance_type_id = gety.encumbrance_type_id
		  join fnd_user fu on gjh.created_by = fu.user_id
		 where 1 = 1
		   and gjh.je_header_id in (123456)
		   and 1 = 1;

-- ##################################################################
-- GL JOURNAL LINES - SLA
-- ##################################################################

-- JOINED TO SLA TABLES
-- HTTP://WWW.ORAFAQ.COM/NODE/2242
-- N.B NO JOIN TO THEM FOR CUSTOM SOURCES E.G. PAYROLL

		select gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , glv.name ledger
			 , decode(gjh.actual_flag,'A','Actual','E','Encumbrance','Other') jnl_type
			 , decode(gjh.status,'U','Unposted','P','Posted','Other') status 
			 , gjb.request_id
			 , gjb.je_batch_id
			 , gjb.name batch_name
			 , gjh.period_name period
			 , gjh.je_header_id
			 , gjh.name jnl_name
			 , gjh.currency_code
			 -- , gety.encumbrance_type
			 -- , gjh.doc_sequence_value doc
			 , to_char(gjl.creation_date, 'DD-MON-YYYY HH24:MI:SS') journal_created
			 , to_char(gjh.default_effective_date, 'DD-MON-YYYY') gl_date_header
			 , to_char(gjl.effective_date, 'dd-MON-yyyy') gl_date_line
			 , gjl.je_line_num line
			 , (replace(replace(gjl.description,chr(10),''),chr(13),' ')) line_descr
			 , gcc.code_combination_id
			 , gcc.concatenated_segments cgh_acct
			 , gjl.accounted_dr
			 , gjl.accounted_cr
			 , gjl.entered_dr
			 , gjl.entered_cr
			 , gjl.creation_date
			 , gjl.last_update_date
			 -- , fu.user_name
			 , xte.transaction_number
			 , xte.source_id_int_1
			 , xte.source_id_int_2
			 , xah.event_type_code
			 , xah.product_rule_code
			 , xte.entity_code
			 , xal.accounting_class_code
			 , xal.encumbrance_type_id
			 , xe.event_id
			 , '#################'
			 , xal.ae_line_num
			 , xal.entered_dr xla_dr
			 , xal.entered_cr xla_cr
			 , to_char(xal.creation_date, 'DD-MON-YYYY HH24:MI:SS') accounting_entry_line_created
			 , xal.description xla_line_description
		  from gl_je_headers gjh 
		  join gl_je_batches gjb on gjh.je_batch_id = gjb.je_batch_id
		  join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl_code_combinations_kfv gcc on gjl.code_combination_id = gcc.code_combination_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
		  join fnd_user fu on gjh.created_by = fu.user_id
		  join gl.gl_import_references gir on gjh.je_header_id = gir.je_header_id and gir.je_line_num = gjl.je_line_num
	 left join gl.gl_encumbrance_types gety on gjh.encumbrance_type_id = gety.encumbrance_type_id
		  join xla.xla_ae_lines xal on gir.gl_sl_link_table = xal.gl_sl_link_table and gir.gl_sl_link_id = xal.gl_sl_link_id
		  join xla.xla_ae_headers xah on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		  join xla.xla_events xe on xah.application_id = xe.application_id and xah.event_id = xe.event_id
		  join xla.xla_transaction_entities xte on xe.application_id = xte.application_id and xe.entity_id = xte.entity_id
		  join gl_ledgers_v glv on glv.ledger_id = gjh.ledger_id
		 where 1 = 1
		   and xte.source_id_int_1 = 123456 
		   and 1 = 1;

-- ##################################################################
-- GL JOURNAL LINES - COUNTING - SOURCE AND CATEGORY
-- ##################################################################

		select gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , to_char(gjh.creation_date, 'YYYY-MM-DD') creation_date
			 , count(distinct gjh.je_header_id) journal_count
			 , min(to_char(gjh.default_effective_date, 'YYYY-MM-DD')) min_jnl_header_gl_date
			 , max(to_char(gjh.default_effective_date, 'YYYY-MM-DD')) max_jnl_header_gl_date
			 , min(to_char(gjl.effective_date, 'YYYY-MM-DD')) min_jnl_line_gl_date
			 , max(to_char(gjl.effective_date, 'YYYY-MM-DD')) max_jnl_line_gl_date
			 , min(gjh.creation_date)
			 , max(gjh.creation_date)
			 , count(*) line_count
		  from gl_je_headers gjh
		  join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
		 where 1 = 1
		   and gjh.creation_date > '25-NOV-2019'
		   and gjst.user_je_source_name = 'Receivables'
	  group by gjst.user_je_source_name
			 , gjct.user_je_category_name
			 , to_char(gjh.creation_date, 'YYYY-MM-DD')
	  order by to_char(gjh.creation_date, 'YYYY-MM-DD') desc
			 , gjst.user_je_source_name
			 , gjct.user_je_category_name;

-- ##################################################################
-- GL JOURNAL HEADERS - COUNTING - SOURCE AND CATEGORY
-- ##################################################################

		select gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , count(*) ct
		  from gl_je_headers gjh
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
		 where 1 = 1
		   and gjh.creation_date > '01-SEP-2020'
	  group by gjst.user_je_source_name
			 , gjct.user_je_category_name;

-- SOURCE, CATEGORY, ACTUAL FLAG

		select gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , gjh.actual_flag
			 , min(gjh.creation_date)
			 , max(gjh.creation_date)
			 , count(*) ct
		  from gl.gl_je_headers gjh
		  join gl.gl_je_batches gjb on gjh.je_batch_id = gjb.je_batch_id
		  join gl.gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl.gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
		  join applsys.fnd_user fu on gjh.created_by = fu.user_id
		 where 1 = 1
		   -- and gjh.creation_date > '01-JAN-2013'
		   -- and gjst.user_je_source_name = 'Projects'
		   -- and gjb.je_batch_id = 5849416
	  group by gjst.user_je_source_name
			 , gjct.user_je_category_name
			 , gjh.actual_flag
	  order by 1,2;

-- SOURCE, CATEGORY, CREATED BY

		select gjst.user_je_source_name source
			 , gjst.created_by source_created_by
			 , gjct.user_je_category_name category
			 , gjct.created_by cat_created_by
			 , max(gjh.creation_date)
			 , min(to_char(gjh.creation_date, 'YYYY-MM-DD hh24:mi:ss')) min_created
			 , max(to_char(gjh.creation_date, 'YYYY-MM-DD hh24:mi:ss')) max_created
			 , count(*) ct
		  from gl_je_headers gjh
		  join gl_je_batches gjb on gjh.je_batch_id = gjb.je_batch_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
		 where 1 = 1
	  group by gjst.user_je_source_name
			 , gjct.user_je_category_name
			 , gjh.actual_flag
			 , gjst.created_by
			 , gjct.created_by
	  order by 1,2

-- ##################################################################
-- GL JOURNAL LINES - COUNTING - SUM
-- ##################################################################

		select gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , sum(gjl.accounted_dr) dr
			 , sum(gjl.accounted_cr) cr
			 , count(*) ct
		  from gl.gl_je_headers gjh 
		  join gl.gl_je_batches gjb on gjh.je_batch_id = gjb.je_batch_id
		  join gl.gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl.gl_import_references gir on gjh.je_header_id = gir.je_header_id and gir.je_line_num = gjl.je_line_num
		  join gl.gl_code_combinations gcc on gjl.code_combination_id = gcc.code_combination_id
		  join gl.gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl.gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
	 left join gl.gl_encumbrance_types gety on gjh.encumbrance_type_id = gety.encumbrance_type_id
		  join xla.xla_ae_lines xal on gir.gl_sl_link_table = xal.gl_sl_link_table and gir.gl_sl_link_id = xal.gl_sl_link_id
		  join xla.xla_ae_headers xah on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		  join xla.xla_events xe on xah.application_id = xe.application_id and xah.event_id = xe.event_id
		  join xla.xla_transaction_entities xte on xe.application_id = xte.application_id and xe.entity_id = xte.entity_id
		  join applsys.fnd_user fu on xe.created_by = fu.user_id
		 where 1 = 1
		   and gjh.creation_date > '01-AUG-2016'
		   and gcc.code_combination_id = 123456
	  group by gjst.user_je_source_name
			 , gjct.user_je_category_name;

-- ##################################################################
-- COUNT BY CATEGORY
-- ##################################################################

		select gjct.user_je_category_name category
			 , count(*) ct
		  from gl.gl_je_headers gjh
		  join gl.gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name
		 where 1 = 1
		   -- and gjh.creation_date > '01-OCT-2015'
	  group by gjct.user_je_category_name
	  order by 1,2;

-- ##################################################################
-- COUNT BY SOURCE
-- ##################################################################

		select gjst.user_je_source_name
			 -- , to_char(gjh.creation_date, 'YYYY-MM-DD') creation_date
			 , count (*) ct
			 -- , max (gjh.creation_date) latest
		  from gl.gl_je_headers gjh
		  join gl.gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name
		 where 1 = 1
		   -- and gjh.creation_date > '01-APR-2019'
		   -- and gjh.je_source = '1003'
		   -- and gjst.user_je_source_name = 'Payables'
		   and 1 = 1
	  group by gjst.user_je_source_name
			 -- , to_char(gjh.creation_date, 'YYYY-MM-DD')
	  order by 2 desc;

-- ##################################################################
-- JOURNAL HEADER AND LINE COUNT PER USER
-- ##################################################################

		select distinct fu.user_name
			 , fu.description
			 , count(distinct gjh.je_header_id) journal_count
			 , count(gjl.je_header_id) line_count
		  from gl.gl_je_headers gjh
		  join gl.gl_je_batches gjb on gjh.je_batch_id = gjb.je_batch_id
		  join gl.gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl.gl_code_combinations gcc on gjl.code_combination_id = gcc.code_combination_id
		  join applsys.fnd_user fu on gjh.created_by = fu.user_id
		 where 1 = 1
		   and gjh.creation_date > '01-JUL-2012'
		   and gjh.creation_date < '10-JUL-2012'
	  group by fu.user_name, fu.description
	  order by fu.user_name;

-- ##################################################################
-- SUMMARY OF JOURNAL VOLUMES
-- ##################################################################

--BY DAY

		select count(*) tally
			 , to_char(gjh.creation_date, 'RRRR-MM-DD') the_date
		  from gl.gl_je_headers gjh
	  group by to_char(gjh.creation_date, 'RRRR-MM-DD')
	  order by to_char(gjh.creation_date, 'RRRR-MM-DD') desc;

--BY DAY

		select count(*) tally
			 , to_char(gjh.creation_date, 'RRRR-MM-DD') the_date
			 , gjh.document_creation_method
		  from gl.gl_je_headers gjh
		 where gjh.authorization_status = 'APPROVED'
		   and gjh.type_lookup_code = 'STANDARD'
		   and gjh.creation_date > '01-FEB-2013'
	  group by to_char(gjh.creation_date, 'RRRR-MM-DD')
			 , gjh.document_creation_method
	  order by to_char(gjh.creation_date, 'RRRR-MM-DD') desc;

--BY MONTH

		select count(*) tally
			 , to_char(gjh.creation_date, 'RRRR-MM') the_date
		  from gl.gl_je_headers gjh
	  group by to_char(gjh.creation_date, 'RRRR-MM')
	  order by to_char(gjh.creation_date, 'RRRR-MM') desc;

--BY MONTH ORDERED BY MONTH

		select count(*) tally
			 , to_char(gjh.creation_date, 'MON-RRRR') the_date
		  from gl.gl_je_headers gjh
	  group by to_char(gjh.creation_date, 'MON-RRRR')
	  order by to_char(gjh.creation_date, 'MON-RRRR') desc;

--BY MONTH ORDERED BY TALLY 

		select count(*) tally
			 , to_char(gjh.creation_date, 'MON-RRRR') the_date
		  from gl.gl_je_headers gjh
	  group by to_char(gjh.creation_date, 'MON-RRRR')
	  order by 1 desc;

--BY YEAR 

		select count(*) tally
			 , to_char(gjh.creation_date, 'RRRR') the_date
		  from gl.gl_je_headers gjh
	  group by to_char(gjh.creation_date, 'RRRR')
	  order by to_char(gjh.creation_date, 'RRRR') desc;

--ALL JOURNALS

		select count(*) tally
		  from gl.gl_je_headers gjh;

-- ##################################################################
-- SOURCE_ID_INT_1 MAPPINGS
-- ##################################################################

-- FOR A GIVEN APPLICATION, FIND OUT WHAT ENTITY (E.G. AP_INVOICES) AND COLUMN_NAME (E.G. INVOICE_ID)
-- FOUND VIA APPLICATION DIAGNOSTICS > SUBLEDGER ACCOUNTING > SETUP DIAGNOSTICS > XLA SETUP DIAGNOSTICS DIAGNOSTICS SCRIPT

-- Refer to file "xla-entity-id-mappings.sql" in "xla" folder

-- ##################################################################
-- BALANCE PER PERIOD ATTEMPTS
-- ##################################################################

		select gcc.segment1
			 -- , gjh.period_name
			 -- , gcc.segment2
			 -- , ffvt.description
			 -- , sum (gjl.accounted_dr)
			 -- , sum (gjl.accounted_cr)
			 , -(sum (gjl.accounted_cr) - sum (gjl.accounted_dr))
		  from gl.gl_je_headers gjh
			 , gl.gl_je_batches gjb
			 , gl.gl_je_lines gjl
			 , gl.gl_je_sources_tl gjst
			 , gl.gl_je_categories_tl gjct
			 , gl.gl_code_combinations gcc
			 , gl.gl_je_lines_recon gjlr
			 , applsys.fnd_user fu
			 , applsys.fnd_flex_values_tl ffvt
		 where gjh.je_batch_id = gjb.je_batch_id(+)
		   and gjh.je_header_id = gjl.je_header_id
		   and gjh.je_source = gjst.je_source_name
		   and gjh.je_category = gjct.je_category_name
		   and gjh.created_by = fu.user_id
		   and gjl.code_combination_id = gcc.code_combination_id
		   and gjl.je_header_id = gjlr.je_header_id(+)
		   and gjl.je_line_num = gjlr.je_line_num(+)
		   and gcc.segment1 = ffvt.flex_value_meaning(+)
		   -- and gjh.period_name = '1516-04:NOV' --(select period_name from pa.pa_periods_all where current_pa_period_flag = 'Y')
		   -- and gcc.code_combination_id = 1234
		   -- and gjst.user_je_source_name = 'Payables'
		   and gcc.segment1 = '01'
		   -- and gcc.segment2 = 'AAA'
		   -- and gcc.segment3 = 'BBB'
		   -- and gcc.segment4 = 'CCC'
		   -- and gcc.segment5 = 'DDD'
		   -- and gcc.segment6 = 'EEE'
		   -- and gjl.creation_date > '21-JAN-2014'
		   -- and gjh.period_name = 'JAN-2022'
	  group by gcc.segment1
			 -- , gjh.period_name
			 -- , gcc.segment2
			 -- , ffvt.description
	  order by gjh.period_name;

		select gcc.segment1
			 , gjh.period_name
			 , gcc.segment2
			 , ffvt.description
			 , -(sum (gjl.accounted_cr) - sum (gjl.accounted_dr))
		  from gl.gl_je_headers gjh
			 , gl.gl_je_batches gjb
			 , gl.gl_je_lines gjl
			 , gl.gl_je_sources_tl gjst
			 , gl.gl_je_categories_tl gjct
			 , gl.gl_code_combinations gcc
			 , applsys.fnd_flex_values_tl ffvt
		 where gjh.je_batch_id = gjb.je_batch_id
		   and gjh.je_header_id = gjl.je_header_id
		   and gjh.je_source = gjst.je_source_name
		   and gjh.je_category = gjct.je_category_name
		   and gjl.code_combination_id = gcc.code_combination_id
		   and gcc.segment1 = ffvt.flex_value_meaning
		   and gjh.period_name = '1516-04:NOV'
		   and gcc.segment2 = 'XXAA'
		   -- and gjst.user_je_source_name = 'Payables'
		   -- and gcc.segment1 = 'WP00400' 
		   -- and gcc.code_combination_id = 321966
	  group by gjh.period_name
			 , gcc.segment1
			 , gcc.segment2
			 , ffvt.description
	  order by gjh.period_name;

-- ##################################################################
-- GL RECONCILIATION STUFF ATTEMPTS
-- ##################################################################

		select gjh.je_header_id jnl_hdr_id
			 , gjct.user_je_category_name category
			 , gjst.user_je_source_name source
			 , gjb.status post_status
			 , gjb.name batch_name
			 , gjh.period_name
			 , gjh.name journal_name
			 , gjh.external_reference ref
			 , gjh.date_created
			 , gjh.description
			 , gjh.running_total_dr ttl
			 , gjh.doc_sequence_value doc
			 , gjh.creation_date
			 , fu.description created_by
			 , '*** LINES ***'
			 , gjl.je_line_num
			 , gjl.description line_descr
			 , gjl.reference_1 line_ref
			 , gjl.reference_5 ap_inv_num
			 , gjl.reference_6 line_src
			 , gjl.reference_10 line_type
			 , gcc.segment1 || '*' || gcc.segment2 || '*' || gcc.segment3 || '*' || gcc.segment4 || '*' || gcc.segment5 || '*' || gcc.segment6 cgh_acct
			 , gjl.accounted_dr dr
			 , gjl.accounted_cr cr
			 , '*** R12 RECONCILIATION ***'
			 , gjlr.jgzz_recon_status
			 , gjlr.jgzz_recon_date
			 , gjlr.jgzz_recon_id
			 , gjlr.jgzz_recon_ref 
		  from gl.gl_je_headers gjh
			 , gl.gl_je_batches gjb
			 , gl.gl_je_lines gjl
			 , gl.gl_je_sources_tl gjst
			 , gl.gl_je_categories_tl gjct
			 , gl.gl_code_combinations gcc
			 , gl.gl_je_lines_recon gjlr
			 , applsys.fnd_user fu
		 where gjh.je_batch_id = gjb.je_batch_id
		   and gjh.je_header_id = gjl.je_header_id
		   and gjh.je_source = gjst.je_source_name
		   and gjh.je_category = gjct.je_category_name
		   and gjh.created_by = fu.user_id
		   and gjl.code_combination_id = gcc.code_combination_id
		   -- and gcc.code_combination_id = 123456
		   and gjl.creation_date > '01-JAN-2015'
		   -- and gjl.creation_date < '01-JUL-2015'
		   -- and gjlr.jgzz_recon_ref is null
		   -- and gjh.doc_sequence_value = 123456
		   -- and gjh.je_header_id = 123456
		   -- and gjlr.jgzz_recon_ref = 'TEST'
		   and gjl.je_header_id = gjlr.je_header_id(+)
		   and gjl.je_line_num = gjlr.je_line_num(+);

-- ##################################################################
-- POSTED UNPOSTED SUMMARY
-- ##################################################################

		select to_char(gjh.creation_date, 'YYYY-MM-DD') creation_date
			 , gjh.status
			 , gjh.period_name
			 , glv.name ledger
			 , count(distinct gjh.je_header_id) journal_count
			 , count(gjl.je_header_id) line_count
		  from gl_je_headers gjh
		  join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl_ledgers_v glv on glv.ledger_id = gjh.ledger_id
		 where 1 = 1
		   and gjh.creation_date > '28-JUL-2021'
		   and 1 = 1
	  group by to_char(gjh.creation_date, 'YYYY-MM-DD')
			 , gjh.status
			 , gjh.period_name
			 , glv.name
	  order by to_char(gjh.creation_date, 'YYYY-MM-DD') desc
			 , gjh.status
			 , gjh.period_name
			 , glv.name;

-- ##############################################################
-- ACTUALS ATTEMPT
-- ##############################################################

		select gjh.period_name period
			 , gcc.segment1
			 , gcc.segment2
			 , gl_flexfields_pkg.get_description_sql(123, 1, gcc.segment1) seg1_descr
			 , gl_flexfields_pkg.get_description_sql(123, 2, gcc.segment2) seg2_descr
			 , nvl(sum(gjl.accounted_dr),0) - nvl(sum(gjl.accounted_cr),0) actual
		  from gl_je_headers gjh
		  join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl_code_combinations gcc on gjl.code_combination_id = gcc.code_combination_id
		 where 1 = 1
		   and gjh.status = 'P'
		   and gjh.period_name = 'JAN-2022'
		   and gcc.segment2 = 'AAAA'
		   and 1 = 1
	  group by gjh.period_name
			 , gcc.segment1
			 , gcc.segment2
			 , gl_flexfields_pkg.get_description_sql(123, 1, gcc.segment1)
			 , gl_flexfields_pkg.get_description_sql(123, 2, gcc.segment2);

-- ##############################################################
-- JOURNALS CREATED IN ADJ PERIOD
-- ##############################################################

		select glv.name ledger
			 , glv.short_name ledger_short_name
			 , glv.description ledger_description
			 , gp.period_name
			 , gjh.je_header_id
			 , gjh.je_source
			 , gjh.je_category
			 , gjh.name journal_name
			 , gjh.currency_code
			 , gjh.creation_date
			 , fu.user_name created_by
			 , gjh.accrual_rev_period_name
			 , gjh.running_total_dr
			 , gjh.running_total_cr
			 , gjh.running_total_accounted_dr
			 , gjh.running_total_accounted_cr
			 , gjh.currency_conversion_rate
			 , gjh.currency_conversion_type
		  from gl_je_headers gjh
		  join gl_periods gp on gjh.period_name = gp.period_name
		  join gl_ledgers_v glv on gjh.ledger_id = glv.ledger_id
		  join fnd_user fu on gjh.created_by = fu.user_id
		 where 1 = 1
		   and gp.adjustment_period_flag = 'Y'
		   and 1 = 1
	  order by gjh.je_header_id desc;
