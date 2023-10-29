/*
File Name: 03-xla-events.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

XLA_EVENTS
This table contains all information related to a specific event

XLA_TRANSACTION_ENTITIES.SOURCE_ID_INT_1 column is often used for the main identifier for a transaction such as an AP Invoice, AR Transaction etc.
So if you have that ID, you can check what SLA data exists for that Transaction by searching against it using the SOURCE_ID_INT_1 column.

Queries:

-- BASIC
-- DETAILED

*/

-- ##################################################################
-- BASIC
-- ##################################################################

select * from xla.xla_events xe where entity_id = 12345678;

-- ##################################################################
-- DETAILED
-- ##################################################################

		select fat.application_id
			 , fat.application_name
			 , '#' xte___
			 , xte.entity_id
			 , xte.entity_code
			 , xte.source_id_int_1
			 , xte.transaction_number
			 , '#' xah___
			 , xah.ae_header_id
			 , decode(xah.balance_type_code,'E','Encumbrance','A','Actual') balance_type
			 , xah.period_name
			 , xah.completed_date
			 , to_char(xah.accounting_date, 'dd-mon-yyyy') accounting_date
			 , xah.gl_transfer_status_code
			 , xah.je_category_name
			 , xah.creation_date
			 , xah.request_id
			 , xah.group_id
			 , xah.description
			 , '#' xla_events___
			 , xe.event_id
			 , xe.*
		  from xla.xla_ae_headers xah
		  join xla.xla_transaction_entities xte on xah.entity_id = xte.entity_id and xah.application_id = xte.application_id
		  join xla.xla_events xe on xe.entity_id = xte.entity_id and xte.application_id = xe.application_id
		  join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
		  join apps.fnd_lookup_values_vl flv2 on xe.event_status_code = flv2.lookup_code and flv2.lookup_type = 'XLA_EVENT_STATUS'
		  join apps.fnd_lookup_values_vl flv3 on xe.process_status_code = flv3.lookup_code and flv3.lookup_type = 'XLA_EVENT_PROCESS_STATUS'
		 where 1 = 1
		   and fat.application_name = 'Projects'
		   and xah.application_id = 275
		   -- and xte.entity_code = 'EXPENDITURES'
		   -- and xte.entity_code = 'AP_INVOICES'
		   -- and xah.je_category_name = 'Purchase Invoices'
		  --  and xe.event_type_code = 'SUPP_COST_DIST'
		   and xte.source_id_int_1 in (12345678)
		   -- and xah.gl_transfer_status_code = 'N'
		   and 1 = 1;
