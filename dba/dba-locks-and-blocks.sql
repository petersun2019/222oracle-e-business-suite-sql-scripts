/*
File Name: dba-locks-and-blocks.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- LOCKS 1
-- LOCKS 2
-- LOCKS 3
-- LOCKS 4

*/

-- ##################################################################
-- LOCKS 1 (HTTPS://ORAHOW.COM/FIND-AND-REMOVE-TABLE-LOCK-IN-ORACLE/)
-- ##################################################################

		select b.owner
			 , b.object_name
			 , a.oracle_username
			 , a.os_user_name 
		  from v$locked_object a
		  join all_objects b on a.object_id = b.object_id;

-- ##################################################################
-- LOCKS 2
-- ##################################################################

		select a.sid||'|'|| a.serial#||'|'|| a.process
		  from v$session a
		  join v$locked_object b on a.sid = b.session_id
		  join dba_objects c on b.object_id = c.object_id
		 where 1 = 1
		   and object_name = upper('PO_REQUISITION_HEADERS_ALL')
		   and 1 = 1;

-- ##################################################################
-- LOCKS 3
-- ##################################################################

		select (select username
				  from v$session 
				 where sid = a.sid) blocker
			 , a.sid
			 , ' is blocking '
			 , (select username 
				  from v$session
				 where sid = b.sid) blockee
			 , b.sid
		  from v$lock a
		  join  v$lock b on a.id1 = b.id1 and a.id2 = b.id2
		 where a.block = 1
		   and b.request > 0;

-- ##################################################################
-- LOCKS 4 (HTTPS://SUPPORT.ORACLE.COM/EPMOS/FACES/DOCUMENTDISPLAY?PARENT=DOCUMENT&SOURCEID=1096873.1&ID=156965.1)
-- ##################################################################

		select substr(to_char(l.session_id)||','||to_char(s.serial#),1,12) sid_ser
			 , substr(l.os_user_name||'/'||l.oracle_username,1,12) username
			 , l.process
			 , p.spid
			 , substr(o.owner||'.'||o.object_name,1,35) owner_object
			 , decode(l.locked_mode,1,'No Lock',2,'Row Share',3,'Row Exclusive',4,'Share',5,'Share Row Excl',6,'Exclusive',null) locked_mode
			 , substr(s.status,1,8) status
		  from v$locked_object l
		  join all_objects o on l.object_id = o.object_id
		  join v$session s on l.session_id = s.sid
		  join v$process p on s.paddr = p.addr
		 where 1 = 1
		   and s.status != 'KILLED'
		   and 1 = 1;
