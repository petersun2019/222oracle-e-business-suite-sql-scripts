/*
File Name: ce-reversed-transactions-matched-to-bank-accounts.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- CASH MANAGEMENT STATEMENTS - DETAILS
-- CASH MANAGEMENT STATEMENTS - SUMMARY
-- CASH MANAGEMENT INTERFACE
-- CASH MANAGEMENT INTERFACE ERRORS
-- RECONCILIATIONS
-- STATEMENT MAPPING

*/

-- ##################################################################
-- CASH MANAGEMENT STATEMENTS - DETAILS
-- ##################################################################

		select csh.statement_header_id
			 , csh.statement_number
			 , to_char(csh.statement_date, 'DD-MON-YYYY') statement_date
			 , csl.status
			 , csl.bank_trx_number
			 , csra.request_id
			 , csra.auto_reconciled_flag
			 , csl.statement_line_id
			 , csl.line_number
			 , to_char(csl.trx_date, 'DD-MON-YYYY') trx_date
			 , csl.trx_type
			 , csl.trx_code
			 , csl.amount
			 , csh.bank_account_id
			 , csra.statement_line_id reconciled
			 , cba.bank_account_name
			 , cba.bank_account_num
			 , '###################'
			 , csl.*
		  from ce.ce_statement_headers csh
		  join ce.ce_statement_lines csl on csh.statement_header_id = csl.statement_header_id
	 left join ce.ce_statement_reconcils_all csra on csra.statement_line_id = csl.statement_line_id
	 left join ce_bank_accounts cba on cba.bank_account_id = csh.bank_account_id
		 where 1 = 1
		   -- and csh.creation_date > '02-MAY-2018'
		   -- and csh.creation_date < '03-MAY-2018'
		   -- and csl.bank_trx_number = '123456'
		   -- and csl.statement_line_id = 123456
		   -- and csl.status = 'RECONCILED'
		   -- and csl.trx_type = 'CREDIT'
		   -- and csh.statement_number = '123456'
		   -- and csl.trx_code = 'TRFD'
		   -- and csl.trx_date = '24-SEP-2017'
		   and abs(csl.amount) = 1471.04
		   -- and csl.statement_line_id = 123456
		   -- and csl.statement_line_id in (123456)
		   -- and csh.bank_account_id = 1234
	  order by csh.creation_date desc
			 , csl.line_number;


-- ##################################################################
-- CASH MANAGEMENT STATEMENTS - SUMMARY
-- ##################################################################

		select csh.statement_header_id
			 , csh.statement_number
			 , csh.statement_date
			 , csh.creation_date 
			 , cba.bank_account_name
			 , cba.bank_account_num
			 , csl.status
			 , count(*) lines
			 , sum(csl.amount) amt
		  from ce.ce_statement_headers csh
		  join ce.ce_statement_lines csl on csh.statement_header_id = csl.statement_header_id
	 left join ce.ce_statement_reconcils_all csra on csra.statement_line_id = csl.statement_line_id
	 left join ce_bank_accounts cba on cba.bank_account_id = csh.bank_account_id
		 where 1 = 1
		   -- and csl.status = 'UNRECONCILED'
		   and csh.creation_date > '02-MAY-2018'
		   and csh.creation_date < '03-MAY-2018'
		   -- and cba.bank_account_name like 'Test%Bank%'
	  group by csh.statement_header_id
			 , csh.statement_number
			 , csh.statement_date
			 , cba.bank_account_name
			 , cba.bank_account_num
			 , csl.status
			 , csh.creation_date 
	  order by csh.statement_date desc;

-- ##################################################################
-- CASH MANAGEMENT INTERFACE
-- ##################################################################

select * from ce_statement_headers_int where creation_date between '18-FEB-2021' and '20-FEB-2021' order by creation_date desc;
select * from ce_statement_headers_int;
select * from ce_statement_lines_interface where creation_date between '18-FEB-2021' and '20-FEB-2021' order by creation_date desc;

-- ##################################################################
-- CASH MANAGEMENT INTERFACE ERRORS
-- ##################################################################

select * from ce_header_interface_errors where creation_date > '16-FEB-2021' order by creation_date desc;
select * from ce_line_interface_errors where creation_date > '16-JAN-2018' order by creation_date desc;
select * from ce_stmt_int_tmp order by rec_no;

		select to_char(creation_date, 'yyyy-mm-dd')
			 , count(*) ct 
		  from ce_header_interface_errors 
		 where creation_date > '01-JAN-2018' 
	  group by to_char(creation_date, 'yyyy-mm-dd')
	  order by to_char(creation_date, 'yyyy-mm-dd') desc;

-- ##################################################################
-- RECONCILIATIONS
-- ##################################################################

select * from ce_reconciliation_errors;
select * from ce_reconciliation_errors where creation_date between '18-FEB-2021' and '20-FEB-2021' order by creation_date desc;
select * from ce.ce_statement_reconcils_all where statement_line_id = 2984204;

-- ##################################################################
-- STATEMENT MAPPING
-- ##################################################################

-- STORES THE DEFINITIONS OF THE MAPPING TEMPLATES
select * from ce_bank_stmt_int_map;

-- MAPS THE COLUMNS THE BANK STATEMENT HEADERS INTERFACE TABLE (CE_STATEMENT_HEADERS_INT_ALL) TO THE COLUMNS IN THE INTERMEDIATE TABLE (CE_STMT_INT_TMP)
select * from ce_bank_stmt_map_hdr;

-- MAPS THE COLUMNS IN THE BANK STATEMENT LINES INTERFACE TABLE (CE_STATEMENT_LINES_INTERFACE) TO THE COLUMNS IN THE INTERMEDIATE TABLE (CE_STMT_INT_TMP)
select * from ce_bank_stmt_map_line;

-- THIS TABLE STORES PRE-DETERMINED CODES BETWEEN YOU AND YOUR BANK TO IDENTIFY THE TYPES OF TRANSACTIONS FOR MATCHING STATEMENT LINES
select * from ce_transaction_codes;

-- INTERMEDIATE TABLE, WHICH STORES THE INFORMATION LOADED FROM A BANK STATEMENT FILE. THIS TABLE IS POPULATED BY THE SQL*LOADER SCRIPT
select * from ce_stmt_int_tmp;

-- RECORDS THE ERRORS ENCOUNTERED BY THE BANK STATEMENT LOADER PROGRAM WHEN LOADING DATA FROM THE BANK STATEMENT FILE INTO THE INTERMEDIATE TABLE
select * from ce_sqlldr_errors;
