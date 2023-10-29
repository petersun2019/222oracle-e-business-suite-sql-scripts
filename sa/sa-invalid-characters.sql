/*
File Name:		sa-invalid-characters.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- INVALID CHARACTERS
-- ##################################################################

		select regexp_instr(city,'[^[:print:]]') as string_position
			 , length(city)
			 , address_line1
			 , address_line2
			 , address_line3
			 , city
			 , dump(city, 1016)
			 , asia.* 
		  from ap.ap_selected_invoices_all asia
		 where checkrun_name = 'CHECKRUN1234'
		   and 1 = 1
		   -- and vendor_id = 919921
		   -- and regexp_instr(address_line1,'[^[:print:]]') > 0
		   -- and regexp_instr(address_line2,'[^[:print:]]') > 0
		   -- and regexp_instr(address_line3,'[^[:print:]]') > 0
		   -- and regexp_instr(address_line4,'[^[:print:]]') > 0
		   and regexp_instr(city,'[^[:print:]]') > 0
		   -- and regexp_instr(state,'[^[:print:]]') > 0
		   -- and regexp_instr(zip,'[^[:print:]]') > 0
		   and 1 = 1;
