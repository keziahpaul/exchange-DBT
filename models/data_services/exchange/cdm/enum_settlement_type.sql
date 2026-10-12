{{
    config(
        materialized = 'ephemeral'
    )
}}
{#- sourced from core-pexa-app/pexa_core/src/main/java/au/necdl/pexa/core/settlement/SettlementType.java @release/R.23.01.00 -#}
{#- If you change the structure of this model, you need to update value of the created_on column -#}

WITH enum AS (
    SELECT enum_name, is_default
    FROM (VALUES
        ('ELODGE', FALSE),
        ('REFINANCE', FALSE),
        ('TRANSFER', FALSE),
        ('NON_TRANSFER', FALSE),
        {#- appended for NULL values #}
        ('<NULL>', TRUE)
    ) v(enum_name, is_default)
)
SELECT
    '2026-03-12 12:30:00 +10'::timestamp_tz AS created_on,
    is_default,

    enum_name,
    
    CASE WHEN enum_name IN ('REFINANCE', 'TRANSFER', 'NON_TRANSFER')
         THEN TRUE ELSE FALSE END AS is_esettle,
    CASE WHEN enum_name = 'ELODGE'
         THEN TRUE ELSE FALSE END AS is_elodge
FROM enum