/*
File Name: sa-api-user-add-end-date.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
API that can be used to end-date user accounts included in the "usercur" cursor
*/

-- ##################################################################
-- USER ACCOUNT - END DATE
-- ##################################################################

declare
cursor usercur 
is
		select fu.user_name
		  from apps.fnd_user fu
		 where nvl(fu.end_date, sysdate + 1) >= sysdate
		   and fu.user_name in ('USER123','USER321');

begin
	for myuser in usercur
	loop
		fnd_user_pkg.updateuser(
		x_user_name => myuser.user_name,
		x_owner => 'CUST',
		x_end_date => trunc(sysdate-1)
		);
	end loop; 
end;

/

commit;

exit
