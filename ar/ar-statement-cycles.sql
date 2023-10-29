/*
File Name: ar-statement-cycles.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- AR STATEMENT CYCLES
-- ##################################################################

		select ascc.name
			 , ascc.description
			 , ascc.interval
			 , ascda.statement_date
			 , ascda.creation_date
			 , ascda.statement_cycle_id
			 , fu.description
		  from ar.ar_statement_cycle_dates_all ascda
		  join applsys.fnd_user fu on fu.user_id = ascda.created_by
		  join ar.ar_statement_cycles ascc on ascda.statement_cycle_id = ascc.statement_cycle_id 
	  order by ascc.name
			 , ascda.statement_date desc
			 , ascda.creation_date;
