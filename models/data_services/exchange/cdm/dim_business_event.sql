{{
    config(
        materialized = 'incremental',
        unique_key = 'id'
    )
}}
{#- There is no null replacement for this model -#}

WITH bus_event_types AS (
    SELECT
        business_event_type_id,
        extraction_start_ts,
        transact_seq,
        name,
        business_event_category_id,
        workspace_related,
        action_required,
        description
    FROM {{ ref('stg_pxa_business_event_types') }}
    {#- workaround to exclude DMS duplicate data, want most recent record #}
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY business_event_type_id ORDER BY extraction_start_ts DESC, transact_seq DESC NULLS LAST)
), 
bus_event_categories AS (
    SELECT
        business_event_category_id,
        extraction_start_ts,
        transact_seq,
        name
    FROM {{ ref('stg_pxa_business_event_categories') }}
    {#- workaround to exclude DMS duplicate data, want most recent record #}
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY business_event_category_id ORDER BY extraction_start_ts DESC, transact_seq DESC NULLS LAST)
), 
src AS (
    SELECT
        {{ dms_timestampntz_us_to_ns('bet.extraction_start_ts', ['bet.business_event_type_id'], ['bet.extraction_start_ts'], 'UTC') }} AS bet_extraction_ts,
        {{ dms_timestampntz_us_to_ns('bec.extraction_start_ts', ['bec.business_event_category_id'], ['bec.extraction_start_ts'], 'UTC') }} AS bec_extraction_ts,
        GREATEST(bet_extraction_ts, bec_extraction_ts) AS extraction_ts,

        bet.business_event_type_id AS id,
        bet.name AS event_name,
        bet.business_event_category_id,
        bec.name AS category_name,
        bet.workspace_related,
        bet.action_required,
        COALESCE(bet.description, '') AS description
    FROM bus_event_types bet
    JOIN bus_event_categories bec USING (business_event_category_id)
)
SELECT
    id,
    extraction_ts AS created_on,
    event_name,
    business_event_category_id,
    category_name,
    workspace_related,
    action_required,
    description
FROM src
ORDER BY id
