
 {{ config ( 
     materialized='scd_materialization', 
     incremental_strategy='scd2_transformation',
     primary_key=[var('primary_keys_dict')['pxa_lodgements']],
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
    lodgement_id,
    version,
    date1,
    status,
    workspace_id,
    verification_request_time,
    verification_response_time,
    transaction_type,
    verification_request_xml,
    settlement_id,
    workspace_lock_date,
    lodgement_request_time,
    lodgement_response_time,
    status_advice_time,
    notification_ack_time,
    notification_status_time,
    billing_event_flag,
    tac_flag,
    express_refi_flag,
    express_refi_subscriber,
    retry_flag,
    day_prior_lv_timestamp,
    verification_ack_response,
    verification_request_xml_ref,
    lodgement_id_external,
    modified_extraction_start_ts as extraction_start_ts,
    row_num,
    src_delete_idn,
    deleted_at,
    inserted_at
from {{ ref('stg_pxa_lodgements' ) }} 
where (op in ('I','U') or (op ='D' and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
