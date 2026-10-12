with 

source as (

    select * from {{ ref('pxa_noa_details') }}

),

renamed as (

    select
        noa_details_id,
        municipality_name,
        municipality_property_no,
        known_dimension,
        area_of_land,
        unit_of_entitlement,
        area,
        measurement,
        unit_entitlement,
        primary_land_use,
        primary_construction_type,
        no_of_bedrooms,
        sale_price,
        property_group,
        nature_of_property,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source

)

select * from renamed
