{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = ['id', 'date_changed'],
        snowflake_warehouse = env_var('DBT_ENV_NAME', 'DEV') | upper | replace('CI', 'TST') ~ '_TRN_S_WH' if flags.FULL_REFRESH else none
    )
}}
{#- id is the document_id -#}
{#- When op is 'D', only the primary key and the management fields contain data, everything else is null -#}

WITH
{%- if is_incremental() %}
{#- only consider "new / updated" documents #}
document_ids AS (
    SELECT DISTINCT
        document_id
    FROM {{ ref('stg_pxa_documents') }}
    WHERE extraction_start_ts > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(date_changed)') }} FROM {{ this }}), '1900-01-01')::timestamp_ntz
),
{%- endif %}
lodge_doc_det_src AS (
    SELECT
        document_id,
        ROW_NUMBER() OVER (PARTITION BY document_id ORDER BY version, extraction_start_ts, transact_seq NULLS FIRST) AS rn,
        op = 'D' AS is_delete,
        extraction_start_ts,
        HASH(
            document_type_id,
            created_date,
            parent_document,
            lodgement_id,
            created_by_role_id,
            created_by_susbscriber_id,
            status,
            settlement_id,
            order_of_lodgement,
            is_delete
        ) AS r_hash,
        document_type_id,
        created_date,
        last_updated_date,
        parent_document,
        lodgement_id,
        created_by_role_id,
        created_by_susbscriber_id,
        status,
        settlement_id,
        order_of_lodgement
    FROM {{ ref('stg_pxa_documents') }}
    {%- if is_incremental() %}
    JOIN document_ids USING (document_id)
    {%- endif %}
    WHERE (op = 'D' OR lodgement_id IS NOT NULL)
    QUALIFY r_hash IS DISTINCT FROM LAG(r_hash) OVER (PARTITION BY document_id ORDER BY version, extraction_start_ts, transact_seq NULLS FIRST)
),
lodge_doc_det_pre AS (
SELECT
    document_id,
    rn AS transact_seq,
    is_delete,
    extraction_start_ts,
    IFF(is_delete, LAG(document_type_id) OVER (PARTITION BY document_id ORDER BY rn), document_type_id) AS document_type_id,
    IFF(is_delete, LAG(created_date) OVER (PARTITION BY document_id ORDER BY rn), created_date) AS created_date,
    IFF(is_delete, LAG(last_updated_date) OVER (PARTITION BY document_id ORDER BY rn), last_updated_date) AS last_updated_date,
    IFF(is_delete, LAG(parent_document) OVER (PARTITION BY document_id ORDER BY rn), parent_document) AS parent_document,
    IFF(is_delete, LAG(lodgement_id) OVER (PARTITION BY document_id ORDER BY rn), lodgement_id) AS lodgement_id,
    IFF(is_delete, LAG(created_by_role_id) OVER (PARTITION BY document_id ORDER BY rn), created_by_role_id) AS created_by_role_id,
    IFF(is_delete, LAG(created_by_susbscriber_id) OVER (PARTITION BY document_id ORDER BY rn), created_by_susbscriber_id) AS created_by_susbscriber_id,
    IFF(is_delete, LAG(status) OVER (PARTITION BY document_id ORDER BY rn), status) AS status,
    IFF(is_delete, LAG(settlement_id) OVER (PARTITION BY document_id ORDER BY rn), settlement_id) AS settlement_id,
    IFF(is_delete, LAG(order_of_lodgement) OVER (PARTITION BY document_id ORDER BY rn), order_of_lodgement) AS order_of_lodgement
FROM lodge_doc_det_src
),
lodge_doc_det AS (
    SELECT
        {{ dms_timestampntz_us_to_ns('extraction_start_ts', ['document_id'], [], 'Australia/Sydney') }} AS event_ts,
        document_id,
        document_type_id,
        {{ timestampntz_to_tz('created_date', 'Australia/Sydney') }} AS created_date,
        {#- {{ timestampntz_to_tz('last_updated_date', 'Australia/Sydney') }} AS last_updated_date, #}
        {{ dms_timestampntz_us_to_ns('last_updated_date', ['document_id'], [], 'UTC') }} AS last_updated_date_tmp,
        {{ timestampntz_to_tz('last_updated_date_tmp::timestamp_ntz', 'Australia/Sydney') }} AS last_updated_date,
        parent_document,
        lodgement_id,
        created_by_role_id,
        created_by_susbscriber_id,
        status,
        settlement_id,
        order_of_lodgement,
        is_delete
    FROM lodge_doc_det_pre
    WHERE lodgement_id IS NOT NULL
),
first_lodge_doc_workspace AS (
    SELECT 
        d.document_id,
        l.workspace_id
    FROM lodge_doc_det d
    JOIN {{ ref('dim_lodgement') }} l ON l.id = d.lodgement_id
    WHERE l.workspace_id IS NOT NULL
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY d.document_id ORDER BY d.event_ts)
),
lodge_doc_chg AS (
    SELECT
        l.document_id AS id,
        l.event_ts,
        IFF(l.is_delete, l.event_ts, l.last_updated_date) AS date_changed,
        l.document_type_id,          {#- dim #}
        l.created_date,              {#- dim #}
        l.last_updated_date,
        l.parent_document,           {#- dim #}
        l.lodgement_id,              {#- dim #}
        flw.workspace_id,            {#- dim #}
        l.created_by_role_id,        {#- dim #}
        l.created_by_susbscriber_id, {#- dim #}
        l.status,
        l.settlement_id,
        l.order_of_lodgement,
        l.is_delete
    FROM lodge_doc_det l
    LEFT JOIN first_lodge_doc_workspace flw USING (document_id)
    WHERE (l.lodgement_id IS NOT NULL AND flw.workspace_id IS NOT NULL)
)
SELECT
    l.id,
    l.date_changed,
    l.document_type_id,
    l.created_date,
    l.parent_document,
    l.lodgement_id,
    l.workspace_id,
    l.created_by_role_id,
    l.created_by_susbscriber_id AS created_by_subscriber_id,
    p.id AS participant_id,
    l.status,
    l.settlement_id,
    l.order_of_lodgement,
    l.is_delete
FROM lodge_doc_chg l
LEFT JOIN {{ ref('dim_participant') }} p ON p.workspace_id = l.workspace_id
    AND p.workspace_role_id = l.created_by_role_id
    AND p.subscriber_id = l.created_by_susbscriber_id
{%- if not is_incremental() %}
WHERE l.workspace_id IS NOT NULL
{%- endif %}
QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY l.id, l.date_changed ORDER BY l.event_ts DESC, p.inserted_at)
ORDER BY l.date_changed
