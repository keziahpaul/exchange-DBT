with source as (

    select * from {{ ref('authority') }}

),

renamed as (

    select
        role,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)

select * from renamed
