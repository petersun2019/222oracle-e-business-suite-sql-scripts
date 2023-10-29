/*
File Name: po-counts.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- REQUISITION COUNT SUMMARY SHOWING NUMBER OF REQS RAISED BY USER
-- REQUISITION COUNT SUMMARY VIA HR ORG
-- REQUISITION COUNT SUMMARY PER WEB REQ USER
-- COUNT SUMMARY SHOWING NUMBER OF POS RAISED BY USER
-- COUNT SUMMARY SHOWING NUMBER OF POS AUTOCREATED BY USER
-- SUMMARY OF PO VOLUMES
-- SUMMARY OF REQ VOLUMES
-- SUMMARY OF RECEIPT VOLUMES
-- RECEIPT VOLUMES BY YEAR AND MONTH
-- BASIC COUNT OF POS AND REQ VOLUME WITH VALUE
-- REQS
-- POS
-- BASIC COUNT OF REQUISITIONS BY CATALOGUE VS NON CATALOGUE
-- BASIC COUNT OF REQUISITION HEADERS, LINES AND VALUES
-- COMPARING AUTOCREATE VOLUMES VS OTHER IN LAST 30 DAYS

*/

-- ###################################################################
-- REQUISITION COUNT SUMMARY SHOWING NUMBER OF REQS RAISED BY USER
-- ###################################################################

		select count(distinct prha.requisition_header_id) req_count
			 , max(prha.creation_date) last_req_raised_date
			 , round(sysdate - max(prha.creation_date), 2) time_since_last_req
			 , papf.full_name
			 , haou.name hr_org
			 , hla.description user_loc
			 , papf.email_address email
		  from po.po_requisition_headers_all prha
		  join hr.per_all_people_f papf on prha.preparer_id = papf.person_id
		  join hr.per_all_assignments_f paaf on papf.person_id = paaf.person_id
		  join hr.hr_all_organization_units haou on paaf.organization_id = haou.organization_id
		  join hr.hr_locations_all hla on paaf.location_id = hla.location_id
		   and sysdate between papf.effective_start_date and papf.effective_end_date
		   and sysdate between paaf.effective_start_date and paaf.effective_end_date
		 where papf.current_employee_flag = 'Y'
		   and paaf.assignment_type = 'E'
		   and paaf.primary_flag = 'Y'
		   and prha.creation_date >= '01-JUN-2016'
		   and prha.authorization_status = 'APPROVED'
	  group by papf.full_name
			 , haou.name
			 , hla.description
			 , papf.email_address
	  order by 1 desc;

-- ###################################################################
-- REQUISITION COUNT SUMMARY VIA HR ORG
-- ###################################################################

		select count(*)
			 , haout.name hr_org
		  from po.po_requisition_headers_all prha
		  join hr.per_all_people_f papf on prha.preparer_id = papf.person_id
		  join hr.per_all_assignments_f paaf on papf.person_id = paaf.person_id
		  join hr.hr_locations_all_tl hlat on paaf.location_id = hlat.location_id
		  join hr.hr_all_organization_units_tl haout on paaf.organization_id = haout.organization_id
		  join hr.per_jobs pj on paaf.job_id = pj.job_id
		   and sysdate between papf.effective_start_date and papf.effective_end_date
		   and sysdate between paaf.effective_start_date and paaf.effective_end_date
		 where prha.creation_date between '01-APR-2007' and '31-OCT-2007'
	  group by haout.name
	  order by 1 desc;

-- ###################################################################
-- REQUISITION COUNT SUMMARY PER WEB REQ USER
-- ###################################################################

		select distinct papf.full_name
			 , (select count(*) 
				  from po.po_requisition_headers_all prha 
				 where prha.preparer_id = papf.person_id 
				   and prha.creation_date between '01-APR-2007' and '01-OCT-2007') req_ct
			 , (select sum(prla.unit_price * prla.quantity) as "bob"
				  from po.po_requisition_headers_all prha2 
				  join po.po_requisition_lines_all prla on prha2.requisition_header_id = prla.requisition_header_id 
				 where prha2.creation_date between '01-APR-2007' and '01-OCT-2007'
				   and prha2.preparer_id = papf.person_id) req_value
			 , papf.employee_number
			 , haout.name
			 , hlat.description
		  from hr.per_all_people_f papf
		  join hr.per_all_assignments_f paaf on papf.person_id = paaf.person_id
		  join hr.hr_locations_all_tl hlat on paaf.location_id = hlat.location_id
		  join hr.hr_all_organization_units_tl haout on paaf.organization_id = haout.organization_id
		  join applsys.fnd_user fu on fu.employee_id = papf.person_id
		  join apps.fnd_user_resp_groups_direct furg on furg.user_id = fu.user_id
		  join applsys.fnd_responsibility_tl frt on furg.responsibility_application_id = frt.application_id and furg.responsibility_id = frt.responsibility_id
		   and sysdate between papf.effective_start_date and papf.effective_end_date
		   and sysdate between paaf.effective_start_date and paaf.effective_end_date
		 where 1 = 1
		   and frt.responsibility_name like 'PO%Internet%'
		   and (select count(*)
				  from po.po_requisition_headers_all prha
				 where prha.preparer_id = papf.person_id
				   and prha.creation_date between '01-APR-2007' and '01-OCT-2007') > 0
	  order by 1;

-- ###################################################################
-- COUNT SUMMARY SHOWING NUMBER OF POS RAISED BY USER
-- ###################################################################

		select count(*) ct
			 , papf.full_name
		  from hr.per_all_people_f papf
		  join hr.per_all_assignments_f paaf on papf.person_id = paaf.person_id
		  join hr.hr_locations_all_tl hlat on paaf.location_id = hlat.location_id
		  join applsys.fnd_user fu on fu.employee_id = papf.person_id
		  join po.po_agents pa on pa.agent_id = papf.person_id
		  join po.po_headers_all pha on pha.agent_id = pa.agent_id
		   and sysdate between papf.effective_start_date and papf.effective_end_date
		   and sysdate between paaf.effective_start_date and paaf.effective_end_date
		 where paaf.primary_flag = 'Y'
		   and paaf.assignment_type = 'E'
		   and pha.creation_date >= '03-JUL-2015'
	  group by papf.full_name
	  order by 1 desc;

-- ###################################################################
-- COUNT SUMMARY SHOWING NUMBER OF POS AUTOCREATED BY USER
-- ###################################################################

		select count(*) ct
			 , papf.full_name
		  from hr.per_all_people_f papf
		  join hr.per_all_assignments_f paaf on papf.person_id = paaf.person_id
		  join hr.hr_locations_all_tl hlat on paaf.location_id = hlat.location_id
		  join applsys.fnd_user fu on fu.employee_id = papf.person_id
		  join po.po_agents pa on pa.agent_id = papf.person_id
		  join po.po_headers_all pha on pha.agent_id = pa.agent_id
		   and sysdate between papf.effective_start_date and papf.effective_end_date
		   and sysdate between paaf.effective_start_date and paaf.effective_end_date
		 where paaf.primary_flag = 'Y'
		   and paaf.assignment_type = 'E'
		   and pha.document_creation_method = 'AUTOCREATE'
		   and pha.creation_date >= '03-JUL-2015'
	  group by papf.full_name
	  order by 1 desc;

-- ###################################################################
-- SUMMARY OF PO VOLUMES
-- ###################################################################

--BY DAY

		select count(*) tally
			 , to_char(pha.creation_date, 'RRRR-MM-DD') the_date
		  from po.po_headers_all pha
		 where pha.creation_date >= sysdate - 90
	  group by to_char(pha.creation_date, 'RRRR-MM-DD')
	  order by to_char(pha.creation_date, 'RRRR-MM-DD') desc;

--BY DAY

		select count(*) tally
			 , to_char(pha.creation_date, 'RRRR-MM-DD') the_date
			 , pha.document_creation_method
		  from po.po_headers_all pha
		 where pha.authorization_status = 'APPROVED'
		   and pha.type_lookup_code = 'STANDARD'
		   and pha.creation_date > '01-FEB-2013'
	  group by to_char(pha.creation_date, 'RRRR-MM-DD')
			 , pha.document_creation_method
	  order by to_char(pha.creation_date, 'RRRR-MM-DD') desc;

--BY MONTH

		select count(*) tally
			 , to_char(pha.creation_date, 'RRRR-MM') the_date
		  from po.po_headers_all pha
	  group by to_char(pha.creation_date, 'RRRR-MM')
	  order by to_char(pha.creation_date, 'RRRR-MM') desc;

--BY MONTH ORDERED BY MONTH

		select count(*) tally
			 , to_char(pha.creation_date, 'MON-RRRR') the_date
		  from po.po_headers_all pha
	  group by to_char(pha.creation_date, 'MON-RRRR')
	  order by to_char(pha.creation_date, 'MON-RRRR') desc;

--BY MONTH ORDERED BY TALLY

		select count(*) tally
			 , to_char(pha.creation_date, 'MON-RRRR') the_date
		  from po.po_headers_all pha
	  group by to_char(pha.creation_date, 'MON-RRRR')
	  order by 1 desc;

--BY YEAR

		select count(*) tally
			 , to_char(pha.creation_date, 'RRRR') the_date
		  from po.po_headers_all pha
	  group by to_char(pha.creation_date, 'RRRR')
	  order by to_char(pha.creation_date, 'RRRR') desc;

-- PO VOLUMES BY YEAR AND MONTH

		select nvl(to_char(extract(year from pha.creation_date)),'TOTAL') creation_year,
			   sum(decode(extract (month from pha.creation_date),1,1,0)) jan,
			   sum(decode(extract (month from pha.creation_date),2,1,0)) feb,
			   sum(decode(extract (month from pha.creation_date),3,1,0)) mar,
			   sum(decode(extract (month from pha.creation_date),4,1,0)) apr,
			   sum(decode(extract (month from pha.creation_date),5,1,0)) may,
			   sum(decode(extract (month from pha.creation_date),6,1,0)) jun,
			   sum(decode(extract (month from pha.creation_date),7,1,0)) jul,
			   sum(decode(extract (month from pha.creation_date),8,1,0)) aug,
			   sum(decode(extract (month from pha.creation_date),9,1,0)) sep,
			   sum(decode(extract (month from pha.creation_date),10,1,0)) oct,
			   sum(decode(extract (month from pha.creation_date),11,1,0)) nov,
			   sum(decode(extract (month from pha.creation_date),12,1,0)) dec,
			   sum(1) total
		  from po.po_headers_all pha
		 where pha.authorization_status = 'APPROVED'
	  group by rollup(extract(year from pha.creation_date));

--ALL POS

		select count(*) tally
		  from po.po_headers_all pha;

-- ###################################################################
-- SUMMARY OF REQ VOLUMES
-- ###################################################################

--BY DAY

		select count(*) tally
			 , to_char(prha.creation_date, 'RRRR-MM-DD') the_date
		  from po.po_requisition_headers_all prha
		 where prha.creation_date >= '01-NOV-2020' 
	  group by to_char(prha.creation_date, 'RRRR-MM-DD')
	  order by to_char(prha.creation_date, 'RRRR-MM-DD') desc;

--BY MONTH

		select count(*) tally
			 , to_char(prha.creation_date, 'RRRR-MM') the_date
		  from po.po_requisition_headers_all prha
	  group by to_char(prha.creation_date, 'RRRR-MM')
	  order by to_char(prha.creation_date, 'RRRR-MM') desc;

--BY YEAR

		select count(*) tally
			 , to_char(prha.creation_date, 'RRRR') the_date
		  from po.po_requisition_headers_all prha
	  group by to_char(prha.creation_date, 'RRRR')
	  order by to_char(prha.creation_date, 'RRRR') desc;

--ALL REQS

		select count(*) tally
		  from po.po_requisition_headers_all prha;

-- REQ VOLUMES BY YEAR AND MONTH

		select nvl(to_char(extract(year from prha.creation_date)),'TOTAL') creation_year,
			   sum(decode(extract (month from prha.creation_date),1,1,0)) jan,
			   sum(decode(extract (month from prha.creation_date),2,1,0)) feb,
			   sum(decode(extract (month from prha.creation_date),3,1,0)) mar,
			   sum(decode(extract (month from prha.creation_date),4,1,0)) apr,
			   sum(decode(extract (month from prha.creation_date),5,1,0)) may,
			   sum(decode(extract (month from prha.creation_date),6,1,0)) jun,
			   sum(decode(extract (month from prha.creation_date),7,1,0)) jul,
			   sum(decode(extract (month from prha.creation_date),8,1,0)) aug,
			   sum(decode(extract (month from prha.creation_date),9,1,0)) sep,
			   sum(decode(extract (month from prha.creation_date),10,1,0)) oct,
			   sum(decode(extract (month from prha.creation_date),11,1,0)) nov,
			   sum(decode(extract (month from prha.creation_date),12,1,0)) dec,
			   sum(1) total
		  from po.po_requisition_headers_all prha
		 where prha.authorization_status = 'APPROVED'
	  group by rollup(extract(year from prha.creation_date));

-- ###################################################################
-- SUMMARY OF RECEIPT VOLUMES
-- ###################################################################

--BY DAY

		select count(*) tally
			 , to_char(rsh.creation_date, 'RRRR-MM-DD') the_date
		  from po.rcv_shipment_headers rsh
		 where rsh.creation_date >= '20-OCT-2013'
	  group by to_char(rsh.creation_date, 'RRRR-MM-DD')
	  order by to_char(rsh.creation_date, 'RRRR-MM-DD') desc;

--BY MONTH

		select count(*) tally
			 , to_char(rsh.creation_date, 'RRRR-MM') the_date
		  from po.rcv_shipment_headers rsh
	  group by to_char(rsh.creation_date, 'RRRR-MM')
	  order by to_char(rsh.creation_date, 'RRRR-MM') desc;

--BY MONTH ORDERED BY MONTH

		select count(*) tally
			 , to_char(rsh.creation_date, 'MON-RRRR') the_date
		  from po.rcv_shipment_headers rsh
	  group by to_char(rsh.creation_date, 'MON-RRRR')
	  order by to_char(rsh.creation_date, 'MON-RRRR') desc;

--BY MONTH ORDERED BY TALLY

		select count(*) tally
			 , to_char(rsh.creation_date, 'MON-RRRR') the_date
		  from po.rcv_shipment_headers rsh
	  group by to_char(rsh.creation_date, 'MON-RRRR')
	  order by 1 desc;

--BY YEAR 
		select count(*) tally
			 , to_char(rsh.creation_date, 'RRRR') the_date
		  from po.rcv_shipment_headers rsh
	  group by to_char(rsh.creation_date, 'RRRR')
	  order by to_char(rsh.creation_date, 'RRRR') desc;

--ALL RECEIPTS

		select count(*) tally
		  from po.rcv_shipment_headers rsh;

-- RECEIPT VOLUMES BY YEAR AND MONTH

		select nvl(to_char(extract(year from rsh.creation_date)),'TOTAL') creation_year,
			   sum(decode(extract (month from rsh.creation_date),1,1,0)) jan,
			   sum(decode(extract (month from rsh.creation_date),2,1,0)) feb,
			   sum(decode(extract (month from rsh.creation_date),3,1,0)) mar,
			   sum(decode(extract (month from rsh.creation_date),4,1,0)) apr,
			   sum(decode(extract (month from rsh.creation_date),5,1,0)) may,
			   sum(decode(extract (month from rsh.creation_date),6,1,0)) jun,
			   sum(decode(extract (month from rsh.creation_date),7,1,0)) jul,
			   sum(decode(extract (month from rsh.creation_date),8,1,0)) aug,
			   sum(decode(extract (month from rsh.creation_date),9,1,0)) sep,
			   sum(decode(extract (month from rsh.creation_date),10,1,0)) oct,
			   sum(decode(extract (month from rsh.creation_date),11,1,0)) nov,
			   sum(decode(extract (month from rsh.creation_date),12,1,0)) dec,
			   sum(1) total
		  from po.rcv_shipment_headers rsh
	  group by rollup(extract(year from rsh.creation_date));

-- ###################################################################
-- BASIC COUNT OF POS AND REQ VOLUME WITH VALUE
-- ###################################################################

-- REQS

		select count(distinct prha.requisition_header_id) tally
			 , sum(prla.quantity * prla.unit_price) total_value
			 , to_char(prha.creation_date, 'RRRR-MM-DD') the_date
		  from po.po_requisition_headers_all prha
		  join po.po_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		 where prha.creation_date between '01-FEB-2008' and '01-MAY-2008'
	  group by to_char(prha.creation_date, 'RRRR-MM-DD')
	  order by to_char(prha.creation_date, 'RRRR-MM-DD');

-- POS
		
		select count(distinct pha.po_header_id) tally
			 , sum(pla.quantity * pla.unit_price) total_value
			 , to_char(pha.creation_date, 'RRRR-MM-DD') the_date
		  from po.po_headers_all pha
		  join po.po_lines_all pla on pha.po_header_id = pla.po_header_id
		 where pha.creation_date between '01-FEB-2007' and '01-MAY-2007'
	  group by to_char(pha.creation_date, 'RRRR-MM-DD')
	  order by to_char(pha.creation_date, 'RRRR-MM-DD');

-- ###################################################################
-- BASIC COUNT OF REQUISITIONS BY CATALOGUE VS NON CATALOGUE
-- ###################################################################

		select to_char(prha.creation_date, 'RRRR-MM') the_month
			 , count(distinct prha.requisition_header_id) req_count
			 , count(prla.requisition_line_id) line_count
			 , round(sum(prla.unit_price * prla.quantity),2) total_value
			 , case when prla.catalog_type in('CATALOG', 'EXTERNAL') then 'CATALOG'
					when prla.catalog_type = 'NONCATALOG' or prla.catalog_type is null then 'NON_CATALOG'
					else 'OTHER'
			   end line_type
		  from po.po_requisition_lines_all prla
		  join po.po_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
		 where prha.authorization_status = 'APPROVED'
		   and prha.creation_date >= '01-DEC-2014'
	  group by case
					when prla.catalog_type in('CATALOG', 'EXTERNAL') then 'CATALOG'
					when prla.catalog_type = 'NONCATALOG' or prla.catalog_type is null then 'NON_CATALOG'
					else 'OTHER'
			   end
			 , to_char(prha.creation_date, 'RRRR-MM')
	  order by 1,3,2;

-- ###################################################################
-- BASIC COUNT OF REQUISITION HEADERS, LINES AND VALUES
-- ###################################################################

		select count(distinct prha.requisition_header_id) req_count
			 , count(prla.requisition_line_id) line_count
			 , round(sum(prla.unit_price * prla.quantity),2) total_value
		  from po.po_requisition_lines_all prla
		  join po.po_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
		 where prha.authorization_status = 'APPROVED'
		   and prha.creation_date >= '01-DEC-2014';

-- ###################################################################
-- COMPARING AUTOCREATE VOLUMES VS OTHER IN LAST 30 DAYS
-- ###################################################################

		select sum(autocreate_ct) count_autocreate
			 , sum(contract_ct) count_contract
		  from (select (select count(distinct pha.po_header_id)
						  from po.po_lines_all pla
						 where pha.po_header_id = pla.po_header_id
						   and pha.document_creation_method = 'AUTOCREATE') autocreate_ct
					 , (select count(distinct pla.po_header_id)
						  from po.po_lines_all pla
						 where pha.po_header_id = pla.po_header_id
						   and pla.contract_id is not null
						   and (pha.document_creation_method <> 'AUTOCREATE')) contract_ct
		  from po.po_headers_all pha
		 where pha.creation_date >= trunc(sysdate) - 30
		   and pha.type_lookup_code = 'STANDARD');
