with source as (

    select * from {{ ref('pxa_workspaces_accessed') }}

),

renamed as (

    select
        id,
        user_id,
        workspace_id,
        date_accessed,
        workspace_role_id,
        files_accessed,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed