/*
File Name:		po-requisitions-sqls-for-service-request.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ###################################################################
-- SQLS FOR REQUISITION FOR SR
-- ###################################################################

-- GET THE REQUISITION_HEADER_ID FOR THE REQ_DISTRIBUTION_ID IN PO_DISTRIBUTIONS_ALL AND USE THAT IN BELOW SQLS

		select distinct prl.requisition_header_id
		  from po.po_requisition_lines_all prl,
			   po.po_req_distributions_all prd,
			   po.po_distributions_all pod
		 where prd.distribution_id=pod.req_distribution_id
		   and prd.requisition_line_id = prl.requisition_line_id 
		   and pod.po_header_id = 12345678;

-- 1.
		select *
		  from po.po_requisition_headers_all
		 where requisition_header_id = 12345678;


--2.
		select *
		  from po.po_requisition_lines_all
		 where requisition_header_id = 12345678;

--3.
		select *
		  from po.po_req_distributions_all
		 where requisition_line_id in (select requisition_line_id
		  from po.po_requisition_lines_all
		 where requisition_header_id = 12345678);

-- 4.
		select *
		  from po.po_bc_distributions
		 where je_source_name = 'Purchasing'
		   and je_category_name = 'Requisitions'
		   and header_id = 12345678;

-- 5.
		select *
		  from xla.xla_events
		 where event_id in (select distinct ae_event_id
									  from po.po_bc_distributions
									 where je_source_name = 'Purchasing'
									   and je_category_name = 'Requisitions'
									   and header_id = 12345678); 

-- 6.
		select *
		  from xla.xla_ae_headers
		 where event_id in (select distinct ae_event_id 
									  from po.po_bc_distributions
									 where je_source_name = 'Purchasing'
									   and je_category_name = 'Requisitions'
									   and header_id = 12345678);

-- 7.
		select *
		  from xla.xla_ae_lines
		 where ae_header_id in (select ae_header_id
									  from xla.xla_ae_headers
									 where event_id in (select distinct ae_event_id 
																  from po.po_bc_distributions
																 where je_source_name = 'Purchasing'
																   and je_category_name = 'Requisitions'
																   and header_id = 12345678));

-- 8.
		select *
		  from xla.xla_transaction_entities
		 where entity_id in (select distinct entity_id
										  from xla.xla_events
										 where event_id in (select distinct ae_event_id
																	  from po.po_bc_distributions
																	 where je_source_name = 'Purchasing'
																	   and je_category_name = 'Requisitions'
																	   and header_id = 12345678));

-- 9.
		select *
		  from xla.xla_distribution_links
		 where event_id in (select distinct ae_event_id
									  from po.po_bc_distributions
									 where je_source_name = 'Purchasing'
									   and je_category_name = 'Requisitions'
									   and header_id = 12345678);

-- 10.
		select * from po.po_action_history 
		 where object_id = 12345678 and object_type_code = 'REQUISITION';
