/*
File Name: po-requisitions-preparer-vs-requester.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- REQUISITION PREPAPER AND REQUESTER DETAILS
-- REQUISITION REQUESTER LOCATION DETAILS WHERE REQUESTER HAS NO USER ACCOUNT
-- REQ RAISED ON BEHALF OF SOMEONE, WHERE THAT USER DID NOT HAVE A USER RECORD.
-- BASIC HR AND USER DETAILS

Requisitions are created by the preparer
The preparer is stored at requisition header, and the preparer_id is the hr person_id for the user raising the req
The requester is the person who the requisition is being created on behalf of.
The requester is stored at requisition line level
In iproc, in a requisition, the preparer means the person who is preparing the requisition.
Requestor is someone who is requesting the item.
Preparer and requestor may be different if the person (preparer) is preparing a requisition for an item requested by someone else (requestor).
*/

-- ##################################################################
-- REQUISITION PREPAPER AND REQUESTER DETAILS
-- ##################################################################

		select prha.segment1 req
			 , prha.requisition_header_id
			 , prha.creation_date
			 , prla.line_num line
			 , prla.creation_date
			 , prla.last_update_date
			 , prla.suggested_vendor_product_code
			 , hla1.location_code req_del_to
			 , papf_created_by.full_name created_by
			 , fu1.user_name created_by_user
			 , papf_preparer.full_name preparer
			 , fu_preparer.user_name prepaper_user
			 , papf_requester.full_name requester
			 , papf_requester.employee_number requester_empno
			 , hla2.location_code requester_loc
			 , pax.default_code_comb_id
			 , gcc.concatenated_segments code_comb
			 , fu_req.user_name requester_user
		  from po_requisition_headers_all prha
		  join po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join fnd_user fu1 on prha.created_by = fu1.user_id
		  join per_people_x papf_created_by on papf_created_by.person_id = fu1.employee_id
		  join per_people_x papf_preparer on papf_preparer.person_id = prha.preparer_id
		  join per_people_x papf_requester on papf_requester.person_id = prla.to_person_id
		  join per_assignments_x pax on pax.person_id = papf_requester.person_id
		  join hr_locations_all hla1 on prla.deliver_to_location_id = hla1.location_id
		  join hr_locations_all hla2 on pax.location_id = hla2.location_id
		  join gl_code_combinations_kfv gcc on gcc.code_combination_id = pax.default_code_comb_id
	 left join fnd_user fu_preparer on fu_preparer.employee_id = papf_preparer.person_id
	 left join fnd_user fu_req on fu_req.employee_id = papf_requester.person_id
		 where 1 = 1
		   and prha.requisition_header_id in (123, 456, 789)
		   and prha.segment1 = 'REQ123456'
		   and 1 = 1
	  order by prha.creation_date desc;

-- ##################################################################
-- REQUISITION REQUESTER LOCATION DETAILS WHERE REQUESTER HAS NO USER ACCOUNT
-- ##################################################################

		select papf_requester.full_name requester
			 , papf_requester.employee_number requester_empno
			 , pax.last_update_date
			 , pax.last_updated_by
			 , hla2.location_code requester_loc
			 , gcc.concatenated_segments code_comb
			 , fu.user_name
		  from per_people_x papf_requester
		  join per_assignments_x pax on pax.person_id = papf_requester.person_id
		  join hr_locations_all hla2 on pax.location_id = hla2.location_id
		  join gl_code_combinations_kfv gcc on gcc.code_combination_id = pax.default_code_comb_id
	 left join fnd_user fu on fu.employee_id = papf_requester.person_id
		 where 1 = 1
		   and hla2.location_code = 'CHEESE HQ'
		   and fu.user_name is null
		   and 1 = 1;

-- ##################################################################
-- REQ RAISED ON BEHALF OF SOMEONE, WHERE THAT USER DID NOT HAVE A USER RECORD.
-- ##################################################################

		select prla.to_person_id
			 , ppx.full_name
			 , fu.user_name
			 , count(*) ct
		  from po_requisition_lines_all prla
		  join po_requisition_headers_all prha on prla.requisition_header_id = prha.requisition_header_id
		  join per_people_x ppx on prla.to_person_id = ppx.person_id
	 left join fnd_user fu on ppx.person_id = fu.employee_id
		 where 1 = 1
		   -- and prla.creation_date > '01-JAN-2017'
		   and prha.preparer_id <> prla.to_person_id
		   and fu.user_id is null
	  group by prla.to_person_id
			 , ppx.full_name
			 , fu.user_name;

-- ##################################################################
-- BASIC HR AND USER DETAILS
-- ##################################################################

		select ppx.full_name
			 , ppx.person_id
			 , ppx.employee_number
			 , to_char(ppx.effective_start_date, 'DD-MON-YYYY') hr_record_start_date
			 , fu.user_name
			 , to_char(fu.start_date, 'DD-MON-YYYY') user_account_start_date
		  from per_people_x ppx
	 left join fnd_user fu on ppx.person_id = fu.employee_id
		 where ppx.full_name in ('Cheese, Mr Edam','Brie, Mrs Fine');
