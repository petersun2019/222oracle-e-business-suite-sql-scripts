/*
File Name:		pa-finances-against-revenues-and-invoices.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- FINANCES AGAINST REVENUES AND INVOICES
-- TROUBLESHOOTING UNEARNED REVENUE/UNBILLED RECEIVABLE AMOUNTS FOR A PROJECT (DOC ID 454159.1)

*/

-- ##################################################################
-- FINANCES AGAINST REVENUES AND INVOICES
-- ##################################################################

		select sum(ubr) ubr
			 , sum(uer) eur
			 , project_id pid
			 , segment1 project
		  from (select 'R' type
					  , pdra.draft_revenue_num seqnum
					  , pdra.unbilled_receivable_dr ubr
					  , pdra.unearned_revenue_cr uer
					  , to_char (pdra.program_update_date, 'YYYY/MM/DD HH24:MI:SS') pupd
					  , ppa.project_id
					  , ppa.segment1
				   from pa.pa_draft_revenues_all pdra
				   join pa.pa_projects_all ppa on pdra.project_id = ppa.project_id
				   join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
				  where 1 = 1
					and ppa.segment1 = 'P123456'
					and pps.project_system_status_code = 'APPROVED'
					and transfer_status_code || '' in ('A', 'T')
				  union
				 select 'I'
					  , pdia.draft_invoice_num
					  , pdia.unbilled_receivable_dr
					  , pdia.unearned_revenue_cr
					  , to_char (pdia.program_update_date, 'YYYY/MM/DD HH24:MI:SS') pupd
					  , ppa.project_id
					  , ppa.segment1
				   from pa.pa_draft_invoices_all pdia
				   join pa.pa_projects_all ppa on pdia.project_id = ppa.project_id
				   join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
				  where 1 = 1
				    and ppa.segment1 = 'P123456'
				    and transfer_status_code || '' in ('A', 'T')
				    and pps.project_system_status_code = 'APPROVED'
				    and nvl(write_off_flag, 'N') = 'N')
	  group by project_id
			 , segment1;

-- ##################################################################
-- TROUBLESHOOTING UNEARNED REVENUE/UNBILLED RECEIVABLE AMOUNTS FOR A PROJECT (DOC ID 454159.1)
-- ##################################################################

		select 'R' type
			 , draft_revenue_num seqnum
			 , unbilled_receivable_dr ubr
			 , unearned_revenue_cr uer
			 , to_char(program_update_date,'YYYY/MM/DD HH24:MI:SS') pupd
		  from pa.pa_draft_revenues_all
		 where project_id = 123456
		   and transfer_status_code||'' in ( 'A', 'T' )
		 union
		select 'I'
			 , draft_invoice_num
			 , unbilled_receivable_dr
			 , unearned_revenue_cr
			 , to_char(program_update_date,'YYYY/MM/DD HH24:MI:SS') pupd
		  from pa.pa_draft_invoices_all
		 where project_id = 123456
		   and transfer_status_code||'' in ( 'A', 'T' )
		   and nvl(write_off_flag,'N') = 'N'
	  order by 5 asc
			 , 2 asc;
