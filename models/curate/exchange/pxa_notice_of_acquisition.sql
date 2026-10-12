
 {{ config ( 
     materialized='scd_materialization', 
     incremental_strategy='scd2_transformation',
     primary_key=[var('primary_keys_dict')['pxa_notice_of_acquisition']],
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
    transferor_land_capactiy,
    transferee_land_capactiy,
    sro_lead_customer,
    principal_place_of_residence,
    total_sale_price,
    deposit_paid,
    purchase_terms_sale,
    contract_of_sale,
    contract_of_sale_date,
    date_of_possession,
    reference_id,
    source_document_id,
    non_fixed_improvements_ind,
    other_land_included_indication,
    contract_sale_date,
    acquisition_type,
    acquisition_date,
    customer_reference,
    selected_transferee,
    selected_property,
    modified_extraction_start_ts as extraction_start_ts,
    row_num,
    src_delete_idn,
    deleted_at,
    inserted_at
from {{ ref('stg_pxa_notice_of_acquisition' ) }} 
where (op in ('I','U') or (op ='D' and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
