with source as (

    select * from {{ ref('pxa_conversations') }}

),

renamed as (

    select
        conversation_id,
        version,
        workspace_id,
        subject,
        high_priority,
        conversation_category,
        conversation_sub_category,
        is_auto_generated,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
     where effective_to::date = '{{var('active_date')}}'

)


select * from renamed