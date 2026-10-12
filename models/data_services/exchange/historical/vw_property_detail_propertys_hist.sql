with source as (

    select * from {{  ref('pxa_property_detail_propertys') }}

),

renamed as (

    select
        property_detail_id,
        property_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed