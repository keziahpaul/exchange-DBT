{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = ['id', 'date_changed'],
        snowflake_warehouse = env_var('DBT_ENV_NAME', 'DEV') | upper | replace('CI', 'TST') ~ '_TRN_S_WH' if flags.FULL_REFRESH else none
    )
}}
{#- id is the settlement_id -#}

WITH
{%- if is_incremental() %}
{#- only consider "new / updated" settlements #}
settlement_ids AS (
    SELECT DISTINCT
        settlement_id
    FROM {{ref('stg_pxa_settle_datetime_history')}}
    WHERE date_changed > COALESCE((SELECT {{ dms_timestamp_trunc(timestampntz_to_tz('MAX(date_changed)', 'UTC')) }} FROM {{ this }}), '1900-01-01')::timestamp_ntz
),
{%- endif %}
uniq_src AS (
    SELECT
        extraction_start_ts,
        transact_seq,
        date_changed, {#- this is ntz already in Sydney time #}
        settlement_id,
        action_performed,
        modified_by_system_user,
        modified_by_subscriber_id,
        modified_by,
        modified_by_username,
        modified_by_role,
        old_datetime,
        new_datetime
    FROM {{ref('stg_pxa_settle_datetime_history')}}
    {%- if is_incremental() %}
    JOIN settlement_ids USING (settlement_id)
    {%- endif %}
    {#- workaround to exclude DMS duplicate data, want first time we saw this record #}
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY settle_datetime_history_id ORDER BY extraction_start_ts, transact_seq NULLS FIRST)
),
src AS (
    SELECT
        {#- DMS only provides microsecond resolution, so fake additional nanoseconds to separate transactions #}
        {{ dms_timestampntz_us_to_ns('stl.date_changed', ['stl.settlement_id'], []) }} AS _date_changed, {#- becomes tz UTC #}
        {{ timestampntz_to_tz('_date_changed', 'Australia/Sydney') }} AS date_changed, {#- replaces tz with Aus/Syd #}
        stl.settlement_id AS id,
        COALESCE(stl.action_performed, ds.enum_name) AS action_performed,
        stl.modified_by_system_user,
        stl.modified_by_subscriber_id,
        stl.modified_by,
        stl.modified_by_username,
        stl.modified_by_role,
        stl.old_datetime,
        stl.new_datetime,
        COALESCE(cs.is_canary, FALSE) AS is_canary
    FROM uniq_src stl
    LEFT JOIN {{ref('canary_subscriber')}} cs ON stl.modified_by_subscriber_id = cs.subscriber_id,
    {{ref('enum_settlement_datetime_update')}} ds
    WHERE ds.is_default = TRUE
    {%- if is_incremental() %}
    {#- remember to remove the nanoseconds adjustment for incremental load comparison and convert back to timestamp_ntz #}
      AND stl.date_changed > COALESCE((SELECT {{ dms_timestamp_trunc(timestampntz_to_tz('MAX(date_changed)', 'UTC')) }} FROM {{ this }}), '1900-01-01')::timestamp_ntz
    {%- endif %}
)
SELECT
    id,                                  {#- d/f  #}
    date_changed,                        {#- fact #}
    is_canary,                           {#- dim  #}
    action_performed,                    {#- fact #}
    modified_by_system_user,             {#- fact #}
    modified_by_subscriber_id,           {#- fact #}
    modified_by,                         {#- fact #}
    modified_by_username,                {#- fact #}
    modified_by_role,                    {#- fact #}
    old_datetime,                        {#- fact #}
    new_datetime                         {#- fact #}
FROM src
ORDER BY date_changed
