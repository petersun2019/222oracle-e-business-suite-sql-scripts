/*
File Name:		ar-receipt-methods.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- AR RECEIPT METHODS - BASIC
-- ##################################################################

select * from ar.ar_receipt_method_accounts_all order by creation_date desc;
select * from ar.ar_receipt_methods order by creation_date desc;
select * from ar.ar_receipt_classes where receipt_class_id = 123456;
