/*
File Name: sa-personalizations-forms.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- FORMS PERSONALISATIONS 1
-- FORMS PERSONALISATIONS 2
-- FORMS PERSONALISATIONS 3
-- FORMS PERSONALISATIONS - PERSONALISATION CONTEXT

*/

-- ##################################################################
-- FORMS PERSONALISATIONS 1
-- ##################################################################

		select *
		  from fnd_form_custom_rules ffcr
		 where ffcr.form_name = 'FNDSCSGN'
		   -- and ffcr.function_name = 'AR_ARXTWMAI_HEADER'
		   -- and ffcr.sequence in (85, 89, 91)
		   and 1 = 1;

-- ##################################################################
-- FORMS PERSONALISATIONS 2
-- ##################################################################

		select ffft.user_function_name "user form name"
			 , ffcr.sequence
			 , ffcr.description
			 , ffcr.rule_type
			 , ffcr.enabled
			 , ffcr.trigger_event
			 , ffcr.trigger_object
			 , ffcr.condition
			 , ffcr.fire_in_enter_query
			 , ffcr.creation_date
			 , fu.description created_by
		  from apps.fnd_form_custom_rules ffcr
	 left join apps.fnd_form_functions_vl ffft on ffcr.id = ffft.function_id
		  join applsys.fnd_user fu on ffcr.created_by = fu.user_id 
		 where ffcr.form_name = 'ARXTWMAI'
		   and ffcr.function_name like '%ARXTWMAI%'
		   and ffcr.sequence in (85, 89, 91)
	  order by ffcr.creation_date desc;

-- ##################################################################
-- FORMS PERSONALISATIONS 3
-- ##################################################################

		select ffcr.id
			 , ffcr.form_name
			 , ffcr.function_name
			 , ffcr.sequence
			 , ffcr.trigger_event
			 , ffcr.trigger_object
			 , ffcr.description
			 , ffca.sequence action_seq
			 , ffca.object_type
			 , ffca.property_value
			 , ffca.target_object
			 , ffcpl.property_name
		  from fnd_form_custom_rules ffcr
		  join fnd_form_custom_actions ffca on ffcr.id = ffca.rule_id
		  join fnd_form_custom_prop_list ffcpl on ffca.property_name = ffcpl.property_id
		 where 1 = 1
		   and ffcr.function_name like 'AR_ARXTWMAI%'
		   -- and ffcpl.property_name like 'REQ%'
		   -- and ffcr.id = 645
		   and 1 = 1;

-- ##################################################################
-- FORMS PERSONALISATIONS - PERSONALISATION CONTEXT
-- ##################################################################

		select ffcs.rule_id
			 , frt.responsibility_id
			 , ffcr.sequence seq
			 , ffcr.form_name
			 , ffcr.trigger_object
			 , frt.responsibility_name
			 -- , ffcr.description
		  from fnd_form_custom_rules ffcr
		  join fnd_form_custom_scopes ffcs on ffcr.id = ffcs.rule_id
		  join fnd_responsibility_tl frt on ffcs.level_value = frt.responsibility_id
		 where 1 = 1
		   -- and ffcs.rule_id = 231
		   and ffcs.level_id = 30
		   and ffcr.form_name = 'ARXTWMAI'
		   -- and frt.responsibility_name = 'Receivables Super User'
		   -- and frt.responsibility_name like '%Receivables%'
	  order by ffcr.sequence;
