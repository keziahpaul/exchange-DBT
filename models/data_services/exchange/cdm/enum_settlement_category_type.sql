{{
    config(
        materialized = 'ephemeral'
    )
}}
{#- sourced from core-pexa-app/pexa_core/src/main/java/au/necdl/pexa/core/settlement/SettlementCategoryType.java @release/R.23.01.00 -#}
{#- If you change the structure of this model, you need to update value of the created_on column -#}

WITH enum AS (
    SELECT enum_name, enum_value, is_default
    FROM (VALUES
        ('SOURCE', 'Source', FALSE),
        ('DISBURSEMENT', 'Destination', FALSE),
        ('ADJUSTMENTS', 'Adjustments', FALSE),
        {#- appended for NULL values #}
        ('<NULL>', 'Unknown Settlement Category Type', TRUE)
    ) v(enum_name, enum_value, is_default)
)
SELECT
    '2026-03-17 12:30:00 +10'::timestamp_tz AS created_on,
    is_default,

    enum_name,
    enum_value,

    enum_name = 'SOURCE' AS is_source,
    enum_name = 'DISBURSEMENT' AS is_disbursement,
    IFF(is_default, NULL, LEFT(enum_name, 1)) AS symbol
FROM enum
