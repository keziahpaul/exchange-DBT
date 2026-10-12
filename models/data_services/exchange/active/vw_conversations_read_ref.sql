with source as (

    select * from {{ ref('pxa_conversations_read_ref') }}

),

renamed as (

    select
        conversations_read_ref_id,
        conversation_subscriber_id,
        message_id,
        read_date,
        user_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source
    where effective_to::date = '{{ var('active_date') }}'
)

select * from renamed
