/*
File Name: gl-journal-categories-and-sources.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- JOURNAL CATEGORIES
-- JOURNAL SOURCES

*/

-- ##################################################################
-- JOURNAL CATEGORIES
-- ##################################################################

		select gjct.je_category_name
			 , gjct.user_je_category_name
			 , gjct.creation_date cr_dt
			 , gjct.description
			 , gjct.je_category_key
			 , fu1.user_name cr_by
			 , gjct.last_update_date up_dt
			 , fu2.user_name up_by
		  from gl.gl_je_categories_tl gjct 
	 left join applsys.fnd_user fu1 on gjct.created_by = fu1.user_id
	 left join applsys.fnd_user fu2 on gjct.last_updated_by = fu2.user_id
		 where 1 = 1
		   -- and fu2.user_name != 'AUTOINSTALL' 
		   -- and gjct.user_je_category_name like 'XXCUST%'
	  order by gjct.creation_date desc;

-- ##################################################################
-- JOURNAL SOURCES
-- ##################################################################

		select gjst.je_source_name
			 , gjst.user_je_source_name
			 , gjst.creation_date cr_dt
			 , gjst.description
			 -- , gjst.je_source_key
			 , fu1.user_name cr_by
			 , gjst.last_update_date up_dt
			 , fu2.user_name up_by
			 , gjst.journal_approval_flag
			 , gjst.override_edits_flag
		  from gl_je_sources_tl gjst 
	 left join fnd_user fu1 on gjst.created_by = fu1.user_id
	 left join fnd_user fu2 on gjst.last_updated_by = fu2.user_id
		 where 1 = 1
		   -- and gjst.description = 'Budget Journal'
		   -- and gjst.user_je_source_name like 'XXCUST%'
		   -- and gjst.override_edits_flag = 'Y'
		   -- and fu2.user_name != 'AUTOINSTALL' 
	  order by gjst.creation_date desc;
