/*
File Name: sa-alerts.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- TABLE DUMPS
-- ALERT DETAILS
-- CHECK DATA LINKED TO ALERT RUN

*/

-- ##################################################################
-- TABLE DUMPS
-- ##################################################################

select * from alr_alert_history_view;
select * from alr_alert_checks where alert_id = 123456;
select * from alr_alerts where lower(alert_name) like '%supplier%';
select * from alr.alr_alert_checks where alert_id = 123456;
select * from alr.alr_alerts where upper(alert_name) like 'XX%' order by creation_date desc;
select created_by from alr.alr_alerts where lower(alert_name) like '%xx_j%';
select * from alr_distribution_lists;

-- ##################################################################
-- ALERT DETAILS
-- ##################################################################

		select aac.last_update_date alert_date
			 , aac.request_id
			 , aac.success_flag
			 , fu.user_name
			 , fu.description
			 , aa.alert_name
			 , aa.table_name
			 , frt.responsibility_name
			 , fcr.status_code
			 , fcr.completion_code
			 , fcr.completion_text
			 , aa.alert_id
		  from alr_alert_checks aac
		  join fnd_user fu on aac.last_updated_by = fu.user_id
		  join alr_alerts aa on aac.alert_id = aa.alert_id
	 left join fnd_concurrent_requests fcr on fcr.request_id = aac.request_id
	 left join fnd_responsibility_tl frt on fcr.responsibility_id = frt.responsibility_id and frt.language = userenv('lang')
		 where 1 = 1
		   -- and lower(aa.alert_name) like '%hold%'
		   and aa.alert_name = 'XX Interface Error Alert'
		   -- and aac.alert_id = 101079 
		   -- and aac.last_update_date > '03-MAR-2017'
		   -- and aac.last_update_date > '01-JAN-2016'
		   -- and aac.success_flag = 'R'
	  order by aac.last_update_date desc;

-- ##################################################################
-- CHECK DATA LINKED TO ALERT RUN
-- ##################################################################

		select * from alr_alert_history_view
		 where alert_name ='IPROC - NEW AND UPDATED USERS' 
		   and output_name = 'EMAIL_ADDRESS' 
		   and alert_check_date > '20-MAR-2022';
