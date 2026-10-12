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
    ,user_email
    ,user_mobile
    ,user_family_name
    ,user_given_name
    ,user_org_name
    ,user_org_contact_given_name
    ,user_org_contact_family_name
    ,inserted_at
    ,load_type
from {{ ref('tracking_user' ) }} 