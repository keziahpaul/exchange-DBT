{{
    config(
        materialized = 'ephemeral'
    )
}}
{#- sourced from core-pexa-app/pexa_core/src/main/java/au/necdl/pexa/core/settlement/RitsStatus.java @release/R.23.01.00 -#}
{#- If you change the structure of this model, you need to update value of the created_on column -#}

WITH enum AS (
    SELECT enum_name, is_default
    FROM (VALUES
        ('NEW', FALSE),
        ('RESERVED', FALSE),
        ('RESERVING', FALSE),
        ('SETTLING', FALSE),
        ('SETTLED', FALSE),
        ('RECALLING', FALSE),
        ('RECALLED', FALSE),
        ('RECALLING_FAILED', FALSE),
        ('RESERVING_FAILED', FALSE),
        ('SETTLING_FAILED', FALSE),
        ('RESERVING_MANUAL', FALSE),
        ('SETTLING_MANUAL', FALSE),
        ('RESERVING_RETRY', FALSE),
        {#- appended for NULL values #}
        ('<NULL>', TRUE)
    ) v(enum_name, is_default)
)
SELECT
    '2026-03-12 12:30:00 +10'::timestamp_tz AS created_on,
    is_default,

    enum_name,
    
    CASE WHEN enum_name NOT IN ('NEW', 'RESERVING')
         THEN TRUE
         WHEN enum_name = '<NULL>'
         THEN NULL
         ELSE FALSE END AS is_past_reservation
FROM enum