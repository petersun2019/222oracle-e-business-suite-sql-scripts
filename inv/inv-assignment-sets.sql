/*
File Name: inv-assignment-sets.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- INVENTORY ASSIGNMENT SETS
-- ##################################################################

		select mas.assignment_set_name assignment_set
			 , msa.assignment_set_id
			 , msa.organization_id
			 , haou.name
			 , count(*) ct
		  from mrp.mrp_sr_assignments msa
	 left join mrp.mrp_assignment_sets mas on msa.assignment_set_id = mas.assignment_set_id
		  join hr.hr_all_organization_units haou on msa.organization_id = haou.organization_id
	  group by mas.assignment_set_name
			 , msa.assignment_set_id
			 , msa.organization_id
			 , haou.name;