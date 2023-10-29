/*
File Name:		iex-tasks.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- TASKS
-- TASKS - SUMMARY
-- TASKS LINKED TO AR TRANSACTION NUMBERS

*/

-- ###################################################################
-- TASKS
-- ###################################################################

		select tasks.task_number
			 , tasks.task_name
			 , substr(tasks.description, 0, 30) descr
			 , tasks.creation_date
			 , tasks.task_type
			 , tasks.task_status
			 , tasks.owner
			 , tasks.cust_account_id
			 , tasks.last_update_date
			 , hca.account_number
			 , hca.account_name
			 , tasks.cust_account_id
			 , fu.description assigned_by
			 , ipd.creation_date
			 , ipd.promise_date
			 , ipd.promise_amount
			 , ipd.amount_due_remaining
			 , ipd.status
			 , ipd.broken_on_date
			 , ipd.state
			 , ac.name collector
		  from iex.iex_promise_details ipd
	right join ar.ar_collectors ac on ipd.resource_id = ac.resource_id
	right join apps.iex_tasks_main_v tasks on tasks.source_object_id = ipd.promise_detail_id
	 left join ar.hz_cust_accounts hca on tasks.cust_account_id = hca.cust_account_id
	 left join ar.hz_parties hp on hca.party_id = hp.party_id
	 left join applsys.fnd_user fu on tasks.assigned_by_name = fu.user_name
		 where 1 = 1
		   -- and tasks.owner = 'Bunny, Bugs'
		   and tasks.task_status in ('Open', 'Working')
		   -- and tasks.task_number in ('123456')
		   -- and hp.party_type = 'ORGANIZATION'
		   and 1 = 1;

-- ###################################################################
-- TASKS - SUMMARY
-- ###################################################################

		select ac.name collector
			 , count(*) ct
		  from iex.iex_promise_details ipd
	right join ar.ar_collectors ac on ipd.resource_id = ac.resource_id
	right join apps.iex_tasks_main_v tasks on tasks.source_object_id = ipd.promise_detail_id
	 left join ar.hz_cust_accounts hca on tasks.cust_account_id = hca.cust_account_id
	 left join applsys.fnd_user fu on tasks.assigned_by_name = fu.user_name
		 where 1 = 1
		   and tasks.task_status in ('Open', 'Working')
		   and 1 = 1
	  group by ac.name;

-- ###################################################################
-- TASKS LINKED TO AR TRANSACTION NUMBERS
-- ###################################################################

		select tasks.task_number
			 , tasks.task_name
			 , substr(tasks.description, 0, 30) descr
			 , tasks.task_type
			 , tasks.task_status
			 , tasks.owner
			 , hca.account_number
			 , hca.account_name
			 , fu.description assigned_by
			 , ipd.creation_date
			 , ipd.promise_date
			 , ipd.promise_amount
			 , ipd.amount_due_remaining
			 , ipd.status
			 , ipd.broken_on_date
			 , ipd.state
			 , ac.name collector
			 , psa.customer_trx_id customer_trx_id
			 , psa.trx_number trx_number
			 , psa.trx_date trx_date
			 , psa.terms_sequence_number terms_sequence_number
			 , psa.due_date due_date
		  from iex.iex_promise_details ipd
		  join iex.iex_delinquencies_all ida on ipd.delinquency_id = ida.delinquency_id
		  join ar.ar_collectors ac on ipd.resource_id = ac.resource_id
		  join ar.ar_payment_schedules_all psa on ida.payment_schedule_id = psa.payment_schedule_id
		  join apps.iex_tasks_main_v tasks on tasks.source_object_id = ipd.promise_detail_id
		  join ar.hz_cust_accounts hca on tasks.cust_account_id = hca.cust_account_id
	 left join applsys.fnd_user fu on tasks.assigned_by_name = fu.user_name
		 where 1 = 1
		   -- and tasks.owner = 'Bunny, Bugs'
		   -- and tasks.task_status in ('Open', 'Working')
		   -- and psa.trx_number = '123456'
		   and ipd.status = 'FULFILLED'
		   -- and tasks.task_number = 123456
		   and 1 = 1;
