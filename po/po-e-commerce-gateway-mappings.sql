/*
File Name: po-e-commerce-gateway-mappings.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ###################################################################
-- E-COMMERCE GATEWAY MAPPINGS
-- ###################################################################

		select fu.user_name
			 , fu.email_address
			 , exd.*
		  from ece_xref_data exd
		  join fnd_user fu on exd.created_by = fu.user_id
		 where 1 = 1
		   -- and exd.description like 'X%'
		   and 1 = 1
	  order by exd.creation_date desc;
