with source as (

    select * from {{ ref('pxa_settle_datetime_history') }}

),

renamed as (

    select
        settle_datetime_history_id,
        version,
        settlement_id,
        modified_by,
        modified_by_role,
        old_datetime,
        new_datetime,
        date_changed,
        action_performed,
        modified_by_username,
        modified_by_subscriber_id,
        modified_by_system_user,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed