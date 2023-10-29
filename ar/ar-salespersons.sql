/*
File Name: ar-salespersons.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- SALESPERSONS
-- TABLE DUMPS

*/

-- ##################################################################
-- SALESPERSONS
-- ##################################################################

		select fu.user_name
			 , fu.email_address
			 , jrs.salesrep_number
			 , jrs.salesrep_id
			 , jrs.resource_id
			 , jrs.creation_date
			 , jrs.name
			 , jrs.status
			 , to_char(jrs.start_date_active, 'DD-MON-YYYY') start_date_active
			 , to_char(jrs.end_date_active, 'DD-MON-YYYY') end_date_active
			 , gsob.name set_of_books
			 , hou.short_code ou
			 , gcc_rev.concatenated_segments gl_rev
			 , gcc_rec.concatenated_segments gl_rec
		  from jtf.jtf_rs_salesreps jrs
		  join applsys.fnd_user fu on jrs.created_by = fu.user_id
		  join apps.gl_sets_of_books gsob on gsob.set_of_books_id = jrs.set_of_books_id
		  join apps.hr_operating_units hou on hou.organization_id = jrs.org_id
	 left join apps.gl_code_combinations_kfv gcc_rev on gcc_rev.code_combination_id = jrs.gl_id_rev
	 left join apps.gl_code_combinations_kfv gcc_rec on gcc_rec.code_combination_id = jrs.gl_id_rec
		 where 1 = 1
		   -- and jrs.salesrep_id = 123456
		   -- and jrs.resource_id = 123456
		   and 1 = 1;

-- ##################################################################
-- TABLE DUMPS
-- ##################################################################

		select *
		  from jtf.jtf_rs_salesreps
		 where 1 = 1
		   and 1 = 1;

		select *
		  from jtf_rs_resource_extns_vl
		 where 1 = 1
		   and 1 = 1;

		select res.resource_name
			 , res.resource_id
		  from ra_salesreps_all s
			 , jtf_rs_resource_extns_vl res 
		 where s.resource_id = res.resource_id
		   and 1 = 1
		   -- and res.resource_id = 123456
		   -- and s.org_id = fnd_global.org_id 
		   -- and s.salesrep_id = fnd_profile.value('XXCUST_DEFAULT_PERSON_ID')
		   and 1 = 1;
