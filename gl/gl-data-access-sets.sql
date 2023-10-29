/*
File Name: gl-data-access-sets.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- GL DATA ACCESS SETS
-- ##################################################################

		select gasv.name
			 , gasv.description
			 , gasv.chart_of_accounts_name coa
			 , gasv.period_set_name calendar
			 , gasv.user_period_type period_type
			 , gasv.creation_date header_created
			 , fu1.user_name || ' (' || fu1.email_address || ')' header_created_by
			 , gl.name ledger
			 , gasnav.segment_value segment
			 , gasnav.all_segment_value_flag all_ticked
			 , gasnav.segment_value_type_code
			 , decode(gasnav.access_privilege_code, 'R', 'Read Only', 'B', 'Read and Write') priv
			 , gasnav.creation_date line_created
			 , fu2.user_name || ' (' || fu2.email_address || ')' line_created_by
		  from gl_access_sets_v gasv
		  join gl_access_set_norm_assign_v gasnav on gasv.access_set_id = gasnav.access_set_id
		  join gl_ledgers gl on gasnav.ledger_id = gl.ledger_id
		  join fnd_user fu1 on gasv.created_by = fu1.user_id
		  join fnd_user fu2 on gasnav.created_by = fu2.user_id
		 where 1 = 1
		   -- and gasnav.segment_value in ('AAA','BBBCC')
		   and 1 = 1
		   -- and gasnav.all_segment_value_flag = 'Y'
		   -- and gasnav.segment_value_type_code = 'S'
		   -- and gasv.name = 'XXCUST_0001'
		   and gasv.creation_date > '01-JAN-2017'
		   and 1 = 1;
