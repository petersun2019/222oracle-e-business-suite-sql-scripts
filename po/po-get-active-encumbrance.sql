/*
File Name:		po-get-active-encumbrance.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

11I/12: INCORRECT ENCUMBERED AMOUNT / ACTIVE ENCUMBRANCE /ENCUMBRANCE DETAIL REPORT FOR PURCHASE ORDER - TROUBLESHOOTING (DOC ID 742621.1)
HTTPS://SUPPORT.ORACLE.COM/RS?TYPE=DOC&ID=742621.1
SQL-8 COMPARE EXPECTED ENCUMBRANCE REVERSAL AT PAYABLES AND PAYABLES API VALUE PER PO DISTRIBUTION
NOTE: SET THE ORG CONTEXT BEFORE EXECUTING THIS SCRIPT

SETTING THE ORG_CONTEXT:

BEGIN
DBMS_APPLICATION_INFO.SET_CLIENT_INFO('123');
END;
*/

-- ###################################################################
-- GET ACTIVE ENCUMBRANCE ATTEMPT
-- ###################################################################

		select d.po_distribution_id
			 , h.segment1
			 , l.shipment_type
			 , l.closed_code
			 , l.cancel_flag
			 , l.accrue_on_receipt_flag
			 , d.destination_type_code
			 , d.quantity_ordered
			 , d.quantity_billed
			 , d.quantity_cancelled
			 , l.price_override
			 , d.rate#
			 , d.nonrecoverable_tax
			 , po_inq_sv.get_active_enc_amount(nvl(d.rate,1)
			 , nvl(d.encumbered_amount,0)
			 , l.shipment_type,d.po_distribution_id) as active_encumbrance
			 , ap_accounting_utilities_pkg.get_po_reversed_encumb_amount(d.po_distribution_id, null, null ) as ap_encum_reversal_val
			 , (case l.accrue_on_receipt_flag
					when 'Y' then 0
					when 'N' then nvl(d.rate,1)*least(d.quantity_ordered,nvl(d.quantity_billed,0)) * (l.price_override+ (nvl(d.nonrecoverable_tax,0)/ d.quantity_ordered) )
			     end) expected_ap_encum_value
		  from po_headers_all h
		  join po_line_locations_all l on l.line_location_id = d.line_location_id
		  join po_distributions_all d on h.po_header_id = d.po_header_id
		 where1 = 1
		   and nvl(l.approved_flag,'N') = 'Y'
		   and d.encumbered_flag = 'Y'
		   and nvl(d.prevent_encumbrance_flag,'N') = 'N'
		   and d.ussgl_transaction_code is null
		   and d.budget_account_id is not null
		   and l.shipment_type in ('SCHEDULED', 'STANDARD', 'BLANKET')
		   and h.segment1 = '123456' -- po number
		   and d.org_id = 123
		   and 1 = 1;
