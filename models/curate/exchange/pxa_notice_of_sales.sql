
 {{ config ( 
     materialized='scd_materialization', 
     incremental_strategy='scd2_transformation',
     primary_key=[var('primary_keys_dict')['pxa_notice_of_sales']],
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
    property,
    locality,
    area,
    measurement,
    nature_of_property,
    party_for_notice,
    party_id,
    contact_name,
    notice_address,
    address_type,
    address,
    transfer_share,
    property_transferred,
    transfer_id,
    gst_amount,
    non_fixed_improvements_ind,
    other_land_included_indication,
    contract_sale_date,
    acquisition_type,
    acquisition_date,
    customer_reference,
    modified_extraction_start_ts as extraction_start_ts,
    row_num,
    src_delete_idn,
    deleted_at,
    inserted_at
from {{ ref('stg_pxa_notice_of_sales' ) }} 
where (op in ('I','U') or (op ='D' and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
