with source as (

    select * from {{  ref('pxa_workgroup_workspaces') }}

),

renamed as (

    select
        workgroup_id,
        workspace_id,
      effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source

)


select * from renamed