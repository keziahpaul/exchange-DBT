with source as (

    select * from {{ ref('pxa_business_event_ref_types') }}  

),

renamed as (

    select
        business_event_ref_type_id,
        name,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)

select * from renamed
