/*
File Name: dba.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- INSTANCE DETAILS
-- TABLE GRANTS ETC.
-- USER SESSION INFO
-- DBA JOBS
-- HOW TO GENERATE PERFORMANCE TRACE FOR WORKFLOW BACKGROUND PROCESS? (DOC ID 734425.1)
-- SNIPPETS

*/

-- ##################################################################
-- INSTANCE DETAILS
-- ##################################################################

/*
From "ebs concurrent processing analyzer report"
From the "concurrent processing database parameter settings" section
EBS CONCURRENT PROCESSING (CP) ANALYZER (DOC ID 1411723.1)

e.g. output

NAME VALUE
--------------------------------------------------------------
NLS_CHARACTERSET 			UTF8
AQ_TM_PROCESSES 			2
CPU_COUNT 					10
JOB_QUEUE_PROCESSES 		10
NLS_LANGUAGE 				AMERICAN
NLS_TERRITORY 				UNITED KINGDOM
PARALLEL_THREADS_PER_CPU 	2
UTL_FILE_DIR 				/usr/tmp/prod, /usr/tmp

*/

		select name
			 , value
		  from v$parameter
		 where upper(name) in ('AQ_TM_PROCESSES','JOB_QUEUE_PROCESSES','JOB_QUEUE_INTERVAL','UTL_FILE_DIR','NLS_LANGUAGE','NLS_TERRITORY','CPU_COUNT','PARALLEL_THREADS_PER_CPU')
		 union select parameter, value from v$nls_parameters where parameter in ('NLS_CHARACTERSET');

-- ##################################################################
-- TABLE GRANTS ETC.
-- ##################################################################

		select *
		  from table_privileges
		 where table_name like 'XXCUST_PROJ%'
	  order by owner
			 , table_name;

-- ##################################################################
-- USER SESSION INFO
-- HTTP://DOWNLOAD.ORACLE.COM/DOCS/CD/B10501_01/SERVER.920/A96540/FUNCTIONS122A.HTM
-- ##################################################################

		select 'AUDITED_CURSORID', sys_context('USERENV', 'AUDITED_CURSORID') from dual union all
		select 'AUTHENTICATION_DATA', sys_context('USERENV', 'AUTHENTICATION_DATA') from dual union all
		select 'AUTHENTICATION_TYPE', sys_context('USERENV', 'AUTHENTICATION_TYPE') from dual union all
		select 'BG_JOB_ID', sys_context('USERENV', 'BG_JOB_ID') from dual union all
		select 'CLIENT_IDENTIFIER', sys_context('USERENV', 'CLIENT_IDENTIFIER') from dual union all
		select 'CLIENT_INFO', sys_context('USERENV', 'CLIENT_INFO') from dual union all
		select 'CURRENT_SCHEMA', sys_context('USERENV', 'CURRENT_SCHEMA') from dual union all
		select 'CURRENT_SCHEMAID', sys_context('USERENV', 'CURRENT_SCHEMAID') from dual union all
		select 'CURRENT_SQL', sys_context('USERENV', 'CURRENT_SQL') from dual union all
		select 'CURRENT_USER', sys_context('USERENV', 'CURRENT_USER') from dual union all
		select 'CURRENT_USERID', sys_context('USERENV', 'CURRENT_USERID') from dual union all
		select 'DB_DOMAIN', sys_context('USERENV', 'DB_DOMAIN') from dual union all
		select 'DB_NAME', sys_context('USERENV', 'DB_NAME') from dual union all
		select 'EXTERNAL_NAME', sys_context('USERENV', 'EXTERNAL_NAME') from dual union all
		select 'FG_JOB_ID', sys_context('USERENV', 'FG_JOB_ID') from dual union all
		select 'GLOBAL_CONTEXT_MEMORY', sys_context('USERENV', 'GLOBAL_CONTEXT_MEMORY') from dual union all
		select 'HOST', sys_context('USERENV', 'HOST') from dual union all
		select 'INSTANCE', sys_context('USERENV', 'INSTANCE') from dual union all
		select 'IP_ADDRESS', sys_context('USERENV', 'IP_ADDRESS') from dual union all
		select 'ISDBA', sys_context('USERENV', 'ISDBA') from dual union all
		select 'LANG', sys_context('USERENV', 'LANG') from dual union all
		select 'LANGUAGE', sys_context('USERENV', 'LANGUAGE') from dual union all
		select 'NETWORK_PROTOCOL', sys_context('USERENV', 'NETWORK_PROTOCOL') from dual union all
		select 'NLS_CALENDAR', sys_context('USERENV', 'NLS_CALENDAR') from dual union all
		select 'NLS_CURRENCY', sys_context('USERENV', 'NLS_CURRENCY') from dual union all
		select 'NLS_DATE_FORMAT', sys_context('USERENV', 'NLS_DATE_FORMAT') from dual union all
		select 'NLS_DATE_LANGUAGE', sys_context('USERENV', 'NLS_DATE_LANGUAGE') from dual union all
		select 'NLS_SORT', sys_context('USERENV', 'NLS_SORT') from dual union all
		select 'NLS_TERRITORY', sys_context('USERENV', 'NLS_TERRITORY') from dual union all
		select 'OS_USER', sys_context('USERENV', 'OS_USER') from dual union all
		select 'PROXY_USER', sys_context('USERENV', 'PROXY_USER') from dual union all
		select 'PROXY_USERID', sys_context('USERENV', 'PROXY_USERID') from dual union all
		select 'SESSION_USER', sys_context('USERENV', 'SESSION_USER') from dual union all
		select 'SESSION_USERID', sys_context('USERENV', 'SESSION_USERID') from dual union all
		select 'SESSIONID', sys_context('USERENV', 'SESSIONID') from dual union all
		select 'TERMINAL', sys_context('USERENV', 'TERMINAL') from dual;

-- ##################################################################
-- DBA JOBS
-- ##################################################################

select * from sys.dba_jobs;
select * from sys.dba_jobs_running;
select * from sys.dba_scheduler_jobs;
select * from sys.dba_scheduler_running_jobs;
select * from applsys.fnd_tables where table_name = 'DBA_JOBS';

-- ##################################################################
-- HOW TO GENERATE PERFORMANCE TRACE FOR WORKFLOW BACKGROUND PROCESS? (DOC ID 734425.1)
-- YOU CAN USE THE FOLLOWING QUERY TO LOCATE THE TRACE FILE NAME IN THE USER_DUMP_DEST DIRECTORY:
-- ##################################################################

		select request_id
			 , oracle_process_id
			 , req.enable_trace
			 , dest.value||'/'||lower(dbnm.value)||'_ora_'||oracle_process_id||'.trc' trace_file
			 , prog.user_concurrent_program_name
			 , execname.execution_file_name|| execname.subroutine_name file_name
			 , decode(phase_code,'R','Running')||'-'||decode(status_code,'R','Normal') status
			 , ses.sid||','|| ses.serial# sid_serial
			 , ses.module
		  from fnd_concurrent_requests req
			 , v$session ses
			 , v$process proc
			 , v$parameter dest
			 , v$parameter dbnm
			 , fnd_concurrent_programs_vl prog
			 , fnd_executables execname
		 where req.request_id = 20427312
		   and req.oracle_process_id=proc.spid(+)
		   and proc.addr = ses.paddr(+)
		   and dest.name = 'user_dump_dest'
		   and dbnm.name = 'db_name'
		   and req.concurrent_program_id = prog.concurrent_program_id
		   and req.program_application_id = prog.application_id
		   and prog.application_id = execname.application_id
		   and prog.executable_id = execname.executable_id; 

-- ##################################################################
-- SNIPPETS
-- ##################################################################

-- SQL TO ACCESS A VIEW IF NOT LOGGED IN AS APPS USER

alter session set nls_language = 'AMERICAN';
exec dbms_application_info.set_client_info(82);

