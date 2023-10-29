/*
File Name:		01-xla-transaction-entities.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

XLA_TRANSACTION_ENTITIES
This table contains a row for each transaction for which events have been raised in Subledger Accounting.

FYI:

If do this on some customers, then nothing is returned:
select * from xla_transaction_entities xte where source_id_int_1 = 31347870;

Yet if I put xla. in front of the table name, data is returned:
select * from xla.xla_transaction_entities xte where source_id_int_1 = 31347870;

The source_id_int_1 value for data in the xla_transaction_entities is often the main ID of the key related sub-ledger transaction.
For example, it might be the Invoice ID for an AP Invoice, or the Transaction ID for an AR Transaction.

You can use the SQL in the "xla_entity_id_mappings.sql" file to find out more about that.

Queries:

-- BASIC
-- LINKED TO APPLICATION

*/

-- ##################################################################
-- BASIC
-- ##################################################################

select * from xla.xla_transaction_entities xte where source_id_int_1 = 12345678;

-- ##################################################################
-- LINKED TO APPLICATION
-- ##################################################################

		select fat.application_name
			 , '#' xte___
			 , xte.*
		  from xla.xla_transaction_entities xte
		  join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
		 where 1 = 1
		   and fat.application_name = 'Projects'
		   -- and xte.entity_code = 'EXPENDITURES'
		   -- and xte.entity_code = 'AP_INVOICES'
		   -- and xte.creation_date > '23-APR-2020'
		   -- and xte.application_id = 140
		   and xte.source_id_int_1 in (12345678)
		   and 1 = 1
	  order by xte.creation_date desc;
