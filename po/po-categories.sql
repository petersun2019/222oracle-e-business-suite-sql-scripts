/*
File Name:		po-categories.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- CATEGORY DETAILS
-- CATEGORY DETAILS LINKED TO REQUISITIONS
-- CATEGORY STATS 1
-- CATEGORY STATS 2

*/

-- ##################################################################
-- CATEGORY DETAILS
-- ##################################################################

		select mcb.segment1 || '.' || mcb.segment2 category
			 , mct.description
			 , mcb.creation_date
			 , fu.description created_by
			 , mcb.enabled_flag
			 , mcst.description category_structure
		  from inv.mtl_categories_b mcb
		  join inv.mtl_categories_tl mct on mcb.category_id = mct.category_id
		  join inv.mtl_category_sets_b mcsb on mcb.structure_id = mcsb.structure_id
		  join inv.mtl_category_sets_tl mcst on mcsb.category_set_id = mcst.category_set_id
		  join applsys.fnd_user fu on mcb.created_by = fu.user_id;

-- ##################################################################
-- CATEGORY DETAILS LINKED TO REQUISITIONS
-- ##################################################################

		select prha.segment1
			 , mcb.segment1 || '.' || mcb.segment2 cat
			 , prla.*
		  from po.po_requisition_headers_all prha
		  join po.po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join inv.mtl_categories_b mcb on mcb.category_id = prla.category_id;

-- ##################################################################
-- CATEGORY STATS 1
-- ##################################################################

		select mcb.segment1 || '.' || mcb.segment2 category
			 , count(distinct prla.requisition_line_id) req_lines
			 , count(distinct prla.requisition_header_id) req_headers
			 , round(sum(prla.unit_price * prla.quantity),2) total_spend
			 , min(fu.user_name)
			 , max(fu.user_name)
			 , min(prha.creation_date)
			 , max(prha.creation_date)
			 , min(prha.segment1)
			 , max(prha.segment1)
			 , mct.description
			 , mcst.description category_structure
		  from inv.mtl_categories_b mcb
		  join inv.mtl_categories_tl mct on mcb.category_id = mct.category_id
		  join inv.mtl_category_sets_b mcsb on mcb.structure_id = mcsb.structure_id
		  join inv.mtl_category_sets_tl mcst on mcsb.category_set_id = mcst.category_set_id
		  join po.po_requisition_lines_all prla on mcb.category_id = prla.category_id
		  join po.po_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
		  join applsys.fnd_user fu on fu.user_id = prha.created_by
		 where 1 = 1
		   -- and mcb.segment1 = 'ABC'
		   -- and fu.user_name like 'CHEESE%'
		   -- and fu.user_name != 'CHEESE_ADMIN'
	  group by mcb.segment1 || '.' || mcb.segment2
			 , mct.description
			 , mcst.description
	  order by mcst.description
			 , mcb.segment1 || '.' || mcb.segment2;

-- ##################################################################
-- CATEGORY STATS 2
-- ##################################################################

		select mcb.segment1 category
			 , count(distinct prla.requisition_line_id) req_lines
			 , count(distinct prla.requisition_header_id) req_headers
			 , round(sum(prla.unit_price * prla.quantity),2) total_spend
			 , mcst.description category_structure
		  from inv.mtl_categories_b mcb
		  join inv.mtl_category_sets_b mcsb on mcb.structure_id = mcsb.structure_id
		  join inv.mtl_category_sets_tl mcst on mcsb.category_set_id = mcst.category_set_id
		  join po.po_requisition_lines_all prla on mcb.category_id = prla.category_id
		  join po.po_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
		 where 1 = 1
		   -- and mcb.segment1 = '101'
	  group by mcb.segment1
			 , mcst.description
	  order by mcst.description
			 , mcb.segment1;
