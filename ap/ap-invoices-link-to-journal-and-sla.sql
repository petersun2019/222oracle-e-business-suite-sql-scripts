/*
File Name: ap-invoices-link-to-journal-and-sla.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##############################################################
-- AP INVOICE LINK THROUGH TO SLA TABLES - SUMMARY ACCOUNTING FIGURES - GL AND SLA
-- ##############################################################

		select aia.invoice_num
			 , aia.doc_sequence_value voucher
			 , aia.invoice_amount
			 , sum(gjl.accounted_dr) jnl_accounted_dr
			 , sum(gjl.accounted_cr) jnl_accounted_cr
			 , sum(gjl.entered_cr) jnl_entered_dr
			 , sum(gjl.entered_cr) jnl_entered_cr
			 , sum(xal.entered_dr) xla_entered_dr
			 , sum(xal.entered_cr) xla_entered_cr
			 , sum(xal.accounted_dr) xla_accounted_dr
			 , sum(xal.accounted_cr) xla_accounted_cr
		  from gl.gl_je_headers gjh 
		  join gl.gl_je_batches gjb on gjh.je_batch_id = gjb.je_batch_id
		  join gl.gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl.gl_code_combinations gcc on gjl.code_combination_id = gcc.code_combination_id
		  join gl.gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name
		  join gl.gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name
		  join applsys.fnd_user fu on gjh.created_by = fu.user_id
	 left join gl.gl_import_references gir on gjh.je_header_id = gir.je_header_id and gir.je_line_num = gjl.je_line_num
	 left join gl.gl_encumbrance_types gety on gjh.encumbrance_type_id = gety.encumbrance_type_id
	 left join xla.xla_ae_lines xal on gir.gl_sl_link_table = xal.gl_sl_link_table and gir.gl_sl_link_id = xal.gl_sl_link_id
	 left join xla.xla_ae_headers xah on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
	 left join xla.xla_events xe on xah.application_id = xe.application_id and xah.event_id = xe.event_id
	 left join xla.xla_transaction_entities xte on xe.application_id = xte.application_id and xe.entity_id = xte.entity_id
	 left join ap.ap_invoices_all aia on aia.invoice_id = xte.source_id_int_1
		 where 1 = 1
		   and xte.source_id_int_1 = 123456 -- this is the ap invoice ID
		   and 1 = 1
	  group by aia.invoice_num
			 , aia.invoice_amount
			 , aia.doc_sequence_value;
