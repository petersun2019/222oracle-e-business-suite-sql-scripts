/*
File Name:		ap-checks-all.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- AP CHECKS - QUERY 1
-- AP CHECKS - QUERY 2

*/

-- ##############################################################
-- AP CHECKS - QUERY 1
-- ##############################################################

		select aca.check_number check_number
			 , aca.creation_date check_created
			 , fu1.user_name check_created_by
			 , aca.amount check_amount
			 , aca.vendor_name supplier
			 , aca.vendor_site_code supplier_site
			 , aia.invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , aia.invoice_amount
			 , aia.creation_date inv_created
			 , to_char(aipa.accounting_date, 'DD-MON-YYYY') payment_accounting_date
			 , aipa.period_name payment_period
			 , fu2.user_name inv_created_by
			 , aia.last_update_date inv_updated
			 , fu3.user_name inv_updated_by
			 , aida.distribution_line_number dist_line
			 , aida.period_name
			 , aida.amount
			 , aida.creation_date dist_created
			 , fu4.user_name dist_created_by
			 , aida.last_update_date dist_updated
			 , fu5.user_name dist_updated_by
			 , aida.accrual_posted_flag
			 , aida.posted_flag
			 , aida.accounting_event_id
			 , to_char(aida.accounting_date, 'DD-MON-YYYY') distr_accounting_date
			 , '#############'
			 , to_char(aaea.accounting_date, 'DD-MM-YYYY') acct_entry_acct_date
			 , aaea.event_status_code
			 , aaea.event_status_code -- populated when invoice validated
			 , aaea.source_table
			 , aaea.creation_date event_created
			 , aaea.request_id
		  from ap_checks_all aca
		  join ap_invoice_payments_all aipa on aca.check_id = aipa.check_id
		  join ap_invoices_all aia on aia.invoice_id = aipa.invoice_id
		  join ap_invoice_distributions_all aida on aia.invoice_id = aida.invoice_id
		  join fnd_user fu1 on aca.created_by = fu1.user_id
		  join fnd_user fu2 on aia.created_by = fu2.user_id
		  join fnd_user fu3 on aia.last_updated_by = fu3.user_id
		  join fnd_user fu4 on aida.created_by = fu4.user_id
		  join fnd_user fu5 on aida.last_updated_by = fu5.user_id
		  join ap_accounting_events_all aaea on aaea.accounting_event_id = aida.accounting_event_id
		 where 1 = 1
		   and aca.check_number = 123456
		   -- and aca.creation_date > '01-JAN-2018'
		   and 1 = 1;

-- ##############################################################
-- AP CHECKS - QUERY 2
-- ##############################################################

		select aca.creation_date
			 , fu.user_name created_by
			 , apt.template_name ppr_template
			 , iapp.system_profile_code
			 , isppv.payment_format_code
			 , aca.last_update_date
			 , fu2.user_name updated_by
			 , aca.checkrun_name
			 , aisc.checkrun_name
			 , aca.vendor_name
			 , aca.bank_account_name
			 , aca.ce_bank_acct_use_id
			 , cba.bank_account_name cba_acct_name
			 , cba.bank_account_num cba_acct_num
			 , aca.amount
			 , aca.cleared_amount
			 , aca.check_number
			 , aca.status_lookup_code
			 , to_char(aca.check_date, 'DD-MM-YYYY') check_date
			 , to_char(aca.cleared_date, 'DD-MM-YYYY') cleared_date
			 , aca.payment_method_code
			 , iappt.payment_profile_name
		  from ap.ap_checks_all aca
		  join iby_acct_pmt_profiles_tl iappt on aca.payment_profile_id = iappt.payment_profile_id
		  join iby_acct_pmt_profiles_b iappb on iappt.payment_profile_id = iappb.payment_profile_id
		  join fnd_user fu on aca.created_by = fu.user_id
		  join fnd_user fu2 on aca.last_updated_by = fu2.user_id
	 left join ce_bank_accounts cba on cba.bank_account_id = aca.ce_bank_acct_use_id
	 left join ap_inv_selection_criteria_all aisc on aisc.checkrun_name = aca.checkrun_name
	 left join ap_payment_templates apt on apt.template_id = aisc.template_id
	 left join iby_acct_pmt_profiles_b iapp on apt.payment_profile_id = iapp.payment_profile_id
	 left join iby_sys_pmt_profiles_vl isppv on iappb.system_profile_code = isppv.system_profile_code
		 where 1 = 1
		   -- and aca.ce_bank_acct_use_id in (123456, 123457) 
		   -- and aca.ce_bank_acct_use_id not in (123456) 
		   and aca.creation_date > '01-SEP-2017' 
	  order by aca.creation_date desc;
