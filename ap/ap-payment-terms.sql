/*
File Name:		ap-payment-terms.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- AP PAYMENT TERMS
-- ##################################################################

		select att.term_id
			 , att.name
			 , att.description
			 , att.due_cutoff_day
			 , att.type
			 , att.enabled_flag
			 , att.creation_date term_created
			 , fu1.description term_created_by
			 , att.last_update_date term_updated
			 , fu2.description term_updated_by
			 , to_char(att.start_date_active, 'DD-MON-YYYY') start_date_active
			 , to_char(att.end_date_active, 'DD-MON-YYYY') end_date_active
			 , '#### lines ####'
			 , atl.due_percent
			 , atl.due_days
			 , atl.creation_date line_created
			 , fu3.description line_created_by
			 , att.last_update_date line_updated
			 , fu4.description line_updated_by 
		  from ap_terms_tl att
		  join ap_terms_lines atl on att.term_id = atl.term_id
		  join fnd_user fu1 on att.created_by = fu1.user_id
		  join fnd_user fu2 on att.last_updated_by = fu2.user_id
		  join fnd_user fu3 on atl.created_by = fu3.user_id
		  join fnd_user fu4 on atl.last_updated_by = fu4.user_id
		 where 1 = 1
		   and 1 = 1
	  order by att.name;
