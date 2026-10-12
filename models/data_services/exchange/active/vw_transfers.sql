with source as (

    select * from {{  ref('pxa_transfers') }}

),

renamed as (

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
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed