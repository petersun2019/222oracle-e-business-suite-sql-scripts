/*
File Name:		dba-check-ota-running.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- CHECK IF OTA IS RUNNING
-- ##################################################################

		select machine,action, decode(count(*),0,'Error: OTA is Not Running','OTA is Running')
		  from gv$session
		 where action like '%OXTA%'
	  group by machine, action;
