with source as (

    select * from {{ ref('batch_lock') }}

),

renamed as (

    select
        id,
        project_id,
        created_at,
        mot_project_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
    where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
