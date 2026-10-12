{{
    config(
        materialized = 'incremental',
        unique_key = ['id', 'event_ts']
    )
}}

SELECT
    id,
    extraction_ts AS event_ts,
    status_id,
    archive_warning,
    archived,
    abandoned,
    interop_lock_id
FROM {{ref('stg_cdm_workspace_status')}}
{%- if is_incremental() %}
WHERE extraction_ts > COALESCE((SELECT MAX(event_ts) FROM {{ this }}), '1900-01-01')
{%- endif %}
ORDER BY event_ts
