/*
File Name: sa-api-resp-add.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

API that can be used to assign responsibilities to users returned by "user_cur" cursor
Edit IDs as required in the "fnd_user_resp_groups_api.insert_assignment" section
*/

-- ##################################################################
-- USER ACCOUNT - RESPONSIBILITY - ADD
-- ##################################################################

declare

cursor user_cur
is
		select fu.user_id usid
		  from applsys.fnd_user fu
		 where fu.user_name in ('USER123','USER321');

my_user user_cur%rowtype;

begin

	for my_user in user_cur
	loop
		fnd_user_resp_groups_api.insert_assignment(
		my_user.usid -- userid
		, 52174 -- resp_id
		, 201 -- resp_application_id
		, 0 -- security_group_id
		, sysdate -- start_date
		, null -- adds an empty end_date
		, 'Adding Resp Via API' -- description
		);
	end loop; 

end;

/

commit;

exit