/*
File Name: pa-asset-info.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- PA - ASSETS - SUMMARY
-- PA - ASSETS - DETAILS
-- PA - ASSETS - ALL
-- PA - ASSETS - LINES

*/

-- ##################################################################
-- PA - ASSETS - SUMMARY
-- ##################################################################

		select ppa.segment1 proj
			 , ppa.project_id
			 , count(distinct fab.asset_id) asset_count
			 , aia.invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , aia.invoice_amount
			 , ppaa.capitalized_flag
			 , sum(round(nvl(pcdla.acct_burdened_cost*(decode(ppala.original_asset_cost, 0, 1, ppala.current_asset_cost)/decode(ppala.original_asset_cost, 0, 1, ppala.original_asset_cost)), 0),2)) report_calc
		  from pa_projects_all ppa
		  join pa_expenditure_items_all peia on ppa.project_id = ppa.project_id
		  join pa_cost_distribution_lines_all pcdla on peia.expenditure_item_id = pcdla.expenditure_item_id
		  join ap_invoices_all aia on peia.document_header_id = aia.invoice_id and peia.transaction_source = 'AP INVOICE'
		  join ap_invoice_distributions_all aida on aia.invoice_id = aida.invoice_id and aida.invoice_distribution_id = peia.document_distribution_id and aida.project_id = ppa.project_id
		  join pa_project_asset_line_details ppald on peia.expenditure_item_id = ppald.expenditure_item_id
		  join pa_project_asset_lines_all ppala on ppala.project_asset_line_detail_id = ppald.project_asset_line_detail_id
	 left join pa_project_assets_all ppaa on ppala.project_asset_id = ppaa.project_asset_id
	 left join fa_additions_b fab on fab.asset_id = ppaa.fa_asset_id
	 left join fa_additions_tl fat on fab.asset_id = fat.asset_id
		 where 1 = 1
		   -- and ppa.segment1 = 'P123456'
		   -- and fab.asset_number = '12345678'
		   and aia.invoice_num in ('123456','123457','123458')
		   -- and aia.invoice_num = '123456'
		   -- and ppaa.capitalized_flag = 'Y'
		   and 1 = 1
	  group by ppa.segment1
			 , ppa.project_id
			 , aia.invoice_id
			 , '#' || aia.invoice_num
			 , aia.invoice_amount
			 , ppaa.capitalized_flag;

-- ##################################################################
-- PA - ASSETS - DETAILS
-- ##################################################################

		select ppa.segment1 proj
			 , ppa.project_id
			 , fab.asset_id
			 , fab.asset_number
			 , fat.description asset_description
			 , ' ========= expend_item_table ========='
			 , peia.quantity
			 , peia.raw_cost
			 , peia.burden_cost
			 , peia.transaction_source
			 , ' ========= ap_invoice_table ==========='
			 , aia.invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , aia.invoice_amount
			 , aida.invoice_distribution_id
			 , ' ====== pa_asset_lines_all_table =============='
			 , ppala.original_asset_cost
			 , ppala.current_asset_cost
			 , ppala.invoice_id
			 , ppala.transfer_status_code
			 , ' ===== pa_asset_line_details ==============='
			 , ppald.cip_cost
			 , ' ========== pa_assets_all ============'
			 , ppaa.capitalized_flag
			 , ' ==== v1_calculation_bits ======='
			 , pcdla.acct_burdened_cost
			 , ppala.original_asset_cost
			 , ppala.current_asset_cost
			 , round(nvl(pcdla.acct_burdened_cost*(decode(ppala.original_asset_cost, 0, 1, ppala.current_asset_cost)/decode(ppala.original_asset_cost, 0, 1, ppala.original_asset_cost)), 0),2) v1_report_calc
		  from pa_projects_all ppa
		  join pa_expenditure_items_all peia on ppa.project_id = ppa.project_id
		  join pa_cost_distribution_lines_all pcdla on peia.expenditure_item_id = pcdla.expenditure_item_id
		  join ap_invoices_all aia on peia.document_header_id = aia.invoice_id and peia.transaction_source = 'AP INVOICE'
		  join ap_invoice_distributions_all aida on aia.invoice_id = aida.invoice_id and aida.invoice_distribution_id = peia.document_distribution_id and aida.project_id = ppa.project_id
		  join pa_project_asset_line_details ppald on peia.expenditure_item_id = ppald.expenditure_item_id
		  join pa_project_asset_lines_all ppala on ppala.project_asset_line_detail_id = ppald.project_asset_line_detail_id
	 left join pa_project_assets_all ppaa on ppala.project_asset_id = ppaa.project_asset_id
	 left join fa_additions_b fab on fab.asset_id = ppaa.fa_asset_id
	 left join fa_additions_tl fat on fab.asset_id = fat.asset_id
		 where 1 = 1
		   -- and ppa.segment1 = 'P123456'
		   -- and aia.invoice_num = '123456'
		   -- and ppaa.capitalized_flag = 'Y'
		   and aia.invoice_num in ('123456')
		   and 1 = 1;

-- ##################################################################
-- PA - ASSETS - ALL
-- ##################################################################

		select ppa.segment1
			 , ppaa.creation_date
			 , ppaa.*
		  from pa_project_assets_all ppaa
		  join pa_projects_all ppa on ppa.project_id = ppaa.project_id
		 where 1 = 1
		   and ppa.segment1 in ('123456','123457')
		   and ppaa.asset_number is null
		   -- and ppaa.fa_asset_id is null
		   -- and ppaa.creation_date > '01-jan-2018'
		   -- and ppaa.capitalized_date is not null
		   -- and ppaa.capitalized_flag = 'Y'
		   -- and ppaa.creation_date < '22-feb-2019'
		   -- and ppaa.request_id = 123456
	  order by ppaa.creation_date desc;

-- ##################################################################
-- PA - ASSETS - LINES
-- ##################################################################

		select ppa.segment1
			 , ppala.*
		  from pa_project_asset_lines_all ppala
		  join pa_projects_all ppa on ppa.project_id = ppala.project_id
		 where 1 = 1
		   -- and ppala.request_id = 123456
		   -- and ppala.creation_date > '21-feb-2019'
		   -- and ppala.creation_date < '22-feb-2019'
		   and ppala.project_asset_id = 123456
		   and 1 = 1;
