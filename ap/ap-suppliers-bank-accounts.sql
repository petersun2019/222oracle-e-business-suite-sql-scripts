/*
File Name: ap-suppliers-bank-accounts.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- SUPPLIER BANK ACCOUNTS 1
-- SUPPLIER BANK ACCOUNTS 2
-- SUPPLIER BANK ACCOUNTS 3
-- AP FIX FOR EXTERNAL BANK ACCOUNT ALREADY EXISTS
-- BANK ACCOUNTS AT DIFFERENT LEVELS
-- SUPPLIER BANK ACCOUNTS - ANOTHER VERSION

*/

-- ##################################################################
-- SUPPLIER BANK ACCOUNTS 1
-- ##################################################################

		select sup.segment1
			 , piu.creation_date
			 , sup.vendor_name
			 , sup.vendor_id
			 , hou.name org
			 , epa.org_id
			 , ss.vendor_site_id
			 , ss.vendor_site_code
			 , eba.iban
			 , '#' || eba.bank_account_num bank_acct_num
			 , '#' || eba.masked_bank_account_num masked_bank_account_num
			 , '#' || eba.bank_account_num_electronic elec_bank_account_num
			 , eba.bank_account_name
			 , iebb.branch_number branch
			 , piu.creation_date
			 , epa.last_update_date
			 , piu.order_of_preference priority
			 , eba.ext_bank_account_id
		  from ap_suppliers sup
			 , ap_supplier_sites_all ss
			 , iby_external_payees_all epa
			 , iby_pmt_instr_uses_all piu
			 , iby_ext_bank_accounts eba
			 , iby_ext_bank_branches_v iebb
			 , hr_operating_units hou
		 where sup.vendor_id = ss.vendor_id
		   and ss.vendor_site_id = epa.supplier_site_id
		   and epa.ext_payee_id = piu.ext_pmt_party_id 
		   and piu.instrument_id = eba.ext_bank_account_id
		   and eba.branch_id = iebb.branch_party_id
		   and ss.org_id = hou.organization_id
		   and sup.segment1 = '123456'
		   and 1 = 1;

-- ##################################################################
-- SUPPLIER BANK ACCOUNTS 2
-- ##################################################################

		select '#' || ieba.bank_account_num acct_num
			 , ieba.ext_bank_account_id
			 , aps.vendor_name supplier
			 , aps.segment1 supp_num
			 , apss.org_id
			 , haou.name org
			 , to_char(aps.creation_date, 'DD-MM-YYYY HH24:MI:SS') supplier_created
			 , fu3.user_name supplier_created_by
			 , to_char(apss.creation_date, 'DD-MM-YYYY HH24:MI:SS') site_created
			 , fu4.user_name site_created_by
			 , apss.vendor_site_code site
			 , aps.vendor_id
			 , apss.vendor_site_id
			 , (select max(creation_date) from ap_invoices_all aiii where aiii.vendor_id = aps.vendor_id) latest_invoice_supplier
			 , (select max(creation_date) from ap_invoices_all aiiii where aiiii.vendor_site_id = apss.vendor_site_id) latest_invoice_site
			 , aps.creation_date supplier_created
			 , apss.creation_date site_created
			 , apss.vendor_site_code_alt cogs_ref
			 , ieba.masked_bank_account_num
			 , ieba.currency_code
			 , ieba.bank_account_name acct_name
			 , ieba.ba_mask_setting
			 , ieba.ba_unmask_length
			 , ieb.bank_name bank
			 , iebb.branch_number branch
			 , iebb.bank_branch_name
			 , to_char(ieba.creation_date, 'DD-MM-YYYY HH24:MI:SS') bank_account_created
			 , fu5.user_name bank_account_created_by
			 , to_char(ieba.last_update_date, 'DD-MM-YYYY HH24:MI:SS') bank_account_updated
			 , fu2.user_name bank_account_updated_by
			 -- , '##########################'
			 -- , iepa.*
			 -- , iebb.creation_date branch_created
			 , '################'
			 , ipiua.instrument_payment_use_id
			 , to_char(ipiua.creation_date, 'DD-MM-YYYY HH24:MI:SS') ipiua_created
			 , fu6.user_name ipiua_created_by
			 -- , '##########################'
			 -- , ipiua.*
		  from ap_suppliers aps
		  join ap_supplier_sites_all apss on aps.vendor_id = apss.vendor_id
	 left join hr_all_organization_units haou on apss.org_id = haou.organization_id
		  join iby_external_payees_all iepa on iepa.supplier_site_id = apss.vendor_site_id
		  join iby_pmt_instr_uses_all ipiua on ipiua.ext_pmt_party_id = iepa.ext_payee_id
		  join iby_ext_bank_accounts ieba on ipiua.instrument_id = ieba.ext_bank_account_id
		  join iby_ext_bank_branches_v iebb on ieba.branch_id = iebb.branch_party_id
		  join iby_ext_banks_v ieb on ieb.bank_party_id = iebb.bank_party_id and ieba.bank_id = ieb.bank_party_id
		  join hz_parties hz_bank on hz_bank.party_id = ieb.bank_party_id
		  join hz_parties hz_branch on hz_branch.party_id = iebb.branch_party_id
		  join fnd_user fu1 on iebb.created_by = fu1.user_id
		  join fnd_user fu2 on ieba.last_updated_by = fu2.user_id
		  join fnd_user fu3 on aps.created_by = fu3.user_id
		  join fnd_user fu4 on apss.created_by = fu4.user_id
		  join fnd_user fu5 on ieba.created_by = fu5.user_id
		  join fnd_user fu6 on ipiua.created_by = fu6.user_id
		 where 1 = 1
		   and aps.segment1 = '123456'
		   and 1 = 1;

-- ##################################################################
-- SUPPLIER BANK ACCOUNTS 3
-- ##################################################################

		select aps.vendor_name "vendor name"
			 , aps.vendor_id
			 , aps.creation_date supplier_created
			 , fu_supplier.user_name || ' (' || fu_supplier.description || ')' supplier_created_by
			 , aps.created_by supplier_cr_by
			 , null, null, null, null, null, '####################################'
			 , apss.vendor_site_code "vendor site code"
			 , apss.vendor_site_id
			 , apss.party_site_id
			 , apss.creation_date site_created
			 , apss.vendor_site_code_alt
			 , null, null, null, null, null, '####################################'
			 , ieba.bank_id
			 , ieb.bank_name "bank name"
			 , ieb.bank_number
			 , ieb.bank_party_id
			 , null, null, null, null, null
			 , iebb.branch_party_id
			 , iebb.branch_party_id
			 , null, null, null, null, null, '####################################'
			 , iebb.branch_number "branch number"
			 , null, null, null, null, null
			 , ieba.ext_bank_account_id
			 , ieba.bank_account_num "bank account number"
			 , ieba.bank_account_name "bank account name"
			 , ieba.branch_id
			 , ieba.creation_date ieba_created
			 , fu_ieba.user_name ieba_cr_by
			 , ipiua.instrument_payment_use_id
			 , ieba.iban
			 , ieba.currency_code
			 , null, null, null, null, null, '####################################'
			 , apss.creation_date supplier_site_created
			 , apss.created_by supplier_site_cr_by
			 , iao.creation_date iby_account_owners_created
			 , iao.created_by iby_account_owners_cr_by
			 , iao.account_owner_party_id
			 , hz_bank.creation_date bank_party_created
			 , hz_bank.created_by bank_party_cr_by
			 , fu_bank.user_name bank_created_by
			 , hz_branch.creation_date bank_site_party_created
			 , hz_branch.created_by bank_site_party_cr_by
			 , fu_branch.user_name branch_created_by
			 , '#####################################'
			 , iepa.*
		  from ap_suppliers aps
	 left join ap_supplier_sites_all apss on aps.vendor_id = apss.vendor_id
	 left join iby_account_owners iao on iao.account_owner_party_id = aps.party_id
	 left join iby_ext_bank_accounts ieba on ieba.ext_bank_account_id = iao.ext_bank_account_id
	 left join iby_pmt_instr_uses_all ipiua on ipiua.instrument_id = ieba.ext_bank_account_id
	 left join iby_ext_bank_branches_v iebb on ieba.branch_id = iebb.branch_party_id
	 left join iby_external_payees_all iepa on ipiua.ext_pmt_party_id = iepa.ext_payee_id and iepa.payee_party_id = aps.party_id and iepa.party_site_id = apss.party_site_id
	 left join iby_ext_banks_v ieb on ieb.bank_party_id = iebb.bank_party_id and ieba.bank_id = ieb.bank_party_id
	 left join hz_parties hz_bank on hz_bank.party_id = ieb.bank_party_id
	 left join hz_parties hz_branch on hz_branch.party_id = iebb.branch_party_id
	 left join fnd_user fu_bank on hz_bank.created_by = fu_bank.user_id
	 left join fnd_user fu_branch on hz_branch.created_by = fu_branch.user_id
	 left join fnd_user fu_supplier on aps.created_by = fu_supplier.user_id
	 left join fnd_user fu_ieba on ieba.created_by = fu_ieba.user_id
		 where 1 = 1
		   and aps.vendor_id = 123456
		   and 1 = 1
	  order by aps.creation_date desc;

-- ##################################################################
-- AP FIX FOR EXTERNAL BANK ACCOUNT ALREADY EXISTS
-- ##################################################################

/*
r12: ap: the external bank account already exists but unable to search via search supplier bank account assignment (doc id 1994729.1)
*/

-- CHECK THE BANK ACCOUNT WITH THE ACCOUNT OWNER AND NO ASSIGNMENT --

		select eba.ext_bank_account_id
			 , eba.country_code
			 , eba.branch_id
			 , eba.bank_id
			 , eba.bank_account_num
			 , eba.currency_code
			 , eba.bank_account_name
		  from iby_ext_bank_accounts eba
		 where exists
			(select 'OWNER'
					  from iby_account_owners
					 where account_owner_party_id <> -99
					   and ext_bank_account_id = eba.ext_bank_account_id
			)
		   and not exists
			(select 'ASSIGNMENT'
					  from iby_pmt_instr_uses_all
					 where instrument_type = 'BANKACCOUNT'
					   and instrument_id = eba.ext_bank_account_id
			);

-- CHECK THE OWNER OF THE BANK ACCOUNT --

		select party_id
			 , party_name
		  from hz_parties
		 where party_id in (select account_owner_party_id
							  from iby_account_owners
							 where account_owner_party_id <> -99
							   and ext_bank_account_id = &ext_bank_account_id);

-- ##################################################################
-- BANK ACCOUNTS AT DIFFERENT LEVELS
-- ##################################################################

/*
HTTPS://SANJAIMISRA.BLOGSPOT.CO.UK/2011/12/SUPPLIER-BANK-ACCOUNT-DETAILS.HTML
*/

		select 'Bank Account At Supplier Site Level' bank_account_level
			 , sup.segment1
			 , sup.vendor_name
			 , epa.org_id
			 , ss.vendor_site_code
			 , null party_site_code
			 , eba.bank_account_num
			 , piu.order_of_preference priority
			 , eba.ext_bank_account_id
		  from ap_suppliers sup
			 , ap_supplier_sites_all ss
			 , iby_external_payees_all epa
			 , iby_pmt_instr_uses_all piu
			 , iby_ext_bank_accounts eba
		 where sup.vendor_id = ss.vendor_id
		   and ss.vendor_site_id = epa.supplier_site_id
		   and epa.ext_payee_id = piu.ext_pmt_party_id 
		   and piu.instrument_id = eba.ext_bank_account_id
		   and sup.segment1 = '123456'
		 union
		select 'Bank Account at Supplier Level'
			 , sup.segment1
			 , sup.vendor_name
			 , epa.org_id
			 , null
			 , null
			 , eba.bank_account_num
			 , piu.order_of_preference priority
			 , eba.ext_bank_account_id
		  from ap_suppliers sup
			 , iby_external_payees_all epa
			 , iby_pmt_instr_uses_all piu
			 , iby_ext_bank_accounts eba
		 where sup.party_id = epa.payee_party_id
		   and epa.ext_payee_id = piu.ext_pmt_party_id 
		   and piu.instrument_id = eba.ext_bank_account_id
		   and sup.segment1 = '123456'
		   and supplier_site_id is null
		   and party_site_id is null
		 union
		select 'Bank Account at Address + Opearting Unit Level'
			 , sup.segment1
			 , sup.vendor_name
			 , epa.org_id
			 , null
			 , psite.party_site_name
			 , eba.bank_account_num
			 , piu.order_of_preference priority
			 , eba.ext_bank_account_id
		  from ap_suppliers sup
			 , hz_party_sites psite
			 , iby_external_payees_all epa
			 , iby_pmt_instr_uses_all piu
			 , iby_ext_bank_accounts eba
		 where sup.party_id = psite.party_id
		   and psite.party_site_id = epa.party_site_id
		   and epa.ext_payee_id = piu.ext_pmt_party_id 
		   and piu.instrument_id = eba.ext_bank_account_id
		   and sup.segment1 = '123456'
		   and supplier_site_id is null
		   and epa.org_id is not null
		 union
		select 'Bank Account at Address Level'
			 , sup.segment1
			 , sup.vendor_name
			 , epa.org_id
			 , null
			 , psite.party_site_name
			 , eba.bank_account_num
			 , piu.order_of_preference priority
			 , eba.ext_bank_account_id
		  from ap_suppliers sup
			 , hz_party_sites psite
			 , iby_external_payees_all epa
			 , iby_pmt_instr_uses_all piu
			 , iby_ext_bank_accounts eba
		 where sup.party_id = psite.party_id
		   and psite.party_site_id = epa.party_site_id
		   and epa.ext_payee_id = piu.ext_pmt_party_id 
		   and piu.instrument_id = eba.ext_bank_account_id
		   and sup.segment1 = '123456'
		   and supplier_site_id is null
		   and epa.org_id is null
	  order by bank_account_num;

-- ##################################################################
-- SUPPLIER BANK ACCOUNTS - ANOTHER VERSION
-- ##################################################################

/*
HTTP://ONLYAPPSR12.BLOGSPOT.CO.UK/2010/07/R12-SUPPLIER-BANK-ACCOUNTS_5090.HTML
*/

		select hp.party_name supplier_name
			 , sup.segment1 supplier_number
			 , assa.vendor_site_code supplier_site
			 , ieb.bank_account_num
			 , ieb.bank_account_name
			 , ieb.currency_code
			 , party_bank.party_name bank_name
			 , branch_prof.bank_or_branch_number bank_number
			 , party_branch.party_name branch_name
			 , branch_prof.bank_or_branch_number branch_number
		  from hz_parties hp
			 , ap_suppliers sup
			 , hz_party_sites hps
			 , ap_supplier_sites_all assa
			 , iby_external_payees_all iep
			 , iby_pmt_instr_uses_all ipi
			 , iby_ext_bank_accounts ieb
			 , hz_parties party_bank
			 , hz_parties party_branch
			 , hz_organization_profiles bank_prof
			 , hz_organization_profiles branch_prof
		 where hp.party_id = sup.party_id
		   and hp.party_id = hps.party_id
		   and hps.party_site_id = assa.party_site_id
		   and assa.vendor_id = sup.vendor_id
		   and iep.payee_party_id = hp.party_id
		   and iep.party_site_id = hps.party_site_id
		   and iep.supplier_site_id = assa.vendor_site_id
		   and iep.ext_payee_id = ipi.ext_pmt_party_id
		   and ipi.instrument_id = ieb.ext_bank_account_id
		   and ieb.bank_id = party_bank.party_id
		   and ieb.bank_id = party_branch.party_id
		   and party_branch.party_id = branch_prof.party_id
		   and party_bank.party_id = bank_prof.party_id
		   and ieb.bank_account_num = '12345678'
	  order by 1, 3;
