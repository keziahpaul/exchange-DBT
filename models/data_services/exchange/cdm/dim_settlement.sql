{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = 'id',
        merge_exclude_columns = ['id', 'workspace_id']
    )
}}

WITH settlement_src AS (
    SELECT
        id,
        workspace_id,
        MAX(extraction_ts) AS last_updated,
        MAX(initial_settlement_date_and_time) AS initial_settlement_date_and_time,
        {#- subscriber_id, #}
        MAX(is_canary) AS is_canary
    FROM {{ref('stg_cdm_settlement_status')}}
    {%- if is_incremental() %}
    WHERE extraction_ts > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(last_updated)') }} FROM {{ this }}), '1900-01-01')
    {%- endif %}
    GROUP BY ALL
)
SELECT
    id,
    workspace_id,
    last_updated,
    initial_settlement_date_and_time,
    {#- subscriber_id, #}
    is_canary
FROM settlement_src
ORDER BY id
