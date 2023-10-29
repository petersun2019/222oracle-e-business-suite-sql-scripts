/*
File Name: dba-session-monitor.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- SESSION MONITOR - VERSION 1
-- SESSION MONITOR - VERSION 2
-- SESSION MONITOR - VERSION 3
-- SESSION MONITOR - VERSION 4

*/

-- ##################################################################
-- SESSION MONITOR - VERSION 1
-- HTTP://STACKOVERFLOW.COM/QUESTIONS/55899/HOW-TO-SEE-THE-ACTUAL-ORACLE-SQL-STATEMENT-THAT-IS-BEING-EXECUTED
-- ##################################################################

		select module
			 , action
			 , disco_sched
			 , disco_submitted
			 , disco_user
			 , username 
			 , disk_reads_per_exec 
			 , sql_text
			 , buffer_gets 
			 , disk_reads 
			 , parse_calls 
			 , sorts 
			 , executions 
			 , rows_processed 
			 , hit_ratio 
			 , first_load_time 
			 , last_load_time
			 , last_active_time
			 , sharable_mem 
			 , persistent_mem 
			 , runtime_mem 
			 , cpu_time 
			 , elapsed_time 
			 , address 
			 , hash_value from (select module
									 , action
									 , case when (instr(sql_text, 'EUL') > 1)then 'Y' end disco_sched
									 , case when module like 'Disco%' then 'Y' end disco_submitted
									 , case when module like 'Disco10,%:%' then (select description || ' (' || substr(module, instr(module, ':')+1, 200) || ')' from applsys.fnd_user fu where user_name = (substr(module, instr(module, ',') + 2, (instr(module, ':') - instr(module, ',')-2)))) end disco_user
									 , u.username
									 , round((s.disk_reads/decode(s.executions,0,1, s.executions)),2) disk_reads_per_exec
									 , sql_text
									 , s.disk_reads
									 , s.buffer_gets
									 , s.parse_calls
									 , s.sorts
									 , s.executions
									 , s.rows_processed
									 , 100 - round(100 * s.disk_reads/greatest(s.buffer_gets,1),2) hit_ratio
									 , s.first_load_time
									 , s.last_load_time
									 , s.last_active_time
									 , sharable_mem
									 , persistent_mem
									 , runtime_mem
									 , cpu_time
									 , elapsed_time
									 , address
									 , hash_value
								  from sys.v_$sql s
								  join sys.all_users u on s.parsing_user_id = u.user_id 
								 where 1 = 1
								   and upper(u.username) not in ('SYS','SYSTEM') 
								   -- and module like 'Tv_$sqltextOAD%'
								   -- and sql_text not like '%EUL%'
							  order by 7 desc)
		 where rownum <= 20;

-- ##################################################################
-- SESSION MONITOR - VERSION 2
-- ##################################################################

		select nvl(ses.username,'ORACLE PROC')||' ('||ses.sid||')' username
			 , sid
			 , machine
			 , module
			 , program
			 -- , replace(sql.sql_text,chr(10),'') stmt
			 , ltrim(to_char(floor(ses.last_call_et/3600), '09')) || ':' || ltrim(to_char(floor(mod(ses.last_call_et, 3600)/60), '09')) || ':' || ltrim(to_char(mod(ses.last_call_et, 60), '09')) run_time
		  from v$session ses
		  join v$sqltext_with_newlines sql on ses.sql_address = sql.address
		 where ses.status = 'ACTIVE'
		   and ses.username is not null
		   and ses.sql_hash_value = sql.hash_value 
		   and ses.audsid <> userenv('SESSIONID') 
	  order by run_time desc
			 , 1
			 , sql.piece;

-- ##################################################################
-- SESSION MONITOR - VERSION 3
-- ##################################################################

		select sess.audsid
			 -- , sess.inst_id
			 , proc.pid
			 , proc.spid spid
			 , sess.sid
			 , sess.serial#
			 , proc.username proc_user
			 , nvl(sess.username,'{Background Task}') sess_user
			 , sess.program
			 , sess.client_identifier
			 , sess.module
			 , sess.action
			 , to_char(sess.logon_time,'YYYY/MM/DD HH24:MI:SS') logon_time
			 , sess.status
			 , trunc(stat.value/1024) memory_kb
		  from v$process proc
		  join v$session sess on proc.addr = sess.paddr
		  join v$sesstat stat on sess.sid = stat.sid
		  join v$statname name on stat.statistic# = name.statistic#
		 where 1 = 1
		   and name.name = 'SESSION PGA MEMORY'
		   -- and proc.spid in (29662,9623) -- when finding specific process
	  -- order by memory_kb desc -- to list by memory consumption
	  order by logon_time desc; -- to list by logon time 

-- ##################################################################
-- SESSION MONITOR - VERSION 4
-- ##################################################################

		select sid
			 , serial#
			 , module
			 , program
			 , username
			 , to_char(logon_time,'hh24:mi:ss')
		  from v$session
		 where 1 = 1
		   and module like '%OA%'
	  order by 6 asc;
