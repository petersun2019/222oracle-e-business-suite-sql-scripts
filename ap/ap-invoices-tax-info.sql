/*
File Name: ap-invoices-tax-info.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- SELF ASSESSED TAX LINES
-- TAX TABLE JOINED TO INVOICE TABLE
-- BASIC INVOICE DETAILS WITH LINES - INCLUDING TAX DATA

*/

-- ##################################################################
-- SELF ASSESSED TAX LINES
-- ##################################################################

		select * 
		  from zx_lines_summary_v tax
		 where 1 = 1
		   -- and tax.trx_number = '256618' 
		   -- and tax.trx_id = 322971
		   and tax.entity_code = 'AP_INVOICES'
		   and tax.event_class_code = 'STANDARD INVOICES'
		   and tax.self_assessed_flag = 'Y';

-- ##################################################################
-- TAX TABLE JOINED TO INVOICE TABLE
-- ##################################################################

		select distinct aia.invoice_id id
			 , aia.invoice_num num
			 , pha.segment1 po
			 , pha.authorization_status
			 , aia.creation_date
			 , aia.invoice_amount amt
			 , aia.invoice_type_lookup_code inv_type
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
			 , aia.payment_status_flag paid
			 , nvl2(aia.cancelled_amount, 'Y', 'N') cancelled
			 , aia.cancelled_date
			 , decode(apps.ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) validation_status_v1 -- http://m-burhan.blogspot.co.uk/2012/06/function-which-provide-ap-validation.html
			 , decode(apps.ap_invoices_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL', 'Fully Applied', 'UNAPPROVED' , 'Unvalidated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'APPROVED', 'Validated', 'NEVER APPROVED', 'Never Validated', 'CANCELLED', 'Cancelled', 'UNPAID', 'Unpaid', 'AVAILABLE', 'Available') validation_status_v2 -- https://community.oracle.com/thread/3573183
			 , apps.ap_invoices_pkg.get_posting_status(aia.invoice_id) accounted
			 , apps.ap_invoices_pkg.get_approval_status(aia.invoice_id, aia.invoice_amount, aia.payment_status_flag, aia.invoice_type_lookup_code) approval_status
			 , '#########'
			 , tax.*
		  from zx_lines_summary_v tax
		  join ap.ap_invoices_all aia on tax.trx_id = aia.invoice_id
		  join ap.ap_suppliers pv on aia.vendor_id = pv.vendor_id
		  join ap.ap_supplier_sites_all pvsa on aia.vendor_site_id = pvsa.vendor_site_id and pv.vendor_id = pvsa.vendor_id
		  join ap.ap_invoice_distributions_all aida on aia.invoice_id = aida.invoice_id
		  join po.po_distributions_all pda on aida.po_distribution_id = pda.po_distribution_id
		  join po.po_lines_all pla on pda.po_line_id = pla.po_line_id
		  join po.po_headers_all pha on pla.po_header_id = pha.po_header_id
		 where 1 = 1
		   and tax.trx_number = 'INV123456' 
		   and tax.entity_code = 'AP_INVOICES'
		   and tax.event_class_code = 'STANDARD INVOICES'
		   and tax.self_assessed_flag = 'Y';

-- ##################################################################
-- BASIC INVOICE DETAILS WITH LINES - INCLUDING TAX DATA
-- ##################################################################

		select aia.invoice_id id
			 , aia.invoice_num num
			 , aia.creation_date
			 , aia.cancelled_date
			 , aia.invoice_type_lookup_code inv_type
			 , decode(apps.ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) validation_status_v1 -- http://m-burhan.blogspot.co.uk/2012/06/function-which-provide-ap-validation.html
			 , apps.ap_invoices_pkg.get_posting_status(aia.invoice_id) accounted
			 , apps.ap_invoices_pkg.get_approval_status(aia.invoice_id, aia.invoice_amount, aia.payment_status_flag, aia.invoice_type_lookup_code) approval_status
			 , aia.payment_status_flag paid
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
			 , aia.invoice_amount
			 , aila.line_number
			 , aila.line_type_lookup_code
			 , aila.amount
			 , aila.original_amount
			 , aila.description
			 , aila.tax_classification_code
			 , aila.tax
			 , aila.tax_rate
			 , aila.tax_regime_code
			 , aila.tax_status_code
			 , aila.period_name
			 , zlv.tax_full_name
			 , zlv.tax_rate
			 , zlv.tax_rate_code
			 , zlv.line_amt
			 , zlv.taxable_amt
			 , zlv.tax_amt
			 , '##############'
			 , zlv.*
		  from ap.ap_invoices_all aia
		  join ap.ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id 
		  join ap.ap_terms_tl att on aia.terms_id = att.term_id 
		  join applsys.fnd_user fu on aia.created_by = fu.user_id
		  join apps.po_vendors pv on aia.vendor_id = pv.vendor_id
		  join apps.po_vendor_sites_all pvsa on aia.vendor_site_id = pvsa.vendor_site_id and pv.vendor_id = pvsa.vendor_id
		  join apps.zx_lines_v zlv on aia.invoice_id = zlv.trx_id and zlv.application_id = 200 and zlv.event_class_code = 'STANDARD INVOICES' and zlv.entity_code = 'AP_INVOICES' and zlv.trx_line_number = aila.line_number and zlv.trx_id = aia.invoice_id
		 where 1 = 1
		   and aia.invoice_num in ('INV123456')
		   and 1 = 1;
