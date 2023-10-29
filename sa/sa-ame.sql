/*
File Name: sa-ame.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- TABLE DUMPS
-- AME TRANSACTION TYPES 1
-- AME TRANSACTION TYPES 2
-- RULES

*/

-- ##################################################################
-- TABLE DUMPS
-- ##################################################################

select * from apps.ame_calling_apps_vl;
select * from apps.ame_rule_usages;
select * from apps.ame_rules where ;
select * from apps.ame_rules_tl;
select * from apps.ame_attributes where name like '%CHEESE%';

-- ##################################################################
-- AME TRANSACTION TYPES 1
-- ##################################################################

		select acav.application_id application_id
			 , acav.application_name transaction_type_description
			 , fav.application_name fnd_application_name
			 , acav.transaction_type_id transaction_type_id
			 , acav.fnd_application_id fnd_application_id
		  from ame_calling_apps_vl acav
			 , fnd_application_vl fav
		 where sysdate between acav.start_date
		   and nvl(acav.end_date - (1/86400),sysdate)
		   and acav.fnd_application_id = fav.application_id;

-- ##################################################################
-- AME TRANSACTION TYPES 2
-- ##################################################################

		select apl.application_name transaction_type
			 , r.description rule
			 , r.creation_date
			 , r.last_update_date
			 , condition conditions
		  from (distinct rule_id
			 , description 
			 , creation_date
			 , last_update_date
		  from ame_rules
		 where sysdate between start_date and end_date) r
			 , (select distinct rule_id
							  , listagg (ame_utility_pkg.get_condition_description (acu.condition_id), chr(10)) within group (order by acu.condition_id) over (partition by acu.rule_id) condition from ame_condition_usages acu) cu
			 , ame_rule_usages aru
			 , (select application_name
					 , application_id 
				  from ame_calling_apps_vl acav
				 where 1 = 1
				   -- and application_name = 'Purchase Requisition Approval'
				   and rownum = 1) apl
		 where r.rule_id = cu.rule_id
		   and aru.rule_id = r.rule_id
		   and aru.item_id = apl.application_id
	  order by r.last_update_date desc;

-- ##################################################################
-- RULES
-- ##################################################################

		select ame.rulename
			 , ame.creation_date
			 , ame.condition_and_action "condition/action"
			 , ame.val "condition_desc"
		  from (select r.description rulename
			 , r.creation_date
			 , condition_id
			 , 'Condition' condition_and_action
			 , ame_utility_pkg.get_condition_description (condition_id) val
			 , null action_type
		  from ame_rules_tl rtl
			 , ame_rules r
			 , ame_condition_usages cu
		 where r.rule_id = rtl.rule_id
		   and cu.rule_id = r.rule_id
		   and rtl.language = userenv('lang')
		union all
		select distinct r.description rulename
			 , r.creation_date
			 , a.action_id
			 , 'Action' condition_and_action
			 , atl.description val
			 , actl.user_action_type_name action_type
		  from ame_rules_tl rtl
			 , ame_rules r
			 , ame_action_usages au
			 , ame_actions a
			 , ame_actions_tl atl
			 , ame_action_types act
			 , ame_action_types_tl actl
		 where r.rule_id = rtl.rule_id
		   and au.rule_id = r.rule_id
		   and rtl.language = userenv('lang')
		   and au.action_id = a.action_id
		   and a.action_id = atl.action_id
		   and act.action_type_id = actl.action_type_id
		   and act.action_type_id = a.action_type_id) ame
		 where 1 = 1
		   -- and ame_utility_pkg.get_condition_description (condition_id) like '%&P_AME_CONDITION%'
	  order by rulename
			 , condition_and_action desc;
