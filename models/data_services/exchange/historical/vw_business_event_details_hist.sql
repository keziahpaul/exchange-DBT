with source as (

    select * from {{ ref('pxa_business_event_details') }}

),

renamed as (

    select
        id,
        business_event_id,
        date_created,
        details,
        details_ref,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed