with source as (

    select * from {{ ref('batch_job_instance') }}

),

renamed as (

    select
        job_instance_id,
        version,
        job_name,
        job_key,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
    where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
