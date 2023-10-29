/*
File Name: sa-concurrent-program-incompatibilities.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- CONCURRENT PROGRAM INCOMPATIBILITIES
-- ##################################################################

		select fcpt1.user_concurrent_program_name prog
			 , fcpt2.user_concurrent_program_name prog_icomp
			 , fcps.creation_date
			 , fu.user_name
			 , fu.description
			 , fcps.running_type
			 , fcps.to_run_type
			 , fat.application_name
			 , fcps.incompatibility_type
			 , '###############'
			 , fcps.*
		  from fnd_concurrent_program_serial fcps
		  join fnd_concurrent_programs_tl fcpt1 on fcps.running_concurrent_program_id = fcpt1.concurrent_program_id and fcpt1.language = userenv('lang')
		  join fnd_concurrent_programs_tl fcpt2 on fcps.to_run_concurrent_program_id = fcpt2.concurrent_program_id and fcpt2.language = userenv('lang')
		  join fnd_application_tl fat on fat.application_id = fcps.running_application_id and fat.language = userenv('lang')
		  join fnd_user fu on fcps.created_by = fu.user_id
		 where 1 = 1
		   -- and fcps.creation_date > '08-sep-2018'
		   -- and fcpt1.user_concurrent_program_name = 'PRC: Generate Revenue Accounting Events'
		   -- and fcpt1.user_concurrent_program_name = fcpt2.user_concurrent_program_name
		   -- and fat.application_name = 'General Ledger'
		   and 1 = 1;
