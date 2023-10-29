/*
File Name:		hr-legislations.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- HR LEGISLATIONS
-- ##################################################################

		select decode(hli.legislation_code
			 , null,'Global'
			 , hli.legislation_code) legcode
			 , hli.application_short_name asn
			 , hli.status status, last_update_date
		  from hr_legislation_installations hli
		 where 1 = 1
		   -- and hli.status = 'I'
		   and 1 = 1;
