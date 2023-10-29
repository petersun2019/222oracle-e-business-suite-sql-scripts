/*
File Name:		sa-fnd-debug.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- TABLE DUMPS
-- FND DEBUG START SEQUENCE
-- LOG MESSAGES DETAILS
-- LOG MESSAGES DETAILS JOINED TO USER TABLE

*/

-- ##################################################################
-- TABLE DUMPS
-- ##################################################################

select max(log_sequence) from fnd_log_messages;
select * from fnd_log_messages;
select count(*) from fnd_log_messages; -- 55625
select * from fnd_log_messages where upper(message_text) like '%XLABAPUB%';
select * from fnd_log_messages where log_sequence in (327994538,327994367,327994402,327994646,325797189,325141953);
select max(log_sequence) from fnd_log_messages where message_text like '%29204293%';

-- ##################################################################
-- FND DEBUG START SEQUENCE
-- ##################################################################

select max(log_sequence) from applsys.fnd_log_messages;

-- ##################################################################
-- LOG MESSAGES DETAILS
-- ##################################################################

		select log_sequence
			 , timestamp
			 , module
			 , message_text
		  from applsys.fnd_log_messages fnd
		 where 1 = 1
		   and fnd.log_sequence between 12345678 and 12349876
	  order by fnd.log_sequence asc;

-- ##################################################################
-- LOG MESSAGES DETAILS JOINED TO USER TABLE
-- ##################################################################

		select log_sequence
			 , timestamp
			 , module
			 , message_text
		  from applsys.fnd_log_messages fnd
		  join applsys.fnd_user fu on fu.user_id = fnd.user_id
		 where 1 = 1
		   and trunc(timestamp) = trunc(sysdate)
		   and fu.user_name = 'USER123'
		   and fnd.log_sequence between :seq_start and :seq_end
	  order by fnd.log_sequence asc;
