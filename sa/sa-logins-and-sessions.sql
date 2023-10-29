/*
File Name: sa-logins-and-sessions.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- USER, LOGIN DETAILS, LOGIN COUNT
-- LOGIN DETAILS LINE LEVEL
-- LOGINS TODAY
-- UNSUCCESSFUL LOGINS
-- SESSIONS TABLE DUMP
-- SESSIONS 1
-- SESSIONS 2
-- SESSIONS 3
-- SESSIONS 4

If a user is end-dated on a test system, and you remove the end-date from their account
but do not reset their password, you will show as the person who last updated the record
even if that user logs in.

If you reset a user password, then when they log in they have to choose a new password.
they then show as the last person to update their fnd user account.
*/

-- ##################################################################
-- USER, LOGIN DETAILS, LOGIN COUNT
-- ##################################################################

		select fu.user_name
			 , (select max(start_time) from applsys.fnd_logins fl where fl.user_id = fu.user_id) last_login
			 , (select count(*) from applsys.fnd_logins fl where fl.user_id = fu.user_id) login_count
			 , (select count(*) from applsys.fnd_logins fl where fl.user_id = fu.user_id and start_time > trunc(sysdate)) login_count_today 
		  from applsys.fnd_user fu
		 where 1 = 1
		   -- and fu.user_name in ('USER123')
		   and nvl(fu.end_date, sysdate + 1) > sysdate
	  order by 3 desc;

-- ##################################################################
-- LOGIN DETAILS LINE LEVEL
-- ##################################################################

		select fu.description
			 , fu.user_name
			 , fl.start_time
			 , fu.email_address
			 , fu.last_logon_date
			 , fl.*
		  from fnd_user fu
		  join fnd_logins fl on fl.user_id = fu.user_id 
		 where 1 = 1
		   and fl.login_type = 'FORM' -- login
		   -- and fl.user_id > 0 -- not sysadmin
		   -- and fl.start_time > '30-AUG-2021'
		   -- and fu.user_name not in ('FSSC_SCHEDULER','SYSADMIN')
		   -- and fu.user_name in ('USER123')
		   and fl.start_time > trunc (sysdate) - 2
		   and fl.user_id > 0 -- not sysadmin
		   -- and fu.user_name = 'USER123'
		   and 1 = 1
	  order by fl.start_time desc;

-- ##################################################################
-- LOGINS TODAY
-- ##################################################################

		select fu.description
			 , fu.user_name
			 , count(*) ct
		  from fnd_logins fl
		  join fnd_user fu on fl.user_id = fu.user_id
		 where 1 = 1
		   -- and fl.start_time > trunc (sysdate) - 1
		   -- and fu.user_name not like 'PSL%'
		   and fl.login_type = 'FORM'
		   and fl.user_id > 0 -- not sysadmin
		   and fu.user_name = 'USER123'
		   and 1 = 1
	  group by fu.description
			 , fu.user_name
	  order by 3 desc;

-- ##################################################################
-- UNSUCCESSFUL LOGINS
-- ##################################################################

		select fu.description
			 , fu.user_name
			 , ful.*
		  from applsys.fnd_unsuccessful_logins ful
		  join applsys.fnd_user fu on ful.user_id = fu.user_id 
		 where 1 = 1
		   and fu.user_name = 'USER123'
	  order by ful.attempt_time desc;

-- ##################################################################
-- SESSIONS TABLE DUMP
-- ##################################################################

select * from icx_sessions where user_id = 41746 order by creation_date desc;
select * from icx_sessions;

-- ##################################################################
-- SESSIONS 1
-- ##################################################################

		select (select user_function_name
				  from fnd_form_functions_vl fffv
				 where fffv.function_id = a.function_id) "current function"
			 , to_char (first_connect, 'MM/DD/YYYY HH24:MI:SS') start_time
			 , to_char (last_connect,'MM/DD/YYYY HH:MI:SS') "date and time of last hit"
			 , to_char (sysdate, 'HH24:MI:SS') current_time
			 , user_name
			 , session_id
			 , (sysdate - last_connect) * 24 * 60 mins_idle
			 , fnd_profile.value_specific ('ICX_SESSION_TIMEOUT', a.user_id, a.responsibility_id, a.responsibility_application_id, a.org_id, null) timeout
			 , counter "how many hits a user has made"
			 , a.limit_connects "num of hits allowed in session"
		  from icx_sessions a
		  join fnd_user b on a.user_id = b.user_id
		 where last_connect > sysdate - 1 / 24;

-- ##################################################################
-- SESSIONS 2
-- ##################################################################

		select d.user_name "user name"
			 , b.sid sid
			 , b.serial# "serial#"
			 , c.spid "srvpid"
			 , a.spid "os_pid"
			 , to_char(start_time,'DD-MON-YY HH24:MM:SS') "stime"
		  from fnd_logins a
		  join v$session b on a.spid = b.process
		  join v$process c on b.paddr = c.addr
		  join fnd_user d on a.pid = c.pid and d.user_id = a.user_id
		 where 1 = 1
		   and d.user_name = 'USER123'
		   and 1 = 1;

-- ##################################################################
-- SESSIONS 3
-- ##################################################################

		select fu.description
			 , iss.session_id
			 , iss.creation_date
		  from applsys.fnd_user fu
			 , icx.icx_sessions iss
		 where iss.user_id = fu.user_id
		   and fu.user_name = 'USER123'
	  order by iss.creation_date desc;

-- ##################################################################
-- SESSIONS 4
-- ##################################################################

		select machine_id
			 , db_name
			 , trunc(min(timestamp),'HH24') min_ts
			 , trunc(max(timestamp),'HH24') max_ts
			 , count(distinct trunc(timestamp, 'HH24')) count_ts
			 , count(*) count_rows
		  from icx_sessions
	  group by machine_id
			 , db_name;
