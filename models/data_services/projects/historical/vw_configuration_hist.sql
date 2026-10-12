with source as (

    select * from {{ ref('configuration') }}

),

renamed as (

    select
        id,
        name,
        data,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)

select * from renamed
