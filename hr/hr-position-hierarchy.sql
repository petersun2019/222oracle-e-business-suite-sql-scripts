/*
File Name:		hr-position-hierarchy.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- TABLE DUMPS
-- POSITION HIERARCHY ATTEMPT 1
-- POSITION HIERARCHY ATTEMPT 2

*/

-- ##################################################################
-- TABLE DUMPS
-- ##################################################################

select * from per_org_structure_elements_v;
select * from per_pos_structure_elements_v where parent_position_id = 123;
select * from per_pos_structure_elements_v where parent_position_id = 345;
select * from per_pos_structure_elements_v where subordinate_position_id = 9876;
select * from apps.per_positions where position_id = 123;
select * from apps.per_positions where name = 'Senior Cheese Taster';

-- ##################################################################
-- POSITION HIERARCHY ATTEMPT 1
-- Need to provide Position Structure Version ID - can use SQLs above to find them
-- ##################################################################

		select lpad(' ', 5 *(level - 1)) || pos.name name
			 , pos.name org_name
			 , pos.position_id
			 , haou.name org
			 , level
			 , (select count(*) from apps.per_all_assignments_f where position_id = pos.position_id and trunc(sysdate) between effective_start_date and effective_end_date) headcount
		  from apps.per_pos_structure_elements_v ppse
			 , apps.per_positions pos
			 , apps.hr_locations_all hla
			 , apps.hr_all_organization_units haou
		 where ppse.pos_structure_version_id = 12345
		   and ppse.subordinate_position_id = pos.position_id
		   and pos.location_id = hla.location_id(+)
		   and pos.organization_id = haou.organization_id(+)
	connect by prior ppse.subordinate_position_id = ppse.parent_position_id
		   and ppse.pos_structure_version_id = 9876
	start with ppse.parent_position_id = 123
		   and ppse.pos_structure_version_id = 12345
order siblings by ppse.subordinate_position_id;

-- ##################################################################
-- POSITION HIERARCHY ATTEMPT 2
-- Need to provide Position Structure Version ID - can use SQLs above to find them
-- ##################################################################

		select lpad(' ', 1 *(level - 1)) || pos.name name
			 , pos.name org_name
			 , pos.position_id
			 , level
		  from apps.per_pos_structure_elements_v ppse
			 , apps.per_positions pos
		 where ppse.pos_structure_version_id = 12345
		   and ppse.subordinate_position_id = pos.position_id
	connect by prior ppse.subordinate_position_id = ppse.parent_position_id
		   and ppse.pos_structure_version_id = 12345
	start with ppse.parent_position_id = 9876
		   and ppse.pos_structure_version_id = 12345
order siblings by ppse.subordinate_position_id;
