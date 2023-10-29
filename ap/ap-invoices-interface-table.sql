/*
File Name:		ap-invoices-interface-table.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- TABLE DUMPS
-- REJECTED INTERFACE RECORDS
-- COUNTING
-- REJECTIONS BY PARENT TABLE
-- COUNT BY STATUS, OPERATING UNIT AND SOURCE
-- INTERFACE REJECTION DETAILS
-- INVOICE INTERFACE DETAILS - REJECTED
-- SOURCE PARAMETER FROM "PAYABLES OPEN INTERFACE IMPORT" JOB
-- PARAMETER: AP_SRS_OPEN_INTERFACE_SOURCE

*/

-- ##############################################################
-- TABLE DUMPS
-- ##############################################################

select * from ap.ap_interface_rejections;
select * from ap.ap_interface_rejections where reject_lookup_code = 'ZX_IMP_TAX_RATE_AMT_MISMATCH';
select * from ap.ap_invoices_interface;
select * from ap.ap_invoices_interface where vendor_id = 123456 and trunc(invoice_date) = '06-AUG-2017';
select * from ap.ap_invoices_interface where invoice_num = 'INV123456';
select * from ap.ap_invoice_lines_interface where creation_date > '01-NOV-2021';
select * from ap.ap_invoice_lines_interface where invoice_id = 123456;
select * from fnd_lookup_values_vl where lookup_code = 'ZX_IMP_TAX_RATE_AMT_MISMATCH';
select * from fnd_lookup_values_vl where lookup_type = 'REJECT_CODE';

-- ##############################################################
-- REJECTED INTERFACE RECORDS
-- ##############################################################

		select * from ap_invoices_interface
		 where status = 'REJECTED'
	  order by creation_date desc;

-- ##############################################################
-- COUNTING
-- ##############################################################

-- REJECTIONS BY PARENT TABLE

		select parent_table
			 , count(*)
			 , min(creation_date)
			 , max(creation_date)
		  from ap_interface_rejections 
	  group by parent_table;

-- COUNT BY STATUS, OPERATING UNIT AND SOURCE

		select status
			 , operating_unit
			 , source
			 , count(*) 
			 , max(creation_date)
			 , min(creation_date)
		  from ap_invoices_interface 
	  group by status
			 , operating_unit
			 , source
	  order by operating_unit
			 , source
			 , status;

-- ##############################################################
-- INTERFACE REJECTION DETAILS
-- ##############################################################

		select to_char(aii.invoice_date, 'DD-MON-YYYY') invoice_date
			 , aii.invoice_amount inv_amt
			 , aii.invoice_currency_code curr
			 , aii.creation_date
			 , aii.description
			 , aii.status
			 , aii.request_id
			 , '################'
			 , air.*
		  from ap_interface_rejections air
		  join ap_invoices_interface aii on air.parent_id = aii.invoice_id and air.parent_table = 'AP_INVOICES_INTERFACE' -- header rejections
		  -- join ap_invoices_interface aii on air.parent_id = aii.invoice_id and air.parent_table = 'AP_INVOICE_LINES_INTERFACE' -- line rejections
		 where 1 = 1;

-- ##############################################################
-- INVOICE INTERFACE DETAILS - REJECTED
-- ##############################################################

		select distinct aif.invoice_id
			 , aif.invoice_num
			 , air.reject_lookup_code
			 , pv.vendor_name
			 , to_char(aif.invoice_date, 'DD-MON-YYYY') invoice_date
			 , aif.invoice_amount inv_amt
			 , aif.invoice_currency_code curr
			 , aif.description
			 , aif.status
			 , aif.request_id
			 , aili.line_number
			 , aili.line_type_lookup_code line_type
			 , aili.amount line_amt
			 , aili.tax_code
			 , aili.dist_code_concatenated
			 , aili.creation_date
			 , hou.short_code || ' (' || organization_id || ')' ou
		  from ap_invoices_interface aif
		  join ap_invoice_lines_interface aili ON aif.invoice_id = aili.invoice_id
		  join hr_operating_units hou on aili.org_id = hou.organization_id
	 left join ap_suppliers pv on aif.vendor_id = pv.vendor_id
	 -- left join apps.ap_interface_rejections air on air.parent_id = aili.invoice_line_id AND air.parent_table = 'AP_INVOICE_LINES_INTERFACE' -- line rejections
		  join ap_interface_rejections air on air.parent_id = aif.invoice_id AND air.parent_table = 'AP_INVOICES_INTERFACE' -- header rejections
		 where 1 = 1
		   -- and air.reject_lookup_code = 'ZX_IMP_TAX_RATE_AMT_MISMATCH'
		   -- and aili.creation_date > '01-NOV-2021'
		   -- and aif.creation_date > SYSDATE - 5
		   -- and aif.vendor_id = 123456
		   -- and aif.invoice_id = 123456
		   and aif.invoice_num in ('INV123456')
		   -- and aili.po_number LIKE 'E%'
		   -- and aif.invoice_date > '01-AUG-2017'
		   and 1 = 1
	  order by aili.creation_date;

-- ##############################################################
-- SOURCE PARAMETER FROM "PAYABLES OPEN INTERFACE IMPORT" JOB
-- ##############################################################

-- PARAMETER: AP_SRS_OPEN_INTERFACE_SOURCE

		select DISPLAYED_FIELD
			 , DESCRIPTION
			 , LOOKUP_CODE
		  from AP_LOOKUP_CODES
		 where lookup_type = 'SOURCE'
		   and lookup_code NOT IN ('XPENSEXPRESS' , 'SELFSERVICE')
		   and enabled_flag = 'Y'
	  order by displayed_field;
