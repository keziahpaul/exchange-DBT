with source as (

    select * from {{  ref('pxa_user_permissions') }}

),

renamed as (

    select
        permission_id,
        user_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source

)


select * from renamed