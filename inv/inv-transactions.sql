/*
File Name:		inv-transactions.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- UNCOSTED TRANSACTIONS PER PERIOD AND INV ORG
-- UNCOSTED TRANSACTIONS PER MONTH, INV ORG AND TRANSACTION TYPE
-- BASIC TRANSACTION DETAILS WITHOUT ACCOUNTING LINKS
-- BASIC TRANSACTION DETAILS WITH ACCOUNTING LINKS
-- BASIC TRANSACTION DETAILS WITH ACCOUNTING LINKS - LINKED TO PROJECT AND EXPENDITURE ITEM
-- TRANSACTION COUNT BY USER
-- TRANSACTION COUNT PER INV_ORG

*/

-- ##################################################################
-- UNCOSTED TRANSACTIONS PER PERIOD AND INV ORG
-- ##################################################################

		select to_char (mmt.creation_date, 'YYYY-MM') month_
			 , haou.name inv_org
			 , count (*) txns
			 , min(mmt.creation_date) oldest
			 , max(mmt.creation_date) newest
			 , trim(replace(replace(to_char(numtodsinterval((sysdate - min(mmt.creation_date)),'day')),'+000000000',''),'.000000000','')) oldest_
			 , trim(replace(replace(to_char(numtodsinterval((sysdate - max(mmt.creation_date)),'day')),'+000000000',''),'.000000000','')) newest_
		  from inv.mtl_material_transactions mmt
		  join inv.mtl_transaction_types mtt on mmt.transaction_type_id = mtt.transaction_type_id
		  join hr.hr_all_organization_units haou on mmt.organization_id = haou.organization_id 
		 where mmt.costed_flag is not null
		   and mmt.costed_flag = 'E' -- in error
	  group by haou.name
			 , haou.organization_id
			 , to_char (mmt.creation_date, 'YYYY-MM')
	  order by haou.organization_id
			 , to_char (mmt.creation_date, 'YYYY-MM');

-- ##################################################################
-- UNCOSTED TRANSACTIONS PER MONTH, INV ORG AND TRANSACTION TYPE
-- ##################################################################

		select to_char (mmt.creation_date, 'YYYY-MM') month_
			 , haou.name inv_org
			 , haou.organization_id org_id
			 , mtt.transaction_type_name tx_type
			 , mmt.costed_flag costed
			 , count (*) txns
			 , min(mmt.creation_date) oldest
			 , max(mmt.creation_date) newest
		  from inv.mtl_material_transactions mmt
		  join inv.mtl_transaction_types mtt on mmt.transaction_type_id = mtt.transaction_type_id
		  join hr.hr_all_organization_units haou on mmt.organization_id = haou.organization_id 
		 where mmt.costed_flag is not null
		   -- and mmt.creation_date > '10-DEC-2013'
	  group by haou.name
			 , haou.organization_id
			 , mtt.transaction_type_name
			 , mmt.costed_flag
			 , to_char (mmt.creation_date, 'YYYY-MM')
	  order by haou.organization_id
			 , to_char (mmt.creation_date, 'YYYY-MM');

-- ##################################################################
-- BASIC TRANSACTION DETAILS WITHOUT ACCOUNTING LINKS
-- ##################################################################

		select mmt.transaction_id tx_id
			 , mmt.organization_id org_id
			 , mmt.primary_quantity * -1 qty
			 , mmt.transaction_date tx_date
			 , mmt.creation_date cr_date
			 , mmt.last_update_date
			 , mmt.request_id
			 , haou.name inv_org
			 , mtt.transaction_type_name tx_type
			 , msib.segment1 item
			 , msib.list_price_per_unit
			 , decode(mmt.costed_flag,'','Yes','N','No','Other') costed
			 , mmt.costed_flag
			 , ppa.segment1 proj
			 , ppa.distribution_rule
			 , pt.task_number task
			 , fu.description cr_by
			 , gcc.segment1
			 , gcc.segment2 
			 -- , (select count(*) ct from inv.mtl_transaction_accounts mta where mta.transaction_id = mmt.transaction_id) acct_lines
			 , mmt.subinventory_code subinv
			 , mmt.transaction_quantity tx_qty
			 , mmt.transaction_reference tx_ref
		  from inv.mtl_material_transactions mmt
		  join inv.mtl_system_items_b msib on mmt.inventory_item_id = msib.inventory_item_id
		   and mmt.organization_id = msib.organization_id
		  join inv.mtl_transaction_types mtt on mmt.transaction_type_id = mtt.transaction_type_id 
		  join applsys.fnd_user fu on mmt.created_by = fu.user_id 
		  join hr.hr_all_organization_units haou on mmt.organization_id = haou.organization_id
	 left join pa.pa_projects_all ppa on mmt.source_project_id = ppa.project_id
	 left join pa.pa_tasks pt on mmt.source_task_id = pt.task_id
	 left join gl.gl_code_combinations gcc on mmt.distribution_account_id = gcc.code_combination_id
		 where 1 = 1
		   -- and mmt.transaction_id = 123456
		   and mmt.creation_date > '07-SEP-2016'
		   and msib.segment1 in ('A:123')
		   -- and mmt.organization_id = 123
		   -- and mtt.transaction_type_name = 'Average cost update'
		   -- and fu.user_name = 'CHEESE_USER'
		   -- and mmt.costed_flag is not null -- uncosted
		   -- and ppa.segment1 = 'P123456'
		   -- and mmt.costed_flag = 'E' -- error
	  order by mmt.transaction_id desc;

-- ##################################################################
-- BASIC TRANSACTION DETAILS WITH ACCOUNTING LINKS
-- ##################################################################

		select mmt.transaction_id tx_id
			 , mmt.organization_id org_id
			 , mmt.primary_quantity * -1 qty
			 , mmt.transaction_date tx_date
			 , mmt.creation_date tx_created
			 , mta.creation_date mta_created
			 , mmt.last_update_date
			 , haou.name inv_org
			 , mtt.transaction_type_name tx_type
			 , msib.segment1 item
			 , msib.list_price_per_unit
			 , mta.primary_quantity
			 , mta.base_transaction_value
			 , decode(mmt.costed_flag,'','Yes','N','No','Other') costed
			 , ppa.segment1 proj
			 , pt.task_number task
			 , fu.description cr_by
			 , gcc.segment1
			 , gcc.segment2
		  from inv.mtl_material_transactions mmt
		  join inv.mtl_system_items_b msib on mmt.inventory_item_id = msib.inventory_item_id
		   and mmt.organization_id = msib.organization_id
		  join inv.mtl_transaction_accounts mta on mmt.transaction_id = mta.transaction_id
		  join inv.mtl_transaction_types mtt on mmt.transaction_type_id = mtt.transaction_type_id
		  join gl.gl_code_combinations gcc on mta.reference_account = gcc.code_combination_id
		  join applsys.fnd_user fu on mmt.created_by = fu.user_id
		  join hr.hr_all_organization_units haou on mmt.organization_id = haou.organization_id
	 left join pa.pa_projects_all ppa on mmt.source_project_id = ppa.project_id
	 left join pa.pa_tasks pt on mmt.source_task_id = pt.task_id
		 where 1 = 1 
		   -- and mmt.transaction_id = 123456
		   and mmt.creation_date > '07-SEP-2016'
		   and msib.segment1 in ('A:123')
		   -- and mmt.organization_id = 123
		   -- and mtt.transaction_type_name = 'Average cost update'
		   -- and fu.user_name = 'CHEESE_USER'
		   -- and mmt.costed_flag is not null -- uncosted
		   -- and ppa.segment1 = 'P123456'
		   -- and mmt.costed_flag = 'E' -- error
		   and 1 = 1;

-- ##################################################################
-- BASIC TRANSACTION DETAILS WITH ACCOUNTING LINKS - LINKED TO PROJECT AND EXPENDITURE ITEM
-- ##################################################################

		select mmt.transaction_id inv_tx_id
			 , mmt.creation_date inv_tx_date
			 , haou.name inv_org
			 , mtt.transaction_type_name tx_type
			 , msib.segment1 inv_item
			 , decode(mmt.costed_flag,'','Yes','N','No','Other') costed
			 , ppa.segment1 project
			 , pt.task_number task
			 , gcc.segment1
			 , gcc.segment2
			 , fu.description cr_by
			 , mmt.transaction_quantity tx_qty
			 , peia.expenditure_item_id exp_item_id
			 , peia.creation_date
			 , peia.expenditure_item_date
			 , peia.expenditure_type
			 , peia.quantity
			 , peia.raw_cost
			 , peia.raw_cost_rate
			 , peia.transaction_source
			 , peia.system_linkage_function
		  from inv.mtl_material_transactions mmt
		  join inv.mtl_system_items_b msib on mmt.inventory_item_id = msib.inventory_item_id
		   and mmt.organization_id = msib.organization_id
		  join inv.mtl_transaction_types mtt on mmt.transaction_type_id = mtt.transaction_type_id
		  join applsys.fnd_user fu on mmt.created_by = fu.user_id
		  join hr.hr_all_organization_units haou on mmt.organization_id = haou.organization_id
		  join pa.pa_projects_all ppa on mmt.source_project_id = ppa.project_id
		  join pa.pa_tasks pt on mmt.source_task_id = pt.task_id
	 left join gl.gl_code_combinations gcc on mmt.distribution_account_id = gcc.code_combination_id
		  join pa.pa_expenditure_items_all peia on ppa.project_id = peia.project_id
		   and peia.inventory_item_id = msib.inventory_item_id
		   and peia.orig_transaction_reference = mmt.transaction_id
		 where 1 = 1
		   and peia.expenditure_item_id in (123456, 123457)
		   -- and peia.expenditure_item_id in (123456)
	  order by mmt.transaction_id desc;

-- ##################################################################
-- TRANSACTION COUNT BY USER
-- ##################################################################

		select mtt.transaction_type_name tx_type
			 , fu.description
			 , count (*) ct
		  from inv.mtl_material_transactions mmt
		  join inv.mtl_system_items_b msib on mmt.inventory_item_id = msib.inventory_item_id
		   and mmt.organization_id = msib.organization_id
		  join inv.mtl_transaction_accounts mta on mmt.transaction_id = mta.transaction_id
		  join inv.mtl_transaction_types mtt on mmt.transaction_type_id = mtt.transaction_type_id
		  join gl.gl_code_combinations gcc on mta.reference_account = gcc.code_combination_id
		  join applsys.fnd_user fu on mmt.created_by = fu.user_id
		 where 1 = 1
		   and mmt.creation_date between '20-OCT-2014' and '25-OCT-2014'
		   -- and mmt.organization_id = 123
		   -- and fu.user_name = 'CHEESE_USER'
	  group by mtt.transaction_type_name
			 , fu.description
	  order by 2 desc;

-- ##################################################################
-- TRANSACTION COUNT PER INV_ORG
-- ##################################################################

		select mmt.organization_id
			 , haou.name
			 , max (mmt.creation_date) most_recent
			 , count (*) ct
		  from inv.mtl_material_transactions mmt
		  join hr.hr_all_organization_units haou on mmt.organization_id = haou.organization_id
	  group by mmt.organization_id
			 , haou.name;
