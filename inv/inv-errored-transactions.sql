/*
File Name:		inv-errored-transactions.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- INVENTORY TRANSACTIONS - ERRORS 1
-- INVENTORY TRANSACTIONS - ERRORS 2
-- INVENTORY TRANSACTIONS - ERRORS - SUMMARY 1
-- INVENTORY TRANSACTIONS - ERRORS - SUMMARY 2
-- INVENTORY TRANSACTIONS - ERRORS - WITH GL INFORMATION

*/

-- ##################################################################
-- INVENTORY TRANSACTIONS - ERRORS 1
-- ##################################################################

		select mmt.transaction_id tx_id
			 , mmt.organization_id org_id
			 , mtt.transaction_type_name tx_type
			 , msib.segment1 item
			 , msib.creation_date item_cr_date
			 , mmt.request_id
			 , mmt.costed_flag
			 , mmt.last_update_date upd_date
			 , mmt.creation_date cr_date
			 , fu.description cr_by
			 , mtt.transaction_type_name tx_type
		  from inv.mtl_material_transactions mmt
		  join inv.mtl_system_items_b msib on mmt.inventory_item_id = msib.inventory_item_id and mmt.organization_id = msib.organization_id 
		  join inv.mtl_transaction_types mtt on mmt.transaction_type_id = mtt.transaction_type_id 
		  join applsys.fnd_user fu on mmt.created_by = fu.user_id 
		 where 1 = 1
		   -- and trunc(mmt.last_update_date) = '02-DEC-2013'
		   -- and mmt.last_update_date between to_date('02-DEC-2013 16:09:00', 'DD-MON-YYYY HH24:MI:SS') and to_date('02-DEC-2013 16:14:00', 'DD-MON-YYYY HH24:MI:SS')
		   -- and mmt.error_code = 'CST_INVALID_ACCT_ALIAS'
		   and mmt.costed_flag = 'E'
		   -- and mmt.organization_id = 123
	  order by mmt.organization_id;

-- ##################################################################
-- INVENTORY TRANSACTIONS - ERRORS 2
-- ##################################################################

		select mmt.*
			 , fu.description
		  from apps.mtl_material_transactions mmt
		  join applsys.fnd_user fu on mmt.created_by = fu.user_id 
		  join inv.mtl_transaction_types mtt on mmt.transaction_type_id = mtt.transaction_type_id 
		 where mmt.organization_id = 123
		   -- and mmt.creation_date > '04-NOV-2013'
		   and costed_flag = 'E';

-- ##################################################################
-- INVENTORY TRANSACTIONS - ERRORS - SUMMARY 1
-- ##################################################################

		select count (costed_flag) total
			 , costed_flag cflag
			 , substr (error_code, 1, 40) code
			 , substr (error_explanation, 1, 100) explan
		  from apps.mtl_material_transactions
		having costed_flag in ('E', 'N')
	  group by costed_flag
			 , error_code
			 , error_explanation;

-- ##################################################################
-- INVENTORY TRANSACTIONS - ERRORS - SUMMARY 2
-- ##################################################################

		select mtt.transaction_type_name tx_type
			 , sum((mmt.primary_quantity) * mmt.actual_cost) chg
			 , count(*) ct
			 , count(distinct mmt.source_project_id) project_count
		  from inv.mtl_material_transactions mmt
		  join inv.mtl_system_items_b msib on mmt.inventory_item_id = msib.inventory_item_id
		   and mmt.organization_id = msib.organization_id 
		  join inv.mtl_transaction_types mtt on mmt.transaction_type_id = mtt.transaction_type_id 
		  join inv.mtl_transaction_accounts mta on mmt.transaction_id = mta.transaction_id 
		  join applsys.fnd_user fu on mmt.created_by = fu.user_id
		 where 1 = 1
		   and mmt.creation_date >= '01-NOV-2013'
		   and mmt.creation_date < '10-NOV-2013'
		   and costed_flag = 'E'
		   and mmt.organization_id = 123
	  group by mtt.transaction_type_name
	  order by mmt.organization_id;

-- ##################################################################
-- INVENTORY TRANSACTIONS - ERRORS - WITH GL INFORMATION
-- ##################################################################

		select mmt.transaction_id tx_id
			 , mmt.organization_id org_id
			 , mtt.transaction_type_name tx_type
			 , mmt.primary_quantity qty
			 , mmt.actual_cost cost
			 , (mmt.primary_quantity)*-1 * mmt.actual_cost chg
			 , msib.segment1 item
			 , mmt.request_id
			 , mmt.costed_flag costed
			 , mmt.last_update_date upd_date
			 , mmt.creation_date cr_date
			 , fu.description cr_by
			 , '**'
			 , gcc.segment1 || '*' || gcc.segment2 || '*' || gcc.segment3 || '*' || gcc.segment4 || '*' || gcc.segment5 || '*' || gcc.segment6 chg_acct
			 , mta.base_transaction_value mta_value
		  from inv.mtl_material_transactions mmt
		  join inv.mtl_system_items_b msib on mmt.inventory_item_id = msib.inventory_item_id
		   and mmt.organization_id = msib.organization_id 
		  join inv.mtl_transaction_types mtt on mmt.transaction_type_id = mtt.transaction_type_id 
		  join inv.mtl_transaction_accounts mta on mmt.transaction_id = mta.transaction_id 
		  join gl.gl_code_combinations gcc on mta.reference_account = gcc.code_combination_id 
		  join applsys.fnd_user fu on mmt.created_by = fu.user_id
		 where 1 = 1
		   and mmt.creation_date >= '01-NOV-2012'
		   and mmt.creation_date < '01-DEC-2012'
		   and costed_flag = 'E'
		   and mmt.organization_id = 123
	  order by mmt.organization_id;
