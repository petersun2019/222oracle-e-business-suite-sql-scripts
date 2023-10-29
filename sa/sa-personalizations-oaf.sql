/*
File Name:		sa-personalizations-oaf.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- OAF PERSONALISATIONS 1
-- OAF PERSONALISATIONS 2
-- OAF PERSONALISATIONS 3
-- OAF PERSONALISATIONS 4
-- OAF PERSONALISATIONS 5

*/

-- ##################################################################
-- OAF PERSONALISATIONS 1
-- ##################################################################

		select jp.*
			 , jc.*
		  from apps.jdr_paths jp
		  join apps.jdr_components jc on jp.path_docid = jc.comp_docid
		 where 1 = 1
		   and jp.path_name = 'EditSubmitPG'
		   and jc.comp_seq = 0
		   and upper(jc.comp_element) = 'CUSTOMIZATION'
		   and jc.comp_id is null
		   and 1 = 1;

-- ##################################################################
-- OAF PERSONALISATIONS 2
-- ##################################################################

/*
https://www.oracleappsguy.com/2012/10/sql-query-to-list-all-oaf.html
exec jdr_utils.listcustomizations('/oracle/apps/fnd/cp/srs/webui/cpprogrampg');
*/

		select path.path_docid perz_doc_id
			 , jdr_mds_internal.getdocumentname(path.path_docid) perz_doc_path
			 , '##############'
			 , path.*
		  from jdr_paths path
		 where path.path_docid in (distinct comp_docid 
		  from jdr_components
		 where comp_seq = 0 
		   and upper(comp_element) = 'CUSTOMIZATION'
		   and comp_id is null)
	  order by perz_doc_path;

-- ##################################################################
-- OAF PERSONALISATIONS 3
-- ##################################################################

/*
https://www.oracleapps2fusion.com/2017/01/sql-query-to-get-all-personalization-on.html?m=0
*/

		select path.path_docid perz_doc_id
			 , jdr_mds_internal.getdocumentname (path.path_docid) perz_doc_path
			 , path.*
		  from jdr_paths path
		 where path.path_docid in (select distinct comp_docid
								     from jdr_components
								    where comp_seq = 0
								      and upper(comp_element) = 'CUSTOMIZATION'
								      and comp_id is null)
		   and upper(jdr_mds_internal.getdocumentname (path.path_docid)) like ('%SHOPPINGHOMEPG%')
	  order by perz_doc_path;

-- ##################################################################
-- OAF PERSONALISATIONS 4
-- ##################################################################

/*
https://www.oracleappsguy.com/2012/10/sql-query-to-list-all-oaf.html
The following sql query will list all the OAF personlizations in an oracle applications instance
*/

		select path.*
			 , jdr_mds_internal.getdocumentname(path.path_docid) perz_doc_path
		  from jdr_paths path
		 where path_name = 'ShoppingHomePG'
		   and path.path_docid in (select distinct comp_docid from jdr_components
								    where comp_seq = 0
									  and upper(comp_element) = 'CUSTOMIZATION'
								      and comp_id is null)
	  order by path.last_update_date desc;

-- ##################################################################
-- OAF PERSONALISATIONS 5
-- ##################################################################

		select jp.*
			 , jc.*
		  from apps.jdr_paths jp
		  join apps.jdr_components jc on jp.path_docid = jc.comp_docid
		 where 1 = 1
		   and jp.path_name = 'EditSubmitPG'
		   and jc.comp_seq = 0
		   and upper(jc.comp_element) = 'CUSTOMIZATION'
		   and jc.comp_id is null
		   and 1 = 1;
