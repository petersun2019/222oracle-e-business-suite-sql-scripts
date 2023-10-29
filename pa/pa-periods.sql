/*
File Name:		pa-periods.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

		select sys_context('USERENV','DB_NAME') instance
			 , hou.name org
			 , hou.short_code org_code
			 , ppa.period_name
			 , ppa.last_update_date
			 , to_char(ppa.start_date, 'DD-MON-YYYY') start_date
			 , to_char(ppa.end_date, 'DD-MON-YYYY') end_date
			 , ppa.status
		  from pa.pa_periods_all ppa 
		  join apps.hr_operating_units hou on ppa.org_id = hou.organization_id
		 where 1 = 1
		   -- and ppa.last_update_date > sysdate - 7
		   -- and hou.name = 'Cheese Org'
		   -- and ppa.period_name in ('Jun-21','Jul-21','Aug-21','Sep-21','Oct-21','Nov-21')
		   -- and sysdate between ppa.start_date and ppa.end_date
		   -- and ppa.current_pa_period_flag = 'Y'
		   -- and '28-SEP-2019' between ppa.start_date and ppa.end_date
		   and 1 = 1;
