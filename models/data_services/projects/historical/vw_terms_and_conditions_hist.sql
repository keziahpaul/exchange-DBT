with source as (

    select * from {{ ref('terms_and_conditions') }}

),

renamed as (

    select
        id,
        tnc,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)

select * from renamed
