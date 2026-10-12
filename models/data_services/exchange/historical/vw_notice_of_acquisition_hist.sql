with 

source as (

    select * from {{ ref('pxa_notice_of_acquisition') }}

),

renamed as (

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
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source

)

select * from renamed
