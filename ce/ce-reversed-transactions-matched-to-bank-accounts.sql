/*
File Name: ce-reversed-transactions-matched-to-bank-accounts.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- CASH MANAGEMENT STATEMENTS - DETAILS
-- ###################################################################

		select acra.receipt_number
			 , acra.cash_receipt_id
			 , acra.currency_code curr
			 , acra.amount
			 , acra.type
			 , to_char(acra.receipt_date, 'DD-MON-YYYY') receipt_date
			 , to_char(acrha.trx_date, 'DD-MON-YYYY') trx_date
			 , to_char(acrha.gl_date, 'DD-MON-YYYY') gl_date
			 , acra.creation_date receipt_created
			 , fu1.user_name receipt_created_by
			 , acrha.creation_date application_created
			 , fu1.user_name application_created_by
			 , csh.statement_header_id
			 , csh.statement_number
			 , csh.creation_date statement_created
			 , fu3.user_name statement_created_by
			 , to_char(csh.statement_date, 'DD-MON-YYYY') statement_date
			 , csl.status statement_line_status
			 , csl.bank_trx_number
			 , csl.statement_line_id
			 , csl.line_number
			 , csh.bank_account_id
			 , csra.statement_line_id reconciled
			 , cba.bank_account_name
			 , cba.bank_account_num
			 , acrha.status receipt_history_status
			 , acrha.cash_receipt_history_id
			 , csra.statement_line_id
			 , csra.reference_type
			 , csra.creation_date reconciliation_creation_date
		  from ar_cash_receipt_history_all acrha
		  -- join ce_statement_reconcils_all csra on acrha.cash_receipt_history_id = csra.reference_id
		  join ar_cash_receipts_all acra on acrha.cash_receipt_id = acra.cash_receipt_id
		  join fnd_user fu1 on acra.created_by = fu1.user_id
		  join fnd_user fu2 on acrha.created_by = fu2.user_id
		  join ce_statement_reconcils_all csra on acrha.cash_receipt_history_id = csra.reference_id
		  join ce_statement_lines csl on csra.statement_line_id = csl.statement_line_id
		  join ce_statement_headers csh on csh.statement_header_id = csl.statement_header_id
		  join ce_bank_accounts cba on cba.bank_account_id = csh.bank_account_id
		  join fnd_user fu3 on csh.created_by = fu3.user_id
	 -- left join ce_statement_reconcils_all csra on acrha.cash_receipt_history_id = csra.reference_id
		 where 1 = 1
		   and acrha.status = 'REVERSED'
		   and acrha.current_record_flag = 'Y'
		   -- and acrha.cash_receipt_history_id in (select csra.reference_id from ce_statement_reconcils_all csra)
		   -- and acrha.cash_receipt_history_id = 123456
		   -- and acra.cash_receipt_id = 123456
		   and 1 = 1;
