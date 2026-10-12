
 {{ config ( 
     materialized='scd_materialization', 
     incremental_strategy='scd2_transformation',
     primary_key=[var('primary_keys_dict')['pxa_invitations']],
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
    invitation_id,
    version,
    reference,
    notes,
    status,
    created,
    workspace_role_id,
    workspace_id,
    from_subscriber_id,
    to_subscriber_id,
    workgroup_id,
    from_user_id,
    decline_reason_type,
    decline_reason_addtl,
    forwardedto_subscriber_id,
    disposition_status,
    forwardedby_subscriber_id,
    date_accepted,
    date_declined,
    account_number,
    from_business_unit_type,
    property_address,
    party_represented,
    other_parties,
    modified_extraction_start_ts as extraction_start_ts,
    row_num,
    src_delete_idn,
    deleted_at,
    inserted_at
from {{ ref('stg_pxa_invitations' ) }} 
where (op in ('I','U') or (op ='D' and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
