/*
File Name:		po-locations.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- LOCATION INFO
-- REQ HEADERS AND LINES PER LOCATION
-- PURCHASE ORDER HEADER COUNT PER SHIP TO LOCATION
-- PURCHASE ORDER HEADER COUNT PER BILL TO LOCATION
-- LOCATION STATS
-- LOCATION SUMMARY

*/

-- ##################################################################
-- LOCATION INFO
-- ##################################################################

/*
ship to site, bill to site, receiving site, internal site, office site
*/

		select hla.location_code
			 , hla.description
			 , ship.location_code ship_to_location
			 , ship.description ship_to_description
			 , hla.ship_to_site_flag
			 , hla.receiving_site_flag
			 , hla.bill_to_site_flag
			 , hla.in_organization_flag
			 , hla.office_site_flag
			 , hla.address_line_1
			 , hla.address_line_2
			 , hla.address_line_3
			 , hla.town_or_city
			 , hla.country
			 , hla.postal_code
			 , hla.creation_date
			 , cr.description created_by
			 , hla.last_update_date
			 , up.description updated_by
			 , hla.inactive_date
			 , (select count(*) from po.po_requisition_lines_all prla where prla.deliver_to_location_id = hla.location_id and prla.creation_date > '01-AUG-2015') req_line_ct
			 , (select count(distinct prla.requisition_header_id) from po.po_requisition_lines_all prla where prla.deliver_to_location_id = hla.location_id and prla.creation_date > '01-AUG-2015') req_header_ct
			 , (select round(sum(prla.unit_price * prla.quantity),2) from po.po_requisition_lines_all prla where prla.deliver_to_location_id = hla.location_id and prla.creation_date > '01-AUG-2015') total_spend
		  from hr.hr_locations_all hla
		  join applsys.fnd_user cr on hla.created_by = cr.user_id
		  join applsys.fnd_user up on hla.last_updated_by = up.user_id
	 left join hr.hr_locations_all ship on hla.ship_to_location_id = ship.location_id
	  order by hla.location_code;

-- ##################################################################
-- REQ HEADERS AND LINES PER LOCATION
-- ##################################################################

		select hla.location_code
			 , count (distinct prha.requisition_header_id) req_headers
			 , count (distinct prla.requisition_line_id) req_lines
		  from po.po_requisition_headers_all prha
		  join po.po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join hr.hr_locations_all hla on prla.deliver_to_location_id = hla.location_id
	  group by hla.location_code
	  order by hla.location_code;

-- ##################################################################
-- PURCHASE ORDER HEADER COUNT PER SHIP TO LOCATION
-- ##################################################################

		select hla.location_code
			 , count(*) ct
		  from hr.hr_locations_all hla
		  join po.po_headers_all pha on pha.ship_to_location_id = hla.location_id
	  group by hla.location_code
	  order by hla.location_code;

-- ##################################################################
-- PURCHASE ORDER HEADER COUNT PER BILL TO LOCATION
-- ##################################################################

		select hla.location_code
			 , count(*) ct
		  from hr.hr_locations_all hla
		  join po.po_headers_all pha on pha.bill_to_location_id = hla.location_id
	  group by hla.location_code
	  order by hla.location_code;

-- ##################################################################
-- LOCATION STATS
-- ##################################################################

		select hla.location_code
			 , count(distinct prla.requisition_line_id) req_lines
			 , count(distinct prla.requisition_header_id) req_headers
			 , round(sum(prla.unit_price * prla.quantity),2) total_spend
		  from hr.hr_locations_all hla
		  join po.po_requisition_lines_all prla on hla.location_id = prla.deliver_to_location_id
		  join po.po_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
	  group by hla.location_code
	  order by hla.location_code;

-- ##################################################################
-- LOCATION SUMMARY
-- ##################################################################

		select hla.location_code
			 , hla.creation_date loc_created
			 , fu.user_name loc_created_by
			 , hla.last_update_date loc_updated
			 , fu2.user_name loc_updated_by
			 , hla.ship_to_site_flag
			 , hla.bill_to_site_flag
			 , hla.receiving_site_flag
			 , hla.in_organization_flag
			 , hla.office_site_flag
			 , '##'
			 , tbl_req.req_min_date
			 , tbl_req.req_max_date
			 , tbl_req.req_count
			 , tbl_req.req_line_count
			 , '##'
			 , tbl_po.po_min_date
			 , tbl_po.po_max_date
			 , tbl_po.po_count
			 , tbl_po.po_line_count
		  from hr_locations_all hla
	 left join (select prla.deliver_to_location_id
					 , min(prha.creation_date) req_min_date
					 , max(prha.creation_date) req_max_date
					 , count (distinct prha.requisition_header_id) req_count
					 , count (distinct prla.requisition_line_id) req_line_count
				  from po_requisition_headers_all prha
				  join po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
			  group by prla.deliver_to_location_id) tbl_req on tbl_req.deliver_to_location_id = hla.location_id
	 left join (select pha.ship_to_location_id
					 , min(pha.creation_date) po_min_date
					 , max(pha.creation_date) po_max_date
					 , count (distinct pha.po_header_id) po_count
					 , count (distinct pla.po_line_id) po_line_count
				  from po_headers_all pha
				  join po_lines_all pla on pha.po_header_id = pla.po_header_id
			  group by pha.ship_to_location_id) tbl_po on tbl_po.ship_to_location_id = hla.location_id
		  join fnd_user fu on hla.created_by = fu.user_id
		  join fnd_user fu2 on hla.last_updated_by = fu2.user_id;
