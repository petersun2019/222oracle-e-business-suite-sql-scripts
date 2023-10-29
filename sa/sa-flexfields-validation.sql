/*
File Name: sa-flexfields-validation.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts

Queries:

-- FLEXFIELD NOTES
-- VALUE SETS - SIMPLE LIST OF VALUE SETS
-- VALUE SETS - DEFINITION
-- VALUE SETS - BASIC LIST OF VALUES
-- VALUE SETS - COUNT PER VALUE SET
-- VALUE SETS - TABLE VALIDATION DETAILS

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
-- VALUE SETS - SIMPLE LIST OF VALUE SETS
-- ##################################################################

/*
FLEXFIELDS > VALIDATION > SETS
*/

		select *
		  from applsys.fnd_flex_value_sets ffvs
		 where 1 = 1 -- ffvs.flex_value_set_name = 'CE_BANK_BRANCHES'
	  order by flex_value_set_name;

-- ##################################################################
-- VALUE SETS - DEFINITION
-- ##################################################################

/*
SETUP > FINANCIALS > FLEXFIELDS > VALIDATION > SETS
*/

		select ffvs.flex_value_set_name name
			 , ffvs.description
			 , decode (ffvs.longlist_flag
			 , 'N', 'List of Values'
			 , 'X', 'Poplist'
			 , 'Y', 'Long List of Values'
			 , 'Other') list_type
			 , decode (ffvs.security_enabled_flag
			 , 'N', 'No Security'
			 , 'Y', 'Non-Hierarchical Security'
			 , 'H', 'Hierarchical Security'
			 , 'Other') security_type
			 , decode (ffvs.format_type
			 , 'C', 'Char'
			 , 'D', 'Date'
			 , 'T', 'DateTime'
			 , 'N', 'Number'
			 , 'X', 'Standard Date'
			 , 'Y', 'Standard DateTime'
			 , 'I', 'Time'
			 , 'NULL') format_type
			 , decode (ffvs.validation_type
			 , 'Y', 'Translatable Dependent'
			 , 'X', 'Translatable Independent'
			 , 'F', 'Table'
			 , 'U', 'Special'
			 , 'D', 'Dependent'
			 , 'I', 'Independent'
			 , 'N', 'None'
			 , 'P', 'Pair') validation_type
			 , ffvs.maximum_size max_size
			 , ffvs.number_precision precision
			 , case when ffvs.format_type = 'N' then 'Y' else 'N' end numbers_only
			 , ffvs.numeric_mode_enabled_flag right_justify
			 , ffvs.uppercase_only_flag uppercase
			 , ffvs.protected_flag
			 , ffvs.security_enabled_flag
			 , ffvs.uppercase_only_flag
			 , ffvs.dependant_default_value
			 , ffvs.dependant_default_meaning
			 , ffvs2.flex_value_set_name independent_value_set
			 , fu.user_name created_by
		  from applsys.fnd_flex_value_sets ffvs
	 left join applsys.fnd_flex_value_sets ffvs2 on ffvs.parent_flex_value_set_id = ffvs2.flex_value_set_id 
		  join applsys.fnd_user fu on fu.user_id = ffvs.created_by
		 where 1 = 1
		   and ffvs.flex_value_set_name = 'PA_SRS_30_CHAR'
		   and ffvs.zd_edition_name = 'SET2'
		   -- and ffvs.security_enabled_flag = 'H'
		   and 1 = 1;

-- ##################################################################
-- VALUE SETS - BASIC LIST OF VALUES
-- ##################################################################

/*
FLEXFIELDS > VALIDATION > VALUES

If you look at the pick list, the list of items in the LOV is not your full list of sets of values as defined in the sql above

It only returns a list of list of values where:

- Validation type in ('Dependent', 'Independent', 'Translatable Independent, 'Translatable Dependent')
- Plus anything where the validation type = 'Table' and the summary_allowed_flag on the fnd_flex_validation_tables = 'Y'
*/

		select flex_value_set_name
			 , '#' || fnd_value.flex_value flex_value
			 , fnd_value_tl.description
			 , fnd_value.enabled_flag
			 , fnd_value.creation_date
			 , fu.user_name
			 , fu.description created_by
		  from fnd_flex_value_sets fnd_set
		  join fnd_flex_values fnd_value on fnd_set.flex_value_set_id = fnd_value.flex_value_set_id 
		  join fnd_flex_values_tl fnd_value_tl on fnd_value_tl.flex_value_id = fnd_value.flex_value_id and fnd_value_tl.language = userenv('lang')
		  join fnd_user fu on fnd_value.created_by = fu.user_id
		 where 1 = 1
		   and fnd_value.flex_value in ('07203','0000','0600','1100')
		   -- and fnd_set.flex_value_set_name = 'XX_GL_DEPARTMENT'
		   -- and fnd_value_tl.description = 'Cheese Flavours'
		   and 1 = 1;

-- ##################################################################
-- VALUE SETS - COUNT PER VALUE SET
-- ##################################################################

		select flex_value_set_name
			 , count(fnd_value.flex_value_set_id) record_count
		  from fnd_flex_value_sets fnd_set
	 left join fnd_flex_values fnd_value on fnd_set.flex_value_set_id = fnd_value.flex_value_set_id 
		 where 1 = 1
		   -- and fnd_set.flex_value_set_name in ('XX_GL_COMPANY','XX_GL_ACCOUNT','XX_GL_COST CENTER')
		   and fnd_set.flex_value_set_id in (1234,2345,3456)
		   and 1 = 1
	  group by flex_value_set_name;

-- ##################################################################
-- VALUE SETS - TABLE VALIDATION DETAILS
-- ##################################################################

		select ffvs.flex_value_set_name name
			 , nvl (fat.application_name, 'n/a') tbl_app
			 , ffvt.application_table_name tbl_name
			 , ffvt.value_column_name
			 , ffvt.meaning_column_name
			 , ffvt.id_column_name
			 , ffvt.additional_where_clause where_
			 , ffvt.summary_allowed_flag
		  from applsys.fnd_flex_value_sets ffvs
		  join applsys.fnd_flex_validation_tables ffvt on ffvs.flex_value_set_id = ffvt.flex_value_set_id 
	 left join applsys.fnd_application_tl fat on ffvt.table_application_id = fat.application_id and fat.language = userenv('lang')
		 where 1 = 1
		   and ffvs.flex_value_set_name = 'PA_SRS_STREAMLINE_INTERFACE'
		   and 1 = 1;
