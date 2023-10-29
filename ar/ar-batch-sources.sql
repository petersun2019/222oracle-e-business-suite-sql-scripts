/*
File Name:		ar-batch-sources.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- AR BATCH SOURCES
-- ##################################################################

		select rbsa.batch_source_id
			 , rbsa.creation_date
			 , fu.description created_by
			 , rbsa.name
			 , rbsa.org_id
			 , rbsa.description
			 , rbsa.status
			 , rbsa.last_batch_num
			 , rbsa.default_inv_trx_type
			 , rbsa.*
			 -- , (select count(*) from ar.ra_customer_trx_all rcta where rcta.batch_source_id = rbsa.batch_source_id and rcta.org_id = rbsa.org_id) trx_ct
			 -- , (select max(creation_date) from ar.ra_customer_trx_all rcta where rcta.batch_source_id = rbsa.batch_source_id and rcta.org_id = rbsa.org_id) last_trx_raised
		  from ar.ra_batch_sources_all rbsa
		  join applsys.fnd_user fu on rbsa.created_by = fu.user_id
		 where rbsa.status = 'A'
		   and rbsa.org_id = 123;
