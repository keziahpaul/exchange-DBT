with source as (

    select * from {{ ref('pxa_messages') }}

),

renamed as (

    select
        message_id,
        version,
        value1,
        author,
        created,
        conversation_id,
        conversation_subscriber_id,
        action_required,
        workspace_role_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed