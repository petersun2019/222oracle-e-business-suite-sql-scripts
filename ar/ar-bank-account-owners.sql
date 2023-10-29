/*
File Name: ar-bank-account-owners.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- BANK ACCOUNT NUMBER QUERY : BANK NAME, CUSTOMR NAME, PARTY NUMBER AND CUST ACCOUNT NUMBER 
-- ##################################################################

		select distinct hou.name "oracle ou"
			 , hp.party_name "customer name"
			 , hp.party_number
			 , hca.account_number
			 , hcsua.location
			 , hps.party_site_number
			 , ieb.bank_name
			 , ieba.bank_account_name
			 , ieba.bank_account_num
			 , ieba.branch_id
			 , ieba.creation_date
		  from ar.hz_parties hp
		  join iby.iby_account_owners iao on iao.account_owner_party_id = hp.party_id
		  join ar.hz_party_sites hps on hp.party_id = hps.party_id
		  join ar.hz_cust_accounts hca on hca.party_id = hp.party_id
		  join iby.iby_ext_bank_accounts ieba on ieba.ext_bank_account_id = iao.ext_bank_account_id
		  join apps.iby_ext_banks_v ieb on ieb.bank_party_id = ieba.bank_id
		  join ar.hz_cust_acct_sites_all hcas on hcas.party_site_id = hps.party_site_id 
		  join hr.hr_all_organization_units hou on hcas.org_id = hou.organization_id
		  join ar.hz_cust_site_uses_all hcsua on hcsua.cust_acct_site_id = hcas.cust_acct_site_id
		   and hca.cust_account_id = hcas.cust_account_id
		 where 1 = 1
		   -- and hca.account_number = 12345678
		   and ieba.ext_bank_account_id = 123456
		   -- and ieba.creation_date > '01-NOV-2014'
		   and 1 = 1;

