/*
File Name: sa-api-user-remove-end-date.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
API that can be used remove end-date against user accounts included in the "usercur" cursor
*/

-- ##################################################################
-- USER ACCOUNT - REMOVE END DATE
-- ##################################################################

declare
cursor usercur
is
		select fu.user_name
		  from apps.fnd_user fu
		 where fu.user_name in ('USER123','USER321');
begin
	for myuser in usercur
	loop
		fnd_user_pkg.updateuser(
		x_user_name => myuser.user_name
		, x_owner => 'CUST'
		, x_end_date => to_date('2', 'J') -- removes end-date
		);
	end loop;
end;

/

commit;

exit
