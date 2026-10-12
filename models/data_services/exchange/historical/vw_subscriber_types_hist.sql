with source as (

    select * from {{  ref('pxa_subscriber_types') }}

),

renamed as (

    select
        subscriber_type_id,
        name,
        category,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed