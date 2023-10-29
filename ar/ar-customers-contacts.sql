/*
File Name:		ar-customers-contacts.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- CUSTOMER CONTACTS
-- ##################################################################

		select rel.object_id party_id
			 , role_acct.cust_account_id customer_id
			 , hca.account_number
			 , hca.account_name
			 , cont_point.primary_flag
			 , party.party_type
			 , org_cont.contact_number
			 , party.party_name contact_name
		  from apps.hz_relationships rel
		  join apps.hz_cust_account_roles acct_role on rel.party_id = acct_role.party_id 
		  join apps.hz_parties party on rel.subject_id = party.party_id
		  join apps.hz_parties rel_party on rel.party_id = rel_party.party_id
		  join apps.hz_cust_accounts role_acct on rel.object_id = role_acct.party_id
		   and acct_role.cust_account_id = role_acct.cust_account_id
	 left join apps.hz_contact_points cont_point on rel_party.party_id = cont_point.owner_table_id
		   and cont_point.owner_table_name = 'HZ_PARTIES'
		  join apps.hz_org_contacts org_cont on rel.relationship_id = org_cont.party_relationship_id
		  join ar.hz_cust_accounts hca on hca.cust_account_id = role_acct.cust_account_id
		 where rel.subject_table_name = 'HZ_PARTIES'
		   and rel.object_table_name = 'HZ_PARTIES'
		   and acct_role.role_type = 'CONTACT' 
		   and rel_party.status = 'A'
		   and party.status = 'A'
		   and rel.status = 'A'
		   and role_acct.cust_account_id in (123456)
		   and acct_role.cust_acct_site_id is null -- i think this checks it at site level, not sure? 
		   and 1 = 1;
