with source as (

    select * from {{ ref('workspace_update_parent_title_job_item') }}

),

renamed as (

    select
        id,
        batch_job_id,
        data,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)

select * from renamed
