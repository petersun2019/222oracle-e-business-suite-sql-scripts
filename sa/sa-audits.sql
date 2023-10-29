/*
File Name: sa-audits.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- RESPONSIBILITY AUDIT
-- RESPONSIBILITY AND FORM AUDIT

*/

-- ##################################################################
-- RESPONSIBILITY AUDIT
-- ##################################################################

		select fl.login_id
			 , fu.user_name
			 , fu.description
			 , fl.start_time login_start_time
			 , fl.end_time login_end_time
			 , frt.responsibility_name resp
			 , flr.start_time resp_start_time
			 , flr.end_time resp_end_time
			 , fl.login_id
			 , fl.terminal_id
		  from apps.fnd_logins fl
		  join apps.fnd_login_responsibilities flr on flr.login_id = fl.login_id 
		  join apps.fnd_responsibility_tl frt on flr.responsibility_id = frt.responsibility_id and frt.language = userenv('lang')
		  join apps.fnd_user fu on fl.user_id = fu.user_id
		 where 1 = 1
		   and fu.user_name = 'USER123'
		   and frt.responsibility_name = 'Alert Manager'
		   -- and fl.login_id in (37991635,37991629,37991619,37991609)
		   -- and flr.start_time > '30-AUG-2021'
		   -- and fl.login_id = 38054506
		   -- and frt.responsibility_name = 'Enterprise Asset Management'
	  order by fl.login_id desc;

-- ##################################################################
-- RESPONSIBILITY AND FORM AUDIT
-- ##################################################################

		select distinct flr.login_id
			 , fu.user_name
			 , fu.user_id
			 , fu.description
			 , frt.responsibility_name
			 , flr.start_time
			 , flr.end_time
			 , fft.user_form_name
			 , fat.application_name
		  from applsys.fnd_logins fl
		  join applsys.fnd_login_responsibilities flr on flr.login_id = fl.login_id
	 left join applsys.fnd_login_resp_forms flrf on flr.login_resp_id = flrf.login_resp_id
		  join applsys.fnd_user fu on fl.user_id = fu.user_id
		  join applsys.fnd_responsibility_tl frt on flr.responsibility_id = frt.responsibility_id and frt.language = userenv('lang')
	 left join applsys.fnd_form ff on ff.form_id = flrf.form_id
	 left join applsys.fnd_form_tl fft on fft.form_id = ff.form_id and ff.zd_edition_name = fft.zd_edition_name and fft.language = userenv('lang')
		  join applsys.fnd_application_tl fat on fat.application_id = flrf.form_appl_id and fat.language = userenv('lang')
		 where 1 = 1
		   and fu.user_name = 'USER123'
		   -- and fl.user_id = 16396
		   -- and fl.login_id = 38054506
		   -- and fu.user_name in ('USER123','USER124')
		   -- and frt.responsibility_name = 'Enterprise Asset Management'
		   -- and fu.description = 'Cheese Face'
		   -- and fu.email_address = 'this@example.com'
		   -- and fat.application_name = 'Payables'
		   -- and frt.responsibility_name = 'Payables'
		   -- and fft.user_form_name like '%Reven%'
		   -- and flr.start_time >= '08-NOV-2013'
	  order by flr.start_time desc;
