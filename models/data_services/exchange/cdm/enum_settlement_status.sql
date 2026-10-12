{{
    config(
        materialized = 'ephemeral'
    )
}}
{#- sourced from core-pexa-app/pexa_core/src/main/java/au/necdl/pexa/core/settlement/SettlementStatus.java @release/R.23.01.00 -#}
{#- If you change the structure of this model, you need to update value of the created_on column -#}

WITH enum AS (
    SELECT enum_name, enum_value, is_default
    FROM (VALUES
        ('IN_PREPARATION', 'In Preparation', FALSE),
        ('APPROVED', 'Signed', FALSE),
        ('READY', 'Ready', FALSE),
        ('SETTLING', 'Settling', FALSE),
        ('SETTLED', 'Settled', FALSE),
        ('NOT_REQUIRED', 'Not Required', FALSE),
        ('DISBURSED', 'Disbursed', FALSE),
        ('DISBURSING', 'Disbursing', FALSE),
        ('LOCKED', 'Locked (Sequential Settlement)', FALSE),
        ('SETTLEMENT_HELD', 'Settlement Held', FALSE),
        ('FAILED', 'Failed', FALSE),
        ('ROLLED_BACK', 'ROLLED BACK', FALSE),
        {#- appended for NULL values #}
        ('<NULL>', 'Unknown Settlement Status', TRUE)
    ) v(enum_name, enum_value, is_default)
)
SELECT
    '2026-03-09 18:30:00 +10'::timestamp_tz AS created_on,
    is_default,

    enum_name,
    enum_value,

    CASE WHEN enum_name IN ('SETTLED', 'DISBURSED', 'DISBURSING')
         THEN TRUE ELSE FALSE END AS settled,
    CASE WHEN enum_name IN ('SETTLING', 'SETTLED', 'DISBURSED', 'DISBURSING')
         THEN TRUE ELSE FALSE END AS ge_than_settling,
    CASE WHEN enum_name IN ('APPROVED', 'READY', 'LOCKED', 'SETTLING', 'SETTLED', 'DISBURSED', 'DISBURSING')
         THEN TRUE ELSE FALSE END AS ge_than_signed,
    CASE WHEN enum_name NOT IN ('IN_PREPARATION', 'APPROVED', 'READY', 'FAILED')
         THEN TRUE ELSE FALSE END AS locked,
    CASE WHEN enum_name IN ('IN_PREPARATION', 'APPROVED', 'READY', 'SETTLEMENT_HELD')
         THEN TRUE ELSE FALSE END AS unlocked
    {#- seems like a bug, SETTLEMENT_HELD is both locked and unlocked, but this is the code #}
FROM enum
