/*
File Name: gl-web-adi.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- JOB DETAILS
-- WEB ADI INTEGRATORS
-- WEB ADI LAYOUTS
-- INTEGRATORS AND LAYOUTS
-- INTEGRATORS AND LAYOUTS -- SIMPLE COUNT

*/

-- ##################################################################
-- JOB DETAILS
-- ##################################################################

		select bauj.job_id
			 , fat.application_name app
			 , bauj.integrator_code
			 , bit.user_name
			 , bauj.upload_state
			 , bauj.translated_upload_state
			 , bauj.job_creation_date
			 , bauj.job_start_date
			 , bauj.job_end_date
			 , bauj.creation_date cr_date
			 , fu.description cy_by
			 , '########################'
			 , bauj.*
		  from bne.bne_async_upload_jobs bauj
			 , bne.bne_integrators_tl bit
			 , applsys.fnd_user fu
			 , applsys.fnd_application_tl fat
		 where bauj.integrator_code = bit.integrator_code
		   and bauj.created_by = fu.user_id
		   and bauj.integrator_app_id = fat.application_id
		   and bauj.creation_date > '20-MAY-2015'
		   and fu.user_name = 'SYSADMIN';

-- ##################################################################
-- WEB ADI INTEGRATORS
-- ##################################################################

		select *
		  from bne_integrators_tl
		 where integrator_code = 'JOURNALS_120';

-- ##################################################################
-- WEB ADI LAYOUTS
-- ##################################################################

select * from bne_layouts_b;
select * from bne_layouts_vl;

-- ##################################################################
-- INTEGRATORS AND LAYOUTS
-- ##################################################################

		select fa.application_short_name appl, bit.application_id
			 , bit.integrator_code
			 , bit.user_name
			 , bit.creation_date
			 , blb.layout_code
			 , blt.user_name user_name_tl
		  from bne.bne_integrators_tl bit
			 , bne.bne_layouts_b blb
			 , bne.bne_layouts_tl blt
			 , applsys.fnd_application fa
		 where bit.integrator_code = blb.integrator_code
		   and blb.layout_code = blt.layout_code
		   and bit.application_id = fa.application_id
		   and bit.integrator_code = 'JOURNALS_120';

-- ##################################################################
-- INTEGRATORS AND LAYOUTS -- SIMPLE COUNT
-- ##################################################################

		select fa.application_short_name appl
			 , bit.integrator_code
			 , count(*) ct
		  from bne.bne_integrators_tl bit
			 , bne.bne_layouts_b blb
			 , bne.bne_layouts_tl blt
			 , applsys.fnd_application fa
		 where bit.integrator_code = blb.integrator_code
		   and blb.layout_code = blt.layout_code
		   and bit.application_id = fa.application_id
	  group by fa.application_short_name
			 , bit.integrator_code
	  order by 2;
