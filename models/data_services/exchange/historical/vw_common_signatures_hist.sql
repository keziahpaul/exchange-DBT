with source as (

    select * from {{ ref('pxa_common_signatures') }}

),

renamed as (

    select
        common_signature_id,
        signed_date,
        signature_configuration,
        xml,
        signed_by_user_id,
        xml_ref,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed