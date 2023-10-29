/*
File Name:		pa-expenditure-types.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- EXPENDITURE TYPES
-- ##################################################################

		select pet.expenditure_type
			 , pet.expenditure_category
			 , pet.revenue_category_code
			 , to_char(pet.start_date_active, 'DD-MON-YYYY') start_date
			 , to_char(pet.end_date_active, 'DD-MON-YYYY') end_date
			 , pet.description
			 , pet.creation_date created
			 , fu1.user_name || ' / ' || fu1.email_address created_by
			 , fu1.email_address created_by
			 , pet.last_update_date updated
			 , fu2.user_name || ' / ' || fu2.email_address updated_by
			 , fu2.email_address updated_by
			 , pet.attribute1
			 , pet.attribute2
		  from pa_expenditure_types pet
		  join fnd_user fu1 on pet.created_by = fu1.user_id
		  join fnd_user fu2 on pet.last_updated_by = fu2.user_id
		 where 1 = 1
		   -- and pet.attribute1 = 'T'
		   -- and pet.expenditure_type like 'Accruals%Prof%'
		   -- and pet.expenditure_type like 'Third%' -- third party recharges
		   and 1 = 1
	  order by pet.last_update_date desc;
