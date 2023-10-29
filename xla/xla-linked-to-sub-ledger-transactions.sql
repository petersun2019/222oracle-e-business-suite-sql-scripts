/*
File Name: xla-linked-to-sub-ledger-transactions.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- PROJECT EXPENDITURES
-- AR TRANSACTIONS
-- AP INVOICES
-- XLA_EVENTS EVENT_STATUS_CODE
-- XLA_EVENTS PROCESS_STATUS_CODE

*/

-- ##################################################################
-- PROJECT EXPENDITURES
-- ##################################################################

		select *
		  from xla.xla_transaction_entities xte
		 where xte.application_id = 275
		   and xte.entity_code = 'EXPENDITURES'
		   and xte.source_id_int_1 in (1436209, 1433450);

		select *
		  from xla.xla_ae_headers xah
		 where xah.application_id = 275
		   and xah.entity_id in (select xte.entity_id
								   from xla.xla_transaction_entities xte
								  where xte.application_id = xah.application_id
								    and xte.entity_code = 'EXPENDITURES'
								    and xte.source_id_int_1 in (1436209, 1433450));

		select *
		  from xla.xla_events xe
		 where xe.application_id = 275
		   and xe.entity_id in (select xte.entity_id
								  from xla.xla_transaction_entities xte
								 where xte.application_id = xe.application_id
								   and xte.entity_code = 'EXPENDITURES'
								   and xte.source_id_int_1 in (1436209, 1433450));

		select xal.*
		  from xla.xla_ae_lines xal
		  join xla.xla_ae_headers xah on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		 where 1 = 1
		   and xah.application_id = 275
		   and xah.entity_id in (select xte.entity_id
								   from xla.xla_transaction_entities xte
								  where xte.application_id = xah.application_id
								    and xte.entity_code = 'EXPENDITURES'
								    and xte.source_id_int_1 in (1436209, 1433450));

-- ##################################################################
-- AR TRANSACTIONS
-- ##################################################################

		select *
		  from xla.xla_transaction_entities xte
		 where xte.application_id = 222
		   and xte.entity_code = 'TRANSACTIONS'
		   and xte.source_id_int_1 in (2190364,2382033);

		select *
		  from xla.xla_ae_headers xah
		 where xah.application_id = 222
		   and xah.entity_id in (select xte.entity_id
								   from xla.xla_transaction_entities xte
								  where xte.application_id = xah.application_id
								    and xte.entity_code = 'TRANSACTIONS'
								    and xte.source_id_int_1 in (2190364,2382033));

		select *
		  from xla.xla_events xe
		 where xe.application_id = 222
		   and xe.entity_id in (select xte.entity_id
								  from xla.xla_transaction_entities xte
								 where xte.application_id = xe.application_id
								   and xte.entity_code = 'TRANSACTIONS'
								   and xte.source_id_int_1 in (2190364,2382033));

		select xal.*
		  from xla.xla_ae_lines xal
		  join xla.xla_ae_headers xah on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		 where 1 = 1
		   and xah.application_id = 222
		   and xah.entity_id in (select xte.entity_id
								   from xla.xla_transaction_entities xte
								  where xte.application_id = xah.application_id
								    and xte.entity_code = 'TRANSACTIONS'
								    and xte.source_id_int_1 in (2190364,2382033));

-- ##################################################################
-- AP INVOICES
-- ##################################################################

/*
AP INVOICES, ENTITY_CODE = 'AP_INVOCES'
AP PAYMENTS, ENTITY_CODE = 'AP_PAYMENTS'
*/

		select *
		  from xla.xla_transaction_entities xte
		 where xte.application_id = 200
		   and xte.entity_code = 'AP_INVOICES'
		   and xte.source_id_int_1 = 38944843;

		select *
		  from xla.xla_ae_headers xah
		 where xah.application_id = 200
		   and xah.entity_id in (select xte.entity_id
								   from xla.xla_transaction_entities xte
								  where xte.application_id = xah.application_id
								    and xte.entity_code = 'AP_INVOICES'
								    and xte.source_id_int_1 = 38944843);

		select *
		  from xla.xla_events xe
		 where xe.application_id = 200
		   and xe.entity_id in (select xte.entity_id
								  from xla.xla_transaction_entities xte
								 where xte.application_id = xe.application_id
								   and xte.entity_code = 'AP_INVOICES'
								   and xte.source_id_int_1 = 337905);

		select xal.*
		  from xla.xla_ae_lines xal
		  join xla.xla_ae_headers xah on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		 where 1 = 1
		   and xah.application_id = 200
		   and xah.entity_id in (select xte.entity_id
								   from xla.xla_transaction_entities xte
								  where xte.application_id = xah.application_id
								    and xte.entity_code = 'AP_INVOICES'
								    and xte.source_id_int_1 = 337905);

-- ##################################################################
-- XLA_EVENTS EVENT_STATUS_CODE
-- ##################################################################

		select lookup_type
			 , lookup_code
			 , meaning
			 , description
		  from fnd_lookup_values_vl 
		 where view_application_id = 602
		   and lookup_type = 'XLA_EVENT_STATUS';

-- ##################################################################
-- XLA_EVENTS PROCESS_STATUS_CODE
-- ##################################################################

		select lookup_type
			 , lookup_code
			 , meaning
			 , description
		  from fnd_lookup_values_vl 
		 where view_application_id = 602
		   and lookup_type = 'XLA_EVENT_PROCESS_STATUS';
