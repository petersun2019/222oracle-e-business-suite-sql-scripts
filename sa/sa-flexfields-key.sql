/*
File Name: sa-flexfields-key.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- FLEXFIELD NOTES
-- KEY FLEXFIELD BASIC INFO
-- KEY FLEXFIELD SEGMENTS
-- KEY FLEXFIELD SEGMENT DETAILS
-- KEY FLEXFIELD SEGMENT VALUES
-- KEY FLEXFIELDS - FIND NATURAL AND BALANCING SEGMENTS

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
-- KEY FLEXFIELD BASIC INFO
-- ##################################################################

/*
AT ITS MOST BASIC, A LIST OF KEY FLEXFIELDS, WITHOUT THE LIST OF SEGMENTS
FLEXFIELDS > KEY > SEGMENTS

THIS SQL IS USEFUL AS IT SHOWS YOU THE UNDERLYING APPLICATION TABLE NAME ASSOCIATED WITH THE KEY FLEXFIELD.
*/

		select fat.application_name
			 , fif.*
		  from fnd_id_flexs fif 
		  join fnd_application_tl fat on fif.application_id = fat.application_id
		 where 1 = 1
		   and fif.id_flex_code = 'GL#'
		   -- and fif.id_flex_code = 'MSTK'
		   -- and fif.id_flex_name like 'Accounting%'
		   and 1 = 1;

/*
THE ABOVE HAS A "DYNAMIC_INSERTS_FEASIBLE_FLAG" COLUMN.
IF Y, THEN "DYNAMIC COMBINATION CREATION ALLOWED" IS TICKED VIA "EDIT KEY FLEXFIELD STRUCTURE INSTANCE" SCREEN
*/

-- ##################################################################
-- KEY FLEXFIELD SEGMENTS
-- ##################################################################

/*
THIS LISTS THE STRUCTURES ASSOCIATED WITH A KEY FLEXFIELD
EACH STRUCTURE CAN HAVE DIFFERENT OPTIONS - E.G. ENABLED, SEPARATOR ETC
*/

		select '------> KEY FLEXFIELD'
			 , fat.application_name
			 , fif.id_flex_name flexfield_title
			 , fif.id_flex_code
			 , fif.dynamic_inserts_feasible_flag flex_dynamic_insert_allowed
			 , '------> STRUCTURE'
			 , fifsv.id_flex_num
			 , fifsv.id_flex_structure_code code
			 , fifsv.id_flex_structure_name title
			 , fifsv.description
			 , fifsv.structure_view_name view_name
			 , fifsv.concatenated_segment_delimiter segment_separator
			 , fifsv.freeze_flex_definition_flag freeze_flexfield_definition
			 , fifsv.cross_segment_validation_flag cross_validate_segments
			 , fifsv.enabled_flag enabled
			 , fifsv.freeze_structured_hier_flag freeze_rollup_groups
			 , fifsv.last_update_date
			 , fifsv.dynamic_inserts_allowed_flag dynamic_insert_allowed
		  from fnd_id_flexs fif
		  join fnd_application_tl fat on fif.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_id_flex_structures_vl fifsv on fif.id_flex_code = fifsv.id_flex_code
		 where 1 = 1
		   and fif.id_flex_code = 'GL#'
		   -- and fif.id_flex_code = 'MSTK'
		   and 1 = 1;

-- ##################################################################
-- KEY FLEXFIELD SEGMENT DETAILS
-- ##################################################################

/*
FROM THE ABOVE VIEW "KEY FLEXFIELD SEGMENTS", IF YOU CLICK INTO A STRUCTURE NAME, AND THEN CLICK ON "SEGMENTS"
YOU CAN SEE THE RELATED SEGMENTS
IF I START TO SUPPORT A NEW CUSTOMER I FIND THIS QUERY USEFUL AS YOU CAN QUICKLY SEE THE SETUP FOR THEIR CHART OF ACCOUNTS
FOR EXAMPLE, YOU CAN SEE HOW MANY SEGMENTS THEY HAVE, THE NAME OF THE SEGMENTS (E.G. ACCOUNT, COST CENTRE ETC)
*/

		select '------> KEY FLEXFIELD'
			 , fat.application_name
			 , fif.id_flex_name flexfield_title
			 , fif.id_flex_code
			 , '------> STRUCTURE'
			 , fifsv.id_flex_structure_code segment_code
			 , fifsv.id_flex_structure_name segment_title
			 , '------> SEGMENTS'
			 , fnd_set.flex_value_set_id
			 , fifsvl.id_flex_num
			 , fifsvl.segment_num "number"
			 , fifsvl.segment_name name
			 , fifsvl.form_left_prompt prompt
			 , fifsvl.description
			 , fifsvl.application_column_name 
			 , fnd_set.flex_value_set_name
			 , fifsvl.display_flag displayed
			 , fifsvl.enabled_flag enabled
			 , fifsvl.display_size
			 , '#' || fifsvl.default_value default_value
		  from fnd_id_flexs fif
		  join fnd_application_tl fat on fif.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_id_flex_structures_vl fifsv on fif.id_flex_code = fifsv.id_flex_code
		  join fnd_id_flex_segments_vl fifsvl on fifsvl.id_flex_code = fifsv.id_flex_code and fifsvl.id_flex_num = fifsv.id_flex_num
	 left join fnd_flex_value_sets fnd_set on fifsvl.flex_value_set_id = fnd_set.flex_value_set_id
		 where 1 = 1
		   and fif.id_flex_code = 'GL#'
		   -- and fnd_set.flex_value_set_id = 123456
		   -- and fifsv.id_flex_structure_code like 'XX_CUST%'
		   -- and fif.id_flex_code = 'MSTK'
		   and 1 = 1;

-- ##################################################################
-- KEY FLEXFIELD SEGMENT VALUES
-- ##################################################################

/*
FROM THE ABOVE, YOU CAN SEE THAT A SEGMENT CAN HAVE A LIST OF VALUES ASSOCIATED WITH IT
WHEN THAT HAPPENS, YOU CAN DRILL DOWN TO SEE THE RECORDS IN THAT LIST OF VALUES
FLEXFIELDS > KEY > VALUES
*/

		select '------> KEY FLEXFIELD'
			 , fat.application_name
			 , fif.id_flex_name flexfield_title
			 , fif.id_flex_code
			 , fifsv.id_flex_num
			 , '------> STRUCTURE'
			 , fifsv.id_flex_structure_code
			 , fifsv.id_flex_structure_name
			 , '------> SEGMENTS'
			 , fifsvl.segment_name name
			 , fifsvl.form_left_prompt prompt
			 , fifsvl.application_column_name 
			 , fnd_set.flex_value_set_name
			 , fifsvl.display_flag displayed
			 , fifsvl.enabled_flag enabled
			 , '------> VALUES'
			 , fnd_value.flex_value
			 , fnd_value_tl.description
			 , fnd_value.end_date_active
			 , fnd_value.enabled_flag
			 , fnd_value.summary_flag parent
			 , substr(replace(replace(fnd_value.compiled_value_attributes,chr(10),''),chr(13),' '),1,1) budg_flag
			 , substr(replace(replace(fnd_value.compiled_value_attributes,chr(10),''),chr(13),' '),2,1) post_flag
		  from fnd_id_flexs fif
		  join fnd_application_tl fat on fif.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_id_flex_structures_vl fifsv on fif.id_flex_code = fifsv.id_flex_code
		  join fnd_id_flex_segments_vl fifsvl on fifsvl.id_flex_code = fifsv.id_flex_code and fifsvl.id_flex_num = fifsv.id_flex_num
	 left join fnd_flex_value_sets fnd_set on fifsvl.flex_value_set_id = fnd_set.flex_value_set_id
		  join fnd_flex_values fnd_value on fnd_value.flex_value_set_id = fnd_set.flex_value_set_id
		  join fnd_flex_values_tl fnd_value_tl on fnd_value.flex_value_id = fnd_value_tl.flex_value_id and fnd_value_tl.language = userenv('lang')
		 where fif.id_flex_code = 'GL#'
		   and fnd_value.flex_value = 'CHEESE'
		   and 1 = 1;

-- ##################################################################
-- KEY FLEXFIELDS - FIND NATURAL AND BALANCING SEGMENTS
-- ##################################################################

		select distinct fifs.id_flex_structure_code
			 , fsav.application_column_name
			 , ffsg.segment_name
			 , decode (fsav.segment_attribute_type,
				'FA_COST_CTR', 'Cost Center Segment',
				'GL_ACCOUNT', 'Natural Account Segment',
				'GL_BALANCING', 'Balancing Segment',
				'GL_INTERCOMPANY', 'Intercompany Segment',
				'GL_SECONDARY_TRACKING','Secondary Tracking Segment',
				'GL_MANAGEMENT', 'Management Segment') details
		  from fnd_segment_attribute_values fsav
			 , fnd_id_flex_structures fifs
			 , fnd_id_flex_segments ffsg
		 where 1 = 1
		   and upper(fifs.id_flex_structure_code) = 'XXCHEESE_LEDGER'
		   and fsav.attribute_value = 'Y'
		   and segment_attribute_type not in ('GL_GLOBAL', 'GL_LEDGER')
		   and fsav.id_flex_num = fifs.id_flex_num
		   and ffsg.id_flex_num = fifs.id_flex_num
		   and ffsg.application_column_name = fsav.application_column_name
		   and decode (fsav.segment_attribute_type,
				'FA_COST_CTR', 'Cost Center Segment',
				'GL_ACCOUNT', 'Natural Account Segment',
				'GL_BALANCING', 'Balancing Segment',
				'GL_INTERCOMPANY', 'Intercompany Segment',
				'GL_SECONDARY_TRACKING','Secondary Tracking Segment',
				'GL_MANAGEMENT', 'Management Segment') is not null
	  order by application_column_name;
