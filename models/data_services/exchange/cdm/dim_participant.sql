{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = 'id',
        merge_update_columns = ['deleted_at']
    )
}}

WITH participant_src AS (
    SELECT
        id,
        workspace_id,
        subscriber_id,
        workspace_role_id,
        workspace_role,
        is_panel_master,
        MIN(inserted_at) AS inserted_at,
        MAX(deleted_at) AS deleted_at
    FROM {{ ref('stg_cdm_participant_event') }}
    WHERE participant_status = 'ACTIVE'
    {%- if is_incremental() %}
      AND inserted_at > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(inserted_at)') }} FROM {{ this }}), '1900-01-01')
    {%- endif %}
    GROUP BY ALL
)
SELECT
    id,
    workspace_id,
    subscriber_id,
    workspace_role_id,
    workspace_role,
    is_panel_master,
    inserted_at,
    deleted_at
FROM participant_src
ORDER BY id
