/*
File Name: ar-transaction-types.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- AR TRANSACTION TYPES
-- ##################################################################

		select rctta.cust_trx_type_id
			 , rctta.name
			 , haou.name linked_hr_org
			 , rctta.description
			 , al2.meaning class
			 , decode(rctta.creation_sign, 'A', 'Any', 'N', 'Negative', 'P', 'Positive') creation_sign
			 , al1.meaning default_trx_status
			 , rctta.default_printing_option
			 , to_char(rctta.start_date, 'DD-MON-YYYY') start_date
			 , to_char(rctta.end_date, 'DD-MON-YYYY') end_date
			 , rctta.creation_date created
			 , fu.description created_by
			 , rctta_cm.name credit_memo_type
			 , rctta.accounting_affect_flag open_receivable
			 , rctta.adj_post_to_gl allow_adjustment_posting
			 , rctta.post_to_gl
			 , rctta.allow_freight_flag allow_freight
			 , rctta.natural_application_only_flag natural_application_only
			 , rctta.exclude_from_late_charges exclude_from_late_charges
			 , rctta.allow_overapplication_flag allow_over_application
			 , rctta.attribute1 document_title
			 , rctta.end_date
			 , '#############'
			 , gcc_rec.concatenated_segments receivable_account
			 , gcc_rev.concatenated_segments revenue_account
			 , gcc_unbilled.concatenated_segments unbilled_account
			 , gcc_tax.concatenated_segments tax_account
			 , gcc_freight.concatenated_segments freight_account
			 , gcc_clearing.concatenated_segments clearing_account
			 , gcc_unearned.concatenated_segments unearned_account
			 , rctta.end_date
			 , '##############'
			 , rctta.*
		  from ar.ra_cust_trx_types_all rctta
	 left join hr.hr_all_organization_units haou on rctta.name = haou.name
		  join applsys.fnd_user fu on rctta.created_by = fu.user_id
	 left join apps.ar_lookups al1 on rctta.default_status = al1.lookup_code and al1.lookup_type = 'INVOICE_TRX_STATUS'
	 left join apps.ar_lookups al2 on rctta.type = al2.lookup_code and al2.lookup_type = 'INV/CM'
	 left join ar.ra_cust_trx_types_all rctta_cm on rctta.credit_memo_type_id = rctta_cm.cust_trx_type_id
	 left join apps.gl_code_combinations_kfv gcc_rec on gcc_rec.code_combination_id = rctta.gl_id_rec
	 left join apps.gl_code_combinations_kfv gcc_rev on gcc_rev.code_combination_id = rctta.gl_id_rev
	 left join apps.gl_code_combinations_kfv gcc_unbilled on gcc_unbilled.code_combination_id = rctta.gl_id_unbilled
	 left join apps.gl_code_combinations_kfv gcc_tax on gcc_tax.code_combination_id = rctta.gl_id_tax
	 left join apps.gl_code_combinations_kfv gcc_freight on gcc_freight.code_combination_id = rctta.gl_id_freight
	 left join apps.gl_code_combinations_kfv gcc_clearing on gcc_clearing.code_combination_id = rctta.gl_id_clearing
	 left join apps.gl_code_combinations_kfv gcc_unearned on gcc_unearned.code_combination_id = rctta.gl_id_unearned
		 where 1 = 1
		   -- and rctta.name in ('XX','Credit Memo')
		   -- and nvl(rctta.end_date, SYSDATE + 1) > SYSDATE
		   and rctta.creation_date > '01-AUG-2020'
		   -- and rctta.last_update_date > '12-AUG-2016'
		   -- and rctta.cust_trx_type_id = 123456
		   -- and rctta.cust_trx_type_id in (123456)
		   -- and rctta.status != 'A'
		   and 1 = 1
	  order by rctta.name;
