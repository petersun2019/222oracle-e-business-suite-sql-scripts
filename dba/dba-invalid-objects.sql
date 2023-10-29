/*
File Name:		dba-invalid-objects.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- INVALID OBJECTS
-- ##################################################################

/*
HTTP://WWW.ORACLE-BASE.COM/ARTICLES/MISC/RECOMPILING-INVALID-SCHEMA-OBJECTS.PHP
*/

		select owner
			 , object_type
			 , object_name
			 , status
		  from dba_objects
		 where 1 = 1
		   and status = 'INVALID'
		   -- and object_name in ('FFW1458_06042016','FFW1627_06042019')
	  order by owner
			 , object_type
			 , object_name;
