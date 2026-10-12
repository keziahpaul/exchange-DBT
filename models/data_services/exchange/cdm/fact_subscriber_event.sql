{{
    config(
        materialized = 'incremental',
        unique_key = ['id', 'event_ts']
    )
}}

SELECT
    id,
    extraction_ts AS event_ts,
    name,
    legal_entity_name,
    operating_name,
    profile,
    status,
    status_value,
    status_is_active,
    status_is_inactive,
    status_is_terminated,
    hidden_from_search,
    status_reason,
    status_reason_date,
    address_id,
    road_number,
    road_name,
    suburb,
    post_code,
    state,
    subscriber_type_id,
    subscriber_type,
    subscriber_category
FROM {{ref('stg_cdm_subscriber_event')}}
{%- if is_incremental() %}
WHERE extraction_ts > COALESCE((SELECT MAX(event_ts) FROM {{ this }}), '1900-01-01')
{%- endif %}
ORDER BY event_ts
