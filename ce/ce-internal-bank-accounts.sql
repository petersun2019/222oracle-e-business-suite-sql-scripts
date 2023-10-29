/*
File Name: ce-internal-bank-accounts.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- CE BANK ACCOUNTS
-- BANKS AND BRANCHES
-- CE BANK ACCOUNTS
-- CE TRANSACTION CODES

*/

-- ##################################################################
-- CE BANK ACCOUNTS
-- ##################################################################

		select cba.bank_account_name
			 , cba.bank_account_num
			 , cbv.bank_name
			 , cbbv.branch_number
			 , cbbv.bank_branch_name
		  from ce_bank_accounts cba
		  join ce_banks_v cbv on cba.bank_id = cbv.bank_party_id
		  join ce_bank_branches_v cbbv on cbbv.branch_party_id = cba.bank_branch_id
		 where 1 = 1
		   and 1 = 1
		   and cbbv.branch_number = '123456'
	  order by 3 desc;

-- ##################################################################
-- BANKS AND BRANCHES
-- ##################################################################

		select cbv.bank_name
			 , cbbv.branch_number
			 , cbbv.bank_branch_name
		  from ce_banks_v cbv
		  join ce_bank_branches_v cbbv on cbv.bank_party_id = cbbv.bank_party_id
		 where 1 = 1
		   and cbbv.branch_number = '123456'
	  order by 2;

-- ##################################################################
-- CE BANK ACCOUNTS
-- ##################################################################

		select hou.name "operating unit"
			 , hp.party_name "legal entity"
			 , '#' || cba.bank_account_num "account number"
			 , cba.bank_account_name "account name"
			 , cba.iban_number "iban"
			 , '#' || cba.bank_account_name_alt "alternate account name"
			 , cba.short_account_name "short account name"
			 , cba.ap_use_allowed_flag use_ap
			 , cba.ar_use_allowed_flag use_ar
			 , cba.currency_code "currency"
			 , cba.multi_currency_allowed_flag "multiple currencies allowed"
			 , cbbv.bank_name "bank name"
			 , '#' || cbbv.bank_branch_name "branch name"
			 , '#' || cbbv.branch_number "branch number"
			 , gcck1.concatenated_segments "cash"
			 , gcck2.concatenated_segments "bank charges"
			 , gcck3.concatenated_segments "foreign exchange charges"
			 , cba.creation_date "creation date"
			 , fu_cr.user_name || ' (' || fu_cr.description || ')' "created by"
			 , cba.last_update_date "updated date"
			 , fu_up.user_name || ' (' || fu_up.description || ')' "updated by"
		  from ce_bank_accounts cba
		  join ce_bank_acct_uses_all cbau on cba.bank_account_id = cbau.bank_account_id
		  join ce_banks_v cbv on cba.bank_id = cbv.bank_party_id
		  join ce_gl_accounts_ccid cgac on cgac.bank_acct_use_id = cbau.bank_acct_use_id
		  join ce_bank_branches_v cbbv on cba.bank_id = cbbv.bank_party_id and cbbv.branch_party_id = cba.bank_branch_id
		  join hr_operating_units hou on cbau.org_id = hou.organization_id
		  join hz_parties hp on hp.party_id = cba.account_owner_party_id
		  join fnd_user fu_cr on cba.created_by = fu_cr.user_id
		  join fnd_user fu_up on cba.last_updated_by = fu_up.user_id
	 left join gl_code_combinations_kfv gcck1 on gcck1.code_combination_id = cgac.ap_asset_ccid
	 left join gl_code_combinations_kfv gcck2 on gcck2.code_combination_id = cgac.bank_charges_ccid
	 left join gl_code_combinations_kfv gcck3 on gcck3.code_combination_id = cba.fx_charge_ccid
	 left join gl_code_combinations_kfv gcck4 on gcck4.code_combination_id = cgac.cash_clearing_ccid
	 left join gl_code_combinations_kfv gcck5 on gcck5.code_combination_id = cgac.bank_errors_ccid
	 left join gl_code_combinations_kfv gcck6 on gcck6.code_combination_id = cgac.future_dated_payment_ccid
	 left join gl_code_combinations_kfv gcck7 on gcck7.code_combination_id = cgac.on_account_ccid
	 left join gl_code_combinations_kfv gcck8 on gcck8.code_combination_id = cgac.unapplied_ccid
	 left join gl_code_combinations_kfv gcck9 on gcck9.code_combination_id = cgac.unidentified_ccid
	 left join gl_code_combinations_kfv gcck10 on gcck10.code_combination_id = cgac.asset_code_combination_id
	 left join gl_code_combinations_kfv gcck11 on gcck11.code_combination_id = cgac.remittance_ccid
		 where 1 = 1
		   and cba.bank_account_num in ('12345678')
		   -- and cba.bank_account_id in (12345678)
		   and 1 = 1;

-- ##################################################################
-- CE TRANSACTION CODES
-- ##################################################################

		select cba.bank_account_num
			 , cba.bank_account_name
			 , hp.party_name
			 , cbv.bank_name
			 , count(*)
		  from ce_transaction_codes ctc
		  join ce_bank_accounts cba on ctc.bank_account_id = cba.bank_account_id
		  join hz_parties hp on hp.party_id = cba.account_owner_party_id
		  join ce_banks_v cbv on cba.bank_id = cbv.bank_party_id
	  group by cba.bank_account_num
			 , cba.bank_account_name
			 , hp.party_name
			 , cbv.bank_name
	  order by cba.bank_account_num;
