with 

source as (

    select * from {{ ref('pxa_notice_of_sales') }}

),

renamed as (

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
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source

)

select * from renamed
