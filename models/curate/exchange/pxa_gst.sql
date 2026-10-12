
 {{ config ( 
     materialized='scd_materialization', 
     incremental_strategy='scd2_transformation',
     primary_key=[var('primary_keys_dict')['pxa_gst']],
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
    id,
    version,
    workspace_id,
    transfer_id,
    form_type,
    gst_data,
    document_status,
    last_modified_by,
    last_modified_date,
    verification_status,
    request_time,
    response_time,
    verification_response_details,
    gst_data_ref,
    verification_response_det_ref,
    lodgement_response_time,
    lodgement_request_time,
    settlement_schedule_id,
    participant_id,
    gst_withholding_amount,
    payment_reference,
    lodgement_reference,
    gst_retry,
    modified_extraction_start_ts as extraction_start_ts,
    row_num,
    src_delete_idn,
    deleted_at,
    inserted_at
from {{ ref('stg_pxa_gst' ) }} 
where (op in ('I','U') or (op ='D' and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
