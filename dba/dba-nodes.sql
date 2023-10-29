/*
File Name: dba-nodes.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- DBA NODES
-- ##################################################################

		select node_name
			 , to_char(creation_date, 'DD-MON-RR HH24:MI') creation_date
			 , platform_code
			 , decode(status,'Y','ACTIVE','INACTIVE') status
			 , decode(support_cp,'Y', 'ConcMgr','No') concmgr
			 , decode(support_forms,'Y','Forms', 'No') forms
			 , decode(support_web,'Y','Web', 'No') webserver
			 , decode(support_admin, 'Y','Admin', 'No') admin
			 , decode(support_db, 'Y','Rdbms', 'No') database
			 , to_char(last_monitored_time, 'DD-MON-RR HH24:MI:SS') last_monitored
			 , node_mode
			 , server_address
			 , host
			 , domain
			 , webhost
			 , virtual_ip
			 , server_id
		  from fnd_nodes;
