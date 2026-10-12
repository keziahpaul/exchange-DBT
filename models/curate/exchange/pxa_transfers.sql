
 {{ config ( 
     materialized='scd_materialization', 
     incremental_strategy='scd2_transformation',
     primary_key=[var('primary_keys_dict')['pxa_transfers']],
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
    transfer_id,
    consideration_type,
    consideration_amount,
    mcp_expiry_date,
    set_of_operative_words,
    mcp_reference,
    cash_amount,
    vendor_terms_amount,
    liabilities_amount,
    other_amount,
    other_description,
    multiple_transfer_indicator,
    first_transfer,
    first_transfer_lodged,
    referenced_transfer_id,
    contract_for_sale_date,
    lr_document_id,
    vgo_valued_indicator,
    sdv_unsign,
    consideration_gst_amount,
    compliance_data,
    restrictive_covenant_id,
    consideration_details,
    has_acting_trustee,
    is_part_tenancy,
    is_all_off,
    has_margin_scheme,
    date_of_agreement,
    land_development_status,
    land_use,
    total_interest_numerator,
    total_interest_denominator,
    modified_extraction_start_ts as extraction_start_ts,
    row_num,
    src_delete_idn,
    deleted_at,
    inserted_at
from {{ ref('stg_pxa_transfers' ) }} 
where (op in ('I','U') or (op ='D' and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
