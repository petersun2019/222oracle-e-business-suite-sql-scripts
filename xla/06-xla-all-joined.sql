/*
File Name:		06-xla-all-joined.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

XLA_TRANSACTION_ENTITIES.SOURCE_ID_INT_1 column is often used for the main identifier for a transaction such as an AP Invoice, AR Transaction etc.
So if you have that ID, you can check what SLA data exists for that Transaction by searching against it using the SOURCE_ID_INT_1 column.

Queries:

-- XLA TABLES JOINED TOGETHER
-- LINKED JOURNAL INFO

*/

-- ##################################################################
-- XLA TABLES JOINED TOGETHER
-- ##################################################################

		select '######### xla_transaction_entities ######################' xla_transaction_entities
			 , xte.entity_id
			 , xte.source_id_int_1
			 , xte.source_id_int_2
			 , xte.transaction_number
			 , xte.entity_code
			 , fat.application_name app
			 , glv.name ledger
			 , '######## xla_ae_headers #########' xla_ae_headers
			 , xah.ae_header_id
			 , decode(xah.balance_type_code,'E','Encumbrance','A','Actual') balance_type
			 , xah.period_name
			 , xah.completed_date
			 , to_char(xah.accounting_date, 'dd-mon-yyyy') accounting_date
			 , xah.gl_transfer_status_code
			 , xah.je_category_name
			 , xah.creation_date
			 , xah.request_id
			 , xah.group_id
			 , xah.description
			 , '######### xla_events ######################' xla_events
			 , xe.event_id
			 , xe.event_number
			 , xe.creation_date event_created
			 , flv2.meaning event_status
			 , flv3.meaning event_process_status
			 , xe.event_type_code
			 , '######## xla_ae_lines #########' xla_ae_lines
			 , gcc.concatenated_segments
			 , xal.accounting_class_code
			 , flv1.meaning accounting_class
			 , xal.displayed_line_number
			 , xal.currency_code currency
			 , xal.entered_dr
			 , xal.entered_cr
			 , xal.accounted_dr
			 , xal.accounted_cr
			 , xal.creation_date line_created
			 , xal.currency_code
			 -- , '########## project_data ##########' project_data
			 -- , ppa.segment1 project
			 -- , pdra.draft_revenue_num
			 -- , pdra.unbilled_receivable_dr
		  from xla.xla_transaction_entities xte
		  join xla.xla_ae_headers xah on xah.entity_id = xte.entity_id and xah.application_id = xte.application_id
		  join xla.xla_events xe on xe.entity_id = xte.entity_id and xte.application_id = xe.application_id
		  join xla.xla_ae_lines xal on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		  join apps.fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
		  join apps.fnd_lookup_values_vl flv1 on xal.accounting_class_code = flv1.lookup_code and flv1.lookup_type = 'XLA_ACCOUNTING_CLASS'
		  join apps.fnd_lookup_values_vl flv2 on xe.event_status_code = flv2.lookup_code and flv2.lookup_type = 'XLA_EVENT_STATUS'
		  join apps.fnd_lookup_values_vl flv3 on xe.process_status_code = flv3.lookup_code and flv3.lookup_type = 'XLA_EVENT_PROCESS_STATUS'
		  join apps.gl_code_combinations_kfv gcc on gcc.code_combination_id = xal.code_combination_id
		  join apps.gl_ledgers_v glv on glv.ledger_id = xte.ledger_id
		 where 1 = 1
		   and fat.application_name = 'Payables'
		   and (xal.entered_dr = 50 or xal.entered_cr = 50)
		   -- and fat.application_id = 275
		   -- and xte.entity_code = 'AP_INVOICES' and xte.source_id_int_1 = 123456 -- get all XLA data for a single source transaction
		   -- and xah.je_category_name = 'Purchase Invoices'
		   -- and xe.event_type_code = 'SUPP_COST_DIST'
		   -- and xte.source_id_int_1 in (123456)
		   -- and xah.gl_transfer_status_code = 'N'
		   -- and xah.period_name = 'DEC-2021'
		   -- and xal.ae_header_id in (12345678, 12345679)
		   -- and xe.event_id = 12345678
		   -- and xah.ae_header_id = 12345678
		   and 1 = 1
	  order by xte.source_id_int_1
			 , xte.transaction_number
			 , xe.event_id
			 , xe.event_number
			 , xal.displayed_line_number;

-- ##################################################################
-- LINKED JOURNAL INFO
-- ##################################################################

		select gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , decode(gjh.actual_flag,'A','Actual','E','Encumbrance','Other') jnl_type
			 , decode(gjh.status,'U','Unposted','P','Posted','Other') status 
			 , gjb.name batch_name
			 , gjh.period_name period
			 , gjh.name jnl_name
			 , gjh.doc_sequence_value doc
			 , gjl.creation_date
			 , to_char(gjl.effective_date, 'dd-MON-yyyy') gl_date_line
			 , gjl.je_line_num line
			 , (replace(replace(gjl.description,chr(10),''),chr(13),' ')) line_descr
			 , gcc.concatenated_segments
			 , gjl.accounted_dr dr
			 , gjl.accounted_cr cr
			 , xte.transaction_number
			 , xte.source_id_int_1
			 , xte.source_id_int_2
			 , xah.event_type_code
			 , xah.product_rule_code
			 , xte.entity_code
			 , xal.accounting_class_code
			 , xe.event_id
		  from gl_je_headers gjh 
		  join gl_je_batches gjb on gjh.je_batch_id = gjb.je_batch_id
		  join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name
		  join gl_import_references gir on gjh.je_header_id = gir.je_header_id and gir.je_line_num = gjl.je_line_num
		  join xla_ae_lines xal on gir.gl_sl_link_table = xal.gl_sl_link_table and gir.gl_sl_link_id = xal.gl_sl_link_id
		  join xla_ae_headers xah on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		  join xla_events xe on xah.application_id = xe.application_id and xah.event_id = xe.event_id
		  join xla_transaction_entities xte on xe.application_id = xte.application_id and xe.entity_id = xte.entity_id
		  join fnd_application_tl fat on xte.application_id = fat.application_id
		  join gl_code_combinations_kfv gcc on gcc.code_combination_id = xal.code_combination_id
		 where 1 = 1
		   and fat.application_name = 'Receivables'
		   -- and xte.entity_code = 'AP_INVOICES' and xte.source_id_int_1 = 123456 -- get all XLA data for a single source transaction
		   and xte.source_id_int_1 in (12345678, 12345679)
		   -- and xal.ae_header_id in (12345678, 12345679)
		   and 1 = 1
