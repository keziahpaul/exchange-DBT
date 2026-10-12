
with source as (

    select * from {{ ref('pxa_notifications') }}

),

renamed as (

    select
        notification_id,
        created,
        delivery_datetime,
        description,
        notification_method,
        recipient,
        status,
        business_event_id,
        notification_type_id,
        subject,
        workspace_id,
        severity,
        cc_recipient,
        data_json_string,
        inserted_at

    from source
)


select * from renamed