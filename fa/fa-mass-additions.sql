/*
File Name:		fa-mass-additions.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- BASIC
-- LINKED TO AP INVOICES

*/

-- ##################################################################
-- BASIC
-- ##################################################################

		select fma.asset_number
			 , fma.mass_addition_id
			 , fma.description
			 , fma.book_type_code
			 , fma.fixed_assets_cost
			 , fma.feeder_system_name
			 , fma.posting_status
			 , fma.queue_name
			 , fma.asset_key_ccid
			 , fma.creation_date
			 , fu1.user_name created_by
			 , fma.last_update_date
			 , fu2.user_name last_updated_by
			 , '##################'
			 , fma.*
		  from fa_mass_additions fma
		  join fnd_user fu1 on fma.created_by = fu1.user_id
		  join fnd_user fu2 on fma.last_updated_by = fu2.user_id
		 where 1 = 1
		   and fma.creation_date > '01-JUN-2019'
		   -- and fma.mass_addition_id = 328133
		   -- and fma.description = 'TESTING'
	  order by fma.creation_date desc;

-- ##################################################################
-- LINKED TO AP INVOICES
-- ##################################################################

		select aia.invoice_id
			 , '#' || aia.invoice_num inv_num
			 , aia.creation_date
			 , fu.user_name inv_created_by
			 , pv.vendor_name supplier
			 , aia.source inv_source
			 , fma.mass_addition_id
			 , fma.creation_date mass_addition_created
		  from ap_invoice_distributions_all aida
		  join ap_invoices_all aia on aia.invoice_id = aida.invoice_id
		  join fnd_user fu on aia.created_by = fu.user_id
		  join ap_suppliers pv on pv.vendor_id = aia.vendor_id
	 left join fa.fa_mass_additions fma on fma.invoice_distribution_id = aida.invoice_distribution_id
		 where aida.creation_date > '01-feb-2018'
		   and assets_addition_flag = 'Y'
		   and assets_tracking_flag = 'Y'
		   and asset_book_type_code = 'XXCUST';
