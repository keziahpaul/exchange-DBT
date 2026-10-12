{{
    config(
        materialized = 'incremental',
        unique_key = 'id',
    )
}}

WITH workspace_src AS (
    SELECT DISTINCT
        id,
        workspace_number,
        jurisdiction,
        created_date,
        ws_transaction_type,
        bundle_type
    FROM {{ref('stg_cdm_workspace_status')}}
    {%- if is_incremental() %}
    WHERE created_date > COALESCE((SELECT MAX(created_date) FROM {{ this }}), '1900-01-01')
    {%- endif %}
)
SELECT
    id,
    workspace_number,
    jurisdiction,
    created_date,
    ws_transaction_type,
    bundle_type
FROM workspace_src
ORDER BY id
