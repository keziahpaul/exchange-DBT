{{
    config(
        materialized = 'incremental',
        unique_key = ['id', 'extraction_ts'],
        snowflake_warehouse = env_var('DBT_ENV_NAME', 'DEV') | upper | replace('CI', 'TST') ~ '_TRN_S_WH' if flags.FULL_REFRESH else none
    )
}}
{#- id is the subscriber_id -#}

{#- PEXA-AU/core-pexa-app/pexa_core/src/main/java/au/necdl/pexa/core/subscriber/SubscriberDomain.java -#}
{#- takes about 1 minute in PROD 17k ish records for --full-refresh #}
{#- takes about 45 sec in PROD 0 ish records for incremental load #}

WITH
{%- if is_incremental() %}
{#- only consider "new / updated" subscribers #}
subscriber_ids AS (
    SELECT DISTINCT
        subscriber_id
    FROM {{ ref('stg_pxa_subscribers') }}
    WHERE extraction_start_ts > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(extraction_ts)') }} FROM {{ this }}), '1900-01-01')::timestamp_ntz
),
{%- endif %}
sub_created AS (
    {#- we can ignore DMS duplicate data as the created_date never changes #}
    SELECT
        be.subscriber_id,
        {{ timestampntz_to_tz('be.created_date', 'Australia/Sydney') }} AS created_date
    FROM {{ref('stg_pxa_business_event')}} be
    JOIN {{ref('dim_business_event')}} ds ON be.business_event_type_id = ds.id
    {%- if is_incremental() %}
    JOIN subscriber_ids USING (subscriber_id)
    {%- endif %}
    {#- this is just bad, use the first event for this subscriber_id as the creation event #}
    WHERE be.subscriber_id IS NOT NULL
      AND ds.category_name = 'Subscriber'
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY be.subscriber_id ORDER BY be.created_date)
),
subscriber_types AS (
    SELECT
        subscriber_type_id,
        name,
        category
    FROM {{ ref('stg_pxa_subscriber_types') }}
    {#- workaround to exclude DMS duplicate data, only want most recent record for this lookup table #}
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY subscriber_type_id ORDER BY extraction_start_ts DESC, transact_seq DESC NULLS LAST)
),
subscribers AS (
    SELECT
        {#- DMS only provides microsecond resolution, so fake additional nanoseconds to separate transactions #}
        {{ dms_timestampntz_us_to_ns('extraction_start_ts', ['subscriber_id', 'version'], ['extraction_start_ts'], 'UTC') }} AS extraction_ts,
        subscriber_id,
        version,
        name,
        legal_entity_name,
        COALESCE(business_unit, reg_business_name, legal_entity_name) AS operating_name,
        abn,
        acn,
        party_type,
        profile,
        status,
        status_reason,
        {{ timestampntz_to_tz('status_reason_date', 'Australia/Sydney') }} AS status_reason_date,
        address_id,
        subscriber_type_id,
        hidden_from_search,
        HASH(
            name,
            legal_entity_name,
            operating_name,
            abn,
            acn,
            party_type,
            profile,
            status,
            status_reason,
            status_reason_date,
            address_id,
            subscriber_type_id,
            hidden_from_search
        ) AS sub_hash
    FROM {{ ref('stg_pxa_subscribers') }}
    {%- if is_incremental() %}
    {#- remember to remove the nanoseconds adjustment for incremental load comparison and convert back to timestamp_ntz #}
    JOIN subscriber_ids USING (subscriber_id)
    {%- endif %}
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY subscriber_id, version ORDER BY extraction_start_ts DESC, transact_seq DESC NULLS LAST)
),
{#- also need to remove records from "subscribers" where the new records are a repeat of the last staged record #}
potential_stage_records AS (
    SELECT
        s.subscriber_id AS id,
        s.extraction_ts,
        sc.created_date,
        s.name,
        s.legal_entity_name,
        s.operating_name,
        s.abn,
        s.acn,
        s.party_type,
        s.profile,
        s.status,
        ss.enum_value AS status_value,
        ss.is_active AS status_is_active,
        ss.is_inactive AS status_is_inactive,
        ss.is_terminated AS status_is_terminated,
        s.hidden_from_search,
        s.status_reason,
        s.status_reason_date,
        s.address_id,
        a.road_number,
        a.road_name,
        a.suburb,
        a.post_code,
        a.state,
        s.subscriber_type_id,
        st.name AS subscriber_type,
        st.category AS subscriber_category
    FROM subscribers s
    JOIN {{ ref('enum_subscriber_status') }} ss ON s.status = ss.enum_name
    JOIN subscriber_types st ON st.subscriber_type_id = s.subscriber_type_id
    LEFT JOIN {{ ref('stg_pxa_addresses') }} a ON a.address_id = s.address_id {#- qualify takes latest address record #}
    LEFT JOIN sub_created sc ON sc.subscriber_id = s.subscriber_id
    QUALIFY sub_hash IS DISTINCT FROM LAG(sub_hash) OVER (PARTITION BY s.subscriber_id ORDER BY s.version, a.version DESC, a.extraction_start_ts DESC, a.transact_seq DESC NULLS LAST)
)
SELECT
    id,                     {#- dim/fact #}
    extraction_ts,          {#- fact #}
    created_date,           {#- dim #}
    name,                   {#- fact #}
    legal_entity_name,      {#- fact #}
    operating_name,         {#- fact #}
    abn,                    {#- dim #}
    acn,                    {#- dim #}
    party_type,             {#- dim #}
    profile,                {#- fact #}
    status,                 {#- fact #}
    status_value,           {#- fact #}
    status_is_active,       {#- fact #}
    status_is_inactive,     {#- fact #}
    status_is_terminated,   {#- fact #}
    hidden_from_search,     {#- fact #}
    status_reason,          {#- fact #}
    status_reason_date,     {#- fact #}
    address_id,             {#- fact #}
    road_number,            {#- fact #}
    road_name,              {#- fact #}
    suburb,                 {#- fact #}
    post_code,              {#- fact #}
    state,                  {#- fact #}
    subscriber_type_id,     {#- fact #}
    subscriber_type,        {#- fact #}
    subscriber_category     {#- fact #}
FROM potential_stage_records
{%- if is_incremental() %}
WHERE extraction_ts > COALESCE((SELECT MAX(extraction_ts) FROM {{ this }}), '1900-01-01')
{%- endif %}
ORDER BY extraction_ts
