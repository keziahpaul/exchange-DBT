with 

source as (

    select * from {{ ref('pxa_property_group') }}

),

renamed as (

    select
        property_group_id,
        property,
        property_group_address,
        document_id,
        noa_details_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source

)

select * from renamed
