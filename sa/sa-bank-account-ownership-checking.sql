/*
File Name:		sa-bank-account-ownership-checking.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

*/

-- ##################################################################
-- BANK ACCOUNT OWNERSHIP CHECKING
-- ##################################################################

		select distinct hp.party_name
			 , hp.party_type
			 , hp.party_number
			 , hp.*
			 , ieb.bank_name
			 , ieba.bank_account_name
			 , ieba.ext_bank_account_id
			 , ieba.bank_account_num
			 , ieba.branch_id
			 , ieba.creation_date
		  from ar.hz_parties hp
		  join iby.iby_account_owners iao on iao.account_owner_party_id = hp.party_id
		  join iby.iby_ext_bank_accounts ieba on ieba.ext_bank_account_id = iao.ext_bank_account_id
		  join apps.iby_ext_banks_v ieb on ieb.bank_party_id = ieba.bank_id
		 where ieba.bank_account_num = '12345678';
