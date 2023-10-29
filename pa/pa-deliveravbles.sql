/*
File Name: pa-deliveravbles.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- PA DELIVERABLES - TABLE DUMPS
-- PA DELIVERABLES - DETAILS

*/

-- ##################################################################
-- PA DELIVERABLES - TABLE DUMPS
-- ##################################################################

select * from oke_deliverables_b;
select * from oke_deliverables_tl;
select * from okc_deliverable_types_tl;

-- ##################################################################
-- PA DELIVERABLES - DETAILS
-- ##################################################################

		select ppa.segment1 project
			 , ppa_template.segment1 template
			 , odb.creation_date deliv_created
			 , fu.user_name deliv_created_by
			 , odb.deliverable_number
			 , ppta.project_type "project type"
		  from oke_deliverables_b odb
		  join pa_projects_all ppa on odb.project_id = ppa.project_id
		  join fnd_user fu on odb.created_by = fu.user_id
	 left join pa.pa_projects_all ppa_template on ppa.created_from_project_id = ppa_template.project_id
	 left join pa.pa_project_types_all ppta on ppa.project_type = ppta.project_type and ppa.org_id = ppta.org_id
	  order by odb.creation_date desc;
