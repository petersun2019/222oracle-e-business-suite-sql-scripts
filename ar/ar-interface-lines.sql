/*
File Name: ar-interface-lines.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- INTERFACE LINES SUMMARY
-- INTERFACE LINES DETAILS
-- TABLE DUMPS

*/

-- ##################################################################
-- INTERFACE LINES SUMMARY
-- ##################################################################

		select rila.batch_source_name batch
			 , rila.org_id
			 , count(*) lines
			 , sum(rila.unit_selling_price * rila.quantity) total
		  from ar.ra_interface_lines_all rila
	 left join ar.ar_receipt_methods arm on rila.receipt_method_id = arm.receipt_method_id
		  join apps.hz_cust_accounts hca on rila.orig_system_bill_customer_id = hca.cust_account_id
		  join apps.hz_parties hp on hp.party_id = hca.party_id
	 left join ar.ra_interface_errors_all riea on rila.interface_line_id = riea.interface_line_id
		 where 1 = 1
	  group by rila.batch_source_name
			 , rila.org_id;

		select cust_trx_type_name
			 , count(*)
		  from ra_interface_lines_all
	  group by cust_trx_type_name
	  order by cust_trx_type_name;

-- ##################################################################
-- INTERFACE LINES DETAILS
-- ##################################################################

		select rila.interface_line_id int_line_id
			 , rila.batch_source_name batch_source
			 , rila.interface_line_context
			 , rila.created_by
			 , rila.creation_date
			 , fu.user_name created_by
			 , rila.last_update_date
			 , hca.account_number act_no
			 , hca.cust_account_id cust_id
			 , hp.party_number party_no
			 , hp.party_name
			 , rila.trx_number
			 , to_char(rila.trx_date, 'DD-MM-YYYY') trx_date
			 , rila.org_id
			 , rila.amount
			 , rila.line_number
			 , rila.quantity
			 , rila.unit_selling_price 
			 , rila.memo_line_name
			 , rila.description
			 -- , rila.*
			 -- , '---> ERRORS'
			 -- , riea.interface_line_id
			 -- , riea.message_text
			 -- , riea.invalid_value
		  from ar.ra_interface_lines_all rila
	 left join ar.ar_receipt_methods arm on rila.receipt_method_id = arm.receipt_method_id
		  join apps.hz_cust_accounts hca on rila.orig_system_bill_customer_id = hca.cust_account_id
		  join apps.hz_parties hp on hp.party_id = hca.party_id
	 --- left join ar.ra_interface_errors_all riea on rila.interface_line_id = riea.interface_line_id
	 left join applsys.fnd_user fu on rila.created_by = fu.user_id
		 where 1 = 1
		   -- and rila.creation_date > '01-MAR-2015'
		   -- and rila.interface_line_id in (123456)
		   -- and rila.amount between 11000 and 13000
		   -- and rila.interface_line_attribute4 = ' 00005'
		   -- and rila.orig_system_bill_customer_id = 123456
		   and rila.batch_source_name = 'PROJECTS INVOICES'
		   -- and hca.cust_account_id in 123456) 
		   and 1 = 1;

-- ##################################################################
-- TABLE DUMPS
-- ##################################################################

select * from ar.ra_interface_lines_all rila;
select * from ar.ra_interface_distributions_all;
select * from ar.ra_interface_errors_all;
