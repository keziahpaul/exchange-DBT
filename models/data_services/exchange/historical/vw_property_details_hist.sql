with source as (

    select * from {{  ref('pxa_property_details') }}

),

renamed as (

    select
        property_detail_id,
        issued,
        description,
        estate_type,
        address,
        bundle_subscription,
        duplicate_ct_issued,
        cert_of_title_details_id,
        positive_tac_flag,
        tac_failure_flag,
        address_id,
        title_type,
        sub_jurisdiction,
        numerator_share_of_land,
        denom_share_of_land,
        expiry_date,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed