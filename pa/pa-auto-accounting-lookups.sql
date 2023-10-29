/*
File Name: pa-auto-accounting-lookups.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- TABLE DUMP
-- AUTO ACCOUNTING LOOKUPS

*/

-- ##################################################################
-- TABLE DUMP
-- ##################################################################

select * from pa_segment_value_lookup_sets psvls;

-- ##################################################################
-- AUTO ACCOUNTING LOOKUPS
-- ##################################################################

		select psvls.segment_value_lookup_set_name
			 , psvls.description
			 , psvls.segment_value_lookup_set_id
			 , psvl.segment_value_lookup intermediate_value
			 , '#' || psvl.segment_value segment_value
			 , psvl.creation_date
			 , fu.user_name || ' (' || fu.email_address || ')' created_by
		  from pa_segment_value_lookup_sets psvls
		  join pa_segment_value_lookups psvl on psvl.segment_value_lookup_set_id = psvls.segment_value_lookup_set_id
		  join fnd_user fu on fu.user_id = psvl.created_by
		 where 1 = 1
		   and lower(psvls.segment_value_lookup_set_name) like '%proj%typ%' -- agreement?
		   -- and psvl.segment_value = '123456'
		   -- and psvls.segment_value_lookup_set_name = 'PA_TRX_SET_1'
		   -- and psvl.segment_value_lookup = 'XX'
		   -- and psvl.segment_value_lookup = '123456'
		   and 1 = 1
	  order by 1
			 , 2;
