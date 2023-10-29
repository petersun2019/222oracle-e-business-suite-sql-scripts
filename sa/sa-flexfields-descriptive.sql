/*
File Name:		sa-flexfields-descriptive.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu

Queries:

-- FLEXFIELD NOTES
-- DESCRIPTIIVE FLEXFIELDS - HEADERS
-- DESCRIPTIIVE FLEXFIELDS - HEADERS AND CONTEXTS
-- DESCRIPTIIVE FLEXFIELDS - HEADERS AND SEGMENTS
-- DESCRIPTIIVE FLEXFIELDS - HEADERS AND SEGMENTS - COUNTING

*/

-- FLEXFIELD NOTES

/*
Three main types of flexfields:

--------------------------
Key
--------------------------
Segments
Values

--------------------------
Descriptive
--------------------------
Segments
Values

--------------------------
Validation
--------------------------
Sets
Values

https://docs.oracle.com/cd/e18727_01/doc.121/e12892/t354897t361274.htm
Oracle E-Business Suite Flexfields Guide
Release 12.1
Part Number E12892-04

Flexfield Concepts
--------------------------

A flexfield is a field made up of sub-fields, or segments. 
There are two types of flexfields: Key Flexfields and Descriptive Flexfields.
A Key Flexfield appears on your form as a normal text field with an appropriate prompt.
A Descriptive Flexfield appears on your form as a two-character-wide text field with square brackets [ ] as its prompt.
When opened, both types of flexfield appear as a pop-up window that contains a separate field and prompt for each segment. 
Each segment has a name and a set of valid values. 
The values may also have value descriptions.

Key Flexfields
--------------------------

Most organizations use "codes" made up of meaningful segments (intelligent keys) to identify general ledger accounts, part numbers, and other business entities.
Each segment of the code can represent a characteristic of the entity. 
For example, your organization might use the part number "PAD-NR-YEL-8 1/2x14" to represent a notepad that is narrow-ruled, yellow, and 8 1/2" by 14".
Another organization may identify the same notepad with the part number "PD-8X14-Y-NR".
Both of these part numbers are codes whose segments describe a characteristic of the part.
Although these codes represent the same part, they each have a different segment structure that is meaningful only to the organization using those codes.
The Oracle E-Business Suite stores these "codes" in key flexfields.
Key flexfields are flexible enough to let any organization use the code scheme they want, without programming.

Descriptive Flexfields
--------------------------

Descriptive Flexfields provide customizable "expansion space" on your forms.
You can use descriptive flexfields to track additional information, important and unique to your business, that would not otherwise be captured by the form.
Descriptive flexfields can be context sensitive, where the information your application stores depends on other values your users enter in other parts of the form.
A Descriptive Flexfield appears on a form as a single-character, unnamed field enclosed in brackets.
Just like in a key flexfield, a pop-up window appears when you move your cursor into a customized descriptive flexfield.
And like a key flexfield, the pop-up window has as many fields as your organization needs.
Each field or segment in a descriptive flexfield has a prompt, just like ordinary fields, and can have a set of valid values.
Your organization can define dependencies among the segments or customize a descriptive flexfield to display context-sensitive segments, so that different segments or additional pop-up windows appear depending on the values you enter in other fields or segments.
*/

-- ##################################################################
-- DESCRIPTIIVE FLEXFIELDS - HEADERS
-- ##################################################################

/*
various parts of Oracle EBS allows you to link what are called descriptive flexfields or "DFFS" to data entities such as purchase orders, requisitions, purchase orders, receipts, invoices and so on.

FLEXFIELD HEADER
FLEXFIELDS > DESCRIPTIVE > SEGMENTS
AT ITS MOST BASIC LEVEL, THIS LISTS THE APPLICATIONS AND TITLES LINKED TO A DFF
*/

		select fat.application_name
			 , fdfv.title
			 , fdfv.descriptive_flexfield_name dff_name
			 , fdfv.freeze_flex_definition_flag frozen_tick
			 , fdfv.concatenated_segment_delimiter separator
			 , fdfv.form_context_prompt prompt
			 , fdfv.default_context_field_name ref_field
			 , fdfv.context_required_flag required_tick
			 , fdfv.context_user_override_flag displayed_tick
			 , fdfv.context_synchronization_flag sync_tick
		  from apps.fnd_descriptive_flexs_vl fdfv
		  join applsys.fnd_application_tl fat on fdfv.application_id = fat.application_id and fat.language = userenv('lang')
		 where 1 = 1
		   -- and fdfv.title = 'PO Headers'
		   and fat.application_name = 'Application Object Library'
		   and fdfv.title = 'Flexfield Segment Values'
		   and 1 = 1;

-- ##################################################################
-- DESCRIPTIIVE FLEXFIELDS - HEADERS AND CONTEXTS
-- ##################################################################

/*
FLEXFIELDS > DESCRIPTIVE > SEGMENTS
SEARCH FOR RELEVANT TITLE, SECOND HALF OF THE SCREEN, UNDER "CONTEXT FIELD VALUES" LISTS THE MAIN PARTS OF THE FLEXFIELD
*/

		select fat.application_name
			 , fdfv.title
			 , fdfv.last_update_date
			 , fdfv.descriptive_flexfield_name dff_name
			 , fdfcv.descriptive_flex_context_code code
			 , fdfcv.descriptive_flex_context_name name
			 , fdfcv.description description
			 , fdfcv.enabled_flag enabled
		  from fnd_descriptive_flexs_vl fdfv
		  join fnd_application_tl fat on fdfv.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_descr_flex_contexts_vl fdfcv on fdfcv.descriptive_flexfield_name = fdfv.descriptive_flexfield_name 
		 where 1 = 1
		   -- and fdfv.title = 'PO Headers'
		   -- and fdfcv.descriptive_flex_context_code = 'XX_ACTIVITY'
		   and fat.application_name = 'Projects'
		   -- and fdfv.title = 'Flexfield Segment Values'
		   and 1 = 1;

-- ##################################################################
-- DESCRIPTIIVE FLEXFIELDS - HEADERS AND SEGMENTS
-- ##################################################################

/*
FLEXFIELDS > DESCRIPTIVE > SEGMENTS

SEARCH FOR RELEVANT TITLE, SECOND HALF OF THE SCREEN, UNDER "CONTEXT FIELD VALUES" LISTS THE MAIN PARTS OF THE FLEXFIELD
CLICK INTO A NAME ON THE "CONTEXT FIELD VALUES" SECTION IN THE LOWER PART OF THE SCREEN, AND CLICK "SEGMENTS"
THIS LISTS THE BITS USERS SEE IN CORE APPLICATIONS WHEN THEY CLICK INTO THE DFF PLUS SHOWS IF THERE IS A LOV LINKED TO THE FIELD
I FIND THIS USERFUL IF I CAN SEE E.G. A PROMPT ON A DFF AND DO NOT KNOW WHICH FIELD ON THE RELATED TABLE IT SITES ON, I CAN SEARCH FOR THE PROMPT ON THE DFF TO FIND OUT.
*/

		select fat.application_name
			 , fdfv.title
			 , fdfv.application_table_name
			 , fdfcv.descriptive_flex_context_code
			 , fdfcv.description
			 , fdfcuv.column_seq_num seq
			 , fdfcuv.end_user_column_name
			 , fdfcuv.form_left_prompt
			 , fdfcuv.application_column_name
			 , ffvs.flex_value_set_name
			 , ffvs.description value_set_description
			 , fdfcuv.required_flag required
			 , fdfcuv.display_flag display
			 , fdfcuv.enabled_flag enabled
			 , fdfcuv.security_enabled_flag
			 , fdfcuv.default_value default_val
			 , fdfcuv.created_by
			 , fu1.user_name created_by
			 , fdfcuv.last_update_date
			 , fu2.user_name updated_by
			 -- , '#########################################################'
			 -- , fdfcuv.*
		  from fnd_descriptive_flexs_vl fdfv
		  join fnd_application_tl fat on fdfv.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_descr_flex_contexts_vl fdfcv on fdfv.descriptive_flexfield_name = fdfcv.descriptive_flexfield_name
		  join fnd_descr_flex_col_usage_vl fdfcuv on fdfcv.descriptive_flexfield_name = fdfcuv.descriptive_flexfield_name and fdfcuv.descriptive_flex_context_code = fdfcv.descriptive_flex_context_code
		  join fnd_user fu1 on fu1.user_id = fdfcuv.created_by
		  join fnd_user fu2 on fu2.user_id = fdfcuv.last_updated_by
	 left join fnd_flex_value_sets ffvs on fdfcv.descriptive_flex_context_code = fdfcuv.descriptive_flex_context_code and fdfcuv.flex_value_set_id = ffvs.flex_value_set_id
		 where 1 = 1
		   -- and fat.application_name = 'Projects'
		   and fdfv.title not like '%$%' -- REMOVES SYSTEM GENERATED TITLES
		   -- and fdfcuv.application_column_name like 'REF%'
		   -- and lower(fdfv.title) like '%site%'
		   -- and fat.application_id = 275
		   -- and fdfv.title = 'Projects'
		   -- and fdfv.title = 'Flexfield Segment Values'
		   -- and fdfv.title = 'Customer Account'
		   -- and fdfv.title = 'Flexfield Segment Values'
		   -- and fdfv.title = 'Process Task Price Adjustments'
		   -- and fdfcuv.end_user_column_name = 'Natural Accouont Override'
		   -- and fdfcuv.end_user_column_name = 'Fund'
		   -- and fdfcuv.application_column_name = 'ATTRIBUTE1'
		   -- and ffvs.description like 'CHEESE%'
		   -- and fdfcuv.column_seq_num is not null
		   -- and fdfcuv.end_user_column_name in ('AR_TRANS_TYPE_CURR')
		   and 1 = 1
	  order by fdfcuv.last_update_date desc;

-- ##################################################################
-- DESCRIPTIIVE FLEXFIELDS - HEADERS AND SEGMENTS - COUNTING
-- ##################################################################

		select fat.application_name
			 , fdfv.title
			 , min(fdfcuv.last_update_date)
			 , max(fdfcuv.last_update_date)
			 , count(*)
		  from fnd_descriptive_flexs_vl fdfv
		  join fnd_application_tl fat on fdfv.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_descr_flex_contexts_vl fdfcv on fdfv.descriptive_flexfield_name = fdfcv.descriptive_flexfield_name
		  join fnd_descr_flex_col_usage_vl fdfcuv on fdfcv.descriptive_flexfield_name = fdfcuv.descriptive_flexfield_name and fdfcuv.descriptive_flex_context_code = fdfcv.descriptive_flex_context_code
	 left join fnd_flex_value_sets ffvs on fdfcv.descriptive_flex_context_code = fdfcuv.descriptive_flex_context_code and fdfcuv.flex_value_set_id = ffvs.flex_value_set_id
		 where 1 = 1
		   and fat.application_name = 'Project Foundation'
		   -- and fdfv.title = 'Project Descriptive Flexfield'
		   and 1 = 1
	  group by fat.application_name
			 , fdfv.title
	  order by fat.application_name
			 , fdfv.title;
