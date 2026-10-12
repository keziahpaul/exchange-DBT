{{
    config(
        materialized = 'ephemeral'
    )
}}
{#- sourced from core-pexa-app/pexa_core/src/main/java/au/necdl/pexa/core/workspace/IopWorkspaceLockStatus.java @release/R.23.01.00 -#}
{#- If you change the structure of this model, you need to update value of the created_on column -#}

WITH enum AS (
    SELECT enum_name, enum_value, is_default
    FROM (VALUES
        ('UNLOCKED', 'Unlocked', TRUE),
        ('LOCK_REQUESTED', 'Lock Requested', FALSE),
        ('LOCKED', 'Locked', FALSE)
        {#- does not require a NULL row #}
    ) v(enum_name, enum_value, is_default)
)
SELECT
    '2026-03-10 08:30:00 +10'::timestamp_tz AS created_on,
    is_default,

    enum_name,
    enum_value
FROM enum
