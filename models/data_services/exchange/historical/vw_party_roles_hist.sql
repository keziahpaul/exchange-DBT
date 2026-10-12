with 

source as (

    select * from {{ ref('pxa_party_roles') }}

),

renamed as (

    select
        party_id,
        workspace_role_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source

)

select * from renamed
