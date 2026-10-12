{{
    config(
        materialized = 'ephemeral'
    )
}}
{#- sourced from core-pexa-app/pexa_core/src/main/java/au/necdl/pexa/core/settlement/SettlementDateTimeUpdateActionEnum.java @release/R.23.01.00 -#}
{#- If you change the structure of this model, you need to update value of the created_on column -#}

WITH enum AS (
    SELECT enum_name, enum_value, is_default
    FROM (VALUES
        ('DATE_TIME_SET', 'set new date and time', FALSE),
        ('RESCHEDULED_BY_USER', 'rescheduled by user', FALSE),
        ('RESCHEDULED_BY_SYSTEM', 'rescheduled by system', FALSE),
        ('PROPOSAL_ACCEPTED', 'proposal accepted', FALSE),
        ('RESET_TO_PENDING', 'reset to pending', FALSE),
        {#- This value is used for default value selection in subscriber maintenance. This is not an actual status #}
        ('SETTLEMENT_FAILED', 'settlement failed', TRUE)
    ) v(enum_name, enum_value, is_default)
)
SELECT
    '2026-03-17 12:30:00 +10'::timestamp_tz AS created_on,
    is_default,

    enum_name,
    enum_value
FROM enum
