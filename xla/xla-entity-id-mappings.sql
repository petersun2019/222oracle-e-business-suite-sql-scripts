/*
File Name: xla-entity-id-mappings.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
Why is the XLA_ENTITY_ID_MAPPINGS table useful?
-- ##################################################################

As described here:

http://www.oracleappstoday.com/2014/05/join-gl-tables-with-xla-subledger.html

The source_id_int_1 column of XLA.XLA_TRANSACTION_ENTITIES stores the primary_id value for the transactions.
You can join the XLA.XLA_TRANSACTION_ENTITIES table with the corresponding transactions table for obtaining additional information of the transaction.
For e.g you join the XLA.XLA_TRANSACTION_ENTITIES table with RA_CUSTOMER_TRX_ALL for obtaining receivables transactions information 
or with MTL_MATERIAL_TRANSACTIONS table for obtaining material transactions information.
The ENTITY_ID mappings can be obtained from the XLA_ENTITY_ID_MAPPINGS table

And also here:

http://interestingoracle.blogspot.com/2016/10/gl-sourceidint1-mappings.html

The SOURCE_ID_INT_1 on the XLA_TRANSACTION_ENTITIES table can be used to join from SLA to related transactions in the sub-ledgers.
There is a very useful table called XLA_ENTITY_ID_MAPPINGS which contains the mapping information.
For example, for a Revenue in Projects the query returns:

APPLICATION_ID: 275
APP: PA
APPLICATION_NAME: Projects
STATUS: Licensed
PRODUCT_VERSION: 12.0.0
PATCH_LEVEL: R12.PA.B.3
ENTITY_CODE: REVENUE
SOURCE_ID_COL_NAME_1: SOURCE_ID_INT_1
TRANSACTION_ID_COL_NAME_1: PROJECT_ID
SOURCE_ID_COL_NAME_2: SOURCE_ID_INT_2
TRANSACTION_ID_COL_NAME_2	DRAFT_REVENUE_NUM

Therefore, for accounting info that flows from Projects through to GL: SOURCE_ID_INT_1 value relates to the PROJECT_ID and a SOURCE_ID_INT_2 value related to the DRAFT_REVENUE_NUM.
Having access to the XLA_ENTITY_ID_MAPPINGS helps take the guess work out of linking source transactions to the sub ledger tables.

Related Queries:

xla/06-xla-all-joined.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- SOURCE_ID_INT_1 MAPPINGS
-- ##################################################################

		select fa.application_id
			 , fa.application_short_name app
			 , fat.application_name
			 , decode(fpi.status,'I','Licensed','S','Shared','N','Not Licensed') status
			 , fpi.product_version
			 , fpi.patch_level
			 , xeim.entity_code
			 , xeim.source_id_col_name_1
			 , xeim.transaction_id_col_name_1
			 , xeim.source_id_col_name_2
			 , xeim.transaction_id_col_name_2
			 , xeim.source_id_col_name_3
			 , xeim.transaction_id_col_name_3
			 , xeim.source_id_col_name_4
			 , xeim.transaction_id_col_name_4
		  from xla_entity_id_mappings xeim
		  join fnd_application fa on xeim.application_id = fa.application_id
		  join fnd_application_tl fat on fa.application_id = fat.application_id and fat.language = userenv('lang')
	 left join fnd_product_installations fpi on fpi.application_id = fa.application_id
		 where 1 = 1
		   and xeim.source_id_col_name_1 is not null
		   -- and fat.application_name like 'Proj%'
		   -- and fpi.status <> 'N'
	  order by fat.application_name
			 , xeim.entity_code;
