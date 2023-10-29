/*
File Name: gl-sla-sum-and-gl-sum.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- SUM FROM THE SLA TABLES
-- SUM FROM THE GL TABLES

TAKEN FROM:
SLA: A TECHNICAL PERSPECTIVE OF THE AP TO GL RECONCILIATION (DOC ID 605707.1)
*/

-- ##################################################################
-- SUM FROM THE SLA TABLES
-- ##################################################################

		select /*+ parallel(xal) parallel(xah) leading(xah) */
			   currency_code
			 , sum (nvl (accounted_cr, 0)) - sum (nvl (accounted_dr, 0)) diff
		  from xla.xla_ae_lines xal, xla.xla_ae_headers xah
		 where xal.accounting_class_code = 'LIABILITY'
		   and xal.code_combination_id = 1011
		   and xal.application_id = 200
		   and xal.ae_header_id = xah.ae_header_id
		   and xal.application_id = xah.application_id
		   and xah.ledger_id = 1
		   and xah.gl_transfer_status_code = 'Y'
		   and xah.accounting_entry_status_code = 'F'
		   and xah.balance_type_code = 'A'
		   and (xah.upg_batch_id is null or xah.upg_batch_id = -9999) -- will help ignore upgraded data
		   and xah.accounting_date between '01-MAY-2014' and '31-MAY-2014'
	  group by currency_code
	  order by currency_code;

-- ##################################################################
-- SUM FROM THE GL TABLES
-- ##################################################################

		select currency_code
			 , sum (nvl (l.accounted_cr, 0)) - sum (nvl (l.accounted_dr, 0)) diff
		  from gl.gl_je_headers h, gl.gl_je_lines l, apps.gl_code_combinations_kfv k
		 where l.ledger_id = 1
		   and l.code_combination_id = k.code_combination_id
		   and h.je_header_id = l.je_header_id
		   and h.actual_flag = 'A'
		   and h.je_from_sla_flag = 'Y' -- will help ingore upgraded data
		   and l.code_combination_id = 1011
		   and h.je_source = 'Payables'
		   and h.period_name in ('MAY-2014')
	  group by currency_code
	  order by currency_code;
