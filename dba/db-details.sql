/*
File Name: db-details.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- DBA SYSTEM / SESSION INFO
-- DATABASE DETAILS
-- INSTANCE DETAILS
-- DATABASE NAME
-- CLIENT INFO

*/

-- ##################################################################
-- DBA SYSTEM / SESSION INFO
-- ##################################################################

select * from v$version;
select * from v$database;
select * from v$instance;
select * from v$parameters;
select * from global_name;
select * from v$parameter order by name;
select * from v$session s where s.audsid = userenv ('sessionid');

/*
HTTPS://STACKOVERFLOW.COM/QUESTIONS/16565829/IS-THERE-A-WAY-TO-GET-INFORMATION-ABOUT-A-SERVER-USING-sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scriptsHTTPS://ORACLE-BASE.COM/ARTICLES/MISC/IDENTIFYING-HOST-NAMES-AND-ADDRESSES
*/

-- ##################################################################
-- DATABASE DETAILS
-- ##################################################################

-- DATABASE VERSION
select * from v$version;

-- OPERATING SYSTEM
		select rtrim(substr(replace(banner,'TNS for ',''),1,instr(replace(banner,'TNS for ',''),':')-1)) os
		  from v$version
		 where banner like 'TNS for %';

-- PRODUCT DETAILS
select * from product_component_version;

-- ##################################################################
-- INSTANCE DETAILS
-- ##################################################################

-- INSTANCE INFO (INSTANCE NAME, HOST NAME, VERSION, STARTUP TIME ETC.)
select * from v$instance;

-- ABOUT LICENSE LIMITS OF THE CURRENT INSTANCE.
select * from v$license;

-- ##################################################################
-- DATABASE NAME
-- ##################################################################

-- DATABASE NAME
select * from global_name;

-- DATABASE IP ADDRESS
select utl_inaddr.get_host_address from dual;

--DB HOST NAME.
select utl_inaddr.get_host_name('12.34.56.255') from dual;

-- ##################################################################
-- CLIENT INFO
-- ##################################################################

-- IP ADDRESS OF THE CLIENT MACHINE
select sys_context('USERENV','IP_ADDRESS') from dual;

-- OPERATING SYSTEM IDENTIFIER FOR THE CURRENT SESSION. THIS IS OFTEN THE CLIENT MACHINE NAME
select sys_context('USERENV','TERMINAL') from dual;

-- HOST NAME OF THE CLIENT MACHINE
select sys_context('USERENV','HOST') from dual;

-- HOST NAME OF THE SERVER RUNNING THE DATABASE INSTANCE
select sys_context('USERENV','SERVER_HOST') from dual;
