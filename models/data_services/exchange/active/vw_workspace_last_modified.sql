with source as (

    select * from {{  ref('pxa_workspace_last_modified') }}

),

renamed as (

    select
        workspace_id,
        last_modified,
        version,
        inserted_at

    from source

)


select * from renamed