/*
File Name:		gl-xla-accounting-data.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

More XLA queries are in the xla folder

Queries:

-- XLA_TRANSACTION_ENTITIES
-- XLA_EVENTS
-- XLA_AE_HEADERS
-- XLA_AE_LINES
-- ACCOUNTING SUMMARY
-- INCLUDING RECEIPT NUMBER
-- XLA_DISTRIBUTION_LINKS
-- LOTS JOINED UP
-- ANOTHER SLA SUMMARY

*/

-- ##################################################################
-- XLA_TRANSACTION_ENTITIES
-- ##################################################################

		select *
		  from xla.xla_transaction_entities xte
		 where xte.application_id = 222
		   and xte.entity_code = 'RECEIPTS'
		   and xte.source_id_int_1 = 2531964;

-- ##################################################################
-- XLA_EVENTS
-- ##################################################################

		select *
		  from xla.xla_events xe
		 where xe.application_id = 222
		   and xe.entity_id in (select xte.entity_id
								  from xla.xla_transaction_entities xte
								 where xte.application_id = 222
								   and xte.entity_code = 'RECEIPTS'
								   and xte.source_id_int_1 = 2641017);

-- ##################################################################
-- XLA_AE_HEADERS
-- ##################################################################

		select *
		  from xla.xla_ae_headers xah
		 where xah.application_id = 222
		   and xah.entity_id in (select xte.entity_id
								   from xla.xla_transaction_entities xte
								  where xte.application_id = 222
								    and xte.entity_code = 'RECEIPTS'
								    and xte.source_id_int_1 = 2641017);

-- ##################################################################
-- XLA_AE_LINES
-- ##################################################################

		select xal.*
		  from xla.xla_ae_lines xal
			 , xla.xla_ae_headers xah
		 where xal.application_id = xah.application_id
		   and xal.ae_header_id = xah.ae_header_id
		   and xah.application_id = 222
		   and xah.entity_id in (select xte.entity_id
								   from xla.xla_transaction_entities xte
								  where xte.application_id = 222
								    and xte.entity_code = 'RECEIPTS'
								    and xte.source_id_int_1 = 2533964);

-- ##################################################################
-- ACCOUNTING SUMMARY
-- ##################################################################

		select xal.ae_header_id
			 , xah.entity_id
			 , sum(entered_dr) - sum(entered_cr) entered
			 , sum(accounted_dr) - sum(accounted_cr) accounted
		  from xla.xla_ae_lines xal
			 , xla.xla_ae_headers xah
		 where xal.application_id = xah.application_id
		   and xal.ae_header_id = xah.ae_header_id
		   and xah.application_id = 222
		   and xah.entity_id in (select xte.entity_id
								   from xla.xla_transaction_entities xte
								  where xte.application_id = 222
								    and xte.entity_code = 'RECEIPTS'
								    and xte.source_id_int_1 = 2533964)
							   group by xal.ae_header_id
								 	  , xah.entity_id;

-- ##################################################################
-- INCLUDING RECEIPT NUMBER
-- ##################################################################

		select acra.receipt_number
			 , acra.cash_receipt_id
			 , xal.ae_header_id
			 , xah.entity_id
			 , sum(entered_dr) - sum(entered_cr) entered
			 , sum(accounted_dr) - sum(accounted_cr) accounted
		  from xla.xla_events xe
			 , xla.xla_ae_lines xal
			 , xla.xla_ae_headers xah
			 , xla.xla_transaction_entities xte
			 , ar.ar_cash_receipts_all acra
		 where xah.application_id = xe.application_id
		   and xah.event_id = xe.event_id
		   and xal.application_id = xah.application_id
		   and xal.ae_header_id = xah.ae_header_id
		   and xte.entity_id = xah.entity_id
		   and xte.source_id_int_1 = acra.cash_receipt_id
		   and xte.entity_code = 'RECEIPTS'
		   and xah.application_id = 222
		   -- and acra.receipt_number = '123456'
		   and acra.creation_date > '22-JUL-2016'
	  group by acra.receipt_number
			 , acra.cash_receipt_id
			 , xal.ae_header_id
			 , xah.entity_id;

-- ##################################################################
-- XLA_DISTRIBUTION_LINKS
-- ##################################################################

		select xdl.*
		  from xla.xla_distribution_links xdl
			 , xla.xla_ae_headers xah
		 where xdl.application_id = xah.application_id
		   and xdl.ae_header_id = xah.ae_header_id
		   and xah.application_id = 222
		   and xah.entity_id in (select xte.entity_id
								   from xla.xla_transaction_entities xte
								  where xte.application_id = 222
								    and xte.entity_code = 'RECEIPTS'
								    and xte.source_id_int_1 = 2641017);

-- ##################################################################
-- LOTS JOINED UP
-- ##################################################################

		select xah.*
			 , acra.receipt_number
			 , acra.cash_receipt_id
			 , xal.ae_header_id
			 , xah.entity_id
		  from xla.xla_events xe
			 , xla.xla_ae_lines xal
			 , xla.xla_ae_headers xah
			 , xla.xla_transaction_entities xte
			 , ar.ar_cash_receipts_all acra
		 where xah.application_id = xe.application_id
		   and xah.event_id = xe.event_id
		   and xal.application_id = xah.application_id
		   and xal.ae_header_id = xah.ae_header_id
		   and xte.entity_id = xah.entity_id
		   and xte.source_id_int_1 = acra.cash_receipt_id
		   and xte.entity_code = 'RECEIPTS'
		   and xah.application_id = 222
		   and acra.receipt_number = '123456';

-- ##################################################################
-- ANOTHER SLA SUMMARY
-- ##################################################################

		select xte.transaction_number trx
			 , xte.source_id_int_1 id
			 , xte.source_id_int_2
			 , xte.source_id_int_3
			 , xah.event_type_code
			 , xah.product_rule_code
			 , xte.entity_code
			 , xal.accounting_class_code
			 , xah.balance_type_code bal_type
			 , xe.event_id
			 , xal.accounted_dr dr
			 , xal.accounted_cr cr
			 , xal.description
			 , xal.business_class_code
			 , trunc(xal.accounting_date) acct_date
			 , xal.code_combination_id
			 , gcc.segment1
			 , gcc.segment2
			 , gcc.segment3
			 , gcc.segment4
			 , gcc.segment5
			 , gcc.segment6
			 , xah.gl_transfer_date
			 , xah.je_category_name
			 , xah.period_name
		  from xla.xla_ae_lines xal
		  join xla.xla_ae_headers xah on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		  join xla.xla_events xe on xah.application_id = xe.application_id and xah.event_id = xe.event_id
		  join xla.xla_transaction_entities xte on xe.application_id = xte.application_id and xe.entity_id = xte.entity_id
		  join gl.gl_code_combinations gcc on gcc.code_combination_id = xal.code_combination_id
		 where 1 = 1
		   and xte.source_id_int_1 in (123456) -- AP INVOICE ID
		   and xte.entity_code = 'AP_INVOICES'
		   and 1 = 1;

