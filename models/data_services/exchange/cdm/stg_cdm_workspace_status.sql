{{
    config(
        materialized = 'incremental',
        unique_key = ['id', 'extraction_ts'],
        snowflake_warehouse = env_var('DBT_ENV_NAME', 'DEV') | upper | replace('CI', 'TST') ~ '_TRN_S_WH' if flags.FULL_REFRESH else none
    )
}}
{#- id is the workspace_id -#}

{#- it seems the "owning" subscriber is in the CREATE event !!! #}
WITH
{%- if is_incremental() %}
{#- only consider "new / updated" workspaces #}
workspace_ids AS (
    SELECT DISTINCT
        workspace_id
    FROM {{ ref('stg_pxa_workspaces') }}
    WHERE extraction_start_ts > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(extraction_ts)') }} FROM {{ this }}), '1900-01-01')::timestamp_ntz
),
{%- endif %}
legacy_created AS (
    {#- we can ignore DMS duplicate data
        there is only ever one created_date value and it is never updated
     #}
    SELECT
        workspace_id,
        COALESCE(MIN(IFF(business_event_type_id = 1, created_date, NULL)),
                 MIN(IFF(business_event_type_id = 9, created_date, NULL))) AS created_date
    FROM {{ref('stg_pxa_business_event')}}
    {%- if is_incremental() %}
    JOIN workspace_ids USING (workspace_id)
    {%- endif %}
    {#- using baseline data
        1 - 'WORKSPACE_CREATED',
        9 - 'WORKSPACE_ROLE_ADDED' because sometimes WORKSPACE_CREATED doesn't happen
     #}
    WHERE business_event_type_id IN (1, 9)
      {#- From 2023-06-04, created_date is maintained in pxa_workspaces - delta/R.18.00.01/delta_2023-05-05_changelog.xml #}
      AND created_date < '2023-06-04'
    GROUP BY 1
),
ws_txn_type AS (
    {#- we can ignore DMS duplicate data
        there is only ever at most 1 ws_transaction_type for a workspace, and it is never updated
     #}
    SELECT DISTINCT
        workspace_id,
        ws_transaction_type
    FROM {{ref('stg_pxa_ws_txn_type_workspaces')}}
    {%- if is_incremental() %}
    JOIN workspace_ids USING (workspace_id)
    {%- endif %}
),
uniq_src AS (
    SELECT
        extraction_start_ts,
        transact_seq,
        workspace_id,
        number1,
        jurisdiction,
        status,
        privacy,
        transaction_scope,
        created_date,
        transaction_type,
        archive_warning,
        archived,
        abandoned,
        bundle_type,
        is_interop,
        is_interop_archived,
        is_ready_to_book,
        is_interop_ready,
        interop_lock_status,
        interop_lock_id,
        panel_master_selected,
        is_pelno,
        {#- When R.23 is available in Snowflake, remove the NULL AS #}
        NULL::boolean AS is_reverted_to_regular_refi
    FROM {{ref('stg_pxa_workspaces')}}
    {%- if is_incremental() %}
    JOIN workspace_ids USING (workspace_id)
    {%- endif %}
    WHERE number1 <> 'Default'
    {#- workaround to exclude DMS duplicate data, want first time we saw this record #}
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY workspace_id, version ORDER BY extraction_start_ts, transact_seq NULLS FIRST)
),
src AS (
    SELECT
        {#- DMS only provides microsecond resolution, so fake additional nanoseconds to separate transactions #}
        {{ dms_timestampntz_us_to_ns('w.extraction_start_ts', ['w.workspace_id'], ['w.extraction_start_ts'], 'UTC') }} AS extraction_ts,
        w.workspace_id AS id,
        w.number1 AS workspace_number,
        w.jurisdiction,
        COALESCE(w.status, ds.workspace_status) AS status,
        COALESCE(w.privacy, ds.privacy) AS privacy,
        COALESCE(w.transaction_scope, ds.transaction_scope) AS transaction_scope,
        COALESCE(w.created_date, pbe.created_date) AS workspace_created,
        {{ timestampntz_to_tz('workspace_created', 'Australia/Sydney') }} AS created_date,
        w.transaction_type,
        COALESCE(wt.ws_transaction_type, ds.transaction_type) AS ws_transaction_type,
        CAST(w.archive_warning AS date) AS archive_warning,
        CAST(w.archived AS date) AS archived,
        {{ timestampntz_to_tz('w.abandoned', 'Australia/Sydney') }} AS abandoned,
        COALESCE(w.bundle_type, 'UNKNOWN BUNDLE TYPE') AS bundle_type,
        COALESCE(w.is_interop, ds.is_interop) AS is_interop,
        COALESCE(w.is_interop_archived, ds.is_interop_archived) AS is_interop_archived,
        COALESCE(w.is_ready_to_book, ds.is_ready_to_book) AS is_ready_to_book,
        COALESCE(w.is_interop_ready, ds.is_interop_ready) AS is_interop_ready,
        COALESCE(w.interop_lock_status, ds.interop_lock_status) AS interop_lock_status,
        COALESCE(w.interop_lock_id, 'UNKNOWN INTEROP LOCK ID') AS interop_lock_id,
        COALESCE(w.panel_master_selected, ds.panel_master_selected) AS panel_master_selected,
        COALESCE(w.is_pelno, ds.is_pelno) AS is_pelno,
        COALESCE(w.is_reverted_to_regular_refi, ds.is_reverted_to_regular_refi) AS is_reverted_to_regular_refi
    FROM uniq_src w
    LEFT JOIN ws_txn_type wt ON w.workspace_id = wt.workspace_id
    LEFT JOIN legacy_created pbe ON w.workspace_id = pbe.workspace_id,
    {{ref('dim_workspace_status')}} ds
    WHERE ds.is_default_row_for_null = TRUE
    {%- if is_incremental() %}
      AND extraction_start_ts > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(extraction_ts)') }} FROM {{ this }}), '1900-01-01')::timestamp_ntz
    {%- endif %}
)
SELECT
    src.id,                  {#- d/f  #}
    src.extraction_ts,       {#- fact #}
    ds.id AS status_id,      {#- fact #}
    src.workspace_number,    {#- dim  #}
    src.jurisdiction,        {#- dim  #}
    src.created_date,        {#- dim  #}
    src.ws_transaction_type, {#- dim  #}
    src.archive_warning,     {#- fact #}
    src.archived,            {#- fact #}
    src.abandoned,           {#- fact #}
    src.bundle_type,         {#- dim  #}
    src.interop_lock_id      {#- fact #}
FROM src
JOIN {{ref('dim_workspace_status')}} ds
    ON HASH(src.status, src.privacy, src.transaction_type, src.transaction_scope, src.panel_master_selected,
            src.is_ready_to_book, src.is_interop, src.is_interop_ready, src.interop_lock_status,
            src.is_interop_archived, src.is_pelno, src.is_reverted_to_regular_refi) = ds.id
ORDER BY src.extraction_ts
