{{
    config(
        materialized = 'incremental',
        unique_key = 'id'
    )
}}

SELECT
    id,
    conversation_id,
    created_at,
    message,
    subscriber_id,
    workspace_role_id,
    user_id,
    action_required
FROM {{ ref('stg_cdm_message_event') }}
{%- if is_incremental() %}
WHERE created_at > COALESCE((SELECT MAX(created_at) FROM {{ this }}), '1900-01-01')
{%- endif %}
ORDER BY created_at
