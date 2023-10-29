/*
File Name: ap-trial-balance.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- AP TRIAL BALANCES 1
-- AP TRIAL BALANCES 2
-- AP TRIAL BALANCE
-- TABLE DUMP

*/

-- ##################################################################
-- AP TRIAL BALANCES 1
-- INVOICE TABLE FIRST - RETURN RECORDS EVEN IF NO DATA IN XLA_TRANSACTION_ENTITIES TABLE
-- ##################################################################

		select aia.invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , tb.entity_id
			 , aps.segment1 supplier#
			 , aps.vendor_name supplier
			 , aia.invoice_amount inv_amt
			 , tb.diff amt_remain
			 , gcc.concatenated_segments account
			 , aia.invoice_type_lookup_code inv_type
			 , to_char(aia.invoice_date, 'DD-MON-YYYY') invoice_date
			 , to_char(aia.cancelled_date, 'DD-MON-YYYY HH24:MI:SS') cancelled_date
			 , aia.last_update_date
			 , fu.user_name updated_by
			 , ap.name term
			 , xte.source_id_int_1
			 , tb.diff
		  from ap_invoices_all aia
	 left join xla.xla_transaction_entities xte on xte.source_id_int_1 = aia.invoice_id
	 left join (select tb.code_combination_id
					 , nvl(tb.applied_to_entity_id, tb.source_entity_id) entity_id
					 , party_id
					 , sum(nvl(tb.acctd_rounded_cr, 0))
					 , sum(nvl(tb.acctd_rounded_dr, 0))
					 , sum(nvl(tb.acctd_rounded_cr, 0)) - sum (nvl (tb.acctd_rounded_dr, 0)) diff
				  from xla_trial_balances tb
				 where tb.definition_code = 'AP_200_1'
			  group by tb.code_combination_id
					 , nvl(tb.applied_to_entity_id, tb.source_entity_id)
					 , tb.party_id
				having sum (nvl (tb.acctd_rounded_cr, 0)) <> sum (nvl (tb.acctd_rounded_dr, 0))) tb on tb.entity_id = xte.entity_id
		  join ap_suppliers aps on aia.vendor_id = aps.vendor_id
	 left join gl_code_combinations_kfv gcc on tb.code_combination_id = gcc.code_combination_id
		  join ap_terms ap on ap.term_id = aia.terms_id
		  join fnd_user fu on aia.last_updated_by = fu.user_id
		 where 1 = 1
		   and xte.application_id = 200
		   and aia.invoice_id in (123456)
		   and xte.entity_code = 'AP_INVOICES'
		   and 1 = 1;

-- ##################################################################
-- AP TRIAL BALANCES 2
-- HTTPS://SHARINGORACLE.BLOGSPOT.COM/2017/11/AP-TRAIL-BALANCES-SQL-QUERY-FOR-R12.HTML
-- RECORDS NOT RETURNED IF NOT TB DATA FOR INVOICE
-- ##################################################################
-- AP TRIAL BALANCE

		select aia.invoice_id
			 , aia.invoice_num
			 , tb.entity_id
			 , aps.segment1 supplier#
			 , aps.vendor_name supplier
			 , aia.invoice_amount inv_amt
			 , tb.diff amt_remain
			 , gcc.concatenated_segments account
			 , aia.invoice_type_lookup_code inv_type
			 , to_char(aia.invoice_date, 'DD-MON-YYYY') invoice_date
			 , to_char(aia.cancelled_date, 'DD-MON-YYYY HH24:MI:SS') cancelled_date
			 , aia.last_update_date
			 , fu.user_name updated_by
			 , ap.name term
		  from xla.xla_transaction_entities xte
	 left join (select tb.code_combination_id
					 , nvl(tb.applied_to_entity_id, tb.source_entity_id) entity_id
					 , party_id
					 , sum(nvl(tb.acctd_rounded_cr, 0))
					 , sum(nvl(tb.acctd_rounded_dr, 0))
					 , sum(nvl(tb.acctd_rounded_cr, 0)) - sum (nvl (tb.acctd_rounded_dr, 0)) diff
				  from xla_trial_balances tb
				 where tb.definition_code = 'AP_200_1'
			  group by tb.code_combination_id
					 , nvl(tb.applied_to_entity_id, tb.source_entity_id)
					 , tb.party_id
				having sum (nvl (tb.acctd_rounded_cr, 0)) <> sum (nvl (tb.acctd_rounded_dr, 0))) tb on tb.entity_id = xte.entity_id
		  join ap_invoices_all aia on xte.source_id_int_1 = aia.invoice_id
		  join ap_suppliers aps on aia.vendor_id = aps.vendor_id
		  join gl_code_combinations_kfv gcc on tb.code_combination_id = gcc.code_combination_id
		  join ap_terms ap on ap.term_id = aia.terms_id
		  join fnd_user fu on aia.last_updated_by = fu.user_id
		 where 1 = 1
		   and xte.application_id = 200
		   and aia.invoice_id in (123456)
		   and xte.entity_code = 'AP_INVOICES'
		   and 1 = 1;

-- ##################################################################
-- TABLE DUMPS
-- ##################################################################

		select * 
		  from ap_liability_balance
		 where invoice_id in (123456)
		   and set_of_books_id = 1
		   and 1 = 1;

		select * from xla_trial_balances
		 where source_entity_id in (123456)
		   and source_application_id = 200
		   and ledger_id = 1;

		select * 
		  from xla_trial_balances
		 where 1 = 1
		   and source_application_id = 200
		   and 1 = 1;
