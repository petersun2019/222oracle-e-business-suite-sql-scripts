/*
File Name: ar-locations.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- AR LOCATIONS
-- ##################################################################

		select p.party_id
			 , p.party_number
			 , p.party_name
			 , p.status party_status
			 , identifying_address_flag
			 , l.creation_date loc_creation
			 , ps.party_site_id
			 , ps.status party_site_status
			 , ps.creation_date ps_creation 
			 , psu.creation_date psu_creation
			 , psu.site_use_type
			 , psu.status use_status 
			 , l.address1
			 , l.address2
			 , l.country
			 , l.postal_code
		  from ar.hz_parties p
		  join ar.hz_party_sites ps on p.party_id = ps.party_id
		  join ar.hz_party_site_uses psu on ps.party_site_id = psu.party_site_id
		  join ar.hz_locations l on ps.location_id = l.location_id
		 where 1 = 1
		   and p.status = 'A'
		   and ps.status = 'A'
		   and psu.site_use_type in ('HOME', 'TERM')
		   -- and length(p.party_number) > 7
		   -- and p.party_number in ('123456')
		   and l.creation_date > '20-NOV-2015';
