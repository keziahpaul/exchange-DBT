with source as (

    select * from {{ ref('batch_step_execution_context') }}

),

renamed as (

    select
        step_execution_id,
        short_context,
        serialized_context,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
    where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
