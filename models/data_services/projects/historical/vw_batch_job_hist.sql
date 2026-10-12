with source as (

    select * from {{ ref('batch_job') }}

),

renamed as (

    select
        id,
        project_id,
        user_id,
        created_at,
        src_updated_at,
        status,
        file_name,
        type,
        role,
        settlement_date_time,
        failed_items,
        total_items,
        mot_project_id,
        created_on,
        created_by,
        last_modified_on,
        last_modified_by,
        version,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)

select * from renamed