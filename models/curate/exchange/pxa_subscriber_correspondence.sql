{{ config (
    materialized='scd_materialization',
    incremental_strategy='scd2_transformation',
    primary_key=[var('primary_keys_dict')['pxa_subscriber_correspondence']],
    source_delta_column = "inserted_at",
    source_scd_effective_column = "extraction_start_ts",
    scd2_ignore_columns =['row_num','src_delete_idn'],
    target_delta_column = "src_delta_extract_ts",
    handle_deletes=true, 
    src_delete_identifier ='src_delete_idn',
    deleted_at_identifier='deleted_at',
    src_timestamp_grain ='millisecond',
    target_ignore_columns=["row_num","src_delete_idn"]
)  
}}
select
    subscriber_corr_id,
    subscriber_id,
    correspondence_id,
    jurisdiction,
    correspondence_type,
    modified_extraction_start_ts as extraction_start_ts,
    row_num,
    src_delete_idn,
    deleted_at,
    inserted_at
from {{ ref('stg_pxa_subscriber_correspondence' ) }} 
where (op in ('I','U') or (op ='D' and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
