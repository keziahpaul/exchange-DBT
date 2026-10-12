with source as (

    select * from {{ ref('pxa_permissions') }}

),

renamed as (

    select
        permission_id,
        name,
        description,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source

)

select * from renamed
