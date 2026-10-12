{{
    config(
        materialized = 'incremental',
        unique_key = ['id', 'extraction_ts']
    )
}}
{#- id is the settlement_id -#}

WITH
{%- if is_incremental() %}
{#- only consider "new / updated" settlements #}
settlement_ids AS (
    SELECT DISTINCT
        settlement_id
    FROM {{ref('stg_pxa_settlements')}}
    WHERE extraction_start_ts > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(extraction_ts)') }} FROM {{ this }}), '1900-01-01')::timestamp_ntz
),
{%- endif %}
uniq_src AS (
    SELECT
        settlement_id,
        extraction_start_ts,
        transact_seq,
        workspace_id,
        subscriber_id, {#- only used for the canary check later #}
        date1,
        orig_settle_date,
        type1,
        status,
        link_type,
        rits_status,
        settlement_tracking_status,
        ext_failure_reason,
        disburse_interim_flag,
        new_fss_on,
        auto_calculate_vendor_surplus,
        fss_partial_view,
        is_interop_fss_ready,
        interop_settlement_status,
        interop_settlement_datetime,
        interop_settlement_lock_status,
        {#- When R.22.01 is available in Snowflake, remove the NULL AS #}
        NULL::boolean AS is_async_update
    FROM {{ref('stg_pxa_settlements')}}
    {%- if is_incremental() %}
    JOIN settlement_ids USING (settlement_id)
    {%- endif %}
    {#- workaround to exclude DMS duplicate data, want first time we saw this record #}
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY settlement_id, version ORDER BY extraction_start_ts, transact_seq NULLS FIRST)
),
src AS (
    SELECT
        {#- DMS only provides microsecond resolution, so fake additional nanoseconds to separate transactions #}
        {{ dms_timestampntz_us_to_ns('stl.extraction_start_ts', ['stl.settlement_id'], ['stl.extraction_start_ts'], 'UTC') }} AS extraction_ts,
        stl.settlement_id AS id,
        stl.workspace_id,
        {{ timestampntz_to_tz('stl.date1', 'Australia/Sydney') }} AS settlement_date_and_time,
        {{ timestampntz_to_tz('stl.orig_settle_date', 'Australia/Sydney') }} AS initial_settlement_date_and_time,
        COALESCE(cs.is_canary, FALSE) AS is_canary,
        COALESCE(stl.type1, ds.settlement_type) AS type1,
        COALESCE(stl.status, ds.settlement_status) AS status,
        COALESCE(stl.link_type, ds.link_type) AS link_type,
        COALESCE(stl.rits_status, ds.rits_status) AS rits_status,
        COALESCE(stl.settlement_tracking_status, ds.settlement_tracking_status) AS settlement_tracking_status,
        stl.ext_failure_reason,
        stl.disburse_interim_flag,
        stl.new_fss_on,
        stl.auto_calculate_vendor_surplus,
        stl.fss_partial_view,
        stl.is_interop_fss_ready,
        stl.interop_settlement_status,
        {{ timestampntz_to_tz('stl.interop_settlement_datetime', 'Australia/Sydney') }} AS interop_settlement_datetime,
        stl.interop_settlement_lock_status,
        COALESCE(stl.is_async_update, FALSE) AS is_async_update
    FROM uniq_src stl
    LEFT JOIN {{ref('canary_subscriber')}} cs ON stl.subscriber_id = cs.subscriber_id,
    {{ref('dim_settlement_status')}} ds
    WHERE ds.is_default_row_for_null = TRUE
    {%- if is_incremental() %}
      {#- remember to remove the nanoseconds adjustment for incremental load comparison and convert back to timestamp_ntz #}
      AND stl.extraction_start_ts > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(extraction_ts)') }} FROM {{ this }}), '1900-01-01')::timestamp_ntz
    {%- endif %}
)
SELECT
    src.id,                                {#- d/f  #}
    src.extraction_ts,                     {#- d/f  #}
    src.workspace_id,                      {#- dim  #}
    src.is_canary,                         {#- dim  #}
    ds.id AS status_id,                    {#- fact #}
    src.settlement_date_and_time,          {#- fact #}
    src.initial_settlement_date_and_time,  {#- dim  #}
    src.ext_failure_reason,                {#- fact #}
    src.disburse_interim_flag,             {#- fact #}
    src.new_fss_on,                        {#- fact #}
    src.auto_calculate_vendor_surplus,     {#- fact #}
    src.fss_partial_view,                  {#- fact #}
    src.is_interop_fss_ready,              {#- fact #}
    src.interop_settlement_status,         {#- fact #}
    src.interop_settlement_datetime,       {#- fact #}
    src.interop_settlement_lock_status,    {#- fact #}
    src.is_async_update                    {#- fact #}
FROM src
JOIN {{ref('dim_settlement_status')}} ds
    ON HASH(src.link_type, src.rits_status, src.status, src.type1, src.settlement_tracking_status) = ds.id
ORDER BY src.extraction_ts
