{{
    config(
        materialized = 'ephemeral'
    )
}}
{#- sourced from core-pexa-app/pexa_core/src/main/java/au/necdl/pexa/core/settlement/LinkType.java @release/R.23.01.00 -#}
{#- If you change the structure of this model, you need to update value of the created_on column -#}

WITH enum AS (
    SELECT enum_name, enum_value, settlement_type, execution_type, is_default
    FROM (VALUES
        ('SEQUENTIAL_SETTLEMENT', 'Sequential Settlement', 'Sequential Settlement', 'Sequential', FALSE),
        ('SIMULTANEOUS_SETTLEMENT', 'Simultaneous Settlement', 'Simultaneous Settlement', 'Simultaneous', FALSE),
        ('NOT_LINKED', 'Not linked', 'Standalone Settlement', 'Not linked', TRUE),
        ('SEQUENTIAL_LODGEMENT', 'Sequential Lodgement', 'Sequential Lodgement', 'Sequential', FALSE),
        ('SIMULTANEOUS_LODGEMENT', 'Simultaneous Lodgement', 'Simultaneous Lodgement', 'Simultaneous', FALSE)
        {#- does not require a NULL row #}
    ) v(enum_name, enum_value, settlement_type, execution_type, is_default)
)
SELECT
    '2026-03-12 12:30:00 +10'::timestamp_tz AS created_on,
    is_default,

    enum_name,
    enum_value,
    settlement_type,
    execution_type
FROM enum
