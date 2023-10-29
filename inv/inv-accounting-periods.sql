/*
File Name: inv-accounting-periods.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- INVENTORY ACCOUNTING PERIODS
-- ##################################################################

		select oap.period_year
			 , oap.period_num
			 , haou.name hr_org
			 , haou.organization_id inv_org_id
			 , oap.period_name
			 , oap.period_start_date
			 , oap.schedule_close_date
			 , oap.period_close_date
			 , oap.open_flag
			 , oap.last_update_date
			 , fu.user_name
		  from inv.org_acct_periods oap
		  join applsys.fnd_user fu on oap.last_updated_by = fu.user_id 
		  join hr.hr_all_organization_units haou on oap.organization_id = haou.organization_id 
		 where 1 = 1
		   -- and oap.period_year = 2016
		   -- and oap.period_name
		   -- and oap.open_flag = 'Y'
		   -- and oap.last_update_date > trunc(sysdate) - 4
		   -- and trunc(sysdate) between oap.period_start_date and oap.period_close_date
		   -- and oap.period_name in ('P06-20','P07-20')
		   and 1 = 1
	  order by oap.creation_date desc;
