/*
File Name:		ar-applications.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- AR RECEIVABLE APPLICATIONS
-- VIEW

*/

-- ##################################################################
-- AR RECEIVABLE APPLICATIONS
-- ##################################################################

		select araa.creation_date
			 , araa.amount_applied
			 , araa.gl_date 
			 , acra.receipt_number
			 , rcta.trx_number
			 , rbsa.name batch_source
			 , hca.account_number
			 , hca.account_name
		  from ar.ar_receivable_applications_all araa
	 left join ar.ar_cash_receipts_all acra on araa.cash_receipt_id = acra.cash_receipt_id
	 left join ar.ra_customer_trx_all rcta on araa.applied_customer_trx_id = rcta.customer_trx_id
	 left join ar.ra_batch_sources_all rbsa on rcta.batch_source_id = rbsa.batch_source_id and rcta.org_id = rbsa.org_id
	 left join ar.hz_cust_accounts hca on acra.pay_from_customer = hca.cust_account_id
		 where rcta.trx_number in ('123456')
		   -- and araa.cash_receipt_id = 123456
		   and araa.display = 'Y';

-- ##################################################################
-- VIEW
-- ##################################################################

select * from apps.ar_app_adj_v;
