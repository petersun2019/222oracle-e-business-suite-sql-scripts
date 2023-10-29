/*
File Name: pa-burden-shedules.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- BURDEN SCHEDULES TABLE DUMPS
-- BURDEN SCHEDULES AGAINST PROJECTS
-- BURDEN SCHEDULES - COUNT SUMMARY
-- BURDEN SCHEDULES AGAINST TASKS
-- BURDEN SCHEDULES - DETAILS ON PROJECT
-- BURDEN SCHEDULES - DETAILS ON TASK

*/

-- ##################################################################
-- BURDEN SCHEDULES TABLE DUMPS
-- ##################################################################

select * from pa_ind_rate_schedules_all_bg;
select * from pa_ind_cost_multipliers;
select * from pa_ind_compiled_sets;
select * from pa_ind_rate_sch_revisions where ind_rate_sch_id in (123456,123457);
select * from pa_ind_cost_multipliers where ind_rate_sch_revision_id in (123456,123457) and multiplier <> 0;

-- ##################################################################
-- BURDEN SCHEDULES AGAINST PROJECTS
-- ##################################################################

		select pirsab.ind_rate_sch_name
			 , trunc(pirsab.creation_date) creation_date
			 , trunc(pirsab.start_date_active) start_date_active
			 , trunc(pirsab.end_date_active) end_date_active
			 , tbl_ct.ct count
			 , tbl_ct_open.ct count_open
			 , trunc(tbl_ct.latest) latest
		  from pa.pa_ind_rate_schedules_all_bg pirsab
			 , ( select pabs2.ind_rate_sch_id
			 , pabs2.ind_rate_sch_name
			 , count (*) ct
			 , max (ppa.creation_date) latest
		  from pa.pa_projects_all ppa
		  join pa.pa_ind_rate_schedules_all_bg pabs2 on ppa.cost_ind_rate_sch_id = pabs2.ind_rate_sch_id
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code 
	  group by pabs2.ind_rate_sch_id
			 , pabs2.ind_rate_sch_name) tbl_ct
			 , ( select pabs2.ind_rate_sch_id
			 , pabs2.ind_rate_sch_name
			 , count (*) ct
			 , max (ppa.creation_date) latest
		  from pa.pa_projects_all ppa
		  join pa.pa_ind_rate_schedules_all_bg on ppa.cost_ind_rate_sch_id = pabs2.ind_rate_sch_id
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		 where pps.project_status_name not like '%Closed%'
	  group by pabs2.ind_rate_sch_id
			 , pabs2.ind_rate_sch_name) tbl_ct_open 
		 where pirsab.ind_rate_sch_id = tbl_ct.ind_rate_sch_id(+)
		   and pirsab.ind_rate_sch_id = tbl_ct_open.ind_rate_sch_id(+)
	  order by 1;

-- ##################################################################
-- BURDEN SCHEDULES - COUNT SUMMARY
-- ##################################################################

		select pabs2.ind_rate_sch_name
			 , count (*) ct
			 , max (ppa.creation_date) latest
		  from pa.pa_projects_all ppa
		  join pa.pa_ind_rate_schedules_all_bg pabs2 on pabs2.ind_rate_sch_id = ppa.cost_ind_rate_sch_id
	  group by pabs2.ind_rate_sch_name;

-- ##################################################################
-- BURDEN SCHEDULES AGAINST TASKS
-- ##################################################################

		select pirsab.ind_rate_sch_name
			 , trunc(pirsab.creation_date) creation_date
			 , trunc(pirsab.start_date_active) start_date_active
			 , trunc(pirsab.end_date_active) end_date_active
			 , tbl_ct.ct count
			 , tbl_ct_open.ct count_open
			 , trunc(tbl_ct.latest) latest
		  from pa.pa_ind_rate_schedules_all_bg pirsab
			 , ( select pabs2.ind_rate_sch_id
			 , pabs2.ind_rate_sch_name
			 , count (*) ct
			 , max (pt.creation_date) latest
		  from pa.pa_tasks pt 
		  join pa.pa_projects_all ppa on ppa.project_id = pt.project_id
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join pa.pa_ind_rate_schedules_all_bg pabs2 on pabs2.ind_rate_sch_id = pt.cost_ind_rate_sch_id
	  group by pabs2.ind_rate_sch_id
			 , pabs2.ind_rate_sch_name) tbl_ct
			 , ( select pabs2.ind_rate_sch_id
			 , pabs2.ind_rate_sch_name
			 , count (*) ct
			 , max (pt.creation_date) latest
		  from pa.pa_tasks pt
		  join pa.pa_projects_all ppa on ppa.project_id = pt.project_id
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join pa.pa_ind_rate_schedules_all_bg pabs2 on pabs2.ind_rate_sch_id = pt.cost_ind_rate_sch_id
		 where pps.project_status_name not like '%Closed%'
	  group by pabs2.ind_rate_sch_id
			 , pabs2.ind_rate_sch_name) tbl_ct_open 
		 where pirsab.ind_rate_sch_id = tbl_ct.ind_rate_sch_id(+)
		   and pirsab.ind_rate_sch_id = tbl_ct_open.ind_rate_sch_id(+)
	  order by 2;

-- ##################################################################
-- BURDEN SCHEDULES - DETAILS ON PROJECT
-- ##################################################################

		select pabs2.ind_rate_sch_id
			 , pabs2.ind_rate_sch_name
			 , ppa.segment1
		  from pa.pa_projects_all ppa
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join pa.pa_ind_rate_schedules_all_bg pabs2 on pabs2.ind_rate_sch_id = ppa.cost_ind_rate_sch_id
		 where ppa.segment1 = 'P123456';

-- ##################################################################
-- BURDEN SCHEDULES - DETAILS ON TASK
-- ##################################################################

		select pabs2.ind_rate_sch_name pa_rate
			 , pabs1.ind_rate_sch_name task_rate
			 , pabs1.ind_rate_sch_id
			 , ppa.segment1
			 , pt.task_number
			 , pt.labor_sch_type
			 , pt.non_labor_sch_type
			 , ppta.project_type proj_type
			 , '##################'
			 , pabs1.*
		  from pa.pa_tasks pt
		  join pa.pa_projects_all ppa on ppa.project_id = pt.project_id
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join pa.pa_project_types_all ppta on ppa.project_type = ppta.project_type and ppa.org_id = ppta.org_id
		  join pa.pa_ind_rate_schedules_all_bg pabs1 on pabs1.ind_rate_sch_id = pt.cost_ind_rate_sch_id
		 where 1 = 1
		   and ppa.segment1 = 'P123456'
		   and 1 = 1;

		select pabs1.ind_rate_sch_name task_rate
			 , pabs1.ind_rate_sch_id
			 , ppa.segment1
			 , pt.task_number
			 , pt.labor_sch_type
			 , pt.non_labor_sch_type
			 , ppta.project_type proj_type
			 , '##################'
			 , picm.ind_cost_code
			 , picm.multiplier
		  from pa.pa_tasks pt
		  join pa.pa_projects_all ppa on ppa.project_id = pt.project_id
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join pa.pa_project_types_all ppta on ppa.project_type = ppta.project_type and ppa.org_id = ppta.org_id
	 left join pa.pa_ind_rate_schedules_all_bg pabs1 on pabs1.ind_rate_sch_id = pt.cost_ind_rate_sch_id
	 left join pa_ind_rate_sch_revisions pirsr on pirsr.ind_rate_sch_id = pabs1.ind_rate_sch_id
	 left join pa_ind_cost_multipliers picm on picm.ind_rate_sch_revision_id = pirsr.ind_rate_sch_revision_id and picm.multiplier <> 0
		 where 1 = 1
		   and ppa.segment1 = 'P123456'
		   and ppa.project_status_code = 'APPROVED'
		   and sysdate between ppa.start_date and ppa.completion_date
		   and ppta.project_type = 'Cheese'
		   -- and pabs1.ind_rate_sch_name = 'UO Zero Multiplier'
		   and 1 = 1;
