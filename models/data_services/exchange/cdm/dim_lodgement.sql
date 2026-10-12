{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = 'id',
        merge_update_columns = ['deleted_at']
    )
}}

{#- all lodgements should only ever have 1 workspace_id -#}

WITH lodgement_src AS (
    SELECT
        id,
        MIN(workspace_id) AS workspace_id,
        MIN(date_changed) AS inserted_at,
        MAX(IFF(is_delete, date_changed, NULL)) AS deleted_at
    FROM {{ ref('stg_cdm_lodgement_event') }}
    {%- if is_incremental() %}
    WHERE date_changed > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(inserted_at)') }} FROM {{ this }}), '1900-01-01')
    {%- endif %}
    GROUP BY id
)
SELECT
    id,
    workspace_id,
    inserted_at,
    deleted_at
FROM lodgement_src
ORDER BY id