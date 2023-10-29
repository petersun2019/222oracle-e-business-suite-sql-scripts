/*
File Name:		ar-receipts.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- TABLE DUMPS
-- BASIC RECEIPTS
-- RECEIPTS EXCLUDING BANK ACCOUNTS INCLUDING DISTRIBUTIONS
-- RECEIPTS EXCLUDING BANK ACCOUNTS
-- RECEIPTS INCLUDING BANK ACCOUNTS
-- RECEIPTS INCLUDING RECEIPT APPLICATIONS
-- RECEIPT APPLICATIONS WITH ACCOUNTING DETAILS
-- APPLICATIONS
-- BATCHES - BASIC INFO
-- RECEIPTS LINKED TO BATCH
-- BATCHES LINKED TO "AUTOMATIC REMITTANCES CREATION PROGRAM (API)" JOB
-- RECEIPTS LINKED TO AR TRANSACTIONS
-- OUTSTANDING AMOUNT CALCULATION
-- LINK BETWEEN RECEIPT NUMBER AND TRANSACTION NUMBER

*/

-- ##################################################################
-- TABLE DUMPS
-- ##################################################################

select * from ar.ar_cash_receipts_all acra where receipt_number = '123456';

-- ##################################################################
-- BASIC RECEIPTS
-- ##################################################################

		select acra.cash_receipt_id
			 , acra.receipt_number
			 , acra.doc_sequence_value document_number
			 , acra.reference_type
			 , acra.type
			 , acra.org_id
			 , acra.creation_date
			 , fu.user_name created_by
		  from ar.ar_cash_receipts_all acra 
		  join applsys.fnd_user fu on acra.created_by = fu.user_id
		 where 1 = 1
		   and acra.cash_receipt_id in (123456)
		   and 1 = 1;

-- ##################################################################
-- RECEIPTS EXCLUDING BANK ACCOUNTS INCLUDING DISTRIBUTIONS
-- ##################################################################

		select arm.name receipt_method
			 , acra.receipt_number
			 , acra.creation_date
			 , fu.user_name || ' (' || fu.email_address || ')' created_by
			 , acra.last_update_date
			 , fu2.user_name || ' (' || fu2.email_address || ')' updated_by
			 , acra.cash_receipt_id
			 , acra.doc_sequence_value doc_number
			 , acra.currency_code curr
			 , decode(acra.type, 'CASH', 'Standard', 'MISC', 'Miscellaneous') receipt_type
			 , arta.name activity
			 , gcck1.segment2
			 , al.meaning state
			 , to_char(acra.receipt_date, 'DD-MON-YYYY') receipt_date
			 , acra.amount receipt_amount
			 , ada.acctd_amount_cr distrib_cr
			 , acra.amount - ada.acctd_amount_cr diff
			 , ada.acctd_amount_dr distrib_dr
			 , amcda.amount misc_cash_dist_amount
			 , amcda.misc_cash_distribution_id
			 , ada.source_id
			 , ada.creation_date dist_created
			 , ada.last_update_date dist_updated
			 , gcck1.concatenated_segments account_code 
			 , hca.account_number
			 , hca.account_name
			 , hp.party_name
		  from ar.ar_cash_receipts_all acra
	 left join ar.ar_receipt_methods arm on acra.receipt_method_id = arm.receipt_method_id
	 left join ar.ar_receipt_classes arc on arm.receipt_class_id = arc.receipt_class_id
	 left join apps.ar_lookups al on al.lookup_code = acra.status and al.lookup_type = 'CHECK_STATUS'
	 left join applsys.fnd_user fu on acra.created_by = fu.user_id
	 left join applsys.fnd_user fu2 on acra.last_updated_by = fu2.user_id
	 left join ar.hz_cust_accounts hca on acra.pay_from_customer = hca.cust_account_id
	 left join ar.hz_parties hp on hca.party_id = hp.party_id
	 left join ar.ar_misc_cash_distributions_all amcda on amcda.cash_receipt_id = acra.cash_receipt_id
	 left join ar.ar_distributions_all ada on ada.source_id = amcda.misc_cash_distribution_id and ada.source_table = 'MCD' and ada.source_type = 'MISCCASH'
	 left join apps.gl_code_combinations_kfv gcck1 on gcck1.code_combination_id = ada.code_combination_id
	 left join ar.ar_receivables_trx_all arta on acra.receivables_trx_id = arta.receivables_trx_id
		 where 1 = 1
		   and acra.receipt_number = '123456'
		   and 1 = 1
	  order by acra.creation_date desc;

-- ##################################################################
-- RECEIPTS EXCLUDING BANK ACCOUNTS
-- ##################################################################

		select arm.name receipt_method
			 , acra.receipt_number
			 , acra.cash_receipt_id
			 , acra.doc_sequence_value doc_number
			 , acra.currency_code curr
			 , acra.amount
			 , decode(acra.type, 'CASH', 'Standard', 'MISC', 'Miscellaneous') receipt_type
			 , al.meaning state
			 , acra.receipt_date
			 , acra.creation_date
			 , acra.created_by
			 , fu.user_name
			 , fu.description created_by
			 , acra.last_update_date
			 , hca.account_number
			 , hca.account_name
		  from ar.ar_cash_receipts_all acra
	 left join ar.ar_receipt_methods arm on acra.receipt_method_id = arm.receipt_method_id
	 left join ar.ar_receipt_classes arc on arm.receipt_class_id = arc.receipt_class_id
	 left join apps.ar_lookups al on al.lookup_code = acra.status and al.lookup_type = 'CHECK_STATUS'
	 left join applsys.fnd_user fu on acra.created_by = fu.user_id
	 left join ar.hz_cust_accounts hca on acra.pay_from_customer = hca.cust_account_id
		 where 1 = 1
		   and acra.receipt_number in ('123456')
		   and 1 = 1
	  order by acra.creation_date desc;

-- COUNT CREATED BY USER

		select fu.user_name
			 , count(*) ct
		  from ar.ar_cash_receipts_all acra
		  join applsys.fnd_user fu on acra.created_by = fu.user_id
		 where 1 = 1
		   and acra.creation_date > '01-MAR-2016'
		   and 1 = 1
	  group by fu.user_name;

-- ##################################################################
-- RECEIPTS INCLUDING BANK ACCOUNTS
-- ##################################################################

		select arm.name receipt_method
			 , acra.receipt_number
			 , acra.cash_receipt_id
			 , acra.doc_sequence_value doc_number
			 , acra.currency_code curr
			 , acra.amount
			 , decode(acra.type, 'CASH', 'Standard', 'MISC', 'Miscellaneous') receipt_type
			 , al.meaning state
			 , acra.receipt_date
			 , acra.creation_date
			 , acra.created_by
			 , fu.description created_by
			 , acra.last_update_date
			 , hca.account_number
			 , hca.account_name
			 , cba.bank_account_name
			 , cba.bank_account_num
			 , cbbv.bank_name remit_bank_name
			 , cbbv.bank_branch_name remit_bank_branch
			 -- , decode (arc.creation_method_code, 'MANUAL', iebav.bank_account_number, null) customer_bank_account
			 -- , decode (arc.creation_method_code, 'MANUAL', iebav.bank_account_number, null) customer_bank_account_num
			 -- , decode (arc.creation_method_code, 'MANUAL', iebav.bank_name, null) customer_bank_name
			 -- , decode (arc.creation_method_code, 'MANUAL', iebav.bank_branch_name, null) customer_bank_branch
		  from ar.ar_cash_receipts_all acra
		  join ar.ar_receipt_methods arm on acra.receipt_method_id = arm.receipt_method_id
		  join ar.ar_receipt_classes arc on arm.receipt_class_id = arc.receipt_class_id
		  join apps.ar_lookups al on al.lookup_code = acra.status and al.lookup_type = 'CHECK_STATUS'
		  join applsys.fnd_user fu on acra.created_by = fu.user_id
	 left join ar.hz_cust_accounts hca on acra.pay_from_customer = hca.cust_account_id
	 left join ce.ce_bank_acct_uses_all cbaua on cbaua.bank_acct_use_id = acra.remit_bank_acct_use_id and cbaua.org_id = acra.org_id
	 left join ce.ce_bank_accounts cba on cbaua.bank_account_id = cba.bank_account_id
	 left join apps.ce_bank_branches_v cbbv on cbbv.branch_party_id = cba.bank_branch_id
	 -- left join apps.iby_ext_bank_accounts_v iebav on iebav.ext_bank_account_id = acra.customer_bank_account_id
		 where 1 = 1
		   and acra.receipt_number in ('123456')
		   -- and acra.cash_receipt_id = 123456
		   -- and hca.account_number = 123456
		   -- and fu.user_name = 'SYSADMIN'
		   -- and acra.creation_date > '09-MAY-2016'
		   and 1 = 1
	  order by acra.creation_date desc;

-- ##################################################################
-- RECEIPTS INCLUDING RECEIPT APPLICATIONS
-- ##################################################################

		select arm.name receipt_method
			 , acra.receipt_number
			 , acra.cash_receipt_id
			 , acra.currency_code curr
			 , acra.amount
			 , acra.type
			 , al1.meaning status
			 , acra.receipt_date
			 , fdfcv.descriptive_flex_context_code payment_type
			 , fdfcv.description payment_type_descr
			 , acrha.trx_date
			 , acrha.gl_date
			 , acrha.reversal_gl_date
			 , gcc.segment1 || '*' || gcc.segment2 || '*' || gcc.segment3 || '*' || gcc.segment4 || '*' || gcc.segment5 || '*' || gcc.segment6 chg_acct
			 , acrha.creation_date
			 , cr.user_name cr_by
			 , acra.last_update_date
			 , up.user_name up_by
			 , hca.account_number
			 -- , '####################'
			 -- , acrha.*
		  from ar.ar_cash_receipts_all acra
		  join ar.ar_cash_receipt_history_all acrha on acra.cash_receipt_id = acrha.cash_receipt_id
		  join ar.ar_receipt_methods arm on acra.receipt_method_id = arm.receipt_method_id
	 left join apps.fnd_descr_flex_contexts_vl fdfcv on acra.attribute_category = fdfcv.descriptive_flex_context_name and fdfcv.descriptive_flexfield_name = 'AR_CASH_RECEIPTS'
	 left join apps.ar_lookups al1 on al1.lookup_code = acrha.status and al1.lookup_type = 'RECEIPT_CREATION_STATUS'
	 left join apps.ar_lookups al2 on al2.lookup_code = acra.status and al2.lookup_type = 'RECEIPT_CREATION_STATUS'
	 left join ar.hz_cust_accounts hca on acra.pay_from_customer = hca.cust_account_id
		  join gl.gl_code_combinations gcc on gcc.code_combination_id = acrha.account_code_combination_id
		  join applsys.fnd_user cr on acra.created_by = cr.user_id
		  join applsys.fnd_user up on acra.last_updated_by = up.user_id
		 where 1 = 1
		   -- and cr.user_name = 'SYSADMIN'
		   and acra.receipt_number in ('123456')
		   -- and acrha.cash_receipt_history_id = 123456
		   -- and acra.cash_receipt_id = 123456
		   -- and hca.account_number = '123456'
		   -- and acra.creation_date > '01-JAN-2018'
		   -- and acrha.current_record_flag = 'Y'
		   -- and acra.creation_date > '01-MAR-2016'
		   -- and acra.creation_date < '01-APR-2016'
		   -- and acra.creation_date > '21-JUL-2016'
		   and 1 = 1
	  order by acra.creation_date desc;


-- ##################################################################
-- RECEIPT APPLICATIONS WITH ACCOUNTING DETAILS
-- ##################################################################

		select araa.creation_date application_created
			 -- , fu.user_name || ' (' || fu.email_address || ')' created_by
			 , acra.receipt_number
			 , acra.currency_code receipt_currency
			 , acra.creation_date receipt_created
			 , araa.amount_applied amt_applied
			 , to_char(araa.gl_date, 'DD-MON-YYYY') gl_date
			 , to_char(araa.gl_posted_date, 'DD-MON-YYYY') gl_posted_date
			 -- , to_char(araa.reversal_date, 'DD-MON-YYYY') reversal_date
			 , araa.code_combination_id
			 , gcc1.concatenated_segments
			 , araa.display
			 , araa.status
			 , araa.application_rule
			 , araa.acctd_amount_applied_from
			 , gcc2.concatenated_segments earned_discount
			 , gcc3.concatenated_segments unearned_discount
			 , araa.application_ref_num
			 , hca.account_number
			 , hp.party_name customer_name
		  from ar_receivable_applications_all araa
		  join fnd_user fu on araa.created_by = fu.user_id
		  join gl_code_combinations_kfv gcc1 on araa.code_combination_id = gcc1.code_combination_id
	 left join gl_code_combinations_kfv gcc2 on araa.earned_discount_ccid = gcc2.code_combination_id
	 left join gl_code_combinations_kfv gcc3 on araa.unearned_discount_ccid = gcc3.code_combination_id
		  join ar_cash_receipts_all acra on acra.cash_receipt_id = araa.cash_receipt_id
	 left join hz_cust_accounts hca on hca.cust_account_id = araa.on_acct_cust_id
	 left join hz_parties hp on hca.party_id = hp.party_id
		 where 1 = 1
		   -- and araa.creation_date > '11-FEB-2018'
		   -- and acra.receipt_number = '123456'
		   and araa.code_combination_id = 123456
		   and 1 = 1;

-- ##################################################################
-- APPLICATIONS
-- ##################################################################

		select acra.cash_receipt_id
			 , acra.receipt_number
			 , acra.creation_date
			 , araa.creation_date app_cr
			 , cr.description app_cr_by
			 , araa.last_update_date app_ud
			 , ud.description app_ud_by
			 , araa.amount_applied
			 , araa.apply_date
			 , araa.application_type
			 , araa.status
			 , hp.party_name
			 , hca.account_number
			 , '#################'
			 , gcc.concatenated_segments
			 , araa.application_rule
			 , araa.status
		  from ar.ar_cash_receipts_all acra
		  join ar.ar_receivable_applications_all araa on acra.cash_receipt_id = araa.cash_receipt_id
		  join applsys.fnd_user cr on araa.created_by = cr.user_id
		  join applsys.fnd_user ud on araa.last_updated_by = ud.user_id
		  join ar.hz_cust_accounts hca on acra.pay_from_customer = hca.cust_account_id
		  join ar.hz_parties hp on hca.party_id = hp.party_id
	 left join apps.gl_code_combinations_kfv gcc on araa.code_combination_id = gcc.code_combination_id
	 left join ar.ar_payment_schedules_all apsa on araa.payment_schedule_id = apsa.payment_schedule_id
		 where 1 = 1
		   -- and acra.cash_receipt_id in (123456)
		   and acra.receipt_number in ('123456')
		   -- and araa.status = 'ACC'
		   and 1 = 1
	  order by acra.receipt_number
			 , araa.creation_date;

-- COUNTING

		select acra.cash_receipt_id
			 , acra.receipt_number
			 , sum(araa.amount_applied) amount_applied
		  from ar.ar_cash_receipts_all acra
		  join ar.ar_receivable_applications_all araa on acra.cash_receipt_id = araa.cash_receipt_id
		  join applsys.fnd_user cr on araa.created_by = cr.user_id
		  join applsys.fnd_user ud on araa.last_updated_by = ud.user_id
		  join ar.hz_cust_accounts hca on acra.pay_from_customer = hca.cust_account_id
		  join ar.hz_parties hp on hca.party_id = hp.party_id
		 where 1 = 1
		   -- and acra.cash_receipt_id in (123456, 123457)
		   and acra.receipt_number in ('12345-7','12345-8','12345-5','123456-00004','123456-00003','123456-00002')
		   and araa.status = 'ACC'
		   and 1 = 1
	  group by acra.cash_receipt_id
			 , acra.receipt_number
	  order by acra.receipt_number;

-- ##################################################################
-- BATCHES - BASIC INFO
-- ##################################################################

		select aba.name batch_num
			 , aba.batch_date
			 , aba.gl_date
			 , aba.batch_id
			 , aba.creation_date batch_created
			 , aba.type
			 , aba.status
			 , aba.currency_code
			 , aba.remit_method_code
			 , arc.name receipt_class
			 , arm.name receipt_method
			 , aba.comments
			 , aba.control_count count
			 , aba.control_amount amount
			 , aba.request_id
			 , aba.batch_applied_status
		  from ar.ar_batches_all aba
		  join ar.ar_receipt_classes arc on aba.receipt_class_id = arc.receipt_class_id
		  join ar.ar_receipt_methods arm on aba.receipt_method_id = arm.receipt_method_id
		 where 1 =1
		   and aba.name = '123456'
	  order by aba.creation_date desc;

-- ##################################################################
-- RECEIPTS LINKED TO BATCH
-- ##################################################################

		select aba.name batch_num
			 , aba.batch_date
			 , aba.batch_id
			 , aba.gl_date
			 , aba.currency_code
			 , aba.remit_method_code
			 , aba.creation_date batch_created
			 , arc.name receipt_class
			 , arm.name receipt_method
			 , aba.comments
			 , aba.control_count
			 , aba.control_amount
			 , '/////////'
			 , acra.cash_receipt_id
			 , acra.receipt_number rx_num
			 , acra.creation_date rx_created
			 , acra.receipt_date rx_date
			 , acra.type rx_type
			 , acra.amount rx_amt
			 , acra.currency_code rx_curr
			 , acra.pay_from_customer rx_cust
			 , acra.status rx_status
		  from ar.ar_batches_all aba
	 left join ar.ar_receipt_classes arc on aba.receipt_class_id = arc.receipt_class_id
	 left join ar.ar_receipt_methods arm on aba.receipt_method_id = arm.receipt_method_id
	 left join ar.ar_cash_receipt_history_all acrha on acrha.batch_id = aba.batch_id
	 left join ar.ar_cash_receipts_all acra on acra.cash_receipt_id = acrha.cash_receipt_id
		 where 1 = 1
		   and acra.receipt_number = '123456'
		   -- and acrha.current_record_flag = 'Y'
		   -- and aba.name = '123456'
		   -- and aba.batch_id = 123456
		   -- and acra.creation_date > '15-MAR-2016'
		   and 1 = 1;

-- ##################################################################
-- BATCHES LINKED TO "AUTOMATIC REMITTANCES CREATION PROGRAM (API)" JOB
-- ##################################################################

		select fcr.request_id id
			 , decode (fcr.phase_code , 'P', 'Pending' , 'R', 'Running' , 'C', 'Complete' , 'I', 'Inactive') phase
			 , decode (fcr.status_code , 'A', 'Waiting' , 'B', 'Resuming' , 'C', 'Normal' , 'D', 'Cancelled' , 'E', 'Error' , 'F', 'Scheduled' , 'G', 'Warning' , 'H', 'On Hold' , 'I', 'Normal' , 'M', 'No Manager' , 'Q', 'Standby' , 'R', 'Normal' , 'S', 'Suspended' , 'T', 'Terminating' , 'U', 'Disabled' , 'W', 'Paused' , 'X', 'Terminated' , 'Z', 'Waiting') status
			 , trunc(fcr.actual_start_date) run_date
			 , to_char((fcr.actual_start_date), 'HH24:MI:SS') start_
			 , to_char((fcr.actual_completion_date), 'HH24:MI:SS') end_
			 , to_char (fcr.actual_start_date, 'Dy') day
			 , case when trunc(fcr.actual_start_date) = trunc(sysdate) then '***' end today_
			 , trim(replace(replace(to_char(numtodsinterval((fcr.actual_completion_date-fcr.actual_start_date),'day')),'+000000000',''),'.000000000','')) dur
			 , fu.user_name || ' (' || fu.description || ')' submitted_by
			 , fcr.completion_text
			 , '##############'
			 , aba.name batch_num
			 , aba.batch_date
			 , aba.gl_date
			 , aba.currency_code
			 , aba.remit_method_code
			 , arc.name receipt_class
			 , arm.name receipt_method
			 , aba.comments
			 , aba.control_count count
			 , aba.control_amount amount
		  from applsys.fnd_concurrent_requests fcr
		  join applsys.fnd_concurrent_programs_tl fcp on fcr.concurrent_program_id = fcp.concurrent_program_id and fcr.program_application_id = fcp.application_id
		  join applsys.fnd_application_tl fat on fcr.program_application_id = fat.application_id
		  join applsys.fnd_responsibility_tl frt on fcr.responsibility_id = frt.responsibility_id
		  join applsys.fnd_user fu on fcr.requested_by = fu.user_id
		  join ar.ar_batches_all aba on fcr.argument7 = aba.batch_id
		  join ar.ar_receipt_classes arc on aba.receipt_class_id = arc.receipt_class_id
		  join ar.ar_receipt_methods arm on aba.receipt_method_id = arm.receipt_method_id
		 where nvl(fcr.description, fcp.user_concurrent_program_name) = 'Automatic Remittances Creation Program (API)'
		   and fcr.argument1 = 'REMIT'
		   and fcr.status_code not in ('D','X') -- not cancelled (D) or teminated (X)
		   and fcr.request_id = 123456
	  order by fcr.actual_start_date desc;

-- ##################################################################
-- RECEIPTS LINKED TO AR TRANSACTIONS
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
			 , to_char(rcta.creation_date, 'DD-MON-YYYY HH24:MI:SS') creation_date
			 , to_char(rcta.trx_date, 'DD-MON-YYYY') transaction_date
			 , to_char(rcta.last_update_date, 'DD-MON-YYYY') last_update_date
			 , rcta.customer_trx_id trx_id
			 , (select sum(extended_amount) from ar.ra_customer_trx_lines_all rctla where rcta.customer_trx_id = rctla.customer_trx_id) tx_value
			 , (select sum(amount_due_remaining) from ar.ar_payment_schedules_all apsa where apsa.customer_trx_id = rcta.customer_trx_id) amt_outstanding
			 , rcta.bill_to_customer_id customer_id
			 , hp.party_name
			 , hca.cust_account_id trx_customer_id
			 , acra.pay_from_customer rx_customer_id
			 , hca.account_number trx_cust_num
			 , hca2.account_number rx_cust_num
			 , rcta.org_id
		  from ar_receivable_applications_all araa
		  join ar.ra_customer_trx_all rcta on araa.applied_customer_trx_id = rcta.customer_trx_id
		  join ar.hz_cust_accounts hca on rcta.bill_to_customer_id = hca.cust_account_id
		  join ar.hz_parties hp on hp.party_id = hca.party_id
		  join ar.ar_cash_receipts_all acra on acra.cash_receipt_id = araa.cash_receipt_id
		  join apps.hr_operating_units hou on hou.organization_id = acra.org_id
		  join ar.hz_cust_accounts hca2 on acra.pay_from_customer = hca2.cust_account_id
		 where 1 = 1
		   -- and rcta.org_id <> 123
		   -- and acra.creation_date > '01-DEC-2018'
		   and hca.account_number = '123456'
		   -- and hca.account_number = '123456'
		   -- and acra.creation_date between '15-JUN-2018' and '16-JUN-2018'
		   -- and hca.cust_account_id != acra.pay_from_customer
		   -- and rcta.trx_number = '123456'
	  order by acra.creation_date desc;

-- OUTSTANDING AMOUNT CALCULATION

		select ttl.cust
			 , sum(os_amt)
		  from (select distinct hca.account_number cust
			 , (select sum(amount_due_remaining) from ar.ar_payment_schedules_all apsa where apsa.customer_trx_id = rcta.customer_trx_id) os_amt
		  from ar_receivable_applications_all araa
		  join ar.ra_customer_trx_all rcta on araa.applied_customer_trx_id = rcta.customer_trx_id
		  join ar.hz_cust_accounts hca on rcta.bill_to_customer_id = hca.cust_account_id
		  join ar.hz_parties hp on hp.party_id = hca.party_id
		  join ar.ar_cash_receipts_all acra on acra.cash_receipt_id = araa.cash_receipt_id
		  join apps.hr_operating_units hou on hou.organization_id = acra.org_id
		  join ar.hz_cust_accounts hca2 on acra.pay_from_customer = hca2.cust_account_id
		 where 1 = 1
		   and rcta.org_id = 123456
		   -- and hca.account_number = '123456'
		   and hca.cust_account_id != acra.pay_from_customer) ttl
	  group by ttl.cust
having sum(os_amt) > 0;

-- ##################################################################
-- LINK BETWEEN RECEIPT NUMBER AND TRANSACTION NUMBER
-- ##################################################################

/*
HTTPS://WWW.TOOLBOX.COM/TECH/ORACLE/QUESTION/HOW-TO-FIND-THE-LINK-BETWEEN-TRANSACTION-NUMBER-AND-RECEIPT-NUMBER-IN-AR-070312/
*/

		select acr.receipt_number receipt_no
			  ,rct.trx_number invoice_no
		  from ar_receivable_applications_all ara
		  join ar_cash_receipts_all acr on ara.cash_receipt_id = acr.cash_receipt_id
		  join ra_customer_trx_all rct on ara.applied_customer_trx_id=rct.customer_trx_id
		 where 1 = 1
		   and ara.status='APP'
		   and rct.customer_trx_id = 123456
		   and 1 = 1;
