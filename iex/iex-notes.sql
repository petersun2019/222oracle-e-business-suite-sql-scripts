/*
File Name:		iex-notes.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- BASIC NOTES INFO
-- NOTES CONTEXTS
-- NOTES, PARTIES, ACCOUNTS, TRANSACTIONS, PAYMENT SCHEDULES

Notes are held at different levels.
They can be added at promise, transaction, party and account levels
When in collections, if you view a transaction, right-click it and view notes, you can only see the notes linked to that transaction
But if you click the notes tab in collections (next to the transactions tab) you see all notes.
Same if you click in the header in the collections form you can click on the view notes yellow icon in the toolbar to see that same thing as you see in the notes tab 
*/

-- ##################################################################
-- BASIC NOTES INFO
-- ##################################################################

		select jnt.jtf_note_id
			 , jnb.source_object_id
			 , jnb.source_object_code
			 , jnb.note_status
			 , jnb.note_type
			 , jnt.creation_date cr_date
			 , (replace(replace(notes,chr(10),' '),chr(13),' ')) notes
			 , fu.description cr_by
			 , case when jnb.source_object_code = 'IEX_INVOICES' then (select rcta.trx_number from ar.ra_customer_trx_all rcta join ar.ar_payment_schedules_all apsa on apsa.customer_trx_id = rcta.customer_trx_id and apsa.payment_schedule_id = jnb.source_object_id) end trx_from_payment_schedule
			 , case when jnb.source_object_code = 'IEX_PROMISE' then (select rcta.trx_number from iex.iex_promise_details ipd join iex.iex_delinquencies_all ida on ipd.delinquency_id = ida.delinquency_id join ar.ra_customer_trx_all rcta on ida.transaction_id = rcta.customer_trx_id and ipd.promise_detail_id = jnb.source_object_id) end trx_from_promise 
			 , case when jnb.source_object_code = 'PARTY' then (select party_number || ': ' || party_name from ar.hz_parties where party_id = jnb.source_object_id) end party_number
			 , case when jnb.source_object_code = 'IEX_ACCOUNT' then (select account_number || ': ' || account_name from ar.hz_cust_accounts where cust_account_id = jnb.source_object_id) end account_number
		  from jtf.jtf_notes_tl jnt 
		  join jtf.jtf_notes_b jnb on jnt.jtf_note_id = jnb.jtf_note_id
		  join applsys.fnd_user fu on jnt.created_by = fu.user_id
		 where 1 = 1
		   and (replace(replace(notes,chr(10),' '),chr(13),' ')) like '%CHEESE%'
		   and 1 = 1;

-- ##################################################################
-- NOTES CONTEXTS
-- ##################################################################

		select jnt.jtf_note_id
			 , jnb.source_object_id
			 , jnb.source_object_code
			 , jnb.note_status
			 , jnb.note_type
			 , jnt.creation_date cr_date
			 , substr(jnt.notes, 0, 100) notes
			 , fu.description cr_by
			 , jnc.note_context_type
		  from jtf.jtf_notes_tl jnt 
		  join jtf.jtf_notes_b jnb on jnt.jtf_note_id = jnb.jtf_note_id
		  join jtf.jtf_note_contexts jnc on jnt.jtf_note_id = jnc.jtf_note_id
		  join applsys.fnd_user fu on jnt.created_by = fu.user_id
		 where 1 = 1
		   and (replace(replace(notes,chr(10),' '),chr(13),' ')) like '%CHEESE%'
		   and 1 = 1;

-- ##################################################################
-- NOTES, PARTIES, ACCOUNTS, TRANSACTIONS, PAYMENT SCHEDULES
-- ##################################################################

with tbl_notes as
	   (select jnt.jtf_note_id
			 , jnb.source_object_id
			 , jnb.source_object_code
			 , jnb.note_status
			 , jnb.note_type
			 , jnt.creation_date cr_date
			 , jnt.notes
			 , fu.description cr_by
		  from jtf.jtf_notes_tl jnt
		  join jtf.jtf_notes_b jnb on jnt.jtf_note_id = jnb.jtf_note_id
		  join applsys.fnd_user fu on jnt.created_by = fu.user_id)
		select tbl_notes.*
			 , hp.party_number
			 , hp.party_name
			 , hca.account_number
			 , hca.account_name
			 , rcta.trx_number
			 , apsa.payment_schedule_id 
			 , apsa.due_date 
			 , apsa.amount_due_original 
			 , apsa.amount_due_remaining 
			 , apsa.amount_applied 
			 , apsa.amount_credited 
			 , apsa.customer_id 
		  from tbl_notes
	 left join ar.hz_parties hp on hp.party_id = tbl_notes.source_object_id and tbl_notes.source_object_code = 'PARTY'
	 left join ar.hz_cust_accounts hca on hca.cust_account_id = tbl_notes.source_object_id and tbl_notes.source_object_code = 'IEX_ACCOUNT'
	 left join ar.ra_customer_trx_all rcta join ar.ar_payment_schedules_all apsa on apsa.customer_trx_id = rcta.customer_trx_id and apsa.payment_schedule_id = jnb.source_object_id and tbl_notes.source_object_code = 'IEX_INVOICES'
	 left join ar.ar_payment_schedules_all apsa on apsa.payment_schedule_id = tbl_notes.source_object_id and tbl_notes.source_object_code = 'IEX_INVOICES'
