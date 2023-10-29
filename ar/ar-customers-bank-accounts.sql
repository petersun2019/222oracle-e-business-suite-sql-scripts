/*
File Name: ar-customers-bank-accounts.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- CUSTOMER BANK ACCOUNTS - HEADER LEVEL
-- CUSTOMER BANK ACCOUNTS - SITE LEVEL
-- CUSTOMER BANK ACCOUNTS - COUNTING SITE LEVEL

*/

-- ##################################################################
-- CUSTOMER BANK ACCOUNTS - HEADER LEVEL (HTTPS://RPFORACLE.BLOGSPOT.COM/2018/12/CUSTOMER-BANK-ACCOUNT-QUERY-IN-ORACLE-APPS.HTML)
-- ##################################################################

		select ca.account_number
			 , ar_cust.customer_name
			 , to_char(iby_payee_uses.start_date, 'yyyy-mm-dd') instr_start
			 , to_char(iby_payee_uses.end_date, 'yyyy-mm-dd') "bank account end date"
			 , iby_eba.bank_account_num
			 , iby_eba.bank_account_name
			 , fu.user_name
			 , iby_payee_uses.creation_date instr_created
		  from hz_cust_accounts ca
		  join ar_customers ar_cust on ar_cust.customer_id = ca.cust_account_id
		  join iby_external_payers_all iby_payee on ca.cust_account_id = iby_payee.cust_account_id
		  join iby_pmt_instr_uses_all iby_payee_uses on iby_payee_uses.ext_pmt_party_id = iby_payee.ext_payer_id
		  join iby_ext_bank_accounts iby_eba on iby_eba.ext_bank_account_id = iby_payee_uses.instrument_id
		  join fnd_user fu on fu.user_id = iby_payee_uses.created_by
		 where 1 = 1
		   and iby_payee.acct_site_use_id is null
		   and iby_payee_uses.payment_function = 'CUSTOMER_PAYMENT'
		   -- and iby_eba.bank_account_num = '12345678'
		   and nvl(iby_payee_uses.end_date, sysdate + 1) > sysdate
		   and 1 = 1
	  order by iby_payee_uses.creation_date desc;

-- ##################################################################
-- CUSTOMER BANK ACCOUNTS - SITE LEVEL (HTTPS://RPFORACLE.BLOGSPOT.COM/2018/12/CUSTOMER-BANK-ACCOUNT-QUERY-IN-ORACLE-APPS.HTML)
-- ##################################################################

		select '#' || hca.account_number account_number
			 , hca.account_name
			 , hp.party_name
			 , '#' || hp.party_number registry_id
			 , hp.party_type
			 , to_char(ipiua.start_date, 'yyyy-mm-dd') bank_acc_start_date
			 , to_char(ipiua.end_date, 'yyyy-mm-dd') bank_acc_end_date
			 , eba.bank_account_num
			 , eba.bank_account_name
			 , ipiua.instrument_payment_use_id
			 , ipiua.order_of_preference
			 , ipiua.last_update_date ipiua_updated
			 , ipiua.instrument_payment_use_id instr_id
			 , ipiua.creation_date instr_creation_date
		  from apps.hz_cust_accounts hca
		  join apps.hz_cust_acct_sites_all hcasa on hcasa.cust_account_id = hca.cust_account_id
		  join apps.hz_parties hp on hca.party_id = hp.party_id
		  join apps.hz_cust_site_uses_all hcsua on hcsua.cust_acct_site_id = hcasa.cust_acct_site_id
		  join apps.iby_external_payers_all iepa on iepa.acct_site_use_id = hcsua.site_use_id 
		  join apps.iby_pmt_instr_uses_all ipiua on ipiua.ext_pmt_party_id = iepa.ext_payer_id
		  join apps.iby_ext_bank_accounts eba on eba.ext_bank_account_id = ipiua.instrument_id
		 where 1 = 1
		   and hca.account_number in ('123456')
		   and 1 = 1
	  order by '#' || hca.account_number
			 , eba.bank_account_num
			 , ipiua.order_of_preference;

-- ##################################################################
-- CUSTOMER BANK ACCOUNTS - COUNTING SITE LEVEL (HTTPS://RPFORACLE.BLOGSPOT.COM/2018/12/CUSTOMER-BANK-ACCOUNT-QUERY-IN-ORACLE-APPS.HTML)
-- ##################################################################

		select '#' || hca.account_number account_number
			 , hca.account_name
			 , decode (hca.status, 'I', 'Inactive', 'A', 'Active', 'Other') hdr
			 -- , hp.party_name
			 , '#' || hp.party_number registry_id
			 , hp.party_type
			 , eba.bank_account_num
			 , eba.bank_account_name
			 , ipiua.order_of_preference
			 , count(*) instr_count
			 , min(to_char(ipiua.start_date, 'yyyy-mm-dd')) min_start
			 , max(to_char(ipiua.end_date, 'yyyy-mm-dd')) max_start
		  from apps.hz_cust_accounts hca
		  join apps.hz_cust_acct_sites_all hcasa on hcasa.cust_account_id = hca.cust_account_id
		  join apps.hz_parties hp on hca.party_id = hp.party_id
		  join apps.hz_cust_site_uses_all hcsua on hcsua.cust_acct_site_id = hcasa.cust_acct_site_id
		  join apps.iby_external_payers_all iepa on iepa.acct_site_use_id = hcsua.site_use_id 
		  join apps.iby_pmt_instr_uses_all ipiua on ipiua.ext_pmt_party_id = iepa.ext_payer_id
		  join apps.iby_ext_bank_accounts eba on eba.ext_bank_account_id = ipiua.instrument_id
		 where 1 = 1
		   and hca.account_number = '123456'
		   and 1 = 1
	  group by '#' || hca.account_number
			 , hca.account_name
			 , decode (hca.status, 'I', 'Inactive', 'A', 'Active', 'Other')
			 , eba.bank_account_num
			 , eba.bank_account_name
			 -- , hp.party_name
			 , '#' || hp.party_number
			 , hp.party_type
			 , ipiua.order_of_preference
	  order by '#' || hca.account_number
			 , eba.bank_account_num
			 , ipiua.order_of_preference;
