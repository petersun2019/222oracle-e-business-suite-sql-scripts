/*
File Name:		ar-transactions.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- TRANSACTIONS - BASIC 1
-- TRANSACTIONS - BASIC 2 - WITH APPLICATIONS
-- CREDIT MEMOS ON INVOICE EXCEPTION REPORT DUE TO MISSING PAYMENT SCHEDULES
-- TRANSACTION HEADERS - VERSION 1
-- TRANSACTION HEADERS - VERSION 2
-- TRANSACTION HEADERS - VERSION 3
-- TRANSACTION HEADERS - VERSION 4 - INCLUDES PROJECTS
-- TRANSACTIONS PLUS LINES - VERSION 1
-- TRANSACTIONS PLUS LINES - VERSION 2
-- TRANSACTIONS PLUS DISTRIBUTIONS
-- SOURCE SUMMARY
-- TRANSACTIONS WHICH DO NOT APPEAR IN THE AR ACCOUNT DETAILS FORM
-- RECEIPTS, CUSTOMERS, TRANSACTIONS, APPLICATIONS

*/

-- ##################################################################
-- TRANSACTIONS - BASIC 1
-- ##################################################################

		select rcta.trx_number
			 , haou.name org 
			 , rcta.org_id
			 , rcta.customer_trx_id trx_id
			 , rctta.name trx_type
			 , rtt.name payment_term
			 , (select sum(unit_selling_price) from ar.ra_customer_trx_lines_all rctla where rcta.customer_trx_id = rctla.customer_trx_id) trx_value
			 , to_char(rcta.creation_date, 'DD-MON-YYYY HH24:MI:SS') created
			 , to_char(rcta.trx_date, 'DD-MON-YYYY') trx_date
			 , to_char(rcta.last_update_date, 'DD-MON-YYYY') updated
			 , rcta.complete_flag complete
			 , hp.party_name
			 , hca.account_number act_no
			 , fu.user_name
			 , '#################'
			 , rcta.*
		  from ar.ra_customer_trx_all rcta
		  join ar.hz_cust_accounts hca on rcta.bill_to_customer_id = hca.cust_account_id
		  join ar.hz_parties hp on hp.party_id = hca.party_id
		  join hr.hr_all_organization_units haou on rcta.org_id = haou.organization_id
		  join ar.ra_cust_trx_types_all rctta on rcta.cust_trx_type_id = rctta.cust_trx_type_id and rcta.org_id = rctta.org_id
		  join applsys.fnd_user fu on rcta.created_by = fu.user_id
	 left join ra_terms_tl rtt on rcta.term_id = rtt.term_id and rtt.language = userenv('lang')
		 where 1 = 1
		   and rcta.trx_number = '123456'
		   -- and rcta.creation_date > '20-MAR-2022'
		   -- and hca.account_number = '123456'
		   and 1 = 1
	  order by rcta.creation_date desc;

-- ##################################################################
-- TRANSACTIONS - BASIC 2 - WITH APPLICATIONS
-- ##################################################################

		select rcta.trx_number
			 , haou.name org 
			 , rcta.org_id
			 , rcta.customer_trx_id trx_id
			 , rctta.name trx_type
			 , rtt.name payment_term
			 , (select sum(unit_selling_price) from ar.ra_customer_trx_lines_all rctla where rcta.customer_trx_id = rctla.customer_trx_id) trx_value
			 , to_char(rcta.creation_date, 'DD-MON-YYYY HH24:MI:SS') created
			 , to_char(rcta.trx_date, 'DD-MON-YYYY') trx_date
			 , to_char(rcta.last_update_date, 'DD-MON-YYYY') updated
			 , rcta.complete_flag complete
			 , hp.party_name
			 , hca.account_number act_no
			 , fu.user_name
			 , rcta_appl.trx_number applied_trx
			 , rcta_appl.customer_trx_id applied_trx_id
			 , hp2.party_name applied_party_name
			 , hca2.account_number applied_account_number
		  from ar.ra_customer_trx_all rcta
		  join ar.hz_cust_accounts hca on rcta.bill_to_customer_id = hca.cust_account_id
		  join ar.hz_parties hp on hp.party_id = hca.party_id
		  join hr.hr_all_organization_units haou on rcta.org_id = haou.organization_id
		  join ar.ra_cust_trx_types_all rctta on rcta.cust_trx_type_id = rctta.cust_trx_type_id and rcta.org_id = rctta.org_id
		  join applsys.fnd_user fu on rcta.created_by = fu.user_id
	 left join ra_terms_tl rtt on rcta.term_id = rtt.term_id and rtt.language = userenv('lang')
	 left join ar.ar_payment_schedules_all apsa on apsa.customer_trx_id = rcta.customer_trx_id
	 left join ar.ar_receivable_applications_all araa on araa.payment_schedule_id = apsa.payment_schedule_id
	 left join ar.ra_customer_trx_all rcta_appl on rcta_appl.customer_trx_id = araa.applied_customer_trx_id
	 left join ar.hz_cust_accounts hca2 on rcta_appl.bill_to_customer_id = hca2.cust_account_id
	 left join ar.hz_parties hp2 on hp2.party_id = hca2.party_id
		 where 1 = 1
		   and rcta.trx_number = '123456'
		   -- and rcta.creation_date > '20-MAR-2022'
		   -- and hca.account_number = '123456'
		   and 1 = 1
	  order by rcta.creation_date desc;

-- ##################################################################
-- CREDIT MEMOS ON INVOICE EXCEPTION REPORT DUE TO MISSING PAYMENT SCHEDULES
-- ##################################################################

/*
AR_S_00003 TRANSACTIONS WORKBENCH ISSUE: R12.1.1: TRANSACTION MISSING IN PAYMENT SCHEDULE (DOC ID 2044211.1)
*/

		select ct.customer_trx_id
			 , ct.trx_number
			 , haou.name org 
			 , haou.short_code
			 , fu.user_name
			 , ct.org_id
			 , ctt.type
			 , ctt.accounting_affect_flag
			 , ct.previous_customer_trx_id
			 , ct.complete_flag complete
			 , (select sum(unit_selling_price) from ar.ra_customer_trx_lines_all rctla where ct.customer_trx_id = rctla.customer_trx_id) trx_value
			 , to_char(ct.creation_date, 'DD-MON-YYYY HH24:MI:SS') creation_date
			 , to_char(ct.trx_date, 'DD-MON-YYYY') transaction_date
			 , to_char(ct.last_update_date, 'DD-MON-YYYY') last_update_date
			 , hp.party_name
			 , hca.account_number act_no
			 , hca.account_name
			 , hca.cust_account_id
		  from ra_customer_trx_all ct
	 left join ra_cust_trx_types_all ctt on ct.cust_trx_type_id = ctt.cust_trx_type_id
		  join hz_cust_accounts hca on ct.bill_to_customer_id = hca.cust_account_id
		  join hz_parties hp on hp.party_id = hca.party_id
		  join hr_operating_units haou on ct.org_id = haou.organization_id
		  join fnd_user fu on ct.created_by = fu.user_id
		 where 1 = 1
		   -- and ctt.type = 'CM'
		   -- and ctt.accounting_affect_flag = 'Y'
		   -- and ct.previous_customer_trx_id is not null
		   -- and ct.complete_flag = 'Y'
		   -- and ct.customer_trx_id in (123456,123457,123458)
		   -- and ct.trx_number in ('123456')
		   -- and haou.short_code = 'MY_ORG'
		   -- and ct.creation_date > '01-JAN-2022'
		   and (select count(*) from ar_payment_schedules_all ps where ps.customer_trx_id = ct.customer_trx_id) = '0'
		   and 1 = 1;

-- ##################################################################
-- TRANSACTION HEADERS - VERSION 1
-- ##################################################################

		select rcta.trx_number
			 , rcta.customer_trx_id
			 , (select sum(extended_amount) from ar.ra_customer_trx_lines_all rctla where rcta.customer_trx_id = rctla.customer_trx_id) tx_value
			 , (select sum(amount_due_remaining) from ar.ar_payment_schedules_all apsa where apsa.customer_trx_id = rcta.customer_trx_id) amt_outstanding
			 , rcta.complete_flag complete
			 , hp.party_name
			 , hca.account_number act_no
			 , rcta.trx_date
			 , rcta.creation_date
			 , rcta.last_update_date
			 , rcta.invoice_currency_code
			 , to_char(arpt_sql_func_util.get_first_real_due_date (rcta.customer_trx_id, rcta.term_id, rcta.trx_date), 'DD-MON-YYYY') due_date
		  from ar.ra_customer_trx_all rcta
		  join ar.hz_cust_accounts hca on rcta.bill_to_customer_id = hca.cust_account_id
		  join ar.hz_parties hp on hp.party_id = hca.party_id
		 where 1 = 1
		   and rcta.trx_number = '123456'
		   -- and rcta.customer_trx_id in (123456)
		   -- and rcta.creation_date > '01-NOV-2017'
		   and 1 = 1;

-- ##################################################################
-- TRANSACTION HEADERS - VERSION 2
-- ##################################################################

		select distinct rcta.trx_number
			 , rcta.customer_trx_id trx_id
			 , rcta.printing_count
			 , rcta.printing_last_printed
			 , rcta.printing_original_date 
			 , rctta.name trx_type
			 , (select sum(unit_selling_price) from ar.ra_customer_trx_lines_all rctla where rcta.customer_trx_id = rctla.customer_trx_id) trx_value
			 -- , (select sum(line_recoverable) from ar.ra_customer_trx_lines_all rctla where rcta.customer_trx_id = rctla.customer_trx_id) line_recoverable
			 -- , (select sum(tax_recoverable) from ar.ra_customer_trx_lines_all rctla where rcta.customer_trx_id = rctla.customer_trx_id) tax_recoverable
			 , (select sum(amount_due_remaining) from ar.ar_payment_schedules_all apsa where apsa.customer_trx_id = rcta.customer_trx_id) amt_outstanding
			 -- , (select to_char(max(due_date), 'DD-MON-YYYY') from ar.ar_payment_schedules_all apsa where apsa.customer_trx_id = rcta.customer_trx_id) due_date
			 -- , arpt_sql_func_util.get_first_real_due_date (rcta.customer_trx_id, rcta.term_id, rcta.trx_date) due_date -- need apps to access this - only seems to work with toad, not sql developer
			 , rcta.creation_date
			 , to_char(rcta.trx_date, 'DD-MON-YYYY') transaction_date
			 , to_char(rcta.last_update_date, 'DD-MON-YYYY') last_update_date
			 , rcta.complete_flag complete
			 , rtt.name payment_term
			 , hp.party_name
			 , hca.account_number act_no
			 , rcta.invoice_currency_code
			 , haou.name org
			 , fu.user_name
			 , jrs.name salesperson
		  from ar.ra_customer_trx_all rcta
			 , ar.hz_cust_accounts hca
			 , ar.hz_parties hp
			 , ar.ra_terms_tl rtt
			 , hr.hr_all_organization_units haou
			 , ar.ra_cust_trx_types_all rctta
			 , applsys.fnd_user fu
			 , jtf.jtf_rs_salesreps jrs
		 where rcta.bill_to_customer_id = hca.cust_account_id
		   and hp.party_id = hca.party_id
		   and rcta.org_id = haou.organization_id
		   and rcta.term_id = rtt.term_id(+) and rtt.language = userenv('lang')
		   and rcta.cust_trx_type_id = rctta.cust_trx_type_id 
		   and rcta.org_id = rctta.org_id
		   and rcta.created_by = fu.user_id
		   and rcta.primary_salesrep_id = jrs.salesrep_id(+)
		   and rcta.trx_number in ('123456')
		   -- and rcta.customer_trx_id in (123456)
		   -- and haou.name = 'SYSADMIN'
		   -- and hca.account_number in ('123456')
		   -- and (select sum(unit_selling_price) from ar.ra_customer_trx_lines_all rctla where rcta.customer_trx_id = rctla.customer_trx_id) = 26.38
		   -- and rcta.creation_date > '01-NOV-2019'
		   -- and rcta.creation_date < '04-NOV-2019'
		   and 1 = 1
	  order by rcta.creation_date desc;

-- ##################################################################
-- TRANSACTION HEADERS - VERSION 3
-- ##################################################################

		select rcta.trx_number
			 , rcta.customer_trx_id
			 , rcta.complete_flag complete
			 , fu1.user_name
			 , fu1.description
			 , fu1.email_address
			 -- , rcta.request_id
			 -- , hp.attribute2 crris_num
			 , '## SOURCE ##' 
			 , rbsa.name
			 , rbsa.description
			 , '## STATS ##' 
			 , fu1.description created_by
			 , fu2.description updated_by 
			 , '## ACCOUNT ##'
			 , hp.party_name
			 , hca.account_number act_no
			 , hps.party_site_number site_num
			 , rcta.org_id
			 , '## DATES ##'
			 , to_char(rcta.trx_date, 'DD-MON-YYYY') trx_date
			 , rcta.creation_date
			 , rcta.last_update_date
			 , '## PRINT ##'
			 , rcta.printing_original_date print_first
			 , rcta.printing_last_printed print_last
			 , '## ADDRESS ##'
			 , hcsua.location
			 , hl.address1
			 , hl.address2
			 , hl.address3
			 , hl.address4
			 , hl.city
			 , hl.state
			 , hl.postal_code
		  from ar.ra_customer_trx_all rcta
			 , ar.hz_cust_accounts hca
			 , ar.hz_parties hp
			 , ar.hz_party_sites hps
			 , ar.hz_cust_acct_sites_all hcasa
			 , ar.hz_cust_site_uses_all hcsua
			 , ar.hz_locations hl
			 , applsys.fnd_user fu1
			 , applsys.fnd_user fu2
			 , ar.ra_batch_sources_all rbsa
		 where rcta.bill_to_customer_id = hca.cust_account_id
		   and hp.party_id = hca.party_id
		   and hp.party_id = hps.party_id
		   and hcasa.party_site_id = hps.party_site_id
		   and hca.cust_account_id = hcasa.cust_account_id
		   and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
		   and rcta.created_by = fu1.user_id
		   and rcta.last_updated_by = fu2.user_id
		   and hcsua.site_use_id = rcta.bill_to_site_use_id
		   and hps.location_id = hl.location_id
		   and rcta.batch_source_id = rbsa.batch_source_id(+)
		   -- and rcta.customer_trx_id = 123456
		   -- and rcta.trx_number = '123456'
		   -- and (select sum(amount_due_remaining) from ar.ar_payment_schedules_all apsa where apsa.customer_trx_id = rcta.customer_trx_id and apsa.amount_due_remaining > 0) > 0
		   -- and hp.party_name like 'M%'
		   -- and rcta.invoice_currency_code = 'GBP'
		   -- and rbsa.name = 'PROJECTS INVOICES'
		   and rcta.creation_date > '20-JUL-2020'
		   -- and rcta.customer_trx_id in (2472983,2471171)
		   and 1 = 1;

-- ##################################################################
-- TRANSACTION HEADERS - VERSION 4 - INCLUDES PROJECTS
-- ##################################################################

		select '------ TRANSACTION HEADER -----' header
			 , rbsa.name source
			 , rcta.trx_number "number"
			 , rcta.customer_trx_id trx_id
			 , al_trx_type.meaning class
			 , rctta.name type
			 , xlolv.legal_entity_name legal_entity
			 , to_char(rcta.trx_date, 'DD-MON-YYYY') trx_date
			 , to_char(rctlgda.gl_date, 'DD-MON-YYYY') gl_date
			 , rcta.invoice_currency_code curr
			 , rcta.doc_sequence_value doc_num
			 , rcta.interface_header_context context_value
			 , rcta.complete_flag complete
			 , rcta.term_id
			 , rtt.name payment_term
			 , arpt_sql_func_util.get_first_real_due_date (rcta.customer_trx_id, rcta.term_id, rcta.trx_date) due_date -- need apps to access this
			 , (select sum(unit_selling_price) from ar.ra_customer_trx_lines_all rctla where rcta.customer_trx_id = rctla.customer_trx_id) trx_value
			 , (select sum(amount_due_remaining) from ar.ar_payment_schedules_all apsa where apsa.customer_trx_id = rcta.customer_trx_id) amt_outstanding
			 , '------ SETUP INFO -----'
			 , rcta.creation_date
			 , fu.user_name created_by
			 , rcta.last_update_date
			 , fu2.user_name updated_by
			 , '------ MORE TAB -----'
			 , haou.name operating_unit
			 , al_trx_print.meaning print_option
			 , rcta.printing_original_date print_date
			 , al_trx_status.meaning status
			 , rcta.purchase_order
			 , rcta.special_instructions
			 , rcta.comments
			 , '------ NOTES TAB -----'
			 , an.creation_date note_date
			 , al_note_type.meaning note_type
			 , an.text memo
			 , '------ REFERENCE INFO TAB -----' ref
			 , al_reason.meaning reason
			 , rcta.customer_reference
			 , rcta.customer_reference_date
			 , rcta_prev.trx_number orig_transaction
			 , rcta_prev.creation_date orig_created
			 , rcta_prev.customer_trx_id orig_trx_id
			 , rtt2.name orig_payment_term
			 , al_trx_type_prev.meaning orig_class
			 , '------ BILL TO CUSTOMER -----'
			 , hp_bill.party_name bill_cust
			 , hca_bill.account_number bill_acct
			 , hca_bill.customer_class_code bill_cust_class
			 , acpcvb.profile_class_description bill_profile_class
			 , hp_bill.tax_reference ship_tax_ref
			 , '------ SHIP TO CUSTOMER -----'
			 , hp_ship.party_name ship_cust
			 , hca_ship.account_number ship_acct
			 , hca_ship.customer_class_code ship_cust_class
			 , acpcvs.profile_class_description ship_profile_class
			 , hp_ship.tax_reference bill_tax_ref
			 , '------ PROJECT --------'
			 , ppa.segment1 project
			 , ppa.distribution_rule
			 , pdia.draft_invoice_num
			 , pdia.draft_invoice_num_credited
			 , '------ BATCH -----'
			 , rba.name batch_name
			 , rba.batch_date
			 , rba.gl_date batch_gl_date
			 , rba.type batch_type
			 , rba.control_count batch_count
			 , rba.control_amount batch_control_amt
			 , rba.request_id
			 , rbsa.name batch_source
			 , rbsa.batch_source_id
		  from ar.ra_customer_trx_all rcta
	 left join ar.ra_cust_trx_line_gl_dist_all rctlgda on rcta.customer_trx_id = rctlgda.customer_trx_id and rctlgda.latest_rec_flag = 'Y' 
	 left join apps.xle_le_ou_ledger_v xlolv on xlolv.operating_unit_id = rcta.legal_entity_id
	 left join ar.ra_cust_trx_types_all rctta on rcta.cust_trx_type_id = rctta.cust_trx_type_id and rcta.org_id = rctta.org_id
	 left join apps.ar_lookups al_trx_type on rctta.type = al_trx_type.lookup_code and al_trx_type.lookup_type = 'INV/CM/ADJ'
	 left join applsys.fnd_user fu on rcta.created_by = fu.user_id
	 left join applsys.fnd_user fu2 on rcta.last_updated_by = fu2.user_id
	 left join hr.hr_all_organization_units haou on rcta.org_id = haou.organization_id
	 left join ar.hz_cust_accounts hca_bill on rcta.bill_to_customer_id = hca_bill.cust_account_id
	 left join ar.hz_parties hp_bill on hp_bill.party_id = hca_bill.party_id
	 left join apps.ar_customer_profile_classes_v acpcvb on hca_bill.customer_class_code = acpcvb.profile_class_name
	 left join ar.hz_cust_accounts hca_ship on rcta.ship_to_customer_id = hca_ship.cust_account_id
	 left join ar.hz_parties hp_ship on hp_ship.party_id = hca_ship.party_id
	 left join apps.ar_customer_profile_classes_v acpcvs on hca_ship.customer_class_code = acpcvs.profile_class_name
	 left join ar.ar_notes an on rcta.customer_trx_id = an.customer_trx_id
	 left join ar.ra_customer_trx_all rcta_prev on rcta.previous_customer_trx_id = rcta_prev.customer_trx_id
	 left join ar.ra_cust_trx_types_all rctta_prev on rcta_prev.cust_trx_type_id = rctta_prev.cust_trx_type_id and rcta_prev.org_id = rctta.org_id
	 left join apps.ar_lookups al_trx_type_prev on rctta_prev.type = al_trx_type_prev.lookup_code and al_trx_type_prev.lookup_type = 'INV/CM/ADJ'
	 left join ar.ra_batches_all rba on rcta.batch_id = rba.batch_id
	 left join ar.ra_batch_sources_all rbsa on rcta.batch_source_id = rbsa.batch_source_id and rcta.org_id = rbsa.org_id
	 left join ar.ra_terms_tl rtt on rcta.term_id = rtt.term_id and rtt.language = userenv('lang')
	 left join ar.ra_terms_tl rtt2 on rcta_prev.term_id = rtt2.term_id and rtt2.language = userenv('lang')
	 left join pa.pa_draft_invoices_all pdia on pdia.ra_invoice_number = rcta.trx_number
	 left join pa.pa_projects_all ppa on pdia.project_id = ppa.project_id
	 left join apps.ar_lookups al_reason on rcta.reason_code = al_reason.lookup_code and al_reason.lookup_type = 'CREDIT_MEMO_REASON'
	 left join apps.ar_lookups al_trx_status on rcta.status_trx = al_trx_status.lookup_code and al_trx_status.lookup_type = 'INVOICE_TRX_STATUS'
	 left join apps.ar_lookups al_trx_print on rcta.printing_option = al_trx_print.lookup_code and al_trx_print.lookup_type = 'INVOICE_PRINT_OPTIONS'
	 left join apps.ar_lookups al_note_type on an.note_type = al_note_type.lookup_code and al_note_type.lookup_type = 'NOTE_TYPE'
		 where 1 = 1
		   and rcta.trx_number in ('123456')
		   -- and rcta.creation_date > '01-AUG-2016'
		   -- and rcta.creation_date < '10-AUG-2016'
		   -- and rcta.customer_trx_id in (123456)
		   -- and ppa.segment1 = 'PROJ123456'
		   -- and hca_bill.account_number in ('123456')
		   and 1 = 1;

-- ##################################################################
-- TRANSACTIONS PLUS LINES - VERSION 1
-- ##################################################################

		select '------ TRANSACTION HEADER -----'
			 , rbsa.name source
			 , rcta.trx_number "number"
			 , rcta.customer_trx_id
			 , al_trx_type.meaning class
			 , rctta.name type
			 , rcta.interface_header_attribute1 reference
			 , xlolv.legal_entity_name legal_entity
			 , rcta.trx_date
			 , rctlgda_gl.gl_date
			 , rcta.invoice_currency_code currency
			 , rcta.doc_sequence_value doc_num
			 , rcta.interface_header_context context_value
			 , rcta.complete_flag complete
			 , rtt.name payment_term
			 , to_char(rcta.trx_date, 'DD-MON-YYYY') trx_date
			 , fu.user_name
			 , fu.description
			 , fu.email_address
			 , '------ BILL TO CUSTOMER -----'
			 , hp_bill.party_name bill_cust
			 , hca_bill.account_number bill_acct
			 , hca_bill.customer_class_code bill_cust_class
			 , acpcvb.profile_class_description bill_profile_class
			 , hp_bill.tax_reference ship_tax_ref
			 , rcta.bill_to_site_use_id
			 , hcsua_bill.location bill_to_location
			 , '------ SHIP TO CUSTOMER -----'
			 , hp_ship.party_name ship_cust
			 , hca_ship.account_number ship_acct
			 , hca_ship.customer_class_code ship_cust_class
			 , acpcvs.profile_class_description ship_profile_class
			 , hp_ship.tax_reference bill_tax_ref
			 , rcta.ship_to_site_use_id
			 , hcsua_ship.location ship_to_location
			 , '------ LINES -----'
			 -- , decode(rctla.link_to_cust_trx_line_id, null, rctla.line_number, rctla_line.line_number) line_number
			 , al_type.meaning line_type
			 , rctla.quantity_credited qty
			 , rctla.unit_selling_price amount
			 , rctla.tax_classification_code
			 , rctla.tax_rate
			 , rctla.taxable_amount
			 , rctla.extended_amount
			 , rctla.description
			 , rctla.reason_code
			 , rctla.creation_date
			 -- , '################################'
			 -- , rctla.*
		  from ar.ra_customer_trx_all rcta
	 left join apps.xle_le_ou_ledger_v xlolv on xlolv.operating_unit_id = rcta.legal_entity_id
	 left join ar.ra_cust_trx_types_all rctta on rcta.cust_trx_type_id = rctta.cust_trx_type_id and rcta.org_id = rctta.org_id
	 left join apps.ar_lookups al_trx_type on rctta.type = al_trx_type.lookup_code and al_trx_type.lookup_type = 'INV/CM/ADJ'
	 left join applsys.fnd_user fu on rcta.created_by = fu.user_id
	 left join applsys.fnd_user fu2 on rcta.last_updated_by = fu2.user_id
	 left join hr.hr_all_organization_units haou on rcta.org_id = haou.organization_id
	 left join ar.ra_customer_trx_lines_all rctla on rctla.customer_trx_id = rcta.customer_trx_id
	 -- left join ar.ra_cust_trx_line_gl_dist_all rctlgda_gl on rctla.customer_trx_id = rctlgda_gl.customer_trx_id and rctlgda_gl.latest_rec_flag = 'Y' and rctlgda.customer_trx_line_id = rctla.customer_trx_line_id
	 -- left join ar.ra_customer_trx_lines_all rctla_line on rctla.link_to_cust_trx_line_id = rctla_line.customer_trx_line_id
	 left join ar.hz_cust_accounts hca_bill on rcta.bill_to_customer_id = hca_bill.cust_account_id
	 left join ar.hz_parties hp_bill on hp_bill.party_id = hca_bill.party_id
	 left join apps.ar_customer_profile_classes_v acpcvb on hca_bill.customer_class_code = acpcvb.profile_class_name
	 left join ar.hz_cust_accounts hca_ship on rcta.ship_to_customer_id = hca_ship.cust_account_id
	 left join ar.hz_parties hp_ship on hp_ship.party_id = hca_ship.party_id
	 left join apps.ar_customer_profile_classes_v acpcvs on hca_ship.customer_class_code = acpcvs.profile_class_name
	 left join ar.ra_customer_trx_all rcta_prev on rcta.previous_customer_trx_id = rcta_prev.customer_trx_id
	 left join ar.ra_batches_all rba on rcta.batch_id = rba.batch_id
	 left join ar.ra_batch_sources_all rbsa on rcta.batch_source_id = rbsa.batch_source_id and rcta.org_id = rbsa.org_id
	 left join ar.ra_terms_tl rtt on rcta.term_id = rtt.term_id and rtt.language = userenv('lang')
	 left join pa.pa_draft_invoices_all pdia on pdia.ra_invoice_number = rcta.trx_number
	 left join pa.pa_projects_all ppa on pdia.project_id = ppa.project_id
	 left join apps.ar_lookups al_type on rctla.line_type = al_type.lookup_code and al_type.lookup_type = 'STD_LINE_TYPE'
	 left join ar.hz_cust_site_uses_all hcsua_bill on hcsua_bill.site_use_id = rcta.bill_to_site_use_id
	 left join ar.hz_cust_site_uses_all hcsua_ship on hcsua_ship.site_use_id = rcta.ship_to_site_use_id
		 where 1 = 1
		   and rcta.trx_number in ('123456')
		   -- and rcta.creation_date > '01-AUG-2016'
		   -- and rcta.creation_date < '10-AUG-2016'
		   -- and rcta.customer_trx_id in (123456)
		   -- and ppa.segment1 = 'PROJ123456'
		   -- and hca_bill.account_number in ('123456')
		   and 1 = 1
	  order by rcta.creation_date desc;

-- ##################################################################
-- TRANSACTIONS PLUS LINES - VERSION 2
-- ##################################################################

		select rcta.customer_trx_id
			 , rcta.trx_number
			 , rcta.creation_date
			 , rctta.name transaction_type
			 , hca.account_number
			 , hp.party_number
			 , hp.party_name
			 , '------ LINES -----'
			 , rctla.customer_trx_line_id
			 , rctla.inventory_item_id
			 , msib.segment1
			 , msib.description line_item
			 , rctla.description
			 , rctla.unit_selling_price
			 , rctla.line_type
			 , rctla.tax_rate
			 , rctla.taxable_amount
			 -- , rctla.*
		  from ar.ra_customer_trx_all rcta
		  join ar.ra_customer_trx_lines_all rctla on rcta.customer_trx_id = rctla.customer_trx_id
		  join ar.ra_cust_trx_types_all rctta on rcta.cust_trx_type_id = rctta.cust_trx_type_id
		  join ar.hz_cust_accounts hca on rcta.bill_to_customer_id = hca.cust_account_id
		  join ar.hz_parties hp on hp.party_id = hca.party_id
	 left join inv.mtl_system_items_b msib on rctla.inventory_item_id = msib.inventory_item_id
		 where 1 = 1
		   and rctla.line_type = 'LINE'
		   -- and rcta.trx_number = '123456'
		   and rcta.customer_trx_id in (123456)
		   -- and hca.account_number = '123456'
		   -- and rcta.creation_date > '01-JUN-2017'
		   and 1 = 1
	  order by rcta.creation_date desc;

-- ##################################################################
-- TRANSACTIONS PLUS DISTRIBUTIONS
-- ##################################################################

		select '------ TRANSACTION HEADER -----'
			 , rbsa.name source
			 , rcta.trx_number "number"
			 , rcta.customer_trx_id
			 , al_trx_type.meaning class
			 , rctta.name type
			 , rcta.interface_header_attribute1 reference
			 , xlolv.legal_entity_name legal_entity
			 , to_char(rcta.trx_date, 'DD-MON-YYYY') trx_date
			 , to_char(rctlgda.gl_date, 'DD-MON-YYYY') gl_date
			 , to_char(rctlgda.gl_posted_date, 'DD-MON-YYYY') gl_posted_date
			 , rcta.invoice_currency_code currency
			 , rcta.doc_sequence_value doc_num
			 , rcta.interface_header_context context_value
			 , rcta.complete_flag complete
			 , rtt.name payment_term
			 , rcta.trx_date
			 , '------ BILL TO CUSTOMER -----'
			 , hp_bill.party_name bill_cust
			 , hca_bill.account_number bill_acct
			 , hca_bill.customer_class_code bill_cust_class
			 , acpcvb.profile_class_description bill_profile_class
			 , hp_bill.tax_reference ship_tax_ref
			 , '------ SHIP TO CUSTOMER -----'
			 , hp_ship.party_name ship_cust
			 , hca_ship.account_number ship_acct
			 , hca_ship.customer_class_code ship_cust_class
			 , acpcvs.profile_class_description ship_profile_class
			 , hp_ship.tax_reference bill_tax_ref
			 , '------ DISTRIBUTIONS -----'
			 , rctlgda.account_class
			 , gcc.concatenated_segments gl_account
			 , rctlgda.latest_rec_flag
			 , rctlgda.gl_date distrib_gl_date
			 , rctlgda.gl_posted_date distrib_gl_posted
			 , rctlgda.percent distrib_percent
			 , rctlgda.amount distrib_amount
			 , rctlgda.creation_date distrib_created
			 , rctlgda.comments
		  from ar.ra_customer_trx_all rcta
	 left join apps.xle_le_ou_ledger_v xlolv on xlolv.operating_unit_id = rcta.legal_entity_id
	 left join ar.ra_cust_trx_types_all rctta on rcta.cust_trx_type_id = rctta.cust_trx_type_id and rcta.org_id = rctta.org_id
	 left join apps.ar_lookups al_trx_type on rctta.type = al_trx_type.lookup_code and al_trx_type.lookup_type = 'INV/CM/ADJ'
	 left join applsys.fnd_user fu on rcta.created_by = fu.user_id
	 left join applsys.fnd_user fu2 on rcta.last_updated_by = fu2.user_id
	 left join hr.hr_all_organization_units haou on rcta.org_id = haou.organization_id
	 left join ar.ra_cust_trx_line_gl_dist_all rctlgda on rcta.customer_trx_id = rctlgda.customer_trx_id
	 left join ar.ra_cust_trx_line_gl_dist_all rctlgda_gl on rcta.customer_trx_id = rctlgda_gl.customer_trx_id and rctlgda_gl.latest_rec_flag = 'Y' 
	 left join apps.gl_code_combinations_kfv gcc on rctlgda.code_combination_id = gcc.code_combination_id
	 left join ar.hz_cust_accounts hca_bill on rcta.bill_to_customer_id = hca_bill.cust_account_id
	 left join ar.hz_parties hp_bill on hp_bill.party_id = hca_bill.party_id
	 left join apps.ar_customer_profile_classes_v acpcvb on hca_bill.customer_class_code = acpcvb.profile_class_name
	 left join ar.hz_cust_accounts hca_ship on rcta.ship_to_customer_id = hca_ship.cust_account_id
	 left join ar.hz_parties hp_ship on hp_ship.party_id = hca_ship.party_id
	 left join apps.ar_customer_profile_classes_v acpcvs on hca_ship.customer_class_code = acpcvs.profile_class_name
	 left join ar.ra_customer_trx_all rcta_prev on rcta.previous_customer_trx_id = rcta_prev.customer_trx_id
	 left join ar.ra_batches_all rba on rcta.batch_id = rba.batch_id
	 left join ar.ra_batch_sources_all rbsa on rcta.batch_source_id = rbsa.batch_source_id and rcta.org_id = rbsa.org_id
	 left join ar.ra_terms_tl rtt on rcta.term_id = rtt.term_id and rtt.language = userenv('lang')
	 left join pa.pa_draft_invoices_all pdia on pdia.ra_invoice_number = rcta.trx_number
	 left join pa.pa_projects_all ppa on pdia.project_id = ppa.project_id
	 left join apps.ar_lookups al_class on rctlgda.account_class = al_class.lookup_code and al_class.lookup_type = 'AUTOGL_TYPE'
		 where 1 = 1
		   and rctla.line_type = 'LINE'
		   -- and rcta.trx_number = '123456'
		   and rcta.customer_trx_id in (123456)
		   -- and hca.account_number = '123456'
		   -- and rcta.creation_date > '01-JUN-2017'
		   and 1 = 1;

-- ##################################################################
-- SOURCE SUMMARY
-- ##################################################################

		select rbsa.name source_name
			 , trunc(rcta.creation_date) tx_date
			 , count (*) tx_ct
			 , max (rcta.creation_date) recent_tx
		  from apps.ra_customer_trx_all rcta
			 , ar.ra_batch_sources_all rbsa
		 where rcta.batch_source_id = rbsa.batch_source_id
		   -- and rbsa.name = 'PROJECTS INVOICES'
		   and rcta.creation_date >= '23-NOV-2015'
		   and 1 = 1
	  group by rbsa.name
			 , trunc(rcta.creation_date)
	  order by trunc(rcta.creation_date) desc;

-- ##################################################################
-- TRANSACTIONS WHICH DO NOT APPEAR IN THE AR ACCOUNT DETAILS FORM
-- ##################################################################

		select distinct gld.customer_trx_id
			 , ct.trx_number
			 , ct.creation_date trx_created
			 , hp.party_name
			 , hca.account_number act_no
		  from ar.ra_customer_trx_all ct
			 , ar.ra_cust_trx_types_all ctt
			 , ar.ra_cust_trx_line_gl_dist_all gld
			 , hz_cust_accounts hca
			 , hz_parties hp
		 where 1 = 1
		   and ct.cust_trx_type_id = ctt.cust_trx_type_id
		   and hca.party_id = hp.party_id
		   and ctt.type in ('INV', 'DM', 'CM', 'CB')
		   and ctt.accounting_affect_flag = 'Y'
		   and gld.customer_trx_id = ct.customer_trx_id
		   and ct.bill_to_customer_id = hca.cust_account_id
		   and ct.complete_flag = 'Y'
		   and gld.customer_trx_id = ct.customer_trx_id
		   and gld.account_class = 'REC'
		   and gld.account_set_flag = 'N'
		   and not exists (select 'x'
							  from ar.ar_payment_schedules_all ps 
							 where ps.customer_trx_id = ct.customer_trx_id);

-- ##################################################################
-- RECEIPTS, CUSTOMERS, TRANSACTIONS, APPLICATIONS
-- ##################################################################

		select araa.cash_receipt_id
			 , acra.receipt_number
			 , acra.creation_date receipt_created
			 , hou.name org
			 , hou.short_code org_code
			 , araa.creation_date application_created
			 , araa.amount_applied
			 , araa.status application_status
			 , araa.applied_customer_trx_id
			 , araa.applied_payment_schedule_id
			 , araa.application_ref_num
			 , rcta.trx_number
			 , rcta.customer_trx_id trx_id
			 , rcta.bill_to_customer_id customer_id
			 , hp.party_name
			 , hca.cust_account_id trx_customer_id
			 , acra.pay_from_customer rx_customer_id
			 , hca.account_number trx_cust_num
			 , hca2.account_number rx_cust_num
		  from ar_receivable_applications_all araa
		  join ar.ra_customer_trx_all rcta on araa.applied_customer_trx_id = rcta.customer_trx_id
		  join ar.hz_cust_accounts hca on rcta.bill_to_customer_id = hca.cust_account_id
		  join ar.hz_parties hp on hp.party_id = hca.party_id
		  join ar.ar_cash_receipts_all acra on acra.cash_receipt_id = araa.cash_receipt_id
		  join apps.hr_operating_units hou on hou.organization_id = acra.org_id
		  join ar.hz_cust_accounts hca2 on acra.pay_from_customer = hca2.cust_account_id
		 where 1 = 1
		   and araa.cash_receipt_id in (123456)
		   -- and acra.creation_date between '15-JUN-2018' and '16-JUN-2018'
	  order by araa.receivable_application_id;
