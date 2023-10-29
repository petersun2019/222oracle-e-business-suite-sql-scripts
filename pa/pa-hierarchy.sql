/*
File Name: pa-hierarchy.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- GET LIST OF ORGANIZATION HIERARCHIES
-- PROJECT HIERARCHY TREE VIEW
-- PROJECT HIERARCHY FLAT VIEW
-- SAMPLE DATA HIERARCHY sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts-- BASIC HR ORGS
-- HR ORG CLASSIFICATIONS

*/

-- ##################################################################
-- GET LIST OF ORGANIZATION HIERARCHIES
-- ##################################################################

/*
GET THE ORGANIZATION_STRUCTURE_ID FROM THIS SQL, TO USE IN SQLS BELOW
*/

select * from apps.per_organization_structures_v;

-- ##################################################################
-- PROJECT HIERARCHY TREE VIEW
-- ##################################################################

		select lpad (' ', 10 * (level - 1)) || pose.d_child_name name
			 , level
			 , org.type
			 , fu.description org_created_by
			 , fu.user_name cr_by
			 , org.creation_date cr_date
			 , org.last_update_date up_date
			 , fu2.description up_by
			 , pose.last_update_date
		  from apps.per_org_structure_elements_v pose
		  join hr.hr_all_organization_units org on pose.organization_id_child = org.organization_id
		  join applsys.fnd_user fu on org.created_by = fu.user_id
		  join applsys.fnd_user fu2 on org.last_updated_by = fu2.user_id
		 where pose.org_structure_version_id = 123 -- GET ID FROM PER_ORGANIZATION_STRUCTURES_V
		   -- and org.last_update_date > '01-JUN-2016'
	start with pose.organization_id_parent = 0
	connect by prior pose.organization_id_child = pose.organization_id_parent
		   -- and level = 3
		   and 1 = 1;

-- ##################################################################
-- PROJECT HIERARCHY FLAT VIEW
-- ##################################################################

		select org.name hr_org
			 , pose.org_structure_element_id
			 , pose.business_group_id
			 , pose.organization_id_parent
			 , pose.d_parent_name
			 , pose.org_structure_version_id
			 , pose.organization_id_child
			 , pose.d_child_name
		  from apps.per_org_structure_elements_v pose
		  join hr.hr_all_organization_units org on pose.organization_id_child = org.organization_id
		 where pose.org_structure_version_id = 123;

-- ##################################################################
-- SAMPLE DATA HIERARCHY sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts-- ##################################################################

with sample_data as
(select 159 organization_id_parent, 'ABC CHEESE' d_parent_name, 2504 organization_id_child, 'ABC CHEESE Blue' d_child_name from dual union all
		select 159, 'ABC CHEESE', 2505, 'ABC CHEESE Green' from dual union all
		select 159, 'ABC CHEESE', 2506, 'ABC CHEESE Other' from dual union all
		select 159, 'ABC CHEESE', 2507, 'ABC CHEESE Smelly' from dual union all
		select 1944, 'ABC CHEESE', 159, 'ABC CHEESE' from dual union all
		select 159, 'ABC CHEESE', 398, 'ABC CHEESE Sock Smell' from dual union all
		select 159, 'ABC CHEESE', 462, 'ABC CHEESE (Fresh)' from dual)
		select lpad (' ', 10 * (level - 1)) || d_child_name name
			 , level from sample_data
	start with organization_id_parent = 1944
	connect by prior organization_id_child = organization_id_parent;

-- ##################################################################
-- BASIC HR ORGS
-- ##################################################################

		select haou.name hr_org
			 , rtrim (substr (haou.name, 1, 4)) alpha
			 , haou.type type_
			 , haou.attribute1 dff
			 , haou.creation_date cr
			 , fu1.description cr_by
			 , haou.last_update_date up
			 , fu2.description up_by
		  from hr.hr_all_organization_units haou
		  join applsys.fnd_user fu1 on haou.created_by = fu1.user_id
		  join applsys.fnd_user fu2 on haou.last_updated_by = fu2.user_id
		 where haou.attribute1 is not null
		   -- and regexp_like (substr (name, 1, 3), '[A-Z]{3}')
		   and haou.name = 'Office Of The Cheese Chief'
		   and 1 = 1;

-- ##################################################################
-- HR ORG CLASSIFICATIONS
-- ##################################################################

		select haou.name
			 , hoiv.org_information1_meaning classification
			 , hoiv.org_information2_meaning enabled
			 , hoiv.creation_date cr_date
			 , fu1.description cr_by
			 , hoiv.last_update_date up_date
			 , fu2.description up_by
		  from apps.hr_organization_information_v hoiv
		  join hr.hr_all_organization_units haou on hoiv.organization_id = haou.organization_id
		  join applsys.fnd_user fu1 on hoiv.created_by = fu1.user_id
		  join applsys.fnd_user fu2 on hoiv.last_updated_by = fu2.user_id
		 where haou.name = 'Office Of The Cheese Chief';
