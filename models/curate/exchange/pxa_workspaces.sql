
 {{ config ( 
     materialized='scd_materialization', 
     incremental_strategy='scd2_transformation',
     primary_key=[var('primary_keys_dict')['pxa_workspaces']],
     source_delta_column = 'inserted_at',
     source_scd_effective_column = 'extraction_start_ts',
     scd2_ignore_columns =['row_num','src_delete_idn'],
     target_delta_column = 'src_delta_extract_ts',
     handle_deletes=true, 
     src_delete_identifier ='src_delete_idn',
     deleted_at_identifier='deleted_at',
     src_timestamp_grain ='millisecond',
     target_ignore_columns=['row_num','src_delete_idn']
 )  
 }} 

select 
    workspace_id,
    version,
    number1,
    jurisdiction,
    status,
    privacy,
    archive_warning,
    archived,
    abandoned,
    bundle_type,
    last_accessed,
    transaction_type,
    date_linked,
    transaction_scope,
    panel_master_selected,
    is_ready_to_book,
    is_interop,
    is_interop_ready,
    interop_lock_status,
    is_interop_archived,
    is_pelno,
    interop_lock_id,
    created_date,
    necds_version,
    manual_settlement_category,
    manual_settlement_reason,
    modified_extraction_start_ts as extraction_start_ts,
    row_num,
    src_delete_idn,
    deleted_at,
    inserted_at
from {{ ref('stg_pxa_workspaces' ) }} 
where (op in ('I','U') or (op ='D' and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
