/*
File Name:		po-requisitions-to-po-timings.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- NON CATALOGUE REQUISITIONS CONVERTED TO POS - DETAILS
-- REQUISITIONS CONVERTED TO POS - AVERAGE SUMMARY

*/

-- ##################################################################
-- NON CATALOGUE REQUISITIONS CONVERTED TO POS - DETAILS
-- ##################################################################

		select prha.segment1 req_num
			 , prla.line_num req_line_num
			 , pla.line_num po_line_num
			 , pha.segment1 po_num
			 , prha.creation_date r_date
			 , pha.creation_date p_date
			 , replace(replace(to_char(numtodsinterval(pha.creation_date - prha.creation_date,'day')),'.000000000',''),'+0000000','') diff5
			 , papf.full_name requisitioner
			 , haout.name req_hr_org
			 , pav.agent_name
		  from po.po_requisition_headers_all prha
		  join po.po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join po.po_line_locations_all plla on plla.line_location_id = prla.line_location_id
		  join po.po_lines_all pla on pla.po_line_id = plla.po_line_id
		  join po.po_headers_all pha on pha.po_header_id = plla.po_header_id
		  join hr.per_all_people_f papf on prha.preparer_id = papf.person_id
		  join hr.per_all_assignments_f paaf on paaf.person_id = papf.person_id
		  join hr.hr_all_organization_units_tl haout on haout.organization_id = paaf.organization_id
		  join apps.po_agents_v pav on pav.agent_id = pha.agent_id
		   and sysdate between papf.effective_start_date and papf.effective_end_date
		   and sysdate between paaf.effective_start_date and paaf.effective_end_date
		 where paaf.primary_flag = 'Y'
		   and paaf.assignment_type = 'E'
		   and prla.item_id is null
		   and pha.segment1 is not null
		   and prha.creation_date < pha.creation_date
		   and prla.catalog_type = 'NONCATALOG'
		   and prla.catalog_source = 'INTERNAL'
		   and prla.source_type_code = 'VENDOR'
		   -- -----------------------------------------------PARAMETERS:
		   and prha.creation_date >= :startdate
		   and prha.creation_date <= :enddate
	  order by prha.segment1
			 , prha.creation_date;

-- ##################################################################
-- REQUISITIONS CONVERTED TO POS - AVERAGE SUMMARY
-- ##################################################################

		select substr(avg(pha.creation_date - prha.creation_date), 0, 6) avg_days
			 , count(distinct prha.requisition_header_id) count_req
			 , count(prla.requisition_line_id) count_lines
		  from po.po_requisition_headers_all prha
		  join po.po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join po.po_line_locations_all plla on plla.line_location_id = prla.line_location_id
		  join po.po_lines_all pla on pla.po_line_id = plla.po_line_id
		  join po.po_headers_all pha on pha.po_header_id = plla.po_header_id
		  join hr.per_all_people_f papf on prha.preparer_id = papf.person_id
		  join hr.per_all_assignments_f paaf on paaf.person_id = papf.person_id
		  join hr.hr_all_organization_units_tl haout on haout.organization_id = paaf.organization_id
		  join apps.po_agents_v pav on pav.agent_id = pha.agent_id
		   and sysdate between papf.effective_start_date and papf.effective_end_date
		   and sysdate between paaf.effective_start_date and paaf.effective_end_date
		 where 1 = 1
		   -- -----------------------------------------------JOB CHECKING STUFF
		   and paaf.primary_flag = 'Y'
		   and paaf.assignment_type = 'E'
		   -- -----------------------------------------------ONLY INCLUDE CONVERTED REQS
		   and pha.segment1 is not null
		   and prha.creation_date < pha.creation_date
		   -- -----------------------------------------------NON CATALOGUE:
		   and prla.catalog_type = 'NONCATALOG'
		   and prla.catalog_source = 'INTERNAL'
		   and prla.source_type_code = 'VENDOR'
		   -- -----------------------------------------------PARAMETERS:
		   and prha.creation_date >= :startdate
		   and prha.creation_date <= :enddate
	  order by 1 desc;