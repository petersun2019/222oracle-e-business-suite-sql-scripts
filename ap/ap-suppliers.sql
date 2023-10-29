/*
File Name: ap-suppliers.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- SUPPLIERS BASIC
-- SUPPPLIER SITES NOT USED IN THE LAST 300 DAYS
-- SUPPLIERS - SITE COUNT
-- SUPPLIERS REPORT - PO AND INV COUNT
-- SUPPLIERS REPORT - REQUISITION COUNT
-- SUPPLIERS - CONTACT INFO 1
-- SUPPLIERS - CONTACT INFO 2
-- SUPPLIERS - TAX REGISTRATION

*/

-- ##################################################################
-- SUPPLIERS BASIC
-- ##################################################################

		select bus_gp.name org
			 , pv.segment1 supplier_num
			 , pv.vendor_id
			 , pv.vendor_type_lookup_code
			 , pv.vendor_name
			 , (select count(*) from ap.ap_invoices_all aia where aia.vendor_id = pv.vendor_id) inv_ct
			 , (select count(*) from po.po_headers_all pha where pha.vendor_id = pv.vendor_id) po_ct
			 , to_char(pv.end_date_active, 'dd-MON-yyyy') header_end_date
			 , fu2.user_name header_updated_by
			 , fu2.email_address header_updated_by_email
			 , pvsa.purchasing_site_flag
			 , pvsa.supplier_notif_method
			 , pvsa.pay_site_flag
			 , to_char(pvsa.inactive_date, 'dd-MON-yyyy') site_end_date
			 , pvsa.vendor_site_code site
			 , pvsa.vendor_site_code_alt
			 , pvsa.last_update_date
			 , fu.user_name site_updated_by
			 , fu.email_address site_updated_by_email
			 , pvsa.address_line1 site_add_1
			 , pvsa.address_line2 site_add_2
			 , pvsa.address_line3 site_add_3
			 , pvsa.city site_city
			 , pvsa.state site_state
			 , pvsa.zip site_zip
			 , pvsa.vendor_site_id
			 , pvsa.org_id
			 , pvsa.supplier_notif_method
			 , pvsa.email_address email
		  from ap_suppliers pv
		  join ap_supplier_sites_all pvsa on pv.vendor_id = pvsa.vendor_id#
		  join hr_all_organization_units_tl bus_gp on pvsa.org_id = bus_gp.organization_id and bus_gp.language = userenv('lang')
		  join fnd_user fu on pvsa.last_updated_by = fu.user_id
		  join fnd_user fu2 on pv.last_updated_by = fu2.user_id
		 where 1 = 1
		   and nvl(pv.end_date_active, sysdate + 1) > sysdate -- active header
		   and nvl(pvsa.inactive_date, sysdate + 1) > sysdate -- active site
		   and pv.vendor_name in ('MORE CHEESE THAN SENSE')
	  order by bus_gp.name
			 , pv.vendor_name
			 , pvsa.vendor_site_code;

-- ##################################################################
-- SUPPPLIER SITES NOT USED IN THE LAST 300 DAYS
-- ##################################################################

		select pv.vendor_name
			 , pvsa.vendor_site_code
			 , (select count(*)
				  from po.po_headers_all pha
				 where pha.vendor_id = pv.vendor_id
				   and pha.vendor_site_id = pvsa.vendor_site_id
				   and pha.creation_date >= :dt) po_count
			 , (select max(pha.creation_date)
				  from po.po_headers_all pha
				 where pha.vendor_id = pv.vendor_id
				   and pha.vendor_site_id = pvsa.vendor_site_id
				   and pha.creation_date >= :dt) latest_po_date
			 , round(sysdate - (select max(pha.creation_date)
								  from po.po_headers_all pha
								 where pha.vendor_id = pv.vendor_id
								   and pha.vendor_site_id = pvsa.vendor_site_id
								   and pha.creation_date >= :dt)
									 , 2) days_since_last_po
			 , (select count(*)
				  from ap.ap_invoices_all aia
				 where aia.vendor_id = pv.vendor_id
				   and aia.vendor_site_id = pvsa.vendor_site_id
				   and aia.creation_date >= :dt) inv_count
			 , (select max(aia.creation_date)
				  from ap.ap_invoices_all aia
				 where aia.vendor_id = pv.vendor_id
				   and aia.vendor_site_id = pvsa.vendor_site_id
				   and aia.creation_date >= :dt) latest_inv_date
			 , round(sysdate - (select max(aia.creation_date)
								  from ap.ap_invoices_all aia
								 where aia.vendor_id = pv.vendor_id
								   and aia.vendor_site_id = pvsa.vendor_site_id
								   and aia.creation_date >= :dt)
									 , 2) days_since_last_inv
		  from ap.ap_suppliers pv
		  join ap.ap_supplier_sites_all pvsa on pv.vendor_id = pvsa.vendor_id
		 where not exists(select 'z'
						  from po.po_headers_all pha
						 where pha.vendor_id = pv.vendor_id
						   and pha.vendor_site_id = pvsa.vendor_site_id
						   and creation_date > sysdate - 300)
		   and not exists(select 'z'
						  from ap.ap_invoices_all aia
						 where aia.vendor_id = pv.vendor_id
						   and aia.vendor_site_id = pvsa.vendor_site_id
						   and creation_date > sysdate - 300)
		   and nvl(pv.end_date_active, sysdate + 1) > sysdate -- active header
		   and nvl(pvsa.inactive_date, sysdate + 1) > sysdate -- active site
		   and pv.vendor_name like 'A%'
		   and pvsa.purchasing_site_flag = 'Y'
	  order by 1
			 , 2;

-- ##################################################################
-- SUPPLIERS - SITE COUNT
-- ##################################################################

		select pv.vendor_name
			 , pv.vendor_type_lookup_code
			 , pv.segment1 supplier_number
			 , count(pvsa.vendor_site_id) site_count
		  from ap.ap_suppliers pv
		  join ap.ap_supplier_sites_all pvsa on pv.vendor_id = pvsa.vendor_id
		 where nvl(pv.end_date_active, sysdate + 1) > sysdate
		   and nvl(pvsa.inactive_date, sysdate + 1) > sysdate
		   and pv.vendor_type_lookup_code = 'VENDOR'
	  group by pv.vendor_name
			 , pv.vendor_type_lookup_code
			 , pv.segment1
	  order by pv.vendor_name;

-- ##################################################################
-- SUPPLIERS REPORT - PO AND INV COUNT
-- ##################################################################

		select pv.vendor_name
			 , pv.vendor_type_lookup_code
			 , pv.segment1 supplier_number
			 , pvsa.vendor_site_code
			 , pvsa.supplier_notif_method
			 , pvsa.email_address email_po_address
			 , pv.creation_date header_creation_date
			 , pvsa.creation_date site_creation_date
			 , pvsa.purchasing_site_flag
			 , pvsa.pay_site_flag
			 , pvsa.address_line1
			 , pvsa.address_line2
			 , pvsa.address_line3
			 , pvsa.city
			 , pvsa.state
			 , pvsa.zip
			 , (select count(*)
				  from po.po_headers_all pha
				 where pha.vendor_id = pv.vendor_id
				   and pha.vendor_site_id = pvsa.vendor_site_id
				   and pha.creation_date >= :dt) po_count
			 , (select max(pha.creation_date)
				  from po.po_headers_all pha
				 where pha.vendor_id = pv.vendor_id
				   and pha.vendor_site_id = pvsa.vendor_site_id
				   and pha.creation_date >= :dt) latest_po_date
			 , round(sysdate - (select max(pha.creation_date)
								  from po.po_headers_all pha
								 where pha.vendor_id = pv.vendor_id
								   and pha.vendor_site_id = pvsa.vendor_site_id
								   and pha.creation_date >= :dt)
									 , 2) days_since_last_po
			 , (select count(*)
				  from ap.ap_invoices_all aia
				 where aia.vendor_id = pv.vendor_id
				   and aia.vendor_site_id = pvsa.vendor_site_id
				   and aia.creation_date >= :dt) inv_count
			 , (select max(aia.creation_date)
				  from ap.ap_invoices_all aia
				 where aia.vendor_id = pv.vendor_id
				   and aia.vendor_site_id = pvsa.vendor_site_id
				   and aia.creation_date >= :dt) latest_inv_date
			 , round(sysdate - (select max(aia.creation_date)
								  from ap.ap_invoices_all aia
								 where aia.vendor_id = pv.vendor_id
								   and aia.vendor_site_id = pvsa.vendor_site_id
								   and aia.creation_date >= :dt)
									 , 2) days_since_last_inv
		  from ap.ap_suppliers pv
		  join ap.ap_supplier_sites_all pvsa on pv.vendor_id = pvsa.vendor_id
		   and nvl(pv.end_date_active, sysdate + 1) > sysdate
		   and nvl(pvsa.inactive_date, sysdate + 1) > sysdate
		   and pv.vendor_name like 'Blue%'
		   and pv.vendor_type_lookup_code = 'VENDOR'
	  order by pv.vendor_name
			 , pvsa.vendor_site_code;

-- ##################################################################
-- SUPPLIERS REPORT - REQUISITION COUNT
-- ##################################################################

		select pv.vendor_name
			 , pvsa.vendor_site_code
			 , count(distinct prla.requisition_header_id) req_count
			 , count(*) req_lines
			 , min(prla.creation_date)
			 , max(prla.creation_date)
		  from po_requisition_lines_all prla
		  join ap_suppliers pv on prla.vendor_id = pv.vendor_id
		  join ap_supplier_sites_all pvsa on pvsa.vendor_site_id = prla.vendor_site_id and pvsa.vendor_id = pv.vendor_id
		 where 1 = 1
		   and pv.segment1 = '123456'
		   and 1 = 1
	  group by pv.vendor_name
			 , pvsa.vendor_site_code;

-- ##################################################################
-- SUPPLIERS - CONTACT INFO 1
-- ##################################################################

		select pv.segment1 supplier_num
			 , pv.vendor_name
			 , pv.end_date_active
			 , pv.creation_date
			 , pv.vendor_type_lookup_code type
			 , pvsa.vendor_site_code site_name
			 , pvsa.inactive_date site_inactive
			 , pvsa.purchasing_site_flag flag_purch
			 , pvsa.rfq_only_site_flag flag_rfq
			 , pvsa.pay_site_flag flag_pay
			 , pvsa.address_line1 site_add_1
			 , pvsa.address_line2 site_add_2
			 , pvsa.address_line3 site_add_3
			 , pvsa.city site_city
			 , pvsa.state site_state
			 , pvsa.zip site_zip
			 , pvsa.email_address site_email_address
			 , '----------'
			 , fu.description site_last_updated_by
			 , pvsa.last_update_date site_last_updated_on
			 , pvc.first_name contact_first_name
			 , pvc.last_name contact_last_name
			 , pvc.phone contact_phone
			 , pvc.email_address contact_email
		  from ap.ap_suppliers pv
		  join ap.ap_supplier_sites_all pvsa on pv.vendor_id = pvsa.vendor_id
	 left join apps.po_vendor_contacts pvc on pvsa.vendor_site_id = pvc.vendor_site_id
		  join applsys.fnd_user fu on pvsa.last_updated_by = fu.user_id
		 where 1 = 1
		   and pv.vendor_name in ('MORE CHEESE THAN SENSE')
	  order by pv.vendor_name;

-- ##################################################################
-- SUPPLIERS - CONTACT INFO 2
-- ##################################################################

		select pv.segment1 supplier_num
			 , pv.vendor_name
			 , pv.creation_date header_created
			 , pv.last_update_date header_updated
			 , pv.start_date_active header_start_date
			 , pv.end_date_active header_end_date
			 , pv.vendor_type_lookup_code supplier_type
			 , pvsa.vendor_site_code site_name
			 , pvsa.creation_date site_created
			 , pvsa.last_update_date site_updated
			 , pvsa.inactive_date site_end_date
			 , pvsa.purchasing_site_flag flag_purch
			 , pvsa.rfq_only_site_flag flag_rfq
			 , pvsa.pay_site_flag flag_pay
			 , pvsa.address_line1
			 , pvsa.address_line2
			 , pvsa.address_line3
			 , pvsa.city site_city
			 , pvsa.state site_state
			 , pvsa.zip site_zip
			 , pvsa.email_address site_email_address
			 , hcp2.email_address as contact_email_address
			 , hps.party_site_id
			 , hps.party_site_name
			 , decode (pay.site_use_type, null, 'N', 'Y') as pay_flag
			 , decode (pur.site_use_type, null, 'N', 'Y') as pur_flag
			 , decode (rfq.site_use_type, null, 'N', 'Y') as rfq_flag
			 , hps.last_update_date
			 , hps.end_date_active
			 , hps.start_date_active
			 , p_notes.notes
			 , hcp1.phone_area_code
			 , hcp1.phone_number contact_telno
			 , hcp1.contact_point_id as phone_contact_id
			 , hcp1.object_version_number as phone_object_version_number
			 , hcp2.contact_point_id as email_contact_id
			 , hcp2.object_version_number as email_object_version_number
			 , hcp3.object_version_number as fax_object_version_number
			 , hcp3.phone_area_code as fax_area_code
			 , hcp3.phone_number as contact_fax
			 , hcp3.contact_point_id as fax_contact_id
			 , hzl.address1
			 , hzl.address2
			 , hzl.address3
			 , hzl.address4
			 , hzl.city
			 , hzl.state
			 , hzl.province
			 , hzl.county
			 , hzl.country
			 , hzl.postal_plus4_code
			 , hzl.postal_code
			 , hzl.location_id
			 , hps.party_id as party_id
			 , hps.status as status
		  from ar.hz_party_sites hps
			 , ar.hz_party_site_uses pay
			 , ar.hz_party_site_uses pur
			 , ar.hz_party_site_uses rfq
			 , pos.pos_address_notes p_notes
			 , ar.hz_contact_points hcp1
			 , ar.hz_contact_points hcp2
			 , ar.hz_contact_points hcp3
			 , ar.hz_locations hzl
			 , ap.ap_suppliers pv
			 , ap.ap_supplier_sites_all pvsa
		 where pv.vendor_id = pvsa.vendor_id
		   and pv.party_id = hps.party_id
		   and pvsa.party_site_id = hps.party_site_id
		   and hps.location_id = hzl.location_id
		   and nvl (hps.end_date_active, sysdate) >= sysdate
		   and pay.party_site_id(+) = hps.party_site_id
		   and pur.party_site_id(+) = hps.party_site_id
		   and rfq.party_site_id(+) = hps.party_site_id
		   and p_notes.party_site_id(+) = hps.party_site_id
		   and pay.status(+) = 'A'
		   and pur.status(+) = 'A'
		   and rfq.status(+) = 'A'
		   and nvl (pay.end_date(+), sysdate) >= sysdate
		   and nvl (pur.end_date(+), sysdate) >= sysdate
		   and nvl (rfq.end_date(+), sysdate) >= sysdate
		   and nvl (pay.begin_date(+), sysdate) <= sysdate
		   and nvl (pur.begin_date(+), sysdate) <= sysdate
		   and nvl (rfq.begin_date(+), sysdate) <= sysdate
		   and pay.site_use_type(+) = 'PAY'
		   and pur.site_use_type(+) = 'PURCHASING'
		   and rfq.site_use_type(+) = 'RFQ'
		   and hcp1.owner_table_id(+) = hps.party_site_id
		   and hcp1.contact_point_type(+) = 'PHONE'
		   and hcp1.phone_line_type(+) = 'GEN'
		   and hcp1.status(+) = 'A'
		   and hcp1.owner_table_name(+) = 'HZ_PARTY_SITES'
		   and hcp1.primary_flag(+) = 'Y'
		   and hcp2.owner_table_id(+) = hps.party_site_id
		   and hcp2.contact_point_type(+) = 'EMAIL'
		   and hcp2.status(+) = 'A'
		   and hcp2.owner_table_name(+) = 'HZ_PARTY_SITES'
		   and hcp2.primary_flag(+) = 'Y'
		   and hcp3.owner_table_id(+) = hps.party_site_id
		   and hcp3.contact_point_type(+) = 'PHONE'
		   and hcp3.phone_line_type(+) = 'FAX'
		   and hcp3.status(+) = 'A'
		   and hcp3.owner_table_name(+) = 'HZ_PARTY_SITES'
		   and hps.party_id = 123456
		   and 1 = 1;

-- ##################################################################
-- SUPPLIERS - TAX REGISTRATION
-- ##################################################################

		select hp.party_name
			 , hp.party_number
			 , pv.vendor_name
			 , pv.vendor_id
			 , pv.creation_date
			 , pv.segment1 supplier_number
			 , pv.num_1099
			 , pv.vat_registration_num
			 , pv.tca_sync_num_1099
			 , pv.tca_sync_vendor_name
			 , pv.tca_sync_vat_reg_num
			 , '#############'
			 , zptp.rep_registration_number
			 , zptp.country_code
			 , zptp.creation_date
			 , zptp.last_update_date
			 , zptp.party_type_code
		  from hz_parties hp
		  join ap_suppliers pv on pv.party_id = hp.party_id
	 left join zx_party_tax_profile zptp on zptp.party_id = hp.party_id
		 where 1 = 1
		   and zptp.rep_registration_number is not null
		   and hp.party_type = 'ORGANIZATION'
		   and pv.segment1 in ('123456')
		   and 1 = 1;
