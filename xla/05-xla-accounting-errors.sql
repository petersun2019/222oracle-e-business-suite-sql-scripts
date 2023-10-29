/*
File Name: 05-xla-accounting-errors.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- BASIC
-- SLA ACCOUNTING ERRORS
-- SLA ACCOUNTING ERRORS - COUNT SUMMARY 1
-- SLA ACCOUNTING ERRORS - COUNT SUMMARY 2

*/

-- ##################################################################
-- BASIC
-- ##################################################################

select * from xla.xla_accounting_errors where creation_date > '01-OCT-2021' and message_number not in (95349);

-- ##################################################################
-- SLA ACCOUNTING ERRORS
-- ##################################################################

		select fat.application_name
			 , '######## xla_ae_headers #########' xla_ae_headers
			 , xah.ae_header_id ae_header_id
			 , decode(xah.balance_type_code,'E','Encumbrance','A','Actual') balance_type
			 , xah.period_name
			 , xah.completed_date
			 , to_char(xah.accounting_date, 'DD-MON-YYYY') accounting_date
			 , xah.gl_transfer_status_code
			 , xah.je_category_name
			 , xah.creation_date
			 , '######## xla_accounting_errors #########' xla_accounting_errors
			 , xae.event_id
			 , xae.accounting_error_id
			 , xae.entity_id
			 , xae.ledger_id
			 , xae.accounting_batch_id
			 , (replace(replace(xae.encoded_msg,chr(10),''),chr(13),' ')) encoded_msg
			 , xae.ae_header_id
			 , xae.ae_line_num
			 , xae.message_number
			 , xae.error_source_code
			 , xae.application_id
			 , xae.created_by
			 , xae.creation_date
			 , xae.last_update_date
			 , xae.last_updated_by
			 , xae.last_update_login
			 , xae.request_id
		  from xla_accounting_errors xae
		  join fnd_application_tl fat on xae.application_id = fat.application_id and fat.language = userenv('lang')
		  join xla_ae_headers xah on xae.ae_header_id = xah.ae_header_id
		 where 1 = 1
		   -- and xae.creation_date > '17-AUG-2021'
		   -- and fat.application_name = 'Projects'
		   -- and xae.event_id in (12345678)
		   -- and xae.encoded_msg like 'The GL date %'
		   -- and xae.message_number = '95325'
		   and 1 = 1
	  order by xae.creation_date desc;

-- ##################################################################
-- SLA ACCOUNTING ERRORS - COUNT SUMMARY 1
-- ##################################################################

		select xae.encoded_msg
			 , to_char(xae.creation_date, 'yyyy-mm-dd') date_created
			 , fu.user_name
			 , fu.email_address
			 , count(*)
		  from xla_accounting_errors xae
		  join fnd_user fu on xae.created_by = fu.user_id
	  group by xae.encoded_msg
			 , to_char(xae.creation_date, 'yyyy-mm-dd')
			 , fu.user_name
			 , fu.email_address;

-- ##################################################################
-- SLA ACCOUNTING ERRORS - COUNT SUMMARY 2
-- ##################################################################

		select substr(xae.encoded_msg,0,100)
			 , count(*)
		  from xla_accounting_errors xae
		  join fnd_application_tl fat on xae.application_id = fat.application_id and fat.language = userenv('lang')
		 where 1 = 1
		   and fat.application_name = 'Projects'
	  group by substr(xae.encoded_msg,0,100);
