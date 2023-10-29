/*
File Name: sa-api-resp-remove-end-date.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
API that can be used to remove end-dates from responsibilities assigned to users returned by "user_cur" cursor
Edit IDs as required in the "fnd_user_resp_groups_api.insert_assignment" section
*/

-- ##################################################################
-- USER ACCOUNT - RESPONSIBILITY - REMOVE END DATE
-- ##################################################################

declare
cursor respcur
is
		select fu.user_id usid
			 , fu.user_name
			 , frt.responsibility_id resid
			 , frt.application_id apid
			 , furgd.security_group_id sgid
			 , furgd.start_date rstart
			 , furgd.security_group_id
			 , furgd.description info
		  from applsys.fnd_user fu join apps.fnd_user_resp_groups_direct furgd on fu.user_id = furgd.user_id
		  join apps.fnd_responsibility_tl frt
on frt.application_id = furgd.responsibility_application_id
		   and frt.responsibility_id = furgd.responsibility_id
		   and nvl(fu.end_date, sysdate + 1) > sysdate
		   and furgd.end_date = '15-JUN-2016'
		 where frt.responsibility_name in('Cheese Administrator')
		   and fu.user_name in ('USER123','USER321');

myresp respcur%rowtype;
begin
	for myresp in respcur
	loop
		apps.fnd_user_resp_groups_api.update_assignment(
		myresp.usid
		, myresp.resid
		, myresp.apid
		, myresp.sgid
		, myresp.rstart
		, null
		, myresp.info
		);
	end loop;
end;

/

commit;

exit
