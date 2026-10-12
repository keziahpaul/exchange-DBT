
 {{ config ( 
     materialized='scd_materialization', 
     incremental_strategy='scd2_transformation',
     primary_key=[var('primary_keys_dict')['pxa_partys']],
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
    party_id,
    version,
    workspace_id,
    address,
    updated_name,
    phone_number,
    title_party_full_name,
    source,
    notice_address,
    delivery_address,
    name_on_title,
    previous_name,
    del_address_diff,
    address_justification,
    fax_number,
    is_foreign_transferee,
    is_trustee,
    trust_name,
    foreign_type,
    self_representing_sub_id,
    subscriber_id,
    created_by_subscriber,
    ris_address,
    has_previously_held_land,
    duplicate_party_name,
    email_address,
    party_poa_id,
    other_names_flag,
    settleme_account_id,
    is_settle_me,
    interop_party_id,
    modified_extraction_start_ts as extraction_start_ts,
    row_num,
    src_delete_idn,
    deleted_at,
    inserted_at
from {{ ref('stg_pxa_partys' ) }} 
where (op in ('I','U') or (op ='D' and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
