/*
File Name: ap_accounting_entries_11i.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scriptsVersion:		11i



Queries:

-- 11i AP ACCOUNTING ENTRIES
-- TABLE DUMPS

*/

-- ##############################################################
-- 11i AP ACCOUNTING ENTRIES
-- ##############################################################

		select aia.invoice_id
			 , '#' || aia.invoice_num
			 , to_char(aia.invoice_date, 'DD-MM-YYYY') invoice_date
			 -- , pv.vendor_name
			 -- , pvsa.vendor_site_code site
			 , aela.entered_cr cr_value
			 -- , aela.entered_dr
			 , to_char(aeha.accounting_date, 'DD-MM-YYYY') ae_header_acct_date
			 , aeha.description ah_header_description
			 , aeha.creation_date ah_header_creation_date
			 , aeha.ae_category
			 -- , aaea.accounting_event_id
			 , to_char(aaea.accounting_date, 'DD-MM-YYYY') acct_entry_acct_date
			 , aaea.event_status_code
			 , aaea.event_status_code -- populated when invoice validated
			 , aela.ae_line_type_code
			 , aaea.source_table
			 , aaea.creation_date event_created
			 , aaea.request_id
			 , '################'
			 , aaea.*
		  from ap_invoices_all aia
		  join po_vendors pv on aia.vendor_id = pv.vendor_id
		  join po_vendor_sites_all pvsa on aia.vendor_site_id = pvsa.vendor_site_id and pv.vendor_id = pvsa.vendor_id
		  join ap_ae_lines_all aela on aela.source_id = aia.invoice_id and aela.reference5 = aia.invoice_num
		  join ap_ae_headers_all aeha on aeha.ae_header_id = aela.ae_header_id
		  join ap_accounting_events_all aaea on aaea.accounting_event_id = aeha.accounting_event_id
		 where aia.invoice_id = 123456;

-- ##################################################################
-- TABLE DUMPS
-- ##################################################################

select * from ap_invoice_payments_all where invoice_id = 123456;
select * from ap_ae_lines_all where source_id = 123456 and reference5 = 'OH/B004424';
select * from ap_ae_headers_all where ae_header_id = 123456;
select * from ap_accounting_events_all where accounting_event_id = 123456;
select * from ap_accounting_events_all where accounting_event_id = 123456;
select * from ap_invoice_distributions_all where invoice_id = 123456;

/*
https://sharingoracle.blogspot.com/2015/10/ap-invoice-technical-details-with.html

when invoice booked and saved
=============================
one row created in ap_invoices_all and its distribution lines created in ap_invoice_distributions_all

when invoice validated :
======================
ap_invoice_distributions_all.match_status_flag='A'
ap_invoice_distributions_all.accounting_event_id=not null(here 1370092)
one row created in ap_accounting_events_all with accounting_event_id=ap_invoice_distributions_all.accounting_event_id ap_accounting_events_all.event_status_code='CREATED' ap_accounting_events_all.source_table='AP_INVOICES'
ap_accounting_events_all.source_id=ap_invoice_distributions_all.invoice_id=
ap_invoice_all.invoice_id

when invoice accounted :
=====================
ap_invoice_distributions_all.accrual_posted_flag='Y'
ap_invoice_distributions_all.posted_flag='Y' ap_accounting_events_all.event_status_code='ACCOUNTED'
one row created in ap_ae_headers_all where ap_ae_headers_all. accounting_event_id=ap_accounting_events_all.accounting_event_id rows created in ap_ae_lines_all
where ap_ae_headers_all.ae_header_id=ap_ae_lines_all.ae_header_id as
below the number of rows generally created in ap_ae_lines_all counted as 1)
one row for invoice with ap_ae_lines_all.ae_line_type_code='LIABILITY'
ap_ae_lines_all.source_table='AP_INVOICES' ,ap_ae_lines_all.source_id=ap_invoices_all.invoice_id2)
other rows are created for the invoice distribution lines (one line per invoice distribution line).ap_ae_lines_all.ae_line_type_code='CHARGE',
source_table='AP_INVOICE_DISTRIBUTIONS',
ap_ae_lines_all.source_id=ap_invoice_distributions.invoice_id

when invoice approved :
========================
ap_invoices_all.wfapproval_status='MANUALLY APPROVED', initially it was 'REQUIRED'

when payment created
=====================
when payment created the one record created in ap_checks_all table.

when payment accounted
=============================
when payment document accounted then one row is created in ap_accounting_events_all table.
ap_invoice_payments_all.accounting_event_id=
ap_accounting_events_all.accounting_event_id
ap_accounting_events_all.event_status_code='ACCOUNTED'. andap_accounting_events_all.source_id=ap_invoice_payments_all.check_id.

after doing the payment (paid) of invoice with created payment document
=============================================================
ap_invoices_all.payment_status_flag='Y' before 'N'it creates the linking between ap_invoices_all and ap_checks_all by ap_invoice_payments_all.one row created in ap_invoice_payments_all with reference of invoice id.
ap_invoice_payments_all.accrual_posted_flag='Y'
ap_invoice_payments_all.cash_posted_flag='Y'
ap_invoice_payments_all.posted_flag='Y'and when get void the ap_invoice_payments_all.reversal_flag='Y' unless it is 'N'
when payment got accounted the one row created in ap_accounting_events_all with ap_accounting_events_all.source_id=ap_invoice_payments_all.check_id and ap_invoice_payments_all.source_table='AP_CHECKS'

after clearing check from cash management
=====================================
open payment document and create accounting for it, showing partial now.
after successfull accounting of the document:
one line is created in ap_payment_history_all with new accounting _event_id.
ap_payment_history_all.accounting_event_id=
ap_accounting_events_all.accounting_event_idone new line created in ap_accounting_events_all with event_type_code='PAYMENT CLEARING'and ap_invoice_payments_all.source_table='AP_CHECKS'
ap_accounting_events_all.source_id=ap_invoice_payments_all.check_id andap_payment_history_all.accounting_event_id=
ap_accounting_events_all.accounting_event_id
one row created in ap_ae_headers_all with new accounting_event_id and two rows in this case created in ap_ae_lines_all with ae_line_type_code='CASH CLEARING ' and 'CASH',source_table='AP_CHECKS'.

when posted in gl (gl_posting)
===============================
after running the request "payables transfer to general ledger".the ap_ae_lines_all.gl_sl_link_id populates.ap_ae_headers_all.gl_transfer_flag='Y'ap_ae_headers_all.
gl_transfer_run_id is not null ap_ae_headers_all.trial_balance_flag='Y'

*/