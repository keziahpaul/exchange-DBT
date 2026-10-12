with source as (

    select * from {{ ref('pxa_corrective_homes') }}

),

renamed as (

    select
        corrective_home_id,
        name,
        active,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source

)

select * from renamed
