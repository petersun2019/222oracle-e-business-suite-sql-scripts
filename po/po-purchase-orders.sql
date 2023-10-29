/*
File Name: po-purchase-orders.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- PO HEADER
-- PO VALUES
-- PO LINES AND DISTRIBUTIONS
-- PO AND REQUISITION DISTRIBUTIONS AND COA SEGMENT DESCRIPTIONS
-- PO AND REQUISITION DISTRIBUTIONS SUMMARY
-- PO ATTACHMENTS
-- PO SUMMARY 1 - WITH PO VALUE
-- PO SUMMARY 2

*/

-- ##################################################################
-- PO HEADER
-- ##################################################################

		select pha.segment1 po
			 , hou.short_code org
			 , pha.org_id
			 , pha.po_header_id
			 , pha.type_lookup_code po_type
			 , pha.document_creation_method doc_method
			 , pha.creation_date
			 , fu.user_name created_by
			 , pha.last_update_date
			 , fu2.user_name updated_by
			 , pha.approved_flag
			 , pha.approved_date
			 , pha.cancel_flag
			 , (select distinct 'y' from po_headers_all where type_lookup_code = 'CONTRACT' and vendor_id = pha.vendor_id and vendor_site_id = pha.vendor_site_id) contract_exists
			 , pha.xml_send_date
			 , pha.xml_flag
			 , (select count(*) from wf_items where item_type = 'POAPPRV' and user_key = pha.segment1) wf_count
			 , loc_ship.location_code ship_to
			 , loc_bill.location_code bill_to
			 , pha.authorization_status status
			 , pha.closed_code
			 , pha.currency_code
			 , pha.creation_date
			 , pav.agent_name
			 , fu1.user_name buyer_user_name
			 , pv.vendor_name supplier
			 -- , (select count(pra.po_header_id) from po_releases_all pra where pra.po_header_id = pha.po_header_id) release_count
		  from po_headers_all pha
		  join po_vendors pv on pha.vendor_id = pv.vendor_id
		  join fnd_user fu on pha.created_by = fu.user_id
		  join fnd_user fu1 on pav.agent_id = fu1.employee_id
		  join fnd_user fu2 on pha.last_updated_by = fu2.user_id
		  join hr_operating_units hou on pha.org_id = hou.organization_id
		  join po_agents_v pav on pha.agent_id = pav.agent_id
		  join hr.hr_locations_all_tl loc_ship on pha.ship_to_location_id = loc_ship.location_id and loc_ship.language = userenv('lang')
		  join hr.hr_locations_all_tl loc_bill on pha.bill_to_location_id = loc_bill.location_id and loc_bill.language = userenv('lang')
		 where 1 = 1
		   and pha.segment1 in ('PO123456')
		   -- and pha.creation_date > '17-APR-2020'
		   -- and fu.user_name = 'CHEESE_USER'
		   -- and pav.agent_name != 'Cheese, Mr Feta'
		   -- and pha.authorization_status = 'IN PROCESS'
		   -- and pha.revision_num > 1
		   -- and pvsa.vendor_site_code = 'CHEESE MARKET'
		   and 1 = 1
	  order by pha.creation_date desc;

-- ##################################################################
-- PO VALUES
-- ##################################################################

		select pha.segment1 po
			 , pha.po_header_id
			 , sum(pla.unit_price * pla.quantity) po_value
			 , hou.short_code org
			 , loc_ship.location_code ship_to
			 , loc_bill.location_code bill_to
			 , pha.authorization_status status
			 , pha.closed_code
			 , pha.currency_code
			 , pha.creation_date
			 , pav.agent_name
			 , pha.document_creation_method doc_method
			 , fu.user_name created_by
			 , pv.vendor_name supplier
			 , pha.cancel_flag
			 , ppa.segment1 project
			 , pt.task_number
		  from po_headers_all pha
		  join po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join ap_suppliers pv on pha.vendor_id = pv.vendor_id
		  join fnd_user fu on pha.created_by = fu.user_id
		  join hr_operating_units hou on pha.org_id = hou.organization_id
		  join po_agents_v pav on pha.agent_id = pav.agent_id
		  join hr.hr_locations_all_tl loc_ship on pha.ship_to_location_id = loc_ship.location_id
		  join hr.hr_locations_all_tl loc_bill on pha.bill_to_location_id = loc_bill.location_id
		  join po_lines_all pla on pla.po_header_id = pha.po_header_id
		  join po_distributions_all pda on pda.po_line_id = pda.po_line_id and pda.po_header_id = pha.po_header_id
		  join pa_projects_all ppa on pda.project_id = ppa.project_id
		  join pa_tasks pt on ppa.project_id = pt.project_id and pt.task_id = pda.task_id
		 where 1 = 1
		   and pha.po_header_id in (123, 456, 789)
		   -- and pha.creation_date > '01-JAN-2021'
		   -- and pha.segment1 in ('PO123456')
		   -- and ppa.segment1 = 'PO123456'
		   -- and pha.currency_code = 'USD'
		   -- and pha.closed_code = 'OPEN'
		   -- and pha.authorization_status = 'APPROVED'
		   -- and pav.agent_name = 'Cheese, Mrs Brie'
		   -- and pha.document_creation_method = 'AUTOCREATE'
		having sum(pla.unit_price * pla.quantity) > 1000000
	  group by pha.segment1
			 , pha.po_header_id
			 , hou.short_code
			 , loc_ship.location_code
			 , loc_bill.location_code
			 , pha.authorization_status
			 , pha.closed_code
			 , pha.currency_code
			 , pha.creation_date
			 , pv.vendor_name
			 , pav.agent_name
			 , pha.document_creation_method
			 , fu.user_name
			 , pha.cancel_flag
			 , ppa.segment1
			 , pt.task_number
	  order by pha.creation_date desc;

-- ##################################################################
-- PO LINES AND DISTRIBUTIONS
-- ##################################################################

		select pha.segment1 po
			 , pha.creation_date po_created
			 , fu0.user_name po_created_by
			 , pha.last_update_date po_last_update
			 , fu2.user_name po_updated_by
			 , pha.po_header_id
			 , pha.document_creation_method
			 , pha.type_lookup_code
			 , pha.approved_date
			 , pha.approved_flag
			 , pha.wf_item_key
			 , pha.currency_code
			 , fcv.currency_code currency_code
			 , pha.authorization_status
			 , pha.closed_code
			 , hlat_bill.description header_bill_to
			 , hlat_ship.description header_ship_to
			 , pav.agent_name buyer
			 , fu1.user_name buyer_user_name
			 , papf.full_name buyer_name
			 , hou.name org
			 , pv.vendor_name
			 , pv.segment1 supplier_number
			 , pvsa.vendor_site_code site
			 , pvsa.address_line1
			 , pvsa.address_line2
			 , pvsa.address_line3 
			 , pvsa.country
			 , pla.line_num
			 , pla.quantity
			 , pla.unit_price
			 , pla.creation_date line_created
			 , pla.contract_id
			 , mtl_cat.segment1 || '.' || mtl_cat.segment2 category
			 , hlat_ship_line.description line_ship_to
			 , fu.user_name deliver_to_user
			 , gcc.concatenated_segments charge_acct
			 , apps.gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,1,gcc.segment1) gcc_seg1_descr
			 , apps.gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,2,gcc.segment2) gcc_seg2_descr
			 , apps.gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,3,gcc.segment3) gcc_seg3_descr
			 , apps.gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,4,gcc.segment4) gcc_seg4_descr
			 , apps.gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,5,gcc.segment5) gcc_seg5_descr
			 , apps.gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id,6,gcc.segment6) gcc_seg6_descr
			 , loc.location_code deliver_to_loc
			 , ppa.segment1 project
			 , pt.task_number
			 , pda.distribution_num
			 , pda.quantity_ordered
			 , ppa.project_id
			 , pda.recovery_rate
			 , pda.recoverable_tax
			 , pda.nonrecoverable_tax
			 , '#####################'
			 , (nvl(pha.rate, 1) * pla.unit_price) currency_unit_price
			 , (replace(replace(pla.item_description,chr(10),''),chr(13),' ')) line_descr
			 , pda.quantity_ordered * (nvl (pha.rate, 1) * pla.unit_price) order_amt
			 , (pda.quantity_delivered - pda.quantity_cancelled) * (nvl(pha.rate, 1) * pla.unit_price) value_received
			 , '######################'
			 -- , pda.*
			 -- , (apps.po_inq_sv.get_active_enc_amount (nvl (pda.rate, 1), pda.encumbered_amount, plla.shipment_type, pda.po_distribution_id)) active_encumb
			 -- , psa_ap_bc_pvt.get_po_reversed_encumb_amount( pda.po_distribution_id,to_date('01/JAN/2008'),to_date('31/DEC/2015'),null) reversal_amount
			 -- , pda.encumbered_amount-psa_ap_bc_pvt.get_po_reversed_encumb_amount( pda.po_distribution_id,to_date('01/JAN/2008'),to_date('31/DEC/2015'),null) main_encumbered_amount
		  from po.po_headers_all pha
		  join po.po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join po.po_distributions_all pda on pda.po_line_id = pla.po_line_id and pda.po_header_id = pha.po_header_id
		  join po.po_line_locations_all plla on plla.po_header_id = pha.po_header_id and plla.po_line_id = pla.po_line_id and plla.po_line_id = pda.po_line_id
		  join hr_operating_units hou on pha.org_id = hou.organization_id
		  join apps.po_agents_v pav on pha.agent_id = pav.agent_id
		  join apps.gl_code_combinations_kfv gcc on pda.code_combination_id = gcc.code_combination_id
	 left join hr.per_all_people_f papf on pha.agent_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
		  join hr.hr_locations_all_tl loc on pda.deliver_to_location_id = loc.location_id
		  join apps.mtl_categories mtl_cat on pla.category_id = mtl_cat.category_id
		  join ap.ap_suppliers pv on pha.vendor_id = pv.vendor_id
		  join ap.ap_supplier_sites_all pvsa on pha.vendor_site_id = pvsa.vendor_site_id and pv.vendor_id = pvsa.vendor_id
	 left join apps.fnd_currencies_vl fcv on pha.currency_code = fcv.currency_code
	 left join pa.pa_projects_all ppa on ppa.project_id = pda.project_id
	 left join pa.pa_tasks pt on pt.task_id = pda.task_id
		  join hr.hr_locations_all_tl hlat_bill on pha.ship_to_location_id = hlat_bill.location_id
		  join hr.hr_locations_all_tl hlat_ship on pha.bill_to_location_id = hlat_ship.location_id
		  join hr.hr_locations_all_tl hlat_ship_line on plla.ship_to_location_id = hlat_ship_line.location_id
	 left join applsys.fnd_user fu on pda.deliver_to_person_id = fu.employee_id
		  join applsys.fnd_user fu0 on pha.created_by = fu0.user_id
		  join applsys.fnd_user fu1 on pav.agent_id = fu1.employee_id
		  join applsys.fnd_user fu2 on pha.last_updated_by = fu2.user_id
		 where 1 = 1
		   and pha.segment1 in ('PO123','PO987')
		   -- and ppa.project_id = 123456
		   -- and pv.segment1 = '123456'
		   -- and pha.creation_date > '01-feb-2022'
		   -- and papf.full_name = 'Cheese, Dr Burrata'
		   and 1 = 1
	  order by pha.creation_date desc;

-- ##################################################################
-- PO AND REQUISITION DISTRIBUTIONS AND COA SEGMENT DESCRIPTIONS
-- ##################################################################

		select distinct 
			   pha.segment1 po
			 , pha.closed_code
			 , prha.segment1 req
			 , hou.name org
			 , fu1.user_name req_created_by
			 , fu2.user_name po_created_by
			 , pda.creation_date po_dist_created
			 , pda.last_update_date po_dist_updated
			 , ppa.segment1 project
			 , pt.task_number task
			 , ppa.name project_name
			 , gcc1.concatenated_segments po_chg_acct
			 , gcc2.concatenated_segments req_chg_acct
			 , '################'
			 , apps.gl_flexfields_pkg.get_description_sql(gcc1.chart_of_accounts_id,1,gcc1.segment1) po_seg1_descr
			 , apps.gl_flexfields_pkg.get_description_sql(gcc1.chart_of_accounts_id,2,gcc1.segment2) po_seg2_descr
			 , apps.gl_flexfields_pkg.get_description_sql(gcc1.chart_of_accounts_id,3,gcc1.segment3) po_seg3_descr
			 , apps.gl_flexfields_pkg.get_description_sql(gcc1.chart_of_accounts_id,4,gcc1.segment4) po_seg4_descr
			 , apps.gl_flexfields_pkg.get_description_sql(gcc1.chart_of_accounts_id,5,gcc1.segment5) po_seg5_descr
			 , apps.gl_flexfields_pkg.get_description_sql(gcc1.chart_of_accounts_id,6,gcc1.segment6) po_seg6_descr
			 , '###############'
			 , apps.gl_flexfields_pkg.get_description_sql(gcc2.chart_of_accounts_id,1,gcc2.segment1) req_seg1_descr
			 , apps.gl_flexfields_pkg.get_description_sql(gcc2.chart_of_accounts_id,2,gcc2.segment2) req_seg2_descr
			 , apps.gl_flexfields_pkg.get_description_sql(gcc2.chart_of_accounts_id,3,gcc2.segment3) req_seg3_descr
			 , apps.gl_flexfields_pkg.get_description_sql(gcc2.chart_of_accounts_id,4,gcc2.segment4) req_seg4_descr
			 , apps.gl_flexfields_pkg.get_description_sql(gcc2.chart_of_accounts_id,5,gcc2.segment5) req_seg5_descr
			 , apps.gl_flexfields_pkg.get_description_sql(gcc2.chart_of_accounts_id,6,gcc2.segment6) req_seg6_descr
		  from po.po_headers_all pha
		  join po.po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join po.po_distributions_all pda on pda.po_line_id = pla.po_line_id and pda.po_header_id = pha.po_header_id
		  join apps.gl_code_combinations_kfv gcc1 on pda.code_combination_id = gcc1.code_combination_id
	 left join pa.pa_projects_all ppa on ppa.project_id = pda.project_id
	 left join pa.pa_tasks pt on pt.task_id = pda.task_id
		  join po.po_req_distributions_all prda on prda.distribution_id = pda.req_distribution_id
		  join po.po_requisition_lines_all prla on prla.requisition_line_id = prda.requisition_line_id
		  join po.po_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
		  join apps.gl_code_combinations_kfv gcc2 on prda.code_combination_id = gcc2.code_combination_id
		  join apps.fnd_user fu1 on prha.created_by = fu1.user_id
		  join apps.fnd_user fu2 on pha.last_updated_by = fu2.user_id
		  join apps.hr_operating_units hou on hou.organization_id = prha.org_id
		 where 1 = 1
		   and pha.segment1 in ('PO123456')
		   -- and ppa.segment1 in ('PROJ1234')
		   -- and pt.task_number = '5'
		   and 1 = 1;

-- ##################################################################
-- PO AND REQUISITION DISTRIBUTIONS SUMMARY
-- ##################################################################

		select ppa.segment1 project
			 , hou.name
			 , gcc1.segment1 || '.' || gcc1.segment2 || '.' || gcc1.segment3 || '.' || gcc1.segment4 po_chg_acct
			 , gcc2.segment1 || '.' || gcc2.segment2 || '.' || gcc2.segment3 || '.' || gcc2.segment4 req_chg_acct
			 , count(distinct prha.requisition_header_id) req_count
			 , count(distinct pha.po_header_id) po_count
			 , count(*)
		  from po.po_headers_all pha
		  join po.po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join po.po_distributions_all pda on pda.po_line_id = pla.po_line_id and pda.po_header_id = pha.po_header_id
		  join apps.gl_code_combinations_kfv gcc1 on pda.code_combination_id = gcc1.code_combination_id
		  join pa.pa_projects_all ppa on ppa.project_id = pda.project_id
		  join pa.pa_tasks pt on pt.task_id = pda.task_id
		  join po.po_req_distributions_all prda on prda.distribution_id = pda.req_distribution_id
		  join po.po_requisition_lines_all prla on prla.requisition_line_id = prda.requisition_line_id
		  join po.po_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
		  join apps.gl_code_combinations_kfv gcc2 on prda.code_combination_id = gcc2.code_combination_id
		  join apps.hr_operating_units hou on hou.organization_id = prha.org_id
		 where 1 = 1
		   and pha.segment1 in ('PO123456')
		   -- and ppa.segment1 in ('PROJ1234')
		   -- and pt.task_number = '5'
		   and 1 = 1
	  group by ppa.segment1
			 , hou.name
			 , gcc1.segment1 || '.' || gcc1.segment2 || '.' || gcc1.segment3 || '.' || gcc1.segment4
			 , gcc2.segment1 || '.' || gcc2.segment2 || '.' || gcc2.segment3 || '.' || gcc2.segment4;

-- ##################################################################
-- PO ATTACHMENTS
-- ##################################################################

		select fl.*
			 , fad.*
		  from fnd_lobs fl
			 , fnd_attached_docs_form_vl fad
		 where fl.file_id = fad.media_id and fad.entity_name in ('PO_HEAD', 'PO_REL')
		   -- and fl.file_name like '%1234%'
		   -- and fl.file_name in ('PO_103_123456_0_US.pdf','PO_103_987654_0_US.pdf')
	  order by 1 desc;

-- ##################################################################
-- PO SUMMARY 1 - WITH PO VALUE
-- ##################################################################

		select pha.segment1 po
			 , pha.authorization_status
			 , pha.creation_date
			 , fu.description created_by
			 , pav.agent_name buyer
			 , ppa.segment1 project
			 , pha.type_lookup_code
			 , pha.document_creation_method
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
			 , sum(pla.unit_price * pla.quantity) po_value
			 -- , gcc.concatenated_segments
			 -- , gcc.segment1
			 -- , gcc.segment2
			 -- , gcc.segment3
			 -- , gcc.segment4
			 -- , gcc.segment5
			 -- , gcc.segment6
			 -- , gcc.segment7
			 -- , gcc.segment8
		  from po.po_headers_all pha
		  join po.po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join po.po_distributions_all pda on pla.po_line_id = pda.po_line_id and pda.po_header_id = pha.po_header_id
		  join ap.ap_suppliers pv on pha.vendor_id = pv.vendor_id
		  join ap.ap_supplier_sites_all pvsa on pha.vendor_site_id = pvsa.vendor_site_id and pv.vendor_id = pvsa.vendor_id
		  join applsys.fnd_user fu on pha.created_by = fu.user_id
		  join apps.po_agents_v pav on pha.agent_id = pav.agent_id
		  join apps.gl_code_combinations_kfv gcc on pda.code_combination_id = gcc.code_combination_id
	 left join pa.pa_projects_all ppa on pda.project_id = ppa.project_id
		  join apps.hr_operating_units hou on pha.org_id = hou.organization_id
		 where 1 = 1
		   and pha.creation_date > '01-JAN-2018'
		   -- and pha.authorization_status = 'PRE-APPROVED'
	  group by hou.short_code
			 , pha.segment1
			 , pha.authorization_status
			 , pha.creation_date
			 , fu.description
			 , pav.agent_name
			 , ppa.segment1
			 , pha.type_lookup_code
			 , pha.document_creation_method
			 , pv.vendor_name
			 , pvsa.vendor_site_code
			 -- , gcc.concatenated_segments
			 -- , gcc.segment1
			 -- , gcc.segment2
			 -- , gcc.segment3
			 -- , gcc.segment4
			 -- , gcc.segment5
			 -- , gcc.segment6
			 -- , gcc.segment7
			 -- , gcc.segment8
		having sum(pla.unit_price * pla.quantity) > 2000000
	  order by pha.creation_date desc;

-- ##################################################################
-- PO SUMMARY 2
-- ##################################################################

		select pha.segment1
			 , pha.authorization_status
			 , pha.creation_date
			 , sum(pla.unit_price * pla.quantity) po_value
			 , count(*) lines
		  from po.po_headers_all pha
		  join po.po_lines_all pla on pha.po_header_id = pla.po_header_id
		 where 1 = 1
		   and pha.creation_date > '01-JAN-2013'
		   and pha.authorization_status = 'PRE-APPROVED'
	  group by pha.segment1
			 , pha.authorization_status
			 , pha.creation_date
		-- having sum(pla.unit_price * pla.quantity) > 2000000
	  order by pha.creation_date desc;
