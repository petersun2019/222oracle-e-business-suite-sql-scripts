/*
File Name:		hr-addresses.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- HR RECORDS - ADDRESSES
-- ##################################################################

		select papf.person_id
			 , papf.employee_number
			 , papf.full_name
			 , pa.address_id
			 , pa.creation_date address_created
			 , pa.address_line1
			 , pa.address_line2
			 , pa.address_line3
			 , pa.town_or_city
			 , pa.postal_code
		  from per_all_people_f papf
	 left join per_addresses pa on papf.person_id = pa.person_id
		 where 1 = 1
		   and sysdate between papf.effective_start_date and papf.effective_end_date
		   -- and lower(papf.full_name) like 'duck%'
		   and papf.full_name in ('Duck, Donald')
		   and 1 = 1;
