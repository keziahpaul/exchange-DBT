with source as (

    select * from {{ ref('workspace') }}

),

renamed as (

    select
        id,
        project_id,
        data,
        modified_by_ip,
        version,
        created_on,
        created_by,
        last_modified_on,
        last_modified_by,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)

select * from renamed
