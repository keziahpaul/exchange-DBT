with source as (

    select * from {{ ref('upload_file') }}

),

renamed as (

    select
        id,
        pot_project_id,
        mot_project_id,
        status,
        file_type,
        file_content,
        mapped_content,
        user_id,
        created_at,
        src_updated_at,
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
    where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
