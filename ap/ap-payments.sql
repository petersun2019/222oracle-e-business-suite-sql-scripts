/*
File Name:		ap-payments.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- PAYMENT RUNS
-- PPR TEMPLATES, PAYMENT PROCESS PROFILES, PAYMENT INSTRUCTION FORMATS AND XML PUBLISHER TEMPLATES
-- PAYMENT RUNS - LINKED TO AP INVOICES - SHOWS WHICH INVOICES INCLUDED IN A PAYMENT RUN
-- INVOICE COUNT PER PAYMENT RUN
-- PAYMENT RUNS GROUPED BY PAYMENT PROFILES
-- PAYMENT DOCUMENTS
-- UNSELECTED INVOICES

*/

-- ##################################################################
-- PAYMENT RUNS
-- ##################################################################

		select aisc.checkrun_name
			 , aisc.creation_date
			 , aisc.org_id
			 , pv.vendor_name
			 , aisc.zero_amounts_allowed
			 , aisc.zero_invoices_allowed
			 , fu.user_name
			 , fu.email_address
			 , apt.template_name
			 , apt.creation_date template_created
			 , (select count(*) from ap_inv_selection_criteria_all aisc where apt.template_id = aisc.template_id and aisc.status = 'selected') ppr_count
			 , apt.description
			 , apt.payment_method_code
			 , cba.bank_account_name
			 , cba.bank_account_num
			 , cbv.bank_name
			 , cbbv.branch_number
			 , cbbv.bank_branch_name
			 , iappt.payment_profile_name payment_process_profile
			 , isppv.system_profile_description ppp_description
			 , isppv.outbound_pmt_file_directory ppp_out_directory
			 , isppv.outbound_pmt_file_extension ppp_extn
			 , isppv.outbound_pmt_file_prefix ppp_prefix
			 , ift.format_name payment_instruction_format
			 , flv_pif.meaning pif_type
			 , iet.extract_desc pif_data_extract
			 , xtv.template_name xml_template
			 , to_char(aisc.check_date, 'yyyy-mm-dd') check_date
			 , to_char(aisc.pay_thru_date, 'yyyy-mm-dd') pay_thru_date
			 , aisc.pay_group_option
			 -- , '#####################'
			 -- , aisc.*
		  from ap_payment_templates apt
		  join ce_bank_accounts cba on apt.bank_account_id = cba.bank_account_id
		  join ce_banks_v cbv on cba.bank_id = cbv.bank_party_id
		  join ce_bank_branches_v cbbv on cbbv.branch_party_id = cba.bank_branch_id
		  join iby_acct_pmt_profiles_b iapp on iapp.payment_profile_id = apt.payment_profile_id
		  join iby_acct_pmt_profiles_tl iappt on iappt.payment_profile_id = iapp.payment_profile_id
		  join iby_sys_pmt_profiles_vl isppv on isppv.system_profile_code = iapp.system_profile_code
		  join iby_formats_b ifb on ifb.format_code = isppv.payment_format_code
		  join iby_formats_tl ift on ifb.format_code = ift.format_code
	 left join xdo_templates_vl xtv on ifb.format_template_code = xtv.template_code
	 left join fnd_lookup_values_vl flv_pif on flv_pif.lookup_code = ifb.format_type_code and flv_pif.lookup_type = 'IBY_FORMAT_TYPES'
	 left join iby_extracts_b ieb on ieb.extract_id = ifb.extract_id
	 left join iby_extracts_tl iet on iet.extract_id = ieb.extract_id
		  join ap_inv_selection_criteria_all aisc on apt.template_id = aisc.template_id
	 left join ap_suppliers pv on pv.vendor_id = aisc.vendor_id
		  join fnd_user fu on fu.user_id = aisc.created_by
		 where 1 = 1
		   -- and aisc.creation_date > sysdate - 20
		   -- and aisc.vendor_id = 123456
		   -- and aisc.creation_date > '15-MAY-2021'
		   -- and aisca.org_id = 106
		   and apt.template_name = 'XXCUST_BACS'
		   -- and fu.user_name = 'SYSADMIN'
		   -- and lower(aisc.checkrun_name) like '%abc%'
		   -- and aisc.creation_date > '11-SEP-2020'
		   -- and aisc.creation_date > '01-OCT-2018'
		   -- and aisc.status = 'SELECTED'
		   and 1 = 1
	  order by aisc.creation_date desc;

-- ##################################################################
-- PPR TEMPLATES, PAYMENT PROCESS PROFILES, PAYMENT INSTRUCTION FORMATS AND XML PUBLISHER TEMPLATES
-- ##################################################################

/*
PPR TEMPLATES
PPR > PAYMENT PROCESS PROFILE (PPP)
CONTAINS THINGS LIKE OUTBOUND DIRECTORY, FILE PREFIX AND FILE EXTENSION
PPP > PAYMENT INSTRUCTION FORMAT (PIF)
LINKS TO TYPE AND DATA EXTRACT
LINKS TO XML PUBLISHER TEMPLATE, WHICH GENERATES THE OUTPUT FORMAT FOR THE PAYMENT FILE
*/

		select apt.template_name ppr_template
			 , apt.creation_date template_created
			 , fu.user_name template_created_by
			 , apt.last_update_date template_updated
			 , (select count(*) from ap_inv_selection_criteria_all aisc where apt.template_id = aisc.template_id and aisc.status = 'SELECTED') ppr_count
			 , apt.description
			 , apt.payment_method_code
			 , '#' || cba.bank_account_num bank_acct
			 , cbv.bank_name bank
			 , cba.bank_account_name bank_acct_name
			 , cbbv.branch_number branch
			 , cbbv.bank_branch_name
			 , cpd.payment_document_name payment_doc
			 , iappt.payment_profile_name payment_process_profile
			 , iappt.last_update_date
			 , apt.payment_exchange_rate_type xchng_rate
			 , isppv.system_profile_description ppp_description
			 , isppv.last_update_date
			 , isppv.outbound_pmt_file_directory ppp_out_directory
			 , isppv.outbound_pmt_file_extension ppp_extn
			 , isppv.outbound_pmt_file_prefix ppp_prefix
			 , ift.format_name payment_instruction_format
			 , ift.last_update_date
			 , flv_pif.meaning pif_type
			 , iet.extract_desc pif_data_extract
			 , xtv.template_name xml_template
			 , xtv.last_update_date
		  from ap_payment_templates apt
		  join fnd_user fu on apt.created_by = fu.user_id
		  join ce_bank_accounts cba on apt.bank_account_id = cba.bank_account_id
		  join ce_banks_v cbv on cba.bank_id = cbv.bank_party_id
		  join ce_bank_branches_v cbbv on cbbv.branch_party_id = cba.bank_branch_id
		  join iby_acct_pmt_profiles_b iapp on iapp.payment_profile_id = apt.payment_profile_id
		  join iby_acct_pmt_profiles_tl iappt on iappt.payment_profile_id = iapp.payment_profile_id
		  join iby_sys_pmt_profiles_vl isppv on isppv.system_profile_code = iapp.system_profile_code
		  join iby_formats_b ifb on ifb.format_code = isppv.payment_format_code
		  join iby_formats_tl ift on ifb.format_code = ift.format_code
	 left join ce_payment_documents cpd on cpd.payment_document_id = apt.payment_document_id
	 left join xdo_templates_vl xtv on ifb.format_template_code = xtv.template_code
	 left join fnd_lookup_values_vl flv_pif on flv_pif.lookup_code = ifb.format_type_code and flv_pif.lookup_type = 'IBY_FORMAT_TYPES'
	 left join iby_extracts_b ieb on ieb.extract_id = ifb.extract_id
	 left join iby_extracts_tl iet on iet.extract_id = ieb.extract_id
		 where 1 = 1
		   and apt.template_name = 'GATEWAY CHAPS / Faster Payment'
		   and 1 = 1;

-- ##################################################################
-- PAYMENT RUNS - LINKED TO AP INVOICES - SHOWS WHICH INVOICES INCLUDED IN A PAYMENT RUN
-- ##################################################################

		select aisca.checkrun_name
			 , to_char(aisca.check_date, 'DD-MON-YYYY') check_date
			 , aisca.creation_date
			 , fu.user_name
			 , to_char(aisca.pay_thru_date, 'DD-MON-YYYY') pay_thru_date
			 , aisca.status
			 , aisca.checkrun_id
			 , aisca.vendor_id
			 , apt.template_name
			 , iapp.system_profile_code
			 , aca.check_id
			 , aca.amount
			 , aca.bank_account_name
			 , aca.check_number
			 , aca.currency_code
			 , aca.vendor_name
			 , aca.remit_to_supplier_name
			 , aca.remit_to_supplier_site
			 , aca.payment_method_code
			 , aia.invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , aia.invoice_amount
			 , aia.invoice_type_lookup_code inv_type
			 , aia.source
			 , aia.description inv_description
			 , aia.pay_group_lookup_code
			 , aia.attribute3
			 , '##########'
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
			 , pvsa.vendor_site_code_alt
		  from apps.ap_inv_selection_criteria_all aisca
		  join apps.fnd_user fu on aisca.created_by = fu.user_id
	 left join apps.iby_acct_pmt_profiles_b iapp on iapp.payment_profile_id = aisca.payment_profile_id
	 left join apps.ap_payment_templates apt on apt.template_id = aisca.template_id
	 left join apps.ap_checks_all aca on aca.checkrun_id = aisca.checkrun_id
	 left join apps.ap_invoice_payments_all aipa on aipa.check_id = aca.check_id
	 left join apps.ap_invoices_all aia on aia.invoice_id = aipa.invoice_id
	 left join apps.ap_suppliers pv on aca.vendor_id = pv.vendor_id
	 left join apps.ap_supplier_sites_all pvsa on aca.vendor_site_id = pvsa.vendor_site_id
		 where 1 = 1
		   -- and aisca.creation_date > '24-JAN-2019'
		   -- and aisca.creation_date < '25-JAN-2019'
		   -- and aia.invoice_id = 123456
		   and aisca.checkrun_name = '28-03-22 BACS'
		   and 1 = 1
	  order by aisca.checkrun_id desc;

-- INVOICE COUNT PER PAYMENT RUN

		select aisca.checkrun_name
			 , count(distinct aia.invoice_id) inv_count
		  from apps.ap_inv_selection_criteria_all aisca
	 left join apps.ap_checks_all aca on aca.checkrun_id = aisca.checkrun_id
	 left join apps.ap_invoice_payments_all aipa on aipa.check_id = aca.check_id
	 left join apps.ap_invoices_all aia on aia.invoice_id = aipa.invoice_id
		 where 1 = 1
		   and aisca.checkrun_name = '28-03-22 BACS'
		   and 1 = 1
	  group by aisca.checkrun_name;

-- ##################################################################
-- PAYMENT RUNS GROUPED BY PAYMENT PROFILES
-- ##################################################################

		select iappt.payment_profile_name
			 , max(aisc.creation_date) last_used
			 , count(*) ct
		  from apps.ap_payment_templates apt
			 , apps.iby_acct_pmt_profiles_b iapp
			 , apps.ap_inv_selection_criteria_all aisc
			 , apps.iby_acct_pmt_profiles_tl iappt
			 , apps.iby_acct_pmt_profiles_b iappb
			 , apps.iby_sys_pmt_profiles_vl isppv
			 , apps.iby_formats_tl ift
		 where 1 = 1
		   and apt.payment_profile_id = iapp.payment_profile_id
		   and apt.template_id = aisc.template_id
		   and iapp.payment_profile_id = aisc.payment_profile_id
		   and aisc.payment_profile_id = iappt.payment_profile_id
		   and iappt.payment_profile_id = iappb.payment_profile_id
		   and iappb.system_profile_code = isppv.system_profile_code
		   and trunc(sysdate) <= trunc(nvl(apt.inactive_date,sysdate))
		   and trunc(sysdate) <= trunc(nvl(iapp.inactive_date,sysdate))
		   -- and aisc.creation_date between '01-JAN-2017' and '21-JAN-2017'
		   and aisc.status = 'SELECTED'
	  group by iappt.payment_profile_name;

-- ##################################################################
-- PAYMENT DOCUMENTS
-- ##################################################################

		select payment_document_name
			 , payment_document_id
			 , payment_instruction_id
			 , internal_bank_account_id
			 , cba.bank_account_name
			 , cba.bank_account_num
			 , cba.currency_code
			 , paper_stock_type
			 , attached_remittance_stub_flag
			 , number_of_lines_per_remit_stub
			 , number_of_setup_documents
			 , ce_payment_documents.format_code
			 , first_available_document_num
			 , last_available_document_number
			 , last_issued_document_number
			 , manual_payments_only_flag
			 , ce_payment_documents.attribute_category
			 , inactive_date
			 , decode(inactive_date, 'Y', 'N') status
			 , meaning paper_stock_type_meaning
			 , fmts.format_name 
		  from ce_payment_documents
			 , ce_lookups lookup
			 , iby_formats_vl fmts
			 , ce_bank_accounts cba
		 where lookup_type = 'CE_PAPER_STOCK_TYPES' 
		   and paper_stock_type = lookup.lookup_code 
		   and ce_payment_documents.format_code=fmts.format_code
		   and internal_bank_account_id = cba.bank_account_id;

-- ##################################################################
-- UNSELECTED INVOICES
-- ##################################################################

		select distinct apinv.org_id
			 , apinv.payment_status_flag
			 , apinv.last_update_date
			 , aps.segment1
			 , aps.vendor_name
			 , apsi.vendor_site_code
			 , aps.hold_all_payments_flag header_hold
			 , apsi.hold_all_payments_flag site_hold
			 , apinv.invoice_type_lookup_code
			 , apinv.invoice_num
			 , apinv.invoice_date
			 , apinv.invoice_amount
			 , apinv.invoice_currency_code
			 , apinv.payment_currency_code
			 , apinv.source
			 , apinv.description
			 , apinv.pay_group_lookup_code
			 , apinv.creation_date
			 , apinv.wfapproval_status
			 , apinv.payment_method_code
			 , appay.hold_flag "scheduled payment hold flag"
			 , appay.due_date
			 , appay.payment_method_code "scheduled payment pay method"
			 , decode(ap_invoices_pkg.get_approval_status(apinv.invoice_id, apinv.invoice_amount, apinv.payment_status_flag, apinv.invoice_type_lookup_code), 'FULL', 'Fully Applied', 'NEVER APPROVED', 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED', 'Cancelled', 'UNPAID', 'Unpaid', 'AVAILABLE', 'Available', 'UNAPPROVED', 'Unvalidated', 'APPROVED', 'Validated', 'PERMANENT', 'Permanent Prepayment') approval_status
			 , apsch.checkrun_id
			 , apus.dont_pay_reason_code
			 , apinv.creation_date
			 , appay.creation_date
			 , aps.creation_date
			 , apsi.creation_date
			 , apsch.creation_date
			 , apus.creation_date
		  from ap_invoices_all apinv
			 , ap_payment_schedules_all appay
			 , ap_suppliers aps
			 , ap_supplier_sites_all apsi
			 , ap_payment_schedules_all apsch
			 , ap_unselected_invoices_all apus
		 where 1 = 1
		   and apinv.invoice_id = appay.invoice_id
		   and apinv.vendor_id = aps.vendor_id
		   and apinv.payment_status_flag != 'Y'
		   and apinv.cancelled_date is null
		   and aps.vendor_id = apsi.vendor_id
		   and apsch.invoice_id = apinv.invoice_id
		   and apinv.invoice_id = apus.invoice_id(+)
		   and 1 = 1
		   and apinv.invoice_id in (123456);
		   and 1 = 1;
