/*
File Name:		gl-application-accounting-definitions.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- APPLICATION ACCOUNTING DEFINITIONS
-- APPLICATION ACCOUNTING DEFINITIONS - COUNT BY APPLICATION AND STATUS
-- APPLICATION ACCOUNTING DEFINITIONS - COUNT BY APPLICATION
-- XLA APPLICATION INFO

Sometimes Application Accounting Definitions can become invalid.
Running "Validate Application Accounting Definitions" can resolve that.
These queries can be useful to confirm which definitions are invalid.
I have used them to check before / after status on definitions.
*/

-- ##################################################################
-- APPLICATION ACCOUNTING DEFINITIONS
-- ##################################################################

		select xprf.application_name appl
			 -- , xprf.*
			 , xprf.description
			 , xprf.compile_status_dsp hdr_status
			 , xprf.enabled_flag enbl
			 , xprf.last_update_date hdr_upd_dt
			 , xpahf.event_class_name ev_class
			 , xpahf.event_type_name ev_type
			 , xpahf.accounting_required_flag crt_acct
			 , xpahf.locking_status_flag locked
			 , xpahf.validation_status_dsp status
			 , xpahf.last_update_date upd_dt
		  from xla_product_rules_fvl xprf
			 , xla_prod_acct_headers_fvl xpahf
		 where xprf.application_id = xpahf.application_id
		   and xprf.product_rule_code = xpahf.product_rule_code
		   -- and xprf.application_name = 'Assets'
		   and xprf.compile_status_dsp <> 'Valid'
		   -- and xprf.description in ('Standard Accounting for Inflation','Standard Accounting for United Kingdom Local Authorities')
		   -- and xpahf.event_class_name = 'Borrowed and Lent'
		   -- and xprf.description = 'China Projects Standard Accounting'
	  order by xprf.application_name
			 , xprf.description
			 , xpahf.event_class_name;

-- ##################################################################
-- APPLICATION ACCOUNTING DEFINITIONS - COUNT BY APPLICATION AND STATUS
-- ##################################################################

		select count(*) ct
			 , xprf.application_name
			 , xprf.compile_status_dsp
		  from apps.xla_product_rules_fvl xprf
			 , apps.xla_prod_acct_headers_fvl xpahf
		 where xprf.application_id = xpahf.application_id
		   and xprf.product_rule_code = xpahf.product_rule_code
		   and xprf.compile_status_dsp = 'Valid'
	  group by xprf.compile_status_dsp
			 , xprf.application_name
	  order by xprf.compile_status_dsp
			 , xprf.application_name;

-- ##################################################################
-- APPLICATION ACCOUNTING DEFINITIONS - COUNT BY APPLICATION
-- ##################################################################

		select xprf.application_name appl
			 , xprf.description
			 , count(*) ct
		  from apps.xla_product_rules_fvl xprf
			 , apps.xla_prod_acct_headers_fvl xpahf
		 where xprf.application_id = xpahf.application_id
		   and xprf.product_rule_code = xpahf.product_rule_code
		   and xprf.compile_status_dsp = 'Valid'
	  group by xprf.application_name
			 , xprf.description
	  order by 3 desc
			 , xprf.application_name
			 , xprf.description;

-- ##################################################################
-- XLA APPLICATION INFO
-- ##################################################################

		select application_id
			 , application_name
			 , name
			 , compile_status_dsp
			 , enabled_flag
			 , last_update_date 
		  from apps.xla_product_rules_fvl xprf;

		select xpahf.*
		  from apps.xla_prod_acct_headers_fvl xpahf;
