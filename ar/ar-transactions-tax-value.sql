/*
File Name: ar-transactions-tax-value.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- TRANSACTIONS WITH TAX VALUE - VERSION 1
-- TRANSACTIONS WITH TAX VALUE - VERSION 2

*/

-- ##################################################################
-- TRANSACTIONS WITH TAX VALUE - VERSION 1
-- ##################################################################

		select rcta.customer_trx_id
			 , rcta.trx_number
			 , rcta.creation_date
			 , rctta.name transaction_type
			 , hca.account_number
			 , hp.party_number
			 , hp.party_name
			 , hp.party_type
			 , rctla.line_type
			 , rbsa.name source
			 , fu.user_name
			 , sum(rctla.unit_selling_price) calc1
			 , (select sum(extended_amount) from ar.ra_customer_trx_lines_all tx_info where rcta.customer_trx_id = tx_info.customer_trx_id and line_type = 'TAX') tax_value
		  from ar.ra_customer_trx_all rcta
			 , ar.ra_cust_trx_types_all rctta
			 , ar.hz_cust_accounts hca
			 , ar.hz_parties hp
			 , ar.ra_customer_trx_lines_all rctla
			 , ar.ra_batch_sources_all rbsa
			 , applsys.fnd_user fu
		 where rcta.bill_to_customer_id = hca.cust_account_id
		   and hp.party_id = hca.party_id
		   and rcta.cust_trx_type_id = rctta.cust_trx_type_id
		   and rcta.customer_trx_id = rctla.customer_trx_id
		   and rcta.batch_source_id = rbsa.batch_source_id and rcta.org_id = rbsa.org_id
		   and rcta.created_by = fu.user_id
		   -- and rcta.trx_number = '123456'
		   and rcta.creation_date between '27-JUN-2021' and '30-JUN-2021'
		   -- and rcta.creation_date > '01-JUL-2017'
		   -- and hp.party_type = 'PERSON'
	  group by rcta.customer_trx_id
			 , rcta.trx_number
			 , rcta.creation_date
			 , rctta.name
			 , hca.account_number
			 , hp.party_number
			 , hp.party_name
			 , hp.party_type
			 , rctla.line_type
			 , rbsa.name
			 , fu.user_name
	  order by rcta.creation_date;

-- ##################################################################
-- TRANSACTIONS WITH TAX VALUE - VERSION 2
-- ##################################################################

with my_data as
(select rcta.customer_trx_id
			 , rcta.trx_number
			 , rcta.creation_date
			 , rctta.name transaction_type
			 , hca.account_number
			 , hp.party_number
			 , hp.party_name
			 , hp.party_type
			 , rctla.line_type
			 , rbsa.name source
			 , fu.user_name
			 , nvl(rctla.unit_selling_price, rctla.extended_amount) amt
		  from ar.ra_customer_trx_all rcta
			 , ar.ra_cust_trx_types_all rctta
			 , ar.hz_cust_accounts hca
			 , ar.hz_parties hp
			 , ar.ra_customer_trx_lines_all rctla
			 , ar.ra_batch_sources_all rbsa
			 , applsys.fnd_user fu
		 where rcta.bill_to_customer_id = hca.cust_account_id
		   and hp.party_id = hca.party_id
		   and rcta.cust_trx_type_id = rctta.cust_trx_type_id
		   and rcta.customer_trx_id = rctla.customer_trx_id
		   and rcta.batch_source_id = rbsa.batch_source_id and rcta.org_id = rbsa.org_id
		   and rcta.created_by = fu.user_id
		   and rcta.trx_number = '123456'
		   -- and rctla.inventory_item_id = 123456
		   -- and rcta.creation_date between '27-JUN-2017' and '30-JUN-2017'
		   -- and rcta.creation_date > '01-JUN-2017'
		   -- and hp.party_name != 'Cheese'
		   -- and hp.party_type = 'PERSON'
		   -- and rbsa.name = 'Invoices'
		   and 1 = 1)
		select customer_trx_id
			 , trx_number
			 , source
			 , creation_date
			 , user_name created_bby
			 , transaction_type
			 , account_number
			 , party_number
			 , party_name
			 , party_type
			 , sum(case when line_type = 'LINE' then amt end) trx_total
			 , sum(case when line_type = 'TAX' then amt end ) tax_total
		  from my_data
	  group by customer_trx_id
			 , trx_number
			 , source
			 , creation_date
			 , user_name
			 , transaction_type
			 , account_number
			 , party_number
			 , party_name
			 , party_type
	  order by creation_date
			 , trx_number;
