/*
File Name:		ar-receivables-activities.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- RECEIVABLES ACTIVITIES
-- ##################################################################

		select arta.receivables_trx_id
			 , arta.name
			 , arta.description
			 , decode(arta.status, 'A', 'Active', 'I', 'Inactive') status
			 , flv1.meaning type
			 , flv2.meaning tax_code_source
			 , flv3.meaning gl_account_source
			 , arta.tax_recoverable_flag recoverable
			 , arta.creation_date
			 , fu.description created_by
			 , arta.last_update_date
			 , fu2.description updated_by
			 , gcc.concatenated_segments activity_gl_account
			 , to_char(arta.start_date_active, 'DD-MON-YYYY') start_date_active
			 , to_char(arta.end_date_active, 'DD-MON-YYYY') end_date_active
			 , to_char(arta.inactive_date, 'DD-MON-YYYY') inactive_date
			 -- , '#################################'
			 -- , arta.*
		  from ar.ar_receivables_trx_all arta
	 left join applsys.fnd_user fu on arta.created_by = fu.user_id
	 left join applsys.fnd_user fu2 on arta.last_updated_by = fu2.user_id
	 left join apps.gl_code_combinations_kfv gcc on arta.code_combination_id = gcc.code_combination_id
	 left join applsys.fnd_lookup_values_vl flv1 on arta.type = flv1.lookup_code and flv1.view_application_id = 222 and flv1.lookup_type = 'RECEIVABLES_TRX'
	 left join applsys.fnd_lookup_values_vl flv2 on arta.tax_code_source = flv2.lookup_code and flv2.view_application_id = 222 and flv2.lookup_type = 'TAX_CODE_SOURCE'
	 left join applsys.fnd_lookup_values_vl flv3 on arta.gl_account_source = flv3.lookup_code and flv3.view_application_id = 222 and flv3.lookup_type = 'GL_ACCOUNT_SOURCE'
		 where 1 = 1
		   -- and arta.name in ('Cheque Refund','Cheque Refund via AP','Earned Discount')
		   -- and arta.name in ('Adjustment Reversal')
		   and arta.org_id = 123
		   -- and gcc.segment2 = '123456'
		   -- and arta.asset_tax_code like '%.%'
		   and 1 = 1
	  order by arta.name;
