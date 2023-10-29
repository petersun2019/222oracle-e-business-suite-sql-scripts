/*
File Name:		po-approval-history.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- REQUISITION ACTION HISTORY
-- PO APPROVAL HISTORY 
-- REQUISITION CANCELLATIONS

*/

-- ##################################################################
-- REQUISITION ACTION HISTORY
-- ##################################################################

		select * from po_req_distributions_all;

		select prha.segment1 req
			 , prha.authorization_status req_status
			 , prha.approved_date
			 , prha.creation_date req_created
			 , pah.sequence_num seq
			 , pah.action_date date_
			 , pah.object_revision_num rev
			 , pah.action_code
			 , papf.full_name performed_by
			 , pah.note
			 , prha.wf_item_type
			 , prha.wf_item_key
			 , fu.user_name created_by
		  from po.po_action_history pah
		  join po.po_requisition_headers_all prha on object_id = prha.requisition_header_id
		  join applsys.fnd_user fu on pah.employee_id = fu.employee_id
		  join hr.per_all_people_f papf on fu.employee_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
		 where pah.object_type_code = 'REQUISITION'
		   and prha.segment1 in ('123456')
		   -- and papf.person_id = 123456
		   -- and pah.action_code = 'APPROVE'
		   -- and papf.full_name = 'Cheese, Mr Cheddar'
		   -- and fu.user_name in ('CHEESE_USER')
		   -- and prha.authorization_status = 'APPROVED'
		   -- and action_date > '01-JAN-2021'
	  order by prha.creation_date desc
			 , pah.sequence_num;

-- ##################################################################
-- PO APPROVAL HISTORY 
-- ##################################################################

		select pha.segment1 po
			 , pha.document_creation_method
			 , pha.authorization_status po_status
			 , pha.creation_date po_created
			 , pah.sequence_num seq
			 , pah.action_date date_
			 , pah.action_code
			 , papf.full_name performed_by
			 , papf.person_id
			 , fu.user_id
			 , fu.user_name
			 , fu.employee_id
			 , fu.email_address
			 , fu_po.user_name po_created_by
			 , pha.wf_item_key
		  from po.po_action_history pah 
		  join po.po_headers_all pha on object_id = pha.po_header_id
		  join applsys.fnd_user fu on pah.employee_id = fu.employee_id
		  join hr.per_all_people_f papf on fu.employee_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
		  join applsys.fnd_user fu_po on pha.created_by = fu_po.user_id
		 where pah.object_type_code = 'PO'
		   -- and papf.employee_num = '0123456'
		   -- and pha.segment1 in ('PO123456','PO123457')
		   -- and pha.document_creation_method = 'CREATEDOC'
		   and pha.creation_date > '03-JUL-2022'
		   -- and papf.full_name = 'Williams, Mr Paul'
		   -- and pha.segment1 = 'PO123456'
		   -- and pha.po_header_id = 123456
		   -- and papf.last_name = 'Cheddar'
	  order by pha.segment1
			 , pah.sequence_num;

-- ##################################################################
-- REQUISITION CANCELLATIONS
-- ##################################################################

		select pah.creation_date
			 , prha.creation_date req_date
			 , prha.authorization_status
			 , prha.segment1
			 , prha.cancel_flag
			 , prha.interface_source_code
			 , prha.wf_item_key
			 , prha.approved_date
			 , prha.created_by
			 , pah.created_by
		  from po.po_action_history pah
		  join po.po_requisition_headers_all prha on object_id = prha.requisition_header_id
		 where pah.object_type_code = 'REQUISITION'
		   and pah.action_code = 'CANCEL'
		   and pah.creation_date > '01-OCT-2013'
		   and pah.creation_date < '01-NOV-2013'
		   and prha.approved_date is null
		   and prha.created_by <> pah.created_by
	  order by prha.segment1 desc;
