/*
File Name:		ap-suppliers-xml-gateway-trading-partners.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- SUPPLIERS LISTED AS TRADING PARTNERS IN XML GATEWAY
-- TABLE DUMPS

*/

-- ##################################################################
-- SUPPLIERS LISTED AS TRADING PARTNERS IN XML GATEWAY
-- ##################################################################

		select pv.vendor_name
			 , pv.vendor_id
			 , pv.segment1
			 , pvsa.vendor_site_code site
			 , em.map_code
			 , '#############'
			 , etd.connection_type
			 , etd.username
			 , etd.source_tp_location_code
			 , etd.external_tp_location_code
			 -- , '##############'
			 -- , pvsa.*
		  from ap.ap_suppliers pv
			 , ap.ap_supplier_sites_all pvsa
			 , ecx.ecx_tp_headers eth
			 , ecx.ecx_tp_details etd
			 , ecx.ecx_mappings em
			 , ecx.ecx_hubs eh
		 where pv.vendor_id = eth.party_id
		   and pvsa.vendor_site_id = eth.party_site_id
		   and eth.tp_header_id = etd.tp_header_id
		   and etd.map_id = em.map_id
		   and etd.hub_id = eh.hub_id
		   and pv.segment1 = '123456'
	  order by vendor_name;

		select distinct etd.*
		  from ap.ap_suppliers pv
			 , ap.ap_supplier_sites_all pvsa
			 , ecx.ecx_tp_headers eth
			 , ecx.ecx_tp_details etd
			 , ecx.ecx_mappings em
			 , ecx.ecx_hubs eh
		 where pv.vendor_id = eth.party_id
		   and pvsa.vendor_site_id = eth.party_site_id
		   and pv.vendor_id = pvsa.vendor_id
		   and eth.tp_header_id = etd.tp_header_id
		   and etd.map_id = em.map_id
		   and etd.hub_id = eh.hub_id
		   and pv.segment1 = '123456'
	  order by vendor_name;

-- ##################################################################
-- TABLE DUMPS
-- ##################################################################

select * from hr_locations_all;
select * from ecx_tp_details;
select * from ecx_hubs;
select * from ecx_tp_headers where party_id = 123456;
select * from hz_parties where party_id = 123456;
