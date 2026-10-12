{{
    config(
        materialized = 'incremental',
        unique_key = ['id', 'created_at']
    )
}}
{#- id is the message_id -#}
{#- value1 is the message -#}

WITH msg_src AS (
    SELECT
        message_id,
        conversation_id,
        {{ timestampntz_to_tz('created', 'Australia/Sydney') }} AS created_at,
        value1 AS message,
        conversation_subscriber_id,
        workspace_role_id,
        author,
        action_required
    FROM {{ ref('stg_pxa_messages') }}
    {%- if is_incremental() %}
    WHERE created > COALESCE((SELECT CAST(MAX(created_at) AS timestamp_ntz) FROM {{ this }}), '1900-01-01')
    {%- endif %}
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY message_id ORDER BY version, extraction_start_ts, transact_seq NULLS FIRST)
),
cnv_src AS (
    SELECT
        c.conversation_id,
        COALESCE(TRIM(c.subject), '<NO SUBJECT>') AS subject,
        c.conversation_category AS category,
        COALESCE(TRIM(c.conversation_sub_category), '<NO SUB CATEGORY>') AS sub_category,
        c.workspace_id
    FROM {{ ref('stg_pxa_conversations') }} c
    {%- if is_incremental() %}
    JOIN (SELECT DISTINCT conversation_id FROM msg_src) m ON c.conversation_id = m.conversation_id
    {%- endif %}
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY c.conversation_id ORDER BY c.version, c.extraction_start_ts, c.transact_seq NULLS FIRST)
),
conv_sub_src AS (
    SELECT
        cs.conversation_subscriber_id,
        cs.subscriber_id
    FROM {{ ref('stg_pxa_conversation_subscribers') }} cs
    {%- if is_incremental() %}
    JOIN (SELECT DISTINCT conversation_subscriber_id FROM msg_src) m ON cs.conversation_subscriber_id = m.conversation_subscriber_id
    {%- endif %}
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY cs.conversation_subscriber_id ORDER BY cs.version, cs.extraction_start_ts, cs.transact_seq NULLS FIRST)
)
SELECT
    m.message_id AS id,
    m.created_at,
    m.conversation_id,
    c.subject,
    c.category,
    c.sub_category,
    c.workspace_id,
    m.message,
    cs.subscriber_id,
    m.workspace_role_id,
    m.author AS user_id,
    m.action_required
FROM msg_src m
JOIN cnv_src c ON m.conversation_id = c.conversation_id
JOIN conv_sub_src cs ON m.conversation_subscriber_id = cs.conversation_subscriber_id
ORDER BY m.created_at
