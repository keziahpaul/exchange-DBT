
 {{ config ( 
     materialized='scd_materialization', 
     incremental_strategy='scd2_transformation',
     primary_key=[var('primary_keys_dict')['pxa_operating_jurisdiction']],
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
    opera_jurisdiction_id,
    jurisdiction_status,
    customer_code,
    jurisdiction,
    customeraccountupdatexml,
    date_status_lrupdate,
    status_reason_change,
    status_change_date,
    status_change_user,
    customer_update_status,
    osr_client_id,
    customeraccountupdatexml_ref,
    modified_extraction_start_ts as extraction_start_ts,
    row_num,
    src_delete_idn,
    deleted_at,
    inserted_at
from {{ ref('stg_pxa_operating_jurisdiction' ) }} 
where (op in ('I','U') or (op ='D' and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
