/*
File Name:		sa-api-user-reset-pwd.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

API that can be used to reset passwords for user accounts included in the "usercur" cursor

Queries:

-- USER ACCOUNT - RESET PASSWORD IN BULK
-- RESET SINGLE ACCOUNT

*/

-- ##################################################################
-- USER ACCOUNT - RESET PASSWORD IN BULK
-- ##################################################################

declare
cursor usercur
is
		select distinct fu.user_name
			 , 'welcome123' newpass
		  from apps.fnd_user fu
		 where fu.user_name in ('USER123','USER321');

myuser usercur%rowtype;
begin
	for myuser in usercur
	loop
		fnd_user_pkg.updateuser(
		x_user_name => myuser.user_name
		, x_owner => 'CUST'
		, x_unencrypted_password => myuser.newpass
		, x_password_date => to_date('2', 'J') -- ensures user is prompted to change pwd
		);
	end loop;
end;

/

commit;

exit

-- ##################################################################
-- RESET SINGLE ACCOUNT
-- ##################################################################

/*
USER NOT PROMPTED TO CHANGE PASSWORD WHEN LOGGING IN USING THIS METHOD, BECAUSE X_PASSWORD_DATE NOT INCLUDED IN API
USERS NOT PROMPTED TO CHANGE THEIR PASSWORD WHEN USING FND_USER_PKG.UPDATEUSER (DOC ID 344979.1)
*/

begin
	fnd_user_pkg.updateuser(
	x_user_name => 'USER123'
	, x_owner => 'CUST'
	, x_unencrypted_password => 'change123'
	);
	dbms_output.put_line('updateuser: ' || sqlerrm);
	commit;
end;