/*
File Name: zx.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- TAX REGIMES
-- TAX RULES
-- TAX RULES HAVE DETERMINING FACTOR SETS ASSOCIATED WITH THEM
-- DETERMINING FACTOR CLASS
-- DETERMINING FACTORS 1
-- DETERMINING FACTORS 2
-- CLASS QUALIFIER
-- DETERMINING FACTORS WITH DETERMINING FACTOR CLASSES
-- TAX RATES 1
-- TAX RATES 2
-- TAX STATUS
-- TAX CLASSIFICATION CODES
-- CONDITION SETS
-- CONDITION SETS WITH CONDITIONS

*/

-- ##################################################################
-- TAX REGIMES
-- ##################################################################

select * from zx_regimes_vl;
select * from zx_regimes_vl where country_code = 'GB';

-- ##################################################################
-- TAX RULES
-- ##################################################################

		select zrb.tax_rule_code rule_code
			 , zrb.creation_date rule_created
			 , zrt.tax_rule_name rule_name
			 , flv_det_status.meaning rule_type
			 , zrb.tax_regime_code
			 , zrb.tax
			 , zrb.priority rule_order
			 , zrb.enabled_flag
			 , zrb.det_factor_templ_code
			 , zdftt.det_factor_templ_name
			 , zrb.record_type_code
			 , zrb.tax_event_class_code
			 , zrb.service_type_code
			 , '--------- CONDITION SETS -----------'
			 , zcgb.condition_group_code condition_set
			 , zcgb.enabled_flag
			 , zpr.priority condition_set_order
			 , zpr.result_type_code
			 , zpr.numeric_result
			 , zpr.alphanumeric_result
			 , zpr.enabled_flag
			 , zpr.record_type_code
			 , zpr.creation_date cond_rules_created
			 , zdftb.creation_date det_factor_created
			 , zcgb.creation_date cond_set_created
		  from zx.zx_rules_b zrb 
	 left join zx.zx_rules_tl zrt on zrb.tax_rule_id = zrt.tax_rule_id
	 left join zx.zx_det_factor_templ_b zdftb on zdftb.det_factor_templ_code = zrb.det_factor_templ_code
	 left join zx.zx_det_factor_templ_tl zdftt on zdftb.det_factor_templ_id = zdftt.det_factor_templ_id
	 left join apps.fnd_lookups flv_det_status on zrb.service_type_code = flv_det_status.lookup_code and flv_det_status.lookup_type = 'ZX_SERVICE_TYPE_CODES'
	 left join zx.zx_condition_groups_b zcgb on zcgb.det_factor_templ_code = zdftb.det_factor_templ_code
	 left join zx.zx_process_results zpr on zpr.condition_group_id = zcgb.condition_group_id
		 where 1 = 1
		   and zrb.tax_regime_code = 'GB VAT'
		   and zrb.tax = 'GB VAT'
		   and flv_det_status.meaning = 'Determine Recovery Rate'
		   -- and zrb.tax_rule_code = 'GB VAT STATUS'
		   -- and zrb.det_factor_templ_code = 'GB VAT STATUS'
		   -- and zrb.service_type_code = 'DET_TAX_STATUS'
		   -- and zcgb.condition_group_code = 'GB GOODS ZERO RATE'
		   -- and zdftb.det_factor_templ_code = 'GB VAT STATUS'
		   and 1 = 1;

-- ##################################################################
-- TAX RULES HAVE DETERMINING FACTOR SETS ASSOCIATED WITH THEM
-- ##################################################################

		select zrb.tax_rule_code rule_code
			 , zrt.tax_rule_name rule_name
			 , flv_det_status.meaning rule_type
			 , zrb.tax_rule_id
			 , zrb.tax_regime_code
			 , zrb.tax
			 , zrb.application_id
			 , zrb.recovery_type_code
			 , zrb.priority
			 , zrb.enabled_flag
			 , zrb.det_factor_templ_code
			 , '##########################'
			 , zdftt.det_factor_templ_name
			 , zrb.creation_date
			 , zrb.record_type_code
			 , zrb.tax_event_class_code
			 , zrb.service_type_code
			 , '--------- CONDITION SETS -----------'
			 , zcgb.condition_group_code condition_set
			 , zcgb.enabled_flag
			 , zpr.priority
			 , zpr.result_type_code
			 , zpr.numeric_result
			 , zpr.alphanumeric_result
			 , zpr.enabled_flag
			 , zpr.record_type_code
			 , zpr.creation_date
			 , '##########################'
			 , zcgb.condition_group_code
			 , zcgb.enabled_flag
			 , '####################'
			 , flv_class.meaning det_factor_class
			 , flv_class_qual.meaning class_qualifier
			 , zc.determining_factor_code det_factor_name
			 , zc.operator_code operator
			 , zc.data_type_code
			 , zc.ignore_flag
			 , zc.numeric_value
			 , zc.date_value
			 , zc.alphanumeric_value
			 , zc.value_low
			 , zc.value_high
			 , zc.creation_date
		  from zx.zx_rules_b zrb 
	 left join zx.zx_rules_tl zrt on zrb.tax_rule_id = zrt.tax_rule_id
	 left join zx.zx_det_factor_templ_b zdftb on zdftb.det_factor_templ_code = zrb.det_factor_templ_code
	 left join zx.zx_det_factor_templ_tl zdftt on zdftb.det_factor_templ_id = zdftt.det_factor_templ_id
	 left join apps.fnd_lookups flv_det_status on zrb.service_type_code = flv_det_status.lookup_code and flv_det_status.lookup_type = 'ZX_SERVICE_TYPE_CODES'
	 left join zx.zx_condition_groups_b zcgb on zcgb.det_factor_templ_code = zdftb.det_factor_templ_code
	 left join zx.zx_process_results zpr on zpr.condition_group_id = zcgb.condition_group_id
	 left join zx.zx_conditions zc on zc.condition_group_code = zcgb.condition_group_code
	 left join apps.fnd_lookups flv_class on zc.determining_factor_class_code = flv_class.lookup_code and flv_class.lookup_type = 'ZX_DETERMINING_FACTOR_CLASS'
	 left join apps.fnd_lookups flv_class_qual on zc.determining_factor_cq_code = flv_class_qual.lookup_code and flv_class_qual.lookup_type = 'ZX_GEO_PARTY_SUB_CLASS'
		 where 1 = 1
		   and zrb.tax_rule_code = 'GB VAT STATUS'
		   and zrb.det_factor_templ_code = 'GB VAT STATUS'
		   and zrb.service_type_code = 'DET_TAX_STATUS'
		   and zrb.tax_regime_code = 'GB VAT'
		   and zc.determining_factor_code = 'TAX_CLASSIFICATION_CODE'
		   and zrb.enabled_flag = 'Y'
		   and zcgb.enabled_flag = 'Y'
		   and zpr.enabled_flag = 'Y'
		   -- and zcgb.condition_group_code = 'GB GOODS ZERO RATE'
		   and 1 = 1;

-- ##################################################################
-- DETERMINING FACTOR CLASS
-- ##################################################################

		select lookup_type
			 , lookup_code
			 , meaning
		  from fnd_lookups 
		 where 1 = 1
		   -- and lookup_type like 'ZX%'
		   and lookup_type = 'ZX_DETERMINING_FACTOR_CLASS' 
		   and lookup_code not in ('DERIVED', 'EVENT') 
		   -- and lookup_type like 'ZX%'
		   and sysdate between start_date_active 
		   and nvl(end_date_active, sysdate) 
		   and nvl(enabled_flag, 'N') = 'Y'
		   -- and meaning in ('Level 1','Point of Acceptance','First Party','Point of Acceptance Party','Point of Origin')
		   and 1 = 1;

-- ##################################################################
-- DETERMINING FACTORS 1
-- ##################################################################

		select distinct fa.application_short_name
			 , fa.application_name
			 , lookup.meaning as determining_factor_class_name
			 , determining_factor_name
			 , determining_factor_desc
			 , decode(df.tax_rules_flag, 'Y', 'Tax Rules', decode(df.taxable_basis_flag, 'Y', 'Taxable Basis Formula', decode(df.tax_regime_det_flag, 'Y', 'Tax Regime Determination'))) usage
		  from zx_determining_factors_vl df
		     , fnd_lookups lookup
		     , fnd_application_vl fa
		 where 1 = 1
		   and df.determining_factor_class_code = lookup.lookup_code and lookup.lookup_type = 'ZX_DETERMINING_FACTOR_CLASS' and lookup.lookup_code <> 'DERIVED' and sysdate between lookup.start_date_active and nvl(lookup.end_date_active, sysdate) and nvl(lookup.enabled_flag, 'N') = 'Y'
		   and (tax_rules_flag = 'Y' or tax_regime_det_flag = 'Y' or taxable_basis_flag = 'Y')
		   and fa.application_id in (select distinct application_id from zx_evnt_cls_mappings ecm2)
		   and fa.application_id not in (select nvl(ecm.application_id, -99) from zx_event_class_params ecp, zx_determining_factors_vl df1, zx_evnt_cls_mappings ecm where df1.tax_parameter_code = ecp.tax_parameter_code(+) and ecm.event_class_mapping_id(+) = ecp.event_class_mapping_id and df1.determining_factor_id = df.determining_factor_id)
		   and fa.application_name = 'Payables';

-- ##################################################################
-- DETERMINING FACTORS 2
-- ##################################################################

		select zdftb.det_factor_templ_code
			 , zdftt.det_factor_templ_name
			 , zdftb.det_factor_templ_id
			 , zdftb.tax_regime_code
			 , zdftb.template_usage_code
			 , zdftb.record_type_code
		  from zx.zx_det_factor_templ_b zdftb
		  join zx.zx_det_factor_templ_tl zdftt on zdftb.det_factor_templ_id = zdftt.det_factor_templ_id
		 where 1 = 1
		   and zdftb.det_factor_templ_code like 'U%AP%'
		   and zdftb.tax_regime_code = 'GB VAT'
		   and 1 = 1;

-- ##################################################################
-- CLASS QUALIFIER
-- ##################################################################

		select lookup_code
			 , meaning
			 , lookup_type
		  from fnd_lookups 
		 where 1 = 1
		   and lookup_type = 'ZX_PLACE_OF_SUPPLY_TYPE'
		   and sysdate between start_date_active and nvl(end_date_active, sysdate) 
		   and nvl(enabled_flag, 'N') = 'Y' 
		   and ((lookup_type in ('ZX_PLACE_OF_SUPPLY_TYPE','ZX_REGISTRATION_CQ') 
		   and lookup_code <> 'SHIP_TO_BILL_TO') or (lookup_type not in ('ZX_PLACE_OF_SUPPLY_TYPE','ZX_REGISTRATION_CQ')))
		   -- and meaning in ('Point of Acceptance')
		   and 1 = 1;

-- ##################################################################
-- DETERMINING FACTORS WITH DETERMINING FACTOR CLASSES
-- ##################################################################

		select zdftb.det_factor_templ_code
			 , zdftt.det_factor_templ_name
			 , zdftb.tax_regime_code
			 , zdftb.template_usage_code
			 , zdftb.record_type_code
			 , zdftb.creation_date
			 , zdftd.determining_factor_class_code
			 , zdftd.determining_factor_cq_code
			 , zdftd.determining_factor_code
			 , zdftd.tax_parameter_code
		  from zx.zx_det_factor_templ_b zdftb
		  join zx.zx_det_factor_templ_tl zdftt on zdftb.det_factor_templ_id = zdftt.det_factor_templ_id
		  join zx.zx_det_factor_templ_dtl zdftd on zdftd.det_factor_templ_id = zdftb.det_factor_templ_id
		 where zdftb.det_factor_templ_code = 'THIS';

-- ##################################################################
-- TAX RATES 1
-- ##################################################################

		select zrb.creation_date
			 , fu.user_name created_by
			 , zrb.last_update_date
			 , fu2.user_name updated_by
			 , zrb.tax_rate_code
			 , zrt.tax_rate_name
			 , zrt.description
			 , to_char(zrb.effective_from, 'dd-MON-yyyy') effective_from
			 , to_char(zrb.effective_to, 'dd-MON-yyyy') effective_to
			 , zrb.tax_regime_code
			 , zrb.percentage_rate
			 , zrb.active_flag
			 , zrb.default_rec_rate_code 
			 , zrb.rate_type_code
			 , zrb.tax_rate_id
			 -- , gcc.concatenated_segments code_comb
			 -- , '####################'
			 -- , zrb.*
			 -- , '####################'
			 -- , zrt.*
		  from zx.zx_rates_b zrb
		  join zx.zx_rates_tl zrt on zrb.tax_rate_id = zrt.tax_rate_id
		  join applsys.fnd_user fu on zrb.created_by = fu.user_id
		  join applsys.fnd_user fu2 on zrb.last_updated_by = fu2.user_id
	 left join zx.zx_accounts za on za.tax_account_entity_id = zrb.tax_rate_id and za.tax_account_entity_code = 'RATES'
	 -- left join apps.gl_code_combinations_kfv gcc on gcc.code_combination_id = za.tax_account_ccid
		 where 1 = 1
		   and nvl(zrb.effective_to, sysdate + 1) > sysdate
		   -- and zrb.percentage_rate = 0
		   -- and zrb.tax_rate_code like 'GB%'
		   and zrb.active_flag = 'Y'
		   -- and zrb.effective_to is null
		   -- and zrb.record_type_code = 'USER_DEFINED'
		   -- and tax_rate_code = 'MPR'
		   -- and tax_rate_code like 'M%'
		   -- and zrb.creation_date > '01-OCT-2018'
		   -- and zrb.tax_rate_code = 'NONREC'
		   -- and zrb.tax_rate_code like 'BUS%'
		   and 1 = 1
	  order by zrb.creation_date desc;

-- ##################################################################
-- TAX RATES 2
-- ##################################################################

		select rb.tax_rate_code
			 , rb.rate_type_code
			 , rb.percentage_rate
			 , rb.recovery_type_code
			 , gl.name ledger
			 , ta.tax_account_ccid
			 , gcc_1.segment1 || '.' || gcc_1.segment2 || '.' || gcc_1.segment3 || '.' || gcc_1.segment4 || '.' || gcc_1.segment5 || '.' || gcc_1.segment6 || '.' || gcc_1.segment7 || '.' || gcc_1.segment8 tax_account
			 , ta.tax_liab_acct_ccid
			 , gcc_2.segment1 || '.' || gcc_2.segment2 || '.' || gcc_2.segment3 || '.' || gcc_2.segment4 || '.' || gcc_2.segment5 || '.' || gcc_2.segment6 || '.' || gcc_2.segment7 || '.' || gcc_2.segment8 tax_liability
			 , ta.non_rec_account_ccid
			 , gcc_3.segment1 || '.' || gcc_3.segment2 || '.' || gcc_3.segment3 || '.' || gcc_3.segment4 || '.' || gcc_3.segment5 || '.' || gcc_3.segment6 || '.' || gcc_3.segment7 || '.' || gcc_3.segment8 tax_non_rec
			 , ta.interim_tax_ccid
			 , gcc_4.segment1 || '.' || gcc_4.segment2 || '.' || gcc_4.segment3 || '.' || gcc_4.segment4 || '.' || gcc_4.segment5 || '.' || gcc_4.segment6 || '.' || gcc_4.segment7 || '.' || gcc_4.segment8 tax_interim
		  from zx_rates_b rb
		  join zx_accounts ta on ta.tax_account_entity_id = rb.tax_rate_id
	 left join gl_ledgers gl on gl.ledger_id = ta.ledger_id
	 left join gl_code_combinations gcc_1 on gcc_1.code_combination_id = ta.tax_account_ccid
	 left join gl_code_combinations gcc_2 on gcc_2.code_combination_id = ta.tax_liab_acct_ccid
	 left join gl_code_combinations gcc_3 on gcc_3.code_combination_id = ta.non_rec_account_ccid
	 left join gl_code_combinations gcc_4 on gcc_4.code_combination_id = ta.interim_tax_ccid
		 where 1 = 1
		   and ta.tax_account_entity_code = 'RATES'
		   and 1 = 1

-- ##################################################################
-- TAX STATUS
-- ##################################################################

		select zsb.creation_date
			 , fu.user_name
			 , zsb.tax_status_code
			 , zsb.effective_from
			 , zsb.effective_to
			 , zsb.tax
			 , zsb.tax_regime_code
			 , '#############'
			 , zsb.*
		  from zx.zx_status_b zsb
		  join zx.zx_status_tl zst on zsb.tax_status_id = zst.tax_status_id
		  join applsys.fnd_user fu on zsb.created_by = fu.user_id
		 where 1 = 1
		   -- and zsb.record_type_code = 'USER_DEFINED'
		   and tax_status_code like 'GB%STAND%'
		   and 1 = 1;

-- ##################################################################
-- TAX CLASSIFICATION CODES
-- ##################################################################

		select zfcb.creation_date
			 , fu.user_name
			 , zfcb.classification_code
			 , zfcb.classification_type_code
			 , zfct.classification_name
		  from zx.zx_fc_codes_b zfcb
		  join zx.zx_fc_codes_tl zfct on zfcb.classification_id = zfct.classification_id
		  join applsys.fnd_user fu on zfcb.created_by = fu.user_id
		 where 1 = 1
		   -- and zfcb.classification_code like '%OS%'
		   and 1 = 1;

-- ##################################################################
-- CONDITION SETS
-- ##################################################################

		select zcgb.creation_date
			 , fu.user_name
			 , zcgb.condition_group_code condition_set
			 , zcgt.condition_group_name name
			 , zcgb.det_factor_templ_code det_factor_set
			 , zcgb.country_code
			 , zcgb.enabled_flag
			 , '--------------------'
			 , zcgb.*
			 , '--------------------'
		  from zx.zx_condition_groups_b zcgb
		  join zx.zx_condition_groups_tl zcgt on zcgb.condition_group_id = zcgt.condition_group_id
		  join applsys.fnd_user fu on zcgb.created_by = fu.user_id
		 where 1 = 1
		   and zcgb.condition_group_code like 'U%'
		   and 1 = 1;

-- ##################################################################
-- CONDITION SETS WITH CONDITIONS
-- ##################################################################

		select zcgb.creation_date
			 , fu.user_name
			 , zc.creation_date condition_created
			 , zcgb.condition_group_code condition_set
			 , zcgt.condition_group_name name
			 , zcgb.det_factor_templ_code det_factor_set
			 , zcgb.last_update_date
			 , zc.condition_group_code
			 , zc.condition_group_code
			 , zc.determining_factor_code
			 , zc.operator_code
			 , zc.ignore_flag
			 , zc.value_low
			 , zc.last_update_date
		  from zx.zx_condition_groups_b zcgb
		  join zx.zx_condition_groups_tl zcgt on zcgb.condition_group_id = zcgt.condition_group_id
		  join zx.zx_conditions zc on zc.condition_group_code = zcgb.condition_group_code
		  join applsys.fnd_user fu on zcgb.created_by = fu.user_id
		 where 1 = 1
		   and 1 = 1
	  order by zcgb.last_update_date desc;
