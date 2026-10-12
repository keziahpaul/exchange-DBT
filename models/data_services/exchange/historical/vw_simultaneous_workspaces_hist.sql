with source as (

    select * from {{ ref('pxa_simultaneous_workspaces') }}

),

renamed as (

    select
        simultaneous_lodgement_id,
        workspace_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source

)

select * from renamed
