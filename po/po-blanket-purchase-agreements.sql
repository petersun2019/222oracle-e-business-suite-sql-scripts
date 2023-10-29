/*
File Name: po-blanket-purchase-agreements.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- BLANKET PURCHASE AGREEMENTS - HEADERS
-- BPA LINES
-- TRYING TO REPLICATE CATALOGUE SPREADSHEET
-- OPEN / CLOSED LINE COUNTING 1
-- OPEN / CLOSED LINE COUNTING 2
-- OPEN / CLOSED LINE COUNTING 3

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
-- BLANKET PURCHASE AGREEMENTS - HEADERS
-- ##################################################################

		select pha.po_header_id
			 , pha.segment1 po
			 , pha.authorization_status
			 , pha.approved_date
			 , pha.creation_date
			 , pha.last_update_date
			 , pha.revision_num
			 , pha.start_date
			 , pha.end_date
			 , pha.cat_admin_auth_enabled_flag
			 , pav.agent_name buyer
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
		  from po_headers_all pha
		  join ap_suppliers pv on pha.vendor_id = pv.vendor_id
		  join ap_supplier_sites_all pvsa on pv.vendor_id = pvsa.vendor_id and pha.vendor_site_id = pvsa.vendor_site_id
		  join po_agents_v pav on pha.agent_id = pav.agent_id
		 where 1 = 1
		   and pha.type_lookup_code='BLANKET'
		   and pha.authorization_status='APPROVED'
		   and pha.segment1 = 'BPA123456'
		   -- and pha.cat_admin_auth_enabled_flag = 'Y'
		   and 1 = 1;

-- ##################################################################
-- BPA LINES
-- ##################################################################

		select pha.segment1
			 , pha.po_header_id
			 , pv.vendor_name
			 , pha.type_lookup_code
			 , pha.approved_date
			 , pha.authorization_status po_status
			 , pla.po_line_id
			 , pla.item_description
			 , pla.creation_date line_created
			 , pla.last_update_date line_updated
			 , pla.line_num
			 , pla.unit_price
			 , pla.list_price_per_unit list_price
			 , pla.expiration_date
			 , pla.vendor_product_num supplier_item
			 , '###'
			 , icavt.po_line_id icx_line_id
			 , icavt.last_update_date
			 -- , '############################'
			 -- , pla.*
		  from po.po_headers_all pha
		  join po.po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join apps.ap_suppliers pv on pha.vendor_id = pv.vendor_id
		  join po.po_attribute_values pav on pla.po_line_id = pav.po_line_id
		  join po.po_attribute_values_tlp pavt on pla.po_line_id = pavt.po_line_id
	 left join icx.icx_cat_attribute_values icav on icav.po_line_id = pla.po_line_id
	 left join icx.icx_cat_attribute_values_tlp icavt on icavt.po_line_id = pla.po_line_id
	 left join icx.icx_cat_items_ctx_hdrs_tlp icicht on icicht.po_line_id = pla.po_line_id and icicht.org_id = pha.org_id
		 where 1 = 1
		   and pha.segment1 = 'BPA123456'
		   and pha.type_lookup_code = 'BLANKET'
		   -- and nvl(pla.expiration_date, sysdate + 1) < sysdate
		   and pla.last_update_date > '24-OCT-2018'
		   -- and pv.vendor_name = 'Cheese Group Ltd'
		   -- and pla.vendor_product_num in ('CHEESE-123','CHEDDAR-456','ADAM-97531')
		   and 1 = 1
	  order by pla.creation_date desc;

-- ##################################################################
-- TRYING TO REPLICATE CATALOGUE SPREADSHEET
-- ##################################################################

		select pha.segment1
			 , pha.po_header_id
			 , pv.vendor_name
			 , pha.type_lookup_code
			 , pha.authorization_status po_status
			 , pla.po_line_id
			 , pla.creation_date line_created
			 , pla.last_update_date line_updated
			 , '###################'
			 , 'SYNC' action
			 , pla.line_num
			 , pla.price_break_lookup_code
			 , pla.last_updated_by
			 , null line_type
			 -- , icav.thumbnail_image
			 -- , icav.picture image
			 , pavt.description
			 -- , icicht.ip_category_name shopping_category
			 , null category
			 , pla.vendor_product_num supplier_item
			 -- , icicht.supplier_part_auxid
			 , null internal_item_number
			 , pla.item_revision
			 -- , icavt.manufacturer
			 -- , icav.manufacturer_part_num
			 , pav.text_base_attribute1 product_size
			 , pla.unit_meas_lookup_code unit
			 , pav.text_base_attribute2 list_price
			 , pla.unit_price price
			 , pav.availability
			 , pav.lead_time
			 , pav.text_base_attribute3 radioactive
			 , pav.text_base_attribute4 hazardouse_material
			 , pav.text_base_attribute5 controlled_substance
			 , pav.text_base_attribute6 toxin
			 , pav.text_base_attribute7 schedule_5
			 , pav.text_base_attribute8 chem_weapon
			 , pav.unspsc
			 , pavt.alias
			 , pavt.comments
			 , pavt.long_description
			 , pav.attachment_url
			 , pav.supplier_url
			 , pav.manufacturer_url
			 , pav.text_base_attribute9 alternative_item
			 , null un_number
			 , null hazard_class
			 , null lowest_cost_item
			 , pav.text_base_attribute11 green_item
			 , pav.text_base_attribute12 green_supplier
			 , pav.text_base_attribute13 equivalent_item
			 , pav.text_base_attribute14 cas_number
			 , null preferred_item_status
			 , to_char(pla.expiration_date, 'dd-mon-yyyy') expiration_date
			 , null ship_to_org
			 , null ship_to_location
			 , pla.quantity
			 , to_char(pla.start_date, 'dd-mon-yyyy') effective_from
			 , to_char(pla.expiration_date, 'dd-mon-yyyy') effective_to
			 , null break_price
			 , null discount 
			 , '############################'
			 -- , icicht.*
		  from po.po_headers_all pha
		  join po.po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join apps.ap_suppliers pv on pha.vendor_id = pv.vendor_id
	 left join po.po_attribute_values pav on pla.po_line_id = pav.po_line_id
	 left join po.po_attribute_values_tlp pavt on pla.po_line_id = pavt.po_line_id
	 -- left join icx.icx_cat_attribute_values icav on icav.po_line_id = pla.po_line_id
	 -- left join icx.icx_cat_attribute_values_tlp icavt on icavt.po_line_id = pla.po_line_id
	 -- left join icx.icx_cat_items_ctx_hdrs_tlp icicht on icicht.po_line_id = pla.po_line_id
		 where 1 = 1
		   and pha.segment1 = 'BPA123456'
		   and pha.type_lookup_code = 'BLANKET'
		   -- and pla.vendor_product_num = 'CHEESE-123'
		   -- and pav.lead_time is not null
		   -- and pv.vendor_name = 'Cheese Group Ltd'
		   -- and pha.po_header_id = 123456
		   -- and pla.po_line_id in (123, 456)
		   -- and pla.po_line_id = 123
		   -- and pla.line_num = 123
		   -- and pla.line_num between 123 and 129
		   -- and pla.creation_date > '20-SEP-2018'
		   -- and pla.last_update_date > '01-JUL-2018'
		   -- and pavt.description = 'CHEESE BOX'
		   -- and expiration_date is null
		   and 1 = 1
	  order by pla.creation_date desc;

-- ##################################################################
-- OPEN / CLOSED LINE COUNTING 1
-- ##################################################################

		select /*+ parallel */ pha.segment1 po
			 , pha.authorization_status po_status
			 , pha.approved_date
			 , pha.creation_date
			 , pha.last_update_date
			 , pha.po_header_id
			 , pha.revision_num revision_num
			 , pav.agent_name buyer
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
			 -- , (select count(*) from po_lines_all pla where pla.po_header_id = pha.po_header_id) bpa_lines_total
			 , (select count(*) from po_lines_all pla where pla.po_header_id = pha.po_header_id and nvl(pla.expiration_date, sysdate + 1) > sysdate) bpa_lines_open
			 -- , (select count(*) from po_lines_all pla where pla.po_header_id = pha.po_header_id and nvl(pla.expiration_date, sysdate + 1) > sysdate) bpa_lines_open
			 -- , (select max(creation_date) from po_lines_all pla where pla.from_header_id = pha.po_header_id) last_linked_po
		  from po_headers_all pha
		  join ap_suppliers pv on pha.vendor_id = pv.vendor_id
		  join ap_supplier_sites_all pvsa on pv.vendor_id = pvsa.vendor_id and pha.vendor_site_id = pvsa.vendor_site_id
		  join po_agents_v pav on pha.agent_id = pav.agent_id
		 where pha.type_lookup_code = 'BLANKET'
		   -- and pha.segment1 in ('BPA123456','BPA123457')
		   and pha.authorization_status = 'APPROVED'
		   -- and (select count(*) from po_lines_all pla where pla.po_header_id = pha.po_header_id) > 30000
	  order by 8 desc;

-- ##################################################################
-- OPEN / CLOSED LINE COUNTING 2
-- ##################################################################

		select /*+ parallel */ pha.segment1 po
			 , pha.authorization_status status
			 , pha.approved_date
			 , pha.creation_date
			 , pha.last_update_date
			 , pha.po_header_id
			 , pha.revision_num rev
			 , pav.agent_name buyer
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
			 , count(*) bpa_line_count
		  from po_headers_all pha
		  join po.po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join ap_suppliers pv on pha.vendor_id = pv.vendor_id
		  join ap_supplier_sites_all pvsa on pv.vendor_id = pvsa.vendor_id and pha.vendor_site_id = pvsa.vendor_site_id
		  join po_agents_v pav on pha.agent_id = pav.agent_id
		 where pha.type_lookup_code = 'BLANKET'
		   -- and pha.segment1 in ('BPA123456','BPA123457')
		   and pha.authorization_status = 'APPROVED'
	  group by pha.segment1
			 , pha.authorization_status
			 , pha.approved_date
			 , pha.creation_date
			 , pha.last_update_date
			 , pha.po_header_id
			 , pha.revision_num
			 , pav.agent_name
			 , pv.vendor_name
			 , pvsa.vendor_site_code
	  order by pha.creation_date desc; 

-- ##################################################################
-- OPEN / CLOSED LINE COUNTING 3
-- ##################################################################

		select /*+parallel */ 
po.po_header_id
			 , po.po 
			 , po.authorization_status
			 , po.approved_date
			 , po.creation_date
			 , po.start_date
			 , po.end_date
			 , po.last_update_date
			 , po.revision_num
			 , po.buyer
			 , po.supplier
			 , po.site
			 , sum(open_lines) open_lines
			 , sum(closed_lines) closed_lines
		  from (select pha.po_header_id
			 , pha.segment1 po
			 , pha.authorization_status
			 , pha.approved_date
			 , pha.creation_date
			 , pha.last_update_date
			 , pha.revision_num
			 , pha.start_date
			 , pha.end_date
			 , pav.agent_name buyer
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
			 , (case when nvl(pla.expiration_date,sysdate+1) < sysdate then 1 else 0 end) closed_lines
			 , (case when nvl(pla.expiration_date,sysdate+1) > sysdate then 1 else 0 end) open_lines
		  from po_headers_all pha
		  join po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join ap_suppliers pv on pha.vendor_id = pv.vendor_id
		  join ap_supplier_sites_all pvsa on pv.vendor_id = pvsa.vendor_id and pha.vendor_site_id = pvsa.vendor_site_id
		  join po_agents_v pav on pha.agent_id = pav.agent_id
		 where pha.type_lookup_code='BLANKET'
		   and pha.authorization_status='APPROVED'
		   -- and pha.po_header_id in (20)
		   and 1 = 1) po
	  group by po.po_header_id
			 , po.po 
			 , po.authorization_status
			 , po.approved_date
			 , po.creation_date
			 , po.start_date
			 , po.end_date
			 , po.last_update_date
			 , po.revision_num
			 , po.buyer
			 , po.supplier
			 , po.site;
