/*
File Name: po-approval-groups.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- PO APPROVAL GROUPS
-- ##################################################################

		select pcga.control_group_name
			 , pcga.description control_group_description
			 , pcga.last_update_date
			 , flv1.meaning
			 , flv2.meaning
			 , pcr.amount_limit
			 , case when pcr.object_code = 'ACCOUNT_RANGE' then
					pcr.segment1_low || '.' || pcr.segment2_low || '.' || pcr.segment3_low || '.' || pcr.segment4_low || '.' || pcr.segment5_low
					else null
			   end low_value
			 , case when pcr.object_code = 'ACCOUNT_RANGE' then
					pcr.segment1_high || '.' || pcr.segment2_high || '.' || pcr.segment3_high || '.' || pcr.segment4_high || '.' || pcr.segment5_high
					else null
			   end high_value
		  from po_control_groups_all pcga 
		  join po.po_control_rules pcr on pcga.control_group_id = pcr.control_group_id
		  join fnd_lookup_values_vl flv1 on pcr.object_code = flv1.lookup_code and flv1.lookup_type = 'CONTROLLED_OBJECT'
		  join fnd_lookup_values_vl flv2 on pcr.rule_type_code = flv2.lookup_code and flv2.lookup_type = 'CONTROL_TYPE'
		 where 1 = 1
		   -- and pcr.object_code = 'DOCUMENT_TOTAL'
		   -- and control_group_name like 'XX%'
		   and 1 = 1
	  order by pcga.control_group_name
			 , flv1.meaning desc;
