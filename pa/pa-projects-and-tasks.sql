/*
File Name:		pa-projects-and-tasks.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- PA PROJECTS AND TASKS - TABLE DUMPS
-- PROJECT DETAILS
-- PROJECT AND TASKS
-- ACTIVITIES AGAINST PROJECTS
-- ACTIVITIES AGAINST PROJECTS AND TASKS - VERSION 1
-- ACTIVITIES AGAINST PROJECTS AND TASKS - VERSION 2
-- PROJECT INFO PER ORG
-- PROJECT TEMPLATES
-- PROJECT TASK HIERARCHY

*/

-- ##################################################################
-- PA PROJECTS AND TASKS - TABLE DUMPS
-- ##################################################################

select * from pa_projects_all; 
select * from pa_tasks;

-- ##################################################################
-- PROJECT DETAILS
-- ##################################################################

		select ppa.segment1 project
			 , ppa.project_id id
			 , ppa.name
			 , ppa.long_name
			 , ppa.created_from_project_id
			 , ppa_template.segment1 template
			 , ppa_template.project_type template_project_type
			 , ppa.carrying_out_organization_id
			 , ppta.project_type
			 , ppa.template_flag
			 , haou.name org
			 , ppa.output_tax_code
			 , ppa.creation_date project_created
			 , fu.user_name created_by
			 , ppa.last_update_date
			 , ppa.distribution_rule distrib_rule
			 , to_char(ppa.start_date, 'DD-MON-YYYY') start_date
			 , to_char(ppa.completion_date, 'DD-MON-YYYY') end_date
			 , ppta.project_type_class_code
			 , pps.project_status_name status
			 , case when ppa.cost_ind_rate_sch_id != 4 then 'y' end burden_flag
			 , ppa.enable_top_task_customer_flag
		  from pa.pa_projects_all ppa
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join applsys.fnd_user fu on ppa.created_by = fu.user_id
	 left join applsys.fnd_user fu2 on ppa.last_updated_by = fu2.user_id
		  join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
		  join pa.pa_project_types_all ppta on ppa.project_type = ppta.project_type and ppa.org_id = ppta.org_id
	 left join pa.pa_projects_all ppa_template on ppa.created_from_project_id = ppa_template.project_id
		 where 1 = 1
		   and ppa.segment1 in ('P123456')
		   -- and ppa.project_id = 123456
		   -- and ppa.creation_date > '10-JUN-2021'
		   -- and sysdate between ppa.start_date and ppa.completion_date -- projects where today is within project start and end dates
		   -- and ppa.project_type = 'CHEESE'
		   -- and pps.project_status_name = 'Approved'
		   -- and ppa.carrying_out_organization_id = 123
		   -- and ppa.template_flag = 'Y' -- project templates
		   -- and ppa.completion_date is not null -- no end date
		   -- and haou.name = 'Cheese Org'
		   -- and fu.user_name = 'CHEESE_USER'
		   -- and ppa.name like 'CH%'
		   and 1 = 1
	  order by ppa.completion_date desc;

-- ##################################################################
-- PROJECT AND TASKS
-- ##################################################################

		select ppa.segment1 project
			 , ppa.project_id id
			 , fu.description task_created_by
			 , to_char(ppa.start_date, 'DD-MON-YYYY') start_date
			 , to_char(ppa.completion_date, 'DD-MON-YYYY') end_date
			 , to_char(ppa.creation_date, 'DD-MON-YYYY HH24:MI:SS') project_created
			 , to_char(ppa.last_update_date, 'DD-MON-YYYY HH24:MI:SS') project_updated
			 , ppa.project_status_code
			 , ppa.carrying_out_organization_id 
			 , pt.task_number
			 , pt.task_name
			 , pt.task_id
			 , pt.task_manager_person_id
			 , pt.last_update_date
			 , pt.last_updated_by
			 , fu2.user_name || ' (' || fu2.email_address || ')' task_updated_by
			 , papf.full_name task_manager
			 , to_char(pt.last_update_date, 'DD-MON-YYYY HH24:MI:SS') task_updated
			 , haou.name project_org
			 , haou2.name task_org
		  from pa.pa_projects_all ppa 
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join pa.pa_project_types_all ppta on ppa.project_type = ppta.project_type and ppa.org_id = ppta.org_id
		  join pa.pa_tasks pt on ppa.project_id = pt.project_id
		  join applsys.fnd_user fu on pt.created_by = fu.user_id
		  join applsys.fnd_user fu2 on pt.last_updated_by = fu2.user_id
		  join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
		  join hr.hr_all_organization_units haou2 on pt.carrying_out_organization_id = haou2.organization_id
	 left join hr.per_all_people_f papf on papf.person_id = pt.task_manager_person_id and sysdate between papf.effective_start_date and papf.effective_end_date
		 where 1 = 1
		   and ppa.segment1 in ('P123456')
		   and haou2.name = 'University of Cheese'
		   -- and haou2.name = 'Research Chese Collaborator'
		   -- and pt.task_number = 'Cheese Abandonment'
		   -- and pt.task_id = 123456
		   -- and pt.task_manager_person_id = 987654
		   and 1 = 1
	  order by pt.last_update_date desc;

-- ##################################################################
-- ACTIVITIES AGAINST PROJECTS
-- ##################################################################

		select ppa.segment1 project
			 , ppa.project_id id
			 , ppa.name
			 , ppa.long_name
			 , ppa.created_from_project_id
			 , ppa_template.segment1 template
			 , ppa_template.project_type template_project_type
			 , ppa.carrying_out_organization_id
			 , ppta.project_type
			 , ppa.template_flag
			 , haou.name org
			 , ppa.output_tax_code
			 , ppa.creation_date project_created
			 , fu.user_name created_by
			 , ppa.last_update_date
			 , ppa.distribution_rule distrib_rule
			 , to_char(ppa.start_date, 'DD-MON-YYYY') start_date
			 , to_char(ppa.completion_date, 'DD-MON-YYYY') end_date
			 , ppta.project_type_class_code
			 , pps.project_status_name status
			 , case when ppa.cost_ind_rate_sch_id != 4 then 'y' end burden_flag
			 , ppa.enable_top_task_customer_flag
			 , '#' budget_info___
			 , (select count(*) from pa_budget_versions pbv where pbv.project_id = ppa.project_id and current_flag = 'Y' and budget_status_code = 'B') bud_ct
			 , (select sum(pbl.burdened_cost) from pa_budget_versions pbv, pa_budget_lines pbl where pbl.budget_version_id = pbv.budget_version_id and pbv.project_id = ppa.project_id and pbv.current_flag = 'Y' and pbv.budget_status_code = 'B') bud_val
			 , '#' task_info___
			 , (select count(*) from pa.pa_tasks pt where pt.project_id = ppa.project_id) task_count
			 , (select count(*) from pa.pa_tasks pt where pt.project_id = ppa.project_id and pt.parent_task_id is null) top_task_count
			 , '#' expenditure_info___
			 , (select count(*) from pa.pa_expenditure_items_all xxx where xxx.project_id = ppa.project_id) expenditure_item_count
			 , (select sum(raw_cost) from pa.pa_expenditure_items_all xxx where xxx.project_id = ppa.project_id) exps_total
			 , (select trunc(min(xxx.creation_date)) from pa.pa_expenditure_items_all xxx where xxx.project_id = ppa.project_id) first_exp_item
			 , (select trunc(max(xxx.creation_date)) from pa.pa_expenditure_items_all xxx where xxx.project_id = ppa.project_id) last_exp_item
			 , '#' po_info___
			 , (select count(*) from po.po_distributions_all xxx where xxx.project_id = ppa.project_id) po_distribution_count
			 , (select count(distinct pha.po_header_id) from po.po_distributions_all xxx join po_headers_all pha on xxx.po_header_id = pha.po_header_id where xxx.project_id = ppa.project_id and pha.closed_code = 'OPEN' and pha.type_lookup_code = 'STANDARD') open_pos
			 , (select count(distinct pha.po_header_id) from po.po_distributions_all xxx join po_headers_all pha on xxx.po_header_id = pha.po_header_id where xxx.project_id = ppa.project_id) po_count
			 , (select sum(po_inq_sv.get_active_enc_amount(nvl(pda.rate,1),nvl(pda.encumbered_amount,0),'STANDARD',pda.po_distribution_id)) from po_distributions_all pda join po_headers_all pha on pha.po_header_id = pda.po_header_id where pda.project_id = ppa.project_id and pha.closed_code = 'OPEN' and pha.type_lookup_code = 'STANDARD') commitment
			 , (select max(creation_date) from po.po_distributions_all xxx where xxx.project_id = ppa.project_id) last_po_dist
			 , '#' ap_info___
			 , (select count(*) from ap.ap_invoice_distributions_all xxx where xxx.project_id = ppa.project_id) inv_distribution_count
			 , (select max(creation_date) from ap.ap_invoice_distributions_all xxx where xxx.project_id = ppa.project_id) last_inv_dist
			 , '#' events_rev_invoices___
			 , (select count(*) from pa.pa_events xxx where xxx.project_id = ppa.project_id) event_count
			 , (select max(creation_date) from pa.pa_events xxx where xxx.project_id = ppa.project_id) latest_event
			 , (select count(*) from pa.pa_draft_revenues_all xxx where xxx.project_id = ppa.project_id) revenue_count
			 , (select max(creation_date) from pa.pa_draft_revenues_all xxx where xxx.project_id = ppa.project_id) latest_revenue
			 , (select count(*) from pa.pa_draft_invoices_all xxx where xxx.project_id = ppa.project_id) invoice_count
			 , (select max(creation_date) from pa.pa_draft_invoices_all xxx where xxx.project_id = ppa.project_id) latest_invoice	 
		  from pa.pa_projects_all ppa
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join applsys.fnd_user fu on ppa.created_by = fu.user_id
	 left join applsys.fnd_user fu2 on ppa.last_updated_by = fu2.user_id
		  join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
		  join pa.pa_project_types_all ppta on ppa.project_type = ppta.project_type and ppa.org_id = ppta.org_id
	 left join pa.pa_projects_all ppa_template on ppa.created_from_project_id = ppa_template.project_id
		 where 1 = 1
		   and ppa.segment1 in ('P123456')
		   -- and ppa.project_id = 123456
		   -- and ppa.creation_date > '10-JUN-2021'
		   -- and sysdate between ppa.start_date and ppa.completion_date -- projects where today is within project start and end dates
		   -- and ppa.project_type = 'CHEESE'
		   -- and pps.project_status_name = 'Approved'
		   -- and ppa.carrying_out_organization_id = 123
		   -- and ppa.template_flag = 'Y' -- project templates
		   -- and ppa.completion_date is not null -- no end date
		   -- and haou.name = 'Cheese Org'
		   -- and fu.user_name = 'CHEESE_USER'
		   -- and ppa.name like 'CH%'
		   and 1 = 1
	  order by ppa.completion_date desc;

-- ##################################################################
-- ACTIVITIES AGAINST PROJECTS AND TASKS - VERSION 1
-- ##################################################################

		select ppa.segment1 proj
			 , pt.task_number task
			 , case when pt.parent_task_id is null then 'Yes' end top_task
			 , (select sum(ppf.project_allocated_amount) from pa.pa_project_fundings ppf where ppf.project_id = ppa.project_id and ppf.task_id = pt.task_id) fund_amt
			 , (select sum(amount) from pa.pa_draft_revenue_items pdri where pdri.project_id = ppa.project_id and pdri.task_id = pt.task_id) rev_amt
			 , (select sum(amount) from pa.pa_draft_invoice_items pdii where pdii.project_id = ppa.project_id and pdii.task_id = pt.task_id) inv_amt
			 , (select sum(peia.raw_cost) from pa.pa_expenditure_items_all peia where peia.project_id = ppa.project_id and peia.task_id = pt.task_id) exp_items_total
			 , (select sum(e.raw_cost) from pa.pa_expenditure_items_all e where e.expenditure_item_id in (select d.expenditure_item_id from pa.pa_cust_rev_dist_lines_all d where d.project_id = ppa.project_id) and e.project_id = ppa.project_id and e.task_id = pt.task_id) exp_items_revenues
			 , (select sum(e.raw_cost) from pa.pa_expenditure_items_all e where e.expenditure_item_id not in (select d.expenditure_item_id from pa.pa_cust_rev_dist_lines_all d where d.project_id = ppa.project_id) and e.project_id = ppa.project_id and e.task_id = pt.task_id) exp_items_no_revenues
		  from pa.pa_projects_all ppa
		  join pa.pa_tasks pt on ppa.project_id = pt.project_id 
		   and ppa.segment1 = 'P123456';

-- ##################################################################
-- ACTIVITIES AGAINST PROJECTS AND TASKS - VERSION 2
-- ##################################################################

		select ppa.segment1
			 , pt.task_number
			 , sum(peia.raw_cost) sum_ttl
			 , count(*) lines
			 , peia.transaction_source
		  from pa.pa_expenditure_items_all peia
		  join pa.pa_projects_all ppa on ppa.project_id = peia.project_id
		  join pa.pa_tasks pt on ppa.project_id = pt.project_id and pt.task_id = peia.task_id
		 where 1 = 1 
		   and ppa.segment1 = 'P123456'
		   -- and peia.project_id = 123
	  group by ppa.segment1
			 , pt.task_number
			 , peia.transaction_source
	  order by 1, 2;

-- ##################################################################
-- PROJECT INFO PER ORG
-- ##################################################################

		select haou.name org
			 , min(ppa.segment1)
			 , max(ppa.segment1)
			 , min(ppa.creation_date)
			 , max(ppa.creation_date)
			 , count(*)
		  from pa.pa_projects_all ppa
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
		 where 1 = 1
		   and pps.project_status_name = 'Approved'
		   and ppa.template_flag != 'Y'
	  group by haou.name;

-- ##################################################################
-- PROJECT TEMPLATES
-- ##################################################################

		select ppa_template.segment1 template
			 , count(*)
		  from pa.pa_projects_all ppa
		  join pa.pa_projects_all ppa_template on ppa.created_from_project_id = ppa_template.project_id
		  join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
		 where 1 = 1
		   and ppa.template_flag != 'Y'
	  group by ppa_template.segment1;

-- ##################################################################
-- PROJECT TASK HIERARCHY
-- ##################################################################

		select lpad (' ', (level - 1) * 3, ' ') || task_number task_name
			 , level
			 , pt.task_id
			 , pt.task_name
			 , pt.parent_task_id
			 , pt.chargeable_flag chg_flag
		  from pa.pa_tasks pt
			 , pa.pa_projects_all ppa
		 where pt.project_id = ppa.project_id
	start with ppa.segment1 = 'P123456' -- pt.task_id = 123456
	connect by prior pt.task_id = pt.parent_task_id;
