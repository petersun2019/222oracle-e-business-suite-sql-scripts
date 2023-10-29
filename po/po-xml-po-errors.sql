/*
File Name:		po-xml-po-errors.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- TABLE DUMPS
-- XML PO LOGS

*/

-- ##################################################################
-- TABLE DUMPS
-- ##################################################################

select * from ecx.ecx_error_msgs eem;
select * from ecx.ecx_doclogs ed  where document_number = '123456:0:123';
select * from ecx.ecx_outbound_logs eol where document_number = '123456:0:123';

-- ##################################################################
-- XML PO LOGS
-- ##################################################################

/* osn po send - xml generation failure (doc id 1576179.1) */

		select eol.trigger_id
			 , eol.transaction_type
			 , eol.transaction_subtype
			 , eol.document_number
			 , case when eem.message <> 'ECX_MSG_CREATED_ENQUEUED' then 'error' else 'ok' end dd
			 , eol.status
			 , eol.error_id
			 , eol.logfile
			 , eol.time_stamp
			 , eol.party_type
			 , eem.message
			 , pha.segment1 po
			 , pha.creation_date
			 -- , '####################'
			 -- , det.*
		  from ecx.ecx_outbound_logs eol
	 left join ecx.ecx_error_msgs eem on eol.error_id = eem.error_id
	 left join po.po_headers_all pha on substr(eol.document_number,0,7) = to_char(pha.segment1)
	 -- left join applsys.fnd_attached_documents ad on pha.po_header_id = ad.pk1_value
	 -- left join applsys.fnd_document_entities_tl det on ad.entity_name = det.data_object_code
		 where 1 = 1
		   -- and eem.message <> 'ECX_MSG_CREATED_ENQUEUED'
		   and pha.creation_date > '15-OCT-2021'
		   -- and pha.segment1 = '123456'
		   -- and ad.entity_name = 'PO_HEAD'
		   -- and eol.document_number = '123456:0:82'
	  order by pha.creation_date desc;
