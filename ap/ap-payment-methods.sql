/*
File Name:		ap-payment-methods.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- AP PAYMENT METHODS
-- ##################################################################

		select pv.vendor_name
			 , pv.vendor_id
			 , pvsa.vendor_site_code site
			 , pvsa.vendor_site_code_alt cogs
			 , '######'
			 , ieppm.payment_method_code
			 , ieppm.creation_date
			 , fu1.user_name created_by
			 , ieppm.last_update_date updated
			 , fu2.user_name updated_by
			 , ieppm.*
		  from ap_suppliers pv
		  join ap_supplier_sites_all pvsa on pv.vendor_id = pvsa.vendor_id
		  join iby_external_payees_all iepa on pvsa.vendor_site_id = iepa.supplier_site_id
		  join iby_ext_party_pmt_mthds ieppm on iepa.ext_payee_id = ieppm.ext_pmt_party_id and ((ieppm.inactive_date is null) or (ieppm.inactive_date > sysdate))
		  join fnd_user fu1 on ieppm.created_by = fu1.user_id
		  join fnd_user fu2 on ieppm.last_updated_by = fu2.user_id
		 where pv.vendor_id = 123456;
