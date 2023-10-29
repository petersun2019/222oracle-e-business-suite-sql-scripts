/*
File Name:		ap-invoices-tax-withholding.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- AWT RATE DEFINITIONS
-- INVOICES WITH AWT RATE AGAINST THE INVOICE LINES

*/

-- ##################################################################
-- AWT RATE DEFINITIONS
-- ##################################################################

		select hou.name org
			 , hou.short_code org_code
			 , aatra.tax_rate_id
			 , aatra.tax_name
			 , aatra.tax_rate
			 , aatra.rate_type
			 , to_char(aatra.start_date, 'DD-MON-YYYY') start_date
			 , to_char(aatra.end_date, 'DD-MON-YYYY') end_date
			 , aatra.creation_date
			 , fu1.user_name created_by
			 , aatra.last_update_date
			 , fu2.user_name updated_by
			 , pv.vendor_name
			 , pvsa.vendor_site_code site
			 , aatra.certificate_number
			 , aatra.certificate_type
			 , aatra.comments
		  from ap_awt_tax_rates_all aatra
		  join fnd_user fu1 on aatra.created_by = fu1.user_id
		  join fnd_user fu2 on aatra.last_updated_by = fu2.user_id
		  join hr_operating_units hou on aatra.org_id = hou.organization_id
	 left join ap_suppliers pv on aatra.vendor_id = pv.vendor_id
	 left join ap_supplier_sites_all pvsa on aatra.vendor_site_id = pvsa.vendor_site_id
		 where aatra.tax_rate = 30;

-- ##################################################################
-- INVOICES WITH AWT RATE AGAINST THE INVOICE LINES
-- ##################################################################

		select distinct aia.invoice_id id
			 , aia.invoice_num num
			 , haou.name org
			 , aia.creation_date
			 , aia.last_update_date 
			 , to_char(aia.invoice_date, 'DD-MON-YYYY') inv_date
			 , aia.invoice_type_lookup_code inv_type
			 , pv.vendor_name supplier
			 , pv.vendor_type_lookup_code supplier_type
			 , pvsa.vendor_site_code site
			 , aia.invoice_amount amt
			 , aia.amount_paid
			 , aia.amount_applicable_to_discount
			 , aia.validated_tax_amount
			 , fu.description cr_by 
			 , aia.payment_status_flag paid
			 , aag.name inv_withholding_tax
			 , aatra.tax_name
			 , aatra.tax_rate
			 , aatra.rate_type
			 -- , '#########################'
			 -- , decode(apps.ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) validation_status_v1 -- http://m-burhan.blogspot.co.uk/2012/06/function-which-provide-ap-validation.html
			 -- , decode(apps.ap_invoices_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL', 'Fully Applied', 'UNAPPROVED' , 'Unvalidated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'APPROVED', 'Validated', 'NEVER APPROVED', 'Never Validated', 'CANCELLED', 'Cancelled', 'UNPAID', 'Unpaid', 'AVAILABLE', 'Available') validation_status_v2 -- https://community.oracle.com/thread/3573183
			 -- , apps.ap_invoices_pkg.get_posting_status(aia.invoice_id) accounted
			 -- , apps.ap_invoices_pkg.get_approval_status(aia.invoice_id, aia.invoice_amount, aia.payment_status_flag, aia.invoice_type_lookup_code) approval_status
			 -- , apps.ap_invoices_pkg.get_amount_withheld (aia.invoice_id) amount_withheld
			 -- , '#########################'
			 -- , aila.*
		  from ap.ap_invoices_all aia
		  join ap.ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id 
		  join ap.ap_terms_tl att on aia.terms_id = att.term_id 
		  join applsys.fnd_user fu on aia.created_by = fu.user_id
		  join apps.po_vendors pv on aia.vendor_id = pv.vendor_id
		  join apps.po_vendor_sites_all pvsa on aia.vendor_site_id = pvsa.vendor_site_id and pv.vendor_id = pvsa.vendor_id
		  join hr_all_organization_units haou on aia.org_id = haou.organization_id
		  join ap.ap_awt_groups aag on aila.awt_group_id = aag.group_id
		  join ap.ap_awt_tax_rates_all aatra on aag.group_id = aatra.tax_rate_id
		 where 1 = 1
		   and aia.invoice_num in ('INV123456') -- ## number ## --
		   and 1 = 1;
