/*
File Name:		sa-business-events.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

FROM ABOUT THIS PAGE > CREATESUBSCRIPTIONVO
/ORACLE/APPS/FND/WF/BES/WEBUI/VIEWSUBSCRIPTIONPG 120.2.12010000.2

*/

-- ##################################################################
-- BUSINESS EVENTS ATTEMPT
-- ##################################################################

		select
			   es.guid as guid -- pk, guid
			 , es.system_guid as system_guid -- fk - wf_systems.guid
			 , sy.name as system_name -- system name
			 , l1.lookup_code as source_type -- local | external | any
			 , es.source_agent_guid -- fk to wf_agents
			 , decode(length(nvl(agt1.name,' ')),1,' ',agt1.name||'@'||sy.name) as source_agent_name -- sourceagent
			 , es.event_filter_guid -- fk to wf_events
			 , ev.name as event_filter_name -- event filter name
			 , es.phase -- execution order
			 , l2.lookup_code as status -- enabled | disabled
			 , es.rule_data -- key | message
			 , es.out_agent_guid -- outbound agent
			 , decode(length(nvl(agt2.name,' ')),1,' ',agt2.name||'@'||sy.name) as out_agent_name -- outagentname
			 , es.to_agent_guid -- destination agent
			 , decode(length(nvl(agt3.name,' ')),1,' ',agt3.name||'@'||sy.name) as to_agent_name -- to agent name
			 , es.priority -- 1-100 message priority
			 , es.rule_function -- code to run
			 , es.wf_process_type -- workflow item type
			 , it.display_name as item_display_name -- workflow item display name
			 , es.wf_process_name -- workflow process name
			 , decode(length(nvl(es.wf_process_type,' ')),1,' ',(es.wf_process_type||'/'||es.wf_process_name)) as process_display_name 
			 , es.parameters -- other parameters
			 , es.owner_name -- owning program
			 , es.owner_tag -- owning program tag
			 , es.expression -- sql rule
			 , es.description -- tl (on base table)
			 , 'N' as select_flag
			 , l1.meaning as source_type_meaning
			 , l2.meaning as status_meaning
			 , l3.lookup_code as custlevel
			 , l3.meaning as custlevel_meaning
			 , es.licensed_flag
			 , es.on_error_code
			 , es.action_code
			 , es.java_rule_func
			 , es.map_code
			 , es.standard_type
			 , es.standard_code
			 , (select meaning from fnd_lookups where lookup_code = nvl(es.action_code, 'CUSTOM_RG')) as action
			 , nvl(es.rule_function, 'java://'||es.java_rule_func) as rule_function_name
		  from
			   wf_event_subscriptions es
			 , wf_systems sy
			 , wf_events ev
			 , wf_agents agt1
			 , wf_agents agt2
			 , wf_agents agt3
			 , (select name, display_name from wf_item_types_tl where language=userenv('LANG')) it
			 , (select b.item_type, b.name process_name  from wf_activities b where b.runnable_flag = 'Y' and b.type = 'PROCESS' and sysdate between b.begin_date and nvl(b.end_date, sysdate)) ps
			 , fnd_lookups l1
			 , fnd_lookups l2
			 , wf_lookups l3
		 where
		   es.system_guid = sy.guid
		   and l1.lookup_code = es.source_type
		   and l1.lookup_type = 'WF_BES_SOURCE_TYPE'
		   and l2.lookup_code = es.status
		   and l2.lookup_type = 'FND_WF_BES_STATUS'
		   and es.event_filter_guid = ev.guid
		   and es.source_agent_guid = agt1.guid (+)
		   and es.out_agent_guid = agt2.guid (+)
		   and es.to_agent_guid = agt3.guid (+)
		   and es.wf_process_type = it.name (+)
		   and es.wf_process_name = ps.process_name (+)
		   and es.wf_process_type = ps.item_type (+)
		   and l3.lookup_code = es.customization_level
		   and l3.lookup_type = 'WF_CUSTOMIZATION_LEVEL'
		   -- and ev.name = 'oracle.apps.ap.payment'
		   -- and lower(es.rule_function) like 'xx%'
		   and lower(nvl(es.rule_function, 'java://'||es.java_rule_func)) like 'xx%'
		   -- and es.rule_function like '%remit%'
		   and 1 = 1;
