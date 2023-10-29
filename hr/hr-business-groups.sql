/*
File Name:		hr-business-groups.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- HR BUSINESS GROUPS
-- ##################################################################

		select hrl.country
			 , hroutl_bg.name bg
			 , hroutl_bg.organization_id
			 , lep.legal_entity_id
			 , lep.name legal_entity
			 , hroutl_ou.name ou_name
			 , hroutl_ou.organization_id org_id
			 , hrl.location_id
			 , hrl.location_code
			 , hrl.description
			 , glev.flex_segment_value
		  from xle.xle_entity_profiles lep
		  join xle.xle_registrations reg on lep.legal_entity_id = reg.source_id
		  join hr.hr_locations_all hrl on hrl.location_id = reg.location_id
		  join ar.hz_parties hzp on lep.party_id = hzp.party_id
		  join apps.hr_operating_units hro on lep.legal_entity_id = hro.default_legal_context_id
		  join hr.hr_all_organization_units_tl hroutl_bg on hroutl_bg.organization_id = hro.business_group_id
		  join hr.hr_all_organization_units_tl hroutl_ou on hroutl_ou.organization_id = hro.organization_id
	 left join gl.gl_legal_entities_bsvs glev on glev.legal_entity_id = lep.legal_entity_id
		 where lep.transacting_entity_flag = 'Y'
		   and reg.source_table = 'XLE_ENTITY_PROFILES';
