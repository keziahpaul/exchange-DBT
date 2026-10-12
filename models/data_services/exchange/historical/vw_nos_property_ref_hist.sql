with 

source as (

    select * from {{ ref('pxa_nos_property_ref') }}

),

renamed as (

    select
        property_ref_id,
        reference_data,
        other_details,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source

)

select * from renamed
