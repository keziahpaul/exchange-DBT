{{
    config(
        materialized = 'incremental',
        unique_key = 'id',
        snowflake_warehouse = env_var('DBT_ENV_NAME', 'DEV') | upper | replace('CI', 'TST') ~ '_TRN_S_WH' if flags.FULL_REFRESH else none
    )
}}
{#- id is the business_event_id -#}

WITH
{%- if is_incremental() %}
business_event_ids AS (
    SELECT DISTINCT
        business_event_id
    FROM {{ref('stg_pxa_business_event')}}
    {#- remember to remove the nanoseconds adjustment for incremental load comparison and convert back to timestamp_ntz #}
    WHERE extraction_start_ts > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(extraction_ts)') }} FROM {{ this }}), '1900-01-01')::timestamp_ntz
),
{%- endif %}
uniq_src AS (
    SELECT
        extraction_start_ts,
        transact_seq,
        created_date,
        business_event_id,
        workspace_id,
        business_event_type_id,
        user_id,
        lodgement_case_id,
        subscriber_id,
        username
    FROM {{ref('stg_pxa_business_event')}}
    {%- if is_incremental() %}
    JOIN business_event_ids USING (business_event_id)
    {%- endif %}
    WHERE workspace_id IS NOT NULL
    {#- workaround to exclude DMS duplicate data, want first time we saw this record #}
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY business_event_id ORDER BY extraction_start_ts, transact_seq NULLS FIRST)
),
src AS (
    SELECT
        {#- DMS only provides microsecond resolution, so fake additional nanoseconds to separate transactions #}
        {{ dms_timestampntz_us_to_ns('be.extraction_start_ts', ['be.business_event_id'], ['be.extraction_start_ts'], 'UTC') }} AS extraction_ts,
        {{ timestampntz_to_tz('be.created_date', 'Australia/Sydney') }} AS created_date,
        be.business_event_id,
        be.workspace_id,
        be.business_event_type_id,
        be.user_id,
        be.lodgement_case_id,
        be.subscriber_id,
        be.username
    FROM uniq_src be
    JOIN {{ref('dim_business_event')}} ds ON be.business_event_type_id = ds.id
    {%- if is_incremental() %}
    {#- remember to remove the nanoseconds adjustment for incremental load comparison and convert back to timestamp_ntz #}
    WHERE be.extraction_start_ts > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(extraction_ts)') }} FROM {{ this }}), '1900-01-01')::timestamp_ntz
    {%- endif %}
)
SELECT
    business_event_id AS id, {#- fact #}
    extraction_ts,
    created_date,            {#- fact #}
    workspace_id,            {#- fact #}
    business_event_type_id,  {#- fact #}
    lodgement_case_id,       {#- fact #}
    subscriber_id,           {#- fact #}
    user_id,                 {#- fact #}
    username                 {#- fact #}
FROM src
ORDER BY extraction_ts
