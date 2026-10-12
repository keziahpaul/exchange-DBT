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
    id,
	subscriber_id ,
	CONVERT_TIMEZONE('Australia/Melbourne',created_at) as created_at,
	CONVERT_TIMEZONE('Australia/Melbourne',updated_at) as updated_at_src,
	deleted,
	integrator_id,
	type,
	inserted_at  
from {{ ref('registration' ) }} 

