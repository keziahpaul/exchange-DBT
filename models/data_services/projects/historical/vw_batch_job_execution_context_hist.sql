with source as (

    select * from {{ ref('batch_job_execution_context') }}

),

renamed as (

    select
        job_execution_id,
        short_context,
        serialized_context,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)

select * from renamed
