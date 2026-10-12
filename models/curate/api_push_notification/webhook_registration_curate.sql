{{ config ( 
     materialized='scd_materialization', 
     incremental_strategy='scd2_transformation',
     primary_key=['registration_id'],
     source_delta_column = 'inserted_at_raw',
     source_scd_effective_column = 'inserted_at_raw',
     target_delta_column = 'src_delta_extract_ts',
     handle_deletes=false, 
     src_timestamp_grain ='millisecond',
 )  
 }} 
  
select 
    registration_id ,
	webhook_uri ,
	current_shared_secret ,
	current_shared_secret_expiry ,
	previous_shared_secret ,
	previous_shared_secret_expiry ,
	inserted_at as inserted_at_raw
from {{ ref('webhook_registration' ) }} 

