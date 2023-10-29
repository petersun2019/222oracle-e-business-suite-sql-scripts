/*
File Name: sa-workflows.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- WORKFLOWS FOR THE PAST X NUMBER OF DAYS
-- PASSWORD RESET WORKFLOW COUNTS
-- OPEN WORKFLOW COUNT PER ITEM TYPE
-- COUNT SUMMARY
-- ATTRIBUTE VALUES FOR SPECIFIC WORKFLOW
-- SEQUENCE OF ACTIVITY STATUSES
-- WORKFLOW NAMES
-- COUNTS PER ITEM TYPE
-- DEFAULT ATTRIBUTES FOR A WORKFLOW
-- SEARCH FOR STUCK CHANGE WORKFLOWS
-- REQ CHANGE REQUESTS
-- REQ CHANGE REQUESTS
-- GL > FINANCIALS > FLEXFIELDS > KEY > ACCOUNTS

*/

-- ##################################################################
-- WORKFLOWS FOR THE PAST X NUMBER OF DAYS
-- ##################################################################

		select wi.*
		  from wf_items wi
		 where 1 = 1
		   -- and item_type = 'HRSSA'
		   -- and end_date is null
		   -- and item_type not like 'HRS%'
		   -- and item_type not like 'WFE%'
		   -- and item_type = 'REQAPPRV'
		   and begin_date > trunc(sysdate) - 1
		   -- and owner_role = 'USER123'
		   -- and user_key = '20220302 XX'
		   -- and begin_date >= '17-JAN-2022'
	  order by wi.begin_date desc;

-- ##################################################################
-- PASSWORD RESET WORKFLOW COUNTS
-- ##################################################################

		select decode(wi.item_type, 'UMXLHELP', 'Login Assistance', 'UMXUPWD', 'Helpdesk > Password Resets') password_type
			 , count(*) reset_count
			 , to_char(wi.begin_date, 'RRRR-MM-DD') the_date
		  from applsys.wf_items wi
		 where wi.item_type = 'UMXLHELP'
		   and wi.end_date is not null
		   and wi.begin_date > trunc(sysdate) - 30 -- last 30 days
		   -- and wi.begin_date >= '20-JUN-2015'
	  group by to_char(wi.begin_date, 'RRRR-MM-DD')
			 , decode(wi.item_type, 'UMXLHELP', 'Login Assistance', 'UMXUPWD', 'Helpdesk > Password Resets')
	  order by to_char(wi.begin_date, 'RRRR-MM-DD') desc;

-- ##################################################################
-- OPEN WORKFLOW COUNT PER ITEM TYPE
-- ################################################################*/

		select wi.item_type
			 , count(distinct wi.item_key)
			 , count(wi.item_key)
		  from applsys.wf_items wi
		  join applsys.wf_item_attribute_values wiav on wi.item_type = wiav.item_type
		   and wi.item_key = wiav.item_key
		 where wi.end_date is null
		   and wi.item_type in ('APVRMDER', 'CREATEPO', 'POAPPRV', 'POERROR', 'POWFPOAG', 'POWFRQAG', 'REQAPPRV', 'PORPOCHA', 'POREQCHA')
	  group by wi.item_type
	  order by 2 desc;

-- ##################################################################
-- COUNT SUMMARY
-- ##################################################################

		select wi.item_type
			 , witt.display_name
			 , (select count(item_key)
		  from applsys.wf_items wi_open
		 where wi_open.end_date is null
		   and wi_open.item_type = wi.item_type) open_workflows
			 , (select count(item_key)
		  from applsys.wf_items wi_closed
		 where wi_closed.end_date is not null
		   and wi_closed.item_type = wi.item_type) closed_workflows
			 , count(wi.item_key) total
		  from applsys.wf_items wi
		  join applsys.wf_item_types_tl witt on witt.name = wi.item_type
	  group by wi.item_type
			 , witt.display_name
	  order by wi.item_type;

-- ##################################################################
-- ATTRIBUTE VALUES FOR SPECIFIC WORKFLOW
-- ##################################################################

		select wi.item_type
			 , wi.item_key
			 , witt.display_name workflow_name
			 , wi.begin_date
			 -- , wi.end_date
			 , wiav.item_type
			 -- , wiav.item_key
			 , wiat.display_name
			 , wia.name
			 , wiav.text_value
			 , wiav.number_value
			 , wiav.date_value
		  from wf_item_attribute_values wiav 
	 left join wf_item_attributes wia on wiav.item_type = wia.item_type and wiav.name = wia.name
	 left join wf_item_attributes_tl wiat on wia.item_type = wiat.item_type and wia.name = wiat.name and wiat.language = userenv('lang')
	 left join wf_items wi on wi.item_type = wiav.item_type and wi.item_key = wiav.item_key and wi.begin_date > '13-JUL-2016'
		  join wf_item_types_tl witt on wi.item_type = witt.name and witt.language = userenv('lang')
		 where (wiav.text_value is not null or wiav.number_value is not null or wiav.date_value is not null)
		   and wiav.item_type = 'UMXLHELP'
		   and wiav.item_key in ('285527')
		   -- and wiav.item_key in ('5838665-116368')
		   -- and text_value in ('AABBCC','DDEEFF','ZZRRTT')
		   -- and wiav.item_key like 'WF%'
		   -- and wi.end_date is null
		   -- and wiav.item_key = '380851'
		   -- and wiav.item_key = '380407'
		   -- and wiav.number_value = 7419824
		   -- and wi.begin_date > '13-JUL-2016'
		   and 1 = 1;

-- ##################################################################
-- SEQUENCE OF ACTIVITY STATUSES
-- ##################################################################

/*
This can be used to return the sequence of Activities against a Workflow
*/

		select execution_time
			 , i.begin_date item_begin
			 , i.end_date item_end
			 , i.item_type
			 , ias.begin_date ias_begin
			 , ias.end_date ias_end
			 , ap.display_name || '/' || ac.display_name activity
			 , ias.activity_status status
			 , ias.activity_result_code result
			 , ias.assigned_user ias_user
			 , ias.item_key
		  from apps.wf_item_activity_statuses ias
		  join apps.wf_process_activities pa on pa.instance_id = ias.process_activity
		  join apps.wf_activities_vl ac on ac.item_type = pa.activity_item_type 
		   and ac.name = pa.activity_name
		  join apps.wf_activities_vl ap on ap.item_type = pa.process_item_type
		   and ap.name = pa.process_name 
		   and ap.version = pa.process_version
		  join apps.wf_items i on i.item_key = ias.item_key 
		 where i.item_type = 'POAPPRV'
		   and ias.item_key = '9191309-284983'
		   and i.begin_date >= ac.begin_date
		   and i.begin_date < nvl(ac.end_date, i.begin_date + 1)
		union all
		select execution_time
			 , i.begin_date item_begin
			 , i.end_date item_end
			 , i.item_type
			 , ias.begin_date ias_begin
			 , ias.end_date ias_end
			 , ap.display_name || '/' || ac.display_name activity
			 , ias.activity_status status
			 , ias.activity_result_code result
			 , ias.assigned_user ias_user
			 , ias.item_key
		  from apps.wf_item_activity_statuses_h ias 
		  join apps.wf_process_activities pa on pa.instance_id = ias.process_activity
		  join apps.wf_activities_vl ac on ac.item_type = pa.activity_item_type
		   and ac.name = pa.activity_name
		  join apps.wf_activities_vl ap on ap.item_type = pa.process_item_type
		   and ap.name = pa.process_name
		   and ap.version = pa.process_version
		  join apps.wf_items i on i.item_key = ias.item_key
		 where ias.item_type = 'POAPPRV'
		   and ias.item_key = '9191309-284983'
		   and i.item_type = 'POAPPRV'
		   and i.begin_date >= ac.begin_date
		   and i.begin_date < nvl(ac.end_date, i.begin_date + 1)
	  order by 2
			 , 1;

-- ##################################################################
-- WORKFLOW NAMES
-- ##################################################################

		select wiit.*
		  from apps.wf_item_types_tl wiit
		 where 1 = 1
		   and name in('POXWFRQA','POXWFPAG','POXWFRAG','POXWFRCV','POREQCHA','PODIFSUM','POSCHORD','POAPPAME','POXWFNOT','POXWFPOA','POPROTEST','POXWFPCA','POXCLOSEOUT','ICXBLKNT')
		   -- and lower(wiit.display_name) like '%receip%'
		   and 2 = 2;

-- ##################################################################
-- COUNTS PER ITEM TYPE
-- ##################################################################

		select wi.item_type
			 , wiit.display_name
			 -- , to_char(begin_date, 'YYYY-MM')
			 , count(*) ct
			 , min(begin_date)
			 , max(begin_date)
		  from applsys.wf_items wi
		  join applsys.wf_item_types_tl wiit on wi.item_type = wiit.name and wiit.language = userenv('lang')
		 where 1 = 1
		   and wi.begin_date > '16-AUG-2021'
		   -- and wi.begin_date < '18-DEC-2020'
		   -- and wi.end_date is null
		   -- and wi.item_type = 'GLBATCH'
	  group by wi.item_type
			 , wiit.display_name
			 -- , to_char(begin_date, 'YYYY-MM')
	  order by 2 desc;

-- ##################################################################
-- DEFAULT ATTRIBUTES FOR A WORKFLOW
-- ##################################################################

/*
You can use this SQL to find the default attributes defined against a Workflow Item Type
This can be useful to check the setup against a workflow
*/

		select wia.item_type
			 , wia.sequence sq
			 , wiat.display_name
			 , wiat.name
			 , wiat.description
			 , wia.text_default txt
			 , wia.number_default num
			 , wia.date_default dt
		  from apps.wf_item_attributes wia
		  join apps.wf_item_attributes_tl wiat on wia.item_type = wiat.item_type and wia.name = wiat.name
		 where wia.item_type = 'POAPPRV'
		   and (wia.text_default is not null
			or wia.number_default is not null
			or wia.date_default is not null)
	  order by wia.sequence;

-- ##################################################################
-- SEARCH FOR STUCK CHANGE WORKFLOWS
-- ##################################################################

/*
Useful as can be used to find activity a workflow is currently stuck at
*/

		select wi2.item_type
			 , wi2.item_key
			 , wi2.user_key req
			 , (select wiav.text_value from applsys.wf_item_attribute_values wiav join applsys.wf_item_attributes wia on wiav.item_type = wia.item_type and wiav.name = wia.name join applsys.wf_item_attributes_tl wiat on wia.item_type = wiat.item_type and wia.name = wiat.name join applsys.wf_items wi3 on wi3.item_type = wiav.item_type and wi3.item_key = wiav.item_key join applsys.wf_item_types_tl witt on wi3.item_type = witt.name and wiav.item_type = wi.item_type and wia.name = 'DOCUMENT_NUMBER' and wiav.item_key = wi.item_key) po
			 , (replace(replace(((select wiav.text_value from applsys.wf_item_attribute_values wiav join applsys.wf_item_attributes wia on wiav.item_type = wia.item_type and wiav.name = wia.name join applsys.wf_item_attributes_tl wiat on wia.item_type = wiat.item_type and wia.name = wiat.name join applsys.wf_items wi3 on wi3.item_type = wiav.item_type and wi3.item_key = wiav.item_key join applsys.wf_item_types_tl witt on wi3.item_type = witt.name and wiav.item_type = wi.item_type and wia.name = 'ERRORS_WITH_PO' and wiav.item_key = wi.item_key)),chr(10),''),chr(13),' ')) error
			 , (select count(*) from wf_notifications wn where wn.message_type = wi.item_type and wn.item_key = wi.item_key and wn.status = 'OPEN') open_notif
			 , (select notification_id from wf_notifications wn where wn.message_type = wi.item_type and wn.item_key = wi.item_key and wn.status = 'OPEN') open_notif_id
			 , (select count(*) from wf_notifications wn where wn.message_type = wi.item_type and wn.item_key = wi.item_key and wn.status = 'CLOSED') closed_notif
			 , (select ac.display_name activity
				  from apps.wf_item_activity_statuses ias 
				  join apps.wf_process_activities pa on pa.instance_id = ias.process_activity 
				  join apps.wf_activities_vl ac on ac.item_type = pa.activity_item_type and ac.name = pa.activity_name 
				  join apps.wf_activities_vl ap on ap.item_type = pa.process_item_type and ap.name = pa.process_name and ap.version = pa.process_version 
				  join apps.wf_items i on i.item_key = ias.item_key 
				 where i.item_type = 'PORPOCHA' 
				   -- and ias.item_key = 'INFORM_7885488_5588472' 
				   and ias.item_key = wi.item_key
				   and i.begin_date >= ac.begin_date
				   and i.begin_date < nvl(ac.end_date, i.begin_date + 1)
				   and execution_time = (select max(execution_time)
										   from apps.wf_item_activity_statuses ias 
										   join apps.wf_process_activities pa on pa.instance_id = ias.process_activity 
										   join apps.wf_activities_vl ac on ac.item_type = pa.activity_item_type and ac.name = pa.activity_name 
										   join apps.wf_activities_vl ap on ap.item_type = pa.process_item_type and ap.name = pa.process_name and ap.version = pa.process_version 
										   join apps.wf_items i on i.item_key = ias.item_key 
										  where i.item_type = 'PORPOCHA' 
										    -- and ias.item_key = 'INFORM_7885488_5588472' 
										    and ias.item_key = wi.item_key
										    and i.begin_date >= ac.begin_date
										    and i.begin_date < nvl(ac.end_date, i.begin_date + 1)
										)
			   ) latest_activity
			 , wi2.begin_date
			 , wi.item_type child_item_type
			 , wi.item_key child_item_key
			 , wi.root_activity child_root_activity
			 , wi.begin_date child_begin_date
		  from wf_items wi
		  join wf_items wi2 on wi.parent_item_type = wi2.item_type and wi.parent_item_key = wi2.item_key
		 where 1 = 1
		   and wi.item_type = 'PORPOCHA' 
		   and wi.item_key like 'INFORM%'
		   -- and wi.item_key = 'INFORM_7885488_5588472'
		   and wi.end_date is null
		   and wi.begin_date > '20-MAY-2018'
		   -- and wi.item_key not in (select wn.item_key from wf_notifications wn where wn.message_type = wi.item_type and wn.item_key = wi.item_key and wn.status = 'OPEN') -- no open notifications
		   and 1 = 1;

-- ##################################################################
-- REQ CHANGE REQUESTS
-- ##################################################################

/*
1. REQ CHANGED - ITEM TYPE CREATED: POREQCHA
2. REQ CHANGE FILTERS TO PO - ITEM TYPE CREATED: PORPOCHA
	- PORPOCHA MIGHT CONTAIN MULTIPLE ITEM KEYS - E.G.
		- INFORM_1859763_1563156
		- RESPONSE_1859763_1563159
3. IF THOSE ERROR, THEN THEY MIGHT TRIGGER WFERROR ITEM KEYS.
*/

/*
Active Changes
*/

		select distinct wf_item_type
			 , wf_item_key
			 , document_num
			 , ref_po_num
		  from po_change_requests 
		 where document_num in ('123456','123457','123458') 
		   and document_type = 'REQ'
		   and change_active_flag = 'Y';

/*
Check WF_ITEMS for Item Key from PO_CHANGE_REQUESTS
*/

select * from wf_items where item_key = '888215-1021889-775017';

-- ##################################################################
-- REQ CHANGE REQUESTS
-- ##################################################################

/*
You can use Tree Walking SQL to return the hierarchy of workflows triggered by a POREQCHA Change Request workflow
But the same process works for other workflows with hierarchies, not just POREQCHA
For example, you might have a POAPPRV PO Approval Workflow which has child error workflows
*/

		select lpad(' ', (level - 1) * 10, '_') || item_type || ' - ' || item_key hier
			 , level
			 , item_type
			 , item_key
			 , begin_date
			 , end_date
			 , user_key
			 , parent_item_type
			 , parent_item_key
		  from wf_items
	connect by prior item_key = parent_item_key
	start with item_type = 'POREQCHA' and item_key = '888215-1021889-775017';

-- ##################################################################
-- GL > FINANCIALS > FLEXFIELDS > KEY > ACCOUNTS
-- ##################################################################

/*
This shows the workflow item type, and the process used to generate the accounts.
*/

		select witt.display_name
			 , ffwp.*
		  from fnd_flex_workflow_processes ffwp
		  join wf_item_types_tl witt on ffwp.wf_item_type = witt.name;
