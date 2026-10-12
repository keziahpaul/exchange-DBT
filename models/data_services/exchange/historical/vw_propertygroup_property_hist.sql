with source as (

    select * from {{ ref('pxa_propertygroup_property') }}

),

renamed as (

    select
        property_group_id,
        property_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed