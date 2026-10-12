{{
    config(
        materialized = 'incremental',
        unique_key = ['id', 'event_ts']
    )
}}
{#- id is the lodgement_id -#}
{#- date1 is lodgement received -#}

{#- When op is 'D', only the primary key and the management fields contain data, everything else is null -#}

WITH
{%- if is_incremental() %}
{#- only consider "new / updated" lodgements #}
lodgement_ids AS (
    SELECT DISTINCT
        lodgement_id
    FROM {{ ref('stg_pxa_lodgements') }}
    WHERE extraction_start_ts > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(event_ts)') }} FROM {{ this }}), '1900-01-01')::timestamp_ntz
),
{%- endif %}
lodge_all AS (
    SELECT
        lodgement_id,
        {{ dms_timestampntz_us_to_ns('extraction_start_ts', ['lodgement_id'], ['version NULLS LAST', 'extraction_start_ts'], 'Australia/Sydney') }} AS event_ts,
        op = 'D' AS is_delete,
        ROW_NUMBER() OVER (PARTITION BY lodgement_id ORDER BY version NULLS LAST, extraction_start_ts, transact_seq NULLS FIRST) AS rn,
        {#- workaround due to nature of Exchange delete, only partition by primary key #}
        IFF(is_delete, LAG(workspace_id) OVER (PARTITION BY lodgement_id ORDER BY version, extraction_start_ts, transact_seq NULLS FIRST), workspace_id) AS workspace_id,
        IFF(is_delete, LAG(settlement_id) OVER (PARTITION BY lodgement_id ORDER BY version, extraction_start_ts, transact_seq NULLS FIRST), settlement_id) AS settlement_id,
        IFF(is_delete, LAG(status) OVER (PARTITION BY lodgement_id ORDER BY version, extraction_start_ts, transact_seq NULLS FIRST), status) AS status,
        IFF(is_delete, LAG(date1) OVER (PARTITION BY lodgement_id ORDER BY version, extraction_start_ts, transact_seq NULLS FIRST), date1) AS date1,
        IFF(is_delete, LAG(verification_request_time) OVER (PARTITION BY lodgement_id ORDER BY version, extraction_start_ts, transact_seq NULLS FIRST), verification_request_time) AS verification_request_time
    FROM {{ ref('stg_pxa_lodgements') }}
    {%- if is_incremental() %}
    JOIN lodgement_ids USING (lodgement_id)
    {%- endif %}
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY lodgement_id, version ORDER BY extraction_start_ts, transact_seq NULLS FIRST)
),
lodge_det AS (
    SELECT
        event_ts,
        rn,
        lodgement_id,     
        workspace_id,
        settlement_id,
        status,
        {{ timestampntz_to_tz('date1', 'Australia/Sydney') }} AS lodgement_date,
        {{ timestampntz_to_tz('verification_request_time', 'Australia/Sydney') }} AS verification_request_time,
        is_delete
    FROM lodge_all
    WHERE workspace_id IS NOT NULL
),
lodge_chg AS (
    SELECT
        lodgement_id AS id,
        event_ts,
        IFF(rn = 1 AND verification_request_time IS NOT NULL AND verification_request_time < event_ts, verification_request_time, event_ts) AS date_changed,
        workspace_id,
        settlement_id,
        status,
        lodgement_date,
        is_delete,
        HASH(settlement_id, status, lodgement_date) AS lodge_hash
    FROM lodge_det
    QUALIFY lodge_hash IS DISTINCT FROM LAG(lodge_hash) OVER (PARTITION BY id ORDER BY event_ts)
)
SELECT
    id,
    event_ts,
    date_changed,
    workspace_id,
    settlement_id,
    status,
    lodgement_date,
    is_delete
FROM lodge_chg
{#- reduce the volume of data to add into the stage table #}
{%- if is_incremental() %}
WHERE event_ts > COALESCE((SELECT MAX(event_ts) FROM {{ this }}), '1900-01-01')
ORDER BY event_ts
{%- endif %}
