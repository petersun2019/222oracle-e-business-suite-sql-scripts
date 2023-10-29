/*
File Name: sa-lookups.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- LOOKUP VALUES
-- LOOKUP TYPES
-- COUNTING VALUES

*/

-- ##################################################################
-- LOOKUP VALUES
-- ##################################################################

		select flt.lookup_type
			 , fltt.description lookup_type_description
			 , fa.application_short_name app
			 , flv.lookup_code
			 , flv.meaning
			 , flv.description
			 , flv.enabled_flag
			 , to_char(start_date_active, 'DD-MON-RRRR') start_date_active
			 , to_char(end_date_active, 'DD-MON-RRRR') end_date_active
			 , flv.creation_date
			 , fu_cr.user_name cr_by
			 , flv.last_update_date
			 , fu_up.user_name up_by
		  from fnd_lookup_values_vl flv
		  join fnd_application fa on flv.view_application_id = fa.application_id
		  join fnd_user fu_cr on flv.created_by = fu_cr.user_id
		  join fnd_user fu_up on flv.last_updated_by = fu_up.user_id
		  join fnd_lookup_types flt on flv.lookup_type = flt.lookup_type and flv.view_application_id = flt.view_application_id
		  join fnd_lookup_types_tl fltt on flt.lookup_type = fltt.lookup_type and flt.view_application_id = fltt.view_application_id and fltt.language = userenv('lang')
		 where 1 = 1
		   and flv.lookup_code in ('AUTOCREATE','PDOI')
		   -- and fa.application_short_name = 'PA'
		   -- and flt.lookup_type = 'TRANSFER STATUS'
		   and 1 = 1;

-- ##################################################################
-- LOOKUP TYPES
-- ##################################################################

		select flt.lookup_type
			 , fltt.description
			 , fa.application_short_name app
			 , flt.application_id
			 , flt.view_application_id
		  from fnd_lookup_types flt 
		  join fnd_lookup_types_tl fltt on flt.lookup_type = fltt.lookup_type and flt.view_application_id = fltt.view_application_id and fltt.language = userenv('lang')
		  join fnd_application fa on flt.view_application_id = fa.application_id
		 where 1 = 1
		   and flt.lookup_type = 'FC_RESULT_CODE'
		   and flt.application_id = 275
		   and 1 = 1;

-- ##################################################################
-- COUNTING VALUES
-- ##################################################################

		select flt.lookup_type
			 , fltt.description lookup_type_description
			 , fa.application_short_name app
			 , count(*)
		  from fnd_lookup_values_vl flv
		  join fnd_application fa on flv.view_application_id = fa.application_id
		  join fnd_lookup_types flt on flv.lookup_type = flt.lookup_type and flv.view_application_id = flt.view_application_id
		  join fnd_lookup_types_tl fltt on flt.lookup_type = fltt.lookup_type and flt.view_application_id = fltt.view_application_id and fltt.language = userenv('lang')
		 where 1 = 1
		   and fa.application_short_name = 'PA'
		   and flt.lookup_type = 'FC_RESULT_CODE'
		   and 1 = 1
	  group by flt.lookup_type
			 , fltt.description
			 , fa.application_short_name;
