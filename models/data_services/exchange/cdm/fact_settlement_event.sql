{{
    config(
        materialized = 'incremental',
        unique_key = ['id', 'event_ts']
    )
}}

SELECT
    id,
    date_changed AS event_ts,
    action_performed,
    modified_by_system_user,
    modified_by_subscriber_id,
    modified_by,
    modified_by_username,
    modified_by_role,
    old_datetime,
    new_datetime
FROM {{ref('stg_cdm_settlement_event')}}
{%- if is_incremental() %}
WHERE date_changed > COALESCE((SELECT MAX(event_ts) FROM {{ this }}), '1900-01-01')
{%- endif %}
ORDER BY event_ts
