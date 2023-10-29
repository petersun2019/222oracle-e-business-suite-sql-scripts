/*
File Name: sa-api-resp-add-end-date.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
API that can be used to end-date responsibilities assigned to users and resps returned by "respcur" cursor
*/

-- ##################################################################
-- USER ACCOUNT - RESPONSIBILITY - END DATE
-- ##################################################################

declare
cursor respcur
is
		select fu.user_id usid
			 , fu.user_name
			 , frt.responsibility_id resid
			 , frt.application_id apid
			 , furgd.start_date rstart
			 , furgd.security_group_id sgid
			 , furgd.description info
		  from applsys.fnd_user fu join apps.fnd_user_resp_groups_direct furgd on fu.user_id = furgd.user_id
		  join apps.fnd_responsibility_tl frt on frt.application_id = furgd.responsibility_application_id
		   and frt.responsibility_id = furgd.responsibility_id
		   and nvl(furgd.end_date, sysdate + 1) > sysdate
		   and nvl(fu.end_date, sysdate + 1) > sysdate
		 where frt.responsibility_name = 'Cheese Administrator'
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
		, trunc(sysdate)
		, 'API END DATE | ' || myresp.info
		);
	end loop;
end;

/

commit;

exit