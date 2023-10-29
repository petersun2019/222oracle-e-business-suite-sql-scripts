/*
File Name: sa-iproc-favourite-charge-accounts.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- IPROC FAV CHARGE ACCOUNTS
-- ##################################################################

		select pfca.creation_date fav_added
			 , fu.user_name
			 , frt.responsibility_name
			 , pfca.charge_account_id
			 , gcc.segment1
			 , gcc.segment2
			 , gcc.segment3
			 , gcc.segment4
			 , gcc.segment5
		  from applsys.fnd_user fu
		  join icx.por_fav_charge_accounts pfca on fu.employee_id = pfca.employee_id
		  join applsys.fnd_responsibility_tl frt on pfca.responsibility_id = frt.responsibility_id
		  join gl.gl_code_combinations gcc on gcc.code_combination_id = pfca.charge_account_id
		 where pfca.creation_date > '01-JAN-2015'
	  order by pfca.creation_date desc;
