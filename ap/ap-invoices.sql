/*
File Name: ap-invoices.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- BASIC INVOICE DETAILS
-- BASIC INVOICE DETAILS WITH LINES
-- INVOICES INCLUDING DISTRIBUTIONS AND PROJECTS
-- INVOICE DETAILS AND PAYMENT NUMBERS (AP_INVOICE_PAYMENT_HISTORY_V)
-- INVOICES, PURCHASE ORDERS AND PROJECTS
-- INVOICES, PURCHASE ORDERS, REQUISITIONS AND PROJECTS

*/

-- ##################################################################
-- BASIC INVOICE DETAILS
-- ##################################################################

		select aia.invoice_id id
			 , '#' || aia.invoice_num num -- put trailing "#" on otherwise when export to Excel invoice numbers starting with 0 e.g. "00012345" get the trailing zero values removed
			 , aia.description
			 , aia.invoice_type_lookup_code inv_type
			 , aia.source
			 , aia.org_id
			 , aia.invoice_amount amt
			 , aia.invoice_currency_code curr
			 , to_char(aia.invoice_date, 'DD-MON-YYYY') inv_date
			 , aia.creation_date created
			 , fu1.user_name created_by
			 , aia.last_update_date updated
			 , fu2.user_name updated_by
			 , aia.payment_status_flag paid
			 , nvl2(aia.cancelled_amount, 'Y', 'N') cancelled
			 , aia.cancelled_amount
			 , aia.exclusive_payment_flag
			 , to_char(aia.cancelled_date, 'DD-MON-YYYY') cancelled_date
			 , hou.name org_name
			 , aba.batch_id
			 , aba.batch_name
			 , pv.vendor_name supplier
			 , pv.vendor_id
			 , pv.creation_date supplier_created
			 , pv.segment1 sup_num
			 , pvsa.vendor_site_code site
			 , pvsa.vendor_site_id
			 , pvsa.creation_date site_created
			 , decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) val_status
			 , ap_invoices_pkg.get_posting_status(aia.invoice_id) posting_status
			 , ap_invoices_pkg.get_approval_status(aia.invoice_id, aia.invoice_amount, aia.payment_status_flag, aia.invoice_type_lookup_code) approval_status
		  from ap_invoices_all aia
		  join fnd_user fu1 on aia.created_by = fu1.user_id
		  join fnd_user fu2 on aia.last_updated_by = fu2.user_id
		  join po_vendors pv on aia.vendor_id = pv.vendor_id
		  join po_vendor_sites_all pvsa on aia.vendor_site_id = pvsa.vendor_site_id and pv.vendor_id = pvsa.vendor_id
		  join hr_operating_units hou on aia.org_id = hou.organization_id
	 left join ap_batches_all aba on aia.batch_id = aba.batch_id
		 where 1 = 1
		   and aia.invoice_num in ('123456')
		   and 1 = 1
	  order by aia.invoice_id desc;

-- ##################################################################
-- BASIC INVOICE DETAILS WITH LINES
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , aia.invoice_id id
			 , '#' || aia.invoice_num num
			 , aia.invoice_type_lookup_code inv_type
			 , aia.source
			 , aia.org_id
			 , aia.invoice_amount amt
			 , aia.original_invoice_amount
			 , aia.invoice_currency_code curr
			 , aia.last_update_date
			 , to_char(aia.invoice_date, 'DD-MON-YYYY') inv_date
			 , aia.creation_date created
			 , fu1.user_name created_by
			 , aia.last_update_date updated
			 , fu2.user_name updated_by
			 , aia.payment_status_flag paid
			 , nvl2(aia.cancelled_amount, 'Y', 'N') cancelled
			 , aia.cancelled_amount
			 , aia.cancelled_date
			 , to_char(aia.cancelled_date, 'DD-MON-YYYY') cancelled_date
			 , hou.name org_name
			 , aba.batch_id
			 , aba.batch_name
			 , pv.vendor_name supplier
			 , pv.vendor_id
			 , pv.creation_date supplier_created
			 , pv.segment1 sup_num
			 , pvsa.vendor_site_code site
			 , pvsa.vendor_site_id
			 , pvsa.creation_date site_created
			 , '############################'
			 , aila.corrected_inv_id
			 , aila.creation_date inv_line_created
			 , aila.last_update_date inv_line_updated
			 , aila.line_number
			 , aila.line_type_lookup_code
			 , aila.discarded_flag
			 , aila.amount
			 , aila.original_amount
			 , aila.tax_classification_code line_tax_code
			 , to_char(aila.accounting_date, 'DD-MON-YYYY') line_accounting_date
			 , aila.tax_rate
			 , '#############################'
			 , ppa.segment1 project
		  from ap_invoices_all aia
		  join ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id
		  join fnd_user fu1 on aia.created_by = fu1.user_id
		  join fnd_user fu2 on aia.last_updated_by = fu2.user_id
		  join po_vendors pv on aia.vendor_id = pv.vendor_id
		  join po_vendor_sites_all pvsa on aia.vendor_site_id = pvsa.vendor_site_id and pv.vendor_id = pvsa.vendor_id
		  join hr_operating_units hou on aia.org_id = hou.organization_id
	 left join ap_batches_all aba on aia.batch_id = aba.batch_id
	 left join pa_projects_all ppa on aila.project_id = ppa.project_id
		 where 1 = 1
		   and aia.invoice_id in (123456)
		   and 1 = 1
	  order by aia.invoice_id desc;

-- ##################################################################
-- INVOICES INCLUDING DISTRIBUTIONS AND PROJECTS
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , aia.invoice_id id
			 , '#' || aia.invoice_num num
			 , aia.invoice_type_lookup_code inv_type
			 , aia.source
			 , aia.org_id
			 , aia.invoice_amount amt
			 , aia.original_invoice_amount
			 , aia.invoice_currency_code curr
			 , aia.last_update_date
			 , to_char(aia.invoice_date, 'DD-MON-YYYY') inv_date
			 , aia.creation_date created
			 , fu1.user_name created_by
			 , aia.last_update_date updated
			 , fu2.user_name updated_by
			 , aia.payment_status_flag paid
			 , nvl2(aia.cancelled_amount, 'Y', 'N') cancelled
			 , aia.cancelled_amount
			 , aia.cancelled_date
			 , to_char(aia.cancelled_date, 'DD-MON-YYYY') cancelled_date
			 , hou.name org_name
			 , aba.batch_id
			 , aba.batch_name
			 , pv.vendor_name supplier
			 , pv.vendor_id
			 , pv.creation_date supplier_created
			 , pv.segment1 sup_num
			 , pvsa.vendor_site_code site
			 , pvsa.vendor_site_id
			 , pvsa.creation_date site_created
			 , '############################'
			 , aila.corrected_inv_id
			 , aila.creation_date inv_line_created
			 , aila.last_update_date inv_line_updated
			 , aila.line_number
			 , aila.line_type_lookup_code
			 , aila.discarded_flag
			 , aila.amount
			 , aila.original_amount
			 , aila.tax_classification_code line_tax_code
			 , to_char(aila.accounting_date, 'DD-MON-YYYY') line_accounting_date
			 , aila.tax_rate
			 , '#############################'
			 , ppa.segment1 project
			 , ppa.project_id
			 , pt.task_number task
			 , to_char(aida.expenditure_item_date, 'DD-MON-YYYY') item_date
			 , aida.expenditure_type exp_type
			 , aida.pa_addition_flag
			 , (select meaning from fnd_lookup_values_vl pa_add where lookup_type = 'PA_ADDITION_FLAG' and view_application_id = 275 and pa_add.lookup_code = aida.pa_addition_flag) pa_add_flag_meaning
			 , '##############################'
			 , aida.invoice_distribution_id
			 , gcc.concatenated_segments account
			 , aida.amount
			 , aida.base_amount
			 , aida.distribution_line_number dist_line
			 , to_char(aida.accounting_date, 'DD-MON-YYYY') dist_gl_date
			 , aida.line_type_lookup_code dist_type
			 , aida.period_name
			 , aida.match_status_flag
			 , aida.quantity_invoiced
			 , aida.encumbered_flag
			 , aida.accounting_event_id -- if populated means sla accounting events were created for the invoice
			 , aida.po_distribution_id
			 , aida.tax_code_id , aida.tax_recoverable_flag , aida.tax_recovery_override_flag , aida.tax_recovery_rate
			 , aida.summary_tax_line_id
			 -- , flv.meaning inv_dist_type
			 -- , zl.tax_rate_code po_tax_rate
		  from ap_invoices_all aia
		  join ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id
		  join ap_invoice_distributions_all aida on aia.invoice_id = aida.invoice_id
		  join fnd_user fu1 on aia.created_by = fu1.user_id
		  join fnd_user fu2 on aia.last_updated_by = fu2.user_id
		  join po_vendors pv on aia.vendor_id = pv.vendor_id
		  join po_vendor_sites_all pvsa on aia.vendor_site_id = pvsa.vendor_site_id and pv.vendor_id = pvsa.vendor_id
		  join hr_operating_units hou on aia.org_id = hou.organization_id
		  join gl_code_combinations_kfv gcc on aida.dist_code_combination_id = gcc.code_combination_id
		  join hr_operating_units hou on aia.org_id = hou.organization_id
	 left join ap_batches_all aba on aia.batch_id = aba.batch_id
	 left join pa.pa_projects_all ppa on aida.project_id = ppa.project_id
	 left join pa.pa_tasks pt on aida.task_id = pt.task_id
	 left join pa.pa_expenditure_items_all peia on peia.document_header_id = aia.invoice_id and peia.document_distribution_id = aida.invoice_distribution_id
	 -- left join zx.zx_lines zl on pha.po_header_id = zl.trx_id and zl.entity_code = 'PURCHASE_ORDER' and zl.event_class_code = 'PO_PA'
	 -- left join applsys.fnd_lookup_values_vl flv on flv.lookup_code = aida.line_type_lookup_code and flv.lookup_type = 'INVOICE DISTRIBUTION TYPE' and flv.view_application_id = 200
		 where 1 = 1
		   and aia.invoice_id in (123456)
		   and 1 = 1
	  order by aia.invoice_id desc;

-- ##################################################################
-- INVOICE DETAILS AND PAYMENT NUMBERS (AP_INVOICE_PAYMENT_HISTORY_V)
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , aia.invoice_id
			 , aia.invoice_num
			 , aia.doc_sequence_value voucher
			 , pv.vendor_name supplier
			 , pv.segment1 supplier_num
			 , decode(aipa.invoice_payment_type, 'PREPAY', aia.invoice_num, aca.check_number) document_number
			 , aca.doc_sequence_value
			 , aca.creation_date
			 , aipa.amount
			 , aipa.accounting_date
			 , aipa.period_name
			 , aipa.posted_flag
			 , aipa.check_id
			 , aipa.creation_date
		  from ap.ap_invoice_payments_all aipa
		  join ap.ap_invoices_all aia on aipa.invoice_id = aia.invoice_id
		  join ap.ap_checks_all aca on aipa.check_id = aca.check_id
		  join ap.ap_suppliers pv on aia.vendor_id = pv.vendor_id
		 where 1 = 1
		   and aia.invoice_id = 123456
		   and 1 = 1;

-- ##################################################################
-- INVOICES, PURCHASE ORDERS AND PROJECTS
-- ##################################################################

-- use distinct to get simple list of invoices and the pos they are matched to

		select distinct sys_context('USERENV','DB_NAME') instance
			 , aia.invoice_id inv_id
			 , aia.invoice_num inv_num
			 , aia.invoice_amount
			 , ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code) dd
			 , decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) val_status
			 , ap_invoices_pkg.get_posting_status(aia.invoice_id) posting_status
			 , ap_invoices_pkg.get_approval_status(aia.invoice_id, aia.invoice_amount, aia.payment_status_flag, aia.invoice_type_lookup_code) approval_status
			 , hou.short_code org
			 , to_char(aia.invoice_date, 'DD-MON-YYYY') inv_date
			 , to_char(aia.gl_date, 'DD-MON-YYYY') gl_date
			 , aia.creation_date invoice_created
			 , pv.vendor_name supplier
			 , pha.segment1 po
			 , pha.creation_date po_created
			 , pha.currency_code
			 , ppa.segment1 project
			 , ppa.project_id
			 , pt.task_number task
		  from ap.ap_invoices_all aia
	 left join ap.ap_invoice_lines_all aila on aila.invoice_id = aia.invoice_id
	 left join ap.ap_invoice_distributions_all aida on aia.invoice_id = aida.invoice_id
	 left join applsys.fnd_user fu on aia.created_by = fu.user_id
	 left join ap.ap_suppliers pv on aia.vendor_id = pv.vendor_id
	 left join ap.ap_supplier_sites_all pvsa on aia.vendor_site_id = pvsa.vendor_site_id and pv.vendor_id = pvsa.vendor_id
	 left join apps.hr_operating_units hou on aia.org_id = hou.organization_id
	 left join po.po_distributions_all pda on aida.po_distribution_id = pda.po_distribution_id
	 left join po.po_lines_all pla on pda. po_line_id = pla.po_line_id
	 left join po.po_headers_all pha on pha.po_header_id = pla.po_header_id
	 left join pa_projects_all ppa on ppa.project_id = aida.project_id
	 left join pa_tasks pt on pt.task_id = aida.task_id
		 where 1 = 1
		   and pha.segment1 = 'PO123456'
		   -- and aia.invoice_id = 123456
		   and 1 = 1;

-- ##################################################################
-- INVOICES, PURCHASE ORDERS, REQUISITIONS AND PROJECTS
-- ##################################################################

		select distinct '#' || aia.invoice_id id
			 , '#' || aia.invoice_num invoice_num
			 , aia.invoice_amount amt
			 , to_char(aia.invoice_date, 'DD-MON-YYYY') invoice_date
			 , flv.meaning hold
			 , to_char(ah.creation_date, 'yyyy-mm-dd HH24:MM') hold_created
			 , pha.segment1 po
			 , pv.vendor_name
			 , prha.requisition_number req
			 , prha.created_by req_created_by
			 , prha.creation_date req_created
			 , ppa.segment1 project
			 , ppa.project_id
			 , pt.task_number task
		  from ap_invoices_all aia
		  join ap_holds_all ah on aia.invoice_id = ah.invoice_id
		  join fnd_lookup_values_vl flv on flv.lookup_code = ah.hold_lookup_code and flv.lookup_type = 'HOLD CODE' and flv.view_application_id = 200
		  join ap_invoice_distributions_all aida on aia.invoice_id = aida.invoice_id
		  join po_distributions_all pda on pda.po_distribution_id = aida.po_distribution_id
		  join po_headers_all pha on pda.po_header_id = pha.po_header_id
		  join po_lines_all pla on pha.po_header_id = pla.po_header_id and pla.po_line_id = pda.po_line_id
		  join poz_suppliers_v pv on pha.vendor_id = pv.vendor_id
		  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id
		  join por_requisition_lines_all prla on prla.po_line_id = pla.po_line_id
		  join por_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
	 left join pa_projects_all ppa on ppa.project_id = aida.project_id
	 left join pa_tasks pt on pt.task_id = aida.task_id
		 where 1 = 1
		   and pha.segment1 = 'PO123456'
		   -- and aia.invoice_id = 123456
		   and 1 = 1
	  order by to_char(ah.creation_date, 'yyyy-mm-dd HH24:MM') desc;
