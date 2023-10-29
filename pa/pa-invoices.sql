/*
File Name:		pa-invoices.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- PA INVOICES - TABLE DUMPS
-- DRAFT INVOICES
-- DRAFT INVOICES AND INVOICE LINES
-- DRAFT INVOICES AND INVOICE ITEMS AND EVENTS - DETAILED VIEW
-- DRAFT INVOICES AND INVOICE ITEMS - SUMMARY VIEW
-- EXPENDITURE ITEMS LINKED TO THE INVOICE
-- REVENUE DISTRIBUTION LINES LINKED TO THE INVOICE
-- COUNTING

*/

-- ###################################################################
-- PA INVOICES - TABLE DUMPS
-- ###################################################################

select * from pa_draft_invoices_all where project_id = 123456 order by creation_date desc;
select * from pa_draft_invoice_items where project_id = 123456 order by creation_date desc;
select * from pa_draft_inv_line_details_v where project_id = 123456 order by creation_date desc;

-- ###################################################################
-- DRAFT INVOICES
-- ###################################################################

		select ppa.segment1
			 , haou.name hr_org
			 , fcr.requested_by
			 , ppa.project_id
			 , (select lk3.meaning from apps.pa_lookups lk3 where lk3.lookup_type = 'INVOICE_CLASS' and lk3.lookup_code = decode (pdia.canceled_flag,'Y', 'CANCEL',decode (pdia.write_off_flag,'Y', 'WRITE_OFF', decode (pdia.concession_flag, 'Y', 'CONCESSION', decode (nvl (pdia.draft_invoice_num_credited, 0), 0, 'INVOICE', 'CREDIT_MEMO')))) and lk3.enabled_flag = 'Y' and trunc (sysdate) between trunc ( nvl (lk3.start_date_active, sysdate - 1)) and trunc ( nvl (lk3.end_date_active, sysdate))) invoice_class
			 , pdia.draft_invoice_num inv
			 , pdia.creation_date
			 , pdia.last_update_date
			 , pdia.released_by_person_id
			 , pdia.org_id
			 , pdia.pa_date
			 , pdia.gl_date
			 , pdia.bill_through_date
			 , pdia.released_date
			 , pdia.request_id
			 , pdia.approved_date
			 , pdia.ra_invoice_number ar_trx
			 , rcta.trx_number
			 , rctta.name type
			 , pdia.draft_invoice_num_credited
			 , ppa.distribution_rule distrib_rule
			 , pdia.request_id
			 , trx_status.meaning trx_status
			 , pdia.transfer_status_code
			 , pdia.unearned_revenue_cr
			 , pdia.unbilled_receivable_dr
			 , hca.account_number act_no
			 , hp.party_name
			 , hca.account_name
			 , fu.user_name cr_by
			 , pdia.transfer_rejection_reason reject_reason
			 , paa.agreement_num
			 , hp.party_name
			 , hca.account_number
			 , pdia.last_updated_by
			 , pdia.credit_memo_reason_code
			 , al.meaning
			 -- , '###########################'
			 -- , pdia.*
		  from pa.pa_draft_invoices_all pdia
		  join applsys.fnd_user fu on pdia.last_updated_by = fu.user_id
		  join pa.pa_projects_all ppa on pdia.project_id = ppa.project_id
		  join ar.hz_cust_accounts hca on pdia.customer_id = hca.cust_account_id
		  join ar.hz_parties hp on hp.party_id = hca.party_id
		  join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
	 left join pa.pa_agreements_all paa on paa.agreement_id = pdia.agreement_id
	 left join ar.hz_cust_accounts hca on paa.customer_id = hca.cust_account_id
	 left join ar.hz_parties hp on hp.party_id = hca.party_id
	 left join apps.ar_lookups al on al.lookup_code = pdia.credit_memo_reason_code and al.lookup_type = 'CREDIT_MEMO_REASON'
	 left join ar.ra_customer_trx_all rcta on rcta.trx_number = pdia.ra_invoice_number
	 left join ar.ra_cust_trx_types_all rctta on rcta.cust_trx_type_id = rctta.cust_trx_type_id and rcta.org_id = rctta.org_id
	 left join (select lookup_code, meaning from apps.pa_lookups where lookup_type = 'TRANSFER STATUS') trx_status on pdia.transfer_status_code = trx_status.lookup_code
	 left join applsys.fnd_concurrent_requests fcr on fcr.request_id = pdia.request_id
		 where 1 = 1
		   and ppa.segment1 = 'P123456'
		   -- and ppa.project_id in (P123456,P123457)
		   -- and ppa.project_id in (P123456)
		   -- and pdia.ra_invoice_number = '987654321'
		   -- and pdia.creation_date between '13-MAR-2020' and '20-MAR-2020'
		   and pdia.creation_date >= '26-JUL-2022'
		   -- and pdia.released_date is null
		   -- and pdia.ra_invoice_number is not null
		   -- and rcta.customer_trx_id = 123456
		   -- and pdia.draft_invoice_num_credited is not null
		   -- and pdia.creation_date > sysdate - 2
		   -- and pdia.bill_through_date <> pdia.gl_date
		   -- and fu.user_name = 'CHEESE_USER'
		   -- and pdia.credit_memo_reason_code is not null
		   -- and pdia.draft_invoice_num in (16)
		   -- and pdia.transfer_status_code = 'X'
		   -- and pdia.transfer_status_code <> 'A'
		   -- and pdia.transfer_status_code = 'R' -- rejected
	  order by pdia.creation_date desc;

-- ##################################################################
-- DRAFT INVOICES AND INVOICE LINES
-- ##################################################################

		select ppa.segment1
			 , pdia.draft_invoice_num inv
			 , ppa.project_id
			 , fu.email_address cr_by
			 , pt.task_number task
			 , pdii.event_num
			 , pdii.amount
			 , '############ Inv Headers ##############'
			 , (select lk3.meaning from apps.pa_lookups lk3 where lk3.lookup_type = 'INVOICE_CLASS' and lk3.lookup_code = decode (pdia.canceled_flag,'Y', 'CANCEL',decode (pdia.write_off_flag,'Y', 'WRITE_OFF', decode (pdia.concession_flag, 'Y', 'CONCESSION', decode (nvl (pdia.draft_invoice_num_credited, 0), 0, 'INVOICE', 'CREDIT_MEMO')))) and lk3.enabled_flag = 'Y' and trunc (sysdate) between trunc ( nvl (lk3.start_date_active, sysdate - 1)) and trunc ( nvl (lk3.end_date_active, sysdate))) invoice_class
			 , to_char(pdia.pa_date, 'DD-MON-YYYY') pa_date
			 , to_char(pdia.gl_date, 'DD-MON-YYYY') gl_date
			 , to_char(pdia.bill_through_date, 'DD-MON-YYYY') bill_through_date
			 , to_char(pdia.released_date, 'DD-MON-YYYY') released_date
			 , pdia.ra_invoice_number ar_inv
			 , pdia.draft_invoice_num inv_num
			 , pdia.creation_date
			 , ppa.distribution_rule distrib_rule
			 , pdia.request_id
			 , pdia.transfer_status_code status
			 , '########### Inv Lines ###############'
			 , pdii.*
		  from pa.pa_draft_invoices_all pdia
		  join pa.pa_draft_invoice_items pdii on pdia.draft_invoice_num = pdii.draft_invoice_num and pdia.project_id = pdii.project_id
		  join pa.pa_projects_all ppa on pdia.project_id = ppa.project_id 
		  join applsys.fnd_user fu on pdia.created_by = fu.user_id
		  join pa.pa_tasks pt on pdii.task_id = pt.task_id
		 where 1 = 1
		   and ppa.segment1 = 'P123456'
		   -- and pdii.event_num > 94
		   -- and pdii.creation_date > '14-JUN-2021'
		   and pdia.draft_invoice_num = 16
		   -- and pdii.invoice_line_type = 'STANDARD'
		   and 1 = 1
	  order by ppa.segment1
			 , pdia.draft_invoice_num
			 , pdii.line_num;

-- ##################################################################
-- DRAFT INVOICES AND INVOICE ITEMS AND EVENTS - DETAILED VIEW
-- ###################################################################

/*
INVOICES CAN BE GENERATED VIA DIFFERENT ROUTES.
FOR EVENT/EVENT PROJECTS, THEY ARE TRIGGERED VIA THE CREATION OF EVENTS
FOR WORK/WORK PROJECTS, THEY ARE USUALLY TRIGGERED VIA THE CREATION OF "WORK" E.G. JOURNALS, WEB ADI, AP INVOICES ETC.
SOMETIMES PEOPLE RAISE MANUAL EVENTS FOR WORK/WORK PROJECTS, WHICH CAN THEN ALSO TRIGGER THE CREATION OF PA INVOICES
*/

		select ppa.segment1
			 , pdia.draft_invoice_num
			 , ppa.project_id
			 , fu.description cr_by
			 , '############ Inv Headers ##############'
			 , pdia.unearned_revenue_cr
			 , (select lk3.meaning from apps.pa_lookups lk3 where lk3.lookup_type = 'INVOICE_CLASS' and lk3.lookup_code = decode (pdia.canceled_flag,'Y', 'CANCEL',decode (pdia.write_off_flag,'Y', 'WRITE_OFF', decode (pdia.concession_flag, 'Y', 'CONCESSION', decode (nvl (pdia.draft_invoice_num_credited, 0), 0, 'INVOICE', 'CREDIT_MEMO')))) and lk3.enabled_flag = 'Y' and trunc (sysdate) between trunc ( nvl (lk3.start_date_active, sysdate - 1)) and trunc ( nvl (lk3.end_date_active, sysdate))) invoice_class
			 , pdia.pa_date
			 , pdia.gl_date
			 , pdia.bill_through_date
			 , pdia.released_date
			 , pdia.ra_invoice_number ar_inv
			 , pdia.draft_invoice_num inv_num
			 , pdia.draft_invoice_num_credited
			 , pdia.creation_date
			 , pdia.last_update_date
			 , ppa.distribution_rule distrib_rule
			 , pdia.request_id
			 , pdia.transfer_status_code status
			 , pdia.credit_memo_reason_code
			 , '########### Inv Lines ###############'
			 , pdii.line_num
			 , pdii.inv_amount
			 , pdii.inv_exchange_rate
			 , pdii.amount
			 , pdii.text
			 , pdii.invoice_line_type
			 , pt.task_number
			 , '########## Events ################'
			 , pe.event_num
			 , pe.event_type
			 , pe.description
			 , pe.bill_amount
			 , pe.revenue_amount
			 , pe.event_id
			 , pe.billed_flag
			 , '########## Revenue Lines ###############'
			 , pcrdla.expenditure_item_id
			 , pcrdla.line_num
			 , '########## Expenditure Items ###############'
			 , peia.transaction_source
			 , peia.raw_cost
			 , '########## AR Transaction ###############'
			 , apsa.class trx_type
			 , rcta.creation_date
			 , rcta.trx_number
			 -- , '#################@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
			 -- , pcrdla.*
		  from pa.pa_draft_invoices_all pdia
		  join pa.pa_draft_invoice_items pdii on pdia.draft_invoice_num = pdii.draft_invoice_num and pdia.project_id = pdii.project_id
		  join pa.pa_projects_all ppa on pdia.project_id = ppa.project_id 
		  join applsys.fnd_user fu on pdia.created_by = fu.user_id
		  join pa.pa_tasks pt on pdii.task_id = pt.task_id
	 left join pa.pa_cust_rev_dist_lines_all pcrdla on pcrdla.project_id = ppa.project_id and pcrdla.draft_invoice_num = pdia.draft_invoice_num and pcrdla.draft_invoice_item_line_num = pdii.line_num
	 left join pa.pa_events pe on pdii.event_num = pe.event_num and pe.project_id = pdii.project_id and pe.task_id = pdii.task_id
	 left join pa.pa_expenditure_items_all peia on pcrdla.expenditure_item_id = peia.expenditure_item_id
	 left join ar.ra_customer_trx_all rcta on pdia.ra_invoice_number = rcta.trx_number
	 left join ar.ar_payment_schedules_all apsa on rcta.customer_trx_id = apsa.customer_trx_id
		 where 1 = 1
		   and ppa.segment1 = 'P123456'
		   and pdia.draft_invoice_num = 20
		   -- and peia.expenditure_item_id = 17323280
		   and pdii.line_num = 7
		   -- and pdii.line_num = 
		   -- and pdia.draft_invoice_num_credited is not null
		   -- and pdia.draft_invoice_num = 48
		   -- and pdia.creation_date > sysdate - 366
		   -- and pdia.project_id = 123456
		   and 1 = 1
	  order by pdia.creation_date desc;

-- ##################################################################
-- DRAFT INVOICES AND INVOICE ITEMS - SUMMARY VIEW
-- ###################################################################

		select ppa.segment1
			 , pdia.draft_invoice_num
			 , ppa.project_id
			 , fu.description cr_by
			 , pdia.unearned_revenue_cr
			 , pdia.pa_date
			 , pdia.gl_date
			 , pdia.bill_through_date
			 , pdia.released_date
			 , pdia.ra_invoice_number ar_inv
			 , pdia.draft_invoice_num inv_num
			 , pdia.draft_invoice_num_credited
			 , pdia.creation_date
			 , pdia.last_update_date
			 , ppa.distribution_rule distrib_rule
			 , pdia.request_id
			 , pdia.transfer_status_code status
			 , sum(pdii.amount) amount
			 , pt.task_number
			 , pe.event_num
			 , pe.event_type
			 , pe.description event_description
			 , pe.bill_amount
			 , pe.revenue_amount
			 , pe.event_id
			 , pe.billed_flag
			 , case when peia.expenditure_item_id is not null then 'Y' end exp_item
			 , sum(peia.raw_cost) raw_cost_total
			 , apsa.class trx_type
			 , rcta.creation_date
		  from pa.pa_draft_invoices_all pdia
		  join pa.pa_draft_invoice_items pdii on pdia.draft_invoice_num = pdii.draft_invoice_num and pdia.project_id = pdii.project_id
		  join pa.pa_projects_all ppa on pdia.project_id = ppa.project_id 
		  join applsys.fnd_user fu on pdia.created_by = fu.user_id
		  join pa.pa_tasks pt on pdii.task_id = pt.task_id
	 left join pa.pa_cust_rev_dist_lines_all pcrdla on pcrdla.project_id = ppa.project_id and pcrdla.draft_invoice_num = pdia.draft_invoice_num and pcrdla.draft_invoice_item_line_num = pdii.line_num
	 left join pa.pa_events pe on pdii.event_num = pe.event_num and pe.project_id = pdii.project_id and pe.task_id = pdii.task_id
	 left join pa.pa_expenditure_items_all peia on pcrdla.expenditure_item_id = peia.expenditure_item_id
	 left join ar.ra_customer_trx_all rcta on pdia.ra_invoice_number = rcta.trx_number
	 left join ar.ar_payment_schedules_all apsa on rcta.customer_trx_id = apsa.customer_trx_id
		 where 1 = 1
		   and ppa.segment1 = 'P123456'
		   and pdia.draft_invoice_num = 8
		   -- and pdia.creation_date > '10-AUG-2014'
		   -- and pdia.project_id = 102635
		   and 1 = 1
	  group by ppa.segment1
			 , pdia.draft_invoice_num
			 , ppa.project_id
			 , fu.description
			 , pdia.unearned_revenue_cr
			 , pdia.pa_date
			 , pdia.gl_date
			 , pdia.bill_through_date
			 , pdia.released_date
			 , pdia.ra_invoice_number
			 , pdia.draft_invoice_num
			 , pdia.draft_invoice_num_credited
			 , pdia.creation_date
			 , pdia.last_update_date
			 , ppa.distribution_rule
			 , pdia.request_id
			 , pdia.transfer_status_code
			 , pt.task_number
			 , pe.event_num
			 , pe.event_type
			 , pe.description
			 , pe.bill_amount
			 , pe.revenue_amount
			 , pe.event_id
			 , pe.billed_flag
			 , case when peia.expenditure_item_id is not null then 'Y' end
			 , apsa.class
			 , rcta.creation_date
	  order by pdia.creation_date desc;

-- ###################################################################
-- EXPENDITURE ITEMS LINKED TO THE INVOICE
-- ###################################################################

		select e.*
		  from pa.pa_expenditure_items_all e
		 where e.expenditure_item_id in
	   (select d.expenditure_item_id
		  from pa.pa_cust_rev_dist_lines_all d
		  join pa.pa_projects_all ppa on d.project_id = ppa.project_id
		 where ppa.segment1 = 'P123456' and d.draft_invoice_num = 20)
	  order by e.expenditure_item_id;

-- ###################################################################
-- REVENUE DISTRIBUTION LINES LINKED TO THE INVOICE
-- ###################################################################

		select d.*
		  from pa.pa_cust_rev_dist_lines_all d
		  join pa.pa_projects_all ppa on d.project_id = ppa.project_id
		 where ppa.segment1 = 'P123456' 
		   and d.draft_invoice_num = 20
		   and d.draft_invoice_item_line_num = 7;

-- ##################################################################
-- COUNTING
-- ###################################################################

		select ppa.segment1
			 , pdia.draft_invoice_num
			 , ppa.project_id
			 , fu.description cr_by
			 , pdii.line_num
			 , pdii.invoice_line_type
			 , pt.task_number
			 , count(*) ct
		  from pa.pa_draft_invoices_all pdia
		  join pa.pa_draft_invoice_items pdii on pdia.draft_invoice_num = pdii.draft_invoice_num and pdia.project_id = pdii.project_id
		  join pa.pa_projects_all ppa on pdia.project_id = ppa.project_id 
		  join applsys.fnd_user fu on pdia.created_by = fu.user_id
		  join pa.pa_tasks pt on pdii.task_id = pt.task_id
	 left join pa.pa_cust_rev_dist_lines_all pcrdla on pcrdla.project_id = ppa.project_id and pcrdla.draft_invoice_num = pdia.draft_invoice_num and pcrdla.draft_invoice_item_line_num = pdii.line_num
		 where 1 = 1
		   and ppa.segment1 = 'P123456'
		   and pdia.draft_invoice_num = 5
		   and 1 = 1
	  group by ppa.segment1
			 , pdia.draft_invoice_num
			 , ppa.project_id
			 , fu.description
			 , pdii.line_num
			 , pdii.invoice_line_type
			 , pt.task_number;
