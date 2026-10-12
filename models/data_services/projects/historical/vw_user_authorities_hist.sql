with source as (

    select * from {{ ref('user_authorities') }}

),

renamed as (

    select
        authority_role,
        user_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)

select * from renamed
