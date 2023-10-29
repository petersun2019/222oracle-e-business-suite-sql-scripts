/*
File Name:		iex-delinquencies.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- DELINQUENCY TABLE ONLY
-- PAYMENT SCHEDULES LINKED TO DELINQUENCIES
-- BASIC DELINQUENCIES WITHOUT XML HISTORY
-- BASIC DELINQUENCIES WITH XML HISTORY
-- DELINQUENCIES WITHOUT A LINK TO PAYMENT SCHEDULE / INSTALLMENT
-- STATUS COUNTS
-- TRANSACTIONS WITH AMOUNT OUTSTANDING AND DELINQUENCY COUNT
-- BASIC XML REQUESTS HISTORY
-- XML REQUESTS HISTORY DETAILS WITH LINK TO DELINQUENCIES
-- XML DATA TABLE DUMPS
-- TRYING STUFF OUT

*/

-- ##################################################################
-- DELINQUENCY TABLE ONLY
-- ##################################################################

		select ida.*
		  from iex.iex_delinquencies_all ida
		 where ida.transaction_id = 123456;

-- ##################################################################
-- PAYMENT SCHEDULES LINKED TO DELINQUENCIES
-- ##################################################################

-- BASIC PAYMENT SCHEDULES ONLY

		select rcta.trx_number 
			 , rcta.customer_trx_id 
			 , rcta.creation_date trx_created 
			 , apsa.payment_schedule_id 
			 , apsa.due_date 
			 , apsa.amount_due_original 
			 , apsa.amount_due_remaining 
			 , apsa.amount_applied 
			 , apsa.amount_credited 
			 , apsa.customer_id 
		  from ar.ra_customer_trx_all rcta 
		  join ar.ar_payment_schedules_all apsa on apsa.customer_trx_id = rcta.customer_trx_id 
		 where 1 = 1 
		   and rcta.trx_number = '123456';

-- PAYMENT SCHEDULES AND DELINQUENCIES

		select ida.delinquency_id 
			 , ida.creation_date del_created 
			 , ida.status del_status 
			 , ida.payment_schedule_id 
			 , rcta.trx_number 
			 , rcta.customer_trx_id 
			 , rcta.creation_date trx_created 
			 , apsa.payment_schedule_id 
			 , apsa.due_date 
			 , apsa.amount_due_original 
			 , apsa.amount_due_remaining 
			 , apsa.amount_applied 
			 , apsa.amount_credited 
			 , apsa.customer_id 
			 , (select count(*) from ar.ar_payment_schedules_all apsa where apsa.customer_trx_id = rcta.customer_trx_id) apsa_ct_all
			 , (select count(*) from ar.ar_payment_schedules_all apsa where apsa.customer_trx_id = rcta.customer_trx_id and apsa.amount_applied is null and apsa.amount_credited is null) apsa_ct_clean
		  from iex.iex_delinquencies_all ida 
	 left join ar.ra_customer_trx_all rcta on ida.transaction_id = rcta.customer_trx_id 
	 left join ar.ar_payment_schedules_all apsa on ida.payment_schedule_id = apsa.payment_schedule_id 
		 where 1 = 1 
		   -- and ida.status = 'DELINQUENT'
		   and rcta.trx_number = '123456'
		   -- and (apsa.amount_applied is null and apsa.amount_credited is null)
		   -- and (select count(*) from ar.ar_payment_schedules_all apsa where apsa.customer_trx_id = rcta.customer_trx_id) = (select count(*) from ar.ar_payment_schedules_all apsa where apsa.customer_trx_id = rcta.customer_trx_id and apsa.amount_applied is null and apsa.amount_credited is null)
		   and 1 = 1 
	  order by ida.creation_date desc;

-- ##################################################################
-- BASIC DELINQUENCIES WITHOUT XML HISTORY
-- ##################################################################

		select ida.delinquency_id
			 , ida.creation_date del_created
			 , ida.last_update_date del_updated
			 , ida.status del_status
			 , ida.payment_schedule_id
			 , hca.account_number
			 , hca.account_name
			 , hp.party_name
			 , rcta.trx_number
			 , rcta.customer_trx_id
			 , rcta.creation_date trx_created
			 , rcta.last_update_date trx_updated
			 , rcta.term_id
			 , apsa.due_date
			 , apsa.amount_due_original
			 , apsa.amount_due_remaining
			 , apsa.status
			 , (select sum(amount_due_remaining) 
		  from ar_payment_schedules_all apsa 
		 where apsa.customer_trx_id = rcta.customer_trx_id 
		   and apsa.amount_due_remaining > 0) balance_due
		  from iex_delinquencies_all ida
		  join ra_customer_trx_all rcta on ida.transaction_id = rcta.customer_trx_id
		  join ar_payment_schedules_all apsa on ida.payment_schedule_id = apsa.payment_schedule_id
		  join hz_cust_accounts hca on ida.cust_account_id = hca.cust_account_id
		  join hz_parties hp on hp.party_id = hca.party_id
		 where 1 = 1
		   and rcta.trx_number in ('123456')
		   -- and ida.status = 'CURRENT'
		   and 1 = 1
	  order by ida.creation_date desc;

-- ##################################################################
-- BASIC DELINQUENCIES WITH XML HISTORY
-- ##################################################################

		select ida.delinquency_id
			 , ida.creation_date del_created
			 , ida.last_update_date del_updated
			 , ida.status del_status
			 , hca.account_number
			 , hca.account_name
			 , rcta.trx_number
			 , rcta.customer_trx_id
			 , rcta.creation_date trx_created
			 , rcta.last_update_date trx_updated
			 , rcta.term_id
			 , ixrh.xml_request_id
			 , ixrh.creation_date xml_cr_date
			 , ixrh.xmldata
			 , dbms_lob.instr(ixrh.xmldata,'PAYMENT_HISTORY_ROW') xml_pay_hist
			 , rtt.name term_trx
			 , rtt.description
			 , rbsa.name batch_source
		  from iex.iex_delinquencies_all ida
		  join ar.hz_cust_accounts hca on ida.cust_account_id = hca.cust_account_id
		  join ar.ra_customer_trx_all rcta on ida.transaction_id = rcta.customer_trx_id
	 left join iex.iex_xml_request_histories ixrh on ixrh.party_id = hca.party_id
		  join ar.ra_terms_tl rtt on rcta.term_id = rtt.term_id
		  join ar.ra_batch_sources_all rbsa on rbsa.batch_source_id = rcta.batch_source_id
		  join ar.ar_payment_schedules_all apsa on ida.payment_schedule_id = apsa.payment_schedule_id
		 where 1 = 1
		   -- and hca.account_name like 'Fil%'
		   -- and ida.delinquency_id = 123456
		   -- and ixrh.creation_date > '01-JUN-2016'
		   -- and dbms_lob.instr(ixrh.xmldata,'PAYMENT_HISTORY_ROW') = 0 -- blank letter
		   and rcta.trx_number in ('123456')
		   -- and ida.status = 'DELINQUENT'
		   -- and hca.account_number = '123456'
		   and 1 = 1
	  order by ida.creation_date desc;

-- ##################################################################
-- DELINQUENCIES WITHOUT A LINK TO PAYMENT SCHEDULE / INSTALLMENT
-- ##################################################################

		select ida.delinquency_id
			 , ida.creation_date del_created
			 , ida.last_update_date del_updated
			 , ida.status del_status
			 , ida.request_id
			 , hca.account_number
			 , hca.account_name
			 , hca.cust_account_id
			 , rcta.trx_number
			 , rcta.customer_trx_id
			 , rcta.creation_date trx_created
			 , rcta.last_update_date trx_updated
			 , rcta.term_id
			 , ixrh.xml_request_id
			 , ixrh.creation_date xml_cr_date
			 , ixrh.resource_id
			 , ixrh.query_temp_id
			 , dbms_lob.instr(ixrh.xmldata,'PAYMENT_HISTORY_ROW') zz
			 , ixrh.xmldata
			 , ixrh.request_id
			 , length(ixrh.xmldata) xmldata_len
			 , rtt.name term_trx
			 , rtt.description
			 , rbsa.name batch_source
			 , (select count(*) from igi.igi_instalment_audit_all iiaa where iiaa.ra_customer_trx_id = rcta.customer_trx_id) inst_count
		  from iex.iex_delinquencies_all ida
		  join ar.hz_cust_accounts hca on ida.cust_account_id = hca.cust_account_id
		  join ar.ra_customer_trx_all rcta on ida.transaction_id = rcta.customer_trx_id
		  join iex.iex_xml_request_histories ixrh on ixrh.party_id = hca.party_id
		  join ar.ra_terms_tl rtt on rcta.term_id = rtt.term_id
		  join ar.ra_batch_sources_all rbsa on rbsa.batch_source_id = rcta.batch_source_id
		 where 1 = 1
		   and ida.payment_schedule_id not in (select apsa.payment_schedule_id from ar.ar_payment_schedules_all apsa where ida.payment_schedule_id = apsa.payment_schedule_id)
		   -- and hca.account_name = 'Daffy Duck'
		   -- and (ixrh.request_id = 123456 or ida.request_id = 123456)
		   -- and ida.delinquency_id = 123456
		   -- and ixrh.creation_date > '13-JUL-2016'
		   -- and dbms_lob.instr(ixrh.xmldata,'PAYMENT_HISTORY_ROW') = 0 -- blank letter
		   -- and hca.account_name like 'Cheese%'
		   -- and rcta.trx_number in ('123456')
		   -- and ida.status = 'DELINQUENT'
		   -- and hca.account_number = '123456'
		   and 1 = 1
	  order by ixrh.creation_date desc;

-- ##################################################################
-- STATUS COUNTS
-- ##################################################################

		select ida.status
			 , count(*) ct
		  from iex.iex_delinquencies_all ida
	  group by ida.status; 

-- ##################################################################
-- TRANSACTIONS WITH AMOUNT OUTSTANDING AND DELINQUENCY COUNT
-- ##################################################################

		select rcta.trx_number
			 , rcta.customer_trx_id trx_id
			 , (select count(*) from iex.iex_delinquencies_all ida where ida.payment_schedule_id = apsa.payment_schedule_id) ida_count
			 , (select sum(amount_due_remaining) from ar.ar_payment_schedules_all apsa where apsa.customer_trx_id = rcta.customer_trx_id and apsa.amount_due_remaining > 0) balance_due
		  from ar.ra_customer_trx_all rcta
		  join ar.ar_payment_schedules_all apsa on rcta.customer_trx_id = apsa.customer_trx_id
		 where 1 = 1
		   -- and rcta.trx_number in ('123456')
		   and rcta.creation_date between '01-JAN-2016' and '01-FEB-2016'
		   and 1 = 1
	  order by rcta.customer_trx_id;

		select rcta.trx_number
			 , rcta.customer_trx_id
			 , rcta.creation_date trx_created
			 , rcta.last_update_date trx_updated
			 , rcta.term_id
			 , rbsa.name source
			 , apsa.payment_schedule_id
			 , apsa.due_date
			 , round(sysdate - apsa.due_date, 0) days_late
			 , apsa.amount_due_original
			 , apsa.amount_due_remaining
			 , apsa.status
			 , apsa.program_application_id
			 , case when apsa.in_collection is null then 'not_in_collection' else 'in_collection' end collection_flag
			 , (select sum(amount_due_remaining) from ar.ar_payment_schedules_all apsa where apsa.customer_trx_id = rcta.customer_trx_id and apsa.amount_due_remaining > 0) balance_due
			 , (select count(*) from iex.iex_delinquencies_all ida where ida.transaction_id = rcta.customer_trx_id and ida.payment_schedule_id = apsa.payment_schedule_id and ida.status = 'DELINQUENT') del_ct_del
			 , (select count(*) from iex.iex_delinquencies_all ida where ida.transaction_id = rcta.customer_trx_id and ida.payment_schedule_id = apsa.payment_schedule_id and ida.status = 'CURRENT') del_ct_current
			 -- , '################'
			 -- , apsa.*
		  from ar.ra_customer_trx_all rcta 
		  join ar.ar_payment_schedules_all apsa on rcta.customer_trx_id = apsa.customer_trx_id
	 left join ar.ra_batch_sources_all rbsa on rcta.batch_source_id = rbsa.batch_source_id and rcta.org_id = rbsa.org_id
		 where 1 = 1
		   -- and apsa.status = 'OP'
		   -- and rcta.trx_number in ('123456')
		   and rcta.creation_date between '01-JAN-2016' and '01-FEB-2016' 
		   and (select sum(amount_due_remaining) from ar.ar_payment_schedules_all apsa where apsa.customer_trx_id = rcta.customer_trx_id and apsa.amount_due_remaining > 0) > 0
	  order by rcta.creation_date desc;

-- ##################################################################
-- BASIC XML REQUESTS HISTORY
-- ##################################################################

		select ixrh.xml_request_id
			 , ixrh.creation_date xml_cr_date
			 , ixrh.xmldata
			 , ixrh.method
			 , ixrh.document_type
			 , ixrh.destination
			 , ixrh.failure_reason
		  from iex.iex_xml_request_histories ixrh
		 where 1 = 1
		   and ixrh.creation_date > '01-JUN-2016'
		   -- and ixrh.method = 'EMAIL'
		   and 1 = 1;

-- ##################################################################
-- XML REQUESTS HISTORY DETAILS WITH LINK TO DELINQUENCIES
-- ##################################################################

		select ida.delinquency_id
			 , ida.creation_date del_created
			 , ida.last_update_date del_updated
			 , ida.status del_status
			 , hca.account_number
			 , hca.account_name
			 , rcta.trx_number
			 , rcta.customer_trx_id
			 , rcta.creation_date trx_created
			 , rcta.last_update_date trx_updated
			 , rcta.term_id
			 , ixrh.xml_request_id
			 , ixrh.creation_date xml_cr_date
			 , ixrh.xmldata
			 , ixrh.method
			 , ixrh.document_type
			 , ixrh.destination
			 , ixrh.failure_reason
			 , rtt.name term_trx
			 , rtt.description
			 , rbsa.name batch_source
		  from iex.iex_delinquencies_all ida
		  join ar.hz_cust_accounts hca on ida.cust_account_id = hca.cust_account_id
		  join ar.ra_customer_trx_all rcta on ida.transaction_id = rcta.customer_trx_id
		  join iex.iex_xml_request_histories ixrh on ixrh.party_id = hca.party_id
		  join ar.ra_terms_tl rtt on rcta.term_id = rtt.term_id
		  join ar.ra_batch_sources_all rbsa on rbsa.batch_source_id = rcta.batch_source_id
		 where 1 = 1
		   -- and hca.account_name like 'Bunny%'
		   -- and hca.account_number = 123456
		   and trunc(ixrh.creation_date) = '15-MAR-2016'
		   and ixrh.method = 'EMAIL'
		   -- and ida.delinquency_id = 123456
		   -- and ixrh.creation_date > '01-MAR-2016'
		   -- and dbms_lob.instr(ixrh.xmldata,'PAYMENT_HISTORY_ROW') = 0 -- blank letter
		   -- and rcta.trx_number in ('123456')
		   -- and ida.status = 'DELINQUENT'
		   -- and hca.account_number = '123456'
		   and 1 = 1
	  order by ida.creation_date desc;

-- ##################################################################
-- XML DATA TABLE DUMPS
-- ##################################################################

/*
Every time the "Oracle Collections Delivery XML Process" job runs, a row is inserted into the IEX_XML_REQUEST_HISTORIES table
We can check that table to see the xml generated via the job (XMLDATA field).
That is then used by the related template 
*/

select * from iex.iex_xml_request_histories order by creation_date desc;
select * from iex.iex_xml_queries;
select * from iex.iex_xml_request_histories where party_id in (123456, 123457);
select * from iex.iex_xml_request_histories where party_id = 123456;
select * from ar.hz_parties hp where hp.party_name like 'Daffy%Duck%';
select * from ar.hz_parties hp where hp.party_id = 123456;
select * from iex.iex_xml_request_histories where conc_request_id = 123456 and destination like 'bunny%';

-- ##################################################################
-- TRYING STUFF OUT
-- ################################################################## 

		select idus.dln_uwq_summary_id
			 , ac1.name collector
			 , idus.collector_resource_name
			 , hca.account_number
			 , hca.account_name
			 , hp.party_name
			 , idus.*
		  from iex.iex_dln_uwq_summary idus
		  join ar.ar_collectors ac1 on idus.collector_id = ac1.collector_id
		  join ar.hz_cust_accounts hca on idus.cust_account_id = hca.cust_account_id 
		  join ar.hz_parties hp on hca.party_id = hp.party_id 
		 where 1 = 1;

		select wkitem.strategy_id strategy_id
			 , wkitem.strategy_temp_id strategy_template_id
			 , wkitem.work_item_order wkitem_order
			 , wkitem.work_item_id wkitem_id
			 , wkitem.work_item_template_id wkitem_template_id
			 , stry_temp_wkitem_tl.name wkitem_template_name
			 -- , iex_utilities.get_lookup_meaning('IEX_STRATEGY_WORK_CATEGORY', stry_temp_wkitem_b.category_type) category_type_meaning
			 , stry_temp_wkitem_b.category_type category
			 , wkitem.execute_start start_time
			 , wkitem.execute_end end_time
			 , wkitem.resource_id resource_id
			 , res.source_name assignee
			 , stry_temp_wkitem_b.escalate_yn escalate_yn
			 , item.display_name workflow_item_type
			 , wkitem.status_code work_item_status
			 , str_temp.strategy_name strategy_temp_name
			 , str.status_code strategy_status
			 , 0 strategy_user_item_id
			 , wkitem.creation_date creation_date
			 , wkitem.created_by created_by
			 , wkitem.last_update_date last_update_date
			 , wkitem.last_updated_by last_updated_by
			 , str.object_type object_type 
		  from iex.iex_strategy_work_items wkitem
			 , iex.iex_stry_temp_work_items_b stry_temp_wkitem_b
			 , iex.iex_stry_temp_work_items_tl stry_temp_wkitem_tl
			 , applsys.wf_item_types_tl item
			 , jtf.jtf_rs_resource_extns res
			 , iex.iex_strategies str
			 , iex.iex_strategy_templates_tl str_temp 
		 where wkitem.work_item_template_id = stry_temp_wkitem_b.work_item_temp_id
		   and stry_temp_wkitem_b.work_item_temp_id = stry_temp_wkitem_tl.work_item_temp_id
		   and stry_temp_wkitem_b.workflow_item_type = item.name(+)
		   and wkitem.resource_id = res.resource_id(+)
		   and wkitem.strategy_id = str.strategy_id
		   and str.strategy_template_id = str_temp.strategy_temp_id
		   and wkitem.status_code in ('OPEN','PRE-WAIT')
		   and str.status_code in ('OPEN','ONHOLD')
		   and str.object_type = 'BILL_TO'
		   and str.strategy_id = 123456
		   and 1 = 1;
