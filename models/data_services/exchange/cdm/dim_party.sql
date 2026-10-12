{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = 'id',
        merge_exclude_columns = ['inserted_at']
    )
}}

{#- When op is 'D', only the primary key and the management fields contain data, everything else is null -#}

WITH
{%- if is_incremental() %}
{#- only consider "new / updated" partys #}
party_ids AS (
    SELECT DISTINCT
        party_id
    FROM {{ ref('stg_pxa_partys') }}
    WHERE extraction_start_ts > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(inserted_at)') }} FROM {{ this }}), '1900-01-01')::timestamp_ntz
    UNION
    SELECT DISTINCT
        party_id
    FROM {{ ref('stg_pxa_persons') }}
    WHERE extraction_start_ts > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(inserted_at)') }} FROM {{ this }}), '1900-01-01')::timestamp_ntz
    UNION
    SELECT DISTINCT
        party_id
    FROM {{ ref('stg_pxa_organisations') }}
    WHERE extraction_start_ts > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(inserted_at)') }} FROM {{ this }}), '1900-01-01')::timestamp_ntz
),
{%- endif %}
partys_all AS (
    SELECT
        party_id,
        {#- workaround due to nature of Exchange delete, only partition by primary key #}
        IFF(op = 'D', LAG(workspace_id) OVER (PARTITION BY party_id ORDER BY version, extraction_start_ts, transact_seq NULLS FIRST), workspace_id) AS workspace_id,
        IFF(op = 'D', LAG(address) OVER (PARTITION BY party_id ORDER BY version, extraction_start_ts, transact_seq NULLS FIRST), address) AS address,
        IFF(op = 'D', LAG(subscriber_id) OVER (PARTITION BY party_id ORDER BY version, extraction_start_ts, transact_seq NULLS FIRST), subscriber_id) AS subscriber_id,
        IFF(op = 'D', LAG(is_foreign_transferee) OVER (PARTITION BY party_id ORDER BY version, extraction_start_ts, transact_seq NULLS FIRST), is_foreign_transferee) AS is_foreign_transferee,
        IFF(op = 'D', LAG(foreign_type) OVER (PARTITION BY party_id ORDER BY version, extraction_start_ts, transact_seq NULLS FIRST), foreign_type) AS foreign_type,
        {{ dms_timestampntz_us_to_ns('extraction_start_ts', ['party_id'], ['version NULLS LAST', 'extraction_start_ts'], 'Australia/Sydney') }} AS event_ts,
        op = 'D' AS is_delete
    FROM {{ ref('stg_pxa_partys') }}
    {%- if is_incremental() %}
    JOIN party_ids USING (party_id)
    {%- endif %}
),
partys AS (
    SELECT
        party_id,
        workspace_id,
        address,
        subscriber_id,
        is_foreign_transferee,
        foreign_type,
        MIN(event_ts) OVER (PARTITION BY party_id) AS inserted_at,
        MIN(IFF(is_delete, event_ts, NULL)) OVER (PARTITION BY party_id) AS deleted_at
    FROM partys_all
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY party_id ORDER BY event_ts DESC)
),
party_name_all AS (
    SELECT
        party_id,
        TRUE AS is_organisation,
        {#- workaround due to nature of Exchange delete, only partition by primary key #}
        IFF(op = 'D', LAG(name) OVER (PARTITION BY party_id ORDER BY extraction_start_ts, transact_seq NULLS FIRST), name) AS name,
        {{ dms_timestampntz_us_to_ns('extraction_start_ts', ['party_id'], ['extraction_start_ts'], 'Australia/Sydney') }} AS event_ts,
        op = 'D' AS is_delete
    FROM {{ ref('stg_pxa_organisations') }}
    {%- if is_incremental() %}
    JOIN party_ids USING (party_id)
    {%- endif %}
    UNION ALL
    SELECT
        party_id,
        FALSE AS is_organisation,
        {#- workaround due to nature of Exchange delete, only partition by primary key #}
        IFF(op = 'D', LAG(full_name) OVER (PARTITION BY party_id ORDER BY extraction_start_ts, transact_seq NULLS FIRST), full_name) AS name,
        {{ dms_timestampntz_us_to_ns('extraction_start_ts', ['party_id'], ['extraction_start_ts'], 'Australia/Sydney') }} AS event_ts,
        op = 'D' AS is_delete
    FROM {{ ref('stg_pxa_persons') }}
    {%- if is_incremental() %}
    JOIN party_ids USING (party_id)
    {%- endif %}
),
party_name AS (
    SELECT
        party_id,
        is_organisation,
        name,
        MIN(event_ts) OVER (PARTITION BY party_id) AS inserted_at,
        MIN(IFF(is_delete, event_ts, NULL)) OVER (PARTITION BY party_id) AS deleted_at
    FROM party_name_all
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY party_id ORDER BY event_ts DESC)
),
party_link AS (
    SELECT
        party_id AS id,
        workspace_id,
        pn.is_organisation,
        pn.name AS party_name,
        address,
        subscriber_id,
        is_foreign_transferee,
        foreign_type,
        LEAST(p.inserted_at, pn.inserted_at) AS inserted_at,
        LEAST(p.deleted_at, pn.deleted_at) AS deleted_at
    FROM partys p
    JOIN party_name pn USING (party_id)
    WHERE workspace_id IS NOT NULL
)
SELECT
    id,
    workspace_id,
    is_organisation,
    party_name,
    address,
    subscriber_id,
    is_foreign_transferee,
    foreign_type,
    inserted_at,
    deleted_at
FROM party_link
ORDER BY id
