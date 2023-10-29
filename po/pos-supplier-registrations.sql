/*
File Name:		pos-supplier-registrations.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- SUPPLIER REGISTRATIONS
-- ##################################################################

		select creation_date
			 , supplier_name
			 , 'https://example.com/OA_HTML/jsp/pos/suppreg/SupplierRegister.jsp?regkey=' || reg_key url
		  from pos.pos_supplier_registrations
		 where registration_status = 'DRAFT'
		   -- and supplier_name like 'Cheese%'
	  order by creation_date desc;
