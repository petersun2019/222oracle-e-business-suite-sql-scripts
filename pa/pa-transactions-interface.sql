/*
File Name: pa-transactions-interface.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- PA TRANSACTIONS INTERFACE - TABLE DUMPS
-- LINE DETAILS
-- GROUP BY TRANSACTION SOURCE AND REJECTION CODE
-- GROUP BY TRANSACTION SOURCE AND BATCH NAME

*/

-- ###################################################################
-- PA TRANSACTIONS INTERFACE - TABLE DUMPS
-- ###################################################################

select * from pa.pa_transaction_interface_all where batch_name = 'AP-123456';
select * from pa.pa_transaction_interface_all order by creation_date desc;
select * from pa.pa_transaction_interface_all where project_number = 'P123456' order by creation_date desc;

-- ##################################################################
-- LINE DETAILS
-- ##################################################################

		select ptia.project_number project
			 , to_char(ppa.start_date, 'DD-MON-YYYY') start_date
			 , to_char(ppa.completion_date, 'DD-MON-YYYY') completion_date
			 , to_char(ptia.expenditure_item_date, 'DD-MON-YYYY') expenditure_item_date
			 , pt.task_number
			 , to_char(ptia.creation_date, 'DD-MON-YYYY HH24:MI:SS') trx_creation_date
			 , to_char(pt.start_date, 'DD-MON-YYYY') task_start_date
			 , to_char(pt.completion_date, 'DD-MON-YYYY') task_completion_date 
			 , pet.expenditure_category
			 , ptia.creation_date
			 , ptia.transaction_source
			 , ptia.transaction_rejection_code
			 , ptia.raw_cost
			 , ptia.task_number
			 , ptia.expenditure_type exp_type
			 , ptia.transaction_status_code status
			 , ptia.expenditure_id exp_id
			 , ptia.orig_transaction_reference
			 , fu.user_name
			 , '#########################################'
			 , ptia.*
		  from pa.pa_transaction_interface_all ptia
		  join pa.pa_expenditure_types pet on ptia.expenditure_type = pet.expenditure_type
		  join applsys.fnd_user fu on ptia.created_by = fu.user_id
		  join applsys.fnd_new_messages fnm on ptia.transaction_rejection_code = fnm.message_name
		  join pa.pa_projects_all ppa on ptia.project_number = ppa.segment1
		  join pa.pa_tasks pt on ppa.project_id = pt.project_id and ptia.task_number = pt.task_number
		 where 1 = 1
		   -- and ptia.expenditure_id = 123456
		   -- and ptia.creation_date > '01-JUN-2016'
		   -- and fu.user_name = 'CHEESE_USER'
		   -- and ptia.batch_name = 'Cheese Reductions'
		   -- and ptia.orig_transaction_reference = 'Cheese - REV'
		   and ptia.project_number in ('P123456')
		   -- and ptia.transaction_status_code <> 'W'
		   and 1 = 1;

-- ##################################################################
-- GROUP BY TRANSACTION SOURCE AND REJECTION CODE
-- ##################################################################

		select ptia.transaction_source
			 , ptia.transaction_rejection_code
			 , count (*) count
			 , sum(ptia.acct_raw_cost) total
			 , max(ptia.creation_date) latest_tx
			 , max(ptia.creation_date) latest_creation_date
			 , max(ptia.expenditure_item_date) latest_item_date
		  from pa.pa_transaction_interface_all ptia
	 -- left join applsys.fnd_new_messages fnm on ptia.transaction_rejection_code = fnm.message_name
		 where 1 = 1
		   -- and ptia.transaction_status_code <> 'W'
		   -- and ptia.creation_date > '01-SEP-2022'
		   and ptia.batch_name = 'Cheese Reductions'
	  group by ptia.transaction_source
			 , ptia.transaction_rejection_code;

-- ##################################################################
-- GROUP BY TRANSACTION SOURCE AND BATCH NAME
-- ##################################################################

		select ptia.transaction_source
			 , ptia.batch_name
			 , count (*) count
			 , sum(ptia.acct_raw_cost) total
			 , sum(length(ptia.expenditure_comment)) comment_length
			 , max(ptia.creation_date) latest_creation_date
			 , max(ptia.expenditure_item_date) latest_item_date
		  from pa.pa_transaction_interface_all ptia
	 left join applsys.fnd_new_messages fnm on ptia.transaction_rejection_code = fnm.message_name
		 where 1 = 1
		   -- and ptia.transaction_status_code <> 'W'
		   -- and ptia.transaction_source = 'Project Journals'
		   and ptia.batch_name = 'Cheese Reductions'
	  group by ptia.transaction_source
			 , ptia.batch_name;
