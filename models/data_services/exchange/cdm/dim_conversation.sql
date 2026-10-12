{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = 'id',
        merge_update_columns = ['last_message_at']
    )
}}

WITH cnv_src AS (
    SELECT
        c.conversation_id,
        c.subject,
        c.category,
        c.sub_category,
        c.workspace_id,
        MIN(c.created_at) AS created_at,
        MAX(c.created_at) AS last_message_at
    FROM {{ ref('stg_cdm_message_event') }} c
    {%- if is_incremental() %}
    WHERE c.created_at > COALESCE((SELECT MAX(last_message_at) FROM {{ this }}), '1900-01-01')
    {%- endif %}
    GROUP BY ALL
)
SELECT
    conversation_id AS id,
    subject,
    category,
    sub_category,
    workspace_id,
    created_at,
    last_message_at
FROM cnv_src
ORDER BY conversation_id
