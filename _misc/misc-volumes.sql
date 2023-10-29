/*
File Name: misc-volumes.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- GENERAL BY MONTH
-- GENERAL
-- AP INVOICES
-- AP PAYMENT RUNS
-- SUPPLIER HEADER UPDATES
-- SUPPLIER SITE UPDATES
-- JOURNALS
-- ASSETS
-- CASH MANAGEMENT - STATEMENT HEADERS
-- ANYTHING

*/

-- ##################################################################
-- GENERAL BY MONTH
-- ##################################################################

		select to_char(creation_date, 'yyyy-mm')
			 , count(*) 
		  from ap_invoices_all
		 where 1 = 1
		   -- and to_char(creation_date, 'yyyy-mm') > '2022-08-01'
	  group by to_char(creation_date, 'yyyy-mm')
	  order by 1 desc;

-- ##################################################################
-- GENERAL
-- ##################################################################

		select to_char(creation_date, 'yyyy-mm-dd')
			 , count(*) 
		  from ap_invoices_all
		 where to_char(creation_date, 'yyyy-mm-dd') > '2022-01-01'
		   and to_char(creation_date, 'yyyy-mm-dd') < '2022-02-01'
	  group by to_char(creation_date, 'yyyy-mm-dd') 
	  order by 1 desc;

-- ##################################################################
-- AP INVOICES
-- ##################################################################

		select fu.user_name
			 , fu.email_address
			 , ppx.full_name
			 , count(*) "#"
			 , max(xxx.creation_date) latest
		  from fnd_user fu
		  join ap_invoices_all xxx on fu.user_id = xxx.created_by
	 left join per_people_x ppx on fu.employee_id = ppx.person_id
		 where xxx.creation_date > sysdate - 800
	  group by fu.user_name
			 , fu.email_address
			 , ppx.full_name
	  order by 4 desc;

		select to_char(aia.creation_date, 'yyyy-mm-dd') creation_date
			 , count(*) ct
		  from ap_invoices_all aia
		 where aia.creation_date > sysdate - 200
		   -- and aia.creation_date < '15-JUL-2021'
	  group by to_char(aia.creation_date, 'yyyy-mm-dd')
	  order by to_char(aia.creation_date, 'yyyy-mm-dd') desc;

-- ##################################################################
-- AP PAYMENT RUNS
-- ##################################################################

		select fu.user_name
			 , fu.email_address
			 , ppx.full_name
			 , count(*) "#"
			 , max(xxx.creation_date) latest
		  from fnd_user fu
		  join ap_inv_selection_criteria_all xxx on fu.user_id = xxx.created_by
	 left join per_people_x ppx on fu.employee_id = ppx.person_id
		 where xxx.creation_date > sysdate - 800
	  group by fu.user_name
			 , fu.email_address
			 , ppx.full_name
	  order by 4 desc;

-- ##################################################################
-- SUPPLIER HEADER UPDATES
-- ##################################################################

		select fu.user_name
			 , fu.email_address
			 , ppx.full_name
			 , count(*) "#"
			 , max(xxx.creation_date) latest
		  from fnd_user fu
		  join ap_suppliers xxx on fu.user_id = xxx.last_updated_by
	 left join per_people_x ppx on fu.employee_id = ppx.person_id
		 where xxx.creation_date > sysdate - 800
	  group by fu.user_name
			 , fu.email_address
			 , ppx.full_name
	  order by 4 desc;

-- ##################################################################
-- SUPPLIER SITE UPDATES
-- ##################################################################

		select fu.user_name
			 , fu.email_address
			 , ppx.full_name
			 , count(*) "#"
			 , max(xxx.creation_date) latest
		  from fnd_user fu
		  join ap_supplier_sites_all xxx on fu.user_id = xxx.last_updated_by
	 left join per_people_x ppx on fu.employee_id = ppx.person_id
		 where xxx.creation_date > sysdate - 800
	  group by fu.user_name
			 , fu.email_address
			 , ppx.full_name
	  order by 4 desc;

-- ##################################################################
-- JOURNALS
-- ##################################################################

		select fu.user_name
			 , fu.email_address
			 , ppx.full_name
			 , count(*) "#"
			 , max(xxx.creation_date) latest
		  from fnd_user fu
		  join gl_je_headers xxx on fu.user_id = xxx.last_updated_by
	 left join per_people_x ppx on fu.employee_id = ppx.person_id
		 where xxx.creation_date > sysdate - 800
	  group by fu.user_name
			 , fu.email_address
			 , ppx.full_name
	  order by 4 desc;

-- ##################################################################
-- ASSETS
-- ##################################################################

		select fu.user_name
			 , fu.email_address
			 , ppx.full_name
			 , count(*) "#"
			 , max(xxx.creation_date) latest
		  from fnd_user fu
		  join fa_additions_b xxx on fu.user_id = xxx.last_updated_by
	 left join per_people_x ppx on fu.employee_id = ppx.person_id
		 where xxx.creation_date > sysdate - 800
	  group by fu.user_name
			 , fu.email_address
			 , ppx.full_name
	  order by 4 desc;

-- ##################################################################
-- CASH MANAGEMENT - STATEMENT HEADERS
-- ##################################################################

		select fu.user_name
			 , fu.email_address
			 , ppx.full_name
			 , count(*) "#"
			 , max(xxx.creation_date) latest
		  from fnd_user fu
		  join ce_statement_headers xxx on fu.user_id = xxx.last_updated_by
	 left join per_people_x ppx on fu.employee_id = ppx.person_id
		 where xxx.creation_date > sysdate - 800
	  group by fu.user_name
			 , fu.email_address
			 , ppx.full_name
	  order by 4 desc;

-- ##################################################################
-- ANYTHING
-- ##################################################################

		select to_char(xyz.creation_date, 'yyyy-mm-dd') creation_date
			 , count(*) ct
		  from pa_expenditure_items_all xyz
		 where xyz.creation_date > '01-JAN-2022'
		   -- and xyz.creation_date < '29-JUL-2021'
	  group by to_char(xyz.creation_date, 'yyyy-mm-dd')
	  order by to_char(xyz.creation_date, 'yyyy-mm-dd') desc;
