/*
File Name: ar-trx-bal-summary.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- AR TRANSACTIONS - BALANCE SUMMARY 1
-- AR TRANSACTIONS - BALANCE SUMMARY 2

*/

-- ##################################################################
-- AR TRANSACTIONS - BALANCE SUMMARY 1
-- ##################################################################

		select hca.account_number
			 , hp.party_name
			 , atbs.best_current_receivables
			 , atbs.total_dso_days_credit
			 , atbs.op_invoices_value
			 , atbs.op_invoices_count
			 , atbs.op_debit_memos_value
			 , atbs.op_debit_memos_count
			 , atbs.op_deposits_value
			 , atbs.op_deposits_count
			 , atbs.op_bills_receivables_value
			 , atbs.op_bills_receivables_count
			 , atbs.op_chargeback_value
			 , atbs.op_chargeback_count
			 , atbs.op_credit_memos_value
			 , atbs.op_credit_memos_count
			 , atbs.unresolved_cash_value
			 , atbs.unresolved_cash_count
			 , atbs.receipts_at_risk_value
			 , atbs.inv_amt_in_dispute
			 , atbs.disputed_inv_count
			 , atbs.pending_adj_value
			 , atbs.last_dunning_date
			 , atbs.dunning_count
			 , atbs.past_due_inv_value
			 , atbs.past_due_inv_inst_count
			 , atbs.last_payment_amount
			 , atbs.last_payment_date
			 , atbs.last_payment_number
			 , atbs.reference_1
			 , atbs.reference_2
			 , atbs.reference_3
			 , atbs.reference_4
			 , atbs.reference_5
		  from ar.hz_cust_accounts hca
		  join ar.hz_parties hp on hca.party_id = hp.party_id
		  join ar.hz_party_sites hps on hp.party_id = hps.party_id
		  join ar.hz_cust_acct_sites_all hcasa on hcasa.party_site_id = hps.party_site_id and hca.cust_account_id = hcasa.cust_account_id
		  join ar.hz_cust_site_uses_all hcsua on hcsua.cust_acct_site_id = hcasa.cust_acct_site_id
		  join ar.ar_trx_bal_summary atbs on hcsua.site_use_id = atbs.site_use_id
		 where atbs.site_use_id = 123456;

-- ##################################################################
-- AR TRANSACTIONS - BALANCE SUMMARY 2
-- ##################################################################

		select cust_account_id
			 , site_use_id
			 , org_id
			 , currency
			 , last_update_date
			 , creation_date
			 , best_current_receivables
			 , total_dso_days_credit
			 , op_invoices_value
			 , op_invoices_count
			 , op_debit_memos_value
			 , op_debit_memos_count
			 , op_deposits_value
			 , op_deposits_count
			 , op_bills_receivables_value
			 , op_bills_receivables_count
			 , op_chargeback_value
			 , op_chargeback_count
			 , op_credit_memos_value
			 , op_credit_memos_count
			 , unresolved_cash_value
			 , unresolved_cash_count
			 , receipts_at_risk_value
			 , inv_amt_in_dispute
			 , disputed_inv_count
			 , pending_adj_value
			 , last_dunning_date
			 , dunning_count
			 , past_due_inv_value
			 , past_due_inv_inst_count
			 , last_payment_amount
			 , last_payment_date
			 , last_payment_number
			 , reference_1
		  from ar.ar_trx_bal_summary
		 where site_use_id = 123456;
