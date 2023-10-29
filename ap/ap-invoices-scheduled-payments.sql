/*
File Name: ap-invoices-scheduled-payments.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- SELECTED / PAYMENT SCHEDULES / BANK ACCOUNTS
-- INVOICE - SCHEDULE PAYMENT HOLDS

*/

-- ##############################################################
-- SELECTED / PAYMENT SCHEDULES / BANK ACCOUNTS
-- IF NO BANK ACCOUNT ON PAYMENT SCHEDULE, CAN GET ERRORS / REJECTIONS IN PAYMENT RUN
-- ##############################################################

		select aia.invoice_id id
			 , aia.invoice_num num
			 , hou.short_code || ' (' || hou.name || ')' org
			 , aia.invoice_amount
			 , to_char(aia.invoice_date, 'DD-MON-YYYY') inv_date
			 , aia.creation_date
			 , aia.invoice_type_lookup_code inv_type
			 , pv.vendor_name supplier
			 , pv.creation_date supplier_created
			 , pv.segment1 supplier_num
			 , pvsa.vendor_site_code site
			 , pvsa.vendor_site_id
			 , pvsa.creation_date site_created
			 , (select count(*) from ap_selected_invoices_all where invoice_id = aia.invoice_id) selected
			 , aia.payment_status_flag paid
			 , nvl2(aia.cancelled_amount, 'Y', 'N') cancelled
			 , apsa.external_bank_account_id
			 , apsa.iby_hold_reason
			 , apsa.last_update_date
			 , apsa.last_updated_by
			 , ieba.bank_account_num
			 , ieba.bank_account_name
		  from ap.ap_invoices_all aia
	 left join ap.ap_batches_all aba on aia.batch_id = aba.batch_id
		  join applsys.fnd_user fu on aia.created_by = fu.user_id
		  join apps.po_vendors pv on aia.vendor_id = pv.vendor_id
		  join apps.po_vendor_sites_all pvsa on aia.vendor_site_id = pvsa.vendor_site_id and pv.vendor_id = pvsa.vendor_id
		  join apps.hr_operating_units hou on aia.org_id = hou.organization_id
	 left join ap_payment_schedules_all apsa on apsa.invoice_id = aia.invoice_id 
	 left join apps.iby_ext_bank_accounts ieba on ieba.ext_bank_account_id = apsa.external_bank_account_id
		 where 1 = 1
		   and 1 = 1
		   and aia.invoice_num = 'INV123456'
	  order by aia.invoice_id desc;

-- ##################################################################
-- INVOICE - SCHEDULE PAYMENT HOLDS
-- ##################################################################

		select aia.invoice_id id
			 , '#' || aia.invoice_num num
			 , aia.doc_sequence_value voucher
			 , aia.invoice_type_lookup_code inv_type
			 , aia.creation_date inv_created
			 , fu.user_name || ' (' || fu.email_address || ')' inv_created_by
			 , aia.last_update_date inv_updated
			 , to_char(aia.invoice_date, 'DD-MON-YYYY') invoice_date
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
			 , aia.invoice_amount
			 , aia.payment_status_flag paid
			 , decode(apps.ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) validation_status -- http://m-burhan.blogspot.co.uk/2012/06/function-which-provide-ap-validation.html
			 , apps.ap_invoices_pkg.get_posting_status(aia.invoice_id) accounted
			 , apps.ap_invoices_pkg.get_approval_status(aia.invoice_id, aia.invoice_amount, aia.payment_status_flag, aia.invoice_type_lookup_code) approval_status
			 , (select count(*) from ap.ap_holds_all ah where ah.invoice_id = aia.invoice_id and ah.release_lookup_code is null) invoice_hold_count
			 , '--- payment schedule ----'
			 , apsa.gross_amount
			 , apsa.amount_remaining
			 , apsa.creation_date
			 , to_char(apsa.due_date, 'DD-MON-YYYY') due_date
			 , ipmt.payment_method_name method
			 , apsa.iby_hold_reason
		  from ap.ap_invoices_all aia
		  join applsys.fnd_user fu on aia.created_by = fu.user_id
		  join applsys.fnd_user fu2 on aia.last_updated_by = fu2.user_id
		  join apps.po_vendors pv on aia.vendor_id = pv.vendor_id
		  join apps.po_vendor_sites_all pvsa on aia.vendor_site_id = pvsa.vendor_site_id and pv.vendor_id = pvsa.vendor_id 
	 left join ap.ap_payment_schedules_all apsa on apsa.invoice_id = aia.invoice_id
	 left join iby.iby_payment_methods_tl ipmt on ipmt.payment_method_code = apsa.payment_method_code
		 where 1 = 1
		   and apsa.hold_flag = 'Y'
		   and nvl2(aia.cancelled_amount, 'Y', 'N') = 'N'
		   and 1 = 1;
