/*
File Name: ar-system-settings.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- AR SYSTEM SETTINGS
-- ##################################################################

		select gsob.name set_of_books
			 , haou.name org
			 , gcc_gain.concatenated_segments code_comb_gain
			 , gcc_loss.concatenated_segments code_comb_loss
			 , gcc_taxt.concatenated_segments code_comb_tax_account
			 , gcc_rund.concatenated_segments code_comb_round_account
			 -- , aspa.*
		  from ar_system_parameters_all aspa
		  join hr_all_organization_units haou on aspa.org_id = haou.organization_id
		  join gl_sets_of_books gsob on aspa.set_of_books_id = gsob.set_of_books_id
		  join gl_code_combinations_kfv gcc_gain on gcc_gain.code_combination_id = aspa.code_combination_id_gain
		  join gl_code_combinations_kfv gcc_loss on gcc_loss.code_combination_id = aspa.code_combination_id_gain
		  join gl_code_combinations_kfv gcc_taxt on gcc_taxt.code_combination_id = aspa.code_combination_id_gain
		  join gl_code_combinations_kfv gcc_rund on gcc_rund.code_combination_id = aspa.code_combination_id_gain
		 where 1 = 1
		   and haou.name = 'MY_ORG'
		   and 1 = 1
	  order by aspa.last_update_date desc;
