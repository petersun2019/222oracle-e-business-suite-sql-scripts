/*
File Name:		po-contract-purchase-agreements.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- CPA DETAILS
-- COUNT SUMMARY PER OPERATING UNIT
-- CPA COUNT SETUP ROLLUP BY YEAR AND MONTH
-- NUMBER OF POS RAISED VIA EACH CPA

Re. difference between Blanket Purchase Agreement and Contract Purchase Agreemment:
https://aytanvahidova.medium.com/whats-the-difference-between-a-purchase-order-a-blanket-agreement-and-a-contract-agreement-6e6268771005

Contract Purchase Agreement
----------------------------------
You create a contract purchase agreement with your supplier to agree on specific terms and conditions without indicating the goods and services that you will be purchasing.
You can later issue purchase orders referencing your contracts using terms negotiated on a contract purchase agreement.

Blanket Purchase Agreement
----------------------------------
You create blanket purchase agreements when you know the details of the goods or services you plan to buy from a specific supplier in a period
, but you do not yet know the detail of your delivery schedules.
You can use blanket purchase agreements to specify negotiated prices for your items before actually purchasing them.

*/

-- ##################################################################
-- CPA DETAILS
-- ##################################################################

		select hou.name ou
			 , pha.segment1 cpa_po_number
			 , pha.creation_date
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
		  from po.po_headers_all pha
		  join ap.ap_suppliers pv on pha.vendor_id = pv.vendor_id
		  join ap.ap_supplier_sites_all pvsa on pha.vendor_site_id = pvsa.vendor_site_id
		  join apps.hr_operating_units hou on pha.org_id = hou.organization_id
		 where pha.type_lookup_code = 'CONTRACT'
		   and pha.authorization_status = 'APPROVED'
	  order by 3
			 , 4;

-- ##################################################################
-- COUNT SUMMARY PER OPERATING UNIT
-- ##################################################################

		select hou.organization_id orgid
			 , hou.name ou
			 , count(*) cpa_count
		  from po.po_headers_all pha
		  join ap.ap_suppliers pv on pha.vendor_id = pv.vendor_id
		  join ap.ap_supplier_sites_all pvsa on pha.vendor_site_id = pvsa.vendor_site_id
		  join apps.hr_operating_units hou on pha.org_id = hou.organization_id
		 where pha.type_lookup_code = 'CONTRACT'
		   and pha.authorization_status = 'APPROVED'
	  group by hou.name
			 , hou.organization_id;

-- ##################################################################
-- CPA COUNT SETUP ROLLUP BY YEAR AND MONTH
-- ##################################################################

		select nvl(to_char(extract(year from pha.creation_date)),'TOTAL') creation_year,
			   sum(decode(extract (month from pha.creation_date),1,1,0)) jan,
			   sum(decode(extract (month from pha.creation_date),2,1,0)) feb,
			   sum(decode(extract (month from pha.creation_date),3,1,0)) mar,
			   sum(decode(extract (month from pha.creation_date),4,1,0)) apr,
			   sum(decode(extract (month from pha.creation_date),5,1,0)) may,
			   sum(decode(extract (month from pha.creation_date),6,1,0)) jun,
			   sum(decode(extract (month from pha.creation_date),7,1,0)) jul,
			   sum(decode(extract (month from pha.creation_date),8,1,0)) aug,
			   sum(decode(extract (month from pha.creation_date),9,1,0)) sep,
			   sum(decode(extract (month from pha.creation_date),10,1,0)) oct,
			   sum(decode(extract (month from pha.creation_date),11,1,0)) nov,
			   sum(decode(extract (month from pha.creation_date),12,1,0)) dec,
			   sum(1) total
		  from po.po_headers_all pha
		  join ap.ap_suppliers pv on pha.vendor_id = pv.vendor_id
		  join ap.ap_supplier_sites_all pvsa on pha.vendor_site_id = pvsa.vendor_site_id
		  join apps.hr_operating_units hou on pha.org_id = hou.organization_id
		 where pha.type_lookup_code = 'CONTRACT'
		   -- and pha.org_id = 123456
		   and pha.authorization_status = 'APPROVED'
	  group by rollup(extract(year from pha.creation_date));

-- ##################################################################
-- NUMBER OF POS RAISED VIA EACH CPA
-- ##################################################################

with header_lines_summary as
	   (select pla.contract_id
			 , count(distinct pha2.po_header_id) as po_count
			 , max(pha2.creation_date) as latest_cpa_po
		  from po.po_headers_all pha2
			 , po.po_lines_all pla
		 where pha2.po_header_id = pla.po_header_id
	  group by pla.contract_id)
		select pha.segment1 cpa_number
			 , pha.comments cpa_description
			 , pha.creation_date
			 , fu.description created_by
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
			 , hls.po_count po_count_raised_via_cpa
			 , hls.latest_cpa_po
		  from po.po_headers_all pha
			 , ap.ap_suppliers pv
			 , ap.ap_supplier_sites_all pvsa
			 , header_lines_summary hls
			 , applsys.fnd_user fu
		 where pha.vendor_id = pv.vendor_id
		   and pha.vendor_site_id = pvsa.vendor_site_id
		   and pha.created_by = fu.user_id
		   and pha.po_header_id = hls.contract_id(+)
		   and pha.type_lookup_code = 'CONTRACT';
