/*
File Name:		ap-payment-groups.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- AP PAYMENT GROUPS
-- ##################################################################

		select vl.lookup_code
			 , vl.meaning
			 , vl.description
			 , vl.creation_date
			 , fu.user_name
			 , fu.email_address
			 , count(*) supplier_site_count
		  from fnd_lookup_values_vl vl
		  join ap_supplier_sites_all pvsa on pvsa.pay_group_lookup_code = vl.lookup_code
		  join fnd_user fu on vl.created_by = fu.user_id
		 where vl.lookup_type = 'PAY GROUP'
	  group by vl.lookup_code
			 , vl.meaning
			 , vl.description
			 , vl.creation_date
			 , fu.user_name
			 , fu.email_address
	  order by vl.meaning;
