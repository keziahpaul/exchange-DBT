{{
    config(
        materialized = 'ephemeral'
    )
}}
{#- This is a list of known canary subscribers which are "LIVE" in PROD -#}

WITH canary AS (
    SELECT DISTINCT
        s.subscriber_id,
        canary_name
    FROM (VALUES
        ('DUMMY REPRESENTATIVE SUBSCRIBER USED BY PEXA'),
        ('NATIONAL E-CONVEYANCING DEVELOPMENT LIMITED'),
        ('NECDL PTY LTD')
    ) v(canary_name)
    JOIN {{ref('stg_pxa_subscribers')}} s ON s.name = v.canary_name
)
SELECT
    subscriber_id,
    TRUE AS is_canary
FROM canary
