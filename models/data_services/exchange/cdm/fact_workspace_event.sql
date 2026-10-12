{{
    config(
        materialized = 'incremental',
        unique_key = 'id'
    )
}}

SELECT
    id,
    created_date,
    workspace_id,
    business_event_type_id,
    lodgement_case_id,
    subscriber_id,
    user_id,
    username
FROM {{ref('stg_cdm_workspace_event')}}
{%- if is_incremental() %}
WHERE created_date > COALESCE((SELECT MAX(created_date) FROM {{ this }}), '1900-01-01')
{%- endif %}
ORDER BY created_date
