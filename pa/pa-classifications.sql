/*
File Name: pa-classifications.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- CLASSIFICATIONS - DETAILS
-- CLASSIFICATIONS - SUMMARY
-- CLASSIFICATIONS - COUNT PER CATEGORY
-- CLASSIFICATIONS - BASE TABLE (RATHER THAN PA_PROJECT_CLASSES_V VIEW)

*/

-- ##################################################################
-- CLASSIFICATIONS - DETAILS
-- ##################################################################

		select ppa.segment1
			 , ppa.name
			 , ppta.project_type
			 , ppa.creation_date pa_cr_date
			 , pps.project_system_status_code sys_stat
			 , ppcv.class_category
			 , ppcv.class_code
			 , ppcv.creation_date class_link_created
		  from apps.pa_project_classes_v ppcv
		  join pa.pa_projects_all ppa on ppcv.project_id = ppa.project_id
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
	 left join pa.pa_project_types_all ppta on ppa.project_type = ppta.project_type and ppa.org_id = ppta.org_id
		 where 1 = 1
		   and ppa.segment1 = 'P123456'
		   -- and ppcv.class_code = 'Super Massive Cheeses'
		   -- and ppcv.class_category = 'Reporting Requirements'
		   -- and pps.project_system_status_code = 'APPROVED'
	  order by ppcv.creation_date desc;

-- ##################################################################
-- CLASSIFICATIONS - SUMMARY
-- ##################################################################

		select ppcv.class_category
			 , ppcv.class_code
			 , ppta.project_type
			 , count(*) ct
		  from apps.pa_project_classes_v ppcv
		  join pa.pa_projects_all ppa on ppcv.project_id = ppa.project_id
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join pa.pa_project_types_all ppta on ppa.project_type = ppta.project_type and ppa.org_id = ppta.org_id
		 where 1 = 1
		   -- and ppa.segment1 = 'P123456'
		   -- and ppcv.class_code = 'Super Massive Cheeses'
		   -- and pps.project_system_status_code = 'APPROVED'
	  group by ppcv.class_category
			 , ppcv.class_code
			 , ppta.project_type;

-- ##################################################################
-- CLASSIFICATIONS - COUNT PER CATEGORY
-- ##################################################################

		select class_category
			 , class_code
			 , count (*) ct
		  from apps.pa_project_classes_v ppcv
	  group by class_category
			 , class_code
	  order by 3 desc;

-- ##################################################################
-- CLASSIFICATIONS - BASE TABLE (RATHER THAN PA_PROJECT_CLASSES_V VIEW)
-- ##################################################################

		select class.project_id
			 , class.class_category
			 , class.class_code
			 , class.last_update_date
			 , class.last_updated_by
			 , class.creation_date
			 , class.created_by
			 , class.last_update_login
			 , code.description code_description
			 , class.code_percentage
			 , class.object_id
			 , class.object_type
			 , class.attribute_category
			 , class.record_version_number
		  from pa_project_classes class
		  join pa_class_codes code on class.class_category = code.class_category and class.class_code = code.class_code;
