/*
File Name: pa-lookups.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- PA LOOKUPS
-- ##################################################################

		select psvls.segment_value_lookup_set_id id
			 , psvls.segment_value_lookup_set_name lookup_set
			 , psvls.description
			 , fu.user_name
			 , fu.email_address
			 , psvl.segment_value lookup_value
			 , psvl.creation_date
		  from pa_segment_value_lookup_sets psvls
		  join pa_segment_value_lookups psvl on psvl.segment_value_lookup_set_id = psvls.segment_value_lookup_set_id
		  join fnd_user fu on psvl.created_by = fu.user_id
		 where 1 = 1
		   -- and psvls.segment_value_lookup_set_name = 'Expenditure Type to Account'
		   -- and psvl.creation_date > '01-SEP-2017'
		   and psvl.segment_value in ('VI','BTC')
		   and 1 = 1;
