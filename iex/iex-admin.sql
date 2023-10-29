/*
File Name:		iex-admin.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- TOP LEVEL SUMMARY ATTEMPT, MIRRORS COLLECTIONS ADMIN
-- TOP LEVEL SUMMARY ATTEMPT, MIRRORS COLLECTIONS ADMIN -- COUNTING
-- CUSTOMERS, MIRRORING COLLECTIONS ADMIN ATTEMPT (IEX_OWNERSHIPS_V DEFINITION)

*/

-- ##################################################################
-- TOP LEVEL SUMMARY ATTEMPT, MIRRORS COLLECTIONS ADMIN
-- ##################################################################

		select joined_up.collector
			 , joined_up.party_name
			 , joined_up.account_number
			 , joined_up.location
			 , joined_up.user_name
			 , joined_up.end_date
			 , sum(work_item_flag) work_items
			 , sum(flag_prom) promises
			 , sum(flag_brok) broken_promises
			 , sum(amount_due_remaining) amount_due_remaining
		  from 
	   (select ac.name collector
			 , hp.party_name
			 , hca.account_number
			 , hcsua.location
			 , ipd.resource_id
			 , hp.party_id
			 , hca.cust_account_id
			 , hcsua.site_use_id
			 , 0 work_item_flag
			 , case when ipd.state = 'PROMISE' then 1 end flag_prom
			 , case when ipd.state = 'BROKEN_PROMISE' then 1 end flag_brok
			 , ipd.amount_due_remaining amount_due_remaining
			 , fu.user_name
			 , fu.end_date 
		  from ar.ar_collectors ac
		  join iex.iex_promise_details ipd on ac.resource_id = ipd.resource_id
		  join iex.iex_delinquencies_all ida on ipd.delinquency_id = ida.delinquency_id
		  join ar.hz_cust_accounts hca on ipd.cust_account_id = hca.cust_account_id
		  join ar.hz_parties hp on hca.party_id = hp.party_id
		  join ar.hz_cust_site_uses_all hcsua on ida.customer_site_use_id = hcsua.site_use_id
		  join applsys.fnd_user fu on fu.employee_id = ac.employee_id
		 where ipd.status = 'COLLECTABLE'
		   and fu.end_date is not null
		union all
		select ac.name collector
			 , hp.party_name
			 , hca.account_number
			 , hcsua.location
			 , iswi.resource_id
			 , hp.party_id
			 , hca.cust_account_id
			 , hcsua.site_use_id
			 , case when iswi.work_item_id > 0 then 1 end work_item_flag
			 , 0 flag_prom
			 , 0 flag_brok
			 , 0 amount_due_remaining
			 , fu.user_name
			 , fu.end_date 
		  from ar.ar_collectors ac
		  join iex.iex_strategy_work_items iswi on ac.resource_id = iswi.resource_id
		  join iex.iex_strategies istrat on istrat.strategy_id = iswi.strategy_id
		  join ar.hz_cust_accounts hca on istrat.cust_account_id = hca.cust_account_id
		  join ar.hz_parties hp on hca.party_id = hp.party_id
		  join ar.hz_cust_site_uses_all hcsua on istrat.customer_site_use_id = hcsua.site_use_id
		  join applsys.fnd_user fu on fu.employee_id = ac.employee_id
		 where iswi.status_code in ('OPEN','PRE-WAIT')
		   and istrat.status_code in ('OPEN', 'ONHOLD')
		   and trunc(iswi.schedule_start) = trunc(iswi.schedule_start)
		   and fu.end_date is not null) joined_up
	  group by joined_up.collector
			 , joined_up.party_name
			 , joined_up.account_number
			 , joined_up.location
			 , joined_up.user_name
			 , joined_up.end_date
	  order by joined_up.collector
			 , joined_up.party_name;

-- ##################################################################
-- TOP LEVEL SUMMARY ATTEMPT, MIRRORS COLLECTIONS ADMIN -- COUNTING
-- ##################################################################

		select collector
			 , user_name
			 , end_date
			 , count(distinct account_number) customers
			 , sum(work_items) work_items
			 , sum(promises) promises
			 , sum(broken_promises) broken_promises
			 , sum(amount_due_remaining) total_outstanding
		  from (select joined_up.collector
			 , joined_up.party_name
			 , joined_up.account_number
			 , joined_up.location
			 , joined_up.user_name
			 , joined_up.end_date
			 , sum(work_item_flag) work_items
			 , sum(flag_prom) promises
			 , sum(flag_brok) broken_promises
			 , sum(amount_due_remaining) amount_due_remaining
		  from 
	   (select ac.name collector
			 , hp.party_name
			 , hca.account_number
			 , hcsua.location
			 , ipd.resource_id
			 , hp.party_id
			 , hca.cust_account_id
			 , hcsua.site_use_id
			 , 0 work_item_flag
			 , case when ipd.state = 'PROMISE' then 1 end flag_prom
			 , case when ipd.state = 'BROKEN_PROMISE' then 1 end flag_brok
			 , ipd.amount_due_remaining amount_due_remaining
			 , fu.user_name
			 , fu.end_date 
		  from ar.ar_collectors ac
		  join iex.iex_promise_details ipd on ac.resource_id = ipd.resource_id
		  join iex.iex_delinquencies_all ida on ipd.delinquency_id = ida.delinquency_id
		  join ar.hz_cust_accounts hca on ipd.cust_account_id = hca.cust_account_id
		  join ar.hz_parties hp on hca.party_id = hp.party_id
		  join ar.hz_cust_site_uses_all hcsua on ida.customer_site_use_id = hcsua.site_use_id
		  join applsys.fnd_user fu on fu.employee_id = ac.employee_id
		 where ipd.status = 'COLLECTABLE'
		   and fu.end_date is not null
		   and 1 = 1
		union all
		select ac.name collector
			 , hp.party_name
			 , hca.account_number
			 , hcsua.location
			 , iswi.resource_id
			 , hp.party_id
			 , hca.cust_account_id
			 , hcsua.site_use_id
			 , case when iswi.work_item_id > 0 then 1 end work_item_flag
			 , 0 flag_prom
			 , 0 flag_brok
			 , 0 amount_due_remaining
			 , fu.user_name
			 , fu.end_date 
		  from ar.ar_collectors ac
		  join iex.iex_strategy_work_items iswi on ac.resource_id = iswi.resource_id
		  join iex.iex_strategies istrat on istrat.strategy_id = iswi.strategy_id
		  join ar.hz_cust_accounts hca on istrat.cust_account_id = hca.cust_account_id
		  join ar.hz_parties hp on hca.party_id = hp.party_id
		  join ar.hz_cust_site_uses_all hcsua on istrat.customer_site_use_id = hcsua.site_use_id
		  join applsys.fnd_user fu on fu.employee_id = ac.employee_id
		 where iswi.status_code in ('OPEN','PRE-WAIT')
		   and istrat.status_code in ('OPEN', 'ONHOLD')
		   and trunc(iswi.schedule_start) = trunc(iswi.schedule_start)
		   and fu.end_date is not null
		   and 1 = 1) joined_up
	  group by joined_up.collector
			 , joined_up.party_name
			 , joined_up.account_number
			 , joined_up.location
			 , joined_up.user_name
			 , joined_up.end_date) tbl
	  group by collector
			 , user_name
			 , end_date
	  order by collector;

-- ##################################################################
-- CUSTOMERS, MIRRORING COLLECTIONS ADMIN ATTEMPT (IEX_OWNERSHIPS_V DEFINITION)
-- ##################################################################

		select ac.name collector
			 , p.party_name party_name
			 , h.account_number account_number
			 , l.location location
			 , a.resource_id resource_id
			 , p.party_id party_id
			 , h.cust_account_id cust_account_id
			 , l.site_use_id customer_site_use_id
			 , 0 work_item_count
			 , count (*) promise_count
			 , sum (a.amount_due_remaining) amount_due_remaining
		  from iex.iex_promise_details a
		  join ar.hz_cust_accounts h on h.cust_account_id = a.cust_account_id 
		  join ar.hz_parties p on h.party_id = p.party_id
	 left join iex.iex_delinquencies_all d on a.delinquency_id = d.delinquency_id
	 left join ar.hz_cust_site_uses_all l on d.customer_site_use_id = l.site_use_id
		  join ar.ar_collectors ac on a.resource_id = ac.resource_id
		  join applsys.fnd_user fu on ac.employee_id = fu.employee_id
		 where a.status = 'COLLECTABLE'
		   and fu.user_name like 'M%'
		   and fu.end_date is not null
	  group by ac.name
			 , p.party_name
			 , h.account_number
			 , l.location
			 , a.resource_id
			 , p.party_id
			 , h.cust_account_id
			 , l.site_use_id
		union all
		select ac.name collector
			 , p.party_name party_name
			 , h.account_number account_number
			 , l.location location
			 , a.resource_id resource_id
			 , p.party_id party_id
			 , h.cust_account_id cust_account_id
			 , l.site_use_id customer_site_use_id
			 , count (*) work_item_count
			 , 0 promise_count
			 , 0 amount_due_remaining
		  from iex.iex_strategy_work_items a
		  join iex.iex_strategies s on s.strategy_id = a.strategy_id
	 left join ar.hz_cust_accounts h on s.cust_account_id = h.cust_account_id
	 left join ar.hz_parties p on s.party_id = p.party_id
right join ar.hz_cust_site_uses_all l on l.site_use_id = s.customer_site_use_id
		  join ar.ar_collectors ac on a.resource_id = ac.resource_id
		  join applsys.fnd_user fu on ac.employee_id = fu.employee_id
		 where a.status_code = 'OPEN'
		   and trunc (a.schedule_start) = trunc (a.schedule_start)
		   and fu.user_name like 'M%'
		   and fu.end_date is not null
	  group by ac.name
			 , p.party_name
			 , h.account_number
			 , l.location
			 , a.resource_id
			 , p.party_id
			 , h.cust_account_id
			 , l.site_use_id;
