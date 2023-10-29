/*
File Name:		po-purchase-orders-sqls-for-sr.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ###################################################################
-- PO DATA COLLECTION SQL USED FOR SERVICE REQUEST
-- ###################################################################

-- get po_header_id

select po_header_id from po_headers_all where segment1 = 'PO123456';

-- po_headers_all

select * from po_headers_all where po_header_id = 12345678;

-- po_lines_all

select * from po_lines_all where po_header_id = 12345678;

-- po_line_locations_all

select * from po_line_locations_all where po_header_id = 12345678;

-- po_distributions_all

select * from po_distributions_all where po_header_id = 12345678;

-- po_headers_archive_all

select * from po_headers_archive_all where po_header_id = 12345678;

-- po_lines_archive_all

select * from po_lines_archive_all where po_header_id = 12345678;

-- po_line_locations_archive_all

select * from po_line_locations_archive_all where po_header_id = 12345678;

-- po_distributions_archive_all

select * from po_distributions_archive_all where po_header_id = 12345678;

-- po_releases_all

select * from po_releases_all where po_header_id = 12345678;

-- po_bc_distributions

		select *
		  from po_bc_distributions
		 where je_source_name = 'Purchasing'
		   and je_category_name = 'Purchases'
		   and header_id = 12345678
	  order by packet_id;

-- xla_events

		select *
		  from xla.xla_events
		 where event_id in (select distinct ae_event_id
							  from po_bc_distributions
							 where je_source_name = 'Purchasing'
							   and je_category_name = 'Purchases'
							   and header_id = 12345678); 
-- xla_ae_headers

		select *
		  from xla.xla_ae_headers
		 where event_id in (select distinct ae_event_id 
							  from po_bc_distributions
							 where je_source_name = 'Purchasing'
							   and je_category_name = 'Purchases'
							   and header_id = 12345678);
-- xla_ae_lines

		select *
		  from xla.xla_ae_lines 
		 where ae_header_id in (select ae_header_id
								  from xla.xla_ae_headers
								 where event_id in (select distinct ae_event_id 
													  from po_bc_distributions
													 where je_source_name = 'Purchasing'
													   and je_category_name = 'Purchases'
													   and header_id = 12345678));

-- xla_transaction_entities

		select *
		  from xla.xla_transaction_entities
		 where entity_id in (select distinct entity_id
							  from  xla.xla_events
							  where event_id in (select distinct ae_event_id
												   from po_bc_distributions
												  where je_source_name = 'Purchasing'
												    and je_category_name = 'Purchases'
												    and header_id = 12345678));

-- xla_distribution_links

		select *
		  from xla.xla_distribution_links
		 where event_id in (select distinct ae_event_id
							  from po_bc_distributions
							 where je_source_name = 'Purchasing'
							   and je_category_name = 'Purchases'
							   and header_id = 12345678);

-- po_action_history

		select * from po_action_history 
		 where object_id = 12345678 
		   and object_type_code = 'PO' 
		   and object_sub_type_code = 'STANDARD';
