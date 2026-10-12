{{ config (
    materialized="view"
)
}}

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
        extraction_start_ts,
        inserted_at 
    from {{ ref('stg_pxa_notifications') }}
 