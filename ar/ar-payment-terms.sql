/*
File Name:		ar-payment-terms.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- AR PAYMENT TERMS - HEADERS
-- AR PAYMENT TERMS - LINES

*/

-- ##################################################################
-- AR PAYMENT TERMS - HEADERS
-- ##################################################################

		select rtb.term_id
			 , rtb.creation_date
			 , fu1.user_name || ' (' || fu1.email_address || ')' created_by
			 , rtb.last_update_date
			 , fu2.user_name || ' (' || fu2.email_address || ')' updated_by
			 , rtt.name
			 , rtt.description
			 , rtb.credit_check_flag credit_check
			 , rtb.prepayment_flag prepayment
			 , acbct.cycle_name billing_cycle
			 , rtb.base_amount
			 , to_char(rtb.start_date_active, 'DD-MON-YYYY') start_date
			 , to_char(rtb.end_date_active, 'DD-MON-YYYY') end_date
			 , rtb.printing_lead_days
			 , flv3.meaning installment_options
			 , rtb.due_cutoff_day
			 -- , '################'
			 -- , rtt.*
		  from ar.ra_terms_b rtb
		  join ar.ra_terms_tl rtt on rtb.term_id = rtt.term_id
		  join applsys.fnd_user fu1 on rtb.created_by = fu1.user_id
		  join applsys.fnd_user fu2 on rtb.created_by = fu2.user_id
	 left join ar.ar_cons_bill_cycles_tl acbct on acbct.billing_cycle_id = rtb.billing_cycle_id
	 left join applsys.fnd_lookup_values_vl flv3 on rtb.first_installment_code = flv3.lookup_code and flv3.view_application_id = 222 and flv3.lookup_type = 'INSTALLMENT_OPTION'
		 where 1 = 1
		   -- and name in ('MY PAYMENT TERMS')
		   and 1 = 1;

-- ##################################################################
-- AR PAYMENT TERMS - LINES
-- ##################################################################

		select rtb.term_id
			 , rtb.creation_date
			 , fu.user_name || ' (' || fu.email_address || ')' created_by
			 , to_char(rtb.start_date_active, 'DD-MON-YYYY') start_date
			 , to_char(rtb.end_date_active, 'DD-MON-YYYY') end_date
			 , rtt.name
			 , rtt.description
			 , rtl.sequence_num seq
			 , rtl.relative_amount
			 , rtl.due_days
			 , rtl.due_date
			 , rtl.due_day_of_month
			 , rtl.due_months_forward
		  from ar.ra_terms_b rtb
		  join ar.ra_terms_tl rtt on rtb.term_id = rtt.term_id
		  join ar.ra_terms_lines rtl on rtl.term_id = rtb.term_id
		  join applsys.fnd_user fu on rtb.created_by = fu.user_id;
