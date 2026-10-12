{{
    config(
        materialized = 'incremental',
        unique_key = 'id',
    )
}}

WITH sub_src AS (
    SELECT DISTINCT
        id,
        created_date,
        abn,
        acn,
        party_type
    FROM {{ref('stg_cdm_subscriber_event')}}
    {%- if is_incremental() %}
    WHERE created_date > COALESCE((SELECT MAX(created_date) FROM {{ this }}), '1900-01-01')
    {%- endif %}
)
SELECT
    id,
    created_date,
    abn,
    acn,
    party_type
FROM sub_src
ORDER BY id
