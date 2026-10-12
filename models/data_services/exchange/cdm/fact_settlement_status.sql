{{
    config(
        materialized = 'incremental',
        unique_key = ['id', 'event_ts']
    )
}}

SELECT
    id,
    {#-- MIN(extraction_ts) AS event_ts, -- do I still need this? #}
    extraction_ts AS event_ts,
    {#- subscriber_id, #}
    status_id,
    settlement_date_and_time,
    ext_failure_reason,
    disburse_interim_flag,
    new_fss_on,
    auto_calculate_vendor_surplus,
    fss_partial_view,
    is_interop_fss_ready,
    interop_settlement_status,
    interop_settlement_datetime,
    interop_settlement_lock_status,
    is_async_update
FROM {{ref('stg_cdm_settlement_status')}}
{%- if is_incremental() %}
WHERE extraction_ts > COALESCE((SELECT MAX(event_ts) FROM {{ this }}), '1900-01-01')
{%- endif %}
ORDER BY event_ts
