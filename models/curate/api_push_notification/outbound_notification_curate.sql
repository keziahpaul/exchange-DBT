{{ config ( 
     materialized='scd_materialization', 
     incremental_strategy='scd2_transformation',
     primary_key=['id'],
     source_delta_column = 'inserted_at',
     source_scd_effective_column = 'updated_at_src',
     target_delta_column = 'src_delta_extract_ts',
     handle_deletes=false, 
     src_timestamp_grain ='millisecond',
 )  
 }} 
  
select 
    id ,
	registration_id ,
	status ,
	CONVERT_TIMEZONE('Australia/Melbourne',created_at) as created_at ,
	CONVERT_TIMEZONE('Australia/Melbourne',updated_at) as updated_at_src ,
	data  ,
	retry_count ,
	CONVERT_TIMEZONE('Australia/Melbourne',last_sent_at) as last_sent_at ,
	CONVERT_TIMEZONE('Australia/Melbourne',next_retry_at) as next_retry_at ,
	trace_id ,
	event_type ,
	workspace_id ,
	inserted_at  
from {{ ref('outbound_notification' ) }} 