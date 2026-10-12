with source as (

    select * from {{ ref('pxa_subscriber_correspondence') }}

),

renamed as (

    select
        subscriber_corr_id,
        subscriber_id,
        correspondence_id,
        jurisdiction,
        correspondence_type,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source

)

select * from renamed
