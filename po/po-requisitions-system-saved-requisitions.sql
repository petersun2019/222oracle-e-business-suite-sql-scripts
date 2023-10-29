/*
File Name:		po-requisitions-system-saved-requisitions.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- SIMPLE CHECK
-- SUMMARY PER REQ INC LINKED PROJECT COUNT
-- DETAILS FOR EACH REQ INCLUDING LINKED PROJECTS

*/

-- ###################################################################
-- SIMPLE CHECK
-- ###################################################################

		select *
		  from po.po_requisition_headers_all
		 where segment1 like '##%';

-- ###################################################################
-- SUMMARY PER REQ INC LINKED PROJECT COUNT
-- ###################################################################

		select prha.segment1 req
			 , prha.creation_date
			 , trunc(sysdate) - trunc(prha.creation_date) age
			 , fu1.description cr_by
			 , fu2.description upd_by
			 , (select count(distinct ppa.segment1)
								  from po.po_requisition_lines_all prla
									 , po.po_req_distributions_all prda
									 , pa.pa_projects_all ppa 
								 where prla.requisition_header_id = prha.requisition_header_id
								   and prla.requisition_line_id = prda.requisition_line_id
								   and prda.project_id = ppa.project_id) proj
		  from po.po_requisition_headers_all prha
		  join applsys.fnd_user fu1 on prha.created_by = fu1.user_id
		  join applsys.fnd_user fu2 on prha.last_updated_by = fu2.user_id
		 where segment1 like '##%'
	  order by prha.creation_date desc;

-- ###################################################################
-- DETAILS FOR EACH REQ INCLUDING LINKED PROJECTS
-- ###################################################################

		select distinct prha.segment1 req
			 , prha.creation_date
			 , trunc(sysdate) - trunc(prha.creation_date) age
			 , fu1.description cr_by
			 , fu2.description upd_by
			 , ppa.segment1 proj
		  from po.po_requisition_headers_all prha
		  join applsys.fnd_user fu1 on prha.created_by = fu1.user_id
		  join applsys.fnd_user fu2 on prha.last_updated_by = fu2.user_id 
		  join po.po_requisition_lines_all prla on prla.requisition_header_id = prha.requisition_header_id
		  join po.po_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
	 left join pa.pa_projects_all ppa on prda.project_id = ppa.project_id
		 where prha.segment1 like '##%'
		   -- and prha.segment1 = :req
	  order by prha.segment1
			 , ppa.segment1;
