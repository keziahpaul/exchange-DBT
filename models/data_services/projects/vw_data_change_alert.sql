with source as (

    select * from {{ ref('data_change_alert') }}

),

renamed as (

    select
        id,
        workspace_id,
        subscriber_reference,
        created_at,
        src_updated_at,
        alert_read,
        alert_flagged,
        change_type,
        change_from,
        change_to,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
    where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
