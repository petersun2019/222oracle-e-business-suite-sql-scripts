/*
File Name: po-commodities.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- SIMPLE COMMODITY CHECK
-- COUNT OF CATEGORIES PER COMMODITY
-- CATEGORIES - ARE THEY LINKED TO COMMODITY?

*/

-- ##################################################################
-- SIMPLE COMMODITY CHECK
-- ##################################################################

		select pct.*
		  from po.po_commodities_tl pct;

-- ##################################################################
-- COUNT OF CATEGORIES PER COMMODITY
-- ##################################################################

		select pct.name
			 , (select count(*)
		  from po.po_commodity_categories pcc
		 where pcc.commodity_id = pct.commodity_id) category_count
		  from po.po_commodities_tl pct
		  join po.po_commodities_b cob on pct.commodity_id = cob.commodity_id
		 where cob.active_flag = 'Y';

-- ##################################################################
-- CATEGORIES - ARE THEY LINKED TO COMMODITY?
-- ##################################################################

		select mcb.segment1 || '.' || mcb.segment2 category
			 , mcb.creation_date cat_creation_date
			 , fu.description created_by
			 , pct.name commodity
		  from po.po_commodity_categories pcc
	right join po.po_commodities_tl pct on pcc.commodity_id = pct.commodity_id
	right join inv.mtl_categories_b mcb on mcb.category_id = pcc.category_id
		  join applsys.fnd_user fu on mcb.created_by = fu.user_id
		 where mcb.disable_date is null
	  order by 1;
