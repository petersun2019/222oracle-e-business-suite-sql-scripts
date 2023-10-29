/*
File Name:		ap-invoices-locked.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##############################################################
-- LOCKED AP INVOICES
-- ##############################################################

/*
WHEN INVOICE VALIDATION GOES WRONG, THEY CAN BECOME LOCKED SO NOTHING CAN BE DONE TO THEM.
THIS SQL CAN FIND THOSE LOCKED INVOICES
*/

select * from ap.ap_invoices_all where validation_request_id is not null;

		select * from ap_invoices_all api
		 where api.validation_request_id is not null 
		   and exists (select 'Request Completed' 
						  from fnd_concurrent_requests fcr 
						 where fcr.request_id = api.validation_request_id 
						   and fcr.phase_code = 'C' ); 

/*
PATCH 21616697: GDF : VALIDATION REQUEST ID NOT NULL THOUGH VALIDATION ERROR
R12:PAYABLES:GENERIC DATA FIX (GDF) PATCH NUMBER 20651268 - INVOICES LOCKED BY INVOICE VALIDATION REQUEST THAT HAD COMPLETED IN ERROR (DOC ID 1072774.1)
*/

		select *
		  from ap_invoices_all ai 
		 where ai.validation_request_id is not null 
		   and ai.validation_request_id > 0 
		   and (exists (select 1 
						  from fnd_concurrent_requests fcr
						 where fcr.request_id = ai.validation_request_id 
						   and fcr.phase_code = 'C' ) 
		 or not exists (select 1 
						  from fnd_concurrent_requests fcr
						 where fcr.request_id = ai.validation_request_id ));
