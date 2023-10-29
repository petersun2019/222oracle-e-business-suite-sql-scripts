/*
File Name:		po-requisitions.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- REQUISITION HEADER DETAILS
-- REQ VALUES
-- SUMMARY BY PROJECT
-- REQUISITION LINES
-- REQUISITION HEADER WITH LINE DETAILS AND DISTRIBUTIONS
-- CATALOGUE REQUISITION LINKED TO BPA INFO

*/

-- ##################################################################
-- REQUISITION HEADER DETAILS
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , prha.segment1 requisition
			 -- , prha.requisition_header_id
			 -- , hou.name person_org
			 -- , hou.short_code person_org_short_code
			 , prha.creation_date
			 -- , prha.description
			 , prha.authorization_status
			 , prha.approved_date
			 , prha.cancel_flag
			 -- , prha.interface_source_code
			 , prha.creation_date
			 , prha.wf_item_key
			 , prha.wf_item_type
			 , fu.user_name created_by
			 , fu.email_address
			 , fu.end_date
			 , ppx.full_name
			 , haou.name hr_org_person_assignment
			 , hou.name req_org
			 , prha.org_id
		  from po.po_requisition_headers_all prha
		  join applsys.fnd_user fu on prha.created_by = fu.user_id
		  join apps.per_people_x ppx on fu.employee_id = ppx.person_id
		  join apps.per_assignments_x pax on ppx.person_id = pax.person_id
		  join hr.hr_all_organization_units haou on pax.organization_id = haou.organization_id
	 left join apps.hr_operating_units hou on hou.organization_id = prha.org_id
		  join apps.hr_operating_units hou on prha.org_id = hou.organization_id
		 where 1 = 1
		   -- and prha.segment1 in ('REQ123456')
		   -- and prha.creation_date > '10-dec-2020'
		   -- and prha.creation_date < '15-dec-2020'
		   and fu.user_name = 'BUGS.BUNNY'
		   -- and prha.segment1 = 'REQ123456'
		   -- and pax.primary_flag = 'Y'
	  order by prha.requisition_header_id desc;

-- ##################################################################
-- REQ VALUES
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , prha.segment1 req
			 , prha.requisition_header_id
			 , fu.user_name
			 , fu.email_address
			 , prha.authorization_status
			 , prha.description
			 , prha.creation_date
			 , prha.approved_date
			 , haou.name org
			 -- , prla.vendor_id
			 , to_char(prha.creation_date, 'yyyy-mm-dd') created
			 , to_char(prha.approved_date, 'yyyy-mm-dd') approved
			 , prha.created_by
			 , prha.wf_item_key
			 -- , ppa.segment1 project
			 , sum(prla.unit_price * prla.quantity) req_value
			 , count(*) lines
		  from po_requisition_headers_all prha
		  join po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  -- join po_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
	 -- left join pa_projects_all ppa on prda.project_id = ppa.project_id
		  -- join gl_code_combinations_kfv gcc on gcc.code_combination_id = prda.code_combination_id
		  join fnd_user fu on prha.created_by = fu.user_id
		  join hr.hr_all_organization_units haou on prha.org_id = haou.organization_id
		 where 1 = 1
		   -- and ppa.segment1 = 'PROJ1234'
		   -- and fu.user_name = 'BUGS.BUNNY'
		   and prha.requisition_header_id in (123,456,678)
		   -- and prla.vendor_id = 1234
		   -- and prha.creation_date > '01-APR-2019'
		   -- and prha.description like '%|%'
		   -- and prha.created_by = 1234
		   and 1 = 1
	  group by sys_context('USERENV','DB_NAME')
			 , prha.segment1
			 , prha.requisition_header_id
			 , fu.user_name
			 , fu.email_address
			 , prha.authorization_status
			 , prha.description
			 , prha.creation_date
			 , prha.approved_date
			 , haou.name
			 -- , prla.vendor_id
			 , to_char(prha.creation_date, 'yyyy-mm-dd')
			 , to_char(prha.approved_date, 'yyyy-mm-dd')
			 , prha.created_by
			 , prha.wf_item_key
			 -- , ppa.segment1
		-- having sum(prla.unit_price * prla.quantity) > 500000
	  order by prha.requisition_header_id desc;

-- ##################################################################
-- SUMMARY BY PROJECT
-- ##################################################################

		select ppa.segment1 project
			 , pt.task_number task
			 , min(prha.creation_date) first_req
			 , max(prha.creation_date) last_req
			 , min(prha.segment1) earliest_req
			 , max(prha.segment1) latest_req
			 , count(distinct prha.requisition_header_id) req_count
		  from apps.po_requisition_headers_all prha
		  join apps.po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join apps.po_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
		  join apps.pa_projects_all ppa on prda.project_id = ppa.project_id
		  join apps.pa_tasks pt on prda.task_id = pt.task_id
	 -- left join apps.zx_lines_det_factors zldf on zldf.trx_id = prha.requisition_header_id and zldf.trx_line_id = prla.requisition_line_id
	 left join apps.fnd_user fu on prha.created_by = fu.user_id
	 left join apps.por_noncat_templates_all_tl templ on prla.noncat_template_id = templ.template_id and templ.language = userenv('lang')
	 left join apps.hr_locations_all hla on prla.deliver_to_location_id = hla.location_id
		 where 1 = 1
		   and ppa.segment1 = 'PROJ1234'
	  group by ppa.segment1
			 , pt.task_number;

-- ##################################################################
-- REQUISITION LINES
-- ##################################################################

		select prha.segment1 req
			 , hla.location_code
			 , hla.description
			 , prha.authorization_status status
			 , hou.short_code header_org
			 , prha.org_id
			 , prla.currency_code currency
			 , prla.line_num line
			 , to_char(prla.need_by_date, 'DD-MM-YYYY') need_by_date
			 , prha.creation_date
			 , fu.user_name req_created_by
			 , templ.template_name line_type
			 , prha.approved_date
			 , prla.creation_date line_created
			 , prla.order_type_lookup_code
			 , case when prla.line_type_id = 1 and prla.order_type_lookup_code = 'QUANTITY' then 'Goods Billed By quantity'
					when prla.line_type_id = 1020 and prla.order_type_lookup_code = 'AMOUNT' then 'Goods or services billed by amount'
					when prla.line_type_id = 1021 and prla.order_type_lookup_code = 'QUANTITY' then 'Services Billed By quantity'
			   end item_type
			 , (replace(replace(prla.item_description,chr(10),''),chr(13),' ')) item_description
			 , mcb.segment10 || '.' || mcb.segment11 category
			 , prla.quantity
			 , prla.unit_meas_lookup_code uom
			 , prla.unit_price
			 , prla.amount
			 , prla.suggested_vendor_name
			 , prla.suggested_vendor_location
			 , prla.suggested_vendor_product_code
			 , hou_line.short_code line_org 
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
			 , pvsa.city
			 , pvsa.state
			 , pvsa.country
			 , ppa.segment1 project
			 , ppa.project_id
			 -- , to_char(ppa.completion_date, 'yyyy-mm-dd') project_completion_date
			 -- , ppa.project_status_code
			 , pt.task_number task
			 -- , to_char(pt.completion_date, 'yyyy-mm-dd') task_completion_date
			 -- , to_char(prda.expenditure_item_date, 'yyyy-mm-dd') item_date
			 -- , round(prda.expenditure_item_date - sysdate, 2) item_date_gap
			 , prda.expenditure_type exp_type
			 , to_char(prda.gl_encumbered_date, 'yyyy-mm-dd') gl_encumbered_date
			 , case
		       --------------------------------------------- PUNCHOUT
					when prla.catalog_type = 'EXTERNAL'
					 and prla.catalog_source = 'EXTERNAL'
					 and prla.source_type_code = 'VENDOR' then 'PUNCHOUT'
		       ---------------------------------------------INTERNAL CATALOGUE
					when prla.catalog_type = 'CATALOG'
					 and prla.catalog_source = 'INTERNAL'
					 and prla.source_type_code = 'VENDOR' then 'LOCAL_CATALOGUE'
		       --------------------------------------------- NON CATALOGUE
					when prla.catalog_type = 'NONCATALOG'
					 and prla.catalog_source = 'INTERNAL'
					 and prla.source_type_code = 'VENDOR' then 'NONCAT'
					else 'Other'
			   end order_type
			 , prda.nonrecoverable_tax
			 , gcc.concatenated_segments charge_acct
			 , apps.gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,1,gcc.segment1) gcc_seg1_descr
			 , apps.gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,2,gcc.segment2) gcc_seg2_descr
			 , apps.gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,3,gcc.segment3) gcc_seg3_descr
			 , apps.gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,4,gcc.segment4) gcc_seg4_descr
			 , apps.gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,5,gcc.segment5) gcc_seg5_descr
			 , apps.gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,6,gcc.segment6) gcc_seg6_descr
			 -- , zldf.product_type
			 -- , zldf.product_category
			 -- , zldf.total_inc_tax_amt
			 -- , zldf.user_defined_fisc_class
			 -- , zldf.line_intended_use
			 -- , zldf.input_tax_classification_code
			 -- , zldf.trx_business_category
		  from apps.po_requisition_headers_all prha
	 left join apps.po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
	 left join apps.po_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
	 left join apps.hr_operating_units hou on hou.organization_id = prha.org_id
	 left join apps.hr_operating_units hou_line on hou_line.organization_id = prla.org_id
	 left join apps.mtl_categories_b mcb on mcb.category_id = prla.category_id
	 left join apps.gl_code_combinations_kfv gcc on gcc.code_combination_id = prda.code_combination_id
	 left join apps.ap_suppliers pv on prla.vendor_id = pv.vendor_id
	 left join apps.ap_supplier_sites_all pvsa on prla.vendor_site_id = pvsa.vendor_site_id
	 left join apps.pa_projects_all ppa on prda.project_id = ppa.project_id
	 left join apps.pa_tasks pt on prda.task_id = pt.task_id
	 -- left join apps.zx_lines_det_factors zldf on zldf.trx_id = prha.requisition_header_id and zldf.trx_line_id = prla.requisition_line_id
	 left join apps.fnd_user fu on prha.created_by = fu.user_id
	 left join apps.por_noncat_templates_all_tl templ on prla.noncat_template_id = templ.template_id and templ.language = userenv('lang')
	 left join apps.hr_locations_all hla on prla.deliver_to_location_id = hla.location_id
		 where 1 = 1
		   -- and prha.creation_date > '01-AUG-2021'
		   -- and zldf.product_category = 'XX EXEMPT'
		   -- and prda.nonrecoverable_tax <> 0
		   and prha.segment1 in ('REQ1234')
		   -- and ppa.segment1 = 'PROJ1234'
		   -- and pt.task_number = 'TASK345'
		   -- and prda.expenditure_type = 'Cheese Costs'
		   -- and prha.requisition_header_id in (111,222,333,444)
		   -- and mcb.segment1 = 'CAT123'
		   -- and fu.user_name = 'BUGS.BUNNY'
	  order by prha.creation_date desc
			 , prha.segment1
			 , prla.line_num;

-- ##################################################################
-- REQUISITION HEADER WITH LINE DETAILS AND DISTRIBUTIONS
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , prha.segment1 req
			 , hou.name hr_org
			 , prha.requisition_header_id
			 , case
		       -- ----------------------------------------------- PUNCHOUT
					when prla.catalog_type = 'EXTERNAL'
					 and prla.catalog_source = 'EXTERNAL'
					 and prla.source_type_code = 'VENDOR' then 'PUNCHOUT'
		       -- -----------------------------------------------INTERNAL CATALOGUE
					when prla.catalog_type = 'CATALOG'
					 and prla.catalog_source = 'INTERNAL'
					 and prla.source_type_code = 'VENDOR' then 'LOCAL_CATALOGUE'
		       -- ----------------------------------------------- NON CATALOGUE
					when prla.catalog_type = 'NONCATALOG'
					 and prla.catalog_source = 'INTERNAL'
					 and prla.source_type_code = 'VENDOR' then 'NONCAT'
					else 'Other'
			   end order_type
			 , prha.creation_date
			 , fu.user_name created_by
			 , fu.email_address
			 , prha.authorization_status
			 , prha.approved_date
			 -- , prla.requisition_line_id
			 , prla.creation_date line_created
			 , prla.last_update_date line_updated
			 -- , templ.template_name line_type
			 , prla.line_num
			 , (replace(replace(prla.item_description,chr(10),''),chr(13),' ')) line_descr
			 , case when prla.line_type_id = 1 and prla.order_type_lookup_code = 'QUANTITY' then 'Goods Billed By quantity'
					when prla.line_type_id = 1020 and prla.order_type_lookup_code = 'AMOUNT' then 'Goods or services billed by amount'
					when prla.line_type_id = 1021 and prla.order_type_lookup_code = 'QUANTITY' then 'Services Billed By quantity'
			   end item_type
			 , prla.quantity
			 -- , prla.noncat_template_id
			 , prla.unit_price
			 -- , prla.new_supplier_flag
			 , prla.suggested_vendor_name
			 , prla.suggested_vendor_location
			 , prla.suggested_vendor_product_code
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
			 , mcb.segment1 || '.' || mcb.segment2 purchase_category
			 , hlat_ship_line.description line_ship_to
			 -- , prda.allocation_value
			 -- , prda.allocation_type
			 , prda.recoverable_tax
			 -- , prda.recovery_rate
			 , prda.nonrecoverable_tax
			 , gcc.concatenated_segments charge_account
			 , gcc.gl_account_type
			 , ppa.segment1 project
			 , haou_proj.name proj_org
			 , pt.task_number
			 , pt.billable_flag
			 -- , pt.task_id
			 , haou.name exp_org
			 , prda.expenditure_type exp_type
			 , prda.creation_date dist_created
			 , prda.last_update_date dist_updated
		  from po.po_requisition_headers_all prha
	 left join po.po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
	 left join po.po_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
	 left join inv.mtl_categories_b mcb on mcb.category_id = prla.category_id
	 left join apps.hr_operating_units hou on hou.organization_id = prha.org_id
	 left join ap.ap_suppliers pv on prla.vendor_id = pv.vendor_id
	 left join ap.ap_supplier_sites_all pvsa on prla.vendor_site_id = pvsa.vendor_site_id
	 left join applsys.fnd_user fu on prha.created_by = fu.user_id
	 left join hr.hr_locations_all_tl hlat_ship_line on prla.deliver_to_location_id = hlat_ship_line.location_id
	 left join apps.gl_code_combinations_kfv gcc on prda.code_combination_id = gcc.code_combination_id
	 left join pa.pa_projects_all ppa on prda.project_id = ppa.project_id
	 left join pa.pa_tasks pt on prda.task_id = pt.task_id
	 left join hr.hr_all_organization_units haou_proj on ppa.carrying_out_organization_id = haou_proj.organization_id
	 left join hr.hr_all_organization_units haou on prda.expenditure_organization_id = haou.organization_id
	 -- left join icx.por_noncat_templates_all_tl templ on prla.noncat_template_id = templ.template_id 
	 -- left join apps.zx_lines_det_factors zldf on zldf.trx_id = prha.requisition_header_id and zldf.trx_line_id = prla.requisition_line_id
		 where 1 = 1
		   -- and ppa.segment1 = 'PO1234'
		   and prha.segment1 in ('REQ1234')
		   -- and mcb.segment1 = 'CAT123'
		   -- and fu.user_name like 'BUGS%'
		   -- and gcc.segment1 = 'SEG123'
		   -- and prha.creation_date > '01-MAR-2021'
		   -- and prha.creation_date < '10-MAR-2021'
		   -- and pt.task_number = 'TASK123'
		   -- and prha.creation_date > '03-DEC-2019'
		   -- and prha.requisition_header_id = 1234
		   -- and fu.user_name in ('BUGS.BUNNY','BIG.BOSS')
		   -- and prha.creation_date > '01-JAN-2019'
	  order by prha.creation_date desc
			 , prha.segment1
			 , prla.line_num
			 , prda.distribution_num;

-- ##################################################################
-- CATALOGUE REQUISITION LINKED TO BPA INFO
-- ##################################################################

		select sys_context('USERENV','DB_NAME') instance
			 , prha.segment1 req
			 , prla.line_num req_line_num
			 , prla.creation_date req_line_created
			 , prla.org_id req_line_org
			 , (replace(replace(prla.item_description,chr(10),''),chr(13),' ')) req_item_description
			 , '#' || prla.suggested_vendor_product_code req_product_code
			 , '####### BPA #######'
			 , pha.segment1 bpa
			 , pla.po_line_id
			 , pla.org_id po_line_org_id
			 , pla.line_num bpa_line_num
			 , (replace(replace(pla.item_description,chr(10),''),chr(13),' ')) bpa_item_description
			 , '#' || pla.vendor_product_num bpa_prod_number
			 -- , '####### ATTRIB ####'
			 -- , pavt.alias
			 -- , pavt.comments
			 -- , pavt.long_description
		  from po.po_requisition_headers_all prha
		  join po.po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join po.po_headers_all pha on prla.blanket_po_header_id = pha.po_header_id
		  join po.po_lines_all pla on prla.blanket_po_line_num = pla.line_num and pla.po_header_id = pha.po_header_id
	 left join po.po_attribute_values_tlp pavt on pla.po_line_id = pavt.po_line_id
		 where 1 = 1
		   and prha.segment1 = 'REQ1234'
		   and 1 = 1
	  order by prha.segment1
			 , prla.line_num;
