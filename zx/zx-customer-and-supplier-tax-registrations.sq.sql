/*
File Name:		zx-customer-and-supplier-tax-registrations.sq.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

HTTPS://SHARINGORACLE.BLOGSPOT.COM/2018/01/SUPPLIER-CUSTOMER-TAX-PROFILES.HTML

Queries:

-- CUSTOMERS
-- SUPPLIERS

*/

-- ##################################################################
-- CUSTOMERS
-- ##################################################################

		select a.customer_name
			 , decode(a.customer_type, 'I', 'Internal', 'R', 'External') customer_type
			 , a1.profile_class_name
			 , a.creation_date
			 , b.party_name
			 , b.party_number
			 , c.party_type_code
			 , d.creation_date
			 , d.class_category
			 , d.class_code
			 , d.start_date_active
			 , e.tax_regime_code
			 , e.registration_number
			 , e.registration_status_code
			 , e.effective_from
			 , a.tax_reference
			 , b1.party_site_name
			 , b1.party_site_number
			 , c1.party_type_code site_party_type_code
			 , e1.tax_regime_code site_tax_regime_code
			 , e1.registration_number site_registration_number
			 , e1.registration_status_code site_registration_status_code
			 , e1.effective_from site_effective_from
			 , d1.class_category site_class_category
			 , d1.class_code site_class_code
			 , d1.start_date_active site_start_date_active
		  from ar_customers a
	 left join ar_customer_profiles_v a1 on a.customer_id = a1.customer_id
		  join hz_parties b on a.orig_system_reference = b.orig_system_reference
		  join hz_party_sites b1 on b.party_id = b1.party_id
	 left join zx_party_tax_profile c on b.party_id = c.party_id and c.party_type_code = 'THIRD_PARTY'
	 left join zx_party_tax_profile c1 on b1.party_site_id = c1.party_id and c1.party_type_code = 'THIRD_PARTY_SITE'
	 left join hz_code_assignments d on c.party_tax_profile_id = d.owner_table_id and d.class_category = 'XXXX'
	 left join hz_code_assignments d1 on c1.party_tax_profile_id = d1.owner_table_id
	 left join zx_registrations e on c.party_tax_profile_id = e.party_tax_profile_id
	 left join zx_registrations e1 on c1.party_tax_profile_id = e1.party_tax_profile_id
		 where 1 = 1
		   and 1 = 1;

-- ##################################################################
-- SUPPLIERS
-- ##################################################################

		select a.vendor_name
			 , a.segment1
			 , (select count(*) from ap.ap_invoices_all aia where aia.vendor_id = a.vendor_id) inv_ct
			 , (select count(*) from po.po_headers_all pha where pha.vendor_id = a.vendor_id) po_ct
			 , (select count(distinct prha.requisition_header_id) from po.po_requisition_headers_all prha join po.po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id where prla.vendor_id = a.vendor_id) req_ct
			 , a.vendor_name
			 , a.vendor_name_alt
			 , b.party_name
			 , a.vendor_type_lookup_code
			 , b.party_number
			 , c.party_type_code
			 , c.process_for_applicability_flag allow_tax_applicability
			 , c.allow_offset_tax_flag allow_offset_tax
			 , d.class_category
			 , d.class_code
			 , d.start_date_active
			 , d.end_date_active
			 , e.tax_regime_code
			 , e.registration_number
			 , e.registration_status_code
			 , e.effective_from
			 , e.effective_to
			 , a.vat_code
			 , b1.party_site_name
			 , b1.party_site_number
			 , c1.party_type_code site_party_type_code
			 , c1.process_for_applicability_flag site_allow_tax_applicability
			 , c1.allow_offset_tax_flag site_allow_offset_tax
			 , d1.class_category site_class_category
			 , d1.class_code site_class_code
			 , d1.start_date_active site_start_date_active
			 , e1.tax_regime_code site_tax_regime_code
			 , e1.registration_number site_registration_number
			 , e1.registration_status_code site_registration_status_code
			 , e1.effective_from site_effective_from
			 , e1.effective_to site_effective_to
		  from ap_suppliers a
		  join hz_parties b on a.party_id = b.party_id
	 left join hz_party_sites b1 on b.party_id = b1.party_id
	 left join zx_party_tax_profile c on b.party_id = c.party_id and and c.party_type_code = 'THIRD_PARTY'
	 left join zx_party_tax_profile c1 on b1.party_site_id = c1.party_id and c1.party_type_code = 'THIRD_PARTY_SITE'
	 left join hz_code_assignments d on c.party_tax_profile_id = d.owner_table_id and d.class_category = 'XXXX'
	 left join hz_code_assignments d1 on c1.party_tax_profile_id = d1.owner_table_id
	 left join zx_registrations e on c.party_tax_profile_id = e.party_tax_profile_id
	 left join zx_registrations e1 on c1.party_tax_profile_id = e1.party_tax_profile_id
		 where 1 = 1
		   and a.vendor_type_lookup_code not in ('EMPLOYEE', 'INTERNAL')
		   and a.segment1 in ('123456','234567')
		   and 1 = 1
	  order by d.class_category desc
			 , e.registration_status_code
			 , b.party_name;
