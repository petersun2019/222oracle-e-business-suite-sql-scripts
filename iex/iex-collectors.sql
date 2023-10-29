/*
File Name: iex-collectors.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- SETUP OF COLLECTORS
-- ##################################################################

		select ac.name collector
			 , ac.alias
			 , papf.full_name
			 , papf.employee_number
			 , ac.collector_id
			 , ac.resource_id
			 , ac.employee_id
			 , ac.creation_date
			 , fu1.email_address created_by
			 , ac.last_update_date
			 , fu2.description updated_by
			 , fu3.user_name user_name
			 , fu3.end_date
		  from ar.ar_collectors ac
		  join applsys.fnd_user fu1 on ac.created_by = fu1.user_id
		  join applsys.fnd_user fu2 on ac.last_updated_by = fu2.user_id
	 left join applsys.fnd_user fu3 on ac.employee_id = fu3.employee_id
	 left join hr.per_all_people_f papf on ac.employee_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
		 where 1 = 1
		   -- and papf.employee_number = '12345678'
		   and 1 = 1
	  order by ac.creation_date desc;
