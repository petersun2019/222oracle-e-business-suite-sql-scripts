/*
File Name: ar-customers.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- HZ PARTIES - COUNT PARTY TYPE
-- AR CUSTOMERS - SUMMARY -- VERSION 1
-- AR CUSTOMERS - SUMMARY -- VERSION 2
-- AR CUSTOMERS - SUMMARY -- VERSION 3
-- AR CUSTOMERS - SUMMARY -- VERSION 4
-- AR CUSTOMERS - SUMMARY -- VERSION 5
-- SITE COUNT SUMMARY
-- RESEARCH CUSTOMERS WITH RESEARCH CONTACTS
-- CUSTOMERS - CHECK IF THEY HAVE ONE SITE BUT NOT ANOTHER

*/

-- ##################################################################
-- HZ PARTIES - COUNT PARTY TYPE
-- ##################################################################

		select hp.party_type
			 , count(*) ct
		  from ar.hz_parties hp
	 left join ar.hz_cust_accounts hca on hp.party_id = hca.party_id
		 where 1 = 1
		   and 1 = 1
	  group by hp.party_type;

-- ##################################################################
-- AR CUSTOMERS - SUMMARY  -- VERSION 1
-- ##################################################################

/*
SUMMARY SHOWING RECEIPTS AND TRANSACTIONS AGAINST CUSTOMERS
YOU COULD SWAP "@" FOR TAB IN NOTEPAD++ THEN PASTE INTO EXCEL TO SPLIT OUT THE INFO
*/

		select hp.party_name
			 , hp.party_number
			 , hca.account_number act_no
			 , hca.account_name
			 , hca.cust_account_id
			 , (select count(*) || '@' || min(acra.creation_date) || '@' || max(acra.creation_date) from apps.ar_cash_receipts_all acra where acra.pay_from_customer = hca.cust_account_id ) rx_info
			 , (select count(*) || '@' || min(rcta.creation_date) || '@' || max(rcta.creation_date) from apps.ra_customer_trx_all rcta where rcta.bill_to_customer_id = hca.cust_account_id) trx_info
		  from ar.hz_cust_accounts hca
		  join ar.hz_parties hp on hp.party_id = hca.party_id
		 where 1 = 1
		   and hca.cust_account_id = 1234
		   and 1 = 1
	  group by hp.party_name
			 , hp.party_number
			 , hca.account_number
			 , hca.account_name
			 , hca.cust_account_id
	  order by hca.account_name;

-- ##################################################################
-- AR CUSTOMERS - SUMMARY -- VERSION 2
-- ##################################################################

		select hca.cust_account_id cust_id
			 , hca.account_number
			 , hp.party_id
			 , hp.party_name
			 , hp.party_number
			 , hp.party_type
			 , hp.creation_date party_created
			 , hp.status party_status
			 , fu.description party_created_by
			 , hca.account_name
			 , hca.creation_date cust_created
			 , hca.status acct_status
			 , fu1.description cust_created_by
			 , hp.tax_reference
			 -- , '##############'
			 -- , hp.*
		  from ar.hz_parties hp
	 left join ar.hz_cust_accounts hca on hp.party_id = hca.party_id -- returns a party without a customer
		  join applsys.fnd_user fu on hp.created_by = fu.user_id
	 left join applsys.fnd_user fu1 on hca.created_by = fu1.user_id
		 where 1 = 1
		   and hca.account_number = '123456'
	  order by hca.creation_date desc;

-- ##################################################################
-- AR CUSTOMERS - SUMMARY -- VERSION 3
-- ##################################################################

		select ' -- PARTY ###########################'
			 , hp.party_id
			 , hp.party_name
			 , hp.party_number
			 , hp.party_type
			 , hp.creation_date party_created
			 , hp.status party_status
			 , hp.last_update_date
			 , hp.tax_reference
			 , ' -- CUSTOMER ###########################'
			 , hca.cust_account_id
			 , hca.account_number
			 , hca.account_name
			 , hca.status account_status
			 , hca.creation_date
			 , fu.description created_by
			 , hca.last_update_date
			 , fu2.user_name last_updated_by
			 , ' -- PARTY SITE ###########################'
			 , hps.party_site_id
			 , hps.creation_date
			 , hps.party_site_number
			 , hps.status party_site_status
			 , hps.last_update_date
			 , ' -- LOCATION ###########################'
			 , hl.location_id
			 , hl.creation_date
			 , hl.address1
			 , hl.address2
			 , hl.address3
			 , hl.address4
			 , hl.city
			 , hl.postal_code
			 , hl.state
			 , hl.province
			 , hl.county
			 , hl.country
			 , hl.last_update_date
			 , ' -- CUST_ACCOUNT_SITES ###########################'
			 , hcasa.cust_acct_site_id
			 , hcasa.creation_date
			 , hcasa.status cust_account_site_status
			 , hcasa.bill_to_flag
			 , hcasa.ship_to_flag
			 , hcasa.last_update_date
			 , ' -- CUST_ACCOUNT_SITE_USES ###########################'
			 , hcsua.site_use_id
			 , hcsua.creation_date
			 , hcsua.last_update_date
			 , hcsua.status site_use_status
			 , hcsua.site_use_code
			 , hcsua.location
			 , hcsua.primary_flag
			 , hcsua.orig_system_reference
			 , hcsua.tax_reference
			 , ' -- HCP ###########################'
			 , hcp.cust_account_profile_id
			 , hcp.send_statements
			 , hcp.dunning_letters
			 , hcp.creation_date
			 , hcp.last_update_date
			 , fu2.email_address updated_by
			 -- , hcp.*
			 -- , (select classes.name from ar.hz_cust_profile_classes classes, ar.hz_customer_profiles profiles where profiles.profile_class_id = classes.profile_class_id and profiles.cust_account_id = hca.cust_account_id  and profiles.site_use_id = hcsua.site_use_id) site_profile_class
			 -- , (select count(*) from ar.hz_cust_site_uses_all hcsua3 where hcsua3.cust_acct_site_id = hcsua.cust_acct_site_id) ct_hcsua222
			 -- , (select count(*) from ar.hz_cust_acct_sites_all hcasa2, ar.hz_cust_site_uses_all hcsua2 where hcsua2.cust_acct_site_id = hcasa2.cust_acct_site_id and hcsua2.orig_system_reference = hcsua.orig_system_reference) ct_hcsua
			 -- , (select count(*) from ar.hz_locations hl2, ar.hz_party_sites hps2 where hl2.location_id = hps2.location_id and hl2.orig_system_reference = hl.orig_system_reference) ct_loc
			 -- , (select count(*) from ar.hz_cust_acct_sites_all hcasa, ar.hz_cust_site_uses_all hcsua where hcasa.cust_account_id = hca.cust_account_id and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id) uses
			 -- , (select count(*) from ar.hz_cust_acct_sites_all hcasa, ar.hz_cust_site_uses_all hcsua where hcasa.cust_account_id = hca.cust_account_id and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id and hcsua.status = 'A') uses_active
			 -- , (select count(*) from ar.hz_cust_acct_sites_all hcasa, ar.hz_cust_site_uses_all hcsua where hcasa.cust_account_id = hca.cust_account_id and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id and hcsua.status = 'I') uses_inactive
			 -- , (select count(*) from ar.hz_cust_acct_sites_all hcasa, ar.hz_cust_site_uses_all hcsua where hcasa.cust_account_id = hca.cust_account_id and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id and hcsua.site_use_code = 'BILL_TO') bill
			 -- , (select count(*) from ar.hz_cust_acct_sites_all hcasa, ar.hz_cust_site_uses_all hcsua where hcasa.cust_account_id = hca.cust_account_id and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id and hcsua.site_use_code = 'BILL_TO' and hcsua.status = 'A') bill_active
			 -- , (select count(*) from ar.hz_cust_acct_sites_all hcasa, ar.hz_cust_site_uses_all hcsua where hcasa.cust_account_id = hca.cust_account_id and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id and hcsua.site_use_code = 'BILL_TO' and hcsua.status = 'I') bill_inactive
			 -- , (select count(*) from ar.hz_cust_acct_sites_all hcasa, ar.hz_cust_site_uses_all hcsua where hcasa.cust_account_id = hca.cust_account_id and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id and hcsua.site_use_code = 'SHIP_TO') ship
			 -- , (select count(*) from ar.hz_cust_acct_sites_all hcasa, ar.hz_cust_site_uses_all hcsua where hcasa.cust_account_id = hca.cust_account_id and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id and hcsua.site_use_code = 'SHIP_TO' and hcsua.status = 'A') ship_active
			 -- , (select count(*) from ar.hz_cust_acct_sites_all hcasa, ar.hz_cust_site_uses_all hcsua where hcasa.cust_account_id = hca.cust_account_id and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id and hcsua.site_use_code = 'SHIP_TO' and hcsua.status = 'I') ship_inactive
		  from ar.hz_parties hp
	 left join ar.hz_party_sites hps on hp.party_id = hps.party_id
	 left join ar.hz_locations hl on hps.location_id = hl.location_id
	 left join ar.hz_cust_accounts hca on hp.party_id = hca.party_id
	 left join ar.hz_cust_acct_sites_all hcasa on hcasa.party_site_id = hps.party_site_id and hca.cust_account_id = hcasa.cust_account_id
	 left join ar.hz_cust_site_uses_all hcsua on hcsua.cust_acct_site_id = hcasa.cust_acct_site_id
	 left join ar.hz_customer_profiles hcp on hcp.cust_account_id = hca.cust_account_id and hcp.site_use_id is null
	 left join applsys.fnd_user fu on hca.created_by = fu.user_id
	 left join applsys.fnd_user fu2 on hca.last_updated_by = fu2.user_id
		 where 1 = 1
		   and hp.party_id = 123456
		   -- and hca.account_number in ('123456')
		   -- and hl.city = 'London' 
		   -- and hp.party_name = 'Cheese'
		   -- and lower(hp.party_name) like 'cheese%'
		   -- and hca.cust_account_id = 123456
		   -- and hl.location_id in (123456)
		   -- and hcp.cust_account_profile_id is null
		   -- and hcp.creation_date > '01-NOV-2015'
		   -- and hca.creation_date > '01-JAN-2015'
		   -- and hcsua.site_use_id in (123456)
		   -- and hca.account_number in ('123456')
		   -- and hp.status = 'A'
		   -- and hca.status = 'A'
		   -- and hcasa.status = 'A'
		   -- and hcsua.status = 'A'
		   -- and hcsua.site_use_code = 'BILL_TO'
		   -- and hp.party_type = 'ORGANIZATION'
		   -- and hcsua.primary_flag = 'Y'
		   and 1 = 1;

-- ##################################################################
-- AR CUSTOMERS - SUMMARY -- VERSION 4
-- ##################################################################

		select hp.party_name
			 , hp.party_number
			 , hp.party_type
			 , hp.party_id
			 , hp.creation_date hp_cr
			 , fu_hp.user_name hp_cr_by
			 , 'hca'
			 , hca.account_number acnum
			 , hca.account_name
			 , hca.cust_account_id cust_id
			 , hca.creation_date hca_cr
			 , fu_hca.user_name hca_cr_by
			 , hca.last_update_date hca_updated
			 , decode (hca.status, 'I', 'Inactive', 'A', 'Active', 'Other') hdr
			 , 'hps'
			 , hps.party_site_id
			 , hps.party_site_number site_num
			 , hps.status
			 , hps.creation_date hps_cr
			 , hl.location_id
			 , hl.address1
			 , hl.address2
			 , hl.address3
			 , hl.address4
			 , hl.city
			 , hl.state
			 , hl.postal_code
			 , trim(hl.address1) || case when trim(hl.address2) is not null and trim(hl.address2) not in (',','.','..','-') then ', ' || trim(hl.address2) end || case when trim(hl.address3) is not null and trim(hl.address3) not in (',','.','..','-') then ', ' || trim(hl.address3) end || case when trim(hl.address4) is not null and trim(hl.address4) not in (',','.','..','-') then ', ' || trim(hl.address4) end || case when trim(hl.city) is not null and trim(hl.city) not in (',','.','..','-') then ', ' || trim(hl.city) end || case when trim(hl.state) is not null and trim(hl.state) not in (',','.','..','-') then ', ' || trim(hl.state) end || case when trim(hl.postal_code) is not null and trim(hl.postal_code) not in (',','.','..','-','No post code') then ', ' || trim(hl.postal_code) end || ', ' || trim(ftt. territory_short_name) address
			 , hl.creation_date hl_created
			 , 'hcasa'
			 , hcasa.cust_acct_site_id
			 , decode (hcasa.status, 'I', 'Inactive', 'A', 'Active', 'Other') site
			 , hcasa.creation_date hcasa_cr
			 , hcasa.bill_to_flag
			 , hcasa.ship_to_flag
			 , 'hcsua'
			 , hcsua.last_update_date
			 , hcsua.site_use_id
			 , hcsua.status
			 , hcsua.site_use_code site_use
			 , hcsua.location
			 , hcsua.primary_flag prim
			 , hcsua.creation_date hcsua_cr
			 , hcsua.last_update_date hcsua_updated
			 , hcsua.request_id
			 , hcsua.bill_to_site_use_id
			 -- , (select classes.name from ar.hz_cust_profile_classes classes, ar.hz_customer_profiles profiles where profiles.profile_class_id = classes.profile_class_id and profiles.cust_account_id = hca.cust_account_id and profiles.site_use_id = hcsua.site_use_id) site_profile_class
			 , acpcv.profile_class_name account_profile_class
			 , acpcv.collector_name account_collector
			 , hcp.creation_date, hcp.created_by
		  from ar.hz_parties hp
	 left join ar.hz_party_sites hps on hp.party_id = hps.party_id
	 left join ar.hz_locations hl on hps.location_id = hl.location_id
	 left join ar.hz_cust_accounts hca on hp.party_id = hca.party_id
	 left join ar.hz_cust_acct_sites_all hcasa on hcasa.party_site_id = hps.party_site_id and hca.cust_account_id = hcasa.cust_account_id
	 left join ar.hz_cust_site_uses_all hcsua on hcsua.cust_acct_site_id = hcasa.cust_acct_site_id
	 left join applsys.fnd_user fu_hp on hp.created_by = fu_hp.user_id
	 left join applsys.fnd_user fu_hca on hca.created_by = fu_hca.user_id
	 left join applsys.fnd_territories_tl ftt on hl.country = ftt.territory_code
	 left join apps.ar_customer_profile_classes_v acpcv on acpcv.profile_class_name = hca.customer_class_code
	 left join ar.ar_collectors ac on acpcv.collector_id = ac.collector_id
	 left join ar.hz_customer_profiles hcp on hcp.site_use_id = hcsua.site_use_id 
		 where 1 = 1
		   and hca.account_number in (123456)
		   and hcsua.site_use_code = 'BILL_TO'
		   -- and hcp.creation_date > '01-NOV-2015'
		   and 1 = 1;

-- ##################################################################
-- AR CUSTOMERS - SUMMARY -- VERSION 5
-- ##################################################################

		select distinct hp.party_number
			 , hca.cust_account_id customer_id
			 , hcsua.cust_acct_site_id
			 , hcsua.site_use_id
			 , hp.party_name
			 , hp.customer_key
			 , hp.party_type
			 , hca.account_number
			 , hca.account_name
			 , hcp_header.credit_hold credit_hold_header
			 , hcp_site.credit_hold credit_hold_site
			 , decode (hca.status, 'I', 'Inactive', 'A', 'Active', 'Other') account_status
			 , hca.customer_class_code
			 , acpcv.profile_class_description
			 , acpcv.collector_name
			 , (select terms.name 
				  from ar.hz_customer_profiles hcp_header
					 , apps.ra_terms_vl terms
				 where hcp_header.standard_terms = terms.term_id
				   and hcp_header.site_use_id is null 
				   and hcp_header.cust_account_id = hca.cust_account_id) payment_terms
			 , hcp_header.send_statements send_statement_flag
			 , (select statements.name 
				  from ar.hz_customer_profiles hcp_header
					 , ar.ar_statement_cycles statements 
				 where hcp_header.statement_cycle_id = statements.statement_cycle_id
				   and hcp_header.site_use_id is null 
				   and hcp_header.cust_account_id = hca.cust_account_id) statement_cycle
			 , hcp_header.credit_balance_statements send_cred_bal_flag
			 , hcp_header.dunning_letters send_dun_let_flag
			 , trunc(hca.creation_date) account_created_on
			 , fu.description account_created_by_desc
			 , fu.user_name account_created_by_uname
			 , trunc(hca.last_update_date) last_update_date
			 , hp.tax_reference tax_reg_number
			 , hps.party_site_number site_number
			 , (select meaning
				  from apps.ar_lookups
				 where lookup_type = 'site_use_code'
				   and lookup_code = hcsua.site_use_code) site_purpose
			 , decode (hcsua.status, 'I', 'Inactive', 'A', 'Active', 'Other') site_status
			 , hcsua.location
			 , hl.address1 add_line1
			 , hl.address2 add_line2
			 , hl.address3 add_line3
			 , hl.address4 add_line4
			 , hl.city add_city
			 , hl.state add_county
			 , hl.postal_code add_post_code
			 , ftt.territory_short_name add_country_long
			 , hcsua.primary_flag
			 , (select classes.name
				  from ar.hz_cust_profile_classes classes
					 , ar.hz_customer_profiles profiles 
				 where profiles.profile_class_id = classes.profile_class_id
				   and profiles.cust_account_id = hca.cust_account_id 
				   and profiles.site_use_id = hcsua.site_use_id) site_profile_class
			 , (select collectors.name 
				  from ar.ar_collectors collectors
					 , ar.hz_customer_profiles profiles 
				 where collectors.collector_id = profiles.collector_id
				   and profiles.cust_account_id = hca.cust_account_id
				   and profiles.site_use_id = hcsua.site_use_id) site_collector
			 , (select terms.name 
				  from ar.hz_customer_profiles hcp_header
					 , apps.ra_terms_vl terms 
				 where hcp_header.standard_terms = terms.term_id 
				   and hcp_header.site_use_id = hcsua.site_use_id 
				   and hcp_header.cust_account_id = hca.cust_account_id) site_payment_terms
			 , hcp_site.credit_hold site_credit_hold
			 , hcp_header.send_statements site_send_statement_flag
			 , hcp_header.credit_balance_statements site_send_cred_bal_flag
			 , hcp_header.dunning_letters site_send_dun_let_flag
			 , tbl_contacts.email_address dun_email_add
			 , tbl_contacts.primary_flag dun_email_add_primary
			 , (select trunc (max (rcta.creation_date)) from ar.ra_customer_trx_all rcta where rcta.bill_to_customer_id = hca.cust_account_id) last_transaction_date
			 , nvl((select sum (acctd_amount_due_remaining) from ar_payment_schedules_all where customer_id = hca.cust_account_id), 0.00) account_balance
			 , gcc1.concatenated_segments revenue_code
			 , gcc2.concatenated_segments rec_code
		  from ar.hz_parties hp
		  join ar.hz_party_sites hps on hp.party_id = hps.party_id
		  join ar.hz_cust_accounts hca on hp.party_id = hca.party_id
		  join ar.hz_cust_acct_sites_all hcasa on hca.cust_account_id = hcasa.cust_account_id and hcasa.party_site_id = hps.party_site_id
		  join ar.hz_cust_site_uses_all hcsua on hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
		  join ar.hz_locations hl on hps.location_id = hl.location_id
		  join applsys.fnd_user fu on hca.created_by = fu.user_id
		  join applsys.fnd_territories_tl ftt on hl.country = ftt.territory_code
	 left join ar.hz_customer_profiles hcp_header on hca.cust_account_id = hcp_header.cust_account_id
	 left join ar.hz_customer_profiles hcp_site on hcsua.site_use_id = hcp_site.site_use_id
	 left join apps.ar_customer_profile_classes_v acpcv on hca.customer_class_code = acpcv.profile_class_name
	 left join apps.gl_code_combinations_kfv gcc1 on hcsua.gl_id_rev = gcc1.code_combination_id
	 left join apps.gl_code_combinations_kfv gcc2 on hcsua.gl_id_rec = gcc2.code_combination_id
		  join (select contacts.primary_flag
					 , contacts.email_address
					 , contacts.owner_table_id
				  from ar.hz_contact_points contacts
				 where contacts.contact_point_type = 'EMAIL'
				   and contacts.owner_table_name = 'HZ_PARTY_SITES') tbl_contacts on hps.party_site_id = tbl_contacts.owner_table_id
		 where 1 = 1
		   and hcsua.site_use_id = 123456
		   -- and hca.account_number = 123456
		   -- and hcsua.site_use_id in (123456)
		   -- and hcsua.site_use_code = 'BILL_TO'
		   -- and hcsua.primary_flag = 'Y'
		   and 1 = 1;

-- ##################################################################
-- SITE COUNT SUMMARY
-- ##################################################################

		select hca.account_number ac_no
			 , hca.account_name
			 , decode (hca.status, 'I', 'Inactive', 'A', 'Active', 'Other') acc_status
			 , (select count(*) from ar.hz_cust_acct_sites_all hcasa where hcasa.cust_account_id = hca.cust_account_id) sites
			 , (select count(*) from ar.hz_cust_acct_sites_all hcasa where hcasa.cust_account_id = hca.cust_account_id and hcasa.status = 'A') site_active
			 , (select count(*) from ar.hz_cust_acct_sites_all hcasa where hcasa.cust_account_id = hca.cust_account_id and hcasa.status = 'I') site_inactive
			 , (select count(*) from ar.hz_cust_acct_sites_all hcasa, ar.hz_cust_site_uses_all hcsua where hcasa.cust_account_id = hca.cust_account_id and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id) uses
			 , (select count(*) from ar.hz_cust_acct_sites_all hcasa, ar.hz_cust_site_uses_all hcsua where hcasa.cust_account_id = hca.cust_account_id and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id and hcsua.status = 'A') uses_active
			 , (select count(*) from ar.hz_cust_acct_sites_all hcasa, ar.hz_cust_site_uses_all hcsua where hcasa.cust_account_id = hca.cust_account_id and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id and hcsua.status = 'I') uses_inactive
			 , (select count(*) from ar.hz_cust_acct_sites_all hcasa, ar.hz_cust_site_uses_all hcsua where hcasa.cust_account_id = hca.cust_account_id and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id and hcsua.site_use_code = 'BILL_TO') bill
			 , (select count(*) from ar.hz_cust_acct_sites_all hcasa, ar.hz_cust_site_uses_all hcsua where hcasa.cust_account_id = hca.cust_account_id and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id and hcsua.site_use_code = 'BILL_TO' and hcsua.status = 'A') bill_active
			 , (select count(*) from ar.hz_cust_acct_sites_all hcasa, ar.hz_cust_site_uses_all hcsua where hcasa.cust_account_id = hca.cust_account_id and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id and hcsua.site_use_code = 'BILL_TO' and hcsua.status = 'I') bill_inactive
			 , (select count(*) from ar.hz_cust_acct_sites_all hcasa, ar.hz_cust_site_uses_all hcsua where hcasa.cust_account_id = hca.cust_account_id and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id and hcsua.site_use_code = 'SHIP_TO') ship
			 , (select count(*) from ar.hz_cust_acct_sites_all hcasa, ar.hz_cust_site_uses_all hcsua where hcasa.cust_account_id = hca.cust_account_id and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id and hcsua.site_use_code = 'SHIP_TO' and hcsua.status = 'A') ship_active
			 , (select count(*) from ar.hz_cust_acct_sites_all hcasa, ar.hz_cust_site_uses_all hcsua where hcasa.cust_account_id = hca.cust_account_id and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id and hcsua.site_use_code = 'SHIP_TO' and hcsua.status = 'I') ship_inactive
		  from ar.hz_parties hp
		  join ar.hz_cust_accounts hca on hp.party_id = hca.party_id
		 where 1 = 1
		   and hca.account_number in (123456)
		   and hca.status = 'A'
		   and hp.status = 'A'
		   -- and hca.creation_date > '01-FEB-2015'
		   and hp.party_type = 'ORGANIZATION'
		   and 1 = 1
	  order by hca.account_name;

-- ##################################################################
-- RESEARCH CUSTOMERS WITH RESEARCH CONTACTS
-- ##################################################################

		select distinct hca.account_number acnum
			 , hca.last_update_date
			 , hca.cust_account_id customer_id
			 , hp.party_name
			 , hp.party_id
			 , tbl_contacts.up_dt
			 , hcsua.site_use_code site_use
			 , decode (hca.status, 'I', 'Inactive', 'A', 'Active', 'Other') hdr
			 , hca.cust_account_id cust_id
			 , hps.party_site_number site_num
			 , hps.location_id
			 , hcsua.cust_acct_site_id site_id
			 , hcsua.location
			 , hcsua.primary_flag prim
			 , decode (hcasa.status, 'I', 'Inactive', 'A', 'Active', 'Other') site
			 , hcasa.creation_date
			 , fu.description cr_by
			 , hl.address1 || ' ' || hl.address2 || ' ' || hl.address3 || ' ' || hl.address4 || ' ' || hl.city street_address
		  from ar.hz_parties hp
		  join ar.hz_party_sites hps on hp.party_id = hps.party_id
		  join ar.hz_locations hl on hps.location_id = hl.location_id
		  join ar.hz_cust_accounts hca on hp.party_id = hca.party_id
		  join ar.hz_cust_acct_sites_all hcasa on hcasa.party_site_id = hps.party_site_id
		   and hca.cust_account_id = hcasa.cust_account_id
		  join ar.hz_cust_site_uses_all hcsua on hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
		  join applsys.fnd_user fu on hcsua.created_by = fu.user_id
		  join (select distinct acct_role.cust_account_id
					 , acct_role.last_update_date up_dt 
				  from ar.hz_cust_account_roles acct_role
				  join ar.hz_relationships rel on acct_role.party_id = rel.party_id
				  join ar.hz_org_contacts org_cont on rel.relationship_id = org_cont.party_relationship_id
				  join ar.hz_parties party on party.party_id = rel.subject_id
				 where 1 = 1
				   and rel.subject_type = 'PERSON'
				   and rel.object_table_name = 'HZ_PARTIES'
				   and rel.subject_table_name = 'HZ_PARTIES'
				   and acct_role.role_type = 'CONTACT'
				   and party.person_last_name = 'Research') tbl_contacts on hca.cust_account_id = tbl_contacts.cust_account_id
		 where 1 = 1
		   and hcsua.site_use_code = 'BILL_TO'
		   and hca.last_update_date > '01-JUN-2015'
		   -- and hca.account_number in (123456)
		   and hca.status = 'A'
		   and hcasa.status = 'A' 
		   -- and hcsua.primary_flag = 'Y'
	  order by hca.last_update_date desc;

-- ##################################################################
-- CUSTOMERS - CHECK IF THEY HAVE ONE SITE BUT NOT ANOTHER
-- ##################################################################

		select e.acnum
			 , e.party_name
			 , e.cust_id
			 , e.cust_num
			 , e.party_id
			 , e.cc
		  from 
	   (select hca.account_number acnum
			 , hp.party_name
			 , hca.cust_account_id cust_id
			 , hca.account_number cust_num
			 , hca.party_id
			 , hca.customer_class_code cc
			 , hcsua.site_use_code site_use
		  from ar.hz_parties hp
		  join ar.hz_party_sites hps on hp.party_id = hps.party_id
		  join ar.hz_cust_accounts hca on hp.party_id = hca.party_id
		  join ar.hz_cust_acct_sites_all hcasa on hcasa.party_site_id = hps.party_site_id
		  join ar.hz_cust_site_uses_all hcsua on hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
		 where 1 = 1
		   and hca.status = 'A'
		   and hcasa.status = 'A'
		   and 1 = 1) e
		 where e.site_use in ('BILL_TO', 'SHIP_TO')
	  group by e.acnum
			 , e.party_name
			 , e.cust_id
			 , e.party_id
			 , e.cc
 having count (distinct site_use) = 1;
