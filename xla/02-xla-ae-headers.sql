/*
File Name: 02-xla-ae-headers.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
XLA_AE_HEADERS
This table contains subledger accounting journal entries

XLA_TRANSACTION_ENTITIES.SOURCE_ID_INT_1 column is often used for the main identifier for a transaction such as an AP Invoice, AR Transaction etc.
So if you have that ID, you can check what SLA data exists for that Transaction by searching against it using the SOURCE_ID_INT_1 column.

Queries:

-- BASIC
-- DETAILED
-- STUCK SUMMARY

*/

-- ##################################################################
-- BASIC
-- ##################################################################

select * from xla.xla_ae_headers xah where xah.entity_id = 123456;

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
			 , xah.*
		  from xla.xla_ae_headers xah
		  join xla.xla_transaction_entities xte on xah.entity_id = xte.entity_id and xah.application_id = xte.application_id
		  join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
		 where 1 = 1
		   and fat.application_name = 'Projects'
		   -- and xah.application_id = 275
		   -- and xte.entity_code = 'EXPENDITURES'
		   -- and xah.je_category_name = 'Purchase Invoices'
		   -- and xe.event_type_code = 'SUPP_COST_DIST'
		   -- and xte.source_id_int_1 in (12345678)
		   and xah.gl_transfer_status_code = 'N'
		   and 1 = 1;

-- ##################################################################
-- STUCK SUMMARY
-- ##################################################################

		select fat.application_id
			 , fat.application_name
			 , xte.entity_code
			 , min(xte.creation_date)
			 , max(xte.creation_date)
			 , count(*)
		  from xla.xla_ae_headers xah
		  join xla.xla_transaction_entities xte on xah.entity_id = xte.entity_id and xah.application_id = xte.application_id
		  join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
		 where 1 = 1
		   and fat.application_name = 'Projects'
		   and xah.gl_transfer_status_code = 'N'
		   and 1 = 1
	  group by fat.application_id
			 , fat.application_name
			 , xte.entity_code;

/*
https://erp-integrations.com/2017/11/02/accounting_entry_status_code-column-in-xla_ae_headers-table-r12/

What does “accounting_entry_status_code” column represent in “xla_ae_headers” table?
The column represents accounting status of a transaction event.
The following describes the values and their descriptions:

1. If accounting_entry_status_code = 'F' then event is accounted successfully.
2. If accounting_entry_status_code = 'N' then event is still not processed.
3. If accounting_entry_status_code = 'I' then event is failed.
4. If accounting_entry_status_code = 'R' then event is in error.
5. If accounting_entry_status_code = 'D' then event is draft accounting entry.
*/
