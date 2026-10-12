with source as (

    select * from {{ ref('pxa_conversation_subscribers') }}

),

renamed as (

    select
        conversation_subscriber_id,
        version,
        conversation_id,
        subscriber_id,
        last_accessed,
        invited_by,
        unread,
        workspace_role_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'

)


select * from renamed