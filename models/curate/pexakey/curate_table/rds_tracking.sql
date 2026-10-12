{{ config ( 
     materialized='scd_materialization', 
     incremental_strategy='scd2_transformation',
     primary_key=['id'],
     source_delta_column = 'inserted_at',
     source_scd_effective_column = 'record_updated_aest',
     target_delta_column = 'src_delta_extract_ts',
     handle_deletes=false, 
     src_timestamp_grain ='millisecond',
 )  
 }} 
  
select 
    id
    ,version
    ,record_created
    ,record_updated
    ,CONVERT_TIMEZONE('Australia/Melbourne',record_updated) as record_updated_aest
    ,tracking_id
    ,tracking_status
    ,invitation_date
    ,workspace_internal_id
    ,settlement_date
    ,workspace_status
    ,party_id
    ,role
    ,correlation_token
    ,subscriber_reference
    ,tracking_user_reference
    ,address_reference
    ,display_name
    ,party_type
    ,tracking_expired
    ,is_hidden
    ,subscriber_mobile
    ,settlement_status
    ,is_settlement_ready
    ,inserted_at
    ,load_type
from {{ ref('tracking' ) }} 