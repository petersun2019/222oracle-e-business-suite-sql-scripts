/*
File Name:		gl-journal-approvals.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- GL JOURNAL APPROVALS
-- ##################################################################

		select fu.user_name
			 , fu.description
			 , papf.employee_number submitter_empno
			 , nvl(gal.authorization_limit, 0) gl_limited_submitter
			 , gjb.creation_date batch_created
			 , gjb.name batch_name
			 , gjb.running_total_dr
			 , gjb.approver_employee_id
			 , gjb.status
			 , gjb.approval_status_code
			 , papf2.full_name approver_name
			 , papf2.employee_number approver_empno
			 , nvl(gal2.authorization_limit, 0) gl_limited_approver
			 , fu2.user_name approver_user
			 , fu2.end_date approver_end_date
		  from gl_je_batches gjb
		  join fnd_user fu on fu.user_id = gjb.created_by
		  join per_all_people_f papf on papf.person_id = fu.employee_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join gl_authorization_limits gal on gal.employee_id = papf.person_id
	 left join per_all_people_f papf2 on papf2.person_id = gjb.approver_employee_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join gl_authorization_limits gal2 on gal2.employee_id = papf2.person_id
	 left join fnd_user fu2 on papf2.person_id = fu2.employee_id
		 where gjb.creation_date > '01-NOV-2017'
	  order by gjb.creation_date desc;
