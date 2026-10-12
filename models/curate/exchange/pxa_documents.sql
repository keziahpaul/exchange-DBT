
 {{ config ( 
     materialized='scd_materialization', 
     incremental_strategy='scd2_transformation',
     primary_key=[var('primary_keys_dict')['pxa_documents']],
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
    document_id,
    status,
    version,
    lodgement_id,
    document_type_id,
    dealing_number,
    last_updated_date,
    last_updated_by,
    order_of_lodgement,
    fee,
    lodgement_verification_status,
    lodgement_verification_date,
    settlement_id,
    created_date,
    created_by,
    created_by_role_id,
    document_definition,
    document_status_advice,
    status_advice_time,
    setofoperativewords,
    subscribersetofoperativewords,
    parent_document,
    created_by_username,
    created_by_susbscriber_id,
    created_by_system_user,
    last_updated_by_username,
    last_updated_by_susbscriber_id,
    last_updated_by_system_user,
    attachment_needed,
    has_joint_with_no_survivorship,
    stamp_duty_id,
    document_summary_text,
    modified_extraction_start_ts as extraction_start_ts,
    row_num,
    src_delete_idn,
    deleted_at,
    inserted_at
from {{ ref('stg_pxa_documents' ) }} 
where (op in ('I','U') or (op ='D' and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
