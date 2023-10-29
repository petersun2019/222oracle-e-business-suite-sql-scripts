/*
File Name: sa-forms.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- FORMS
-- ##################################################################

		select * 
		  from fnd_form ff
		  join fnd_form_tl fft on ff.form_id = fft.form_id
		 where 1 = 1
		   -- and ff.form_name = 'GLXIQFUN'
		   and ff.form_name in ('PAXBLRSL','PAXBUEBU')
		   and 1 = 1;
