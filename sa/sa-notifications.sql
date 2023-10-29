/*
File Name:		sa-notifications.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- BASIC CHECKING
-- NOTIFICATION CHECKING - DETAIL
-- NOTIFICATION CHECKING - COUNT
-- NOTIFICATIONS ABOUT ERRORING CONCURRENT REQUESTS
-- NOTIFICATION ATTRIBUTES

*/

-- ##################################################################
-- BASIC CHECKING
-- ##################################################################

select * from wf_notifications where subject like '%PO123456%';
select * from wf_notifications where recipient_role = 'USER123' and message_type = 'REQAPPRV';
select * from wf_notifications where message_type = 'POAPPRV' and message_ name = 'UNABLE_TO_RESERVE' and status = 'O' order by 1 desc;
select * from wf_notifications where to_user = 'USER123' and message_type = 'REQAPPRV';
select * from wf_notifications where message_type = 'FNDCMMSG' and message_name = 'REQ_COMPLETION_W_URL' and begin_date > '31-dec-2020' and subject like '%(PRC: %Error';

-- ##################################################################
-- NOTIFICATION CHECKING - DETAIL
-- ##################################################################

		select wn.notification_id
			 , wn.to_user
			 , wn.recipient_role
			 , wn.item_key
			 , wn.message_type
			 , wn.message_name 
			 , wn.recipient_role
			 , wn.status
			 , wn.begin_date 
			 , wn.mail_status
			 , wn.subject
			 , wn.context
			 , wn.responder
			 , wn.end_date
			 , '------>'
			 , wn.*
		  from applsys.wf_notifications wn
		 where 1 = 1
		   and message_type = 'FNDCMMSG'
		   -- and message_name = 'XX_PA_BUDGETS_AMENDED'
		   and notification_id in (9011364)
		   -- and wn.to_user = 'USER123'
		   -- and subject like '%123456%'
		   -- and begin_date > sysdate - 1
		   -- and wn.begin_date > '07-FEB-2022'
		   -- and wn.begin_date < '05-OCT-2021'
		   and 1 = 1
	  order by wn.notification_id desc;

-- ##################################################################
-- NOTIFICATION CHECKING - COUNT
-- ##################################################################

		select wn.message_type
			 , count(*) ct 
		  from applsys.wf_notifications wn
		 where 1 = 1
		   and begin_date > '17-DEC-2020'
		   and begin_date < '18-DEC-2020'
	  group by wn.message_type;

-- ##################################################################
-- NOTIFICATIONS ABOUT ERRORING CONCURRENT REQUESTS
-- ##################################################################

		select notification_id
			 , group_id
			 -- , from_role
			 -- , sent_date
			 , message_type
			 , message_name
			 , recipient_role
			 , status
			 , access_key
			 , mail_status
			 , priority
			 , to_char(begin_date, 'DD-MM-YYYY') distinct_date
			 , begin_date
			 , end_date
			 , original_recipient
			 , from_user
			 , to_user
			 , subject
			 , sent_date
			 , to_char(begin_date, 'DD-MM-YYYY') begin_date
		  from wf_notifications
		 where message_type = 'FNDCMMSG'
		   -- and to_char(begin_date, 'DD-MM-YYYY') = '31-01-2022'
		   -- and lower(subject) like '%error%'
		   -- and message_name = 'REQ_COMPLETION_W_URL'
		   -- and to_user = 'Sean Dacre'
		   -- and to_char(begin_date, 'yyyy-mm-dd') = '2022-02-02'
		   and subject like '%(PRC: %Error'
	  order by notification_id desc;

-- ##################################################################
-- NOTIFICATION ATTRIBUTES
-- ##################################################################

		select * 
		  from wf_notification_attributes
		 where notification_id = 12345678;
