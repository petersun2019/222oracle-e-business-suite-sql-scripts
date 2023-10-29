/*
File Name:		sa-attachments.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- TABLE DUMPS
-- AP INVOICES
-- PURCHASE ORDERS
-- PROJECTS
-- AR TRANSACTIONS

*/

-- ##################################################################
-- TABLE DUMPS
-- ##################################################################

select * from applsys.fnd_documents where creation_date > '02-may-2019';
select * from applsys.fnd_attached_documents where creation_date > '02-may-2019';
select * from applsys.fnd_attached_documents where entity_name = 'PA_PROJECTS';
select * from fnd_attached_documents where pk1_value = '123456';

-- ##################################################################
-- AP INVOICES
-- ##################################################################

		select fad.pk1_value source_transaction_id -- e.g. po_header_id, ap_invoice_id etc.
			 , fdet.user_entity_name -- e.g. invoice
			 , fad.creation_date
			 , fad.entity_name
			 , fdt.title attachment_title
			 , fd.file_name
			 , substr(fd.file_name, (length(fd.file_name)-2),3) file_format
			 , fdct.user_name category
		  from applsys.fnd_document_datatypes fdt
		  join applsys.fnd_documents fd on fd.datatype_id = fdt.datatype_id
		  join applsys.fnd_attached_documents fad on fd.document_id = fad.document_id
		  join applsys.fnd_documents_tl fdt on fdt.document_id = fd.document_id
		  join applsys.fnd_document_entities_tl fdet on fad.entity_name = fdet.data_object_code
		  join applsys.fnd_document_categories_tl fdct on fdct.category_id = fd.category_id
		 where 1 = 1
		   and fad.creation_date > '16-APR-2020'
		   -- and fad.pk1_value = '123456' -- e.g. invoice_id
		   and fad.entity_name = 'AP_INVOICES_ALL'
		   and 1 = 1
	  order by fad.creation_date desc;

-- ##################################################################
-- PURCHASE ORDERS
-- ##################################################################

		select pha.segment1 po
			 , pha.po_header_id
			 , pha.creation_date
			 , pha.approved_date
			 , pha.creation_date po_created
			 , '###############'
			 , fdet.user_entity_name -- e.g. po head
			 , fad.creation_date attachment_created
			 , fad.entity_name
			 , fdt.title attachment_title
			 , fd.file_name
			 , substr(fd.file_name, (length(fd.file_name)-2),3) file_format
			 , fdct.user_name category
		  from po.po_headers_all pha
		  join applsys.fnd_attached_documents fad on fad.pk1_value = pha.po_header_id and fad.entity_name = 'PO_HEAD'
		  join applsys.fnd_document_entities_tl fdet on fad.entity_name = fdet.data_object_code and fdet.language = userenv('lang')
		  join applsys.fnd_documents fd on fd.document_id = fad.document_id
		  join applsys.fnd_documents_tl fdt on fdt.document_id = fd.document_id and fdt.language = userenv('lang')
		  join applsys.fnd_document_datatypes fdt1 on fdt1.datatype_id = fd.datatype_id
		  join applsys.fnd_document_categories_tl fdct on fdct.category_id = fd.category_id and fdct.language = userenv('lang')
		 where 1 = 1
		   and fad.creation_date > '16-APR-2020'
	  order by fad.creation_date desc;

-- ##################################################################
-- PROJECTS
-- ##################################################################

		select ppa.segment1 project
			 , ppa.project_id id
			 , ppa.name
			 , haou.name org
			 , ppa.creation_date project_created
			 , to_char(ppa.start_date, 'DD-MON-YYYY') start_date
			 , to_char(ppa.completion_date, 'DD-MON-YYYY') end_date
			 , ppta.project_type
			 , pps.project_status_name
			 , '###############'
			 , fdet.user_entity_name -- e.g. project
			 , fad.creation_date
			 , fad.entity_name
			 , fdt.title attachment_title
			 , fd.file_name
			 , substr(fd.file_name, (length(fd.file_name)-2),3) file_format
			 , fdct.user_name category
		  from pa.pa_projects_all ppa
		  join pa.pa_project_statuses pps on ppa.project_status_code = pps.project_status_code
		  join pa.pa_project_types_all ppta on ppa.project_type = ppta.project_type and ppa.org_id = ppta.org_id
		  join hr.hr_all_organization_units haou on ppa.carrying_out_organization_id = haou.organization_id
		  join applsys.fnd_attached_documents fad on fad.pk1_value = ppa.project_id and fad.entity_name = 'PA_PROJECTS'
		  join applsys.fnd_document_entities_tl fdet on fad.entity_name = fdet.data_object_code
		  join applsys.fnd_documents fd on fd.document_id = fad.document_id
		  join applsys.fnd_documents_tl fdt on fdt.document_id = fd.document_id
		  join applsys.fnd_document_datatypes fdt1 on fdt1.datatype_id = fd.datatype_id
		  join applsys.fnd_document_categories_tl fdct on fdct.category_id = fd.category_id
		 where 1 = 1
		   -- and ppa.segment1 in ('123456')
		   and ppa.project_id = 123456
		   and fad.entity_name = 'PA_PROJECTS'
		   -- and pps.project_status_name = 'Approved'
	  order by ppa.creation_date desc;

-- ##################################################################
-- AR TRANSACTIONS
-- ##################################################################

		select fad.pk1_value source_transaction_id -- e.g. po_header_id, ap_invoice_id etc.
			 , fdet.user_entity_name -- e.g. po head, invoice, disbursement payment instruction etc
			 , fad.creation_date
			 , fad.entity_name
			 , fdt.title attachment_title
			 , fd.file_name
			 , substr(fd.file_name, (length(fd.file_name)-2),3) file_format
			 , fdct.user_name category
		  from applsys.fnd_document_datatypes fdt
		  join applsys.fnd_documents fd on fd.datatype_id = fdt.datatype_id
		  join applsys.fnd_attached_documents fad on fd.document_id = fad.document_id
		  join applsys.fnd_documents_tl fdt on fdt.document_id = fd.document_id
		  join applsys.fnd_document_entities_tl fdet on fad.entity_name = fdet.data_object_code
		  join applsys.fnd_document_categories_tl fdct on fdct.category_id = fd.category_id
		 where 1 = 1
		   -- and fad.creation_date > '16-APR-2020'
		   and fad.pk1_value = '123456' -- e.g. transaction id
		   and fad.entity_name = 'RA_CUSTOMER_TRX'
		   and 1 = 1
	  order by fad.creation_date desc;
