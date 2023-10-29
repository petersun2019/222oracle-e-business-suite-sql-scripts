/*
File Name: pa-bc-packets.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- PA BALANCES - TABLE DUMPS
-- PA BALANCES - TOP LEVEL NOT LINKED TO REQ OR PO
-- PA BALANCES - REQUISITION DETAILS
-- PA BALANCES - REQUISITIONS - SUMMARY BY REQUISITION, PROJECT AND TASK
-- PA BALANCES - REQUISITIONS - SUMMARY BY PROJECT AND TASK
-- PA BALANCES - PURCHASE ORDERS
-- PA BALANCES - AP INVOICES

*/

-- ##################################################################
-- PA BALANCES - TABLE DUMPS
-- ##################################################################

/*
WHEN YOU GO TO PROJECTS > EXPENDITURES > TRANSACTION FUNDS CHECK RESULTS,
YOU CAN CHECK IF A PROJECT PASSED FUNDS CHECKS FOR E.G. A REQ OR PO.
THE DATA IS STORED IN THE PA_BC_PACKETS TABLE
*/

select * from pa.pa_bc_packets where project_id = 123456;
select * from pa_bc_packets where document_distribution_id = 417394 and creation_date > '30-may-2019';

/*
WHEN ORACLE TRIES A FUNDS CHECK AGAINST A PROJECT, DATA IS ENTERED INTO PA_BC_PACKETS
THE SQL BELOW SHOWS THE RESULTS OF THE FUNDS CHECK PROCESS AGAINST VARIOUS DIFFERENT LEVELS
THIS CAN BE USEFUL TO SEE WHERE A BUDGET SHORTFALL IS, IF SOMETHING DOES NOT PASS FUNDS CHECK
*/

-- ##################################################################
-- PA BALANCES - TOP LEVEL NOT LINKED TO REQ OR PO
-- ##################################################################

		select pbp.packet_id
			 , pbp.creation_date packet_created
			 , pbp.created_by
			 , pbp.bc_packet_id
			 , pbp.project_id
			 , ppa.segment1 proj
			 , pt.task_number
			 , pbp.expenditure_type
			 , pbp.je_source_name source
			 , pbp.je_category_name category
			 , '(' || pbp.status_code || ') ' || flv_status.meaning status
			 , flv_doc.meaning doc_type
			 , pbp.document_type doc
			 , pbp.document_header_id
			 , pbp.balance_posted_flag
			 , pbp.actual_flag
			 , to_char(pbp.expenditure_item_date, 'DD-MON-YYYY') exp_item_date
			 , to_char(pbp.gl_date, 'DD-MON-YYYY') gl_date
			 , to_char(pbp.pa_date, 'DD-MON-YYYY') pa_date
			 , pbp.period_name period
			 , '########### CR DR #############'
			 , pbp.entered_dr
			 , pbp.accounted_dr
			 , pbp.entered_cr
			 , pbp.accounted_cr
			 , '########### RESULTS #############'
			 , '(' || flv_result.lookup_code || ') ' || flv_result.meaning result
			 , '(' || flv_result_task.lookup_code || ') ' || flv_result_task.meaning task_result_code
			 , '(' || flv_result_res_grp.lookup_code || ') ' || flv_result_res_grp.meaning res_grp_result_code
			 , '(' || flv_result_res.lookup_code || ') ' || flv_result_res.meaning res_result_code
			 , '(' || flv_result_top_task.lookup_code || ') ' || flv_result_top_task.meaning top_task_result_code
			 , '(' || flv_result_project.lookup_code || ') ' || flv_result_project.meaning project_result_code
			 , '########### PROJECT #############'
			 , pbp.project_budget_posted project_budget
			 , pbp.project_enc_posted project_commitment
			 , pbp.project_actual_posted project_actual
			 , '########### TASK #############'
			 , pbp.task_budget_posted task_budget
			 , pbp.task_enc_posted task_commitment
			 , pbp.task_actual_posted task_actual
			 , '########### TOP TASK #############'
			 , pbp.top_task_budget_posted top_task_budget
			 , pbp.top_task_enc_posted top_task_commitment
			 , pbp.top_task_actual_posted top_task_actual
			 , '########### RESOURCE GROUP #############'
			 , pbp.res_grp_budget_posted resource_grp_budget
			 , pbp.res_grp_enc_posted resource_grp_commitment
			 , pbp.res_grp_actual_posted resource_grp_actual
			 , '########### RESOURCE #############'
			 , pbp.res_budget_posted resource_budget
			 , pbp.res_enc_posted resource_commitment
			 , pbp.res_actual_posted resource_actual
			 , '########### BALANCES #############'
			 , pbp.res_budget_bal resource_balance
			 , pbp.res_grp_budget_bal resource_grp_balance
			 , pbp.task_budget_bal task_balance
			 , pbp.top_task_budget_bal top_task_balance
			 , pbp.project_budget_bal project_balance
			 , '########### OTHER #############'
			 , pbp.creation_date
		  from pa_bc_packets_hist pbp
		  join pa_projects_all ppa on pbp.project_id = ppa.project_id
		  join pa_tasks pt on ppa.project_id = pt.project_id and ppa.project_id = pt.project_id and pbp.task_id = pt.task_id
		  join fnd_lookup_values_vl flv_status on flv_status.lookup_code = pbp.status_code and flv_status.view_application_id = 275 and flv_status.lookup_type = 'FC_STATUS_CODE'
		  join fnd_lookup_values_vl flv_doc on flv_doc.lookup_code = pbp.document_type and flv_doc.view_application_id = 275 and flv_doc.lookup_type = 'FC_DOC_TYPE'
		  join fnd_lookup_values_vl flv_result on flv_result.lookup_code = pbp.result_code and flv_result.view_application_id = 275 and flv_result.lookup_type = 'FC_RESULT_CODE'
		  join fnd_lookup_values_vl flv_result_task on flv_result_task.lookup_code = pbp.task_result_code and flv_result_task.view_application_id = 275 and flv_result_task.lookup_type = 'FC_RESULT_CODE'
		  join fnd_lookup_values_vl flv_result_res on flv_result_res.lookup_code = pbp.res_result_code and flv_result_res.view_application_id = 275 and flv_result_res.lookup_type = 'FC_RESULT_CODE'
		  join fnd_lookup_values_vl flv_result_res_grp on flv_result_res_grp.lookup_code = pbp.res_grp_result_code and flv_result_res_grp.view_application_id = 275 and flv_result_res_grp.lookup_type = 'FC_RESULT_CODE'
		  join fnd_lookup_values_vl flv_result_top_task on flv_result_top_task.lookup_code = pbp.top_task_result_code and flv_result_top_task.view_application_id = 275 and flv_result_top_task.lookup_type = 'FC_RESULT_CODE'
		  join fnd_lookup_values_vl flv_result_project on flv_result_project.lookup_code = pbp.project_result_code and flv_result_project.view_application_id = 275 and flv_result_project.lookup_type = 'FC_RESULT_CODE'
		 where 1 = 1
		   -- and pbp.creation_date > '31-MAY-2019' 
		   and ppa.segment1 in ('P123456')
		   -- and ppa.project_id = 123456
		   -- and pbp.last_updated_by = 123456
	  order by pbp.creation_date desc;

-- ##################################################################
-- PA BALANCES - REQUISITION DETAILS
-- ##################################################################

		select pbp.packet_id
			 , ppa.segment1 proj
			 , pt.task_number task
			 , pt2.task_number budget_task
			 , pbp.creation_date
			 , prha.segment1 req
			 , (select sum(unit_price*quantity) from po_requisition_lines_all where requisition_header_id = prha.requisition_header_id) req_value
			 , pbp.document_distribution_id , pbp.document_header_id , pbp.document_line_id 
			 , pbp.expenditure_type
			 , to_char(pbp.expenditure_item_date, 'DD-MON-YYYY') item_date
			 , to_char(pbp.gl_date, 'DD-MON-YYYY') gl_date
			 , to_char(pbp.pa_date, 'DD-MON-YYYY') pa_date
			 , to_char(pbp.fc_start_date, 'DD-MON-YYYY') fc_start_date
			 , to_char(pbp.fc_end_date, 'DD-MON-YYYY') fnd_end_date
			 , pbp.period_name
			 , gsob.name ledger
			 , pbp.je_category_name cat
			 , pbp.je_source_name src
			 , '(' || pbp.status_code || ') ' || flv_status.meaning status
			 , flv_doc.meaning doc_type
			 , hou.short_code org
			 , pbp.actual_flag
			 , gett.encumbrance_type
			 , pbp.effect_on_funds_code
			 , pbp.entered_dr
			 , pbp.entered_cr
			 , pbp.accounted_dr
			 , pbp.accounted_cr
			 , '(' || flv_result.lookup_code || ') ' || flv_result.meaning result
			 , pbp.task_budget_posted
			 , pbp.task_enc_posted
			 , pbp.task_enc_approved
			 , pbp.task_actual_posted
			 , pbp.task_actual_approved
			 , '(' || flv_result_task.lookup_code || ') ' || flv_result_task.meaning task_result_code
			 , pbp.res_grp_enc_approved
			 , pbp.res_grp_actual_posted
			 , '(' || flv_result_res_grp.lookup_code || ') ' || flv_result_res_grp.meaning res_grp_result_code
			 , pbp.res_enc_approved
			 , pbp.res_actual_posted
			 , '(' || flv_result_res.lookup_code || ') ' || flv_result_res.meaning res_result_code
			 , pbp.res_budget_bal
			 , pbp.res_grp_budget_bal
			 , pbp.task_budget_bal
			 , pbp.top_task_budget_bal
			 , pbp.project_budget_bal
			 , pbp.top_task_budget_posted
			 , pbp.top_task_enc_posted
			 , pbp.top_task_enc_approved
			 , pbp.top_task_actual_posted
			 , '(' || flv_result_top_task.lookup_code || ') ' || flv_result_top_task.meaning top_task_result_code
			 , pbp.project_budget_posted
			 , pbp.project_enc_posted
			 , pbp.project_enc_approved
			 , pbp.project_actual_posted
			 , '(' || flv_result_project.lookup_code || ') ' || flv_result_project.meaning project_result_code
			 , pbp.reference1
			 , pbp.reference2
			 , pbp.reference3
			 -- , '################'
			 -- , pbp.*
		  from pa_bc_packets pbp
		  join pa_projects_all ppa on pbp.project_id = ppa.project_id
		  join pa_tasks pt on pbp.task_id = pt.task_id
		  join pa_tasks pt2 on pbp.bud_task_id = pt2.task_id
		  join gl_sets_of_books gsob on pbp.set_of_books_id = gsob.set_of_books_id
		  join hr_operating_units hou on hou.organization_id = pbp.expenditure_organization_id
		  join fnd_lookup_values_vl flv_status on flv_status.lookup_code = pbp.status_code and flv_status.view_application_id = 275 and flv_status.lookup_type = 'FC_STATUS_CODE'
		  join fnd_lookup_values_vl flv_doc on flv_doc.lookup_code = pbp.document_type and flv_doc.view_application_id = 275 and flv_doc.lookup_type = 'FC_DOC_TYPE'
		  join fnd_lookup_values_vl flv_result on flv_result.lookup_code = pbp.result_code and flv_result.view_application_id = 275 and flv_result.lookup_type = 'FC_RESULT_CODE'
		  join fnd_lookup_values_vl flv_result_task on flv_result_task.lookup_code = pbp.task_result_code and flv_result_task.view_application_id = 275 and flv_result_task.lookup_type = 'FC_RESULT_CODE'
		  join fnd_lookup_values_vl flv_result_res on flv_result_res.lookup_code = pbp.res_result_code and flv_result_res.view_application_id = 275 and flv_result_res.lookup_type = 'FC_RESULT_CODE'
		  join fnd_lookup_values_vl flv_result_res_grp on flv_result_res_grp.lookup_code = pbp.res_grp_result_code and flv_result_res_grp.view_application_id = 275 and flv_result_res_grp.lookup_type = 'FC_RESULT_CODE'
		  join fnd_lookup_values_vl flv_result_top_task on flv_result_top_task.lookup_code = pbp.top_task_result_code and flv_result_top_task.view_application_id = 275 and flv_result_top_task.lookup_type = 'FC_RESULT_CODE'
		  join fnd_lookup_values_vl flv_result_project on flv_result_project.lookup_code = pbp.project_result_code and flv_result_project.view_application_id = 275 and flv_result_project.lookup_type = 'FC_RESULT_CODE'
		  join gl_encumbrance_types gett on pbp.encumbrance_type_id = gett.encumbrance_type_id
	 left join po_requisition_headers_all prha on prha.requisition_header_id = pbp.document_header_id
		 where 1 = 1
		   -- and pbp.creation_date > '31-MAY-2019' 
		   and ppa.segment1 in ('P123456','P123457')
	  order by pbp.creation_date desc;

-- ##################################################################
-- PA BALANCES - REQUISITIONS - SUMMARY BY REQUISITION, PROJECT AND TASK
-- ##################################################################

		select prha.segment1 req
			 , ppa.segment1 project
			 , pt.task_number task
			 , sum(prla.quantity*prla.unit_price) req_value
		  from po_requisition_headers_all prha
		  join po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join po_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
		  join pa_projects_all ppa on prda.project_id = ppa.project_id
		  join pa_tasks pt on pt.task_id = prda.task_id
		 where ppa.segment1 = '66677'
	  group by prha.segment1
			 , ppa.segment1
			 , pt.task_number;

-- ##################################################################
-- PA BALANCES - REQUISITIONS - SUMMARY BY PROJECT AND TASK
-- ##################################################################

		select ppa.segment1 project
			 , pt.task_number task
			 , sum(prla.quantity*prla.unit_price) req_value
			 , min(prha.creation_date) earliest_req
			 , max(prha.creation_date) latest_req
		  from po_requisition_headers_all prha
		  join po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join po_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
		  join pa_projects_all ppa on prda.project_id = ppa.project_id
		  join pa_tasks pt on pt.task_id = prda.task_id
		 where ppa.segment1 = '66677'
	  group by ppa.segment1
			 , pt.task_number;

-- ##################################################################
-- PA BALANCES - PURCHASE ORDERS
-- ##################################################################

		select pbp.packet_id
			 , ppa.segment1 proj
			 , pt.task_number task
			 , pt2.task_number budget_task
			 , pbp.creation_date
			 , pha.segment1 po
			 , (select sum(unit_price*quantity) from po_lines_all where po_header_id = pha.po_header_id) po_value
			 , pbp.document_distribution_id , pbp.document_header_id , pbp.document_line_id 
			 , pbp.expenditure_type
			 , to_char(pbp.expenditure_item_date, 'DD-MON-YYYY') item_date
			 , to_char(pbp.gl_date, 'DD-MON-YYYY') gl_date
			 , to_char(pbp.pa_date, 'DD-MON-YYYY') pa_date
			 , to_char(pbp.fc_start_date, 'DD-MON-YYYY') fc_start_date
			 , to_char(pbp.fc_end_date, 'DD-MON-YYYY') fnd_end_date
			 , pbp.period_name
			 , gsob.name ledger
			 , pbp.je_category_name cat
			 , pbp.je_source_name src
			 , '(' || pbp.status_code || ') ' || flv_status.meaning status
			 , flv_doc.meaning doc_type
			 , hou.short_code org
			 , pbp.actual_flag
			 , gett.encumbrance_type
			 , pbp.effect_on_funds_code
			 , pbp.entered_dr
			 , pbp.entered_cr
			 , pbp.accounted_dr
			 , pbp.accounted_cr
			 , '(' || flv_result.lookup_code || ') ' || flv_result.meaning result
			 , pbp.task_budget_posted
			 , pbp.task_enc_posted
			 , pbp.task_enc_approved
			 , pbp.task_actual_posted
			 , pbp.task_actual_approved
			 , '(' || flv_result_task.lookup_code || ') ' || flv_result_task.meaning task_result_code
			 , pbp.res_grp_enc_approved
			 , pbp.res_grp_actual_posted
			 , '(' || flv_result_res_grp.lookup_code || ') ' || flv_result_res_grp.meaning res_grp_result_code
			 , pbp.res_enc_approved
			 , pbp.res_actual_posted
			 , '(' || flv_result_res.lookup_code || ') ' || flv_result_res.meaning res_result_code
			 , pbp.res_budget_bal
			 , pbp.res_grp_budget_bal
			 , pbp.task_budget_bal
			 , pbp.top_task_budget_bal
			 , pbp.project_budget_bal
			 , pbp.top_task_budget_posted
			 , pbp.top_task_enc_posted
			 , pbp.top_task_enc_approved
			 , pbp.top_task_actual_posted
			 , '(' || flv_result_top_task.lookup_code || ') ' || flv_result_top_task.meaning top_task_result_code
			 , pbp.project_budget_posted
			 , pbp.project_enc_posted
			 , pbp.project_enc_approved
			 , pbp.project_actual_posted
			 , '(' || flv_result_project.lookup_code || ') ' || flv_result_project.meaning project_result_code
			 , pbp.reference1
			 , pbp.reference2
			 , pbp.reference3
			 -- , '################'
			 -- , pbp.*
		  from pa_bc_packets pbp
		  join pa_projects_all ppa on pbp.project_id = ppa.project_id
		  join pa_tasks pt on pbp.task_id = pt.task_id
		  join pa_tasks pt2 on pbp.bud_task_id = pt2.task_id
		  join gl_sets_of_books gsob on pbp.set_of_books_id = gsob.set_of_books_id
		  join hr_operating_units hou on hou.organization_id = pbp.expenditure_organization_id
		  join fnd_lookup_values_vl flv_status on flv_status.lookup_code = pbp.status_code and flv_status.view_application_id = 275 and flv_status.lookup_type = 'FC_STATUS_CODE'
		  join fnd_lookup_values_vl flv_doc on flv_doc.lookup_code = pbp.document_type and flv_doc.view_application_id = 275 and flv_doc.lookup_type = 'FC_DOC_TYPE'
		  join fnd_lookup_values_vl flv_result on flv_result.lookup_code = pbp.result_code and flv_result.view_application_id = 275 and flv_result.lookup_type = 'FC_RESULT_CODE'
		  join fnd_lookup_values_vl flv_result_task on flv_result_task.lookup_code = pbp.task_result_code and flv_result_task.view_application_id = 275 and flv_result_task.lookup_type = 'FC_RESULT_CODE'
		  join fnd_lookup_values_vl flv_result_res on flv_result_res.lookup_code = pbp.res_result_code and flv_result_res.view_application_id = 275 and flv_result_res.lookup_type = 'FC_RESULT_CODE'
		  join fnd_lookup_values_vl flv_result_res_grp on flv_result_res_grp.lookup_code = pbp.res_grp_result_code and flv_result_res_grp.view_application_id = 275 and flv_result_res_grp.lookup_type = 'FC_RESULT_CODE'
		  join fnd_lookup_values_vl flv_result_top_task on flv_result_top_task.lookup_code = pbp.top_task_result_code and flv_result_top_task.view_application_id = 275 and flv_result_top_task.lookup_type = 'FC_RESULT_CODE'
		  join fnd_lookup_values_vl flv_result_project on flv_result_project.lookup_code = pbp.project_result_code and flv_result_project.view_application_id = 275 and flv_result_project.lookup_type = 'FC_RESULT_CODE'
		  join gl_encumbrance_types gett on pbp.encumbrance_type_id = gett.encumbrance_type_id
		  join po_headers_all pha on pha.po_header_id = pbp.document_header_id
		 where 1 = 1
		   and pbp.creation_date > '31-MAY-2019' 
		   -- and ppa.segment1 = 'P123456'
	  order by pbp.creation_date desc;

-- ##################################################################
-- PA BALANCES - AP INVOICES
-- ##################################################################

		select pbp.packet_id
			 , ppa.segment1 proj
			 , ppa.project_id
			 , pt.task_number task
			 , pt2.task_number budget_task
			 , pbp.creation_date
			 , aia.invoice_num
			 , aia.invoice_amount
			 , pbp.document_distribution_id , pbp.document_header_id , pbp.document_line_id 
			 , pbp.expenditure_type
			 , to_char(pbp.expenditure_item_date, 'DD-MON-YYYY') item_date
			 , to_char(pbp.gl_date, 'DD-MON-YYYY') gl_date
			 , to_char(pbp.pa_date, 'DD-MON-YYYY') pa_date
			 , to_char(pbp.fc_start_date, 'DD-MON-YYYY') fc_start_date
			 , to_char(pbp.fc_end_date, 'DD-MON-YYYY') fnd_end_date
			 , pbp.period_name
			 , gsob.name ledger
			 , pbp.je_category_name cat
			 , pbp.je_source_name src
			 , '(' || pbp.status_code || ') ' || flv_status.meaning status
			 , flv_doc.meaning doc_type
			 , hou.short_code org
			 , pbp.actual_flag
			 , gett.encumbrance_type
			 , pbp.effect_on_funds_code
			 , pbp.entered_dr
			 , pbp.entered_cr
			 , pbp.accounted_dr
			 , pbp.accounted_cr
			 , '(' || flv_result.lookup_code || ') ' || flv_result.meaning result
			 , pbp.task_budget_posted
			 , pbp.task_enc_posted
			 , pbp.task_enc_approved
			 , pbp.task_actual_posted
			 , pbp.task_actual_approved
			 , '(' || flv_result_task.lookup_code || ') ' || flv_result_task.meaning task_result_code
			 , pbp.res_grp_enc_approved
			 , pbp.res_grp_actual_posted
			 , '(' || flv_result_res_grp.lookup_code || ') ' || flv_result_res_grp.meaning res_grp_result_code
			 , pbp.res_enc_approved
			 , pbp.res_actual_posted
			 , '(' || flv_result_res.lookup_code || ') ' || flv_result_res.meaning res_result_code
			 , pbp.res_budget_bal
			 , pbp.res_grp_budget_bal
			 , pbp.task_budget_bal
			 , pbp.top_task_budget_bal
			 , pbp.project_budget_bal
			 , pbp.top_task_budget_posted
			 , pbp.top_task_enc_posted
			 , pbp.top_task_enc_approved
			 , pbp.top_task_actual_posted
			 , '(' || flv_result_top_task.lookup_code || ') ' || flv_result_top_task.meaning top_task_result_code
			 , pbp.project_budget_posted
			 , pbp.project_enc_posted
			 , pbp.project_enc_approved
			 , pbp.project_actual_posted
			 , pbp.project_budget_posted - (pbp.project_enc_posted + pbp.project_actual_posted) rem
			 , '(' || flv_result_project.lookup_code || ') ' || flv_result_project.meaning project_result_code
			 , pbp.reference1
			 , pbp.reference2
			 , pbp.reference3
			 -- , '################'
			 -- , pbp.*
		  from pa_bc_packets_hist pbp
		  join pa_projects_all ppa on pbp.project_id = ppa.project_id
		  join pa_tasks pt on pbp.task_id = pt.task_id
		  join pa_tasks pt2 on pbp.bud_task_id = pt2.task_id
		  join gl_sets_of_books gsob on pbp.set_of_books_id = gsob.set_of_books_id
		  join hr_operating_units hou on hou.organization_id = pbp.expenditure_organization_id
		  join fnd_lookup_values_vl flv_status on flv_status.lookup_code = pbp.status_code and flv_status.view_application_id = 275 and flv_status.lookup_type = 'FC_STATUS_CODE'
		  join fnd_lookup_values_vl flv_doc on flv_doc.lookup_code = pbp.document_type and flv_doc.view_application_id = 275 and flv_doc.lookup_type = 'FC_DOC_TYPE'
		  join fnd_lookup_values_vl flv_result on flv_result.lookup_code = pbp.result_code and flv_result.view_application_id = 275 and flv_result.lookup_type = 'FC_RESULT_CODE'
		  join fnd_lookup_values_vl flv_result_task on flv_result_task.lookup_code = pbp.task_result_code and flv_result_task.view_application_id = 275 and flv_result_task.lookup_type = 'FC_RESULT_CODE'
		  join fnd_lookup_values_vl flv_result_res on flv_result_res.lookup_code = pbp.res_result_code and flv_result_res.view_application_id = 275 and flv_result_res.lookup_type = 'FC_RESULT_CODE'
		  join fnd_lookup_values_vl flv_result_res_grp on flv_result_res_grp.lookup_code = pbp.res_grp_result_code and flv_result_res_grp.view_application_id = 275 and flv_result_res_grp.lookup_type = 'FC_RESULT_CODE'
		  join fnd_lookup_values_vl flv_result_top_task on flv_result_top_task.lookup_code = pbp.top_task_result_code and flv_result_top_task.view_application_id = 275 and flv_result_top_task.lookup_type = 'FC_RESULT_CODE'
		  join fnd_lookup_values_vl flv_result_project on flv_result_project.lookup_code = pbp.project_result_code and flv_result_project.view_application_id = 275 and flv_result_project.lookup_type = 'FC_RESULT_CODE'
		  join gl_encumbrance_types gett on pbp.encumbrance_type_id = gett.encumbrance_type_id
	 left join ap_invoices_all aia on aia.invoice_id = pbp.document_header_id
		 where 1 = 1
		   -- and pbp.creation_date > '31-MAY-2019' 
		   and ppa.segment1 = 'P123456'
	  order by pbp.creation_date desc;

