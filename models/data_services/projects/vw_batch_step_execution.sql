with source as (

    select * from {{ ref('batch_step_execution') }}

),

renamed as (

    select
        step_execution_id,
        version,
        step_name,
        job_execution_id,
        start_time,
        end_time,
        status,
        commit_count,
        read_count,
        filter_count,
        write_count,
        read_skip_count,
        write_skip_count,
        process_skip_count,
        rollback_count,
        exit_code,
        exit_message,
        last_updated,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
    where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
