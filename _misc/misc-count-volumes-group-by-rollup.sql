/*
File Name: misc-count-volumes-group-by-rollup.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- USERS COUNT SETUP
-- PROJECTS COUNT SETUP
-- ISUPPLIER COUNT SETUP
-- STAFF COUNT SETUP
-- PO COUNT
-- REQUISITION COUNT
-- AP INVOICE COUNT
-- SUPPLIER HEADER COUNT
-- SUPPLIER SITE COUNT

*/

-- ##################################################################
-- USERS COUNT SETUP
-- ##################################################################

		select
			nvl(to_char(extract(year from creation_date)),'TOTAL') creation_year,
			sum(decode(extract (month from creation_date),1,1,0)) jan,
			sum(decode(extract (month from creation_date),2,1,0)) feb,
			sum(decode(extract (month from creation_date),3,1,0)) mar,
			sum(decode(extract (month from creation_date),4,1,0)) apr,
			sum(decode(extract (month from creation_date),5,1,0)) may,
			sum(decode(extract (month from creation_date),6,1,0)) jun,
			sum(decode(extract (month from creation_date),7,1,0)) jul,
			sum(decode(extract (month from creation_date),8,1,0)) aug,
			sum(decode(extract (month from creation_date),9,1,0)) sep,
			sum(decode(extract (month from creation_date),10,1,0)) oct,
			sum(decode(extract (month from creation_date),11,1,0)) nov,
			sum(decode(extract (month from creation_date),12,1,0)) dec,
			sum(1) total
		  from fnd_user
	  group by rollup(extract(year from creation_date));

-- ##################################################################
-- PROJECTS COUNT SETUP
-- ##################################################################

		select
			nvl(to_char(extract(year from creation_date)),'TOTAL') creation_year,
			sum(decode(extract (month from creation_date),1,1,0)) jan,
			sum(decode(extract (month from creation_date),2,1,0)) feb,
			sum(decode(extract (month from creation_date),3,1,0)) mar,
			sum(decode(extract (month from creation_date),4,1,0)) apr,
			sum(decode(extract (month from creation_date),5,1,0)) may,
			sum(decode(extract (month from creation_date),6,1,0)) jun,
			sum(decode(extract (month from creation_date),7,1,0)) jul,
			sum(decode(extract (month from creation_date),8,1,0)) aug,
			sum(decode(extract (month from creation_date),9,1,0)) sep,
			sum(decode(extract (month from creation_date),10,1,0)) oct,
			sum(decode(extract (month from creation_date),11,1,0)) nov,
			sum(decode(extract (month from creation_date),12,1,0)) dec,
			sum(1) total
		  from pa.pa_projects_all
	  group by rollup(extract(year from creation_date));

-- ##################################################################
-- ISUPPLIER COUNT SETUP
-- ##################################################################

		select
			nvl(to_char(extract(year from creation_date)),'TOTAL') creation_year,
			sum(decode(extract (month from creation_date),1,1,0)) jan,
			sum(decode(extract (month from creation_date),2,1,0)) feb,
			sum(decode(extract (month from creation_date),3,1,0)) mar,
			sum(decode(extract (month from creation_date),4,1,0)) apr,
			sum(decode(extract (month from creation_date),5,1,0)) may,
			sum(decode(extract (month from creation_date),6,1,0)) jun,
			sum(decode(extract (month from creation_date),7,1,0)) jul,
			sum(decode(extract (month from creation_date),8,1,0)) aug,
			sum(decode(extract (month from creation_date),9,1,0)) sep,
			sum(decode(extract (month from creation_date),10,1,0)) oct,
			sum(decode(extract (month from creation_date),11,1,0)) nov,
			sum(decode(extract (month from creation_date),12,1,0)) dec,
			sum(1) total
		  from applsys.fnd_registrations
	  group by rollup(extract(year from creation_date));

-- ##################################################################
-- STAFF COUNT SETUP
-- ##################################################################

		select
			nvl(to_char(extract(year from creation_date)),'TOTAL') creation_year,
			sum(decode(extract (month from creation_date),1,1,0)) jan,
			sum(decode(extract (month from creation_date),2,1,0)) feb,
			sum(decode(extract (month from creation_date),3,1,0)) mar,
			sum(decode(extract (month from creation_date),4,1,0)) apr,
			sum(decode(extract (month from creation_date),5,1,0)) may,
			sum(decode(extract (month from creation_date),6,1,0)) jun,
			sum(decode(extract (month from creation_date),7,1,0)) jul,
			sum(decode(extract (month from creation_date),8,1,0)) aug,
			sum(decode(extract (month from creation_date),9,1,0)) sep,
			sum(decode(extract (month from creation_date),10,1,0)) oct,
			sum(decode(extract (month from creation_date),11,1,0)) nov,
			sum(decode(extract (month from creation_date),12,1,0)) dec,
			sum(1) total
		  from applsys.fnd_user
	  group by rollup(extract(year from creation_date));

-- ##################################################################
-- PO COUNT
-- ##################################################################

		select
			nvl(to_char(extract(year from creation_date)),'TOTAL') creation_year,
			sum(decode(extract (month from creation_date),1,1,0)) jan,
			sum(decode(extract (month from creation_date),2,1,0)) feb,
			sum(decode(extract (month from creation_date),3,1,0)) mar,
			sum(decode(extract (month from creation_date),4,1,0)) apr,
			sum(decode(extract (month from creation_date),5,1,0)) may,
			sum(decode(extract (month from creation_date),6,1,0)) jun,
			sum(decode(extract (month from creation_date),7,1,0)) jul,
			sum(decode(extract (month from creation_date),8,1,0)) aug,
			sum(decode(extract (month from creation_date),9,1,0)) sep,
			sum(decode(extract (month from creation_date),10,1,0)) oct,
			sum(decode(extract (month from creation_date),11,1,0)) nov,
			sum(decode(extract (month from creation_date),12,1,0)) dec,
			sum(1) total
		  from po.po_headers_all pha
		 where pha.type_lookup_code = 'STANDARD'
	  group by rollup(extract(year from creation_date));

-- ##################################################################
-- REQUISITION COUNT
-- ##################################################################

		select
			nvl(to_char(extract(year from creation_date)),'TOTAL') creation_year,
			sum(decode(extract (month from creation_date),1,1,0)) jan,
			sum(decode(extract (month from creation_date),2,1,0)) feb,
			sum(decode(extract (month from creation_date),3,1,0)) mar,
			sum(decode(extract (month from creation_date),4,1,0)) apr,
			sum(decode(extract (month from creation_date),5,1,0)) may,
			sum(decode(extract (month from creation_date),6,1,0)) jun,
			sum(decode(extract (month from creation_date),7,1,0)) jul,
			sum(decode(extract (month from creation_date),8,1,0)) aug,
			sum(decode(extract (month from creation_date),9,1,0)) sep,
			sum(decode(extract (month from creation_date),10,1,0)) oct,
			sum(decode(extract (month from creation_date),11,1,0)) nov,
			sum(decode(extract (month from creation_date),12,1,0)) dec,
			sum(1) total
		  from po.po_requisition_headers_all
	  group by rollup(extract(year from creation_date));

-- ##################################################################
-- AP INVOICE COUNT
-- ##################################################################

		select
			nvl(to_char(extract(year from creation_date)),'TOTAL') creation_year,
			sum(decode(extract (month from creation_date),1,1,0)) jan,
			sum(decode(extract (month from creation_date),2,1,0)) feb,
			sum(decode(extract (month from creation_date),3,1,0)) mar,
			sum(decode(extract (month from creation_date),4,1,0)) apr,
			sum(decode(extract (month from creation_date),5,1,0)) may,
			sum(decode(extract (month from creation_date),6,1,0)) jun,
			sum(decode(extract (month from creation_date),7,1,0)) jul,
			sum(decode(extract (month from creation_date),8,1,0)) aug,
			sum(decode(extract (month from creation_date),9,1,0)) sep,
			sum(decode(extract (month from creation_date),10,1,0)) oct,
			sum(decode(extract (month from creation_date),11,1,0)) nov,
			sum(decode(extract (month from creation_date),12,1,0)) dec,
			sum(1) total
		  from ap.ap_invoices_all
	  group by rollup(extract(year from creation_date));

-- ##################################################################
-- SUPPLIER HEADER COUNT
-- ##################################################################

		select
			nvl(to_char(extract(year from creation_date)),'TOTAL') creation_year,
			sum(decode(extract (month from creation_date),1,1,0)) jan,
			sum(decode(extract (month from creation_date),2,1,0)) feb,
			sum(decode(extract (month from creation_date),3,1,0)) mar,
			sum(decode(extract (month from creation_date),4,1,0)) apr,
			sum(decode(extract (month from creation_date),5,1,0)) may,
			sum(decode(extract (month from creation_date),6,1,0)) jun,
			sum(decode(extract (month from creation_date),7,1,0)) jul,
			sum(decode(extract (month from creation_date),8,1,0)) aug,
			sum(decode(extract (month from creation_date),9,1,0)) sep,
			sum(decode(extract (month from creation_date),10,1,0)) oct,
			sum(decode(extract (month from creation_date),11,1,0)) nov,
			sum(decode(extract (month from creation_date),12,1,0)) dec,
			sum(1) total
		  from apps.po_vendors
	  group by rollup(extract(year from creation_date));

-- ##################################################################
-- SUPPLIER SITE COUNT
-- ##################################################################

		select
			nvl(to_char(extract(year from creation_date)),'TOTAL') creation_year,
			sum(decode(extract (month from creation_date),1,1,0)) jan,
			sum(decode(extract (month from creation_date),2,1,0)) feb,
			sum(decode(extract (month from creation_date),3,1,0)) mar,
			sum(decode(extract (month from creation_date),4,1,0)) apr,
			sum(decode(extract (month from creation_date),5,1,0)) may,
			sum(decode(extract (month from creation_date),6,1,0)) jun,
			sum(decode(extract (month from creation_date),7,1,0)) jul,
			sum(decode(extract (month from creation_date),8,1,0)) aug,
			sum(decode(extract (month from creation_date),9,1,0)) sep,
			sum(decode(extract (month from creation_date),10,1,0)) oct,
			sum(decode(extract (month from creation_date),11,1,0)) nov,
			sum(decode(extract (month from creation_date),12,1,0)) dec,
			sum(1) total
		  from apps.po_vendor_sites_all
	  group by rollup(extract(year from creation_date));
