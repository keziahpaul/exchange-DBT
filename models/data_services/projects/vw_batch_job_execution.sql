with source as (

    select * from {{ ref('batch_job_execution') }}

),

renamed as (

    select
        job_execution_id,
        version,
        job_instance_id,
        create_time,
        start_time,
        end_time,
        status,
        exit_code,
        exit_message,
        last_updated,
        job_configuration_location,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
    where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
