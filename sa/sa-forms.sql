/*
File Name:		sa-forms.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
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
