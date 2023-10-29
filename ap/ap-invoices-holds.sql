/*
File Name:		ap-invoices-holds.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- INVOICE - MATCH / HOLD INFORMATION
-- HOLD DEFINITIONS

*/

-- ##################################################################
-- INVOICE - MATCH / HOLD INFORMATION
-- ##################################################################

		select distinct aia.invoice_id id
			 , '#' || aia.invoice_num invoice_num
			 , aia.cancelled_amount
			 , aia.cancelled_by
			 , aia.cancelled_date 
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
			 , aia.invoice_amount amt
			 , to_char(aia.invoice_date, 'DD-MON-YYYY') invoice_date
			 , ah.hold_lookup_code
			 , flv.meaning hold
			 , ah.hold_reason
			 , ah.hold_date
			 , ah.status_flag
			 , to_char(ah.creation_date, 'yyyy-mm-dd HH24:MM:SS') hold_created
			 , ah.last_update_date hold_updated
			 , ah.release_lookup_code
			 , ah.release_reason
		  from apps.ap_invoices_all aia
		  join apps.ap_suppliers pv on aia.vendor_id = pv.vendor_id
		  join apps.ap_supplier_sites_all pvsa on aia.vendor_site_id = pvsa.vendor_site_id
		  join apps.ap_holds_all ah on aia.invoice_id = ah.invoice_id
		  join apps.fnd_lookup_values_vl flv on flv.lookup_code = ah.hold_lookup_code and flv.lookup_type = 'HOLD CODE' and flv.view_application_id = 200
		 where 1 = 1
		   and ah.release_reason is null -- hold is still active
		   and aia.invoice_num = 'INV123456'
		   and 1 = 1
	  order by to_char(ah.creation_date, 'yyyy-mm-dd HH24:MM:SS') desc;

-- ##################################################################
-- HOLD DEFINITIONS
-- ##################################################################

		select ahc.hold_lookup_code 
			 , ahc.hold_type
			 , ahc.description
			 , ahc.creation_date
			 , fu.user_name created_by
			 , ahc.user_releaseable_flag
			 , ahc.user_updateable_flag
			 , ahc.inactive_date
			 , ahc.postable_flag
		  from ap.ap_hold_codes ahc
		  join applsys.fnd_user fu on ahc.created_by = fu.user_id
		 where 1 = 1
		   -- and lower(ahc.hold_lookup_code) like '%tax%'
	  order by ahc.creation_date desc;
