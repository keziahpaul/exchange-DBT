

with source as (

    select * from {{ ref('outbound_notification_curate') }}

),

renamed as (

    select
        id,
        registration_id,
        status,
        created_at,
        data,
        retry_count,
        last_sent_at,
        next_retry_at,
        trace_id,
        event_type,
        workspace_id,
        updated_at_src,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source
   

)


select * from renamed
