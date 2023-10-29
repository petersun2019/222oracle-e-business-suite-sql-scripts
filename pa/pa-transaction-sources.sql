/*
File Name:		pa-transaction-sources.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- TRANSACTION SOURCES
-- ##################################################################

		select pts.user_transaction_source
			 , pts.transaction_source
			 , pts.batch_size
			 , pts.purgeable_flag
			 , pts.allow_adjustments_flag
			 , pts.gl_accounted_flag
			 , pts.allow_duplicate_reference_flag
			 , pts.modify_interface_flag
			 , pts.creation_date
			 , fu1.user_name created_by
			 , pts.last_update_date
			 , fu2.user_name updated_by
		  from pa.pa_transaction_sources pts
		  join applsys.fnd_user fu1 on pts.created_by = fu1.user_id
		  join applsys.fnd_user fu2 on pts.last_updated_by = fu2.user_id
		 where 1 = 1
		   -- and lower(pts.user_transaction_source) like '%web%'
		   -- and pts.user_transaction_source in ('Payroll - Adjustments','Spreadsheet')
		   and 1 = 1
	  order by pts.creation_date desc;
