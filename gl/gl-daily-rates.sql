/*
File Name:		gl-daily-rates.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- GL DAILY RATES 1
-- GL DAILY RATES - MAX DATE
-- GL DAILY RATES  - COUNT BY USER CONVERSION TYPE
-- GL DAILY RATES  - COUNT BY USER
-- GL DAILY RATES  - COUNT BY CONVERSION DATE
-- GL DAILY RATES  - USER DETAILS
-- API TO CHECK IF CURRENCY EXISTS

*/

-- ##################################################################
-- GL DAILY RATES 1
-- ##################################################################

		select gdr.from_currency
			 , gdr.to_currency
			 , gdr.creation_date
			 , to_char(gdr.conversion_date, 'YYYY-MM-DD') conversion_date
			 , gdr.conversion_rate
			 , gdct.user_conversion_type
		  from gl_daily_rates gdr
		  join gl_daily_conversion_types gdct on gdct.conversion_type = gdr.conversion_type
		 where 1 = 1
		   -- and to_char(gdr.conversion_date, 'YYYY-MM-DD') = '2021-11-20'
		   and gdr.conversion_date in ('29-APR-2021','29-APR-2022')
		   -- and gdr.conversion_date = to_char(sysdate, 'DD-MON-YYYY')
		   -- and ((from_currency = 'USD' and to_currency = 'GBP') or (from_currency = 'GBP' and to_currency = 'USD'))
		   and from_currency = 'USD' and to_currency = 'GBP'
		   -- and gdct.user_conversion_type = 'Average'
		   -- and gdct.user_conversion_type = 'XXCUST CORPORATE'
		   and 1 = 1;

-- ##################################################################
-- GL DAILY RATES - MAX DATE
-- ##################################################################

		select max(conversion_date) 
		  from gl.gl_daily_rates;

-- ##################################################################
-- GL DAILY RATES  - COUNT BY USER CONVERSION TYPE
-- ##################################################################

		select gdct.user_conversion_type
			 , min(gdr.creation_date)
			 , max(gdr.creation_date)
		  from gl_daily_rates gdr
		  join gl_daily_conversion_types gdct on gdct.conversion_type = gdr.conversion_type
		 where 1 = 1
		   and 1 = 1
	  group by gdct.user_conversion_type;

-- ##################################################################
-- GL DAILY RATES  - COUNT BY USER
-- ##################################################################

		select fu.description
			 , fu.user_name
			 , count(*)
		  from gl.gl_daily_rates gdr 
		  join applsys.fnd_user fu on gdr.created_by = fu.user_id 
		 where to_char(gdr.conversion_date, 'DD-MON-YYYY') > '01-JAN-2016' 
	  group by fu.description
			 , fu.user_name;

-- ##################################################################
-- GL DAILY RATES  - COUNT BY CONVERSION DATE
-- ##################################################################

		select to_char(conversion_date, 'YYYY')
			 , count(*)
		  from gl_daily_rates
	  group by to_char(conversion_date, 'YYYY')
	  order by to_char(conversion_date, 'YYYY');

-- ##################################################################
-- GL DAILY RATES  - USER DETAILS
-- ##################################################################

		select fu.description
			 , gdr.* 
		  from gl.gl_daily_rates gdr 
		  join applsys.fnd_user fu on gdr.created_by = fu.user_id
		 where to_char(gdr.conversion_date, 'DD-MON-YYYY') > '01-AUG-2016';

		select fu.description
			 , gdr.* 
		  from gl_daily_rates gdr 
		  join fnd_user fu on gdr.created_by = fu.user_id
		 where 1 = 1
		   and to_char(gdr.conversion_date, 'DD-MON-YYYY') in ('20-OCT-2010','31-MAY-2019')
		   and 1 = 1;

-- ##################################################################
-- API TO CHECK IF CURRENCY EXISTS
-- ##################################################################

select gl_currency_api.rate_exists('GBP','USD','10-AUG-2017','Corporate') from dual;
